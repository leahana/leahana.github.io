---
title: Composite 模式
---

## Composite模式

容器与内容的一致性，能够使容器与内容具有一致性，创造出递归结构的模式就是Composite模式

### Composite模式中的登场角色

#### Leaf（树叶）
表示“内容”的角色，该角色中不能让入其他对象，在示例程序中，File类扮演此角色

#### Composite（复合物）
表示容器的角色，可以在其中放入Leaf角色和Composite角色，在示例程序中，Directory类扮演此角色

#### Component
使Leaf角色和Composite角色具有一致性的角色，Component角色是Leaf角色和Composite角色的父类，在示例程序中，Entry扮演此角色

#### Client
使用Composite模式的角色。在示例程序中Main类扮演此角色

### 拓展思路要点
- 多个和单个的一致性：使用Composite模式可以使容器与内容具有一致性，也可以称其为多个和单个的一致性，即多个对象结合在一起，当作一个对象进行处理。
- add方法应该放在哪里
- 到处都存在递归结构

### 相关的设计模式
- Command 模式
- Visitor 模式
- Decorator 模式