---
layout: post
title: Claude Code 更新追踪
date: 2026-04-13 12:00:00 +0800
categories: [tech, tools, tracking]
tags: [Claude Code, Anthropic, CLI, 更新追踪]
description: 持续追踪 Claude Code CLI 的版本更新，按季度组织，记录新特性用法与关键修复。
toc: true
---

> 持续追加型文档，每次工具更新后由 AI 代理追加新批次。
> 主文章参见：[Claude Code Vibecoding 指南](../../ai/2026-03-13-claude-code-cli-vibecoding-guide.md)

---

## 2025 年

### Q4（2025-10 ~ 12）

#### 待补录 | vX.X.X ~ vX.X.X

> 占位，待补录。信号来源：[Anthropic Docs](https://docs.anthropic.com/en/release-notes/claude-code) / [GitHub CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)

---

### Q3（2025-07 ~ 09）

#### 待补录 | 含首次公开发布

> 占位，待补录。Claude Code 首次公开发布约在此季度。

---

### Q2（2025-04 ~ 06）

#### 待补录 | 内测 / 早期版本

> 占位，待补录（如有公开版本）。

---

## 2026 年

### Q2（2026-04 ~ 06）

#### 2026-04 | v2.1.89 ~ v2.1.97

**信息截止**：2026-04-09 | **最新 Release**：v2.1.97

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `v2.1.97` | 2026-04-08 | `NO_FLICKER` 新增 `Ctrl+O` Focus View，状态栏支持 `refreshInterval`，`/agents` 显示子 Agent 数量；集中修了 `--resume`、权限、MCP reconnect、429 重试和 CJK 输入问题 |
| `v2.1.96` | 2026-04-08 | 快速修复 `v2.1.94` 引入的 Bedrock `403 "Authorization header is missing"` 回归 |
| `v2.1.94` | 2026-04-07 | 新增 Amazon Bedrock Mantle 支持；默认 effort 提升为 `high`；插件技能名优先用 frontmatter `name` |
| `v2.1.92` | 2026-04-04 | 新增交互式 Bedrock 配置向导；`/cost` 显示按模型和 cache hit 的拆分；`/release-notes` 变为交互式；移除 `/tag` 和 `/vim` |
| `v2.1.91` | 2026-04-02 | MCP 工具结果持久化上限可放宽；新增 `disableSkillShellExecution`；插件支持 `bin/` 可执行文件 |
| `v2.1.90` | 2026-04-01 | 新增 `/powerup` 交互式教学入口；离线时保留旧 marketplace cache |
| `v2.1.89` | 2026-03-31 | `CLAUDE_CODE_NO_FLICKER=1` 正式提供无闪烁界面；`PreToolUse` hooks 新增 `defer`；`@` 提示支持命名 subagents |

##### 新特性用法

- `NO_FLICKER` 界面：`export CLAUDE_CODE_NO_FLICKER=1` 后启动，按 `Ctrl+O` 打开 Focus View，把 prompt / 工具摘要 / 最终响应整理成更易扫读的结构
- `/powerup` + `/release-notes` + `/cost` + `/effort`：快速摸清新能力、查版本、看成本、调推理强度的固定组合
- Bedrock Mantle：`export CLAUDE_CODE_USE_MANTLE=1` 后启动，在登录界面选 `3rd-party platform`，走交互式配置向导
- 插件 `bin/` 目录：插件现在可打包可执行文件，直接从 Bash tool 调用，越来越接近可复用工具包
- `@` 命名 subagent：composer 输入 `@` 可直接选命名 subagent，减少记忆负担

##### 关键 fix

- `--resume` 恢复链路多版本持续修复（v2.1.97 集中处理）
- CJK 输入法问题（v2.1.97）
- MCP reconnect 稳定性（v2.1.97）
- Bedrock `403` 鉴权回归（v2.1.96 修复 v2.1.94 引入的问题）
- 429 重试逻辑（v2.1.97）

---

### Q1（2026-01 ~ 03）

#### 2026-03 | v2.1.64 ~ v2.1.88

**信息截止**：2026-03-30 | **最新 Release**：v2.1.88

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `v2.1.88` | 2026-03-30 | 优化大型代码库的索引性能；`/cost` 精度提升 |
| `v2.1.85` | 2026-03-26 | **Hooks 成熟**：支持条件 `if` 字段，实现更复杂的自动化流控 |
| `v2.1.84` | 2026-03-25 | 新增 `TaskCreated` / `WorktreeCreate` hook；企业级 `allowedChannelPlugins` 设置 |
| `v2.1.83` | 2026-03-24 | 新增 `CwdChanged` / `FileChanged` hook；支持 `/` 键进行 transcript 全文搜索 |
| `v2.1.81` | 2026-03-20 | **Channels 预览**：引入 `--channels` 研究预览，支持并发会话 |
| `v2.1.80` | 2026-03-19 | Skills/Commands 支持 `effort` frontmatter；插件市场支持 `settings` 源 |
| `v2.1.75` | 2026-03-13 | **语音模式**：稳定性大幅增强，解决长对话音频截断问题 |
| `v2.1.68` | 2026-03-04 | **MCP OAuth**：全面支持 RFC 9728，打通第三方工具授权链路 |

##### 新特性用法

- **条件 Hooks**：在 `CLAUDE.md` 的 hooks 定义中新增 `if: "shell command"` 字段，仅当命令返回 0 时触发 hook。
- **Transcript 搜索**：在交互界面按下 `/` 键，可快速搜索当前会话的历史上下文，对长 Vibecoding session 非常友好。
- **Channels 预览**：通过 `claude --channels` 启动，允许在同一个项目目录下开启多个互不干扰的推理通道。

##### 关键 fix

- 并发会话下的 Token 刷新与重新鉴权逻辑修复 (v2.1.81)
- 改进空闲 75 分钟后的超时提示，防止不必要的 Token 消耗 (v2.1.84)
- `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` 环境污染清理 (v2.1.83)

#### 2026-02 | v2.1.30 ~ v2.1.63

**信息截止**：2026-02-28 | **最新 Release**：v2.1.63

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `v2.1.53` | 2026-02-24 | 安全加固批次：插件隔离增强，防止恶意脚本越权 |
| `v2.1.45` | 2026-02-17 | **插件系统引入**：正式支持从 GitHub/NPM 安装第三方 Plugins |
| `v2.1.40` | 2026-02-12 | 大幅改进 Session Resume 稳定性，减少恢复时的 Context 丢失 |
| `v2.1.30` | 2026-02-03 | **Hooks 基础系统**：首次引入 `PreToolUse` 等生命周期钩子 |

##### 新特性用法

- **插件安装**：支持 `/plugin install <repo>`，开启了 Claude Code 的生态扩展能力。
- **Session 恢复**：`--resume` 成为默认推荐的故障恢复手段，内部优化了状态持久化层。

#### 2026-01 | v2.1.0 ~ v2.1.29

**信息截止**：2026-01-31 | **最新 Release**：v2.1.29

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `v2.1.20` | 2026-01-27 | 优化文件读取工具的 Chunking 策略，支持超大文件扫描 |
| `v2.1.10` | 2026-01-17 | 进入 v2.1 稳定版序列；全新的交互式登录流 |
| `v2.1.0` | 2026-01-07 | **v2.1 时代开启**：核心架构重构，推理速度与准确度显著提升 |

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-13 | 初始版本，建立追踪框架；迁移 v2.1.89~v2.1.97 批次；Q1 占位 |
| v1.1 | 2026-04-13 | 补录 Q1 2026 批次（v2.1.10~v2.1.88）；新增 2025 年占位结构 |
