---
title: Prototype 模式
date: 2023-01-03 00:00:00 +0800
updated: 2026-01-09
categories: [设计模式]
tags: [设计模式, 创建型模式]
description: Prototype模式通过复制现有实例来创建新对象，避免了创建对象时的复杂初始化过程，适用于对象创建成本较高的场景。
toc: true
---

## Prototype 模式

### 一、基础介绍

Prototype（原型）模式是一种创建型设计模式，它通过复制现有实例来创建新对象，而不是通过 `new` 关键字创建。这个模式的核心思想是：**通过克隆（clone）原型对象来创建新的对象**。

原型模式允许你创建对象而无需知道其具体类型，也无需关心创建细节。当你需要创建与现有对象相似的对象时，原型模式非常高效。

### 二、生活比喻：复印机

想象一台**复印机**：

> **传统方式（new）**：每次需要一份文档时，你都要重新手写一份。如果文档很复杂，包含图表、公式等，重新编写既费时又容易出错。
>
> **原型方式（clone）**：你有一份精心制作的原版文档，只需要放入复印机，按下按钮，就能快速得到完全相同的副本。如果需要修改，只需要在副本上修改即可。

在这个比喻中：
- **Prototype** = 原版文档（可以复印的对象）
- **clone()** = 复印按钮（复制操作）
- **ConcretePrototype** = 具体的文档类型（报告、合同、图纸）
- **Client** = 使用复印机的人

### 三、模式结构与角色

```
┌─────────────────────────────────────────────────────────────┐
│                       Prototype                              │
│                    (原型接口/抽象类)                          │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + clone(): Prototype  // 克隆方法                        ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                            │ inherits
                            │
┌─────────────────────────────────────────────────────────────┐
│                  ConcretePrototype                          │
│                     (具体原型)                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + clone(): Prototype  // 返回自己的副本                  ││
│  │ - 各种业务属性和方法                                      ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘

        使用 clone()                              创建新的
        进行复制                            ConcretePrototype
         ┌─────────┐                              ┌─────────┐
         │  原型   │ ──克隆(clone)───▶             │  副本   │
         └─────────┘                              └─────────┘
```

#### 登场角色

| 角色 | 说明 |
|------|------|
| **Prototype（原型）** | 声明克隆方法的接口，通常是 `clone()` |
| **ConcretePrototype（具体原型）** | 实现克隆方法，返回自己的副本 |
| **Client（客户端）** | 通过克隆原型来创建新对象 |

### 四、应用场景

#### 适用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **对象创建成本高** | 初始化需要大量资源或时间 | 复杂图形、大型文档 |
| **对象种类繁多** | 无法预知需要创建哪些类 | 游戏中的怪物配置 |
| **避免类爆炸** | 使用工厂方法会产生大量子类 | 不同配置的报表 |
| **保持状态一致性** | 需要保存和恢复对象状态 | 游戏存档、撤销操作 |
| **解耦框架与实例** | 框架不依赖具体类 | 插件系统、模板系统 |

#### 真实案例

- **游戏开发**：克隆怪物、武器、道具对象
- **文档编辑**：复制粘贴功能、模板文档
- **科学计算**：复制大型数据集进行实验
- **配置管理**：基于模板创建新配置

### 五、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **性能提升** | 克隆比直接创建快，特别是复杂对象 |
| **简化创建** | 无需知道创建细节，只需克隆 |
| **动态扩展** | 运行时可以增删对象类型 |
| **保持状态** | 克隆会复制原对象的状态 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **浅拷贝问题** | 默认克隆只复制引用，不复制对象 |
| **深拷贝复杂** | 实现深拷贝需要额外工作 |
| **违反开闭原则** | 修改原型类可能影响所有克隆 |
| **调试困难** | 克隆链难以追踪对象来源 |

#### 浅拷贝 vs 深拷贝

