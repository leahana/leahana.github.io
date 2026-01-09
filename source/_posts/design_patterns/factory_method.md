---
title: Factory Method 模式
date: 2023-01-01
updated: 2025-01-09
categories:
  - 设计模式
tags:
  - 设计模式
  - 创建型模式
description: Factory Method模式通过将实例的生成交给子类进行，定义了一个用于创建对象的接口，让子类决定实例化哪一个类。
toc: true
---

## Factory Method 模式

### 一、基础介绍

Factory Method（工厂方法）模式是一种创建型设计模式，它定义了一个用于创建对象的接口，但由子类决定要实例化的类是哪一个。Factory Method使一个类的实例化延迟到其子类。

这个模式的核心思想是：**将对象的创建逻辑封装在单独的类中，而不是在客户端代码中直接使用 `new` 关键字创建对象**。

### 二、生活比喻：工厂的订单系统

想象一家**定制家具工厂**：

> **传统方式**：客户直接告诉工人"我要一张椅子"，工人现场制作。问题来了——如果客户要更换家具类型，工人需要重新学习制作方法。
>
> **工厂方法方式**：客户向工厂提交订单，工厂根据订单类型分配给不同的车间（椅子车间、桌子车间）。客户只需要知道"我要什么"，而不需要知道"怎么做"。

在这个比喻中：
- **Factory** = 工厂订单接收处
- **ConcreteFactory** = 具体车间（椅子车间、桌子车间）
- **Product** = 家具接口
- **ConcreteProduct** = 具体家具（椅子、桌子）

### 三、模式结构与角色

```
┌─────────────────────────────────────────────────────────────┐
│                        Product                               │
│                    (产品接口/抽象类)                          │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + operation()                                            ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                            │ inherits
                            │
┌─────────────────────────────────────────────────────────────┐
│                    ConcreteProduct                          │
│                     (具体产品)                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + operation()  // 具体实现                               ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                        Creator                               │
│                  (工厂接口/抽象类)                            │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + factoryMethod(): Product  // 工厂方法                   ││
│  │ + anOperation()                                          ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                            │ inherits
                            │
┌─────────────────────────────────────────────────────────────┐
│                    ConcreteCreator                          │
│                     (具体工厂)                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + factoryMethod(): Product  // 返回具体产品               ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

#### 登场角色

| 角色 | 说明 |
|------|------|
| **Product（产品）** | 定义工厂方法所创建的对象的接口 |
| **ConcreteProduct（具体产品）** | 实现Product接口的具体类 |
| **Creator（创建者）** | 声明工厂方法的类，返回Product类型对象 |
| **ConcreteCreator（具体创建者）** | 实现工厂方法，返回ConcreteProduct实例 |

### 四、应用场景

#### 适用场景

1. **无法预知对象确切类别及其依赖关系时**
   - 例如：日志框架，运行时决定输出到文件、控制台还是数据库

2. **希望子类指定创建对象时**
   - 例如：不同的数据库驱动，由具体驱动类决定创建什么类型的连接对象

3. **希望将创建逻辑与使用代码解耦时**
   - 例如：文档编辑器，支持多种文件格式（PDF、Word、HTML）

#### 真实案例

- **日志框架**：Log4j、SLF4J、Python logging
- **数据库连接池**：根据配置创建不同类型的连接
- **集合框架**：`Collections.unmodifiableCollection()` 使用工厂方法创建不可修改集合

### 五、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **符合开闭原则** | 新增产品类型时，只需新增具体工厂，无需修改现有代码 |
| **解耦创建与使用** | 客户端通过接口操作产品，不关心具体创建细节 |
| **代码复用** | 创建逻辑集中在工厂类中，避免重复代码 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **类数量增加** | 每个具体产品都需要对应的具体工厂类 |
| **增加系统复杂性** | 对于简单对象，使用工厂方法可能过度设计 |
| **难以重构** | 如果产品类层级变化，需要同步修改工厂类 |

#### 使用建议

- 对象创建逻辑复杂时使用
- 需要根据不同条件创建不同对象时使用
- 简单对象的创建（如只有几个字段的数据类）不建议使用

### 六、工厂方法的三种实现方式

#### 方式一：抽象方法（推荐）

```java
abstract class Factory {
    // 子类必须实现，编译器会强制检查
    public abstract Product createProduct(String name);
}
```

```python
from abc import ABC, abstractmethod

