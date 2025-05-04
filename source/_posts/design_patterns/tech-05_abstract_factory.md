---
title: Abstract Factory 模式
---

## Abstract Factory模式

关联零件组装成产品

### Abstract Factory 模式中的登场角色

#### AbstractProduct（抽象产品）
负责定义Abstract角色所产生的抽象零件和产品的接口（API），在示例程序中 Link类 Tray类 Page类扮演此角色

#### AbstractFactory（抽象工厂）
负责定义用于生成抽象产品的接口（API），在示例程序中，由Factory类扮演此角色

#### Client（委托者）
仅会调用AbstractFactory角色和AbstractProduct角色的接口（API） 来进行工作，对与具体的零件，产品和工厂一无所知，在示例程序中，Main类扮演此角色

#### ConcreteProduct（具体产品）
负责实现Abstract Product角色的接口（API）在示例程序中，ListLink类，ListTray类，ListPage类扮演

#### ConcreteFactory（具体工厂）
负责实现AbstractFactory角色的接口（API）在示例程序中，ListFactory类扮演

### 拓展思路要点：

- 易于增加具体的工厂：增加具体的工厂非常容易，指的是需要编写哪些类和实现哪些方法都非常清楚。无论增加多少个具体工厂，或是修改具体工厂里面的bug 都无需修改抽象工厂和Main部分
- 难以增加新的零件：如果我们增加一个零件，这时我们必须要对所有的具体工厂进行相应的修改才可以。已经完成的具体工厂越多，修改的工作量就会更越大。

### 相关的设计模式
- Builder模式
- Factory Method模式
- Compsite模式
- Singleton模式

### 延伸
- 生成实例的方法：new、clone、someobj.getClass.newInstance()