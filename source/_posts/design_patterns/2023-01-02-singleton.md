---
title: Singleton 模式
date: 2023-01-02 00:00:00 +0800
updated: 2026-01-09
categories: [设计模式]
tags: [设计模式, 创建型模式]
description: Singleton模式确保一个类只有一个实例，并提供一个全局访问点来访问该实例，常用于需要严格控制资源共享的场景。
toc: true
---

## Singleton 模式

### 一、基础介绍

Singleton（单例）模式是一种创建型设计模式，它确保一个类只有一个实例，并提供一个全局访问点来访问该实例。这种模式在需要一个全局唯一对象来协调操作时非常有用。

单例模式的核心要点：

1. **私有构造函数**：防止外部通过 `new` 创建实例
2. **私有静态实例变量**：存储唯一的实例
3. **公共静态访问方法**：提供全局访问点（通常命名为 `getInstance()`）

### 二、生活比喻：王国里的国王

想象一个**王国**：

> 在一个王国里，只能有一个国王在位。无论王国的哪个部门（军队、财政、外交）需要见国王，他们都会去同一个地方——王座，见的都是同一个人。
>
> 如果有多个"国王"同时发布命令，国家就会陷入混乱。因此，**确保国王的唯一性**是王国正常运转的前提。

在这个比喻中：
- **Singleton** = 王国的国王制度
- **getInstance()** = 获取国王接见的官方渠道
- **唯一实例** = 在位的国王本人

### 三、应用场景

#### 适用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **资源共享** | 多个组件需要访问同一资源 | 数据库连接池、线程池 |
| **配置管理** | 应用全局配置的唯一访问点 | 配置中心、系统设置 |
| **日志记录** | 统一的日志输出管理 | 日志框架、审计系统 |
| **缓存管理** | 统一的缓存访问接口 | 缓存管理器 |
| **设备驱动** | 硬件设备的唯一访问接口 | 打印机队列、显示驱动 |

#### 真实案例

- **Java Runtime**：`Runtime.getRuntime()` 返回 JVM 的唯一运行时实例
- **日志管理器**：Log4j、SLF4J 的 Logger 管理
- **配置中心**：Spring 的 `ApplicationContext`
- **缓存系统**：Redis 连接池、Memcached 客户端

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **唯一实例** | 确保资源不被重复创建，节约内存 |
| **全局访问** | 提供统一的访问点，方便使用 |
| **延迟初始化** | 可以等到第一次使用时才创建实例 |
| **减少资源消耗** | 避免频繁创建和销毁对象 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **违反单一职责** | 单例类既管理业务逻辑，又管理创建逻辑 |
| **全局状态** | 引入隐式依赖，使代码难以测试 |
| **并发问题** | 多线程环境下需要特殊处理 |
| **难以继承** | 私有构造函数导致难以扩展 |
| **内存泄漏** | 生命周期贯穿整个应用，易积累无用数据 |

#### 使用建议

- 谨慎使用：能用依赖注入解决的场景，优先不用单例
- 线程安全：多线程环境必须考虑并发访问
- 可测试性：提供方式重置单例，便于单元测试

### 五、Java 经典案例

#### 实现 1：饿汉式（推荐简单场景）

```java
/**
 * 饿汉式：类加载时就创建实例
 * 优点：简单、线程安全
 * 缺点：不支持延迟加载，可能浪费资源
 */
public class EagerSingleton {
    // 类加载时就创建实例
    private static final EagerSingleton instance = new EagerSingleton();

    // 私有构造函数
    private EagerSingleton() {
        // 初始化代码
    }

    // 返回唯一实例
    public static EagerSingleton getInstance() {
        return instance;
    }
}
```

#### 实现 2：懒汉式（线程不安全）

```java
/**
 * 懒汉式：第一次使用时创建实例
 * 警告：线程不安全，多线程环境下可能创建多个实例！
 */
public class UnsafeLazySingleton {
    private static UnsafeLazySingleton instance = null;

    private UnsafeLazySingleton() {}

    public static UnsafeLazySingleton getInstance() {
        if (instance == null) {
            instance = new UnsafeLazySingleton();
        }
        return instance;
    }
}
```

#### 实现 3：懒汉式（同步方法）

```java
/**
 * 同步方法懒汉式
 * 优点：线程安全
 * 缺点：每次获取实例都需要同步，性能较差
 */
public class SyncedLazySingleton {
    private static SyncedLazySingleton instance = null;

    private SyncedLazySingleton() {}

    public static synchronized SyncedLazySingleton getInstance() {
        if (instance == null) {
            instance = new SyncedLazySingleton();
        }
        return instance;
    }
}
```

