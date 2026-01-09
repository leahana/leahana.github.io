---
title: Chain of Responsibility 模式
date: 2023-01-10
updated: 2025-01-09
categories:
  - 设计模式
tags:
  - 设计模式
  - 行为型模式
description: Chain of Responsibility模式为请求创建一个接收者对象链，使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系。
toc: true
---

## Chain of Responsibility 模式

### 一、基础介绍

Chain of Responsibility（责任链）模式是一种行为型设计模式，它允许你将请求沿着处理链传递，直到有一个处理者能够处理它为止。

Chain of Responsibility 模式的核心思想是：**为请求创建一个接收者对象链，使多个对象都有机会处理请求，从而避免请求的发送者和接收者之间的耦合关系**。

### 二、生活比喻：客服工单处理

想象一个**客服工单处理系统**：

> **没有责任链**：客服接到问题后，需要自己判断找哪个部门，技术问题、财务问题、物流问题都需要分别转接。流程复杂，容易出错。
>
> **责任链方式**：设置处理链条 - 一线客服 → 二线技术 → 技术主管 → 产品经理。问题沿着链条传递，直到有人能解决。

在这个比喻中：
- **Handler** = 处理者接口（判断能否处理）
- **ConcreteHandler** = 具体处理者（一线客服、技术、主管等）
- **Client** = 问题提交者（用户）
- **Request** = 工单/问题

### 三、应用场景

| 场景 | 说明 | 示例 |
|------|------|------|
| **多对象处理** | 多个对象可以处理同一请求 | 审批流程、日志级别 |
| **动态处理链** | 处理者和顺序可动态指定 | 异常捕获、中间件 |
| **不确定处理者** | 不知道哪个对象能处理 | 插件系统、事件处理 |
| **解耦请求处理**：发送者无需知道具体处理者 | 工作流引擎、规则引擎 |

### 四、使用注意事项

#### 优点

| 优点 | 说明 |
|------|------|
| **降低耦合度** | 发送者无需知道具体处理者 |
| **灵活增强** | 可动态添加/删除处理者 |
| **职责单一** | 每个处理者专注自己的职责 |
| **简化连接** | 对象只需知道后继者 |

#### 缺点

| 缺点 | 说明 |
|------|------|
| **处理延迟** | 请求可能在链中传递很久 |
| **循环风险** | 链条配置错误可能导致循环 |
| **调试困难**：处理路径不直观 |
| **性能损耗** | 每个请求都要遍历链条 |

#### 使用建议

- 有多个对象可以处理请求时使用
- 不知道具体哪个对象处理时使用
- 处理顺序需要灵活配置时使用

### 五、Java 经典案例

#### 实现 1：请假审批流程

