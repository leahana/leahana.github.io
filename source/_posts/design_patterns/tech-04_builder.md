---
title: Builder 模式
---

## Builder模式

组装复杂的实例

### Builder模式中登场的角色

#### Builder （建造者）
负责定义用于生成实例的接口

#### ConcreteBuilder（具体的建造者）
实现Builder角色的类，定义了在生成实例时实际被调用的方法。

#### Director（建工）
负责使用Builder角色的接口来生成实例，并不依赖于ConcreteBuilder角色。为了确保无论ConcreteBuilder如何被定义，Director都能正常工作，他只调用在builder角色中被定义的方法。

### 相关设计模式：
- Template Method 模式
- Composite 模式
- Abstract Factory 模式
- Facade 模式

### 拓展思路：
在面向对象编程中“谁知道什么”非常重要。我们需要在编程时注意哪个类可以使用哪个方法，以及用这个方法好不好。Director不知道自己使用的究竟是Builder的哪个子类，这样才能实现可替换性。