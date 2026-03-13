#!/bin/bash
# Git Hooks 安装脚本
# 使用 core.hooksPath 指向版本控制的 .githooks/ 目录

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📦 安装 Git Hooks..."

# 使用 core.hooksPath 指向 .githooks/ 目录（版本控制友好）
git config core.hooksPath .githooks

# 确保 hooks 有执行权限
chmod +x "$PROJECT_ROOT/.githooks/pre-commit"
chmod +x "$PROJECT_ROOT/.githooks/pre-push"

echo "✅ Git Hooks 安装完成！（使用 .githooks/ 目录）"
echo "   - pre-commit: 提交前检查敏感信息"
echo "   - pre-push: 推送前检查敏感信息和图片URL"
