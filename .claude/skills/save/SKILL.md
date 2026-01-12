---
description: 保存当前对话为 Markdown 文件进行存档
---

# 保存对话为 Markdown

将当前对话保存为 Markdown 文件，用于后续参考或归档。

## 保存格式

```markdown
# 对话存档：{标题}

**日期**: {{ date }}
**主题**: {{ topic }}

---

## 对话内容

{conversation_history}

---

## 总结

{summary}
```

## 保存位置

- 默认保存到 `source/_posts/docs/` 目录
- 文件名格式：`YYYY-MM-DD-{topic}.md`

## 使用场景

- 重要对话记录
- 技术方案讨论
- 问题解决过程
- 知识沉淀归档
