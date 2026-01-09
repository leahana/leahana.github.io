---
title: Facade 模式
date: 2023-01-12
updated: 2025-01-09
categories:
  - 设计模式
tags:
  - 设计模式
  - 结构型模式
description: Facade模式为子系统中的一组接口提供一个一致的界面，定义一个高层接口，这个接口使得这一子系统更加容易使用。
toc: true
---

## Facade 模式

### 一、基础介绍

Facade（外观）模式是一种结构型设计模式，它为子系统中的一组接口提供一个一致的界面，定义一个高层接口，这个接口使得这一子系统更加容易使用。

Facade 模式的核心思想是：**通过一个外观类来封装复杂的子系统，为客户端提供简单易用的接口**。

### 二、生活比喻：餐厅点餐

想象一家**大型餐厅**：

> **没有 Facade**：顾客需要分别去窗口点菜、去饮料台点饮料、去收银台付款、去餐具区取餐具...流程繁琐，容易出错。
>
> **有 Facade（服务员）**：顾客只需要告诉服务员"我要一份套餐"，服务员会协调后厨、饮料台、收银台等各个部门，顾客无需关心内部流程。

在这个比喻中：
- **Facade** = 服务员（提供统一的点餐接口）
- **Subsystem** = 后厨、饮料台、收银台等（复杂的子系统）
- **Client** = 顾客（只需要与 Facade 交互）

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **简化复杂接口** | 子系统接口复杂难用 | 库存管理系统、支付系统 |
| **解耦客户端与子系统** | 减少客户端对子系统的依赖 | API 网关、服务层 |
| **层次化架构** | 构建分层系统 | MVC 架构、微服务网关 |
| **遗留系统重构** | 逐步重构老系统 | 包装旧的复杂 API |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **简化使用** | 提供简单统一的高层接口 |
| **解耦** | 客户端与子系统解耦 |
| **灵活组合**：可以灵活组合子系统功能 |
| **易于维护**：减少客户端对子系统的直接依赖 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **功能受限**：Facade 只提供部分功能 |
| **过度封装**：可能导致不必要的间接层 |
| **职责不清**：Facade 可能变成"上帝对象" |

#### 使用建议

- 子系统复杂、接口众多时使用
- 需要隐藏子系统复杂性时使用
- 需要解耦客户端与子系统时使用

### 五、Java 经典案例

#### 实现 1：家庭影院系统

```java
/**
 * 子系统：各种设备
 */
class Amplifier {
    private String description;

    public Amplifier(String description) {
        this.description = description;
    }

    public void on() {
        System.out.println(description + " 打开");
    }

    public void off() {
        System.out.println(description + " 关闭");
    }

    public void setVolume(int level) {
        System.out.println(description + " 音量设置为 " + level);
    }
}

class DvdPlayer {
    private String description;

    public DvdPlayer(String description) {
        this.description = description;
    }

    public void on() {
        System.out.println(description + " 打开");
    }

    public void play(String movie) {
        System.out.println(description + " 播放 \"" + movie + "\"");
    }

    public void stop() {
        System.out.println(description + " 停止");
    }
}

class Projector {
    private String description;

    public Projector(String description) {
        this.description = description;
    }

    public void on() {
        System.out.println(description + " 打开");
    }

    public void setInput(String input) {
        System.out.println(description + " 输入设置为 " + input);
    }
}

class TheaterLights {
    private String description;

    public TheaterLights(String description) {
        this.description = description;
    }

    public void dim(int level) {
        System.out.println(description + " 调暗至 " + level + "%");
    }
}

/**
 * 外观类：家庭影院统一接口
 */
class HomeTheaterFacade {
    private Amplifier amp;
    private DvdPlayer dvd;
    private Projector projector;
    private TheaterLights lights;

    public HomeTheaterFacade(Amplifier amp, DvdPlayer dvd,
                             Projector projector, TheaterLights lights) {
        this.amp = amp;
        this.dvd = dvd;
        this.projector = projector;
        this.lights = lights;
    }

    public void watchMovie(String movie) {
        System.out.println("准备观看电影...");
        lights.dim(10);
        projector.on();
        projector.setInput("DVD");
        amp.on();
        amp.setVolume(5);
        dvd.on();
        dvd.play(movie);
    }

    public void endMovie() {
        System.out.println("结束观影...");
        lights.dim(100);
        amp.off();
        projector.off();
        dvd.stop();
        dvd.off();
    }
}

// 使用
public class FacadeDemo {
    public static void main(String[] args) {
        // 创建子系统组件
        Amplifier amp = new Amplifier("功放");
        DvdPlayer dvd = new DvdPlayer("DVD播放器");
        Projector projector = new Projector("投影仪");
        TheaterLights lights = new TheaterLights("影院灯光");

        // 创建外观
        HomeTheaterFacade theater = new HomeTheaterFacade(amp, dvd, projector, lights);

        // 使用简单接口
        theater.watchMovie("复仇者联盟");
        System.out.println();
        theater.endMovie();
    }
}
```