```
浅拷贝（Shallow Copy）:
┌─────────────┐        ┌─────────────┐
│  原对象     │        │  克隆对象   │
│  - name     │        │  - name     │  ← 基本类型复制值
│  - list ────┼────────┼─── list     │  ← 引用类型共享内存
└─────────────┘        └─────────────┘
                       ↑
                       修改list会互相影响

深拷贝（Deep Copy）:
┌─────────────┐        ┌─────────────┐
│  原对象     │        │  克隆对象   │
│  - name     │        │  - name     │  ← 完全独立
│  - list     │  复制  │  - list     │  ← 独立的内存
└─────────────┘        └─────────────┘
                       修改互不影响
```

### 六、Java 经典案例

#### 实现 1：基本原型模式

```java
/**
 * 原型接口
 */
interface Prototype {
    Prototype clone();
}

/**
 * 具体原型：文档
 */
class Document implements Prototype {
    private String title;
    private String content;
    private String author;

    public Document(String title, String content, String author) {
        this.title = title;
        this.content = content;
        this.author = author;
    }

    // 实现克隆方法
    @Override
    public Document clone() {
        return new Document(this.title, this.content, this.author);
    }

    // Getters and Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }

    @Override
    public String toString() {
        return "Document{title='" + title + "', content='" + content + "', author='" + author + "'}";
    }
}

// 使用
public class PrototypeDemo {
    public static void main(String[] args) {
        // 创建原型文档
        Document prototype = new Document("项目报告", "这是项目报告的内容", "张三");
        System.out.println("原型: " + prototype);

        // 克隆文档
        Document copy1 = prototype.clone();
        copy1.setTitle("项目报告 - 副本1");
        copy1.setContent("这是副本1的修改内容");

        Document copy2 = prototype.clone();
        copy2.setTitle("项目报告 - 副本2");

        System.out.println("副本1: " + copy1);
        System.out.println("副本2: " + copy2);
    }
}
```

#### 实现 2：使用 Cloneable 接口（浅拷贝）

```java
/**
 * 实现 Cloneable 接口的原型
 */
class ShallowCopyExample implements Cloneable {
    private String name;
    private int[] data;

    public ShallowCopyExample(String name, int[] data) {
        this.name = name;
        this.data = data;
    }

    @Override
    protected ShallowCopyExample clone() {
        try {
            // Object 的 clone() 方法是浅拷贝
            return (ShallowCopyExample) super.clone();
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
    }

    // Getters and Setters
    public String getName() { return name; }
    public int[] getData() { return data; }
    public void setData(int index, int value) { data[index] = value; }

    @Override
    public String toString() {
        return name + ": " + java.util.Arrays.toString(data);
    }
}

// 演示浅拷贝问题
public class ShallowCopyDemo {
    public static void main(String[] args) {
        int[] dataArray = {1, 2, 3, 4, 5};
        ShallowCopyExample original = new ShallowCopyExample("Original", dataArray);

        // 克隆对象
        ShallowCopyExample cloned = original.clone();
        cloned.setName("Cloned");

        // 修改克隆对象的数组
        cloned.setData(0, 999);

        System.out.println("Original: " + original);  // Original: [999, 2, 3, 4, 5]
        System.out.println("Cloned: " + cloned);      // Cloned: [999, 2, 3, 4, 5]

        // 问题：原对象的数组也被修改了！
    }
}
```

#### 实现 3：深拷贝实现

