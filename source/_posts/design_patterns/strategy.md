---
title: Strategy 模式
date: 2023-01-07
updated: 2025-01-09
categories:
  - 设计模式
tags:
  - 设计模式
  - 行为型模式
description: Strategy模式定义了一系列算法，并将每个算法封装起来，使它们可以相互替换，让算法独立于使用它的客户端而变化。
toc: true
---

## Strategy 模式

### 一、基础介绍

Strategy（策略）模式是一种行为型设计模式，它定义了一系列算法，将每个算法封装到具有共同接口的独立的类中，从而使得它们可以相互替换。

Strategy 模式的核心思想是：**将算法封装成独立的类，使它们可以互相替换，让算法的变化独立于使用算法的客户**。

### 二、生活比喻：出行方式

想象一个人**要去机场**：

> **没有策略**：你把所有的出行方式（开车、打车、地铁、公交）都写在一个方法里。代码臃肿，难以维护，添加新方式需要修改主代码。
>
> **策略方式**：你定义一个"出行方式"接口，有开车、打车、地铁等具体策略。根据天气、时间、预算等条件，选择合适的策略。

在这个比喻中：
- **Strategy** = 出行方式接口
- **ConcreteStrategy** = 具体出行方式（开车、打车、地铁）
- **Context** = 旅行者（使用策略的人）

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **多种算法** | 同一问题有多种解决方式 | 排序算法、压缩算法 |
| **动态切换** | 需要在运行时切换算法 | 支付方式、日志级别 |
| **避免条件语句** | 大量 if-else 或 switch-case | 折扣计算、验证规则 |
| **算法隔离**：算法与使用代码分离 | 业务逻辑与实现解耦 |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **符合开闭原则** | 新增策略无需修改上下文 |
| **避免条件语句** | 消除冗长的 if-else |
| **算法解耦** | 算法与使用代码分离 |
| **运行时切换** | 可动态改变行为 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **类数量增加** | 每个策略一个类 |
| **客户端必须知道策略** | 需要选择合适的策略 |
| **通信开销**：策略间可能无法共享信息 |

#### 使用建议

- 同一问题有多种算法时使用
- 算法需要频繁切换时使用
- 算法复杂且需要隔离时使用

### 五、Java 经典案例

#### 实现 1：支付方式选择

```java
/**
 * 策略接口：支付方式
 */
interface PaymentStrategy {
    void pay(int amount);
}

/**
 * 具体策略：信用卡支付
 */
class CreditCardPayment implements PaymentStrategy {
    private String cardNumber;

    public CreditCardPayment(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public void pay(int amount) {
        System.out.println("使用信用卡支付 $" + amount);
    }
}

/**
 * 具体策略：支付宝支付
 */
class AlipayPayment implements PaymentStrategy {
    private String accountId;

    public AlipayPayment(String accountId) {
        this.accountId = accountId;
    }

    public void pay(int amount) {
        System.out.println("使用支付宝支付 ¥" + amount);
    }
}

/**
 * 具体策略：微信支付
 */
class WeChatPayment implements PaymentStrategy {
    private String openId;

    public WeChatPayment(String openId) {
        this.openId = openId;
    }

    public void pay(int amount) {
        System.out.println("使用微信支付 ¥" + amount);
    }
}

/**
 * 上下文：购物车
 */
class ShoppingCart {
    private PaymentStrategy paymentStrategy;

    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.paymentStrategy = strategy;
    }

    public void checkout(int amount) {
        paymentStrategy.pay(amount);
    }
}

// 使用
public class StrategyDemo {
    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();

        // 根据用户选择切换支付方式
        cart.setPaymentStrategy(new AlipayPayment("user@example.com"));
        cart.checkout(100);

        cart.setPaymentStrategy(new WeChatPayment("wx_openid_123"));
        cart.checkout(200);
    }
}
```

#### 实现 2：排序算法选择