#### 实现 2：订单处理系统

```java
import java.util.HashMap;
import java.util.Map;

/**
 * 子系统：库存管理
 */
class InventoryManager {
    private Map<String, Integer> inventory = new HashMap<>();

    public InventoryManager() {
        inventory.put("Product A", 100);
        inventory.put("Product B", 50);
    }

    public boolean checkStock(String productId, int quantity) {
        int available = inventory.getOrDefault(productId, 0);
        return available >= quantity;
    }

    public void reduceStock(String productId, int quantity) {
        int available = inventory.get(productId);
        inventory.put(productId, available - quantity);
        System.out.println("库存更新: " + productId + " 剩余 " + (available - quantity));
    }
}

/**
 * 子系统：支付处理
 */
class PaymentProcessor {
    public boolean processPayment(String accountId, double amount) {
        System.out.println("处理支付: 账户 " + accountId + " 金额 " + amount);
        return true;  // 简化示例，假设总是成功
    }
}

/**
 * 子系统：物流安排
 */
class ShippingManager {
    public void arrangeShipping(String address, String orderId) {
        System.out.println("安排发货: 订单 " + orderId + " 到 " + address);
    }
}

/**
 * 子系统：通知系统
 */
class NotificationService {
    public void sendConfirmation(String email, String orderId) {
        System.out.println("发送确认邮件到 " + email + ", 订单 " + orderId);
    }
}

/**
 * 外观类：订单处理统一接口
 */
class OrderProcessingFacade {
    private InventoryManager inventory;
    private PaymentProcessor payment;
    private ShippingManager shipping;
    private NotificationService notification;

    public OrderProcessingFacade() {
        this.inventory = new InventoryManager();
        this.payment = new PaymentProcessor();
        this.shipping = new ShippingManager();
        this.notification = new NotificationService();
    }

    public boolean placeOrder(String productId, int quantity,
                              String accountId, String address, String email) {
        System.out.println("=== 开始处理订单 ===");

        // 1. 检查库存
        if (!inventory.checkStock(productId, quantity)) {
            System.out.println("库存不足，订单失败");
            return false;
        }

        // 2. 处理支付
        double amount = quantity * 99.99;  // 简化价格计算
        if (!payment.processPayment(accountId, amount)) {
            System.out.println("支付失败，订单取消");
            return false;
        }

        // 3. 减少库存
        inventory.reduceStock(productId, quantity);

        // 4. 安排发货
        String orderId = "ORD-" + System.currentTimeMillis();
        shipping.arrangeShipping(address, orderId);

        // 5. 发送通知
        notification.sendConfirmation(email, orderId);

        System.out.println("=== 订单处理完成 ===");
        return true;
    }
}

// 使用
public class OrderDemo {
    public static void main(String[] args) {
        OrderProcessingFacade orders = new OrderProcessingFacade();

        orders.placeOrder("Product A", 2, "ACC001",
                         "北京市朝阳区xxx", "customer@example.com");
    }
}
```

### 六、Python 经典案例

#### 实现 1：计算机启动系统

```python
from typing import Protocol


class CPU:
    """CPU 子系统"""

    def freeze(self) -> None:
        print("CPU 停止")

    def jump(self, position: int) -> None:
        print(f"CPU 跳转到位置 {position}")

    def execute(self) -> None:
        print("CPU 执行指令")


class Memory:
    """内存子系统"""

    def load(self, position: int, data: str) -> None:
        print(f"内存加载: 位置 {position}, 数据 {data}")


class HardDrive:
    """硬盘子系统"""

    def read(self, lba: int, size: int) -> str:
        print(f"硬盘读取: LBA {lba}, 大小 {size}")
        return "boot_data"


class ComputerFacade:
    """计算机外观：统一的启动接口"""

    def __init__(self):
        self.cpu = CPU()
        self.memory = Memory()
        self.hard_drive = HardDrive()

    def start(self) -> None:
        """统一的启动接口"""
        print("=== 计算机启动 ===")

        # 1. 从硬盘加载引导数据
        boot_data = self.hard_drive.read(0, 4096)

        # 2. 加载到内存
        self.memory.load(0, boot_data)

        # 3. CPU 执行
        self.cpu.jump(0)
        self.cpu.execute()

        print("=== 计算机启动完成 ===")

    def shutdown(self) -> None:
        """统一的关机接口"""
        print("=== 计算机关机 ===")
        self.cpu.freeze()
        print("=== 计算机已关闭 ===")


# 使用
def main():
    computer = ComputerFacade()

    # 简单的接口启动计算机
    computer.start()
    print()
    computer.shutdown()


if __name__ == "__main__":
    main()
```

#### 实现 2：API 网关

