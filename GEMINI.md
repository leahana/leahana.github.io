# GEMINI.md

This file serves as the foundational mandate for Gemini CLI working in this Hexo blog repository. Adhere strictly to these rules and workflows.

## Build & Development Commands

### Core Commands
- `pnpm dev`: Start development server (http://localhost:4000)
- `pnpm build`: Generate static site to `public/`
- `pnpm clean`: Clean `public/` folder
- `pnpm preview`: Clean, generate, and serve with drafts

### Content Creation
- `hexo new post <title>`: Create new post in `source/_posts/`
- `hexo new page <name>`: Create new page
- `hexo new draft <title>`: Create draft

### Theme Build
The **Kratos-Rebirth** theme (git submodule) requires a separate build:
- `cd themes/kratos-rebirth && pnpm install && pnpm run build`

## Content Management

### File Naming (CRITICAL)
- **Format**: `YYYY-MM-DD-{kebab-title}.md`
- **Date**: Initial publication date - **NEVER change or rename files** after creation.
- **Purpose**: Stable URLs for RAG knowledge base references.

### Markdown Frontmatter
```yaml
---
layout: post
title: Post Title
date: YYYY-MM-DD HH:mm:ss +0800
categories: [category1, category2]
tags: [tag1, tag2]
description: Optional description
toc: true
---
```

### Update Records (Changelog)
When modifying content, **NEVER rename the file**. Append a row to the "更新记录" table at the end of the post:
```markdown
---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-09 | 初始版本 |
| v1.1 | 2025-01-12 | 补充 XXX 内容 |
```
- `v1.0`: Initial version
- `v1.x`: Content update
- `v2.0`: Major rewrite/restructure

### Directory Structure
- `source/_posts/tech/ai/`: AI / Agent / Prompt 技术文章
- `source/_posts/tech/backend/`: 后端技术文章
- `source/_posts/tech/tools/`: 工具使用与实践
- `source/_posts/tech/tools/tracking/`: 工具更新追踪（持续追加型，每工具一篇）
- `source/_posts/design_patterns/`: Design patterns
- `source/_posts/gaming/`: Game research
- `source/_posts/mindset/`: 思考随笔
- `source/docs/`: Meta documentation (templates, guides)

### Tracking 文章规则

`tools/tracking/` 下的文章为持续追加型日志：
- 已有工具不新建文件，追加新批次（H4）到对应年/季度节下
- 批次格式：`#### YYYY-MM | vA ~ vB`，含版本速览表 + 新特性用法 + 关键 fix
- `categories: [tech, tools, tracking]`

## Image Management

All images are hosted in a separate repository: `leahana/blog-images` and served via jsDelivr CDN.

- **CDN URL Format**: `https:// cdn.jsdelivr.net/gh/leahana/blog-images@dev/{path}`
- **Verification**: `bin/check-images.sh` (triggered by pre-push hook) verifies CDN URLs. 404s block push.

## Security & Integrity

### Secret Scanning
- **Manual**: `pnpm check:secrets`
- **Automatic**: Git hooks in `.githooks/` (pre-commit, pre-push) check for leaked keys/secrets.
- **Activation**: `pnpm hooks:install` (sets `core.hooksPath`).

### Deployment
- Deployment is handled by **GitHub Actions** on push to the `hexo` branch.
- **DO NOT** use `hexo deploy`.

## Technology Stack
- **Hexo**: 8.1.1
- **Package Manager**: pnpm v9+
- **Node.js**: v20
- **Theme**: Kratos-Rebirth
- **Formatting**: markdownlint (follow `.markdownlint.yaml`)

## Common Pitfalls
1. **Renaming files**: Breaks RAG links and permalinks.
2. **Changing dates**: Changes permalinks.
3. **Skipping theme build**: Deployment fails.
4. **Bypassing hooks**: Security risk.

## Project Skills & Special Features
- **Mermaid**: Use ` ```mermaid ` blocks for diagrams.
- **optimize-doc**: Use `source/docs/` for templates and optimization guides.
- **Local Search**: Configured in theme settings.
