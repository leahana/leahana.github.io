---
title: Decorator 模式
---

## Decorator 模式

装饰边框与被装饰物的一致性

### 登场角色

#### Component
增加功能时的核心角色，只定义了接口，在示例程序中Display类扮演此角色

#### Concrete Component
实现了Component角色定义的接口，在示例程序中 StringDisplay扮演此角色

#### Decorator
该角色具有与Component角色相同接口，在内部保存了被装饰对象，Component角色，Decorator角色知道自己要装饰的对象，在示例程序中Border扮演此角色

#### ConCreteDecorator
具体的Decorator角色，在示例程序中由StringBorder类和FullBorder类扮演此角色

### 拓展思路
- 接口API的透明性：装饰边框与装饰物具有一致性。可以实现不修改被装饰的类即可增加功能，使用了委托
- 可以动态的增加功能：Decorator模式中用到了委托，使类之间形成了弱关联关系。因此，不用改变框架代码，就可以生成一个与其他对象具有不同关系的新对象。
- 只需要一些装饰物即可添加许多功能
- java.io中，javax.swing.border包 使用了Decorator模式
- 导致增加许多很小的类

### 相关的设计模式
- Adapter 模式
- Stragety模式

### 延伸
- 继承--父类和子类的一致性
- 委托--自己和被委托对象的一致性