```python
from typing import Dict, List, Optional
from abc import ABC, abstractmethod


# ============ 子系统 ============
class UserService:
    """用户服务子系统"""

    _users: Dict[str, Dict] = {
        "user1": {"id": "user1", "name": "Alice", "email": "alice@example.com"},
        "user2": {"id": "user2", "name": "Bob", "email": "bob@example.com"}
    }

    def get_user(self, user_id: str) -> Optional[Dict]:
        return self._users.get(user_id)

    def create_user(self, name: str, email: str) -> Dict:
        user_id = "user" + str(len(self._users) + 1)
        user = {"id": user_id, "name": name, "email": email}
        self._users[user_id] = user
        return user

    def delete_user(self, user_id: str) -> bool:
        if user_id in self._users:
            del self._users[user_id]
            return True
        return False


class OrderService:
    """订单服务子系统"""

    _orders: List[Dict] = []

    def create_order(self, user_id: str, items: List[str]) -> Dict:
        order_id = "ORD-" + str(len(self._orders) + 1)
        order = {
            "id": order_id,
            "user_id": user_id,
            "items": items,
            "status": "pending"
        }
        self._orders.append(order)
        return order

    def get_order(self, order_id: str) -> Optional[Dict]:
        for order in self._orders:
            if order["id"] == order_id:
                return order
        return None

    def cancel_order(self, order_id: str) -> bool:
        order = self.get_order(order_id)
        if order:
            order["status"] = "cancelled"
            return True
        return False


class PaymentService:
    """支付服务子系统"""

    def process_payment(self, order_id: str, amount: float) -> bool:
        print(f"处理支付: 订单 {order_id}, 金额 {amount}")
        return True

    def refund(self, order_id: str, amount: float) -> bool:
        print(f"退款: 订单 {order_id}, 金额 {amount}")
        return True


class NotificationService:
    """通知服务子系统"""

    def send_email(self, to: str, subject: str, body: str) -> None:
        print(f"发送邮件到 {to}: {subject}")

    def send_sms(self, to: str, message: str) -> None:
        print(f"发送短信到 {to}: {message}")


# ============ 外观类 ============
class ECommerceFacade:
    """电商系统外观"""

    def __init__(self):
        self.user_service = UserService()
        self.order_service = OrderService()
        self.payment_service = PaymentService()
        self.notification_service = NotificationService()

    def create_account(self, name: str, email: str, phone: str) -> Dict:
        """创建账户的统一接口"""
        user = self.user_service.create_user(name, email)
        self.notification_service.send_email(
            email,
            "欢迎注册",
            f"欢迎 {name}！您的账户已创建。"
        )
        self.notification_service.send_sms(
            phone,
            f"欢迎 {name}！您的账户已创建。"
        )
        return user

    def place_order(self, user_id: str, items: List[str]) -> Optional[Dict]:
        """下单的统一接口"""
        # 检查用户
        user = self.user_service.get_user(user_id)
        if not user:
            print("用户不存在")
            return None

        # 创建订单
        order = self.order_service.create_order(user_id, items)

        # 处理支付
        amount = len(items) * 99.0
        if not self.payment_service.process_payment(order["id"], amount):
            self.order_service.cancel_order(order["id"])
            return None

        # 发送通知
        self.notification_service.send_email(
            user["email"],
            "订单确认",
            f"您的订单 {order['id']} 已创建。"
        )

        return order

    def cancel_order(self, order_id: str) -> bool:
        """取消订单的统一接口"""
        # 取消订单
        if not self.order_service.cancel_order(order_id):
            return False

        # 处理退款
        self.payment_service.refund(order_id, 99.0)

        return True


# 使用
def main():
    # 创建外观
    ecommerce = ECommerceFacade()

    # 创建账户
    user = ecommerce.create_account("Charlie", "charlie@example.com", "13800138000")
    print(f"用户创建成功: {user}\n")

    # 下单
    order = ecommerce.place_order(user["id"], ["商品A", "商品B"])
    print(f"订单创建成功: {order}\n")

    # 取消订单
    ecommerce.cancel_order(order["id"])


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 外观模式章节

#### 在线资源
- [Refactoring.Guru - Facade](https://refactoring.guru/design-patterns/facade)
- [Java设计模式：外观模式](https://java-design-patterns.com/patterns/facade/)

#### 相关设计模式
- **Abstract Factory**：可以与 Facade 结合使用
- **Mediator（中介者）**：Mediator 解耦同事对象，Facade 简化接口
- **Adapter（适配器）**：Adapter 转换接口，Facade 简化接口
- **Proxy（代理）**：Proxy 控制访问，Facade 简化访问

#### 最佳实践建议
1. Facade 保持简单，不包含业务逻辑
2. 一个 Facade 可以包装多个子系统
3. 可以创建多个 Facade 提供不同粒度的接口
4. 子系统可以不知道 Facade 的存在
