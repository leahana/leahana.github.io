# GLM-4.7 Cursor IDE 配置与排查指南

## 📋 问题描述

- 使用 GLM-4.7 模型
- 检查重写的 OpenAI key 是否可用
- 排查选择 GLM-4.7 后一直 "planning next moves" 的问题

---

## 🔧 配置步骤

### 1. 检查 Cursor 版本

确保使用最新版本的 Cursor IDE（建议 2.1.50+），旧版本可能存在 bug。

**检查方法：**
- macOS: `Cursor` → `About Cursor`
- 或访问：https://www.cursor.so/ 下载最新版

### 2. 配置 GLM-4.7 模型

#### Step 1: 打开设置
- 点击右上角 ⚙️ **Settings** 图标
- 或使用快捷键：
  - macOS: `Cmd+Shift+J`
  - Windows/Linux: `Ctrl+Shift+J`

#### Step 2: 进入 Models 设置
- 在设置菜单中，选择 **"Models"** 标签页

#### Step 3: 配置 API Key 和 Base URL
在 **"API Keys"** 部分：

1. ✅ 启用 **"OpenAI API Key"**
2. ✅ 启用 **"Override OpenAI Base URL"**
3. 输入你的 OpenAI API Key（GLM 的 API key）
4. 设置 Base URL 为：
   ```
   https://api.z.ai/api/coding/paas/v4
   ```

#### Step 4: 添加自定义模型
1. 点击 **"+ Add Custom Model"**
2. 配置参数：
   - **Protocol**: 选择 `OpenAI Protocol`
   - **Model Name**: 输入 `GLM-4.7`（⚠️ **必须大写**）
3. 点击 **Save** 保存

#### Step 5: 选择模型
- 返回主界面
- 在模型选择器中选择 `GLM-4.7`

---

## 🔍 排查 "Planning Next Moves" 问题

### 问题原因分析

"Planning next moves" 一直卡住可能由以下原因导致：

1. **代码库索引问题** - Cursor 正在索引大型代码库
2. **模型配置错误** - API key 或 Base URL 配置不正确
3. **网络连接问题** - 无法连接到 GLM API
4. **模型响应超时** - GLM API 响应慢或超时
5. **Cursor 版本 bug** - 旧版本存在已知问题

### 排查步骤

#### ✅ Step 1: 验证 API Key 是否可用

**方法 1: 使用 curl 测试**

```bash
curl https://api.z.ai/api/coding/paas/v4/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "GLM-4.7",
    "messages": [
      {"role": "user", "content": "Hello"}
    ]
  }'
```

**预期响应：**
- ✅ 成功：返回 JSON 格式的响应
- ❌ 失败：返回错误信息（401/403/404 等）

**方法 2: 检查 Cursor 日志**

1. 打开 Cursor
2. macOS: `Cmd+Shift+P` → 输入 "Developer: Toggle Developer Tools"
3. 查看 Console 标签页的错误信息

#### ✅ Step 2: 检查模型名称

⚠️ **重要：模型名称必须完全匹配**

- ✅ 正确：`GLM-4.7`
- ❌ 错误：`glm-4.7`、`GLM4.7`、`glm-4-7`

#### ✅ Step 3: 检查 Base URL

确保 Base URL 完全正确：
```
https://api.z.ai/api/coding/paas/v4
```

**常见错误：**
- ❌ `https://api.z.ai/api/coding/paas/v4/`（末尾多了斜杠）
- ❌ `https://api.z.ai/api/coding/paas/v3`（版本错误）

#### ✅ Step 4: 检查代码库索引

如果代码库很大，索引可能需要时间：

1. **查看索引状态：**
   - 右下角查看是否有 "Indexing..." 提示
   - 等待索引完成

2. **排除不必要的目录：**
   - 在项目根目录创建 `.cursorignore` 文件
   - 添加不需要索引的目录：
     ```
     node_modules/
     .git/
     dist/
     build/
     *.log
     ```

#### ✅ Step 5: 重启 Cursor

