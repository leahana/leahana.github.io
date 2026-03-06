#!/bin/bash
# 图片URL有效性检查脚本
# 在推送前检查文章中引用的CDN图片是否已上传

set -e

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🖼️  检查图片URL...${NC}"

# 获取所有被git追踪的markdown文件（排除 CLAUDE.md，其中含示例 URL）
MD_FILES=$(git ls-files | grep -E "\.md$" | grep -v "^CLAUDE\.md$" || true)

if [ -z "$MD_FILES" ]; then
    echo -e "${GREEN}✅ 没有需要检查的markdown文件${NC}"
    exit 0
fi

BLOCK=0
WARNINGS=0

# 扫描所有markdown文件中的CDN图片URL
while IFS= read -r file; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # 提取所有cdn.jsdelivr.net图片URL，格式: ![...](https://cdn.jsdelivr.net/...)
    URLS=$(grep -oE "https://cdn\.jsdelivr\.net/gh/[^)\"'\s]+" "$file" 2>/dev/null || true)

    if [ -z "$URLS" ]; then
        continue
    fi

    while IFS= read -r url; do
        if [ -z "$url" ]; then
            continue
        fi

        echo -n "  检查: $url ... "

        # 发送HEAD请求检查URL是否可访问，超时5秒
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null || echo "000")

        if [ "$STATUS" = "404" ]; then
            echo -e "${RED}❌ 404 Not Found${NC}"
            echo -e "${RED}   文件: $file${NC}"
            echo -e "${RED}   ⚠️  图片未上传到blog-images仓库，请先上传后再推送${NC}"
            BLOCK=1
        elif [ "$STATUS" = "000" ] || [ -z "$STATUS" ]; then
            echo -e "${YELLOW}⚠️  超时/网络错误${NC}"
            echo -e "${YELLOW}   (网络可能有问题，稍后重试)${NC}"
            WARNINGS=$((WARNINGS + 1))
        elif [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
            echo -e "${GREEN}✅ OK${NC}"
        else
            echo -e "${YELLOW}⚠️  $STATUS${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    done <<< "$URLS"
done <<< "$MD_FILES"

echo ""
if [ $BLOCK -eq 1 ]; then
    echo -e "${RED}❌ 发现未上传的图片，推送已被阻止${NC}"
    echo -e "${YELLOW}💡 解决步骤：${NC}"
    echo "   1. 将图片添加到 https://github.com/leahana/blog-images"
    echo "   2. 等待CDN缓存（通常几秒钟）"
    echo "   3. 重新尝试推送 (git push)"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  检查完成，但有 $WARNINGS 个警告${NC}"
    echo -e "${YELLOW}   如果网络正常，请重试推送${NC}"
    exit 0
else
    echo -e "${GREEN}✅ 所有图片检查通过${NC}"
    exit 0
fi
