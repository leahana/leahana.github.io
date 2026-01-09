---
title: Builder 模式
date: 2023-01-04
updated: 2025-01-09
categories:
  - 设计模式
tags:
  - 设计模式
  - 创建型模式
description: Builder模式将复杂对象的构建与表示分离，允许用相同的构建过程创建不同的表示，适用于创建包含多个组成部分的复杂对象。
toc: true
---

## Builder 模式

### 一、基础介绍

Builder（建造者）模式是一种创建型设计模式，它将复杂对象的构建与表示分离，使得同样的构建过程可以创建不同的表示。

Builder 模式的核心思想是：**将复杂对象的构造过程分解到多个步骤中，通过一个指挥者（Director）来协调构建过程**。这样可以灵活地创建不同表示的对象，而无需修改构建代码。

### 二、生活比喻：组装电脑

想象一家**电脑组装公司**：

> **传统方式**：每次组装电脑时，你都要详细告诉工人CPU型号、内存大小、硬盘类型、显卡型号等。如果配置很复杂，很容易遗漏或出错。
>
> **Builder方式**：你填写一份配置单（Builder），专业的组装师傅（Director）根据配置单，按照标准流程组装电脑。不同的配置单可以组装出不同配置的电脑，但组装流程是一样的。

在这个比喻中：
- **Builder** = 配置单（定义组装步骤的接口）
- **ConcreteBuilder** = 具体配置单（游戏本、办公本、服务器）
- **Director** = 专业组装师傅（按照流程组装）
- **Product** = 组装好的电脑

### 三、模式结构与角色

```
┌─────────────────────────────────────────────────────────────┐
│                       Builder                                │
│                   (建造者接口)                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + buildPartA()  // 构建部件A                             ││
│  │ + buildPartB()  // 构建部件B                             ││
│  │ + getResult()   // 获取最终产品                          ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                            │ inherits
                            │
┌─────────────────────────────────────────────────────────────┐
│                  ConcreteBuilder                            │
│                   (具体建造者)                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ + buildPartA()  // 具体实现                              ││
│  │ + buildPartB()  // 具体实现                              ││
│  │ + getResult()   // 返回构建的产品                        ││
│  │ - product: Product  // 持有并构建产品                     ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ uses
                            │
┌─────────────────────────────────────────────────────────────┐
│                      Director                                │
│                      (指挥者)                                │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ - builder: Builder                                       ││
│  │ + construct()  // 构建算法                               ││
│  └─────────────────────────────────────────────────────────┘│
```

#### 登场角色

| 角色 | 说明 |
|------|------|
| **Builder（建造者）** | 定义构建产品各个部件的抽象接口 |
| **ConcreteBuilder（具体建造者）** | 实现Builder接口，构建和装配各个部件 |
| **Director（指挥者）** | 使用Builder接口来构建对象，不依赖具体建造者 |
| **Product（产品）** | 被构建的复杂对象 |

### 四、应用场景

#### 适用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **复杂对象创建** | 对象有多个组成部分，创建过程复杂 | HTML文档、SQL查询 |
| **不同表示创建** | 同样的构建过程产生不同表示 | 不同风格的文档 |
| **参数繁多** | 构造函数参数过多，代码不优雅 | 配置对象、HTTP请求 |
| **不可变对象** | 需要创建不可变对象，但要分步构建 | Java StringBuilder、Python 字符串 |

#### 真实案例

- **StringBuilder**：Java 的 `StringBuilder`、Python 的字符串拼接
- **SQL构建器**：MyBatis Plus、SQLAlchemy
- **HTML生成器**：网页模板引擎
- **HTTP客户端**：OkHttp、Requests 的构建器
- **Lombok @Builder**：自动生成建造者模式代码

