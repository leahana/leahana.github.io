---
title: Decorator 模式
date: 2023-01-09 00:00:00 +0800
updated: 2026-01-09
categories: [设计模式]
tags: [设计模式, 结构型模式]
description: Decorator模式动态地给一个对象添加一些额外的职责，就增加功能来说，Decorator模式相比生成子类更为灵活。
toc: true
---

## Decorator 模式

### 一、基础介绍

Decorator（装饰）模式是一种结构型设计模式，它允许在不改变对象结构的情况下，动态地为对象添加新的行为。

Decorator 模式的核心思想是：**通过包装对象来扩展其功能，而不是通过继承**。这样可以在运行时灵活地添加或移除功能。

### 二、生活比喻：给礼物包装

想象一个**礼品包装过程**：

> **传统方式（继承）**：如果要买"包装好的礼盒"，需要预定义各种组合：红盒包装的礼物、彩带装饰的红盒礼物、带贺卡的彩带红盒礼物...组合无限，类爆炸。
>
> **装饰方式**：你有一个裸礼物，可以依次包装：红盒→加彩带→加贺卡。每一步都是动态的，可以随时调整。

在这个比喻中：
- **Component** = 裸礼物
- **ConcreteComponent** = 具体礼物（如书、手表）
- **Decorator** = 包装纸接口
- **ConcreteDecorator** = 具体包装（红盒、彩带、贺卡）

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **动态扩展** | 运行时动态添加/撤销功能 | IO流处理、UI组件 |
| **避免类爆炸** | 继承会导致子类激增时 | 咖啡配料、披萨 toppings |
| **组合功能** | 多个功能可以任意组合 | 压缩+加密、日志+缓存 |
| **透明装饰** | 不改变原有接口 | Java IO、Python contextlib |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **动态扩展** | 运行时灵活添加功能 |
| **避免类爆炸** | 不需要大量子类 |
| **单一职责** | 每个装饰器只负责一个功能 |
| **保持接口** | 装饰后仍可使用原接口 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **多层嵌套** | 装饰器过多会增加复杂性 |
| **调试困难**：多层包装增加调试难度 |
| **小类过多**：每个功能一个装饰器类 |

#### 使用建议

- 需要动态添加功能时使用
- 不能用继承或继承代价过大时使用
- 功能可任意组合时使用

### 五、Java 经典案例

#### 实现 1：咖啡订单系统

```java
/**
 * 抽象组件：饮料
 */
abstract class Beverage {
    protected String description = "Unknown Beverage";

    public String getDescription() {
        return description;
    }

    public abstract double cost();
}

/**
 * 具体组件：具体饮料
 */
class Espresso extends Beverage {
    public Espresso() {
        description = "Espresso";
    }

    public double cost() {
        return 1.99;
    }
}

class HouseBlend extends Beverage {
    public HouseBlend() {
        description = "House Blend Coffee";
    }

    public double cost() {
        return 0.89;
    }
}

/**
 * 抽象装饰器：配料
 */
abstract class CondimentDecorator extends Beverage {
    public abstract String getDescription();
}

/**
 * 具体装饰器：各种配料
 */
class Mocha extends CondimentDecorator {
    Beverage beverage;

    public Mocha(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", Mocha";
    }

    public double cost() {
        return 0.20 + beverage.cost();
    }
}

class Whip extends CondimentDecorator {
    Beverage beverage;

    public Whip(Beverage beverage) {
        this.beverage = beverage;
    }

    public String getDescription() {
        return beverage.getDescription() + ", Whip";
    }

    public double cost() {
        return 0.10 + beverage.cost();
    }
}

// 使用
public class DecoratorDemo {
    public static void main(String[] args) {
        // 一杯 Espresso
        Beverage beverage = new Espresso();
        System.out.println(beverage.getDescription() + " $" + beverage.cost());

        // Espresso 加 Mocha
        beverage = new Mocha(beverage);
        System.out.println(beverage.getDescription() + " $" + beverage.cost());

        // 再加 Whip
        beverage = new Whip(beverage);
        System.out.println(beverage.getDescription() + " $" + beverage.cost());
    }
}
```

#### 实现 2：Java IO 流

```java
import java.io.*;

// Java IO 是典型的 Decorator 模式应用
public class JavaIODemo {
    public static void main(String[] args) throws IOException {
        // 基础流
        FileInputStream fis = new FileInputStream("test.txt");

        // 装饰缓冲
        BufferedInputStream bis = new BufferedInputStream(fis);

        // 装饰数据类型处理
        DataInputStream dis = new DataInputStream(bis);

        // 可以继续装饰其他功能
        // PushbackInputStream, GZIPInputStream 等

        int data = dis.read();
        System.out.println("Data: " + data);

        dis.close();
    }
}
```

### 六、Python 经典案例

#### 实现 1：文本处理装饰器

