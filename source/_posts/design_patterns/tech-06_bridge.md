---
title: Bridge 模式
date: 2023-01-06
updated: 2023-06-06
categories: 
  - 设计模式
tags:
  - 设计模式
  - 结构型模式
description: Bridge模式将抽象部分与实现部分分离，使它们可以独立变化，解决了继承机制中类爆炸的问题。
---

## Bridge模式

### ▎模式定义

Bridge模式是一种结构型设计模式，它将抽象部分与实现部分分离，使它们可以独立地变化。这种模式通过提供桥接结构，实现了抽象和实现的分离，从而降低了它们的耦合度。

### ▎模式结构

```java
// 实现者接口
interface Implementor {
    void operationImpl();
}

// 具体实现者
class ConcreteImplementorA implements Implementor {
    public void operationImpl() {
        // 具体实现
    }
}

// 抽象类
abstract class Abstraction {
    protected Implementor implementor;
    
    public Abstraction(Implementor implementor) {
        this.implementor = implementor;
    }
    
    public abstract void operation();
}

// 扩展抽象类
class RefinedAbstraction extends Abstraction {
    public RefinedAbstraction(Implementor implementor) {
        super(implementor);
    }
    
    public void operation() {
        implementor.operationImpl();
    }
}
```

### 类的层次结构两个作用

- 希望增加新功能: 父类中具有基本功能，在子类中增加新的功能
- 希望实现新功能: 父类通过声明抽象方法来定义接口，子类通过实现具体方法来实现接口

#### 类的层次接口的混杂与分离

编写子类时先问自己：我是要增加功能还是增加实现

### Bridge中登场的角色

- Abstraction（抽象化）：位于"类的功能层次结构"的最上层，使用Implementor角色的方法定义了基本功能，保存了Implementor角色的实例。在示例程序中Display类扮演此角色。
- RefinedAbstraction（改善后的抽象化）：在Abstraction角色的基础上增加了新功能的角色，在示例程序中由countDsiplay类扮演。
- Implementor（实现者）：位于"类的实现层次结构"的最上层，定义了用于实现Abstraction角色的结偶的方法。在示例程序中由DisplayImpl类扮演。
- ConcreteImplementor（具体实现者）：负责实现Implementor角色中定义的接口。

### 拓展思路

- 分开后更容易扩展
- 继承是强关联，委托是弱关联

### 相关的设计模式

- Template Method 模式
- Abstract Factory模式
- Adaptor模式
