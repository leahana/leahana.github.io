---
layout: category
title: 设计模式
permalink: "/categories/tech/design_patterns/"
has_children: true
---

## 设计模式笔记

[[返回技术笔记]]({{ "/tech/" | relative_url }})

设计模式是解决软件设计中常见问题的可复用方案。这些模式通常分为三大类：创建型模式、结构型模式和行为型模式。每种模式都有其特定的应用场景和解决的问题。

## 设计模式分类

### 创建型模式

创建型模式关注对象的创建过程，主要解决对象创建时的灵活性问题。

| 设计模式 | 描述 |
|---------|------|
| [Factory Method 模式](tech-01_factory_method.md) | 定义一个用于创建对象的接口，让子类决定实例化哪一个类 |
| [Singleton 模式](tech-02_singleton.md) | 确保一个类只有一个实例，并提供全局访问点 |
| [Prototype 模式](tech-03_prototype.md) | 用原型实例指定创建对象的种类，通过拷贝这些原型创建新对象 |
| [Builder 模式](tech-04_builder.md) | 将复杂对象的构建与表示分离，允许用相同的构建过程创建不同的表示 |
| [Abstract Factory 模式](tech-05_abstract_factory.md) | 提供一个创建一系列相关或相互依赖对象的接口 |

### 结构型模式

结构型模式关注如何组合类和对象以形成更大的结构，同时保持结构的灵活性和高效性。

| 设计模式 | 描述 |
|---------|------|
| [Bridge 模式](tech-06_bridge.md) | 将抽象部分与实现部分分离，使它们可以独立变化 |
| [Composite 模式](tech-08_composite.md) | 将对象组合成树形结构以表示"部分-整体"的层次结构 |
| [Decorator 模式](tech-09_decorator.md) | 动态地给一个对象添加一些额外的职责 |
| [Facade 模式](tech-12_facade.md) | 为子系统中的一组接口提供一个一致的界面 |

### 行为型模式

行为型模式关注对象之间的通信和职责分配，定义对象之间的交互方式以及职责分配。

| 设计模式 | 描述 |
|---------|------|
| [Strategy 模式](tech-07_strategy.md) | 定义一系列算法，把它们封装起来，并使它们可以互换 |
| [Visitor 模式](tech-10_visitor.md) | 表示一个作用于某对象结构中的各元素的操作 |
| [Chain of Responsibility 模式](tech-11_chain_of_responsibility.md) | 为解除请求的发送者和接收者之间耦合，使多个对象都有机会处理这个请求 |
