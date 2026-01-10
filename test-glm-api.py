#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GLM-4.7 API 测试脚本
用于验证 API Key 和 Base URL 配置是否正确
"""

import sys
import json
import requests
from typing import Optional

# 颜色输出
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_colored(text: str, color: str = Colors.NC):
    """打印带颜色的文本"""
    print(f"{color}{text}{Colors.NC}")

def test_base_url(base_url: str) -> bool:
    """测试 Base URL 连接"""
    print_colored("\n1️⃣  测试 Base URL 连接...", Colors.BLUE)
    try:
        response = requests.get(base_url, timeout=10)
        status_code = response.status_code
        if status_code in [404, 405]:
            print_colored(f"✅ 连接成功 (HTTP {status_code})", Colors.GREEN)
            print_colored("   注意: 404/405 是正常的，说明服务器可达", Colors.YELLOW)
            return True
        else:
            print_colored(f"⚠️  返回 HTTP {status_code}", Colors.YELLOW)
            return True
    except requests.exceptions.ConnectionError:
        print_colored(f"❌ 连接失败: 无法连接到 {base_url}", Colors.RED)
        print_colored("   可能原因: 网络问题、防火墙、或 URL 错误", Colors.YELLOW)
        return False
    except requests.exceptions.Timeout:
        print_colored("❌ 连接超时", Colors.RED)
        return False
    except Exception as e:
        print_colored(f"❌ 连接错误: {str(e)}", Colors.RED)
        return False

def test_api_call(api_key: str, base_url: str, model_name: str) -> tuple[bool, Optional[dict]]:
    """测试 API 调用"""
    print_colored("\n2️⃣  测试 API 调用...", Colors.BLUE)
    
    url = f"{base_url}/chat/completions"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    
    payload = {
        "model": model_name,
        "messages": [
            {"role": "user", "content": "Hello, 请回复'测试成功'"}
        ],
        "max_tokens": 50
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=30)
        status_code = response.status_code
        print_colored(f"   HTTP 状态码: {status_code}", Colors.BLUE)
        
        try:
            response_data = response.json()
        except:
            response_data = {"raw_response": response.text}
        
        if status_code == 200:
            print_colored("✅ API 调用成功！", Colors.GREEN)
            print_colored("\n📄 响应内容:", Colors.BLUE)
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
            
            # 检查是否包含错误信息
            if "error" in response_data:
                print_colored("\n⚠️  响应中包含错误信息:", Colors.YELLOW)
                print(json.dumps(response_data.get("error", {}), indent=2, ensure_ascii=False))
                return False, response_data
            else:
                print_colored("\n✅ 模型响应正常", Colors.GREEN)
                return True, response_data
                
        elif status_code == 401:
            print_colored("❌ 认证失败 (401 Unauthorized)", Colors.RED)
            print_colored("   可能原因:", Colors.YELLOW)
            print_colored("   - API Key 无效或已过期", Colors.YELLOW)
            print_colored("   - API Key 格式错误", Colors.YELLOW)
            print_colored("   - API Key 权限不足", Colors.YELLOW)
            print_colored("\n响应详情:", Colors.BLUE)
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
            return False, response_data
            
        elif status_code == 403:
            print_colored("❌ 访问被拒绝 (403 Forbidden)", Colors.RED)
            print_colored("   可能原因:", Colors.YELLOW)
            print_colored("   - API Key 没有访问此模型的权限", Colors.YELLOW)
            print_colored("   - 账户余额不足", Colors.YELLOW)
            print_colored("   - IP 地址被限制", Colors.YELLOW)
            print_colored("\n响应详情:", Colors.BLUE)
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
            return False, response_data
            
        elif status_code == 404:
            print_colored("❌ 模型未找到 (404 Not Found)", Colors.RED)
            print_colored("   可能原因:", Colors.YELLOW)
            print_colored(f"   - 模型名称错误（应该是 '{model_name}'，大写）", Colors.YELLOW)
            print_colored("   - Base URL 路径错误", Colors.YELLOW)
            print_colored("   - 该模型在此 API 端点不可用", Colors.YELLOW)
            print_colored("\n响应详情:", Colors.BLUE)
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
            return False, response_data
            
        else:
            print_colored(f"⚠️  未知错误 (HTTP {status_code})", Colors.YELLOW)
            print_colored("\n响应详情:", Colors.BLUE)
            print(json.dumps(response_data, indent=2, ensure_ascii=False))
            return False, response_data
            
    except requests.exceptions.Timeout:
        print_colored("❌ 连接超时", Colors.RED)
        print_colored("   可能原因:", Colors.YELLOW)
        print_colored("   - 网络连接问题", Colors.YELLOW)
        print_colored("   - API 服务器响应慢", Colors.YELLOW)
        print_colored("   - 防火墙阻止连接", Colors.YELLOW)
        return False, None
    except Exception as e:
        print_colored(f"❌ 请求错误: {str(e)}", Colors.RED)
        return False, None

def main():
    """主函数"""
    print_colored("🔍 GLM-4.7 API 连接测试", Colors.BLUE)
    print_colored("=" * 50, Colors.BLUE)
    
    # 配置信息
    BASE_URL = "https://api.z.ai/api/coding/paas/v4"
    MODEL_NAME = "GLM-4.7"
    
    # 获取 API Key
    if len(sys.argv) > 1:
        api_key = sys.argv[1]
    else:
        api_key = input(f"\n请输入你的 GLM API Key: ").strip()
    
    if not api_key:
        print_colored("❌ API Key 不能为空", Colors.RED)
        sys.exit(1)
    
    print_colored("\n📋 配置信息:", Colors.BLUE)
    print_colored(f"  Base URL: {BASE_URL}", Colors.BLUE)
    print_colored(f"  Model: {MODEL_NAME}", Colors.BLUE)
    print_colored(f"  API Key: {api_key[:10]}...{api_key[-4:]}", Colors.BLUE)
    
    # 测试 Base URL
    if not test_base_url(BASE_URL):
        print_colored("\n❌ Base URL 连接失败，无法继续测试", Colors.RED)
        sys.exit(1)
    
    # 测试 API 调用
    success, response_data = test_api_call(api_key, BASE_URL, MODEL_NAME)
    
    print_colored("\n" + "=" * 50, Colors.BLUE)
    if success:
        print_colored("✅ 测试完成 - API 配置正确！", Colors.GREEN)
        print_colored("\n💡 如果测试成功，请在 Cursor 中配置:", Colors.YELLOW)
        print_colored(f"   - Base URL: {BASE_URL}", Colors.YELLOW)
        print_colored(f"   - Model Name: {MODEL_NAME}", Colors.YELLOW)
        print_colored("   - API Key: (你的 API Key)", Colors.YELLOW)
    else:
        print_colored("❌ 测试失败 - 请检查配置", Colors.RED)
        sys.exit(1)

if __name__ == "__main__":
    main()
