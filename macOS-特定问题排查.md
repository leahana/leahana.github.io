# macOS 特定问题排查指南

## 📋 问题描述

- ✅ Windows 上 GLM-4.7 工作正常
- ❌ macOS 上一直显示 "planning next moves"

这说明配置本身是正确的，问题可能是 macOS 特定的。

---

## 🔍 macOS vs Windows 差异排查

### 1. Cursor 版本差异

**检查步骤：**

1. **macOS 上检查版本：**
   ```
   Cursor → About Cursor
   ```

2. **Windows 上检查版本：**
   ```
   Help → About
   ```

3. **对比版本号：**
   - 如果 macOS 版本较旧，更新到最新版本
   - 确保两个平台使用相同或相近的版本

**解决方案：**
```bash
# 检查 macOS 上的 Cursor 版本
defaults read com.cursor.Cursor CFBundleShortVersionString 2>/dev/null || echo "无法读取版本"
```

---

### 2. 配置文件位置差异

**macOS 配置位置：**
```
~/Library/Application Support/Cursor/User/settings.json
```

**Windows 配置位置：**
```
%APPDATA%\Cursor\User\settings.json
```

**检查步骤：**

1. **导出 Windows 配置：**
   - 在 Windows 上打开 Cursor
   - `Settings` → `Models` → 截图或记录配置
   - 或者导出配置文件

2. **在 macOS 上对比配置：**
   - 打开 macOS 上的 Cursor
   - `Settings` → `Models`
   - 逐一对比每个设置项

**关键配置项对比：**

| 配置项 | Windows | macOS | 状态 |
|--------|---------|-------|------|
| OpenAI API Key | ✅ | ? | 需检查 |
| Override Base URL | ✅ | ? | 需检查 |
| Base URL 值 | ✅ | ? | 需检查 |
| 模型名称 | ✅ | ? | 需检查 |

---

### 3. macOS 特定问题

#### 问题 1: 权限问题

**症状：**
- Cursor 无法访问网络
- 无法保存配置

**解决方案：**
```bash
# 检查网络权限
# 系统设置 → 隐私与安全性 → 网络 → 确保 Cursor 有权限

# 检查文件权限
ls -la ~/Library/Application\ Support/Cursor/
```

#### 问题 2: 缓存问题

**症状：**
- 配置已更新但未生效
- 一直显示旧状态

**解决方案：**
```bash
# 清理 Cursor 缓存
rm -rf ~/Library/Application\ Support/Cursor/Cache/*
rm -rf ~/Library/Application\ Support/Cursor/User/workspaceStorage/*

# 重启 Cursor
```

#### 问题 3: 网络代理/VPN

**症状：**
- Windows 上能连接，macOS 上不能
- 可能是代理设置不同

**解决方案：**
```bash
# 检查 macOS 代理设置
scutil --proxy

# 测试 API 连接（绕过代理）
curl --noproxy "*" https://open.bigmodel.cn/api/coding/paas/v4/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV" \
  -d '{"model": "GLM-4.7", "messages": [{"role": "user", "content": "test"}]}'
```

---

## 🔧 macOS 特定解决方案

### 方案 1: 完全重置配置

**步骤：**

1. **备份当前配置：**
   ```bash
   cp -r ~/Library/Application\ Support/Cursor/User/settings.json \
        ~/Library/Application\ Support/Cursor/User/settings.json.backup
   ```

2. **删除模型相关配置：**
   - 打开 Cursor
   - `Settings` → `Models`
   - 删除 GLM-4.7 模型
   - 清除 API Key 和 Base URL

3. **重新配置：**
   - 按照 Windows 上的配置重新设置
   - 确保每个字符都完全一致

### 方案 2: 同步 Windows 配置

**步骤：**

1. **在 Windows 上导出配置：**
   - 打开 `%APPDATA%\Cursor\User\settings.json`
   - 查找模型相关配置
   - 复制配置内容

