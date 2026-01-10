#!/bin/bash

# GLM-4.7 API 测试脚本
# 用于验证 API Key 和 Base URL 配置是否正确

echo "🔍 GLM-4.7 API 连接测试"
echo "================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否提供了 API Key
if [ -z "$1" ]; then
    echo -e "${YELLOW}⚠️  使用方法: ./test-glm-api.sh YOUR_API_KEY${NC}"
    echo ""
    echo "或者设置环境变量:"
    echo "  export GLM_API_KEY=your_api_key"
    echo "  ./test-glm-api.sh"
    echo ""
    exit 1
fi

# 获取 API Key
API_KEY=${1:-$GLM_API_KEY}
BASE_URL="https://api.z.ai/api/coding/paas/v4"
MODEL_NAME="GLM-4.7"

echo "📋 配置信息:"
echo "  Base URL: $BASE_URL"
echo "  Model: $MODEL_NAME"
echo "  API Key: ${API_KEY:0:10}...${API_KEY: -4}"
echo ""

# 测试 1: 检查 Base URL 连接
echo "1️⃣  测试 Base URL 连接..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL" --max-time 10)

if [ "$HTTP_CODE" == "000" ]; then
    echo -e "${RED}❌ 连接失败: 无法连接到 $BASE_URL${NC}"
    echo "   可能原因: 网络问题、防火墙、或 URL 错误"
    exit 1
elif [ "$HTTP_CODE" == "404" ] || [ "$HTTP_CODE" == "405" ]; then
    echo -e "${GREEN}✅ 连接成功 (HTTP $HTTP_CODE)${NC}"
    echo "   注意: 404/405 是正常的，说明服务器可达"
else
    echo -e "${YELLOW}⚠️  返回 HTTP $HTTP_CODE${NC}"
fi
echo ""

# 测试 2: 测试 API 调用
echo "2️⃣  测试 API 调用..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$BASE_URL/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{
        \"model\": \"$MODEL_NAME\",
        \"messages\": [
            {\"role\": \"user\", \"content\": \"Hello, 请回复'测试成功'\"}
        ],
        \"max_tokens\": 50
    }" \
    --max-time 30)

# 分离响应体和状态码
HTTP_BODY=$(echo "$RESPONSE" | head -n -1)
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)

echo "   HTTP 状态码: $HTTP_CODE"
echo ""

# 检查响应
if [ "$HTTP_CODE" == "200" ]; then
    echo -e "${GREEN}✅ API 调用成功！${NC}"
    echo ""
    echo "📄 响应内容:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
    echo ""
    
    # 检查是否包含错误信息
    if echo "$HTTP_BODY" | grep -q "error"; then
        echo -e "${YELLOW}⚠️  响应中包含错误信息，请检查:${NC}"
        echo "$HTTP_BODY" | grep -o '"error":[^}]*}' | head -1
    else
        echo -e "${GREEN}✅ 模型响应正常${NC}"
    fi
elif [ "$HTTP_CODE" == "401" ]; then
    echo -e "${RED}❌ 认证失败 (401 Unauthorized)${NC}"
    echo "   可能原因:"
    echo "   - API Key 无效或已过期"
    echo "   - API Key 格式错误（缺少 'Bearer ' 前缀等）"
    echo "   - API Key 权限不足"
    echo ""
    echo "响应详情:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
elif [ "$HTTP_CODE" == "403" ]; then
    echo -e "${RED}❌ 访问被拒绝 (403 Forbidden)${NC}"
    echo "   可能原因:"
    echo "   - API Key 没有访问此模型的权限"
    echo "   - 账户余额不足"
    echo "   - IP 地址被限制"
    echo ""
    echo "响应详情:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
elif [ "$HTTP_CODE" == "404" ]; then
    echo -e "${RED}❌ 模型未找到 (404 Not Found)${NC}"
    echo "   可能原因:"
    echo "   - 模型名称错误（应该是 'GLM-4.7'，大写）"
    echo "   - Base URL 路径错误"
    echo "   - 该模型在此 API 端点不可用"
    echo ""
    echo "响应详情:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
elif [ "$HTTP_CODE" == "000" ]; then
    echo -e "${RED}❌ 连接超时${NC}"
    echo "   可能原因:"
    echo "   - 网络连接问题"
    echo "   - API 服务器响应慢"
    echo "   - 防火墙阻止连接"
else
    echo -e "${YELLOW}⚠️  未知错误 (HTTP $HTTP_CODE)${NC}"
    echo ""
    echo "响应详情:"
    echo "$HTTP_BODY" | python3 -m json.tool 2>/dev/null || echo "$HTTP_BODY"
fi

echo ""
echo "================================"
echo "✅ 测试完成"
echo ""
echo "💡 如果测试成功，请在 Cursor 中配置:"
echo "   - Base URL: $BASE_URL"
echo "   - Model Name: $MODEL_NAME"
echo "   - API Key: (你的 API Key)"
