#!/bin/bash

echo "🔍 Cursor macOS 配置检查"
echo "================================"
echo ""

# 检查 Cursor 版本
echo "1️⃣  Cursor 版本:"
VERSION=$(defaults read com.cursor.Cursor CFBundleShortVersionString 2>/dev/null)
if [ -z "$VERSION" ]; then
    echo "   ⚠️  无法读取版本号（Cursor 可能未安装或使用不同 Bundle ID）"
else
    echo "   ✅ 版本: $VERSION"
fi
echo ""

# 检查配置文件
echo "2️⃣  配置文件位置:"
SETTINGS_FILE="$HOME/Library/Application Support/Cursor/User/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
    echo "   ✅ 配置文件存在: $SETTINGS_FILE"
    echo "   文件大小: $(ls -lh "$SETTINGS_FILE" | awk '{print $5}')"
    echo "   最后修改: $(stat -f "%Sm" "$SETTINGS_FILE")"
else
    echo "   ❌ 配置文件不存在"
fi
echo ""

# 检查 API Key 配置（不显示完整 key）
echo "3️⃣  API Key 配置检查:"
if grep -q "55e1161592d14d4d944ce608af4ec4cf" "$SETTINGS_FILE" 2>/dev/null; then
    echo "   ✅ 检测到 API Key（部分匹配）"
else
    echo "   ⚠️  未在配置文件中找到 API Key（可能存储在加密位置）"
fi
echo ""

# 检查 Base URL
echo "4️⃣  Base URL 检查:"
if grep -q "open.bigmodel.cn" "$SETTINGS_FILE" 2>/dev/null; then
    echo "   ✅ 检测到 Base URL"
    grep -o "https://[^\"']*bigmodel[^\"']*" "$SETTINGS_FILE" 2>/dev/null | head -1 | sed 's/^/   URL: /'
else
    echo "   ⚠️  未找到 Base URL 配置"
fi
echo ""

# 检查模型配置
echo "5️⃣  模型配置检查:"
if grep -qi "GLM-4.7\|glm-4.7" "$SETTINGS_FILE" 2>/dev/null; then
    echo "   ✅ 检测到 GLM-4.7 模型配置"
else
    echo "   ⚠️  未找到 GLM-4.7 模型配置"
fi
echo ""

# 检查文件权限
echo "6️⃣  文件权限:"
if [ -f "$SETTINGS_FILE" ]; then
    PERMS=$(stat -f "%OLp" "$SETTINGS_FILE")
    echo "   权限: $PERMS"
    if [ "$PERMS" = "644" ] || [ "$PERMS" = "600" ]; then
        echo "   ✅ 权限正常"
    else
        echo "   ⚠️  权限可能异常（建议: 644 或 600）"
    fi
fi
echo ""

# 检查缓存
echo "7️⃣  缓存目录:"
CACHE_DIR="$HOME/Library/Application Support/Cursor/Cache"
if [ -d "$CACHE_DIR" ]; then
    CACHE_SIZE=$(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')
    echo "   缓存大小: $CACHE_SIZE"
    echo "   💡 如果问题持续，可以清理缓存"
fi
echo ""

echo "================================"
echo "✅ 检查完成"
echo ""
echo "💡 建议:"
echo "   1. 对比 Windows 上的配置"
echo "   2. 确保所有配置项完全一致"
echo "   3. 如果配置不同，重新配置"