class Factory(ABC):
    @abstractmethod
    def create_product(self, name: str):
        pass
```

#### 方式二：默认实现

```java
class Factory {
    // 提供默认实现，子类可选覆盖
    public Product createProduct(String name) {
        return new Product(name);
    }
}
```

```python
class Factory:
    def create_product(self, name: str):
        return Product(name)
```

#### 方式三：异常处理

```java
class Factory {
    // 未实现时抛出异常，提醒开发者
    public Product createProduct(String name) {
        throw new FactoryMethodRuntimeException(
            "createProduct method not implemented"
        );
    }
}
```

```python
class Factory:
    def create_product(self, name: str):
        raise NotImplementedError(
            "create_product method not implemented"
        )
```

### 七、Java 经典案例

#### 案例1：JDK 中的集合框架

```java
// List 接口的工厂方法
List<String> list = new ArrayList<>();
List<String> synchronizedList = Collections.synchronizedList(list);

// Iterator 通过工厂方法获取
Iterator<String> iterator = list.iterator();
```

#### 案例2：Java SQL 连接

```java
// DriverManager 充当抽象工厂角色
Connection conn = DriverManager.getConnection(url, user, password);

// 不同的数据库驱动返回不同的 Connection 实现
// MySQL: com.mysql.cj.jdbc.ConnectionImpl
// PostgreSQL: org.postgresql.jdbc.PgConnection
```

#### 案例3：完整代码示例

```java
// ============ 产品接口 ============
interface LoggerFactory {
    Logger createLogger();
}

interface Logger {
    void log(String message);
}

// ============ 具体产品 ============
class ConsoleLogger implements Logger {
    @Override
    public void log(String message) {
        System.out.println("[CONSOLE] " + message);
    }
}

class FileLogger implements Logger {
    @Override
    public void log(String message) {
        System.out.println("[FILE] Writing to file: " + message);
    }
}

class DatabaseLogger implements Logger {
    @Override
    public void log(String message) {
        System.out.println("[DATABASE] Inserting log: " + message);
    }
}

// ============ 具体工厂 ============
class ConsoleLoggerFactory implements LoggerFactory {
    @Override
    public Logger createLogger() {
        return new ConsoleLogger();
    }
}

class FileLoggerFactory implements LoggerFactory {
    @Override
    public Logger createLogger() {
        return new FileLogger();
    }
}

class DatabaseLoggerFactory implements LoggerFactory {
    @Override
    public Logger createLogger() {
        return new DatabaseLogger();
    }
}

// ============ 客户端使用 ============
public class FactoryMethodDemo {
    public static void main(String[] args) {
        // 根据配置选择工厂
        LoggerFactory factory;

        // 可以轻松切换不同的日志实现
        factory = new ConsoleLoggerFactory();
        // factory = new FileLoggerFactory();
        // factory = new DatabaseLoggerFactory();

        Logger logger = factory.createLogger();
        logger.log("Application started");
    }
}
```

### 八、Python 经典案例

#### 案例1：Django 的表单工厂

```python
from django import forms

# 表单工厂函数
def get_form_class(form_type: str):
    """根据类型返回不同的表单类"""
    if form_type == 'login':
        return LoginForm
    elif form_type == 'register':
        return RegisterForm
    elif form_type == 'profile':
        return ProfileForm
    else:
        raise ValueError(f"Unknown form type: {form_type}")

class LoginForm(forms.Form):
    username = forms.CharField()
    password = forms.CharField(widget=forms.PasswordInput)

# 使用
FormClass = get_form_class('login')
form = FormClass()
```

#### 案例2：Python 标准库 - logging 模块

```python
import logging

# LoggerFactory 的工厂方法
logger = logging.getLogger(__name__)

