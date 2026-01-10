---
title: Spring AOP 注解使用案例与场景设计
date: 2026-01-09
tags:
  - Spring
  - AOP
  - Java
  - 后端开发
categories: [tech, backend]
---

## Spring AOP 注解使用案例与场景设计

## 目录

1. [五大核心注解对比](#一五大核心注解对比)
2. [注解使用案例](#二注解使用案例)
3. [实际场景设计](#三实际场景设计)
4. [切点表达式汇总](#四切点表达式汇总)
5. [最佳实践建议](#五最佳实践建议)

## 一、五大核心注解对比

| 注解 | 执行时机 | 使用场景 |
|------|---------|---------|
| @Before | 方法执行前 | 参数校验、权限检查、日志记录 |
| @AfterReturning | 方法正常返回后 | 处理返回值、缓存更新 |
| @AfterThrowing | 方法抛出异常后 | 异常日志、告警通知 |
| @After | 方法结束后（finally） | 资源释放、清理工作 |
| @Around | 环绕方法 | 性能监控、事务控制、缓存 |

## 二、注解使用案例

### 2.1 @Before - 参数校验

```java
@Aspect
@Component
public class ValidateAspect {

    @Before("@annotation(com.example.Validate)")
    public void validateParams(JoinPoint joinPoint) {
        Object[] args = joinPoint.getArgs();

        for (Object arg : args) {
            if (arg instanceof UserDTO) {
                UserDTO user = (UserDTO) arg;
                if (StringUtils.isBlank(user.getUsername())) {
                    throw new IllegalArgumentException("用户名不能为空");
                }
            }
        }
    }
}

// 使用
@Validate
public void createUser(UserDTO user) { ... }
```

**常用场景**：接口入参校验、权限验证、限流检查

---

### 2.2 @AfterReturning - 缓存更新

```java
@Aspect
@Component
public class CacheAspect {

    @Autowired
    private RedisTemplate redisTemplate;

    @AfterReturning(
        pointcut = "@annotation(com.example.CacheUpdate)",
        returning = "result"
    )
    public void updateCache(JoinPoint joinPoint, Object result) {
        String key = joinPoint.getSignature().getName();
        redisTemplate.opsForValue().set(key, result, 1, TimeUnit.HOURS);

        System.out.println("缓存已更新: " + key);
    }
}

// 使用
@CacheUpdate
public UserInfo getUserById(Long id) { ... }
```

**常用场景**：数据库更新后刷新缓存、发送通知消息

---

### 2.3 @AfterThrowing - 异常告警

```java
@Aspect
@Component
public class ExceptionAspect {

    @AfterThrowing(
        pointcut = "execution(* com.example.service.*.*(..))",
        throwing = "ex"
    )
    public void handleException(JoinPoint joinPoint, Exception ex) {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();

        // 记录异常日志
        log.error("方法 {} 执行异常，参数: {}", methodName, args, ex);

        // 发送告警通知
        alertService.sendAlert(methodName, ex.getMessage());

        // 保存异常信息到数据库
        exceptionLogService.save(methodName, args, ex);
    }
}
```

**常用场景**：统一异常处理、告警通知、故障记录

---

### 2.4 @After - 资源清理

```java
@Aspect
@Component
public class ResourceAspect {

    private static final ThreadLocal<Connection> CONNECTION_HOLDER = new ThreadLocal<>();

    @Before("@annotation(com.example.RequiresConnection)")
    public void setConnection(JoinPoint joinPoint) {
        CONNECTION_HOLDER.set(dataSource.getConnection());
    }

    @After("@annotation(com.example.RequiresConnection)")
    public void closeConnection(JoinPoint joinPoint) {
        Connection conn = CONNECTION_HOLDER.get();
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                log.error("关闭连接失败", e);
            } finally {
                CONNECTION_HOLDER.remove();
            }
        }
    }
}
```

**常用场景**：资源释放、清理临时文件、重置上下文

---

### 2.5 @Around - 性能监控（最常用）

```java
@Aspect
@Component
public class PerformanceAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object monitorPerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        String methodName = joinPoint.getSignature().toShortString();

        try {
            // 执行目标方法
            Object result = joinPoint.proceed();

            long duration = System.currentTimeMillis() - start;

            // 记录正常执行时间
            if (duration > 1000) {
                log.warn("慢方法: {}, 耗时: {}ms", methodName, duration);
            } else {
                log.info("方法: {}, 耗时: {}ms", methodName, duration);
            }

            return result;

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            log.error("方法执行异常: {}, 耗时: {}ms", methodName, duration, e);
            throw e;
        }
    }
}
```

**常用场景**：性能监控、事务控制、熔断降级

## 三、实际场景设计

### 3.1 场景1：操作日志记录（企业级）

```java
@Aspect
@Component
public class OperationLogAspect {

    @Autowired
    private OperationLogService operationLogService;

    @Around("@annotation(operationLog)")
    public Object recordLog(ProceedingJoinPoint joinPoint, OperationLog operationLog) throws Throwable {
        // 获取当前用户
        String currentUser = SecurityContextHolder.getCurrentUser();

        // 获取方法信息
        String module = operationLog.module();
        String action = operationLog.action();
        String description = operationLog.description();

        // 获取入参
        Object[] args = joinPoint.getArgs();

        long startTime = System.currentTimeMillis();

        try {
            Object result = joinPoint.proceed();

            // 记录成功日志
            operationLogService.saveLog(OperationLogEntity.builder()
                .module(module)
                .action(action)
                .description(description)
                .operator(currentUser)
                .requestParams(JSON.toJSONString(args))
                .response(JSON.toJSONString(result))
                .status("SUCCESS")
                .costTime(System.currentTimeMillis() - startTime)
                .build()
            );

            return result;

        } catch (Exception e) {
            // 记录失败日志
            operationLogService.saveLog(OperationLogEntity.builder()
                .module(module)
                .action(action)
                .operator(currentUser)
                .requestParams(JSON.toJSONString(args))
                .errorMsg(e.getMessage())
                .status("FAILED")
                .costTime(System.currentTimeMillis() - startTime)
                .build()
            );

            throw e;
        }
    }
}

// 使用
@PostMapping("/user")
@OperationLog(module = "用户管理", action = "创建用户", description = "管理员创建新用户")
public Result createUser(@RequestBody UserDTO user) {
    userService.createUser(user);
    return Result.success();
}
```

---

### 3.2 场景2：接口幂等性控制

```java
@Aspect
@Component
public class IdempotentAspect {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Around("@annotation(idempotent)")
    public Object checkIdempotent(ProceedingJoinPoint joinPoint, Idempotent idempotent) throws Throwable {
        String key = buildKey(joinPoint, idempotent);

        // 尝试设置锁
        Boolean success = redisTemplate.opsForValue()
            .setIfAbsent(key, "1", idempotent.timeout(), TimeUnit.SECONDS);

        if (Boolean.FALSE.equals(success)) {
            throw new IdempotentException("请勿重复提交");
        }

        try {
            return joinPoint.proceed();
        } catch (Exception e) {
            // 执行失败，删除锁允许重试
            redisTemplate.delete(key);
            throw e;
        }
    }

    private String buildKey(JoinPoint joinPoint, Idempotent idempotent) {
        String prefix = idempotent.prefix();
        Object[] args = joinPoint.getArgs();
        String argsStr = DigestUtils.md5Hex(JSON.toJSONString(args));
        return "idempotent:" + prefix + ":" + argsStr;
    }
}

// 使用
@PostMapping("/order")
@Idempotent(prefix = "createOrder", timeout = 10)
public Result createOrder(@RequestBody OrderDTO order) {
    orderService.createOrder(order);
    return Result.success();
}
```

---

### 3.3 场景3：接口限流

```java
@Aspect
@Component
public class RateLimitAspect {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Around("@annotation(rateLimit)")
    public Object limitRate(ProceedingJoinPoint joinPoint, RateLimit rateLimit) throws Throwable {
        String key = "rate_limit:" + getClientIP();

        // 计数器加1
        Long count = redisTemplate.opsForValue().increment(key);

        if (count == 1) {
            // 设置过期时间
            redisTemplate.expire(key, rateLimit.period(), TimeUnit.SECONDS);
        }

        if (count > rateLimit.count()) {
            throw new RateLimitException("访问过于频繁，请稍后再试");
        }

        return joinPoint.proceed();
    }
}

// 使用
@GetMapping("/api/data")
@RateLimit(count = 10, period = 60)  // 60秒内最多10次
public Result getData() {
    return Result.success(dataService.getData());
}
```

---

### 3.4 场景4：重试机制

```java
@Aspect
@Component
public class RetryAspect {

    @Around("@annotation(retry)")
    public Object retry(ProceedingJoinPoint joinPoint, Retry retry) throws Throwable {
        int maxAttempts = retry.maxAttempts();
        long delay = retry.delay();

        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
            try {
                return joinPoint.proceed();
            } catch (Exception e) {
                if (attempt == maxAttempts) {
                    throw e;
                }

                log.warn("第{}次重试: {}", attempt, e.getMessage());
                Thread.sleep(delay);
            }
        }

        throw new RuntimeException("重试失败");
    }
}

// 使用
@Retry(maxAttempts = 3, delay = 1000)
public void callExternalAPI() {
    httpClient.call();
}
```

## 四、切点表达式汇总

```java
// 1. 精确匹配
@Pointcut("execution(* com.example.UserService.getUserById(..))")

// 2. 匹配包下所有方法
@Pointcut("execution(* com.example.service.*.*(..))")

// 3. 匹配注解
@Pointcut("@annotation(com.example.Log)")

// 4. 匹配自定义注解参数
@Pointcut("@annotation(cacheable) && args(id)")

// 5. 组合切点
@Pointcut("execution(* com.example.service.*.*(..)) || @annotation(com.example.Log)")

// 6. 匹配特定返回类型
@Pointcut("execution(java.util.List com.example.*.*(..))")
```

**切点表达式说明**

| 表达式 | 说明 |
|--------|------|
| `execution(* com.example.service.*.*(..))` | 匹配 service 包下所有类的所有方法 |
| `execution(public * com.example..*.*(..))` | 匹配 public 方法 |
| `@annotation(com.example.Log)` | 匹配带 @Log 注解的方法 |
| `@within(org.springframework.stereotype.Service)` | 匹配 Service 类下的所有方法 |
| `this(com.example.Service)` | 匹配实现了 Service 接口的代理对象 |
| `target(com.example.Service)` | 匹配实现了 Service 接口的目标对象 |

## 五、最佳实践建议

### 5.1 注解选择建议

| 建议 | 说明 |
|------|------|
| 优先使用 @Around | 功能最强大，可以控制入参、返回值、异常 |
| 避免 @Around 包裹业务逻辑 | 用于横切关注点，不要改变业务流程 |
| ThreadLocal 必须清理 | 防止内存泄漏 |
| 异常处理要谨慎 | 不要吞掉异常，做好日志记录 |
| 性能敏感代码慎用 AOP | AOP 有性能开销，高频方法注意测试 |
| 组合使用注解 | @Before + @AfterReturning 比 @Around 更清晰 |

### 5.2 性能优化

```java
// 优化前：每个方法都拦截
@Around("execution(* com.example..*.*(..))")
public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    // ...
}

// 优化后：只拦截必要的方法
@Around("@annotation(com.example.Monitor)")
public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    // ...
}
```

### 5.3 常见问题处理

**问题1：@Around 不执行**

```java
// 错误：private 方法不会被代理
@Around("execution(* com.example.service.*.*(..))")
private Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    // ...
}

// 正确：使用 public
@Around("execution(* com.example.service.*.*(..))")
public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
    // ...
}
```

**问题2：同类方法调用不生效**

```java
@Service
public class UserService {

    // 错误：内部调用不会触发 AOP
    public void method1() {
        this.method2();  // 不会触发 AOP
    }

    @Log
    public void method2() {
        // ...
    }

    // 正确：注入自己或使用 AopContext
    @Autowired
    private UserService self;

    public void method1() {
        self.method2();  // 会触发 AOP
    }
}
```

### 5.4 实践检查清单

> **使用 AOP 前检查**
>
> - [ ] 是否需要修改方法参数？（是 → 使用 @Around）
> - [ ] 是否需要修改返回值？（是 → 使用 @Around 或 @AfterReturning）
> - [ ] 是否需要捕获异常？（是 → 使用 @Around 或 @AfterThrowing）
> - [ ] 是否只是记录日志？（是 → 使用 @Before 或 @After）
> - [ ] ThreadLocal 是否正确清理？
> - [ ] 是否考虑了性能影响？

### 5.5 推荐组合方案

| 场景 | 推荐方案 | 理由 |
|------|---------|------|
| 参数校验 | @Before | 简单直接，不修改业务逻辑 |
| 缓存更新 | @AfterReturning | 只在成功时更新缓存 |
| 性能监控 | @Around | 可以统计完整耗时 |
| 异常处理 | @AfterThrowing | 专注异常场景 |
| 完整日志 | @Around | 可以记录入参和返回值 |
| 幂等控制 | @Around | 需要控制是否执行 |

## 延伸阅读

1. ^^[Spring官方文档 - AOP概念](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#aop)^^
2. ^^[Spring AOP API文档](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/aop/package-summary.html)^^
3. ^^[AspectJ编程指南](https://www.eclipse.org/aspectj/doc/released/progguide/index.html)^^
4. ^^[Spring AOP与AspectJ区别](https://spring.io/blog/2012/05/23/what-is-aspect-oriented-programming)^^
