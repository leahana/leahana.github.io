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
├── tech/
│   ├── ai/          # AI / Agent / Prompt 技术文章
│   ├── backend/     # 后端技术文章
│   └── tools/       # 工具使用与实践
│       └── tracking/    # 工具更新追踪（持续追加型文档）
├── design_patterns/ # 设计模式
├── gaming/          # 游戏相关
├── mindset/         # 思考随笔
└── docs/            # Meta 文档（模板、优化指南、格式规范）
```

### Tracking 文章规则（重要）

`tools/tracking/` 下存放持续追加型的工具更新日志，行为约束如下：

- **永远不要新建重复 tracking 文件**：若目标工具已有 tracking 文章，只追加内容
- **追加位置**：找到正确的年份（`## YYYY 年`）和季度（`### Qx`）H3 节，
  在其下新增一个 H4 批次
- **批次标题格式**：`#### YYYY-MM | vA.B.C ~ vX.Y.Z`
- **每个批次固定三段**：版本速览表 + **新特性用法** + **关键 fix**
- **版本速览表首行**：注明 `**信息截止**：YYYY-MM-DD | **最新 Release**：vX.Y.Z`
- **季度不存在时**：先新增 `### Qx（YYYY-MM ~ MM）` H3，再追加批次
- **frontmatter categories**：必须为 `[tech, tools, tracking]`

### Category & Tag Conventions
- **Categories**: Hierarchical, use existing (e.g., `[tech, tools]`, `[tech, ai]`,
  `[tech, tools, tracking]`)
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

### Commit Convention (IMPORTANT)

Use the correct prefix — it determines changelog grouping (articles vs infrastructure):

| Prefix | Use For | Example |
|--------|---------|---------|
| `post:` / `post(scope):` | New blog post | `post(ai): add Kaggle Agent day2 notes` |
| `content:` | Edit existing post | `content: fix MCP heading typo` |
| `page:` | New standalone page | `page: add about page` |
| `feat:` | New infra capability | `feat: add security-review command` |
| `fix:` | Bug fix | `fix: BSD grep regex` |
| `ci:` | CI/CD changes | `ci: add dependabot` |
| `style:` | CSS/theme visual | `style: mermaid background` |
| `chore:` | Config/deps/cleanup | `chore: update submodule` |
| `docs:` | Project docs only | `docs: update AGENTS.md` |

**Do NOT** use `feat:` or `docs:` for new articles — use `post:` instead.

## Technology Stack

- **Hexo**: 8.1.1
- **Package Manager**: pnpm v9+
- **Node.js**: v20
- **Deployment**: GitHub Actions → GitHub Pages
- **Linting**: markdownlint

## Special Features

- **Mermaid diagrams**: Use \`\`\`mermaid\`\`\` blocks
- **optimize-doc companion docs**: `source/docs/`（模板、方法、格式规范）
- **Git hooks**: Auto-check secrets on commit/push
- **Post assets**: `post_asset_folder: true` enabled

## Common Pitfalls

1. **Renaming files**: Breaks RAG links → Use update records
2. **Skipping theme build**: Actions fail → Build locally first
3. **Security hooks**: Commits blocked → Run `pnpm check:secrets` to fix
4. **Changing dates**: Alters permalinks → Keep original date

## Image Management

All images are hosted in a separate repository: `leahana/blog-images`,
served via jsDelivr CDN.

- **CDN URL format**: `https://cdn.jsdelivr.net/gh/leahana/blog-images@dev/{path}`
- **Folder name**: matches post filename (without `.md`)
- **Image names**: `overview.png`, `problem.png`, `solution.png`, `step-N.png`
- **Verification**: `bin/check-images.sh` (triggered by pre-push hook) — 404s
  block push, timeouts are warnings only

**Branch strategy**:
- `dev` branch: daily uploads (use `@dev` in CDN URLs)
- `main` branch: archive only — merge via PR + tag periodically

## Release Process

Releases use **calendar versioning**: `vYYYY.MM` (e.g., `v2026.04`).
Multiple releases in one month: `v2026.04.1`.

**To create a release:**
1. Go to GitHub Actions → **"Create Release"** workflow
2. Click **Run workflow**
3. (Optional) Enter tag, e.g. `v2026.05`. Leave blank to auto-generate.
4. (Optional) Enable `dry_run` to preview changelog without publishing.

**To preview locally** (requires `brew install git-cliff`):
```bash
git cliff --config cliff.toml --unreleased
```

## Project Skills & Commands

Custom skills in `.claude/skills/` (Claude Code) — also informational for
other agents:

| Skill / Command | Description |
|-----------------|-------------|
| `optimize-doc` | 博客型 Markdown 优化工作流，结合模板、优化指南和格式规范使用 |
| `save` | 保存当前对话为 Markdown 文件存档 |
| `/security-review` | AI 驱动安全审查，扫描密钥泄露、配置风险、脚本注入等 |

Reference docs in `source/docs/`:
- `markdown-templates.md` — 起稿模板
- `markdown-optimization-guide.md` — 优化方法
- `markdown-format-check.md` — 格式校验规则
