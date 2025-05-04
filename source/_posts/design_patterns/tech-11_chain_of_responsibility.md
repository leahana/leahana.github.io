---
title: Chain of Responsibility 模式
---

## Chain of Responsibility模式

### 登场角色

#### Handler 处理者
Handler角色定义了处理请求的接口，Handler角色知道（下一个处理者）是谁，如果自己无法处理请求，他会将请求转发给“下一个处理者”。当然下一个处理者也是Handler角色，在示例程序中，Support类扮演此角色名负责处理请求的Support方法。

#### ConcreteHandler 具体的处理者
concreteHandler角色是处理请求的具体角色，在示例程序中NoSupport、LimitSupport、OddSupport、SpecialSupport等类扮演此角色。

#### Client 请求者
Client角色是向第一个Handler角色发送请求的角色，在示例程序中 Main类扮演此角色。

### 拓展思路
- 弱化了发出请求的人和处理请求的人之间的关系
- 可以动态的改变职责链
- 专注于自己的工作
- 推卸请求会导致处理延迟，如果请求和处理者之间的关系是确定的，而且需要非常快的处理速度时，不适用本模式会更好

### 相关的设计模式
- Composite 模式
- Command 模式