#### 实现 4：双重检查锁（推荐）

```java
/**
 * 双重检查锁（Double-Checked Locking）
 * 优点：延迟加载、线程安全、性能良好
 * 注意：必须使用 volatile 关键字
 */
public class DCLSingleton {
    // volatile 防止指令重排序
    private static volatile DCLSingleton instance = null;

    private DCLSingleton() {
        // 初始化代码
    }

    public static DCLSingleton getInstance() {
        // 第一次检查：避免不必要的同步
        if (instance == null) {
            synchronized (DCLSingleton.class) {
                // 第二次检查：确保只有一个实例被创建
                if (instance == null) {
                    instance = new DCLSingleton();
                }
            }
        }
        return instance;
    }
}
```

#### 实现 5：静态内部类（推荐）

```java
/**
 * 静态内部类方式（Holder 模式）
 * 优点：延迟加载、线程安全、代码简洁
 * 原理：利用类加载机制保证线程安全
 */
public class HolderSingleton {
    // 私有构造函数
    private HolderSingleton() {
        // 初始化代码
    }

    // 静态内部类，延迟加载
    private static class Holder {
        private static final HolderSingleton INSTANCE = new HolderSingleton();
    }

    // 返回实例
    public static HolderSingleton getInstance() {
        return Holder.INSTANCE;
    }
}
```

#### 实现 6：枚举单例（最佳实践）

```java
/**
 * 枚举单例（Effective Java 推荐）
 * 优点：
 *   1. 线程安全
 *   2. 防止反射攻击
 *   3. 防止序列化破坏
 *   4. 代码简洁
 */
public enum EnumSingleton {
    INSTANCE;  // 唯一实例

    // 添加业务方法
    public void doSomething() {
        System.out.println("Singleton is working");
    }

    // 可以添加属性
    private String data;

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}

// 使用
public class Main {
    public static void main(String[] args) {
        EnumSingleton singleton = EnumSingleton.INSTANCE;
        singleton.doSomething();
        singleton.setData("Hello");
        System.out.println(singleton.getData());
    }
}
```

#### JDK 中的单例示例

```java
// Runtime 类是典型的单例模式
public class RuntimeDemo {
    public static void main(String[] args) {
        // 获取 Runtime 实例
        Runtime runtime = Runtime.getRuntime();

        // 使用单例实例
        System.out.println("处理器数量: " + runtime.availableProcessors());
        System.out.println("最大内存: " + runtime.maxMemory() / 1024 / 1024 + " MB");
    }
}
```

### 六、Python 经典案例

#### 实现 1：模块级单例（Pythonic 方式）

```python
# singleton.py
class Singleton:
    """单例类"""

    def __init__(self):
        self.value = None

    def do_something(self):
        print("Singleton is working")

# 模块级别的唯一实例
instance = Singleton()

# 使用
# from singleton import instance
# instance.do_something()
```

#### 实现 2：装饰器实现单例

```python
from functools import wraps

def singleton(cls):
    """
    单例装饰器
    使用：@singleton
    """
    instances = {}

    @wraps(cls)
    def get_instance(*args, **kwargs):
        if cls not in instances:
            instances[cls] = cls(*args, **kwargs)
        return instances[cls]

    return get_instance

# 使用装饰器
@singleton
class DatabaseConnection:
    def __init__(self):
        print("Creating database connection")
        self.connection = "Connected to database"

    def query(self, sql):
        print(f"Executing: {sql}")

# 测试
db1 = DatabaseConnection()
db2 = DatabaseConnection()
print(db1 is db2)  # True
```

#### 实现 3：类方法实现单例

```python
class Singleton:
    """
    使用类方法实现单例模式
    """
    _instance = None

    def __init__(self):
        if Singleton._instance is not None:
            raise Exception("Use getInstance() method to get the instance")
        print("Creating singleton instance")
        self.value = None

    @classmethod
    def getInstance(cls):
        """获取唯一实例"""
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def do_something(self):
        print(f"Doing something with value: {self.value}")

# 使用
singleton1 = Singleton.getInstance()
singleton1.value = "Test"
singleton1.do_something()

singleton2 = Singleton.getInstance()
print(singleton1 is singleton2)  # True
singleton2.do_something()  # Value: Test
```

#### 实现 4：__new__ 方法实现单例

