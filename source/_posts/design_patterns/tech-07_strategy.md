---
title: Strategy 模式
---

## Strategy 模式

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