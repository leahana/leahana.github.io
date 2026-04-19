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

#### 2026-04 | 0.119.0 ~ 0.121.0

**信息截止**：2026-04-17 | **最新 Release**：0.121.0（稳定版）

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `0.119.0` | 2026-04-10 | 语音会话默认切到 v2 WebRTC；MCP Apps、远程工作流和 `/resume` 可用性增强 |
| `0.120.0` | 2026-04-11 | Realtime V2 开始支持后台 Agent 进度流；TUI Hook 展示更清晰 |
| `0.121.0` | 2026-04-15 | `codex marketplace add` 上线；记忆控制、MCP 元数据和安全 devcontainer 一起补齐 |

##### 新特性用法

- **安装 Marketplace**：`codex marketplace add` 现在可以直接接
  GitHub、git URL、本地目录和 `marketplace.json` 链接，适合把团队
  插件集成做成一条安装命令。
```bash
codex marketplace add https://github.com/your-org/codex-marketplace
codex marketplace add ./local-marketplace
codex marketplace add https://example.com/marketplace.json
```
- **TUI 历史检索**：在输入框按 `Ctrl+R` 可以反向搜索历史 prompt，
  已接受的 slash command 也会被本地 recall，适合反复调试长 prompt
  或命令链。
```text
Ctrl+R
# 输入关键字，回溯历史 prompt / slash command
```
- **后台 Agent 进度流**：从 `0.120.0` 开始，Realtime V2 会在任务尚未
  结束时持续回传后台 Agent 进度，跟进同一任务时不用再等整轮完成。
```text
开始长任务
查看终端里的增量进度
完成后继续 follow-up
```
- **Memory 控制**：`0.121.0` 增加了记忆模式、重置/删除与扩展清理入口，
  适合在切换项目或排查“旧偏好串味”时主动清空上下文沉淀。
```text
在 TUI / App Server 中关闭 memory
重置或删除已有 memory
清理 memory extension 残留
```

##### 关键 fix

- **MCP 与 App Server 稳定性**：`0.119.0 ~ 0.121.0` 连续修了 MCP
  清理、工具调用元数据、elicitation timeout、`fs/readDirectory`
  遇到坏 symlink 等边角问题，受影响最大的是重度 MCP / plugin 用户和
  app-server 集成方。
- **Sandbox / 权限边角**：修了 Windows elevated sandbox carveout、
  symlinked writable roots、macOS private DNS/proxy、WSL1
  bubblewrap 等问题；之前需要手动降权限或绕开目录结构的场景，
  现在更少了。
- **会话恢复与路径匹配**：修了 `resume --last`、`thread/list`、
  resume picker、当前线程恢复崩溃等问题，尤其对 Windows 路径前缀和
  长时间多线程工作流更重要。

**预发布观察**（截至 2026-04-17）：
- 2026-04-16 发布 `0.122.0-alpha.3`，GitHub 公开 release 页未展示
  详细 notes；目前只能确认它是 `0.121.0` 之后的新预发布标签，
  建议等稳定版或 compare 页面补全后再纳入正式批次。

---

#### 2026-04 | App 26.415

**信息截止**：2026-04-17 | **最新 Release**：26.415

| 更新 | 日期 | 一句话 |
|------|------|--------|
| App 26.415 | 2026-04-16 | Codex App 扩成更完整工作台：in-app browser、computer use、无项目 chats、thread automations、PR review 与 artifact viewer 同步上线 |

##### 新特性用法

- **In-app browser 验证页面**：现在可以直接在 Codex App 里打开本地
  或公网页面，在渲染结果上评论，再让 Codex 按页面级反馈继续修改，
  比“截图再转述”更顺手。
```text
打开本地预览页
直接在页面上评论问题
让 Codex 根据评论继续修正
```
- **无项目目录 Chats + Thread Automations**：现在可以先开线程做调研、
  写作、方案拆解，再决定要不要落到仓库；需要定时回来看结果时，
  可以给同一线程挂 automation，而不是新开会话重讲上下文。
```text
先开 chat 做资料整理
需要晚点跟进时，为当前线程添加 automation
```
- **PR Review + Artifact Viewer**：App 侧边栏已经能看 GitHub PR、
  review comment、改动文件和生成物预览，适合一边看 diff 一边让 Codex
  解释评论、补修改、核对 PDF / 表格 / 文档类输出。
```text
在侧边栏打开 PR 或 artifact
查看 diff / 评论 / 预览
让 Codex 继续修改或解释
```
- **Computer Use**：Codex 现在可以在 macOS 上看、点、输，适合 GUI
  Only 的原生应用测试或模拟器流程；官方说明该功能首发不在 EEA、
  英国和瑞士开放。

##### 关键 fix

- **线程与工具渲染改进**：官方在这条更新里明确提到 improved thread
  and tool rendering，长任务过程中侧边栏和工具结果的可读性更好了。
- **工作流衔接更顺**：Chats 不再要求先选项目目录，很多“先研究、后落地”
  的场景少了一次 setup 跳转，属于明显的流程摩擦修复。

---

#### 2026-04 | 0.122.0-alpha.5（预发布观察）

**信息截止**：2026-04-17 | **最新 Release**：0.122.0-alpha.5（预发布）

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `0.122.0-alpha.3` | 2026-04-16 18:09 | 当天首个 `0.122.0` 预发布标签出现，但公开 release 页未附说明 |
| `0.122.0-alpha.5` | 2026-04-16 23:47 | 同日继续滚到 `alpha.5`，说明这一轮预发布仍在快速烘焙 |

##### 新特性用法

