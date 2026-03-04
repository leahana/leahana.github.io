#!/bin/bash
# Git Hooks 安装脚本
# 将项目中的 hooks 安装到 .git/hooks/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "📦 安装 Git Hooks..."

# 创建 pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# Pre-commit hook: 检查敏感信息

bash bin/check-secrets.sh --staged
EOF

chmod +x "$HOOKS_DIR/pre-commit"

# 创建 pre-push hook
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash
# Pre-push hook: 推送前检查敏感信息和图片URL

echo "🔄 推送前检查..."
bash bin/check-secrets.sh
bash bin/check-images.sh
EOF

chmod +x "$HOOKS_DIR/pre-push"

echo "✅ Git Hooks 安装完成！"
echo "   - pre-commit: 提交前检查敏感信息"
echo "   - pre-push: 推送前检查敏感信息"