```java
import java.util.List;
import java.util.ArrayList;
import java.util.Collections;

/**
 * 策略接口：排序算法
 */
interface SortStrategy {
    List<Integer> sort(List<Integer> list);
}

/**
 * 具体策略：冒泡排序
 */
class BubbleSort implements SortStrategy {
    public List<Integer> sort(List<Integer> list) {
        System.out.println("使用冒泡排序");
        List<Integer> result = new ArrayList<>(list);
        int n = result.size();
        for (int i = 0; i < n - 1; i++) {
            for (int j = 0; j < n - i - 1; j++) {
                if (result.get(j) > result.get(j + 1)) {
                    Collections.swap(result, j, j + 1);
                }
            }
        }
        return result;
    }
}

/**
 * 具体策略：快速排序
 */
class QuickSort implements SortStrategy {
    public List<Integer> sort(List<Integer> list) {
        System.out.println("使用快速排序");
        List<Integer> result = new ArrayList<>(list);
        quickSort(result, 0, result.size() - 1);
        return result;
    }

    private void quickSort(List<Integer> list, int low, int high) {
        if (low < high) {
            int pi = partition(list, low, high);
            quickSort(list, low, pi - 1);
            quickSort(list, pi + 1, high);
        }
    }

    private int partition(List<Integer> list, int low, int high) {
        int pivot = list.get(high);
        int i = low - 1;
        for (int j = low; j < high; j++) {
            if (list.get(j) <= pivot) {
                i++;
                Collections.swap(list, i, j);
            }
        }
        Collections.swap(list, i + 1, high);
        return i + 1;
    }
}

/**
 * 上下文：排序器
 */
class Sorter {
    private SortStrategy strategy;

    public void setStrategy(SortStrategy strategy) {
        this.strategy = strategy;
    }

    public List<Integer> sort(List<Integer> list) {
        return strategy.sort(list);
    }
}

// 使用
public class SortStrategyDemo {
    public static void main(String[] args) {
        List<Integer> data = List.of(5, 2, 8, 1, 9);

        Sorter sorter = new Sorter();

        // 小数据量用冒泡排序
        sorter.setStrategy(new BubbleSort());
        System.out.println(sorter.sort(data));

        // 大数据量用快速排序
        sorter.setStrategy(new QuickSort());
        System.out.println(sorter.sort(data));
    }
}
```

### 六、Python 经典案例

#### 实现 1：折扣计算策略

```python
from abc import ABC, abstractmethod
from typing import Protocol


class DiscountStrategy(Protocol):
    """折扣策略接口"""

    def calculate_discount(self, price: float) -> float:
        ...


class NoDiscount:
    """无折扣策略"""

    def calculate_discount(self, price: float) -> float:
        return 0.0


class PercentageDiscount:
    """百分比折扣策略"""

    def __init__(self, percentage: float):
        self.percentage = percentage

    def calculate_discount(self, price: float) -> float:
        return price * self.percentage / 100


class FixedAmountDiscount:
    """固定金额折扣策略"""

    def __init__(self, amount: float):
        self.amount = amount

    def calculate_discount(self, price: float) -> float:
        return min(self.amount, price)


class SeasonalDiscount:
    """季节性折扣策略"""

    def calculate_discount(self, price: float) -> float:
        # 假设当前季节有8折优惠
        return price * 0.2


class ShoppingCart:
    """购物车上下文"""

    def __init__(self, strategy: DiscountStrategy):
        self.strategy = strategy
        self.items: list[tuple[str, float]] = []

    def add_item(self, item: str, price: float) -> None:
        self.items.append((item, price))

    def set_discount_strategy(self, strategy: DiscountStrategy) -> None:
        self.strategy = strategy

    def calculate_total(self) -> float:
        subtotal = sum(price for _, price in self.items)
        discount = self.strategy.calculate_discount(subtotal)
        return subtotal - discount

    def print_receipt(self) -> None:
        total = self.calculate_total()
        print(f"=== 购物小票 ===")
        for item, price in self.items:
            print(f"{item}: ¥{price}")
        print(f"总计: ¥{total:.2f}")


# 使用
def main():
    # 创建购物车
    cart = ShoppingCart(NoDiscount())
    cart.add_item("Python编程书", 89)
    cart.add_item("机械键盘", 299)

    # 无折扣
    print("无折扣:")
    cart.print_receipt()

    # 百分比折扣
    cart.set_discount_strategy(PercentageDiscount(15))
    print("\n85折优惠:")
    cart.print_receipt()

    # 固定金额折扣
    cart.set_discount_strategy(FixedAmountDiscount(50))
    print("\n立减50元:")
    cart.print_receipt()


if __name__ == "__main__":
    main()
```

