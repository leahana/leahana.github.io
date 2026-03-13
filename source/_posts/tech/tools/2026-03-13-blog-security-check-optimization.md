---
layout: post
title: 博客安全检查方案优化——从 Git Hooks 到 AI 审查的多层防护
date: 2026-03-13 00:00:00 +0800
categories: [tech, tools]
tags: [安全, Git Hooks, CI/CD, Claude Code, 博客优化]
toc: true
description: 对 Hexo 博客的安全检查方案进行系统优化，包括 Hooks 版本控制化、密钥检测模式扩展、CI 安全扫描集成，以及 AI 驱动的安全审查命令
---

## 背景

个人博客用 Git Hooks + Bash 正则做密钥泄露检测已经跑了一段时间，基本够用。但遇到几个痛点：

1. `.git/hooks/` 不受版本控制，换环境要手动装
2. 检测模式不够全，缺少 Google、Slack、JWT 等常见格式
3. CI 部署流水线零安全检查，本地漏了就直接上线
4. 缺少 AI 级别的语义安全扫描能力

正好 Anthropic 发布了 Claude Code Security Review 工具，研究了一下，决定把两种方案结合起来做一轮优化。

## 两种方案对比

### 现有方案：Git Hooks + Bash 正则

| 维度 | 评价 |
|------|------|
| 检测方式 | 22 条正则表达式匹配 |
| 检测范围 | 密钥/Token/数据库连接串 + CDN 图片 URL |
| 触发时机 | pre-commit（暂存文件）、pre-push（全量） |
| 优点 | 零延迟、离线可用、无需 API Key、简单可控 |
| 缺点 | 纯文本匹配无语义理解、模式覆盖有限 |

### AI 方案：Claude Code Security Review

| 维度 | 评价 |
|------|------|
| 检测方式 | AI 驱动，上下文语义分析 |
| 检测范围 | 注入攻击、认证/授权、数据泄露、XSS、业务逻辑等 |
| 触发时机 | PR 提交时（GitHub Action）或本地命令 |
| 优点 | 深度语义理解、覆盖 OWASP Top 10、自动假阳性过滤 |
| 缺点 | 需要 API Key（计费）、需网络、扫描耗时较长 |

### 结论

两者**互补而非替代**：

- Bash 正则 → **快速拦截**明显的密钥泄露（第一道防线，毫秒级）
- AI Review → **深度扫描**代码逻辑漏洞（第二道防线，按需触发）

对于 Hexo 博客，代码变更少、安全风险主要是密钥泄露，正则方案已足够。AI 方案作为补充在需要时手动触发。

## 优化内容

### 1. Hooks 版本控制化

**问题**：hooks 在 `.git/hooks/` 目录下，不受版本控制，新环境需手动安装。

**方案**：将 hooks 移到 `.githooks/` 目录，通过 Git 的 `core.hooksPath` 配置指向。

```
.githooks/
├── pre-commit    # 提交前：密钥扫描（暂存文件）
└── pre-push      # 推送前：全量密钥扫描 + 图片 URL 检查
```

安装方式从"生成 hooks 文件"变为"指向 hooks 目录"：

```bash
# 旧方式：复制内容到 .git/hooks/
cat > "$HOOKS_DIR/pre-commit" << 'EOF' ...

# 新方式：指向版本控制的目录
git config core.hooksPath .githooks
```

好处：hooks 代码跟随仓库，`git clone` 后只需 `pnpm hooks:install` 即可。

### 2. 扩展密钥检测模式

原有 22 条正则缺少一些常见服务的密钥格式，新增 4 条：

| 模式 | 说明 | 示例 |
|------|------|------|
| `AIza[0-9A-Za-z_-]{35}` | Google API Key | `AIzaSyA...` |
| `xox[bpors]-[0-9a-zA-Z-]{10,}` | Slack Token | `xoxb-...` |
| `SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}` | SendGrid API Key | `SG.xxx...` |
| `eyJ...\.eyJ...\.xxx` | JWT Token | `eyJhbG...` |

现在共 26 条模式，覆盖主流云服务和认证协议。

### 3. 添加 AI 安全审查命令

新建 `.claude/commands/security-review.md`，在 Claude Code 中通过 `/security-review` 触发。

扫描范围：

1. **密钥与凭证**：全文件扫描，弥补正则遗漏
2. **配置安全**：`_config.yml` 中的敏感设置
3. **脚本注入**：`bin/` 和 `.githooks/` 中的命令注入风险
4. **GitHub Actions**：action 版本锁定、权限范围、日志泄露
5. **依赖风险**：`package.json` 中的已知漏洞包
6. **内容安全**：Markdown 中的内部 URL、邮箱等信息

输出分三级：Critical / Warning / Info，每项附文件路径和修复建议。

### 4. CI 添加安全检查步骤

在 `.github/workflows/deploy.yml` 的 `hexo generate` 前插入密钥扫描：

```yaml
- name: Security check - scan for secrets
  run: pnpm run check:secrets

- name: Generate static site
  run: pnpm run build
```

即使本地 hooks 被跳过（`--no-verify`），CI 也会拦截。形成完整防护链：

```
本地提交 → pre-commit（暂存文件扫描）
本地推送 → pre-push（全量扫描 + 图片检查）
CI 部署  → check:secrets（部署前兜底扫描）
按需触发 → /security-review（AI 深度审查）
```

## 验证

```bash
# 1. 安装 hooks
pnpm hooks:install
# ✅ Git Hooks 安装完成！（使用 .githooks/ 目录）

# 2. 运行密钥扫描（新模式无误报）
pnpm check:secrets
# ✅ 未发现敏感信息

# 3. AI 安全审查（在 Claude Code 中）
/security-review
# → 输出结构化安全报告

# 4. CI 推送后查看 GitHub Actions
# → Security check 步骤通过
```

## 总结

| 优化项 | 改动 | 效果 |
|--------|------|------|
| Hooks 版本控制化 | `.git/hooks/` → `.githooks/` + `core.hooksPath` | 新环境开箱即用 |
| 扩展检测模式 | 22 → 26 条正则 | 覆盖 Google/Slack/SendGrid/JWT |
| AI 安全审查 | 新建 `/security-review` 命令 | 按需深度扫描 |
| CI 安全检查 | `deploy.yml` 加 `check:secrets` 步骤 | 部署前兜底防护 |

四层防护体系：**本地提交 → 本地推送 → CI 部署 → AI 审查**，从快速拦截到深度分析，层层递进。

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-13 | 初始版本 |
