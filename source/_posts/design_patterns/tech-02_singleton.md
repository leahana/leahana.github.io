---
title: Singleton 模式
---

## Singleton模式

#### Singleton 中登场的角色

##### Singleton

在Singleton模式中，只有Singleton这一个角色，Singleton角色中有一个返回实例的static 方法，该方法总会返回同一个实例

#### 拓展思路的要点

- 为什么必须设置限制

存在多个实例时，实例之间相互影响，可能产生意想不到的bug，确保只有一个实例的时候，就可以在这个前提条件下放心编程，并且不会造成资源浪费的情况发生。不用每次使用某个对象而一直创建他的实例。

- 何时生成唯一实例

程序运行后，第一次调用getInstance方法是，Singleton类就会被初始化，也就是在这时候，static修饰的singleton被初始化，生成了唯一一个实例

#### 相关的设计模式

- AbstractFactory模式
- Builder模式
- Facade模式
- Prototype模式