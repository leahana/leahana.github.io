# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Hexo static site generator blog hosted on GitHub Pages at `https://leahana.github.io/yannyi.github.io`. The site deploys to the `gh-pages` branch from the `hexo` working branch.

## Common Commands

```bash
# Create a new post
hexo new "Post Title"

# Clean generated files
pnpm run clean
# or
hexo clean

# Generate static site
pnpm run build
# or
hexo generate

# Start local development server
pnpm run server
# or
hexo server

# Deploy to GitHub Pages
pnpm run deploy
# or
hexo deploy
```

## Configuration Structure

The project uses a multi-theme configuration system with separate config files for each theme:

- `_config.yml` - Main Hexo configuration
- `_config.kratos-rebirth.yml` - Kratos-Rebirth theme config (currently active)
- `_config.next.yml` - NexT theme config (alternate)
- `_config.arknights.yml` - Arknights theme config (alternate)

### Switching Themes

To switch themes, modify two values in `_config.yml`:

```yaml
theme: kratos-rebirth  # or: next, arknights
theme_config: _config.kratos-rebirth.yml  # matching config file
```

All themes are symlinked from `themes/` to external locations in `/Users/anshengyo/Documents/GitHub/hexo-themes/`.

## Architecture

### Directory Structure

```
├── source/
│   ├── _posts/          # Blog posts (Markdown)
│   └── images/          # Site images
├── scaffolds/           # Post templates (post.md, page.md, draft.md)
├── themes/              # Theme symlinks (gitignored)
├── public/              # Generated static files (deployed)
└── _config.yml          # Main Hexo config
```

### Post Front Matter

Posts use YAML front matter. The default post scaffold (`scaffolds/post.md`) includes:

```yaml
---
title: {{ title }}
date: {{ date }}
tags:
---
```

Posts can also include categories, and when `post_asset_folder: true` is set in config, each post gets its own asset folder.

### Key Site Paths

- URL root: `/yannyi.github.io/` (configured in `_config.yml`)
- Images: `/yannyi.github.io/images/`
- The `root` path prefix must be included when referencing local assets

### Deploy Configuration

Deployment uses `hexo-deployer-git` to push to:
- Repository: `https://github.com/leahana/yannyi.github.io`
- Branch: `gh-pages`
- The `public/` directory is NOT gitignored (see `.gitignore` line 6)

### Extensions

Key Hexo plugins installed:
- `hexo-filter-mermaid-diagrams` / `hexo-mermaid` - Mermaid diagram support
- `hexo-toc` - Table of contents generation
- `hexo-renderer-marked` - Markdown rendering
- `hexo-renderer-stylus` - Stylus CSS rendering

Mermaid is configured with CDN: `https://cdn.jsdelivr.net/npm/mermaid@latest/dist/`

### Theme Configuration (Kratos-Rebirth)

The active theme has these notable features:
- PJAX enabled for partial page loads
- Local search enabled
- Image viewer (viewerjs) for lightbox functionality
- Custom CDN path for vendors: `/vendors`
- Chinese language interface
- Sidebar widgets: about, TOC, categories, tags, recent posts
