# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hexo-based static blog site titled "MamimiJa Nai" (oiiai.top) with Chinese as the primary language. The site is deployed to GitHub Pages via automated GitHub Actions.

## Common Commands

### Development

- `pnpm dev` - Start local development server (default: http://localhost:4000)
- `pnpm build` - Generate static site to `public/` directory
- `pnpm clean` - Clean the `public/` folder
- `pnpm preview` - Clean, generate, and serve with drafts included

### Security Checks

- `pnpm check:secrets` - Manually check for sensitive information in files
- `pnpm hooks:install` - Install Git hooks for automatic secret checking

### Creating Content

- `hexo new post <title>` - Create a new blog post
- `hexo new page <name>` - Create a new page
- `hexo new draft <title>` - Create a draft post

## Architecture

### Directory Structure

```
source/               # Source content directory
├── _posts/          # Blog posts (Markdown files)
├── css/             # Custom styles (custom.styl)
├── images/          # Static images
└── CNAME            # Custom domain configuration

themes/              # Git submodules for themes
├── kratos-rebirth/  # Active theme (custom fork)
└── [other themes]   # Inactive themes

scaffolds/           # Post/page templates (post.md, page.md, draft.md)
scripts/             # Utility scripts (secret checking, hooks installation)
_config.yml          # Main Hexo configuration
_config.kratos-rebirth.yml  # Active theme configuration
```

### Key Configuration Files

- **`_config.yml`** - Main Hexo config: site metadata, URL, theme selection, permalink structure, plugins
- **`_config.kratos-rebirth.yml`** - Theme config: navigation, layouts, widgets, donation system, comments, search
- **`source/css/custom.styl`** - Custom CSS overrides for the theme

### Theme System

The project uses the **Kratos-Rebirth** theme as a git submodule. The theme requires its own build step:

1. `cd themes/kratos-rebirth && pnpm install && pnpm run build`

This is handled automatically by the GitHub Actions workflow.

### Deployment Workflow

1. Source code lives on the `hexo` branch
2. Pushing to `hexo` branch triggers `.github/workflows/deploy.yml`
3. GitHub Actions:
   - Checks out code with submodules
   - Installs pnpm and dependencies
   - Builds theme assets
   - Runs `hexo generate` to create static files
   - Deploys `public/` to GitHub Pages

**Note**: The `hexo deploy` command is NOT used. Deployment is handled entirely by GitHub Actions.

### Security Checks

**CRITICAL**: Before committing or pushing, always check for sensitive information:

**Automatic Checks** (Git Hooks):

- `pre-commit`: Runs automatically before each commit
- `pre-push`: Runs automatically before each push

**Manual Check**:

```bash
pnpm check:secrets
```

**Detection Patterns**:

- Passwords/API keys: `password:`, `apikey:`, `secret:`
- Tokens: `access_token`, `auth_token`, `bearer`
- Service keys: Stripe (`sk-`), GitHub (`ghp_`, `gho_`, `ghu_`), AWS (`AKIA`)
- Database URLs: `mysql://`, `mongodb://`, `postgresql://`, `redis://`

**If Hooks Are Missing**:

```bash
pnpm hooks:install
```

## Content Management

### File Naming Convention

- **Format**: `YYYY-MM-DD-{kebab-title}.md`
- **Date**: Represents initial publication date, NEVER change after creation
- **Purpose**: Stable URL for RAG knowledge base references

### Post Format

Posts are stored in `source/_posts/` with frontmatter:

```yaml
---
layout: post
title: Post Title
date: YYYY-MM-DD HH:mm:ss +0800
categories: [category]
tags: [tag1, tag2]
description: Post description (recommended)
toc: true
---
```

### Update Records (Changelog)

**CRITICAL**: When modifying content, NEVER rename the file. Instead, add an entry to the "更新记录" section at the end of the article:

```markdown
## 更新记录

- 2025-01-09：初始版本
- 2025-01-12：补充 XXX 内容
- 2025-01-15：修正 YYY 错误
```

**Format**: `- YYYY-MM-DD：简短描述本次修改内容`

This practice ensures:

1. Stable URLs for RAG knowledge base
2. Complete content modification history
3. No broken links from file renames

### Asset Management

- `post_asset_folder: true` is enabled, allowing post-specific asset folders
- Assets can be placed alongside posts in `source/_posts/<post-name>/`

### Drafts

Draft posts are not rendered by default. Use `--drafts` flag with `hexo server` or `hexo generate` to include them.

### Article Templates

**Ready-to-use templates** are available in `source/docs/2025-01-12-markdown-templates.md`:

| Template | Use Case | Time Investment |
|----------|----------|----------------:|
| **普通笔记（轻量级）** | Quick notes, ideas, temporary records | 5-15 minutes |
| **问题-方法型技术实战（完整级）** | Solving technical problems with complete solutions | 1-3 hours |

**Documentation Structure**:

```
source/docs/
├── 2025-01-09-markdown-format-check.md      # Format standards
├── 2025-01-09-markdown-optimization-guide.md # Content optimization
└── 2025-01-12-markdown-templates.md         # Article templates ⭐
```

**When to use each**:

- **Quick notes** → Use template 1 (普通笔记)
- **Technical solutions** → Use template 2 (问题-方法型实战)
- **Deep optimization** → Refer to `markdown-optimization-guide.md`
- **Format checking** → Refer to `markdown-format-check.md`

## Special Features

- **Mermaid Diagrams**: Enable with `mermaid` code blocks in posts
- **Local Search**: Configured in theme settings
- **Custom Domain**: Configured via `source/CNAME` (oiiai.top)
- **PJAX**: Partial page loading enabled for smoother navigation
- **Donation System**: Alipay/WeChat QR codes configured in theme config
- **Syntax Highlighting**: Uses highlight.js with line numbers

## Technology Stack

- **Static Site Generator**: Hexo 7.3.0 / 8.1.1
- **Package Manager**: pnpm (requires v9+)
- **Node.js**: v20
- **Theme**: Kratos-Rebirth (custom fork)
- **Deployment**: GitHub Actions + GitHub Pages

## Project Skills

This project includes custom Claude Code skills in `.claude/skills/`:

### Available Skills

| Skill | Description | Reference |
|-------|-------------|-----------|
| `optimize-doc` | 优化 Markdown 文档，提升可读性和实用性 | `source/docs/2025-01-09-markdown-optimization-guide.md` |
| `save` | 保存当前对话为 Markdown 文件进行存档 | - |

### Usage

```bash
# 优化文档
/optimize-doc path/to/article.md

# 保存对话
/save
```

### Skills vs Global Skills

- Project skills in `.claude/skills/` take precedence over global skills
- This project's skills reference local documentation in `source/docs/`
- Keep global skills minimal, use project-specific skills for blog-related tasks
