---
layout: post
title: Agent 节点调用数据中台接口返回空列表的处理方案
date: 2026-03-27 12:00:00 +0800
categories: [tech, ai]
tags: [Agent, 数据中台, HTTP, Python, 返回值处理]
toc: false
---

## 💭 Agent 节点调用数据中台接口返回空列表的处理方案

> 💡 核心观点：当中台接口对未匹配的 ID 返回空列表 `[]` 时，不应要求对方修改接口语义，而是在 Agent 工作流中通过 Python 节点自行补全缺失数据，保证下游节点拿到完整的 ID 映射。

### 🔍 问题场景

Agent 工作流中有一个 HTTP 节点，用数据 ID 调用数据中台接口查询详情。正常情况下返回：

```json
{
  "code": 200,
  "data": [
    {"id": "abc123", "name": "示例数据"}
  ]
}
```

但当传入的 ID 在中台侧无匹配记录时，接口返回空列表：

```json
{
  "code": 200,
  "data": []
}
```

问题在于：Agent 下游节点需要知道**哪些 ID 没查到数据**，空列表丢失了输入 ID 的信息，导致后续流程无法区分"未查询"和"查无结果"。

### 🤔 方案选择

和中台开发沟通后，有两个方向：

| 方案 | 做法 | 取舍 |
|------|------|------|
| 改接口 | 中台对未匹配 ID 也返回记录（字段填 `null`） | 改变了接口语义，影响其他调用方 |
| **自行处理** | Agent 侧用 Python 节点对比输入输出，补全缺失 ID | 不侵入中台接口，改动可控 |

最终选择**方案二**——在 Agent 工作流中增加一个 Python 节点处理。理由：

- 中台接口返回空列表是合理的 RESTful 语义（查无结果 ≠ 错误）
- 修改接口会影响其他已接入的系统
- Agent 侧处理更灵活，后续可根据业务调整补全逻辑

### 🛠️ Python 节点实现

在 HTTP 节点之后增加一个 Python 节点，对比输入 ID 列表与接口返回结果，补全缺失项：

```python
def handle_response(input_ids: list, api_result: list) -> list:
    """对比输入 ID 与接口返回，补全未匹配的 ID"""
    matched_ids = {item["id"] for item in api_result}

    result = list(api_result)  # 保留已匹配的完整数据

    for id_ in input_ids:
        if id_ not in matched_ids:
            result.append({"id": id_, "name": None})

    return result
```

处理效果：

```python
input_ids = ["abc123", "def456", "ghi789"]

# 中台返回（仅匹配到 abc123）
api_result = [{"id": "abc123", "name": "示例数据"}]

# Python 节点处理后
output = [
    {"id": "abc123", "name": "示例数据"},
    {"id": "def456", "name": None},
    {"id": "ghi789", "name": None}
]
```

下游节点通过判断 `name is None` 即可识别哪些 ID 未在中台找到数据。

### 🔑 关键收获

- 不要轻易要求上游修改接口，尤其是该接口已有多个调用方的情况
- 空列表是合理的接口语义，消费端应自行处理"缺失"逻辑
- Agent 工作流中 Python 节点是处理数据转换的利器，比改接口更灵活可控

### ✅ 行动项

- [ ] 将 Python 补全逻辑封装为通用函数，后续类似场景复用
- [ ] 在 Agent 工作流中增加日志输出，记录补全了哪些 ID

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-27 | 初始版本 |