```python
class Singleton:
    """
    使用 __new__ 方法实现单例
    这是 Python 中最常用的实现方式
    """
    _instance = None

    def __new__(cls):
        """重写 __new__ 方法控制实例创建"""
        if cls._instance is None:
            print("Creating new instance")
            cls._instance = super().__new__(cls)
            # 初始化实例属性
            cls._instance.value = None
        return cls._instance

    def do_something(self):
        print(f"Singleton value: {self.value}")

# 测试
s1 = Singleton()
s1.value = "First"
s1.do_something()

s2 = Singleton()
print(f"s1 is s2: {s1 is s2}")  # True
s2.do_something()  # Singleton value: First
```

#### 实现 5：元类实现单例（高级）

```python
class SingletonMeta(type):
    """
    单例元类
    通过元类控制类的创建行为
    """
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class Database(metaclass=SingletonMeta):
    """使用元类实现单例"""

    def __init__(self):
        print("Initializing database connection")
        self.connected = False

    def connect(self):
        self.connected = True
        print("Database connected")

    def disconnect(self):
        self.connected = False
        print("Database disconnected")

    def execute(self, query):
        if self.connected:
            print(f"Executing query: {query}")
        else:
            print("Error: Database not connected")

# 测试
db1 = Database()
db1.connect()
db1.execute("SELECT * FROM users")

db2 = Database()
print(f"db1 is db2: {db1 is db2}")  # True
db2.execute("SELECT * FROM products")
```

#### 实现 6：线程安全的单例

```python
import threading

class ThreadSafeSingleton:
    """
    线程安全的单例实现
    使用锁确保多线程环境下只创建一个实例
    """
    _instance = None
    _lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            with cls._lock:
                # 双重检查，避免锁竞争
                if cls._instance is None:
                    print("Creating thread-safe singleton instance")
                    cls._instance = super().__new__(cls)
                    cls._instance.value = None
        return cls._instance


def worker():
    """工作线程函数"""
    singleton = ThreadSafeSingleton()
    print(f"Thread {threading.current_thread().name} got singleton: {id(singleton)}")


# 测试多线程
threads = []
for i in range(5):
    t = threading.Thread(target=worker)
    threads.append(t)
    t.start()

for t in threads:
    t.join()
```

#### Python 标准库中的单例

```python
# logging 模块使用单例模式
import logging

# getLogger 返回相同的 logger 实例
logger1 = logging.getLogger(__name__)
logger2 = logging.getLogger(__name__)

print(f"Same logger: {logger1 is logger2}")  # True

logger1.setLevel(logging.INFO)
print(f"Logger level: {logger2.level}")  # 20 (INFO)
```

### 七、常见问题与解决方案

#### 问题 1：反射攻击（Java）

```java
// 通过反射可以创建新的实例，破坏单例
Constructor<Singleton> constructor = Singleton.class.getDeclaredConstructor();
constructor.setAccessible(true);
Singleton newSingleton = constructor.newInstance();

// 解决方案：使用枚举单例
public enum EnumSingleton {
    INSTANCE;
}
```

#### 问题 2：序列化破坏（Java）

```java
// 序列化和反序列化会创建新实例
// 解决方案：添加 readResolve() 方法
public class Singleton implements Serializable {
    private static final long serialVersionUID = 1L;
    private static volatile Singleton instance;

    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }

    // 防止反序列化创建新实例
    protected Object readResolve() {
        return getInstance();
    }
}
```

#### 问题 3：单例测试困难

```java
// 解决方案：提供重置方法，仅用于测试
public class Singleton {
    private static Singleton instance;

    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }

    // 仅用于测试
    static void resetInstance() {
        instance = null;
    }
}
```

### 八、参考资料与延伸阅读

#### 经典书籍

- 《Effective Java（第三版）》- Joshua Bloch
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 单例模式章节

#### 在线资源

- [Refactoring.Guru - Singleton](https://refactoring.guru/design-patterns/singleton)
- [Java设计模式：单例模式](https://java-design-patterns.com/patterns/singleton/)
- [Python单例模式的5种实现方式](https://refactoring.guru/design-patterns/singleton/python/example)

#### 相关设计模式

- **Abstract Factory（抽象工厂）**：工厂常以单例形式出现
- **Builder（建造者）**：可以创建单例的构建器
- **Facade（外观）**：Facade 对象通常是单例
- **Prototype（原型）**：单例可以克隆自身（需谨慎）

#### 最佳实践建议

1. **优先使用依赖注入**：避免隐式依赖
2. **枚举单例（Java）**：简洁且安全
3. **模块级变量（Python）**：充分利用语言特性
4. **注意线程安全**：多线程环境必须同步
5. **考虑可测试性**：提供测试友好的实现

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2023-01-02 | 初始版本 |