- **暂无公开新特性说明**：GitHub 公开 release 页当前只确认了更新到
  `0.122.0-alpha.5`，没有同步放出 release notes；现阶段更稳妥的做法
  是继续按 `0.121.0` 的命令集和配置使用。
```text
生产环境继续使用 0.121.0
关注下一个稳定版或 compare / notes 补全
```
- **预发布解读方式**：如果你只是追踪趋势，可以把这次变化理解成
  “`0.121.0` 之后又做了同日连续预发布”；在没有 notes 之前，
  不建议把具体功能或 fix 写成已确认结论。

##### 关键 fix

- **暂无可确认 fix 明细**：公开 release 页面没有列出 `alpha.3` 到
  `alpha.5` 的功能项或修复项，因此现阶段不能把任何 PR 直接写成已落地
  结论。
- **升级建议偏保守**：同一天从 `alpha.3` 快速推进到 `alpha.5`，
  更像预发布烘焙过程；追求稳定的用户建议等待下一个正式 release。

---

#### 2026-04 | 0.122.0-alpha.6 ~ 0.122.0-alpha.10（预发布）

**信息截止**：2026-04-19 | **最新 Release**：0.122.0-alpha.10（预发布）

| 版本 | 日期 | 一句话 |
|------|------|--------|
| `0.122.0-alpha.6` | 2026-04-17 12:36 | 预发布继续滚到 `alpha.6`，GitHub 公开 release 页仍未附 notes |
| `0.122.0-alpha.7` | 2026-04-17 16:19 | 同日继续迭代到 `alpha.7`，说明这一轮 `0.122.0` 仍在高频烘焙 |
| `0.122.0-alpha.8` | 2026-04-17 20:19 | 晚间继续推进到 `alpha.8`，主分支开始出现 thread history 与 plugin UX 相关提交 |
| `0.122.0-alpha.9` | 2026-04-17 23:17 | 同日晚间滚到 `alpha.9`，但公开 release notes 依旧缺席 |
| `0.122.0-alpha.10` | 2026-04-18 06:26 | 当前最新公开 prerelease；已能看到 marketplace remove、thread 历史分页与 `/status` 细化等信号 |

##### 新特性用法

- **移除 Marketplace 条目**：从 `#17752` 的 merged commit 可以确认，
  预发布里已经补上 remove 流程，而且 CLI 解析测试显示命令挂到
  `codex plugin marketplace remove` 命名空间下；由于稳定版 changelog
  仍写 `codex marketplace add`，这一点更适合先按“预发布观察”理解。
```bash
codex plugin marketplace remove debug
```
- **分页拉取线程与 turn 历史**：`codex-rs/app-server/README.md`
  已写明 `thread/list` 新增 `sortKey`、`sortDirection`、
  `backwardsCursor`，并补了 `thread/turns/list` 示例，做自定义历史面板
  或二次集成会更顺手。
```json
{ "method": "thread/list", "id": 20, "params": {
  "limit": 25,
  "sortKey": "updated_at",
  "sortDirection": "desc"
} }

{ "method": "thread/turns/list", "id": 24, "params": {
  "threadId": "thr_123",
  "limit": 50,
  "sortDirection": "desc"
} }
```
- **命令面板与插件目录更可见**：从 merged commit 标题可见，
  `/plugins` 正在补 inline enablement toggles 与 tabbed marketplace
  menu，`/status` 也会展示默认 reasoning；这些都属于“少切菜单、
  少猜状态”的交互收敛。
```text
/plugins
# 直接启用 / 禁用已安装插件
# 在 marketplace 标签查看可装条目

/status
# 确认当前默认 reasoning / effort
```

##### 关键 fix

- **`apply_patch` / 文件系统 helper**：`#18296` 修了 fs sandbox
  helper 对 `apply_patch` 的处理，`#18380` 又补了 exec-server 保留
  fs helper runtime env；受影响最大的是依赖 workspace-write 或
  external sandbox 的编辑流。
- **插件与跨仓来源边角**：`#18449` 补了未安装 cross-repo plugin
  read 的提示，`#17277` 和 `#18017` 则把 remote plugin fields /
  cross-repo sources 往 API 与 marketplace manifest 里推，说明
  插件来源与跨仓场景正在继续收敛。
- **信任门与执行策略**：`#14718` 修了 project hooks 与 exec policies
  的 trust-gate 判定，少一类“项目已可信却还被错误拦住”的审批摩擦。
- **启动性能**：`#18370` 把 startup skills refresh 延后，skill /
  plugin 较多的环境启动压力更小。

**主分支未发版** (截至 2026-04-19)：
- PR #18325: 回滚“只在 request 边界清空 mailbox”的尝试，说明消息边界
  处理还在继续收敛
- PR #18386: 图片输出默认改为 `high detail`，视觉结果更细，但也可能更
  耗时
- PR #18499: 当前工作目录不可用时修复 plugin cache panic，适合频繁切
  目录或清理工作区的人关注
- PR #18212: executor-backed MCP stdio 进入第 5/6 步，MCP stdio
  底层仍在继续重构

这些内容已进入主分支但尚未发版，需等待下个 Release 或自行评估源码安
装。

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
| v1.3 | 2026-04-17 | 追加 0.119.0 ~ 0.121.0 稳定版增量，并补记 0.122.0-alpha.3 预发布观察 |
| v1.4 | 2026-04-17 | 追加 App 26.415 批次，并补记同日滚到 0.122.0-alpha.5 的最新预发布观察 |
| v1.5 | 2026-04-19 | 追加 0.122.0-alpha.6 ~ alpha.10 预发布批次，并补记 alpha.10 之后的主分支未发版观察 |