```java
/**
 * 抽象处理者
 */
abstract class LeaveApprover {
    protected LeaveApprover nextApprover;
    protected String name;

    public LeaveApprover(String name) {
        this.name = name;
    }

    public void setNextApprover(LeaveApprover nextApprover) {
        this.nextApprover = nextApprover;
    }

    public abstract boolean processRequest(LeaveRequest request);
}

/**
 * 请假请求
 */
class LeaveRequest {
    private String employeeName;
    private int leaveDays;
    private String reason;

    public LeaveRequest(String employeeName, int leaveDays, String reason) {
        this.employeeName = employeeName;
        this.leaveDays = leaveDays;
        this.reason = reason;
    }

    public String getEmployeeName() {
        return employeeName;
    }

    public int getLeaveDays() {
        return leaveDays;
    }

    public String getReason() {
        return reason;
    }
}

/**
 * 具体处理者：组长
 */
class TeamLeader extends LeaveApprover {
    public TeamLeader(String name) {
        super(name);
    }

    @Override
    public boolean processRequest(LeaveRequest request) {
        if (request.getLeaveDays() <= 1) {
            System.out.println(
                "组长 " + name + " 批准了 " + request.getEmployeeName() +
                " 的请假申请，天数: " + request.getLeaveDays()
            );
            return true;
        } else {
            System.out.println("组长无权批准，转交上级...");
            if (nextApprover != null) {
                return nextApprover.processRequest(request);
            }
            return false;
        }
    }
}

/**
 * 具体处理者：经理
 */
class Manager extends LeaveApprover {
    public Manager(String name) {
        super(name);
    }

    @Override
    public boolean processRequest(LeaveRequest request) {
        if (request.getLeaveDays() <= 3) {
            System.out.println(
                "经理 " + name + " 批准了 " + request.getEmployeeName() +
                " 的请假申请，天数: " + request.getLeaveDays()
            );
            return true;
        } else {
            System.out.println("经理无权批准，转交上级...");
            if (nextApprover != null) {
                return nextApprover.processRequest(request);
            }
            return false;
        }
    }
}

/**
 * 具体处理者：总监
 */
class Director extends LeaveApprover {
    public Director(String name) {
        super(name);
    }

    @Override
    public boolean processRequest(LeaveRequest request) {
        if (request.getLeaveDays() <= 7) {
            System.out.println(
                "总监 " + name + " 批准了 " + request.getEmployeeName() +
                " 的请假申请，天数: " + request.getLeaveDays()
            );
            return true;
        } else {
            System.out.println("请假天数过多，拒绝申请");
            return false;
        }
    }
}

// 使用
public class ChainOfResponsibilityDemo {
    public static void main(String[] args) {
        // 构建责任链
        LeaveApprover teamLeader = new TeamLeader("张组长");
        LeaveApprover manager = new Manager("李经理");
        LeaveApprover director = new Director("王总监");

        teamLeader.setNextApprover(manager);
        manager.setNextApprover(director);

        // 测试不同天数的请假
        System.out.println("=== 测试1天请假 ===");
        LeaveRequest request1 = new LeaveRequest("小赵", 1, "休息");
        teamLeader.processRequest(request1);

        System.out.println("\n=== 测试3天请假 ===");
        LeaveRequest request2 = new LeaveRequest("小钱", 3, "旅游");
        teamLeader.processRequest(request2);

        System.out.println("\n=== 测试7天请假 ===");
        LeaveRequest request3 = new LeaveRequest("小孙", 7, "回家");
        teamLeader.processRequest(request3);

        System.out.println("\n=== 测试10天请假 ===");
        LeaveRequest request4 = new LeaveRequest("小李", 10, "出国");
        teamLeader.processRequest(request4);
    }
}
```

#### 实现 2：日志记录系统

```java
/**
 * 日志级别枚举
 */
enum LogLevel {
    DEBUG, INFO, WARNING, ERROR
}

/**
 * 抽象日志记录器
 */
abstract class Logger {
    protected LogLevel level;
    protected Logger nextLogger;

    public Logger(LogLevel level) {
        this.level = level;
    }

    public void setNextLogger(Logger nextLogger) {
        this.nextLogger = nextLogger;
    }

    public void log(LogLevel level, String message) {
        if (this.level.ordinal() <= level.ordinal()) {
            write(message);
        }
        if (nextLogger != null) {
            nextLogger.log(level, message);
        }
    }

    protected abstract void write(String message);
}

/**
 * 具体日志记录器：控制台
 */
class ConsoleLogger extends Logger {
    public ConsoleLogger(LogLevel level) {
        super(level);
    }

    @Override
    protected void write(String message) {
        System.out.println("Console::Logger: " + message);
    }
}

/**
 * 具体日志记录器：文件
 */
class FileLogger extends Logger {
    public FileLogger(LogLevel level) {
        super(level);
    }

    @Override
    protected void write(String message) {
        System.out.println("File::Logger: " + message);
    }
}

/**
 * 具体日志记录器：远程服务器
 */
class RemoteLogger extends Logger {
    public RemoteLogger(LogLevel level) {
        super(level);
    }

    @Override
    protected void write(String message) {
        System.out.println("Remote::Logger: " + message);
    }
}

// 使用
public class LoggerChainDemo {
    private static Logger getChainOfLoggers() {
        Logger consoleLogger = new ConsoleLogger(LogLevel.DEBUG);
        Logger fileLogger = new FileLogger(LogLevel.INFO);
        Logger remoteLogger = new RemoteLogger(LogLevel.ERROR);

        consoleLogger.setNextLogger(fileLogger);
        fileLogger.setNextLogger(remoteLogger);

        return consoleLogger;
    }

    public static void main(String[] args) {
        Logger loggerChain = getChainOfLoggers();

        System.out.println("=== DEBUG级别 ===");
        loggerChain.log(LogLevel.DEBUG, "调试信息");

        System.out.println("\n=== INFO级别 ===");
        loggerChain.log(LogLevel.INFO, "普通信息");

        System.out.println("\n=== WARNING级别 ===");
        loggerChain.log(LogLevel.WARNING, "警告信息");

        System.out.println("\n=== ERROR级别 ===");
        loggerChain.log(LogLevel.ERROR, "错误信息");
    }
}
```