```python
from abc import ABC, abstractmethod
from typing import Protocol


class TextProcessor(Protocol):
    """文本处理器接口"""

    def process(self, text: str) -> str:
        ...


class SimpleTextProcessor:
    """简单文本处理器"""

    def process(self, text: str) -> str:
        return text


class TextDecorator:
    """装饰器基类"""

    def __init__(self, processor: TextProcessor):
        self.processor = processor

    def process(self, text: str) -> str:
        return self.processor.process(text)


class UpperCaseDecorator(TextDecorator):
    """转大写装饰器"""

    def process(self, text: str) -> str:
        return super().process(text).upper()


class LowerCaseDecorator(TextDecorator):
    """转小写装饰器"""

    def process(self, text: str) -> str:
        return super().process(text).lower()


class TrimDecorator(TextDecorator):
    """去除空白装饰器"""

    def process(self, text: str) -> str:
        return super().process(text).strip()


class ReverseDecorator(TextDecorator):
    """反转装饰器"""

    def process(self, text: str) -> str:
        return super().process(text)[::-1]


# 使用
def main():
    # 基础处理器
    processor: TextProcessor = SimpleTextProcessor()

    # 装饰：转大写
    processor = UpperCaseDecorator(processor)

    # 装饰：去除空白
    processor = TrimDecorator(processor)

    # 装饰：反转
    processor = ReverseDecorator(processor)

    # 处理文本
    result = processor.process("  Hello World  ")
    print(f"结果: {result}")  # "DLROW OLLEH"


if __name__ == "__main__":
    main()
```

#### 实现 2：使用 Python 装饰器语法

```python
from functools import wraps
import time


def timing_decorator(func):
    """计时装饰器"""

    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} 执行时间: {end - start:.4f} 秒")
        return result

    return wrapper


def logging_decorator(func):
    """日志装饰器"""

    @wraps(func)
    def wrapper(*args, **kwargs):
        print(f"调用 {func.__name__}，参数: {args}, {kwargs}")
        result = func(*args, **kwargs)
        print(f"{func.__name__} 返回: {result}")
        return result

    return wrapper


def cache_decorator(func):
    """缓存装饰器"""
    cache = {}

    @wraps(func)
    def wrapper(*args, **kwargs):
        key = str(args) + str(kwargs)
        if key not in cache:
            cache[key] = func(*args, **kwargs)
        return cache[key]

    return wrapper


# 组合使用装饰器
@timing_decorator
@logging_decorator
@cache_decorator
def fibonacci(n: int) -> int:
    """计算斐波那契数列"""
    if n <= 1:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)


# 使用
def main():
    result = fibonacci(10)
    print(f"斐波那契数列第10项: {result}")


if __name__ == "__main__":
    main()
```

#### 实现 3：权限验证装饰器

```python
from typing import Callable, TypeVar, Any
from functools import wraps

T = TypeVar('T')


class PermissionChecker:
    """权限检查器"""

    def __init__(self, required_permission: str):
        self.required_permission = required_permission

    def check(self, user_permission: str) -> bool:
        return self.required_permission == user_permission


class PermissionDecorator:
    """权限装饰器"""

    def __init__(self, permission: str):
        self.permission = permission

    def __call__(self, func: Callable[..., T]) -> Callable[..., T]:
        @wraps(func)
        def wrapper(*args, **kwargs):
            # 假设从 kwargs 中获取用户权限
            user_permission = kwargs.get('permission', 'guest')
            checker = PermissionChecker(self.permission)

            if checker.check(user_permission):
                return func(*args, **kwargs)
            else:
                raise PermissionError(f"需要 {self.permission} 权限")

        return wrapper


# 使用装饰器
@PermissionDecorator("admin")
def delete_user(user_id: int, **kwargs) -> str:
    return f"用户 {user_id} 已删除"


@PermissionDecorator("user")
def view_profile(user_id: int, **kwargs) -> str:
    return f"查看用户 {user_id} 的资料"


# 使用
def main():
    try:
        # 有权限
        result = view_profile(123, permission="user")
        print(result)

        # 无权限
        delete_user(456, permission="guest")
    except PermissionError as e:
        print(f"错误: {e}")


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 装饰模式章节

#### 在线资源
- [Refactoring.Guru - Decorator](https://refactoring.guru/design-patterns/decorator)
- [Java设计模式：装饰模式](https://java-design-patterns.com/patterns/decorator/)

#### 相关设计模式
- **Adapter（适配器）**：Adapter 改变接口，Decorator 增强功能
- **Proxy（代理）**：Proxy 控制访问，Decorator 添加功能
- **Composite（组合）**：Decorator 可以嵌套组合
- **Strategy（策略）**：装饰时可以改变内部策略

#### 最佳实践建议
1. 保持装饰器接口与原组件一致
2. 单一职责：每个装饰器只做一件事
3. 注意装饰顺序对结果的影响
4. Python 中优先使用 `@wraps` 保留元信息