2. **在 macOS 上应用：**
   - 打开 `~/Library/Application Support/Cursor/User/settings.json`
   - 对比并更新配置
   - 保存并重启 Cursor

### 方案 3: 检查 Cursor 日志

**步骤：**

1. **打开 Developer Tools：**
   ```
   Cmd+Shift+P → "Developer: Toggle Developer Tools"
   ```

2. **查看 Console：**
   - 切换到 Console 标签页
   - 查找错误信息
   - 特别关注 API 请求相关的错误

3. **查看 Network：**
   - 切换到 Network 标签页
   - 尝试使用 GLM-4.7
   - 查看 API 请求和响应

---

## 📝 macOS 配置检查清单

### 基础检查

- [ ] Cursor 版本与 Windows 一致或更新
- [ ] 已订阅 Cursor Pro
- [ ] 网络连接正常
- [ ] 无代理/VPN 干扰

### 配置检查

- [ ] API Key: `55e1161592d14d4d944ce608af4ec4cf.3lHP9rIwwu67aGLV`
- [ ] Base URL: `https://open.bigmodel.cn/api/coding/paas/v4`（无末尾斜杠）
- [ ] 模型名称: `GLM-4.7`（大写）
- [ ] 已启用 "Override OpenAI Base URL"

### 环境检查

- [ ] 代码库索引已完成
- [ ] 无权限问题
- [ ] 缓存已清理
- [ ] 已重启 Cursor

---

## 🚀 快速修复步骤

### 步骤 1: 清理并重新配置

```bash
# 1. 完全退出 Cursor
killall Cursor 2>/dev/null

# 2. 清理缓存（可选，谨慎操作）
# rm -rf ~/Library/Application\ Support/Cursor/Cache/*

# 3. 重新启动 Cursor
open -a Cursor

# 4. 重新配置模型
# Settings → Models → 按照 Windows 配置重新设置
```

### 步骤 2: 验证配置

运行测试脚本：
```bash
./test-glm-api-detailed.sh
```

### 步骤 3: 检查日志

1. 打开 Developer Tools
2. 尝试使用 GLM-4.7
3. 查看 Console 和 Network 标签页

---

## 🔍 常见 macOS 特定问题

### 问题 1: 配置未保存

**原因：**
- 文件权限问题
- Cursor 未完全退出

**解决方案：**
```bash
# 检查文件权限
ls -la ~/Library/Application\ Support/Cursor/User/settings.json

# 确保有写权限
chmod 644 ~/Library/Application\ Support/Cursor/User/settings.json
```

### 问题 2: 网络请求被阻止

**原因：**
- macOS 防火墙
- 网络代理设置

**解决方案：**
1. 系统设置 → 网络 → 防火墙 → 确保 Cursor 允许
2. 检查系统代理设置
3. 尝试关闭 VPN/代理后测试

### 问题 3: 代码库索引卡住

**原因：**
- macOS 文件系统权限
- 大文件索引

**解决方案：**
```bash
# 创建 .cursorignore
cat > .cursorignore << EOF
node_modules/
.git/
dist/
build/
*.log
EOF
```

---

## 💡 建议操作顺序

1. **首先：** 对比 Windows 和 macOS 的 Cursor 版本
2. **然后：** 在 macOS 上完全按照 Windows 配置重新设置
3. **接着：** 清理缓存并重启 Cursor
4. **最后：** 如果问题仍在，查看 Developer Tools 日志

---

## 📞 如果问题仍未解决

1. **收集信息：**
   - macOS Cursor 版本号
   - Windows Cursor 版本号
   - Developer Tools 中的错误日志
   - 配置截图（Windows 和 macOS）

2. **联系支持：**
   - Cursor 社区论坛：https://forum.cursor.com/
   - 提供平台差异信息

---

**最后更新**: 2026-01-10
**适用平台**: macOS