### 五、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **分步创建** | 复杂对象的创建过程清晰可控 |
| **复用构建过程** | 相同的构建过程可以创建不同表示 |
| **解耦构建与使用** | 客户端不需要知道产品内部结构 |
| **精细控制** | 可以逐步控制构建过程 |
| **可读性好** | 链式调用代码简洁易读 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **代码量增加** | 需要额外的Builder类 |
| **产品限制** | 产品需要有共同接口，限制了使用范围 |
| **复杂性** | 对于简单对象可能过度设计 |

#### 使用建议

- 对象有4个以上可选参数时使用
- 对象创建过程复杂时使用
- 需要创建不同表示的对象时使用
- 简单对象（少于3个参数）不建议使用

### 六、Java 经典案例

#### 实现 1：标准 Builder 模式

```java
/**
 * 产品类：电脑
 */
class Computer {
    private String cpu;
    private String ram;
    private String storage;
    private String gpu;
    private boolean hasWiFi;
    private boolean hasBluetooth;

    // 私有构造函数，只能通过Builder创建
    private Computer(Builder builder) {
        this.cpu = builder.cpu;
        this.ram = builder.ram;
        this.storage = builder.storage;
        this.gpu = builder.gpu;
        this.hasWiFi = builder.hasWiFi;
        this.hasBluetooth = builder.hasBluetooth;
    }

    @Override
    public String toString() {
        return "Computer{" +
                "cpu='" + cpu + '\'' +
                ", ram='" + ram + '\'' +
                ", storage='" + storage + '\'' +
                ", gpu='" + gpu + '\'' +
                ", hasWiFi=" + hasWiFi +
                ", hasBluetooth=" + hasBluetooth +
                '}';
    }

    /**
     * Builder 静态内部类
     */
    public static class Builder {
        // 必需参数
        private final String cpu;
        private final String ram;

        // 可选参数
        private String storage = "256GB SSD";
        private String gpu = "Integrated";
        private boolean hasWiFi = true;
        private boolean hasBluetooth = true;

        // 构造函数：必需参数
        public Builder(String cpu, String ram) {
            this.cpu = cpu;
            this.ram = ram;
        }

        // 可选参数：链式调用
        public Builder storage(String storage) {
            this.storage = storage;
            return this;
        }

        public Builder gpu(String gpu) {
            this.gpu = gpu;
            return this;
        }

        public Builder hasWiFi(boolean hasWiFi) {
            this.hasWiFi = hasWiFi;
            return this;
        }

        public Builder hasBluetooth(boolean hasBluetooth) {
            this.hasBluetooth = hasBluetooth;
            return this;
        }

        // 构建最终对象
        public Computer build() {
            return new Computer(this);
        }
    }
}

// 使用示例
public class BuilderDemo {
    public static void main(String[] args) {
        // 最小配置
        Computer basic = new Computer.Builder("Intel i5", "8GB").build();
        System.out.println("Basic: " + basic);

        // 完整配置
        Computer gaming = new Computer.Builder("Intel i9", "32GB")
                .storage("1TB NVMe SSD")
                .gpu("RTX 4090")
                .hasWiFi(true)
                .hasBluetooth(true)
                .build();
        System.out.println("Gaming: " + gaming);

        // 自定义配置
        Computer office = new Computer.Builder("Intel i7", "16GB")
                .storage("512GB SSD")
                .hasWiFi(true)
                .hasBluetooth(false)
                .build();
        System.out.println("Office: " + office);
    }
}
```

#### 实现 2：使用 Director 的标准模式