```java
/**
 * 深拷贝实现示例
 */
class DeepCopyExample implements Cloneable {
    private String name;
    private int[] data;

    public DeepCopyExample(String name, int[] data) {
        this.name = name;
        // 复制数组，确保独立
        this.data = data.clone();
    }

    @Override
    protected DeepCopyExample clone() {
        try {
            DeepCopyExample cloned = (DeepCopyExample) super.clone();
            // 深拷贝：也要复制数组
            cloned.data = this.data.clone();
            return cloned;
        } catch (CloneNotSupportedException e) {
            throw new RuntimeException(e);
        }
    }

    // Getters and Setters
    public String getName() { return name; }
    public int[] getData() { return data; }
    public void setData(int index, int value) { data[index] = value; }

    @Override
    public String toString() {
        return name + ": " + java.util.Arrays.toString(data);
    }
}

// 演示深拷贝
public class DeepCopyDemo {
    public static void main(String[] args) {
        int[] dataArray = {1, 2, 3, 4, 5};
        DeepCopyExample original = new DeepCopyExample("Original", dataArray);

        // 克隆对象
        DeepCopyExample cloned = original.clone();
        cloned.setName("Cloned");
        cloned.setData(0, 999);

        System.out.println("Original: " + original);  // Original: [1, 2, 3, 4, 5]
        System.out.println("Cloned: " + cloned);      // Cloned: [999, 2, 3, 4, 5]

        // 现在：原对象的数组没有被修改，完全独立！
    }
}
```

#### 实现 4：序列化实现深拷贝

```java
import java.io.*;

/**
 * 使用序列化实现深拷贝
 * 适用于复杂对象的深拷贝
 */
class SerializationUtil {
    @SuppressWarnings("unchecked")
    public static <T extends Serializable> T deepCopy(T obj) {
        try {
            // 序列化到字节数组
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(obj);
            oos.flush();

            // 从字节数组反序列化
            ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
            ObjectInputStream ois = new ObjectInputStream(bis);
            return (T) ois.readObject();
        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException("Deep copy failed", e);
        }
    }
}

/**
 * 可序列化的复杂对象
 */
class ComplexObject implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private nestedObject nested;

    public ComplexObject(String name, String nestedValue) {
        this.name = name;
        this.nested = new nestedObject(nestedValue);
    }

    private static class nestedObject implements Serializable {
        private static final long serialVersionUID = 1L;
        private String value;
        public nestedObject(String value) { this.value = value; }
        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }
    }

    // Getters
    public String getName() { return name; }
    public nestedObject getNested() { return nested; }
}

// 使用序列化进行深拷贝
public class SerializationCopyDemo {
    public static void main(String[] args) {
        ComplexObject original = new ComplexObject("Original", "Nested Value");

        // 使用序列化进行深拷贝
        ComplexObject cloned = SerializationUtil.deepCopy(original);

        // 修改克隆对象
        cloned.getNested().setValue("Modified");

        System.out.println("Original nested: " + original.getNested().getValue());
        System.out.println("Cloned nested: " + cloned.getNested().getValue());

        // Original 和 Cloned 完全独立
    }
}
```

### 七、Python 经典案例

#### 实现 1：基本原型模式

```python
import copy
from typing import Protocol


class Prototype(Protocol):
    """原型接口"""

    def clone(self) -> 'Prototype':
        ...


class Document:
    """文档类 - 可克隆的对象"""

    def __init__(self, title: str, content: str, author: str):
        self.title = title
        self.content = content
        self.author = author

    def clone(self) -> 'Document':
        """克隆方法"""
        # 创建新对象，复制所有属性
        return Document(self.title, self.content, self.author)

    def __str__(self) -> str:
        return f"Document{{title='{self.title}', content='{self.content}', author='{self.author}'}}"


# 使用
def main():
    # 创建原型文档
    prototype = Document("项目报告", "这是项目报告的内容", "张三")
    print(f"原型: {prototype}")

    # 克隆文档
    copy1 = prototype.clone()
    copy1.title = "项目报告 - 副本1"
    copy1.content = "这是副本1的修改内容"

    copy2 = prototype.clone()
    copy2.title = "项目报告 - 副本2"

    print(f"副本1: {copy1}")
    print(f"副本2: {copy2}")


if __name__ == "__main__":
    main()
```

#### 实现 2：使用 copy 模块（浅拷贝）

