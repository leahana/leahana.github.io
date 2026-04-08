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
- `pnpm hooks:install` - Configure Git to use `.githooks/` directory for automatic secret checking

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

.githooks/           # Git hooks (version controlled)
├── pre-commit       # Secret scan on staged files
└── pre-push         # Full secret scan + image URL check

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
   - Runs secret scan (`pnpm check:secrets`)
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
- Tokens: `access_token`, `auth_token`, `bearer`, JWT (`eyJ...`)
- Service keys: Stripe (`sk-`), GitHub (`ghp_`, `gho_`, `ghu_`), AWS (`AKIA`), Google (`AIza`), Slack (`xox`), SendGrid (`SG.`)
- Database URLs: `mysql://`, `mongodb://`, `postgresql://`, `redis://`

**Hooks Setup**:

Hooks are version-controlled in `.githooks/` and activated via `core.hooksPath`:

```bash
pnpm hooks:install
```

## Commit Convention & Release Process

### Commit Prefix Rules

Use the correct prefix to separate article content from infrastructure changes. This drives the auto-generated changelog grouping.

| Prefix | Category | When to Use | Example |
|--------|----------|-------------|---------|
| `post:` / `post(scope):` | 📝 新文章 | Brand new blog post | `post(ai): add Kaggle Agent day2 notes` |
| `content:` / `content(scope):` | ✏️ 内容更新 | Edit/improve existing post | `content: fix MCP heading typo` |
| `page:` | 📄 页面 | New standalone page | `page: add about page` |
| `feat:` | 🚀 新功能 | New infrastructure capability | `feat: add security-review command` |
| `fix:` | 🐛 Bug 修复 | Fix broken functionality | `fix: BSD grep regex` |
| `ci:` | ⚙️ CI/CD | Workflow/action changes | `ci: add dependabot monitoring` |
| `style:` | 🎨 样式 | CSS/theme visual changes | `style: mermaid background` |
| `refactor:` | ♻️ 重构 | Code restructure | `refactor: hooks migration` |
| `chore:` | 🔧 维护 | Config/dependency/cleanup | `chore: update submodule` |
| `docs:` | 🔧 维护 | Project docs (README, CLAUDE.md) | `docs: update AGENTS.md` |

**Key rule**: Use `post:` (not `feat:` or `docs:`) for new articles. `docs:` is for project documentation only.

### Release Process (Monthly)

Releases use **calendar versioning**: `vYYYY.MM` (e.g., `v2026.04`). Multiple releases in one month: `v2026.04.1`.

**To create a release:**
1. Go to GitHub Actions → **"Create Release"** workflow
2. Click **Run workflow**
3. (Optional) Enter tag, e.g., `v2026.05`. Leave blank to auto-generate from current month.
4. (Optional) Enable `dry_run` to preview changelog without publishing
5. The workflow will: generate changelog → commit `CHANGELOG.md` → create git tag → create GitHub Release

**To preview locally** (requires `brew install git-cliff`):
```bash
git cliff --config cliff.toml --unreleased
```

**Initial bootstrap tag**: `v2026.04` marks the starting point. Commits before this tag are not tracked.

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

**CRITICAL**: When modifying content, NEVER rename the file. Instead, append a new row to the "更新记录" table at the end of the article:

```markdown
---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-01-09 | 初始版本 |
| v1.1 | 2025-01-12 | 补充 XXX 内容 |
| v1.2 | 2025-01-15 | 修正 YYY 错误 |
```

**版本规则**：`v1.0`=初始版本，`v1.x`=内容修改，`v2.0`=结构重写/重构。新条目追加到表格末尾。

This practice ensures:

1. Stable URLs for RAG knowledge base
2. Complete content modification history
3. No broken links from file renames

### Asset Management

- `post_asset_folder: true` is enabled, allowing post-specific asset folders
- Assets can be placed alongside posts in `source/_posts/<post-name>/`

### Image Management (博客图片管理)

All blog images are hosted in a **separate GitHub repository**: [`leahana/blog-images`](https://github.com/leahana/blog-images) and served via jsDelivr CDN.

**Folder Structure** (in blog-images repo):
```
blog-images/
├── AGENTS.md              ← Image management guidelines
├── tech/
│   ├── ai/
│   │   └── 2026-03-04-ai-api-key-management/
│   │       ├── overview.png
│   │       ├── problem.png
│   │       └── solution.png
│   └── backend/
├── design/
└── common/
```

**Naming Convention**:
- Folder name matches markdown filename (without `.md`)
- Image names: `overview.png`, `problem.png`, `solution.png`, `step-N.png`
- CDN URL format: `https://cdn.jsdelivr.net/gh/leahana/blog-images@dev/{path}`

**Image Reference in Posts**:
```markdown
![image description](https://cdn.jsdelivr.net/gh/leahana/blog-images@dev/tech/ai/2026-03-04-ai-api-key-management/overview.png)
```

**Branch Strategy**:
- `dev` branch: daily image uploads (use `@dev` in CDN URLs)
- `main` branch: archive only — merge via PR + tag periodically (e.g., `v2026.03`)

**Pre-push Image Verification**:
- Before pushing to hexo repo, `bin/check-images.sh` automatically verifies all CDN image URLs
- 404 errors: **blocks push** (image not yet uploaded to blog-images)
- Network timeouts: **warning only** (may be connectivity issue)
- Install/reinstall hooks with: `pnpm hooks:install`

### Drafts

Draft posts are not rendered by default. Use `--drafts` flag with `hexo server` or `hexo generate` to include them.

### optimize-doc Support Docs

The `optimize-doc` workflow has three public companion docs under `source/docs/`:

| Document | Primary Use |
|----------|-------------|
| `markdown-templates.md` | Template entry for starting a new article |
| `markdown-optimization-guide.md` | Method guide for restructuring and improving drafts |
| `markdown-format-check.md` | Rule sheet for final Markdown / frontmatter validation |

**Documentation Structure**:

```
source/docs/
├── markdown-templates.md          # Template companion doc
├── markdown-optimization-guide.md # Method companion doc
└── markdown-format-check.md       # Rule companion doc
```

**When to use each**:

- **Starting from a blank page** → Start with `markdown-templates.md`
- **Improving an existing draft** → Refer to `markdown-optimization-guide.md`
- **Checking Markdown / frontmatter before publish** → Refer to `markdown-format-check.md`

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
| `optimize-doc` | 博客型 Markdown 优化工作流；结合模板、优化指南和格式规范使用 | `source/docs/markdown-templates.md`, `source/docs/markdown-optimization-guide.md`, `source/docs/markdown-format-check.md` |
| `save` | 保存当前对话为 Markdown 文件进行存档 | - |

### Available Commands

| Command | Description |
|---------|-------------|
| `/security-review` | AI 驱动的安全审查，扫描密钥泄露、配置风险、脚本注入等 |

### Usage

```bash
# 安全审查
/security-review

# 优化文档
/optimize-doc path/to/article.md

# 保存对话
/save
```

### Skills vs Global Skills

- Project skills in `.claude/skills/` take precedence over global skills
- This project's skills reference local documentation in `source/docs/`
- Keep global skills minimal, use project-specific skills for blog-related tasks