```java
/**
 * 产品类：文档
 */
class Document {
    private String title;
    private String content;
    private String footer;
    private java.util.List<String> sections = new java.util.ArrayList<>();

    public void setTitle(String title) { this.title = title; }
    public void setContent(String content) { this.content = content; }
    public void setFooter(String footer) { this.footer = footer; }
    public void addSection(String section) { this.sections.add(section); }

    @Override
    public String toString() {
        return "Document{" +
                "title='" + title + '\'' +
                ", content='" + content + '\'' +
                ", footer='" + footer + '\'' +
                ", sections=" + sections +
                '}';
    }
}

/**
 * Builder 接口
 */
interface DocumentBuilder {
    void buildTitle(String title);
    void buildContent(String content);
    void buildFooter(String footer);
    void buildSection(String section);
    Document getDocument();
}

/**
 * 具体建造者：HTML 文档建造者
 */
class HtmlDocumentBuilder implements DocumentBuilder {
    private Document document = new Document();

    @Override
    public void buildTitle(String title) {
        document.setTitle("<h1>" + title + "</h1>");
    }

    @Override
    public void buildContent(String content) {
        document.setContent("<p>" + content + "</p>");
    }

    @Override
    public void buildFooter(String footer) {
        document.setFooter("<footer>" + footer + "</footer>");
    }

    @Override
    public void buildSection(String section) {
        document.addSection("<section>" + section + "</section>");
    }

    @Override
    public Document getDocument() {
        return document;
    }
}

/**
 * 具体建造者：Markdown 文档建造者
 */
class MarkdownDocumentBuilder implements DocumentBuilder {
    private Document document = new Document();

    @Override
    public void buildTitle(String title) {
        document.setTitle("# " + title);
    }

    @Override
    public void buildContent(String content) {
        document.setContent(content);
    }

    @Override
    public void buildFooter(String footer) {
        document.setFooter("---\n" + footer);
    }

    @Override
    public void buildSection(String section) {
        document.addSection("## " + section);
    }

    @Override
    public Document getDocument() {
        return document;
    }
}

/**
 * Director：指挥构建过程
 */
class DocumentDirector {
    private DocumentBuilder builder;

    public DocumentDirector(DocumentBuilder builder) {
        this.builder = builder;
    }

    public void setBuilder(DocumentBuilder builder) {
        this.builder = builder;
    }

    public Document constructSimpleDocument(String title, String content) {
        builder.buildTitle(title);
        builder.buildContent(content);
        builder.buildFooter("Generated by Builder Pattern");
        return builder.getDocument();
    }

    public Document constructComplexDocument(String title, String content, java.util.List<String> sections) {
        builder.buildTitle(title);
        builder.buildContent(content);
        for (String section : sections) {
            builder.buildSection(section);
        }
        builder.buildFooter("© 2025 Builder Pattern Demo");
        return builder.getDocument();
    }
}

// 使用示例
public class DocumentBuilderDemo {
    public static void main(String[] args) {
        DocumentDirector director = new DocumentDirector(null);

        // 构建 HTML 文档
        HtmlDocumentBuilder htmlBuilder = new HtmlDocumentBuilder();
        director.setBuilder(htmlBuilder);
        Document htmlDoc = director.constructComplexDocument(
                "Builder Pattern",
                "This is a design pattern for building complex objects.",
                java.util.Arrays.asList("Introduction", "Implementation", "Examples")
        );
        System.out.println("HTML Document: " + htmlDoc);

        // 构建 Markdown 文档
        MarkdownDocumentBuilder mdBuilder = new MarkdownDocumentBuilder();
        director.setBuilder(mdBuilder);
        Document mdDoc = director.constructComplexDocument(
                "Builder Pattern",
                "This is a design pattern for building complex objects.",
                java.util.Arrays.asList("Introduction", "Implementation", "Examples")
        );
        System.out.println("Markdown Document: " + mdDoc);
    }
}
```

#### 实现 3：JDK 中的 StringBuilder

```java
/**
 * StringBuilder 是典型的 Builder 模式应用
 */
public class StringBuilderDemo {
    public static void main(String[] args) {
        // StringBuilder 的链式调用
        String result = new StringBuilder()
                .append("Hello")
                .append(" ")
                .append("World")
                .insert(5, " Beautiful")
                .replace(0, 5, "Hi")
                .toString();

        System.out.println(result);  // "Hi Beautiful World"
    }
}
```

#### 实现 4：Lombok @Builder 注解

