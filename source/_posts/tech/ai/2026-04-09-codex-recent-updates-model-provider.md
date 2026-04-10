---
layout: post
title: Codex 最近更新速记：模型与 Provider
date: 2026-04-09 12:00:00 +0800
categories: [tech, ai]
tags: [Codex, OpenAI, GPT-5.4, plugin, Agent]
description: 基于 OpenAI 官方 changelog 整理 2026-03-05 到 2026-04-07
  的 Codex 更新，重点记录 GPT-5.4 系列、模型选择器、
  自定义 provider 与插件能力。
toc: true
---

## 📅 [2026-04-09] 增量更新：Codex

**同步版本区间**:
`[未记录（首次建档）]`
-> `[2026-04-07 / Codex model availability update]`
**信息截止日期**: `2026-04-09`

### 📦 已发布版本更新

- **最新 Release**:
  `2026-04-07 / Codex model availability update` (`2026-04-07`)
- **一句话总结**：`2026-03-05` 到 `2026-04-07`
  这一轮更新的核心，不是“又多了一个新按钮”，而是 Codex
  把主力模型收敛到 `GPT-5.4` 系列，同时把 `model`、
  `provider`、`plugins`、`skills`
  和线程检索这几条使用路径串得更清楚了。

### 🚀 核心新特性 (快速掌握)

| 特性 | 价值点 | 💡 使用案例 (Quick Start) |
| :--- | :--- | :--- |
| **`GPT-5.4` 进入 Codex** | 复杂规划、长任务、最终判断有了更强默认模型 | `codex --model gpt-5.4` |
| **`GPT-5.4 mini` 进入 Codex** | 轻量任务、子 Agent、代码库探索更省额度 | `codex --model gpt-5.4-mini` |
| **模型可用性调整** | ChatGPT 登录用户的模型池更收敛，主推 `GPT-5.4` 系列 | 在会话里用 `/model` 切换，或在输入框模型选择器里切换 |
| **自定义 model provider 更正式** | 可以通过 API key 或 provider 接入其他 API 支持模型 | 在 `~/.codex/config.toml` 设置 `model_provider` 与 `[model_providers.<id>]` |
| **Plugins 可安装化** | skill、MCP、app 配置可以打包成可复用工作流 | 创建 `.codex-plugin/plugin.json` 并通过 marketplace 安装 |
| **skills 进入 `@` 菜单** | 不用再死记技能名，插入技能和上下文更快 | 在 composer 中输入 `@` 直接选技能 |
| **历史线程搜索与归档增强** | 过去会话更容易回收复用，不必重复描述上下文 | 用 sidebar/thread search 找旧线程，一键归档本地线程 |

### 🔧 优化与修复 (认知同步)

- **[Model availability]**：`2026-04-07` 起，使用 ChatGPT 登录的
  Codex 模型选择器不再显示 `gpt-5.2-codex`、
  `gpt-5.1-codex-mini`、`gpt-5.1-codex-max`、
  `gpt-5.1-codex`、`gpt-5.1`、`gpt-5`；官方说明会在
  `2026-04-14` 将这些模型从 ChatGPT 登录路径下的 Codex 中移除。
- **💡 认知**：以前看到输入框附近多了 `my_codex`
  这类名字，很容易误会成“新模型”或“新功能”。
  现在更准确的理解是：它通常是自定义 provider 的显示名，来自
  `model_provider` 和 `model_providers.<id>.name`。
  建议：如果要排查“为什么输入框里出现 `my_codex`”，先检查
  `~/.codex/config.toml`。

- **[CLI 0.118.0]**：`2026-03-31` 发布的 `Codex CLI 0.118.0`
  把自定义 provider 能力往前推了一步，支持动态获取和刷新
  短期 bearer token；同时 `codex exec` 支持
  prompt + stdin 组合输入，App Server 客户端也新增了
  device code 登录流。
- **💡 认知**：以前自定义 provider 更像“静态中转配置”；
  现在它更像一条可持续维护的正式接入面。
  建议：如果你是走企业代理、统一网关或短期凭证，
  优先评估动态 token 刷新能力。

- **[App workflow]**：`2026-03-25` 到 `2026-03-24`
  这一段，Codex 增加了插件安装机制、历史线程搜索、
  一键归档项目内本地线程，以及 App 和 VS Code Extension
  之间的关键设置同步。
- **💡 认知**：以前很多能力是“单点可用”；
  现在更像是在形成一套可复用工作流。
  建议：把 plugin、skill、旧线程和设置同步当作
  同一层生产力基础设施来管理。

- **[Composer / Slash commands]**：`2026-03-19` 到 `2026-03-18`
  的 App 更新让 skills 进入 `@` 菜单，并新增切换模型与推理等级的
  slash commands，plan mode 提问也有了更明显的通知。
- **💡 认知**：以前会话内调度模型和技能更依赖记忆；
  现在输入框已经在向“统一调度台”演进。
  建议：把 `/model`、`@skill`
  和线程搜索组合成固定习惯。

### 🧪 Quick Demo

#### 1. 切到 `GPT-5.4` 或 `GPT-5.4 mini`

```bash
codex --model gpt-5.4
codex --model gpt-5.4-mini
```

会话中也可以直接用：

```text
/model
```

#### 2. 看懂 `my_codex` 这类输入框标签

```toml
model_provider = "my_codex"
model = "gpt-5.4"

[model_providers.my_codex]
name = "my_codex"
base_url = "https://your-gateway.example/v1"
wire_api = "responses"
requires_openai_auth = true
```

如果输入框里出现 `my_codex`，优先把它理解成
“当前 provider 的显示名”，而不是一个独立新模型。

#### 3. Plugins 的最小结构

```text
my-plugin/
  .codex-plugin/
    plugin.json
  skills/
  .mcp.json
  assets/
```

这类插件可以把 skill、MCP server 配置和集成入口打包，
适合沉淀团队常用工作流。

### 🧪 主分支未发版变更

- **[本次未单列]**：这篇笔记只采用 OpenAI 官方 changelog
  中已经发布的更新。
- **⚠️ 状态说明**：本次没有把 GitHub 默认分支上的未发版提交
  写入“已落地更新”，避免把实验性改动误记成可直接使用的正式能力。

### ⚠️ 架构变更与风险提醒

- **底层变动**：Codex 现在把“模型”和“provider”
  分得更清楚。
  `GPT-5.4`、`GPT-5.4 mini` 是模型；
  `openai`、`my_codex` 这类是 provider。
- **手动干预**：如果你用 ChatGPT 登录后发现旧模型不见了，
  先按 `2026-04-07` / `2026-04-14` 这两个官方日期判断，
  不要先怀疑本地环境损坏。
- **手动干预**：如果你要用其他 API 支持模型，
  官方建议改走 API key 登录或配置自定义 provider。
- **手动干预**：如果输入框出现 `my_codex`
  一类名称，先检查 `~/.codex/config.toml` 中的
  `[model_providers.<id>].name`。

### 🔗 信号来源

- `Changelog`:
  [OpenAI Developers - Codex changelog](https://developers.openai.com/codex/changelog)
- `Config reference`:
  [OpenAI Developers - Codex config reference](https://developers.openai.com/codex/config-reference)
- `App settings`:
  [OpenAI Developers - Codex app settings](https://developers.openai.com/codex/app/settings)

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-09 | 初始版本，记录 2026-03 到 2026-04 的 Codex 增量更新 |
