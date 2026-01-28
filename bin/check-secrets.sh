#!/bin/bash
# 敏感信息检查脚本
# 在提交或推送前检查是否有敏感信息

set -e

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 检查敏感信息...${NC}"

# 检查模式列表
PATTERNS=(
    "password\s*[:=]\s*['\"][^'\"]+['\"]"
    "passwd\s*[:=]\s*['\"][^'\"]+['\"]"
    "api[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
    "apikey\s*[:=]\s*['\"][^'\"]+['\"]"
    "secret[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
    "access[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"
    "refresh[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"
    "auth[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"
    "bearer\s+[A-Za-z0-9\-._~+/]+=*"
    "private[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
    "sk-[a-zA-Z0-9]{32,}"  # Stripe API key
    "ghp_[a-zA-Z0-9]{36,}"  # GitHub personal access token
    "gho_[a-zA-Z0-9]{36,}"  # GitHub OAuth token
    "ghu_[a-zA-Z0-9]{36,}"  # GitHub user token
    "ghs_[a-zA-Z0-9]{36,}"  # GitHub server token
    "ghr_[a-zA-Z0-9]{36,}"  # GitHub refresh token
    "AKIA[0-9A-Z]{16}"      # AWS access key
    "mysql://[^:/]+:[^@]+@"        # MySQL connection string with password
    "mongodb://[^:/]+:[^@]+@"      # MongoDB connection string with password
    "postgresql://[^:/]+:[^@]+@"   # PostgreSQL connection string with password
    "redis://[^:/]+:[^@]+@"        # Redis connection string with password
)

# 需要排除的文件或目录
EXCLUDES=(
    "node_modules/"
    ".git/"
    "public/"
    "package-lock.json"
    "pnpm-lock.yaml"
    "yarn.lock"
    "*.min.js"
    "*.min.css"
    "*.jpg"
    "*.jpeg"
    "*.png"
    "*.gif"
    "*.svg"
    "*.webp"
    "*.ico"
    "*.woff"
    "*.woff2"
    "*.ttf"
    "*.eot"
    "bin/check-secrets.sh"
    ".claude/"
)

# 构建排除参数
EXCLUDE_ARGS=""
for exclude in "${EXCLUDES[@]}"; do
    EXCLUDE_ARGS="$EXCLUDE_ARGS --exclude='$exclude'"
done

FOUND=0

# 二进制文件扩展名列表
BINARY_EXTS="jpg|jpeg|png|gif|svg|webp|ico|woff|woff2|ttf|eot|otf"

# 检查暂存的文件
if [ "$1" = "--staged" ] || [ "$1" = "staged" ]; then
    echo -e "${YELLOW}📋 检查暂存文件...${NC}"
    FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -viE "\.($BINARY_EXTS|min\.js|min\.css)$" | grep -v "_config\." || true)
else
    echo -e "${YELLOW}📁 检查所有文件...${NC}"
    FILES=$(git ls-files | grep -viE "\.($BINARY_EXTS|min\.js|min\.css)$" | grep -v "node_modules/" | grep -v "pnpm-lock.yaml" | grep -v "_config\." || true)
fi

# 应用排除列表
for exclude in "${EXCLUDES[@]}"; do
    FILES=$(echo "$FILES" | grep -v "$exclude" || true)
done

if [ -z "$FILES" ]; then
    echo -e "${GREEN}✅ 没有需要检查的文件${NC}"
    exit 0
fi

# 逐个文件检查
for file in $FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi

    for pattern in "${PATTERNS[@]}"; do
        # 跳过代码块内容 (``` 和 ``` 之间)
        # 使用单引号避免 shell 变量展开问题
        MATCHES=$(awk -v pat="$pattern" '
            /^```/ {flag=!flag}
            !flag && !/^\s*#/ && $0 ~ pat {print}
        ' "$file" 2>/dev/null || true)

        # 对于 base64-like 模式，还需要过滤掉 Markdown 链接中的 URL
        if [[ "$pattern" == *"mysql://"* ]] || [[ "$pattern" == *"mongodb://"* ]] || \
           [[ "$pattern" == *"postgresql://"* ]] || [[ "$pattern" == *"redis://"*
 ]]; then
            # 过滤掉引号内的 URL 和示例连接字符串
            MATCHES=$(echo "$MATCHES" | grep -vE "['\"]?mysql://|['\"]?mongodb://|['\"]?postgresql://|['\"]?redis://" || true)
        fi

        if [ -n "$MATCHES" ]; then
            echo -e "${RED}⚠️  发现潜在敏感信息: $file${NC}"
            echo -e "${RED}   匹配模式: $pattern${NC}"
            echo "$MATCHES" | head -3 | grep -iE --color=always "$pattern"
            echo ""
            FOUND=1
        fi
    done
done

if [ $FOUND -eq 1 ]; then
    echo -e "${RED}❌ 发现敏感信息！请检查后再提交。${NC}"
    echo -e "${YELLOW}💡 提示：如果这些不是敏感信息，可以添加到排除列表中${NC}"
    exit 1
else
    echo -e "${GREEN}✅ 未发现敏感信息${NC}"
    exit 0
fi
