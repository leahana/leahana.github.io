---
layout: post
title: 自定义 RedisTemplate 使用 StringRedisSerializer 避免双重引号问题
date: 2026-03-16 12:00:00 +0800
categories: [tech, backend]
tags: [Redis, RedisTemplate, 序列化, StringRedisSerializer, Spring Boot, 踩坑记录]
description: 通过自定义 RedisTemplate 统一使用 StringRedisSerializer，避免 ObjectMapper 二次序列化导致的双重双引号包裹问题
toc: true
---

> 🎯 **一句话定位**：解决 Redis 存储值被 `""""` 双重双引号包裹的序列化陷阱。
>
> 💡 **核心理念**：让 RedisTemplate 只做纯字符串存取，序列化的活交给业务层自己控制。

---

## 问题背景

### 业务场景

在 Spring Boot 项目中使用 Redis 缓存数据，业务代码先用 `ObjectMapper` 将对象序列化为 JSON 字符串，再通过 `RedisTemplate` 写入 Redis。从 Redis 读取后，再用 `ObjectMapper` 反序列化回对象。

一个典型的操作流程：

```java
// 写入
String json = objectMapper.writeValueAsString(user);
redisTemplate.opsForValue().set("user:1001", json);

// 读取
String cached = (String) redisTemplate.opsForValue().get("user:1001");
User user = objectMapper.readValue(cached, User.class);
```

### 痛点分析

- **痛点 1**：使用默认的 `Jackson2JsonRedisSerializer` 或 `GenericJackson2JsonRedisSerializer` 作为 value 序列化器时，写入的 JSON 字符串会被**再次序列化**，导致值被双重引号包裹，如 `"\"{"name":"张三"}\"`
- **痛点 2**：Redis 中存储的 key 带有 `\xac\xed\x00\x05t\x00` 等乱码前缀（JDK 默认序列化器），用 `redis-cli` 无法直接查看
- **痛点 3**：Hash 结构的 hashKey 同样被污染，排查问题时在 Redis 客户端看到的数据完全不可读

### 目标

让 Redis 中存储的 key 和 value 都是**干净的纯字符串**，用 `redis-cli` 或可视化工具能直接看到可读内容。

---

## 方案对比

### 方案调研

| 方案 | 核心思路 | 优点 | 缺点 | 适用场景 |
|------|---------|------|------|---------|
| 方案 A：默认 RedisTemplate | 不做任何配置，使用 JDK 序列化 | 零配置 | key/value 都是乱码，不可读 | 不推荐 |
| 方案 B：Jackson2JsonRedisSerializer | 用 Jackson 序列化器处理 value | 自动序列化对象 | 业务层已序列化的字符串会被二次序列化 | 直接存对象，不手动序列化 |
| 方案 C：全部使用 StringRedisSerializer | key/value/hashKey/hashValue 统一用字符串序列化器 | 存取透明，所见即所得 | 需要业务层自行处理对象序列化 | 业务层已有 ObjectMapper 序列化逻辑 |

### 选择理由

选择**方案 C**。大多数项目中，业务层已经在用 `ObjectMapper` 做序列化/反序列化，RedisTemplate 只需要做**纯粹的字符串存取**。让序列化职责明确归属业务层，避免框架层的隐式二次序列化。

---

## 核心实现

### 问题根因

```mermaid
graph TD
    A["业务代码调用 ObjectMapper"] -->|"序列化为 JSON 字符串"| B["得到: {\"name\":\"张三\"}"]
    B -->|"写入 RedisTemplate"| C{"Value 序列化器类型?"}
    C -->|"Jackson2Json"| D["再次序列化: \"{\\"name\\":\\"张三\\"}\""]
    C -->|"StringRedis"| E["原样写入: {\"name\":\"张三\"}"]

    style D fill:#ffccbc,stroke:#333,color:#000
    style E fill:#c8e6c9,stroke:#333,color:#000
```

关键在于：`Jackson2JsonRedisSerializer` 会把传入的字符串**当作一个 Java 对象再序列化一次**，给外层加上引号和转义，导致 Redis 中存储的值变成 `"\"...\""` 这种双重引号结构。

### 完整代码

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, String> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, String> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);

        // 统一使用 StringRedisSerializer
        StringRedisSerializer serializer = new StringRedisSerializer();

        // key 和 value 使用字符串序列化
        template.setKeySerializer(serializer);
        template.setValueSerializer(serializer);

        // hash 的 key 和 value 也使用字符串序列化
        template.setHashKeySerializer(serializer);
        template.setHashValueSerializer(serializer);

        template.afterPropertiesSet();
        return template;
    }
}
```

### 关键点说明

- **泛型声明为 `<String, String>`**：明确告诉调用方，这个 RedisTemplate 只接受字符串类型的 key 和 value，编译期就能发现类型错误
- **四个序列化器全部设置**：`keySerializer`、`valueSerializer`、`hashKeySerializer`、`hashValueSerializer` 缺一不可，否则遗漏的部分仍会使用 JDK 默认序列化器
- **调用 `afterPropertiesSet()`**：触发 RedisTemplate 的初始化逻辑，确保所有配置生效

---

## 生产实践

### 使用示例

配置完成后，业务代码中序列化和反序列化完全由自己控制：

```java
@Service
public class UserCacheService {

    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper;

