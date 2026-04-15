---
layout: post
title: Codex 更新追踪
date: 2026-04-13 12:00:00 +0800
categories: [tech, tools, tracking]
tags: [Codex, OpenAI, GPT-5.4, CLI, 更新追踪]
description: 持续追踪 OpenAI Codex 的版本更新，按季度组织，记录新特性用法与关键修复。
toc: true
---

> 持续追加型文档，每次工具更新后由 AI 代理追加新批次。

---

## 2026 年

### Q2（2026-04 ~ 06）

#### 2026-04 | Model Availability Update

**信息截止**：2026-04-09 | **最新 Release**：2026-04-07

| 更新 | 日期 | 一句话 |
|------|------|--------|
| Model pool convergence | 2026-04-07 | GPT-5.4 系列成为主力，支持通过 `codex --model gpt-5.4` 使用；旧版 GPT-5.1/5.2 从 ChatGPT 登录路径移除 |
| GPT-5.4 mini 引入 | 2026-04-07 | 轻量任务、子 Agent、代码库探索更省额度，使用 `codex --model gpt-5.4-mini` |

##### 新特性用法

- **模型收敛感知**：在 Codex App 或 CLI 中，`/model` 默认列表已简化为 GPT-5.4 系列。若需使用特定旧模型或第三方模型，可通过 API key 或 provider 在 `~/.codex/config.toml` 中配置 `[model_providers.<id>]` 接入。
- **自定义 Provider 显示名**：如果输入框里出现 `my_codex` 这类名称，优先把它理解成“当前 provider 的显示名”（来自 `model_providers.<id>.name`），而不是一个独立新模型。

##### 关键 fix

- 明确了自定义 Provider 的显示名称逻辑，解决用户对模型标签的认知困惑。

---

### Q1（2026-01 ~ 03）

#### 2026-03 | CLI 0.118.0 / App Workflow Update

**信息截止**：2026-03-31 | **最新 Release**：0.118.0

| 更新 | 日期 | 一句话 |
|------|------|--------|
| CLI 0.118.0 | 2026-03-31 | 支持动态 Bearer Token 刷新；`codex exec` 支持 prompt + stdin 组合输入 |
| App Workflow | 2026-03-25 | Plugins 可安装化；线程检索增强；App ↔ VS Code 设置同步 |
| Slash Commands | 2026-03-19 | Skills 进入 `@` 菜单；新增 `/model` 快速切换命令 |

##### 新特性用法

- **动态 Token**：在 `config.toml` 中配置 `requires_openai_auth = true`，CLI 会自动 handle 短期凭证的刷新，适合企业代理环境。
```toml
# 自定义 Provider 示例
model_provider = "my_codex"
model = "gpt-5.4"

[model_providers.my_codex]
name = "my_codex"
base_url = "https://your-gateway.example/v1"
wire_api = "responses"
requires_openai_auth = true
```
- **`@` 菜单**：在 Composer 中直接输入 `@` 即可选择已安装的 Skill，无需记忆长指令。
- **Plugins 封装**：创建 `.codex-plugin/plugin.json`，可将 skill、MCP server 配置和 app 设置打包成可复用工作流，通过 marketplace 安装。
- **历史归档**：使用 sidebar 或 thread search 查找旧线程，支持一键归档本地线程，不必重复描述上下文。

##### 关键 fix

- (无重大 fix，聚焦功能增强)

#### 2026-01 ~ 02 | Harness Engineering / GPT-5.3

**信息截止**：2026-02-28 | **最新 Release**：v0.1.x (Stable Beta)

| 更新 | 日期 | 一句话 |
|------|------|--------|
| Harness Engineering | 2026-02-11 | OpenAI 发布核心宣言，定义“Humans steer. Agents execute.”协作范式 |
| GPT-5.3-codex | 2026-01-15 | 深度编码模型发布，大幅提升大规模代码重构的逻辑一致性 |
| App Server Beta | 2026-01-05 | 开启 App Server 跨端同步测试，支持多设备共享 Session 历史 |

##### 新特性用法

- **Harness 理念实践**：强化了“反馈回路”机制，Codex 开始支持在执行工具后根据输出结果自动进行第二轮推理。

##### 关键 fix

- (无)

---

## 2025 年

### Q4（2025-10 ~ 12）

#### 2025-11 ~ 12 | v0.1.x Preview / MCP Integration

**信息截止**：2025-12-30 | **最新 Release**：v0.1.20

| 更新 | 日期 | 一句话 |
|------|------|--------|
| GPT-5.2-codex | 2025-12-08 | 增强多文件读写与 Context 管理能力 |
| Native MCP Support | 2025-11-15 | Codex 原生支持模型上下文协议，打通第三方工具集成 |
| Preview Launch | 2025-10-24 | Codex CLI 进入公共预览阶段 (Public Preview) |

##### 新特性用法

- **MCP 集成**：通过配置文件指定 MCP Server 路径，Codex 可以直接调用外部数据库或 API 文档工具。

##### 关键 fix

- (无)

---

### Q3（2025-07 ~ 09）

#### 2025-08 ~ 09 | v0.0.x Internal Beta

**信息截止**：2025-09-30 | **最新 Release**：v0.0.88

| 更新 | 日期 | 一句话 |
|------|------|--------|
| Initial CLI Release | 2025-09-12 | 首个命令行版本下发至内测用户，支持基础文件操作 |
| GPT-5.1-codex | 2025-08-15 | 早期代码专精模型进入测试池 |

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-13 | 初始版本，建立追踪框架；记录 2026-03~04 批次内容 |
| v1.1 | 2026-04-13 | 补全 2025 Q3 至 2026 Q1 历史更新，覆盖从内测到 GPT-5.4 演进全过程 |
| v1.2 | 2026-04-13 | 修正格式规范，使用 H5 标题组织批次段落；合并深度分析内容 |
