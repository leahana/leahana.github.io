---
layout: post
title: RESTful API 设计规范：返回值、状态码与响应结构
date: 2026-03-27 12:00:00 +0800
categories: [tech, backend]
tags: [RESTful, API, HTTP, 接口设计, 状态码]
toc: false
---

## 💭 RESTful API 设计规范：返回值、状态码与响应结构

> 💡 核心观点：HTTP 状态码表达**协议层语义**，不是业务层语义。理解"单资源 vs 集合"的区分，是正确设计 API 返回值的关键。

### 🔑 最关键的区分：单资源 vs 集合

| 请求类型 | 示例 | 无数据时应返回 | 原因 |
|---------|------|--------------|------|
| 按 ID 获取单资源 | `GET /users/123` | **404 Not Found** | 资源路径本身不存在 |
| 查询集合（含筛选） | `GET /users?name=xxx` | **200 OK + `[]`** | 路径有效，结果集为空 |
| 批量 ID 查询 | `POST /users/batch` | **200 OK + 匹配子集** | 路径有效，部分匹配是正常业务结果 |

核心逻辑：404 表达的是"你请求的路径/资源不存在"，而不是"查询结果为空"。集合端点永远存在，只是内容可能为空。

### 📋 HTTP 状态码速查

```text
2xx 成功
  200 OK              GET 成功，含响应体
  201 Created          POST 创建成功
  204 No Content       DELETE 成功，无响应体

4xx 客户端错误
  400 Bad Request      参数校验失败
  401 Unauthorized     未认证
  403 Forbidden        已认证但无权限
  404 Not Found        资源/路径不存在
  409 Conflict         资源冲突（如重复创建）
  422 Unprocessable    语义错误（参数合法但业务不允许）

5xx 服务端错误
  500 Internal         未知服务端错误
  502 Bad Gateway      上游服务异常
  503 Unavailable      服务暂不可用
  504 Gateway Timeout  上游超时
```

### 🏗️ 响应体结构：两大流派

**流派 A：信封模式（Envelope Pattern）**

```json
{
  "code": 200,
  "data": [],
  "msg": "success"
}
```

- 国内企业 API（尤其内部系统）普遍采用
- 优点：结构统一、前端好解析、不依赖 HTTP 状态码
- 缺点：HTTP 状态码永远 200，丧失协议语义，不利于网关和缓存

**流派 B：HTTP 原生（RESTful 正统）**

```text
HTTP/1.1 200 OK
Content-Type: application/json

[]
```

- Google、GitHub、Stripe 等国际大厂采用
- 优点：符合 HTTP 规范、利于缓存和中间件
- 缺点：需要客户端正确处理各种 HTTP 状态码

**Google 的折中方案**

响应体中 `data` 和 `error` 二选一，不能同时存在：

```json
// 成功
{ "data": { "id": 123, "name": "example" } }

// 错误
{ "error": { "code": 404, "message": "Not found", "status": "NOT_FOUND" } }
```

### 💡 实践经验

- **集合查询返回空列表是正确的 RESTful 语义**——空集合 ≠ 错误
- **消费端应自行处理"缺失"逻辑**——谁需要数据映射谁来做，不应要求上游改接口语义
- **信封模式虽不"正统"但国内广泛使用**——团队统一比教条更重要，关键是保持一致
- **不要用 404 表示"查无结果"**——这会让真正的路由错误和空结果混淆，增加排查难度

### ✅ TODO

- [ ] 观看 IT 老齐视频《34 条 RESTful API 设计经验总结》，补充要点到本文
- [ ] 补充 URL 设计规范（资源命名、路径层级、版本管理）
- [ ] 补充分页、排序、过滤等查询参数设计规范
- [ ] 补充错误响应体的标准化设计（error code 体系）
- [ ] 结合实际项目，整理团队内部的接口规范模板

### 📚 参考资源

- [API Handyman - Empty list: 200 vs 204 vs 404](https://apihandyman.io/empty-lists-http-status-code-200-vs-204-vs-404/)
- [Google Cloud API Design Guide](https://docs.cloud.google.com/apis/design)
- [Google JSON Style Guide](https://google.github.io/styleguide/jsoncstyleguide.xml)
- [RESTful API 最佳实践 - 阮一峰](https://ruanyifeng.com/blog/2018/10/restful-api-best-practices.html)
- [Best Practices for a Pragmatic RESTful API - Vinay Sahni](https://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api)
- [IT 老齐 - 34 条 RESTful API 设计经验总结（B 站视频）](https://www.bilibili.com/video/BV1Vr421W7Ws)

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-27 | 初始版本：状态码、响应结构、单资源 vs 集合区分 |