```java
import lombok.Builder;
import lombok.ToString;

/**
 * 使用 Lombok 自动生成 Builder
 */
@Builder
@ToString
class User {
    // 必需参数
    private final String name;
    private final Integer age;

    // 可选参数
    private String email;
    private String phone;
    private String address;
}

// 使用
public class LombokBuilderDemo {
    public static void main(String[] args) {
        // Lombok 自动生成的 Builder
        User user = User.builder()
                .name("Alice")
                .age(30)
                .email("alice@example.com")
                .phone("123-456-7890")
                .build();

        System.out.println(user);
    }
}
```

### 七、Python 经典案例

#### 实现 1：标准 Builder 模式

```python
from dataclasses import dataclass
from typing import Optional


@dataclass
class Computer:
    """产品类：电脑"""
    cpu: str
    ram: str
    storage: str = "256GB SSD"
    gpu: str = "Integrated"
    has_wifi: bool = True
    has_bluetooth: bool = True


class ComputerBuilder:
    """建造者类"""

    def __init__(self, cpu: str, ram: str):
        """必需参数"""
        self.cpu = cpu
        self.ram = ram
        # 可选参数默认值
        self.storage = "256GB SSD"
        self.gpu = "Integrated"
        self.has_wifi = True
        self.has_bluetooth = True

    def set_storage(self, storage: str) -> 'ComputerBuilder':
        """链式调用"""
        self.storage = storage
        return self

    def set_gpu(self, gpu: str) -> 'ComputerBuilder':
        self.gpu = gpu
        return self

    def set_wifi(self, has_wifi: bool) -> 'ComputerBuilder':
        self.has_wifi = has_wifi
        return self

    def set_bluetooth(self, has_bluetooth: bool) -> 'ComputerBuilder':
        self.has_bluetooth = has_bluetooth
        return self

    def build(self) -> Computer:
        """构建最终对象"""
        return Computer(
            cpu=self.cpu,
            ram=self.ram,
            storage=self.storage,
            gpu=self.gpu,
            has_wifi=self.has_wifi,
            has_bluetooth=self.has_bluetooth
        )


# 使用
def main():
    # 最小配置
    basic = ComputerBuilder("Intel i5", "8GB").build()
    print(f"Basic: {basic}")

    # 游戏配置
    gaming = (ComputerBuilder("Intel i9", "32GB")
              .set_storage("1TB NVMe SSD")
              .set_gpu("RTX 4090")
              .set_wifi(True)
              .set_bluetooth(True)
              .build())
    print(f"Gaming: {gaming}")

    # 办公配置
    office = (ComputerBuilder("Intel i7", "16GB")
              .set_storage("512GB SSD")
              .set_wifi(True)
              .set_bluetooth(False)
              .build())
    print(f"Office: {office}")


if __name__ == "__main__":
    main()
```

#### 实现 2：使用 Director 的标准模式