    public UserCacheService(RedisTemplate<String, String> redisTemplate,
                            ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
    }

    public void cacheUser(String userId, User user) throws JsonProcessingException {
        String key = "user:" + userId;
        String json = objectMapper.writeValueAsString(user);
        // 写入 Redis 的就是纯 JSON 字符串，不会被二次序列化
        redisTemplate.opsForValue().set(key, json, Duration.ofHours(1));
    }

    public User getUser(String userId) throws JsonProcessingException {
        String key = "user:" + userId;
        String json = redisTemplate.opsForValue().get(key);
        if (json == null) {
            return null;
        }
        // 读取的就是纯 JSON 字符串，直接反序列化
        return objectMapper.readValue(json, User.class);
    }
}
```

### 常见坑点

1. **StringRedisTemplate 与自定义 RedisTemplate 的关系**
   - **现象**：项目中同时存在 `StringRedisTemplate` 和自定义的 `RedisTemplate<String, String>`，注入时不确定用哪个
   - **原因**：Spring Boot 自动配置会注册一个 `StringRedisTemplate` Bean，它本身就是用 `StringRedisSerializer` 的
   - **解决**：如果只需要纯字符串操作，直接注入 `StringRedisTemplate` 即可，无需自定义。自定义 `RedisTemplate` 适合需要额外定制（如自定义连接池、超时配置）的场景

2. **存入非字符串类型报错**
   - **现象**：`redisTemplate.opsForValue().set("key", someObject)` 编译报错或运行时抛 `ClassCastException`
   - **原因**：泛型声明为 `<String, String>`，value 只接受 `String` 类型
   - **解决**：先用 `objectMapper.writeValueAsString()` 转为字符串再存入，这正是我们想要的——显式控制序列化

3. **Hash 操作忘记设置 hashKey/hashValue 序列化器**
   - **现象**：`opsForHash()` 操作的 field 出现乱码前缀
   - **原因**：只设置了 `keySerializer` 和 `valueSerializer`，没有设置 `hashKeySerializer` 和 `hashValueSerializer`
   - **解决**：四个序列化器必须全部显式设置，参见上方完整代码

### 效果对比

在 `redis-cli` 中查看存储效果：

```bash
# 使用默认 JDK 序列化器（不可读）
127.0.0.1:6379> GET "\xac\xed\x00\x05t\x00\x09user:1001"
"\xac\xed\x00\x05t\x00\x1b{\"name\":\"\xe5\xbc\xa0\xe4\xb8\x89\"}"

# 使用 Jackson2JsonRedisSerializer（双重引号）
127.0.0.1:6379> GET "user:1001"
"\"\\\"{\\'name\\':\\'\\\\\\\"张三\\\\\\\"'}\\\"\""

# 使用 StringRedisSerializer（干净可读）
127.0.0.1:6379> GET "user:1001"
"{\"name\":\"张三\",\"age\":25}"
```

### 最佳实践

- 如果项目中只需要字符串级别的 Redis 操作，**直接用 `StringRedisTemplate`** 是最简单的方案，Spring Boot 已经自动配置好了
- 如果需要自定义配置（连接池、超时等），再手动声明 `RedisTemplate<String, String>` 并设置四个序列化器
- 团队约定：所有 Redis 读写**统一走封装好的 Service 层**，禁止在 Controller 或其他地方直接操作 RedisTemplate，方便统一管理序列化逻辑

---

## 总结

### 核心要点

1. `Jackson2JsonRedisSerializer` 会把已经是 JSON 字符串的 value 再序列化一次，产生 `""""` 双重引号
2. 统一使用 `StringRedisSerializer` 设置 key/value/hashKey/hashValue 四个序列化器，让 Redis 存取透明化
3. 序列化职责归业务层（`ObjectMapper`），RedisTemplate 只做字符串搬运工

### 适用场景

- 业务层已经在用 `ObjectMapper` 做 JSON 序列化/反序列化
- 需要在 Redis 客户端中直接查看可读数据
- Hash 结构的 field 和 value 也需要可读

### 注意事项

- 如果项目中希望 RedisTemplate **自动处理对象序列化**（不手动调用 ObjectMapper），那应该用 `Jackson2JsonRedisSerializer` 并且**不要在业务层提前序列化**——二者只能选其一，不能叠加使用
- `StringRedisTemplate` 是 Spring Boot 开箱即用的方案，大部分场景下无需自定义 `RedisTemplate`

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-03-16 | 初始版本 |
