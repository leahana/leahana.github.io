# GLM-4.7 Cursor 配置检查清单

## ✅ API 测试结果

**测试时间**: 2026-01-10

**测试结果**: ✅ **API 可用**

- **API Key**: `55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV` ✅ 有效
- **Base URL**: `https://open.bigmodel.cn/api/coding/paas/v4` ✅ 可连接
- **模型**: `GLM-4.7` ✅ 可调用

---

## 📋 Cursor 配置检查清单

### 1. 基础配置

- [ ] **Cursor 版本**: 确保使用最新版本（建议 2.1.50+）
  - 检查方法: `Cursor` → `About Cursor`
  
- [ ] **Cursor Pro 订阅**: 自定义 API 需要 Pro 版本
  - 检查方法: 设置 → 账户

### 2. API Key 配置

- [ ] **启用 OpenAI API Key**
  - 位置: `Settings` → `Models` → `API Keys`
  - 状态: ✅ 已启用

- [ ] **输入 API Key**
  - 值: `55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV`
  - 检查: 无多余空格、完整复制

### 3. Base URL 配置

- [ ] **启用 Override OpenAI Base URL**
  - 位置: `Settings` → `Models` → `API Keys`
  - 状态: ✅ 已启用

- [ ] **输入 Base URL**
  - 值: `https://open.bigmodel.cn/api/coding/paas/v4`
  - ⚠️ **重要**: 末尾**不要**有斜杠 `/`
  - ✅ 正确: `https://open.bigmodel.cn/api/coding/paas/v4`
  - ❌ 错误: `https://open.bigmodel.cn/api/coding/paas/v4/`

### 4. 模型配置

- [ ] **添加自定义模型**
  - 位置: `Settings` → `Models` → `+ Add Custom Model`
  
- [ ] **模型协议**
  - 选择: `OpenAI Protocol`

- [ ] **模型名称**
  - 值: `GLM-4.7`
  - ⚠️ **重要**: 必须**大写**
  - ✅ 正确: `GLM-4.7`
  - ❌ 错误: `glm-4.7`、`GLM4.7`、`glm-4-7`

- [ ] **保存配置**

### 5. 选择模型

- [ ] **在主界面选择模型**
  - 位置: 聊天界面顶部模型选择器
  - 选择: `GLM-4.7`

---

## 🔍 排查 "Planning Next Moves" 问题

### 问题原因分析

根据 API 测试结果，GLM-4.7 的响应包含 `reasoning_content` 字段，这可能是导致 Cursor 一直处于 "planning next moves" 的原因。

### 排查步骤

#### ✅ Step 1: 验证配置

运行测试脚本验证 API:
```bash
./test-glm-api-detailed.sh
```

#### ✅ Step 2: 检查模型名称

确保模型名称完全匹配：
- ✅ `GLM-4.7`（大写，带连字符）
- ❌ 其他任何变体

#### ✅ Step 3: 检查 Base URL

确保 Base URL 完全正确：
- ✅ `https://open.bigmodel.cn/api/coding/paas/v4`
- ❌ 末尾不要有斜杠

#### ✅ Step 4: 重启 Cursor

1. 完全退出 Cursor（`Cmd+Q`）
2. 等待 5 秒
3. 重新启动 Cursor
4. 重新选择 GLM-4.7 模型

#### ✅ Step 5: 检查代码库索引

如果代码库很大：
1. 创建 `.cursorignore` 文件（项目根目录）
2. 添加不需要索引的目录：
   ```
   node_modules/
   .git/
   dist/
   build/
   *.log
   ```

#### ✅ Step 6: 查看 Cursor 日志

1. 打开 Developer Tools: `Cmd+Shift+P` → "Developer: Toggle Developer Tools"
2. 查看 `Console` 标签页的错误信息
3. 查看 `Network` 标签页的 API 请求

#### ✅ Step 7: 尝试简化测试

1. 关闭当前项目
2. 创建新的空文件夹
3. 在新文件夹中测试 GLM-4.7
4. 如果新文件夹中正常，说明是原项目的问题

---

## 🚨 常见问题与解决方案

### 问题 1: 一直显示 "Planning Next Moves"

**可能原因**:
1. GLM-4.7 的 `reasoning_content` 导致 Cursor 无法正确解析响应
2. 代码库索引卡住
3. Cursor 版本 bug

**解决方案**:
1. 尝试使用其他 GLM 模型（如 GLM-4.6）
2. 等待代码库索引完成
3. 更新 Cursor 到最新版本
4. 检查 Cursor 日志中的错误信息

### 问题 2: 模型选择后无响应

**可能原因**:
- 模型名称错误
- Base URL 错误
- API Key 无效

**解决方案**:
1. 确认模型名称是 `GLM-4.7`（大写）
2. 确认 Base URL 是 `https://open.bigmodel.cn/api/coding/paas/v4`（无末尾斜杠）
3. 运行测试脚本验证 API Key

### 问题 3: API 调用失败

**可能原因**:
- 网络问题
- API Key 过期
- Base URL 错误

**解决方案**:
1. 运行测试脚本: `./test-glm-api-detailed.sh`
2. 检查网络连接
3. 联系 API 服务商确认 Key 状态

---

## 📝 配置摘要

```
✅ API Key: 55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV
✅ Base URL: https://open.bigmodel.cn/api/coding/paas/v4
✅ Model: GLM-4.7
✅ 测试状态: API 可用
```

---

## 🔗 相关资源

- [Cursor 官方文档 - API Keys](https://docs.cursor.com/advanced/api-keys)
- [GLM 官方文档](https://open.bigmodel.cn/)

---

## 💡 额外提示

1. **GLM-4.7 特性**:
   - 支持推理过程（`reasoning_content`）
   - 这可能导致某些客户端无法正确解析响应

2. **如果问题持续**:
   - 尝试使用 GLM-4.6 或其他版本
   - 检查 Cursor 是否支持 GLM-4.7 的 reasoning 模式
   - 联系 Cursor 支持团队

3. **性能优化**:
   - 使用 `.cursorignore` 减少索引时间
   - 定期清理 Cursor 缓存
   - 保持 Cursor 更新到最新版本

---

**最后更新**: 2026-01-10
**测试状态**: ✅ API 可用
