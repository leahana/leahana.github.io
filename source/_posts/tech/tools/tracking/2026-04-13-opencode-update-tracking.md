---
layout: post
title: OpenCode & oh-my-openagent 更新追踪
date: 2026-04-13 12:00:00 +0800
categories: [tech, tools, tracking]
tags: [OpenCode, oh-my-openagent, AI编程代理, CLI, 更新追踪]
description: 持续追踪 OpenCode 与 oh-my-openagent（原 oh-my-opencode）的版本更新，按季度组织，记录新特性用法与关键修复。
toc: true
---

> 持续追加型文档，每次工具更新后由 AI 代理追加新批次。
> oh-my-openagent 是 OpenCode 的插件平台，两者关联性强，合并追踪。

---

## 2026 年

### Q2（2026-04 ~ 06）

#### 2026-04 | v1.3.14 ~ v1.3.17 (OpenCode) & v3.15.x (oh-my-openagent)

**信息截止**：2026-04-07 | **最新 Release**：OpenCode v1.3.17 / oh-my-openagent v3.15.3

| 版本 | 日期 | 一句话 |
|------|------|--------|
| OpenCode v1.3.14~1.3.17 | 2026-04-07 | git-backed review 恢复，配置能力增强，插件兼容性修复 |
| oh-my-openagent v3.15.x | 2026-04-07 | 重命名兼容层收口，lineage-aware continuation，多 Agent 调度更稳 |

##### 新特性用法

- **git-backed review 恢复（OpenCode）**：运行 `git diff main...HEAD` 后，在 OpenCode 中可以直接按分支差异审查当前改动，支持长分支连续 review。
- **Provider 配置增强（OpenCode）**：Azure 同时兼容 chat / responses；ACP 会话暴露 model / mode；Cloudflare 缺参报错更直接。使用 `{"model":"azure/gpt-5.4"}` 配置。
- **重命名兼容层继续收口（oh-my-openagent）**：自动更新、发布和包名识别继续兼容新旧名称，可通过 `rg -n "oh-my-opencode|oh-my-openagent" ~/.config .` 回查引用。
- **lineage-aware continuation（oh-my-openagent）**：使用 `{"description":"continue refactor","run_in_background":true}` 可以在后台任务结束后继续沿同一 lineage 接力。
- **delegate-task 契约补强（oh-my-openagent）**：参数校验、可调用 agent 模式限制和通知默认值更一致，通过显式传参避免隐式默认行为。

##### 关键 fix

- OpenCode 修复了 revert chain 之后的 snapshot 恢复问题，review 状态能跟着 git diff 一起恢复。
- OpenCode 修复了 OpenAI-compatible provider 在工具调用后 session 卡住的问题。
- OpenCode TUI 支持禁用鼠标捕获，Windows 上 `Ctrl+Z` 改为 undo，kitty 键盘输入处理更稳。
- OpenCode 修复 npm 安装、`node-gyp` 路径与插件解析的兼容性问题。
- oh-my-openagent 在 SDK 不可用时可回退到文件存储，补上 session-last-agent 排序和 background task tracking。
- oh-my-openagent 继续补强 legacy config path 迁移、原子写配置和 auto-update 兼容性。
- oh-my-openagent tar 预检改为 fail-closed，MCP 环境变量清理时屏蔽云凭证，提升安全性。

---

### Q1（2026-01 ~ 03）

#### 2026-Q1 | v1.1.65 ~ v1.3.17 (OpenCode) / v3.x (oh-my-openagent)

**信息截止**：2026-04-03 | **最新 Release**：OpenCode v1.3.17

| 工具 | 版本 | 日期 | 一句话 |
|------|------|------|--------|
| OpenCode | v1.3.17 | 2026-04-03 | 当前追踪截止版本 |
| OpenCode | v1.3.13 | 2026-03 | Effect 架构重构完成，AI SDK v6，Node.js runtime 支持 |
| OpenCode | v1.3.4 | 2026-03 | Session/Config/Plugin/LSP/Skill 五大服务用 Effect 重写 |
| OpenCode | v1.3.0 | 2026-03 | GitLab Agent Platform 集成；单版本 16 位贡献者里程碑 |
| OpenCode | v1.2.0 | 2026-02 | 会话存储迁移至 SQLite 数据库 |
| oh-my-openagent | v3.14.1 | 2026-03 | 兼容层发布；"Atlas Trusts No One" 大拆分落地 |
| oh-my-openagent | v3.x | 2026-03 | 品牌重塑（oh-my-opencode → oh-my-openagent） |
| oh-my-openagent | v3.x | 2026-Q1 | Hash-Anchored Edits 发布（编辑准确率 6.7% → 68.3%） |

##### 新特性用法