# 根据配置返回不同的 Logger 实现
# 可以是 FileHandler, StreamHandler, RotatingFileHandler 等
```

#### 案例3：完整代码示例

```python
from abc import ABC, abstractmethod
from typing import Protocol

# ============ 产品接口 ============
class Logger(Protocol):
    """Logger 协议接口"""
    def log(self, message: str) -> None:
        ...

class LoggerFactory(ABC):
    """抽象工厂"""
    @abstractmethod
    def create_logger(self) -> Logger:
        ...

# ============ 具体产品 ============
class ConsoleLogger:
    """控制台日志记录器"""
    def log(self, message: str) -> None:
        print(f"[CONSOLE] {message}")

class FileLogger:
    """文件日志记录器"""
    def __init__(self, filename: str = "app.log"):
        self.filename = filename

    def log(self, message: str) -> None:
        print(f"[FILE] Writing to {self.filename}: {message}")
        # 实际应用中会写入文件
        # with open(self.filename, 'a') as f:
        #     f.write(message + '\n')

class DatabaseLogger:
    """数据库日志记录器"""
    def log(self, message: str) -> None:
        print(f"[DATABASE] Inserting log: {message}")
        # 实际应用中会插入数据库

# ============ 具体工厂 ============
class ConsoleLoggerFactory(LoggerFactory):
    """控制台日志工厂"""
    def create_logger(self) -> Logger:
        return ConsoleLogger()

class FileLoggerFactory(LoggerFactory):
    """文件日志工厂"""
    def create_logger(self) -> Logger:
        return FileLogger()

class DatabaseLoggerFactory(LoggerFactory):
    """数据库日志工厂"""
    def create_logger(self) -> Logger:
        return DatabaseLogger()

# ============ 客户端使用 ============
def configure_logging(factory: LoggerFactory) -> Logger:
    """使用工厂配置日志"""
    return factory.create_logger()

def main():
    # 根据配置选择工厂
    # 可以轻松切换不同的日志实现
    factory = ConsoleLoggerFactory()
    # factory = FileLoggerFactory()
    # factory = DatabaseLoggerFactory()

    logger = configure_logging(factory)
    logger.log("Application started")

if __name__ == "__main__":
    main()
```

#### 案例4：Python 简化版本（使用函数式工厂）

```python
from typing import Callable, TypeVar, Dict

T = TypeVar('T')

class Logger:
    pass

class ConsoleLogger(Logger):
    def log(self, message: str) -> None:
        print(f"[CONSOLE] {message}")

class FileLogger(Logger):
    def log(self, message: str) -> None:
        print(f"[FILE] {message}")

# 函数式工厂
def create_logger(logger_type: str) -> Logger:
    """工厂函数：根据类型创建不同的 Logger"""
    factories: Dict[str, Callable[[], Logger]] = {
        'console': ConsoleLogger,
        'file': FileLogger,
    }

    factory = factories.get(logger_type)
    if factory is None:
        raise ValueError(f"Unknown logger type: {logger_type}")

    return factory()

# 使用
logger = create_logger('console')
logger.log("Hello, World!")
```

### 九、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF 23种设计模式
- 《Head First 设计模式》- 第4章：工厂模式
- 《Python设计模式》- Pythons设计模式实践

#### 在线资源
- [Refactoring.Guru - Factory Method](https://refactoring.guru/design-patterns/factory-method)
- [Java设计模式：工厂方法模式](https://java-design-patterns.com/patterns/factory-method/)
- [Python设计模式：工厂方法](https://refactoring.guru/design-patterns/factory-method/python/example)

#### 相关设计模式
- **Abstract Factory（抽象工厂）**：创建**产品族**，而工厂方法创建**单一产品**
- **Template Method（模板方法）**：工厂方法常与模板方法配合使用
- **Singleton（单例）**：工厂方法可以返回单例对象
- **Prototype（原型）**：工厂方法也可以通过克隆原型来创建对象
- **Builder（建造者）**：创建复杂对象时，Builder 更灵活
