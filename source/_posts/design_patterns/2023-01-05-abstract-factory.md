---
title: Abstract Factory 模式
date: 2023-01-05 00:00:00 +0800
updated: 2026-01-09
categories: [设计模式]
tags: [设计模式, 创建型模式]
description: Abstract Factory模式提供一个创建一系列相关或相互依赖对象的接口，而无需指定它们具体的类，适用于需要创建产品族的场景。
toc: true
---

## Abstract Factory 模式

### 一、基础介绍

Abstract Factory（抽象工厂）模式是一种创建型设计模式，它提供一个接口，用于创建**相关或依赖对象家族**，而不需要明确指定具体类。

抽象工厂模式的核心思想是：**将一组相关的对象（产品族）的创建封装在一起，客户端通过抽象接口操作，无需关心具体实现**。

### 二、生活比喻：家具工厂

想象一家**跨国家具公司**：

> **传统方式**：如果你想买一套北欧风格的沙发和茶几，需要去北欧风格的店；如果想要中式风格的，又要去中式风格的店。每次更换风格，都要找不同的供应商。
>
> **抽象工厂方式**：家具公司提供统一的订购接口（AbstractFactory），你只需要告诉它"我要北欧风格"或"我要中式风格"，它就会为你搭配好整套家具（沙发+茶几+餐桌），保证风格统一。

在这个比喻中：
- **AbstractFactory** = 家具订购接口
- **ConcreteFactory** = 北欧风格工厂、中式风格工厂
- **AbstractProduct** = 抽象家具（沙发、茶几、餐桌）
- **ConcreteProduct** = 北欧沙发、中式茶几等具体产品

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **产品族创建** | 需要创建一系列相关对象 | GUI组件族（按钮+窗口） |
| **多系列切换** | 系统支持多种产品族 | 不同风格的UI主题 |
| **跨平台开发** | 不同平台需要不同实现 | Windows/Mac/Linux组件 |
| **数据库兼容** | 支持多种数据库 | MySQL/PostgreSQL/Oracle |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **产品族一致性** | 确保同一工厂的产品族配套使用 |
| **解耦创建与使用** | 客户端不依赖具体类 |
| **符合开闭原则** | 新增产品族无需修改现有代码 |
| **易于切换** | 可以轻松切换整个产品族 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **扩展困难** | 新增产品种类需要修改所有工厂 |
| **复杂性增加** | 类层级结构复杂 |
| **抽象性强** | 代码更抽象，理解成本高 |
| **过度设计** | 简单场景可能过度设计 |

### 五、Java 经典案例

#### GUI 组件工厂

```java
// 抽象产品
interface Button {
    void render();
    void onClick();
}

interface Checkbox {
    void render();
    void toggle();
}

// 具体产品 - Windows 风格
class WindowsButton implements Button {
    public void render() {
        System.out.println("Rendering Windows button");
    }
    public void onClick() {
        System.out.println("Windows button clicked");
    }
}

class WindowsCheckbox implements Checkbox {
    public void render() {
        System.out.println("Rendering Windows checkbox");
    }
    public void toggle() {
        System.out.println("Windows checkbox toggled");
    }
}

// 具体产品 - Mac 风格
class MacButton implements Button {
    public void render() {
        System.out.println("Rendering Mac button");
    }
    public void onClick() {
        System.out.println("Mac button clicked");
    }
}

class MacCheckbox implements Checkbox {
    public void render() {
        System.out.println("Rendering Mac checkbox");
    }
    public void toggle() {
        System.out.println("Mac checkbox toggled");
    }
}

// 抽象工厂
interface GUIFactory {
    Button createButton();
    Checkbox createCheckbox();
}

// 具体工厂
class WindowsFactory implements GUIFactory {
    public Button createButton() {
        return new WindowsButton();
    }
    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}

class MacFactory implements GUIFactory {
    public Button createButton() {
        return new MacButton();
    }
    public Checkbox createCheckbox() {
        return new MacCheckbox();
    }
}

// 客户端
class Application {
    private Button button;
    private Checkbox checkbox;

    public Application(GUIFactory factory) {
        button = factory.createButton();
        checkbox = factory.createCheckbox();
    }

    public void render() {
        button.render();
        checkbox.render();
    }
}

// 使用
public class AbstractFactoryDemo {
    public static void main(String[] args) {
        GUIFactory factory = System.getProperty("os.name").toLowerCase().contains("mac")
            ? new MacFactory()
            : new WindowsFactory();

        Application app = new Application(factory);
        app.render();
    }
}
```

### 六、Python 经典案例

#### 主题工厂（暗色/亮色主题）

```python
from abc import ABC, abstractmethod
from typing import Protocol


class Button(Protocol):
    def render(self) -> None: ...
    def click(self) -> None: ...


class Checkbox(Protocol):
    def render(self) -> None: ...
    def toggle(self) -> None: ...


class ThemeFactory(ABC):
    @abstractmethod
    def create_button(self) -> Button: pass

    @abstractmethod
    def create_checkbox(self) -> Checkbox: pass


# 亮色主题产品族
class LightButton:
    def render(self) -> None:
        print("Rendering Light button")
    def click(self) -> None:
        print("Light button clicked")


class LightCheckbox:
    def render(self) -> None:
        print("Rendering Light checkbox")
    def toggle(self) -> None:
        print("Light checkbox toggled")


class LightThemeFactory(ThemeFactory):
    def create_button(self) -> Button:
        return LightButton()
    def create_checkbox(self) -> Checkbox:
        return LightCheckbox()


# 暗色主题产品族
class DarkButton:
    def render(self) -> None:
        print("Rendering Dark button")
    def click(self) -> None:
        print("Dark button clicked")


class DarkCheckbox:
    def render(self) -> None:
        print("Rendering Dark checkbox")
    def toggle(self) -> None:
        print("Dark checkbox toggled")


class DarkThemeFactory(ThemeFactory):
    def create_button(self) -> Button:
        return DarkButton()
    def create_checkbox(self) -> Checkbox:
        return DarkCheckbox()


# 客户端
class Application:
    def __init__(self, factory: ThemeFactory):
        self.button = factory.create_button()
        self.checkbox = factory.create_checkbox()

    def render(self):
        self.button.render()
        self.checkbox.render()


# 使用
def main():
    factory = DarkThemeFactory()  # 或 LightThemeFactory()
    app = Application(factory)
    app.render()


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 抽象工厂模式章节

#### 在线资源
- [Refactoring.Guru - Abstract Factory](https://refactoring.guru/design-patterns/abstract-factory)
- [Java设计模式：抽象工厂模式](https://java-design-patterns.com/patterns/abstract-factory/)

#### 相关设计模式
- **Factory Method**：创建单个对象，Abstract Factory 创建产品族
- **Builder**：关注构建复杂对象，Abstract Factory 关注产品族
- **Prototype**：可以用原型存储产品族实例
- **Singleton**：具体工厂通常是单例
- **Facade**：可以用 Abstract Factory 简化子系统创建

#### 最佳实践建议
1. 产品族稳定时使用，频繁变动时不适用
2. 一个工厂对应一个产品族
3. 保持产品族的一致性
4. 新增产品种类代价大，谨慎设计

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2023-01-05 | 初始版本 |