- **SQLite 会话迁移（OpenCode v1.2.0）**：升级后删除 `~/.local/share/opencode/opencode.db*` 触发重建；会话量大时启动速度和切换响应明显提升
- **Effect 架构（OpenCode v1.3.4+）**：插件崩溃不再拖垮主进程；插件开发门槛降低，Effect 类型系统可在编译期捕获大部分错误
- **GitLab Agent Platform（OpenCode v1.3.0）**：可直接发现 GitLab workflow 模型并通过 WebSocket 参与 CI/CD 流水线编排
- **Node.js Runtime（OpenCode v1.3.13+）**：不再强绑 Bun，对已有 Node 工具链的团队更友好
- **Hash-Anchored Edits（oh-my-openagent）**：每次编辑前锁定目标文件的 hash，10x 准确率提升（6.7% → 68.3%）；升级后无需额外配置，默认生效
- **多模型编排引擎（oh-my-openagent）**：按任务类型自动路由最优模型；8 Agent 协作系统（Sisyphus 编排 + 7 专家 Agent）
- **`@` 菜单 skills（oh-my-openagent）**：输入 `@` 直接选技能，无需记忆技能名

##### 关键 fix

- OpenCode：SQLite 迁移兼容性处理，旧会话数据完整保留
- OpenCode：Effect 重构后的 Plugin 生命周期稳定性
- oh-my-openagent：v3.14.1 兼容层修复跨版本插件兼容问题
- oh-my-openagent："Atlas Trusts No One" 拆分后的 200 LOC 硬限制防止模块膨胀，提升长期可维护性

> **深度分析：OpenCode，从底层架构到企业级集成**
>
> OpenCode 在 Q1 完成了从 v1.1.65 到 v1.3.13 的跨越式迭代。仅 3 月份就发布了 10 个版本，社区贡献者从个位数飙升到单版本 16 人。这种节奏背后是两个关键决策：底层架构彻底重构，以及企业级功能的大步推进。
> 
> - **SQLite 数据库迁移（v1.2.0）**：会话存储从文件系统迁移到了 SQLite 数据库。这为后续的会话搜索、跨会话引用、统计分析等功能提供了结构化查询基础，大量历史会话时的响应速度有明显提升。
> - **Effect 架构重构（v1.3.4）**：这是 Q1 最大的架构变更。Session、Config、Plugin、LSP、Skill 五大核心服务全部用 Effect 框架重写。每个服务都有统一的错误处理、依赖注入和资源管理。这大大提升了插件稳定性。
> - **GitLab Agent Platform 集成（v1.3.0）**：填补了大型企业市场的空白，通过 WebSocket 访问工具，让 Agent 可以实时监听 CI/CD 流水线状态并在 MR 提交时自动审查代码、建议修复甚至触发回滚。
> - **Node.js Runtime 支持（v1.3.0）**：消除了仅支持 Bun 带来的生态兼容性采纳障碍，对企业标准化 Node.js 环境非常友好。
> - 其他值得关注更新包括：交互式升级流程、多步认证（GitHub Copilot Enterprise）、语法高亮扩展（Kotlin/HCL/Lua/TOML）、TUI 插件系统、插件版本锁定和 Catppuccin 主题支持。

> **深度分析：oh-my-openagent，从插件到架构的进化**
>
> oh-my-openagent 在 Q1 经历了身份和架构的双重转变，从项目名 "oh-my-opencode" 变为 "oh-my-openagent" 代表了其向 "独立 Agent 平台" 的定位跃迁。
>
> - **"Atlas Trusts No One" 大拆分（v3.5.0）**：645 个文件被拆分重构，代码变更量达到 +34,507/-21,492 行。引入 200 行 LOC 硬限制。这极大地提升了稳定性，降低了维护成本。
> - **Hash-Anchored Edits：10 倍准确率提升**：引入了基于行哈希的编辑验证机制。编辑成功率从 6.7% 飙升到 68.3%，是解决 AI 编程代理 "编辑错位" 问题的质变。
> - **多模型编排引擎**：引入了按任务类型自动路由到不同模型的机制：visual-engineering (Gemini)、ultrabrain (GPT-5.4)、quick (GPT-5.4 Mini)、deep (GPT-5.3-codex)。系统自动切换匹配最适合的能力。
> - **8 Agent 协作系统**：构建了 8 个专业化 Agent 的协作网络，Sisyphus 作为编排者协调 7 个专家 Agent（Hephaestus, Prometheus, Atlas, Oracle, Librarian, Explore, Looker）。类似微服务架构在 AI Agent 领域的应用，让复杂项目任务拆解更合理并行执行质量更高。

> **深度分析：综合分析与行动建议**
>
> 两个项目在 Q1 都在做三件相同的事：架构拆分、多模型支持、社区驱动。
> OpenCode 选择了 "底层先行" 策略（重构架构、叠加企业功能），而 oh-my-openagent 选择了 "体验先行" 策略（大拆分、多模型编排）。
>
> 行动建议：
> - OpenCode 老用户：升级到 v1.3.13，删除旧数据库触发迁移。
> - oh-my-openagent 老用户：升级到 v3.14.1，确认兼容层正常。
> - 企业评估者：用 OpenCode GitLab 集成做 PoC。
> - 个人开发者：结合使用，OpenCode 做日常编码，oh-my-openagent 做复杂项目。

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-13 | 初始版本，建立追踪框架；迁移 Q1 精选内容（v1.1.65~v1.3.17） |
| v1.1 | 2026-04-13 | 修正格式规范，使用 H5 标题组织批次段落；合并深度分析内容 |