1. 完全退出 Cursor（macOS: `Cmd+Q`）
2. 重新启动 Cursor
3. 重新选择 GLM-4.7 模型

#### ✅ Step 6: 检查网络连接

```bash
# 测试 API 连接
ping api.z.ai

# 测试 HTTPS 连接
curl -I https://api.z.ai/api/coding/paas/v4
```

#### ✅ Step 7: 尝试简化测试

1. 关闭当前项目
2. 创建一个新的空文件夹
3. 在新文件夹中测试 GLM-4.7
4. 如果新文件夹中正常，说明是原项目的问题

---

## 🚨 常见问题与解决方案

### 问题 1: API Key 无效

**症状：**
- 401 Unauthorized
- 403 Forbidden

**解决方案：**
1. 确认 API key 是否正确复制（无多余空格）
2. 确认 API key 是否已激活
3. 联系 GLM 服务商确认 key 状态

### 问题 2: Base URL 错误

**症状：**
- 404 Not Found
- Connection refused

**解决方案：**
1. 确认 Base URL 完全匹配：`https://api.z.ai/api/coding/paas/v4`
2. 检查是否有代理/VPN 影响连接
3. 尝试直接访问 Base URL 测试

### 问题 3: 模型名称错误

**症状：**
- 模型选择后无响应
- "Model not found" 错误

**解决方案：**
1. 确认模型名称是 `GLM-4.7`（大写）
2. 检查 GLM 文档确认正确的模型名称
3. 尝试其他 GLM 模型（如 GLM-4.6V）

### 问题 4: Cursor 内置模型失效

**症状：**
- 配置自定义 API 后，Cursor 内置模型无法使用

**原因：**
- 启用 "Override OpenAI Base URL" 后，Cursor 会将所有模型请求路由到自定义 URL

**解决方案：**
1. 需要切换模型时，临时禁用 "Override OpenAI Base URL"
2. 或使用多个 Cursor 配置文件

### 问题 5: 代码库索引卡住

**症状：**
- 一直显示 "Indexing..." 或 "Planning next moves"

**解决方案：**
1. 创建 `.cursorignore` 排除大文件
2. 重启 Cursor
3. 如果项目太大，考虑拆分项目

---

## 📝 配置检查清单

在开始使用前，确认以下所有项：

- [ ] Cursor 版本是最新的（2.1.50+）
- [ ] 已订阅 Cursor Pro（自定义 API 需要 Pro）
- [ ] API Key 已正确输入（无多余空格）
- [ ] "Override OpenAI Base URL" 已启用
- [ ] Base URL 设置为：`https://api.z.ai/api/coding/paas/v4`
- [ ] 模型名称设置为：`GLM-4.7`（大写）
- [ ] 已通过 curl 测试 API 可用性
- [ ] 网络连接正常
- [ ] 已重启 Cursor

---

## 🔗 相关资源

- [Cursor 官方文档 - API Keys](https://docs.cursor.com/advanced/api-keys)
- [GLM 官方文档](https://docs.z.ai/)
- [Cursor 社区论坛](https://forum.cursor.com/)

---

## 💡 额外提示

1. **GLM-4.7 特性：**
   - 主要支持文本处理
   - 不支持图像输入
   - 如需图像分析，使用 GLM-4.6V

2. **功能限制：**
   - Tab Completion 可能不支持自定义模型
   - Apply from Chat 可能需要特定模型
   - Composer 功能可能受限

3. **性能优化：**
   - 使用 `.cursorignore` 减少索引时间
   - 定期清理 Cursor 缓存
   - 保持 Cursor 更新到最新版本

---

## 📞 如果问题仍未解决

1. **查看 Cursor 日志：**
   - 打开 Developer Tools（`Cmd+Shift+P` → "Developer: Toggle Developer Tools"）
   - 查看 Console 和 Network 标签页

2. **联系支持：**
   - Cursor 社区论坛：https://forum.cursor.com/
   - GLM 技术支持

3. **提供信息：**
   - Cursor 版本号
   - 错误日志
   - 配置截图
   - 网络环境信息

---

**最后更新：** 2026-01-10