#### 实现 2：文件压缩策略

```python
import zlib
import gzip
import json
from abc import ABC, abstractmethod
from typing import Protocol


class CompressionStrategy(Protocol):
    """压缩策略接口"""

    def compress(self, data: str) -> bytes:
        ...

    def decompress(self, data: bytes) -> str:
        ...


class NoCompression:
    """无压缩策略"""

    def compress(self, data: str) -> bytes:
        return data.encode('utf-8')

    def decompress(self, data: bytes) -> str:
        return data.decode('utf-8')


class ZlibCompression:
    """Zlib 压缩策略"""

    def compress(self, data: str) -> bytes:
        return zlib.compress(data.encode('utf-8'))

    def decompress(self, data: bytes) -> str:
        return zlib.decompress(data).decode('utf-8')


class GzipCompression:
    """Gzip 压缩策略"""

    def compress(self, data: str) -> bytes:
        return gzip.compress(data.encode('utf-8'))

    def decompress(self, data: bytes) -> str:
        return gzip.decompress(data).decode('utf-8')


class JSONCompression:
    """JSON 格式化压缩策略"""

    def compress(self, data: str) -> bytes:
        # 先解析为JSON，再压缩
        obj = json.loads(data)
        return gzip.compress(json.dumps(obj).encode('utf-8'))

    def decompress(self, data: bytes) -> str:
        return gzip.decompress(data).decode('utf-8')


class DataProcessor:
    """数据处理器上下文"""

    def __init__(self, strategy: CompressionStrategy):
        self.strategy = strategy

    def set_strategy(self, strategy: CompressionStrategy) -> None:
        self.strategy = strategy

    def save_data(self, data: str, filename: str) -> None:
        """保存数据（应用压缩）"""
        compressed = self.strategy.compress(data)
        with open(filename, 'wb') as f:
            f.write(compressed)
        print(f"数据已保存到 {filename}")

    def load_data(self, filename: str) -> str:
        """加载数据（应用解压）"""
        with open(filename, 'rb') as f:
            compressed = f.read()
        return self.strategy.decompress(compressed)


# 使用
def main():
    # 准备数据
    data = json.dumps({"name": "Alice", "age": 30, "city": "Beijing"})

    processor = DataProcessor(NoCompression())
    processor.save_data("data_plain.txt", data)

    # 使用 Zlib 压缩
    processor.set_strategy(ZlibCompression())
    processor.save_data("data_zlib.bin", data)
    print(f"解压: {processor.load_data('data_zlib.bin')}")

    # 使用 Gzip 压缩
    processor.set_strategy(GzipCompression())
    processor.save_data("data_gzip.bin", data)
    print(f"解压: {processor.load_data('data_gzip.bin')}")


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 策略模式章节

#### 在线资源
- [Refactoring.Guru - Strategy](https://refactoring.guru/design-patterns/strategy)
- [Java设计模式：策略模式](https://java-design-patterns.com/patterns/strategy/)

#### 相关设计模式
- **State（状态）**：State 改变内部状态，Strategy 改变行为
- **Factory Method（工厂方法）**：可配合创建策略对象
- **Decorator（装饰）**：Decorator 改变对象外观，Strategy 改变行为

#### 最佳实践建议
1. 策略接口保持简单
2. 每个策略独立无状态
3. 上下文通过组合使用策略
4. 避免策略间相互依赖