```python
from abc import ABC, abstractmethod
from typing import List
from dataclasses import dataclass, field


@dataclass
class Document:
    """产品类：文档"""
    title: str = ""
    content: str = ""
    footer: str = ""
    sections: List[str] = field(default_factory=list)


class DocumentBuilder(ABC):
    """Builder 抽象类"""

    @abstractmethod
    def build_title(self, title: str) -> None:
        pass

    @abstractmethod
    def build_content(self, content: str) -> None:
        pass

    @abstractmethod
    def build_footer(self, footer: str) -> None:
        pass

    @abstractmethod
    def build_section(self, section: str) -> None:
        pass

    @abstractmethod
    def get_document(self) -> Document:
        pass


class HtmlDocumentBuilder(DocumentBuilder):
    """HTML 文档建造者"""

    def __init__(self):
        self.document = Document()

    def build_title(self, title: str) -> None:
        self.document.title = f"<h1>{title}</h1>"

    def build_content(self, content: str) -> None:
        self.document.content = f"<p>{content}</p>"

    def build_footer(self, footer: str) -> None:
        self.document.footer = f"<footer>{footer}</footer>"

    def build_section(self, section: str) -> None:
        self.document.sections.append(f"<section>{section}</section>")

    def get_document(self) -> Document:
        return self.document


class MarkdownDocumentBuilder(DocumentBuilder):
    """Markdown 文档建造者"""

    def __init__(self):
        self.document = Document()

    def build_title(self, title: str) -> None:
        self.document.title = f"# {title}"

    def build_content(self, content: str) -> None:
        self.document.content = content

    def build_footer(self, footer: str) -> None:
        self.document.footer = f"---\n{footer}"

    def build_section(self, section: str) -> None:
        self.document.sections.append(f"## {section}")

    def get_document(self) -> Document:
        return self.document


class DocumentDirector:
    """Director：指挥构建过程"""

    def __init__(self, builder: DocumentBuilder):
        self.builder = builder

    def set_builder(self, builder: DocumentBuilder) -> None:
        self.builder = builder

    def construct_simple_document(self, title: str, content: str) -> Document:
        """构建简单文档"""
        self.builder.build_title(title)
        self.builder.build_content(content)
        self.builder.build_footer("Generated by Builder Pattern")
        return self.builder.get_document()

    def construct_complex_document(self, title: str, content: str, sections: List[str]) -> Document:
        """构建复杂文档"""
        self.builder.build_title(title)
        self.builder.build_content(content)
        for section in sections:
            self.builder.build_section(section)
        self.builder.build_footer("© 2025 Builder Pattern Demo")
        return self.builder.get_document()


# 使用
def main():
    director = DocumentDirector(HtmlDocumentBuilder())

    # 构建 HTML 文档
    html_builder = HtmlDocumentBuilder()
    director.set_builder(html_builder)
    html_doc = director.construct_complex_document(
        "Builder Pattern",
        "This is a design pattern for building complex objects.",
        ["Introduction", "Implementation", "Examples"]
    )
    print(f"HTML Document: {html_doc}")

    # 构建 Markdown 文档
    md_builder = MarkdownDocumentBuilder()
    director.set_builder(md_builder)
    md_doc = director.construct_complex_document(
        "Builder Pattern",
        "This is a design pattern for building complex objects.",
        ["Introduction", "Implementation", "Examples"]
    )
    print(f"Markdown Document: {md_doc}")


if __name__ == "__main__":
    main()
```

#### 实现 3：使用上下文管理器的 Builder

```python
from typing import List, Optional


class SQLQueryBuilder:
    """SQL 查询构建器"""

    def __init__(self):
        self._select: List[str] = []
        self._from: Optional[str] = None
        self._where: List[str] = []
        self._group_by: List[str] = []
        self._order_by: List[str] = []
        self._limit: Optional[int] = None

    def select(self, *columns: str) -> 'SQLQueryBuilder':
        """添加 SELECT 字段"""
        self._select.extend(columns)
        return self

    def from_table(self, table: str) -> 'SQLQueryBuilder':
        """添加 FROM 表"""
        self._from = table
        return self

    def where(self, condition: str) -> 'SQLQueryBuilder':
        """添加 WHERE 条件"""
        self._where.append(condition)
        return self

    def group_by(self, *columns: str) -> 'SQLQueryBuilder':
        """添加 GROUP BY"""
        self._group_by.extend(columns)
        return self

    def order_by(self, *columns: str) -> 'SQLQueryBuilder':
        """添加 ORDER BY"""
        self._order_by.extend(columns)
        return self

    def limit(self, count: int) -> 'SQLQueryBuilder':
        """添加 LIMIT"""
        self._limit = count
        return self

    def build(self) -> str:
        """构建最终的 SQL 查询"""
        query = []

        if not self._select:
            raise ValueError("SELECT cannot be empty")
        query.append(f"SELECT {', '.join(self._select)}")

        if not self._from:
            raise ValueError("FROM table is required")
        query.append(f"FROM {self._from}")

        if self._where:
            query.append(f"WHERE {' AND '.join(self._where)}")

        if self._group_by:
            query.append(f"GROUP BY {', '.join(self._group_by)}")

        if self._order_by:
            query.append(f"ORDER BY {', '.join(self._order_by)}")

        if self._limit:
            query.append(f"LIMIT {self._limit}")

        return " ".join(query)


# 使用
def main():
    # 简单查询
    query1 = (SQLQueryBuilder()
              .select("*")
              .from_table("users")
              .build())
    print(f"Query 1: {query1}")

    # 复杂查询
    query2 = (SQLQueryBuilder()
              .select("name", "email", "COUNT(*) as count")
              .from_table("users")
              .where("age > 18")
              .where("status = 'active'")
              .group_by("name", "email")
              .order_by("count DESC")
              .limit(10)
              .build())
    print(f"Query 2: {query2}")


if __name__ == "__main__":
    main()
```

