---
title: Strategy 模式
date: 2023-01-07
updated: 2023-06-07
categories: 
  - 设计模式
tags:
  - 设计模式
  - 行为型模式
description: Strategy模式定义了一系列算法，并将每个算法封装起来，使它们可以相互替换，让算法独立于使用它的客户端而变化。
---

## Strategy 模式

### ▎模式定义

Strategy模式是一种行为型设计模式，它定义了一系列算法，将每个算法封装到具有共同接口的独立的类中，从而使得它们可以相互替换。Strategy模式使得算法可以独立于使用它的客户端而变化。

### ▎模式结构

```java
// 策略接口
interface Strategy {
    void algorithmInterface();
}

// 具体策略A
class ConcreteStrategyA implements Strategy {
    public void algorithmInterface() {
        // 具体算法A的实现
    }
}

// 具体策略B
class ConcreteStrategyB implements Strategy {
    public void algorithmInterface() {
        // 具体算法B的实现
    }
}

// 上下文
class Context {
    private Strategy strategy;
    
    public Context(Strategy strategy) {
        this.strategy = strategy;
    }
    
    public void setStrategy(Strategy strategy) {
        this.strategy = strategy;
    }
    
    public void executeStrategy() {
        strategy.algorithmInterface();
    }
}
```

整体的替换算法

### 登场角色

#### Strategy(策略)

负责决定实现策略所必须的api，在示例程序中，Startegy接口扮演此角色

#### ConcreteStrategy (具体的策略)

负责实现Strategy角色定义的api，即负责实现具体的策略(战略，方向，方法，算法)，示例程序中，WinnerStrategy，ProbStrategy扮演此角色

#### Context(上下文)

负责使用Strategy接口，Context中保留了ConcreteStrategy角色的实例，并使用 ContreteStrategy角色去实现需求，示例程序中，Player角色扮演此角色

### 拓展

- 为什么要特地编写Strategy角色：使用委托这种弱关联关系可以很方便的整体替换算法
- 程序运行中也可以切换策略：内存容量较少的运行环境中可以使用SlowButLessMemoryStrategy（速度慢但是省内存的策略），内存容量较多的运行环境中可以使用FastButMoreMemoryStrategy（速度快但是耗内存的策略）

### 相关设计模式

- Flyweight 模式
- Abstract Factory 模式
- State 模式
