---
title: Composite 模式
date: 2023-01-08 00:00:00 +0800
updated: 2026-01-09
categories: [设计模式]
tags: [设计模式, 结构型模式]
description: Composite模式将对象组合成树形结构以表示"部分-整体"的层次结构，使用户对单个对象和组合对象的使用具有一致性。
toc: true
---

## Composite 模式

### 一、基础介绍

Composite（组合）模式是一种结构型设计模式，它将对象组合成树形结构来表示"部分-整体"的层次结构，使用户对单个对象和组合对象的使用具有一致性。

### 二、生活比喻：文件系统

想象一个**计算机文件系统**：

> **传统方式**：文件和文件夹需要分别处理。列出内容、计算大小、删除等操作，两者处理方式不同。
>
> **组合方式**：文件和文件夹都实现了相同的接口。对文件或文件夹调用 `getSize()`，文件夹会递归计算所有子项的大小。

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **树形结构** | 需要表示部分-整体层次结构 | 文件系统、组织架构 |
| **统一处理** | 希望一致对待单个和组合对象 | 菜单系统、GUI组件 |
| **递归遍历** | 需要对树形结构递归操作 | DOM树、语法树 |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **统一接口** | 客户端一致对待单个和组合对象 |
| **层次清晰** | 树形结构直观表达层次关系 |
| **扩展灵活** | 可方便增加新的节点类型 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **设计复杂** | 较难限制组合中的组件类型 |
| **类型安全** | 运行时才能发现类型错误 |

### 五、Java 经典案例

#### 文件系统

```java
import java.util.ArrayList;
import java.util.List;

// 抽象组件
abstract class Entry {
    protected String name;
    public Entry(String name) { this.name = name; }
    public abstract int getSize();
    public abstract void print();
}

// 叶子节点：文件
class File extends Entry {
    private int size;
    public File(String name, int size) {
        super(name);
        this.size = size;
    }
    public int getSize() { return size; }
    public void print() {
        System.out.println(name + " (" + size + " KB)");
    }
}

// 组合节点：目录
class Directory extends Entry {
    private List<Entry> entries = new ArrayList<>();
    public Directory(String name) { super(name); }
    public void add(Entry entry) { entries.add(entry); }
    public int getSize() {
        int size = 0;
        for (Entry entry : entries) {
            size += entry.getSize();
        }
        return size;
    }
    public void print() {
        System.out.println(name + " (" + getSize() + " KB)");
        for (Entry entry : entries) {
            entry.print();
        }
    }
}

// 使用
public class CompositeDemo {
    public static void main(String[] args) {
        Directory root = new Directory("root");
        Directory home = new Directory("home");
        File file1 = new File("readme.txt", 10);
        File file2 = new File("doc.pdf", 500);

        root.add(home);
        home.add(file1);
        root.add(file2);

        root.print();
    }
}
```

### 六、Python 经典案例

#### 图形绘制系统

```python
from abc import ABC, abstractmethod
from typing import List


class Graphic(ABC):
    @abstractmethod
    def draw(self) -> None: pass


class Circle(Graphic):
    def __init__(self, name: str, radius: float):
        self.name = name
        self.radius = radius

    def draw(self) -> None:
        print(f"绘制圆形: {self.name}")


class Picture(Graphic):
    def __init__(self, name: str):
        self.name = name
        self.graphics: List[Graphic] = []

    def add(self, graphic: Graphic) -> None:
        self.graphics.append(graphic)

    def draw(self) -> None:
        print(f"绘制图片: {self.name}")
        for g in self.graphics:
            g.draw()


# 使用
def main():
    circle1 = Circle("圆1", 10)
    circle2 = Circle("圆2", 15)

    picture = Picture("组合图")
    picture.add(circle1)
    picture.add(circle2)

    picture.draw()


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

- 《设计模式：可复用面向对象软件的基础》- GoF
- [Refactoring.Guru - Composite](https://refactoring.guru/design-patterns/composite)

#### 相关设计模式
- **Decorator**：Decorator 为对象添加功能，Composite 构建层次结构
- **Iterator**：常用于遍历 Composite 结构
- **Visitor**：可以对 Composite 结构执行复杂操作
