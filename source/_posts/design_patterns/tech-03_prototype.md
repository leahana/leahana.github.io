---
title: Prototype 模式
---

## Prototype模式

### 使用场景

1）对象种类繁多，无法将他们整合到一个类中时
2）难以根据类生成实例时
3）想解耦框架与生成的实例时

### prototype中登场的角色

#### Prototype （原型）
负责定义用于复制现有实例来生成新实例的方法

#### ConcretePrototype（具体的原型）
负责实现复制现有实例并生成新实例的方法

#### Client（使用者）
负责使用复制实例的方法生成新的实例

### 相关设计模式
- Flyweight模式
- Memento模式
- Composite模式
- Command模式

### 延伸
clone方法是浅拷贝