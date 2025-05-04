---
title: Visitor 模式
---

## Visitor模式

访问数据结构并处理数据

### 登场角色

#### Visitor （访问者）
负责对数据结构中每个具体元素（ConcreteElement 角色）声明一个用于访问的方法，负责实现该方法的是ConcreteVisitor角色，示例程序中Visitor类扮演此角色

#### ConcrteVisitor（具体的访问者）
负责实现Visitor角色定义的接口，实现所有的Visitor方法，即实现如何处理每个ConcreteElement角色，在示例程序中ListVisitor类扮演此角色，如果再ListVisitor中 currentdir字段的值不断变化一样，随着visit（***）方法的处理进行，本角色内部的状态也会不断发射管变化

#### Element（元素）
表示Visitor角色的访问对象，接受了访问者的accpect方法，接受的参数是Visitor角色，在示例程序中，Element接口扮演此角色

#### ConcreteElement
负责实现Element角色定义的接口，示例程序中，File类和Directory类扮演此角色

#### Object Structure（对象结构）
负责处理Elment角色的集合，ConcreteVisitor角色为每个Element角色都准备了处理方法，在示例程序中有Directory类扮演此角色（一人分饰两角）。为了让ConcreteVisitor 角色可以遍历处理每个Element角色，在示例程序中实现了Iterator方法

### 拓展思路
- 双重分发
- 为什么要弄的复杂：将处理从数据结构中分离出来
- 开闭原则：对扩展开放，对修改关闭
- 易于增加ConcreteVisitor角色
- 难以增加ConcreteElement角色
- Visitor工作所需条件

### 相关设计模式
- Iterator模式
- Composite模式
- interpreter模式