### 六、Python 经典案例

#### 实现 1：中间件处理链

```python
from abc import ABC, abstractmethod
from typing import Callable, Optional


class Handler(ABC):
    """抽象处理者"""

    def __init__(self):
        self._next_handler: Optional[Handler] = None

    def set_next(self, handler: 'Handler') -> 'Handler':
        """设置下一个处理者"""
        self._next_handler = handler
        return handler

    @abstractmethod
    def handle(self, request: dict) -> Optional[dict]:
        """处理请求"""
        if self._next_handler:
            return self._next_handler.handle(request)
        return None


class AuthenticationHandler(Handler):
    """身份验证处理者"""

    def handle(self, request: dict) -> Optional[dict]:
        token = request.get('token')

        if not token:
            print("AuthenticationHandler: 缺少token，拒绝访问")
            return None

        if token != "valid_token_123":
            print("AuthenticationHandler: token无效，拒绝访问")
            return None

        print("AuthenticationHandler: 身份验证通过")
        return super().handle(request)


class RateLimitHandler(Handler):
    """限流处理者"""

    def __init__(self):
        super().__init__()
        self.request_count = {}
        self.max_requests = 5

    def handle(self, request: dict) -> Optional[dict]:
        user_id = request.get('user_id', 'unknown')

        if user_id not in self.request_count:
            self.request_count[user_id] = 0

        self.request_count[user_id] += 1

        if self.request_count[user_id] > self.max_requests:
            print(f"RateLimitHandler: 用户 {user_id} 请求超限，拒绝访问")
            return None

        print(f"RateLimitHandler: 限流检查通过（当前: {self.request_count[user_id]}/{self.max_requests}）")
        return super().handle(request)


class ValidationHandler(Handler):
    """参数验证处理者"""

    def handle(self, request: dict) -> Optional[dict]:
        action = request.get('action')

        if not action:
            print("ValidationHandler: 缺少action参数")
            return None

        if action not in ['create', 'update', 'delete']:
            print(f"ValidationHandler: 无效的action: {action}")
            return None

        print(f"ValidationHandler: 参数验证通过")
        return super().handle(request)


class BusinessLogicHandler(Handler):
    """业务逻辑处理者"""

    def handle(self, request: dict) -> Optional[dict]:
        action = request.get('action')
        print(f"BusinessLogicHandler: 执行业务逻辑 - {action}")

        result = {
            'status': 'success',
            'action': action,
            'message': f'{action} 操作成功'
        }

        return result


# 使用
def main():
    # 构建责任链
    auth = AuthenticationHandler()
    rate_limit = RateLimitHandler()
    validation = ValidationHandler()
    business = BusinessLogicHandler()

    auth.set_next(rate_limit).set_next(validation).set_next(business)

    # 测试不同请求
    print("=== 测试1: 有效请求 ===")
    request1 = {
        'token': 'valid_token_123',
        'user_id': 'user_001',
        'action': 'create'
    }
    result1 = auth.handle(request1)
    print(f"结果: {result1}\n")

    print("=== 测试2: 无效token ===")
    request2 = {
        'token': 'invalid_token',
        'user_id': 'user_001',
        'action': 'create'
    }
    result2 = auth.handle(request2)
    print(f"结果: {result2}\n")

    print("=== 测试3: 限流 ===")
    for i in range(7):
        print(f"\n第 {i+1} 次请求:")
        request3 = {
            'token': 'valid_token_123',
            'user_id': 'user_002',
            'action': 'update'
        }
        result3 = auth.handle(request3)
        if i == 6:
            print(f"最终结果: {result3}")


if __name__ == "__main__":
    main()
```

#### 实现 2：事件处理系统

