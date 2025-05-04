---
title: Factory Method 模式
---

## Factory Method 模式

### ▎模式结构
```java
abstract class Factory {
    public abstract Product createProduct(String name);
}
```

### 框架和具体加工

用相同的框架创建出其他的“产品”和“工厂”。例如，我们这次要创建表示电视机类的Television和表示电视机工厂的TelevisionFactory 。这里我们只需要impor  framework包就可以编写television包。我们这里没有修改， 根本没有必要修改framwork的内容就可以创建出其他的“产品”和“工厂”。framework不依赖于idcard包，television包。

### 生成实例---方法的三种实现方式

##### 指定其为抽象方法

​	一旦将createProduct指定为抽象方法后， 子类就必须实现该方法。如果子类不实现该方法，编译器将会报告编译错误，也就是示例程序所采用的方式。

```java
abstract class Factory{
		public abstract Product createProduct(String name)
}
```

##### 为其实现默认处理

​		实现默认处理后，如果子类没有实现该方法，将进行默认处理。这时是使用new 关键字创建出实例的，因此不能将Product 类定义为抽象类。

```java
class Factory{
    public Product createProduct(String name){
    		return new Product(name);
    }
}
```

##### 在其中抛出异常

​		createProduct方法的默认处理为抛出异常，这样一来，如果未在子类实现中实现该方法，程序运行就会报错（报错，告知开发人员没有实现createProduct 方法）, 不过需要另外编写FactoryMethodRuntimeException

```java
class Factory {
		public Product createProduct(String name){
				throw new FactoryMethodRuntimeException();
		}
}
```

### 相关的设计模式

- Template Method 模式
- Singletion 模式
- ComPosite 模式
- Iterator模式