---
layout: post
title: Markdown 格式检查指南：确保文档符合 Hexo 规范
date: 2025-01-09 00:00:00 +0800
categories: [docs]
tags: [Markdown, 格式检查, Hexo, 规范]
description: 本文档定义了本博客 Markdown 文档的格式检查标准，包括 Front Matter、代码格式、Markdown 语法等规范，并提供自动化检查工具。
toc: true
---

# Markdown 格式检查指南

> 本文档定义了本博客 Markdown 文档的格式检查标准，专注于确保文档符合 Hexo 规范和 Markdown 语法要求。

## 📋 目录

- [Front Matter 规范](#front-matter-规范)
- [代码规范](#代码规范)
- [格式检查清单](#格式检查清单)
- [常见格式错误](#常见格式错误)
- [自动化检查](#自动化检查)

---

## Front Matter 规范

### 标准格式

```yaml
---
layout: post
title: 文章标题：吸引人的副标题
date: YYYY-MM-DD HH:mm:ss +0800
categories: [主分类, 子分类]
tags: [tag1, tag2, tag3]
description: 文章描述（可选，但推荐）
toc: true
---
```

### 字段说明

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| `layout` | string | 是 | 布局类型 | `post` |
| `title` | string | 是 | 文章标题 | `Java 并发编程实战` |
| `date` | string | 是 | 发布日期 | `2025-01-09 14:30:00 +0800` |
| `categories` | array | 是 | 分类（数组格式） | `[tech, backend]` |
| `tags` | array | 是 | 标签（数组格式） | `[Java, 并发, 多线程]` |
| `description` | string | 否 | 文章描述 | `深入理解 Java 并发编程` |
| `toc` | boolean | 否 | 是否显示目录 | `true` |

### 日期格式

**标准格式**：`YYYY-MM-DD HH:mm:ss +0800`

```yaml
date: 2025-01-09 14:30:00 +0800
```

**错误格式**：

- ❌ `date: 2025-01-09` （缺少时间部分）
- ❌ `date: 2025-01-09 14:30:00` （缺少时区）
- ❌ `date: 2025/01/09` （错误的分隔符）

### Categories 和 Tags 格式

**标准格式（数组）**：

```yaml
categories: [设计模式]
tags: [设计模式, 创建型模式]
```

**错误格式（列表）**：

```yaml
categories:
  - 设计模式
tags:
  - 设计模式
  - 创建型模式
```

---

## 代码规范

### 代码块格式

**标准格式**：

````markdown
```语言
代码内容
```
````

### 必须包含的语言标识

| 类型 | 语言标识 |
|------|---------|
| Java | `java` |
| Python | `python` |
| Bash | `bash` |
| YAML | `yaml` |
| JSON | `json` |
| Text/模板 | `text` |
| Markdown | `markdown` |
| SQL | `sql` |

### 代码注释规范

**Java 代码注释**：

```java
/**
 * 方法说明
 *
 * @param param 参数说明
 * @return 返回值说明
 */
public String method(String param) {
    // 实现逻辑
    return result;
}
```

**Python 代码注释**：

```python
def method(param: str) -> str:
    """
    方法说明
    
    Args:
        param: 参数说明
        
    Returns:
        返回值说明
    """
    # 实现逻辑
    return result
```

### 代码规范要求

- ✅ 代码块必须有语言标识
- ✅ 代码必须完整可运行
- ✅ 包含注释说明关键逻辑
- ✅ 提供预期输出或运行结果
- ✅ 避免外部依赖，或明确说明依赖

---

## 格式检查清单

### Front Matter 检查

- [ ] `layout: post` 存在且正确
- [ ] `title` 存在且不为空
- [ ] `date` 格式为 `YYYY-MM-DD HH:mm:ss +0800`
- [ ] `categories` 使用数组格式 `[分类]`
- [ ] `tags` 使用数组格式 `[tag1, tag2]`
- [ ] `description` 存在（推荐）
- [ ] Front Matter 以 `---` 开始和结束

### Markdown 语法检查

- [ ] 标题层级正确（## → ### → ####）
- [ ] 列表格式正确（`-` 或 `*` 后跟空格）
- [ ] 代码块有语言标识
- [ ] 链接格式正确 `[文本](URL)`
- [ ] 图片格式正确 `![alt](URL)`
- [ ] 表格对齐正确
- [ ] 分隔线使用 `---`（三个减号）

### 文件命名检查

- [ ] 文件名格式为 `YYYY-MM-DD-{kebab-title}.md`
- [ ] 日期部分正确（YYYY-MM-DD）
- [ ] 标题部分使用 kebab-case（小写字母和连字符）
- [ ] 文件名与 Front Matter 中的 date 一致

### 内容格式检查

- [ ] 中文和英文之间有空格
- [ ] 标点符号使用正确（中文使用中文标点）
- [ ] emoji 使用合理，不过度
- [ ] 表格对齐正确
- [ ] 代码块缩进正确
- [ ] 列表项格式统一

---

## 常见格式错误

### 错误 1：Front Matter 格式错误

**错误**：

```yaml
categories:
  - 设计模式
tags:
  - 设计模式
  - 创建型模式
```

**正确**：

```yaml
categories: [设计模式]
tags: [设计模式, 创建型模式]
```

### 错误 2：日期格式不完整

**错误**：

```yaml
date: 2025-01-09
```

**正确**：

```yaml
date: 2025-01-09 00:00:00 +0800
```

### 错误 3：代码块缺少语言标识

**错误**：

````markdown
```
public class Test {
    // 代码
}
```
````

**正确**：

````markdown
```java
public class Test {
    // 代码
}
```
````

### 错误 4：文件名与日期不一致

**错误**：

- 文件名：`2025-01-09-article.md`
- Front Matter：`date: 2024-12-25 00:00:00 +0800`

**正确**：

- 文件名：`2025-01-09-article.md`
- Front Matter：`date: 2025-01-09 00:00:00 +0800`

### 错误 5：标题层级跳跃

**错误**：

```markdown
## 一级标题
#### 三级标题（跳过了 ###）
```

**正确**：

```markdown
## 一级标题
### 二级标题
#### 三级标题
```

---

## 自动化检查

### 使用脚本检查格式

```bash
# 检查 Front Matter 格式
grep -r "categories:" source/_posts/ | grep -v "categories: \["

# 检查日期格式
grep -r "date:" source/_posts/ | grep -v "date: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} +0800"

# 检查代码块语言标识
grep -r "^```$" source/_posts/
```

### Python 检查脚本

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Markdown 格式检查脚本
"""

import os
import re
from pathlib import Path

def check_front_matter(content, filepath):
    """检查 Front Matter 格式"""
    errors = []
    
    # 检查 Front Matter 是否存在
    if not content.startswith('---'):
        errors.append(f"{filepath}: 缺少 Front Matter")
        return errors
    
    # 提取 Front Matter
    fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
    if not fm_match:
        errors.append(f"{filepath}: Front Matter 格式错误")
        return errors
    
    fm_content = fm_match.group(1)
    
    # 检查必需字段
    required_fields = ['title', 'date', 'categories']
    for field in required_fields:
        if field not in fm_content:
            errors.append(f"{filepath}: 缺少必需字段 {field}")
    
    # 检查 date 格式
    date_match = re.search(r'date:\s*(\d{4}-\d{2}-\d{2}[\s\d:+-]*)', fm_content)
    if date_match:
        date_value = date_match.group(1).strip()
        if not re.match(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+0800', date_value):
            errors.append(f"{filepath}: date 格式错误，应为 YYYY-MM-DD HH:mm:ss +0800")
    
    # 检查 categories 格式（应为数组）
    if 'categories:' in fm_content:
        if re.search(r'categories:\s*\n\s*-', fm_content):
            errors.append(f"{filepath}: categories 应使用数组格式 [分类]")
    
    # 检查 tags 格式（应为数组）
    if 'tags:' in fm_content:
        if re.search(r'tags:\s*\n\s*-', fm_content):
            errors.append(f"{filepath}: tags 应使用数组格式 [tag1, tag2]")
    
    return errors

def check_code_blocks(content, filepath):
    """检查代码块格式"""
    errors = []
    
    # 查找所有代码块
    code_block_pattern = r'```(\w+)?\n'
    matches = re.finditer(code_block_pattern, content)
    
    for match in matches:
        lang = match.group(1)
        if not lang:
            line_num = content[:match.start()].count('\n') + 1
            errors.append(f"{filepath}: 第 {line_num} 行代码块缺少语言标识")
    
    return errors

def check_file_naming(filepath):
    """检查文件名格式"""
    errors = []
    filename = Path(filepath).name
    
    # 检查文件名格式
    if not re.match(r'\d{4}-\d{2}-\d{2}-[a-z0-9-]+\.md', filename):
        errors.append(f"{filepath}: 文件名格式错误，应为 YYYY-MM-DD-kebab-title.md")
    
    return errors

def check_all_files(directory):
    """检查目录下所有 Markdown 文件"""
    all_errors = []
    
    for md_file in Path(directory).rglob("*.md"):
        if md_file.name == "README.md":
            continue
        
        print(f"检查: {md_file}")
        
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 检查各项
        all_errors.extend(check_file_naming(str(md_file)))
        all_errors.extend(check_front_matter(content, str(md_file)))
        all_errors.extend(check_code_blocks(content, str(md_file)))
    
    return all_errors

if __name__ == "__main__":
    base_dir = "/Users/anshengyo/WorkSpace/leahana.github.io/source/_posts"
    print(f"开始检查目录: {base_dir}\n")
    
    errors = check_all_files(base_dir)
    
    if errors:
        print("\n❌ 发现以下格式错误：")
        for error in errors:
            print(f"  - {error}")
        exit(1)
    else:
        print("\n✅ 所有文件格式检查通过！")
        exit(0)
```

---

## 快速修复命令

### 批量修复 Front Matter 格式

使用之前创建的 `fix-front-matter.py` 脚本：

```bash
python3 fix-front-matter.py
```

### 手动修复示例

**修复 categories 和 tags**：

```bash
# 使用 sed 批量替换（谨慎使用）
find source/_posts -name "*.md" -exec sed -i '' 's/categories:\n  -/categories: [/g' {} \;
```

---

## 相关文档

- [Markdown 文档优化指南](./2025-01-09-markdown-optimization-guide.md) - 内容优化标准

---

## 更新记录

最后更新：2025-01-09
