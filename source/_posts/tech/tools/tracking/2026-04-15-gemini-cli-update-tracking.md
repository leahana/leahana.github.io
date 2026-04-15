---
layout: post
title: Google Gemini CLI 更新追踪
date: 2026-04-15 10:00:00 +0800
categories: [tech, tools, tracking]
tags: [Gemini CLI, Google, Agent, CLI, 更新追踪]
description: 持续追踪 Google Gemini CLI 的版本更新，记录新特性用法与关键修复。
toc: true
---

> 持续追加型文档，每次工具更新后由 AI 代理追加新批次。
> 主文章参见：{% post_link tech/tools/2026-04-02-gemini-cli-sandbox-and-ghostty-isolation.md 'Gemini CLI Sandbox vs. Ghostty' %}

---

## 2026 年

### Q2（2026-04 ~ 06）

#### 2026-04 | v0.37.0 ~ v0.37.1

**信息截止**：2026-04-15 | **最新 Release**：v0.37.1

| 版本 | 日期 | 一句话 |
|------------|------|--------|
| `v0.37.1` | 2026-04-09 | 动态沙箱扩展、Chapters 叙事流、浏览器 Agent 增强 |
| `v0.37.0` | 2026-04-08 | 初始 v0.37 特性集发布，上下文压缩与后台内存服务 |
| `v0.38.0-p0` | 2026-04-08 | (Preview) 上下文压缩、后台任务监控、计划模式安全增强 |

##### 新特性用法

- **动态沙箱扩展 (Dynamic Sandbox Expansion)**：
  在 Linux 和 Windows 上实现了动态沙箱扩展和 Git worktree 支持，增强了在受限/隔离环境中的开发灵活性。

  ```bash
  # 开启沙箱并结合 Git Worktree 进行大规模重构
  gemini -s -w "Refactor legacy modules with isolation"
  ```

- **章节式叙事流 (Chapters Narrative Flow)**：
  引入了基于工具的主题分组（“Chapters”），将 Agent 的交互按意图和工具使用进行逻辑分组，长会话结构更清晰。

- **增强型浏览器 Agent**：
  新增了持久化会话管理和动态只读工具发现，支持沙箱感知的初始化。

- **上下文压缩服务 (Context Compression Service)**：
  自动优化长对话中的 Token 使用，并落地了后台内存服务，用于自动提取和管理 Skill。

##### 关键 fix

- **计划模式 (Plan Mode) 安全硬化**：Plan Mode 现在默认开启，并在调用 `activate_skill` 或 `web_fetch` 等敏感工具时强制要求用户确认。
- **Linux 沙箱崩溃修复**：修复了因 `ARG_MAX` 限制导致的崩溃问题。
- **Windows 安全修复**：解决了 Windows 下的符号链接绕过漏洞。
- **交互优化**：支持 Windows 终端 Ctrl+Backspace 删除单词，改进工具确认界面的选择布局。

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-04-15 | 初始版本，记录 2026-04 核心更新内容 |
