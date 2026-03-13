# AGENTS.md

This file guides agentic coding agents working in this Hexo blog repository.

## Build & Development Commands

### Core Commands
```bash
pnpm dev           # Start dev server (http://localhost:4000)
pnpm build         # Generate static site to public/
pnpm clean         # Clean public/ folder
pnpm preview       # Clean + generate + serve with drafts
```

### Content Creation
```bash
hexo new post <title>    # Create new post in source/_posts/
hexo new page <name>     # Create new page
hexo new draft <title>   # Create draft (not rendered by default)
```

### Security & Hooks
```bash
pnpm check:secrets       # Manual sensitive info scan
pnpm hooks:install       # Install git hooks (pre-commit, pre-push)
```

### Theme Build
```bash
cd themes/kratos-rebirth && pnpm install && pnpm run build
```

## Code Style Guidelines

### File Naming (CRITICAL - DO NOT RENAME)
- **Format**: `YYYY-MM-DD-{kebab-title}.md`
- **Date**: Represents initial publication date - NEVER change after creation
- **Purpose**: Stable URLs for RAG knowledge base references

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

### Markdown Formatting
Follow `.markdownlint.yaml`: 80 char line limit (code exempt), allowed HTML: `<details>`, `<summary>`, `<br>`.

### Content Updates (NEVER RENAME FILES)
Append a new row to the "更新记录" table when modifying:
```markdown
---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-09 | 初始版本 |
| v1.1 | 2025-01-12 | 补充 XXX 内容 |
```
Version: `v1.0`=initial, `v1.x`=content update, `v2.0`=rewrite. Chinese, concise.

### Directory Structure
```
source/_posts/
├── tech/backend/    # Technical articles
├── design_patterns/ # Design patterns
├── gaming/          # Game research
└── docs/           # Meta documentation
```

### Category & Tag Conventions
- **Categories**: Hierarchical, use existing (e.g., `tech/backend`)
- **Tags**: Flat, English for tech terms (e.g., `Spring`, `AOP`)

## Architecture

### Theme
- **Active**: Kratos-Rebirth (git submodule)
- **Config**: `_config.kratos-rebirth.yml`
- **Build**: Required in theme directory

### Key Configs
- `_config.yml`: Main Hexo config (site, theme, plugins)
- `_config.kratos-rebirth.yml`: Theme config (nav, widgets, features)
- `source/css/custom.styl`: Custom CSS overrides

### Deployment
1. Push to `hexo` branch
2. GitHub Actions auto-triggers `.github/workflows/deploy.yml`
3. Builds theme + generates site
4. Deploys `public/` to `gh-pages` branch

**Note**: Do NOT use `hexo deploy`.

## Technology Stack

- **Hexo**: 8.1.1
- **Package Manager**: pnpm v9+
- **Node.js**: v20
- **Deployment**: GitHub Actions → GitHub Pages
- **Linting**: markdownlint

## Special Features

- **Mermaid diagrams**: Use \`\`\`mermaid\`\`\` blocks
- **Article templates**: `source/docs/2025-01-12-markdown-templates.md`
- **Git hooks**: Auto-check secrets on commit/push
- **Post assets**: `post_asset_folder: true` enabled

## Common Pitfalls

1. **Renaming files**: Breaks RAG links → Use update records
2. **Skipping theme build**: Actions fail → Build locally first
3. **Security hooks**: Commits blocked → Run `pnpm check:secrets` to fix
4. **Changing dates**: Alters permalinks → Keep original date