#### 实现 4：使用函数式构建器

```python
from typing import Callable, TypeVar, TypeVarTuple

T = TypeVar('T')


class ConfigBuilder:
    """配置构建器"""

    def __init__(self):
        self.config = {}

    def set(self, key: str, value: str) -> 'ConfigBuilder':
        self.config[key] = value
        return self

    def set_multiple(self, **kwargs) -> 'ConfigBuilder':
        self.config.update(kwargs)
        return self

    def remove(self, key: str) -> 'ConfigBuilder':
        self.config.pop(key, None)
        return self

    def build(self) -> dict:
        return self.config.copy()


# 函数式构建器
def build_config(configurator: Callable[[ConfigBuilder], None]) -> dict:
    """
    函数式构建器
    接收一个函数来配置 Builder
    """
    builder = ConfigBuilder()
    configurator(builder)
    return builder.build()


# 使用
def main():
    # 标准方式
    config1 = (ConfigBuilder()
               .set("host", "localhost")
               .set("port", "8080")
               .set("debug", "true")
               .build())
    print(f"Config 1: {config1}")

    # 函数式方式
    config2 = build_config(
        lambda b: b.set("host", "localhost")
                   .set("port", "5432")
                   .set("database", "mydb")
                   .set_multiple(
                       user="admin",
                       password="secret",
                       timeout="30"
                   )
    )
    print(f"Config 2: {config2}")


if __name__ == "__main__":
    main()
```

### 八、参考资料与延伸阅读

#### 经典书籍

- 《Effective Java（第三版）》- Joshua Bloch（第2条：遇到多个构造器参数时要考虑用构建器）
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 建造者模式章节

#### 在线资源

- [Refactoring.Guru - Builder](https://refactoring.guru/design-patterns/builder)
- [Java设计模式：建造者模式](https://java-design-patterns.com/patterns/builder/)
- [Python设计模式：Builder](https://refactoring.guru/design-patterns/builder/python/example)

#### 相关设计模式

- **Abstract Factory（抽象工厂）**：专注于创建产品族，Builder 专注于分步构建
- **Factory Method（工厂方法）**：创建单个对象，Builder 构建复杂对象
- **Composite（组合）**：Builder 常用于构建组合结构
- **Facade（外观）**：Facade 可以用 Builder 来构建复杂子系统

#### 最佳实践建议

1. **Java**：
   - 优先使用 Lombok `@Builder` 注解
   - Builder 作为静态内部类
   - 链式调用返回 Builder 实例
   - 必需参数通过构造函数传入

2. **Python**：
   - 返回 self 实现链式调用
   - 使用类型注解提高可读性
   - 使用 dataclasses 定义产品类
   - 考虑使用上下文管理器

3. **通用建议**：
   - 验证参数在 build() 方法中统一进行
   - 产品类不可变时，Builder 是理想选择
   - 4个以上参数时考虑使用 Builder