```python
import copy


class ShallowCopyExample:
    """浅拷贝示例"""

    def __init__(self, name: str, data: list):
        self.name = name
        self.data = data

    def __str__(self) -> str:
        return f"{self.name}: {self.data}"


def shallow_copy_demo():
    """演示浅拷贝的问题"""
    data_list = [1, 2, 3, 4, 5]
    original = ShallowCopyExample("Original", data_list)

    # 使用 copy.copy() 进行浅拷贝
    cloned = copy.copy(original)
    cloned.name = "Cloned"
    cloned.data[0] = 999

    print(f"Original: {original}")  # Original: [999, 2, 3, 4, 5]
    print(f"Cloned: {cloned}")      # Cloned: [999, 2, 3, 4, 5]

    # 问题：原对象的列表也被修改了！


if __name__ == "__main__":
    shallow_copy_demo()
```

#### 实现 3：深拷贝实现

```python
import copy


class DeepCopyExample:
    """深拷贝示例"""

    def __init__(self, name: str, data: list):
        self.name = name
        self.data = list(data)  # 复制列表

    def __str__(self) -> str:
        return f"{self.name}: {self.data}"


def deep_copy_demo():
    """演示深拷贝"""
    data_list = [1, 2, 3, 4, 5]
    original = DeepCopyExample("Original", data_list)

    # 使用 copy.deepcopy() 进行深拷贝
    cloned = copy.deepcopy(original)
    cloned.name = "Cloned"
    cloned.data[0] = 999

    print(f"Original: {original}")  # Original: [1, 2, 3, 4, 5]
    print(f"Cloned: {cloned}")      # Cloned: [999, 2, 3, 4, 5]

    # 现在：原对象的列表没有被修改，完全独立！


if __name__ == "__main__":
    deep_copy_demo()
```

#### 实现 4：复杂对象的深拷贝

```python
import copy
from dataclasses import dataclass
from typing import List


@dataclass
class Item:
    """嵌套对象"""
    name: str
    value: int


@dataclass
class ShoppingCart:
    """购物车 - 复杂对象"""
    items: List[Item]
    customer: str

    def clone(self) -> 'ShoppingCart':
        """克隆方法"""
        # 使用 deepcopy 确保完全独立
        return copy.deepcopy(self)

    def __str__(self) -> str:
        items_str = ", ".join(item.name for item in self.items)
        return f"{self.customer}'s cart: [{items_str}]"


def complex_deep_copy_demo():
    """复杂对象的深拷贝演示"""
    # 创建原型购物车
    prototype = ShoppingCart(
        items=[Item("Laptop", 1000), Item("Mouse", 50)],
        customer="Prototype Customer"
    )

    # 克隆购物车
    cart1 = prototype.clone()
    cart1.customer = "Alice"
    cart1.items.append(Item("Keyboard", 100))

    cart2 = prototype.clone()
    cart2.customer = "Bob"

    print(f"Prototype: {prototype}")  # 原型保持不变
    print(f"Cart1: {cart1}")
    print(f"Cart2: {cart2}")


if __name__ == "__main__":
    complex_deep_copy_demo()
```

#### 实现 5：使用 __copy__ 和 __deepcopy__ 魔术方法

```python
import copy


class CustomClone:
    """自定义克隆行为的类"""

    def __init__(self, name: str, data: dict):
        self.name = name
        self.data = data
        self.cache = None  # 不希望被克隆的缓存

    def __copy__(self):
        """自定义浅拷贝行为"""
        print("Using custom __copy__ method")
        new_obj = CustomClone(self.name, self.data)
        # cache 不会被复制
        return new_obj

    def __deepcopy__(self, memo):
        """自定义深拷贝行为"""
        print("Using custom __deepcopy__ method")
        # memo 用于处理循环引用
        new_obj = CustomClone(
            self.name,
            copy.deepcopy(self.data, memo)
        )
        # cache 不会被复制
        return new_obj

    def __str__(self) -> str:
        return f"{self.name}: data={self.data}, cache={self.cache}"


def custom_clone_demo():
    """自定义克隆演示"""
    obj = CustomClone("Test", {"key": "value"})
    obj.cache = "Cached Value"

    # 浅拷贝
    shallow = copy.copy(obj)
    print(f"Shallow copy: {shallow}")

    # 深拷贝
    deep = copy.deepcopy(obj)
    print(f"Deep copy: {deep}")


if __name__ == "__main__":
    custom_clone_demo()
```

