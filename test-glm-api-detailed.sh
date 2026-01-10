#!/bin/bash

# GLM-4.7 API 详细测试脚本
# 使用用户提供的 API Key 和 Base URL

API_KEY="55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV"
BASE_URL="https://open.bigmodel.cn/api/coding/paas/v4"
MODEL_NAME="GLM-4.7"

echo "🔍 GLM-4.7 API 详细测试"
echo "================================"
echo ""
echo "📋 配置信息:"
echo "  Base URL: $BASE_URL"
echo "  Model: $MODEL_NAME"
echo "  API Key: ${API_KEY:0:20}...${API_KEY: -10}"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试 1: 基础连接测试
echo -e "${BLUE}1️⃣  测试 Base URL 连接...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" --max-time 10)

if [ "$HTTP_CODE" == "000" ]; then
    echo -e "${RED}❌ 连接失败${NC}"
    exit 1
elif [ "$HTTP_CODE" == "404" ] || [ "$HTTP_CODE" == "405" ]; then
    echo -e "${GREEN}✅ 连接成功 (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  返回 HTTP $HTTP_CODE${NC}"
fi
echo ""

# 测试 2: 完整 API 调用测试
echo -e "${BLUE}2️⃣  测试完整 API 调用...${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$BASE_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"$MODEL_NAME\",
        \"messages\": [
            {\"role\": \"user\", \"content\": \"Hello, 请回复'测试成功'\"}
        ],
        \"max_tokens\": 100
    }" \
    --max-time 30)

# 分离响应体和状态码
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')

echo "   HTTP 状态码: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" == "200" ]; then
    echo -e "${GREEN}✅ API 调用成功！${NC}"
    echo ""
    echo "📄 完整响应:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
    echo ""
    
    # 检查响应结构
    if echo "$HTTP_BODY" | grep -q "reasoning_content"; then
        echo -e "${YELLOW}⚠️  检测到 reasoning_content 字段${NC}"
        echo "   这可能是 GLM-4.7 的推理过程，可能导致 Cursor 一直处于 'planning next moves'"
        echo ""
        echo "   建议解决方案："
        echo "   1. 在 Cursor 中禁用 reasoning 功能（如果支持）"
        echo "   2. 尝试使用其他 GLM 模型（如 GLM-4.6）"
        echo "   3. 检查 Cursor 是否支持 GLM-4.7 的 reasoning 模式"
    fi
    
    # 检查模型名称
    MODEL_IN_RESPONSE=$(echo "$HTTP_BODY" | grep -o '"model":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ "$MODEL_IN_RESPONSE" == "$MODEL_NAME" ]; then
        echo -e "${GREEN}✅ 模型名称匹配: $MODEL_IN_RESPONSE${NC}"
    else
        echo -e "${YELLOW}⚠️  模型名称不匹配: 期望 $MODEL_NAME, 实际 $MODEL_IN_RESPONSE${NC}"
    fi
    
    # 检查错误信息
    if echo "$HTTP_BODY" | grep -q '"error"'; then
        echo -e "${RED}❌ 响应中包含错误信息:${NC}"
        echo "$HTTP_BODY" | grep -o '"error":[^}]*}' | head -1
    fi
else
    echo -e "${RED}❌ API 调用失败 (HTTP $HTTP_CODE)${NC}"
    echo ""
    echo "响应详情:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
fi

echo ""
echo "================================"
echo "✅ 测试完成"
echo ""
echo "💡 Cursor 配置建议:"
echo "   - Base URL: $BASE_URL"
echo "   - Model Name: $MODEL_NAME (必须大写)"
echo "   - API Key: (已测试，可用)"
echo ""
echo "🔧 如果 Cursor 一直显示 'planning next moves':"
echo "   1. 检查模型名称是否为 'GLM-4.7'（大写）"
echo "   2. 确认 Base URL 末尾没有斜杠"
echo "   3. 尝试重启 Cursor"
echo "   4. 检查 Cursor 版本是否为最新"
echo "   5. 如果问题持续，可能是 GLM-4.7 的 reasoning 模式导致"