```python
from abc import ABC, abstractmethod
from typing import Optional, List
from dataclasses import dataclass


@dataclass
class Event:
    """事件数据"""
    type: str
    data: dict
    handled: bool = False


class EventHandler(ABC):
    """事件处理者基类"""

    def __init__(self, name: str):
        self.name = name
        self._next_handler: Optional[EventHandler] = None

    def set_next(self, handler: 'EventHandler') -> 'EventHandler':
        """设置下一个处理者"""
        self._next_handler = handler
        return handler

    def handle(self, event: Event) -> Event:
        """处理事件"""
        # 尝试处理
        if self.can_handle(event):
            print(f"{self.name}: 正在处理事件 {event.type}")
            event = self.process(event)

        # 如果事件未被完全处理，传递给下一个
        if not event.handled and self._next_handler:
            return self._next_handler.handle(event)

        return event

    def can_handle(self, event: Event) -> bool:
        """判断是否能处理该事件"""
        return event.type in self.get_supported_types()

    @abstractmethod
    def get_supported_types(self) -> List[str]:
        """返回支持的事件类型"""
        pass

    @abstractmethod
    def process(self, event: Event) -> Event:
        """处理事件的具体逻辑"""
        pass


class MouseEventHandler(EventHandler):
    """鼠标事件处理者"""

    def get_supported_types(self) -> List[str]:
        return ['click', 'double_click', 'hover']

    def process(self, event: Event) -> Event:
        x = event.data.get('x', 0)
        y = event.data.get('y', 0)

        print(f"  处理鼠标事件: 坐标({x}, {y})")

        if event.type == 'click':
            print(f"  触发点击处理逻辑")
            event.handled = True
        elif event.type == 'double_click':
            print(f"  触发双击处理逻辑")
            event.handled = True

        return event


class KeyboardEventHandler(EventHandler):
    """键盘事件处理者"""

    def get_supported_types(self) -> List[str]:
        return ['key_press', 'key_release']

    def process(self, event: Event) -> Event:
        key = event.data.get('key', '')

        print(f"  处理键盘事件: 按键 {key}")

        if key == 'Escape':
            print(f"  ESC键按下，关闭窗口")
            event.handled = True

        return event


class LogEventHandler(EventHandler):
    """日志记录处理者"""

    def get_supported_types(self) -> List[str]:
        return ['*']  # 支持所有事件

    def process(self, event: Event) -> Event:
        # 记录所有事件日志
        print(f"  [日志] 记录事件: {event.type}, 数据: {event.data}")
        return event


class UIEventHandler(EventHandler):
    """UI事件处理者"""

    def get_supported_types(self) -> List[str]:
        return ['click', 'resize', 'close']

    def process(self, event: Event) -> Event:
        print(f"  UI响应: {event.type}")

        if event.type == 'close':
            print(f"  关闭窗口")
            event.handled = True

        return event


# 使用
def main():
    # 构建责任链
    mouse_handler = MouseEventHandler("MouseHandler")
    keyboard_handler = KeyboardEventHandler("KeyboardHandler")
    log_handler = LogEventHandler("LogHandler")
    ui_handler = UIEventHandler("UIHandler")

    # 链条: 鼠标 -> 键盘 -> UI -> 日志
    mouse_handler.set_next(keyboard_handler).set_next(ui_handler).set_next(log_handler)

    print("=== 测试1: 点击事件 ===")
    event1 = Event(type='click', data={'x': 100, 'y': 200})
    mouse_handler.handle(event1)
    print()

    print("=== 测试2: 键盘事件 ===")
    event2 = Event(type='key_press', data={'key': 'Escape'})
    mouse_handler.handle(event2)
    print()

    print("=== 测试3: 未知事件 ===")
    event3 = Event(type='custom', data={'value': 123})
    mouse_handler.handle(event3)


if __name__ == "__main__":
    main()
```

### 七、参考资料与延伸阅读

#### 经典书籍
- 《设计模式：可复用面向对象软件的基础》- GoF
- 《Head First 设计模式》- 责任链模式章节

#### 在线资源
- [Refactoring.Guru - Chain of Responsibility](https://refactoring.guru/design-patterns/chain-of-responsibility)
- [Java设计模式：责任链模式](https://java-design-patterns.com/patterns/chain-of-responsibility/)

#### 相关设计模式
- **Composite（组合）**：常与组合模式配合使用
- **Decorator（装饰）**：类似的对象链结构
- **Observer（观察者）**：都是处理请求的方式

#### 最佳实践建议
1. 保持处理者简单专注
2. 避免链条过长影响性能
3. 提供默认处理行为
4. 考虑设置处理超时