#### 实现 6：原型注册表（工厂模式结合）

```python
from typing import Dict, TypeVar, Type
import copy

T = TypeVar('T')


class PrototypeRegistry:
    """原型注册表 - 管理所有原型对象"""

    def __init__(self):
        self._prototypes: Dict[str, object] = {}

    def register(self, key: str, prototype: object) -> None:
        """注册原型"""
        self._prototypes[key] = prototype
        print(f"Registered prototype: {key}")

    def unregister(self, key: str) -> None:
        """注销原型"""
        if key in self._prototypes:
            del self._prototypes[key]

    def clone(self, key: str) -> object:
        """克隆指定原型"""
        if key not in self._prototypes:
            raise ValueError(f"Prototype '{key}' not found")
        return copy.deepcopy(self._prototypes[key])


class Monster:
    """游戏怪物类"""

    def __init__(self, name: str, health: int, damage: int):
        self.name = name
        self.health = health
        self.damage = damage

    def __str__(self) -> str:
        return f"{self.name}(HP:{self.health}, DMG:{self.damage})"


def prototype_registry_demo():
    """原型注册表演示"""
    registry = PrototypeRegistry()

    # 注册不同的怪物原型
    registry.register("goblin", Monster("哥布林", 50, 10))
    registry.register("dragon", Monster("巨龙", 500, 100))
    registry.register("skeleton", Monster("骷髅", 30, 5))

    # 使用原型创建怪物
    goblin1 = registry.clone("goblin")
    goblin2 = registry.clone("goblin")
    goblin2.name = "哥布林战士"
    goblin2.health = 80

    dragon = registry.clone("dragon")

    print(f"\nCreated monsters:")
    print(f"  {goblin1}")
    print(f"  {goblin2}")
    print(f"  {dragon}")


if __name__ == "__main__":
    prototype_registry_demo()
```

### 八、参考资料与延伸阅读

#### 经典书籍

- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 原型模式章节
- 《Java设计模式》- 深拷贝与浅拷贝专题

#### 在线资源

- [Refactoring.Guru - Prototype](https://refactoring.guru/design-patterns/prototype)
- [Java Cloneable 接口详解](https://java-design-patterns.com/patterns/prototype/)
- [Python copy 模块文档](https://docs.python.org/3/library/copy.html)

#### 相关设计模式

- **Abstract Factory（抽象工厂）**：可以用原型存储产品实例
- **Composite（组合）**：原型可以克隆复杂的组合结构
- **Decorator（装饰）**：装饰后的对象可以被克隆
- **Memento（备忘录）**：备忘录可以使用原型实现
- **Command（命令）**：命令可以被克隆以支持撤销操作

#### 最佳实践建议

1. **Java**：
   - 优先使用 `Cloneable` 接口
   - 注意深拷贝的实现
   - 复杂对象考虑使用序列化

2. **Python**：
   - 优先使用 `copy` 模块
   - 浅拷贝用 `copy.copy()`
   - 深拷贝用 `copy.deepcopy()`
   - 自定义对象可实现 `__copy__` 和 `__deepcopy__`

3. **通用建议**：
   - 明确区分浅拷贝和深拷贝
   - 复杂对象使用原型注册表管理
   - 注意循环引用的克隆问题

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2023-01-03 | 初始版本 |
