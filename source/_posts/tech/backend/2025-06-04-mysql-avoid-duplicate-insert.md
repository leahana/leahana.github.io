---
title: 避免MySQL重复插入的几种方式
date: 2025-06-05 10:05:39
tags: [MySQL, 数据库, 性能优化]
categories: [tech, backend]
---

## 避免MySQL重复插入的几种方式

[[返回技术博客]](/)

## 目录

1. [应用场景](#一应用场景)
2. [核心知识点](#二核心知识点)
3. [代码实现](#三代码实现)
4. [注意事项](#四注意事项)
5. [拓展应用](#五拓展应用)
6. [延伸阅读](#六延伸阅读)

## 一、应用场景

### 1.1 数据去重场景

在实际业务开发中，经常会遇到需要避免重复插入数据的场景，比如：

- **用户注册**：防止同一用户重复注册
- **订单处理**：防止重复订单生成
- **日志记录**：避免重复记录相同操作日志
- **批量导入**：数据导入时避免重复数据

### 1.2 幂等性保证

在分布式系统和接口设计中，保证操作的幂等性是非常重要的。避免重复插入是实现幂等性的关键手段之一。

### 1.3 数据一致性维护

通过合理的重复插入处理机制，可以确保数据库中的数据唯一性和一致性，避免脏数据产生。

## 二、核心知识点

### 2.1 关键技术原理

- **唯一索引/主键约束**：数据库层面的唯一性保证机制
- **INSERT IGNORE**：忽略重复键错误，静默处理
- **REPLACE INTO**：删除旧记录后插入新记录
- **ON DUPLICATE KEY UPDATE**：遇到重复键时执行更新操作
- **先查询后插入**：应用层判断，性能较差但灵活

### 2.2 技术选型对比

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|----------|
| INSERT IGNORE | 语法简单，性能好 | 无法获取是否插入成功 | 只需插入，不关心是否已存在 |
| REPLACE INTO | 自动替换，操作简单 | 会删除旧记录，可能丢失数据 | 需要替换旧数据的场景 |
| ON DUPLICATE KEY UPDATE | 灵活，可自定义更新逻辑 | 语法稍复杂 | 需要更新部分字段的场景 |
| 先查询后插入 | 逻辑清晰，可控性强 | 性能差，存在并发问题 | 需要复杂判断逻辑的场景 |

> **技术隐喻**：INSERT IGNORE 像"静音模式"，遇到重复就跳过；REPLACE INTO 像"强制覆盖"，直接替换；ON DUPLICATE KEY UPDATE 像"智能更新"，遇到重复就更新；先查询后插入像"人工审核"，先检查再决定。

## 三、代码实现

### 3.1 INSERT IGNORE

#### 3.1.1 基础用法

```sql
-- 单条插入
INSERT IGNORE INTO users (id, username, email) 
VALUES (1, 'john', 'john@example.com');

-- 批量插入
INSERT IGNORE INTO users (id, username, email) 
VALUES 
    (1, 'john', 'john@example.com'),
    (2, 'jane', 'jane@example.com'),
    (3, 'bob', 'bob@example.com');
```

#### 3.1.2 实现原理

当使用 `INSERT IGNORE` 时，如果插入的数据违反了唯一索引或主键约束，MySQL会忽略这个错误，不会抛出异常，也不会插入数据。

**技术说明**：
- 需要表中有唯一索引或主键约束
- 返回的 `affected_rows` 为实际插入的行数
- 不会触发 `ON DUPLICATE KEY UPDATE`

### 3.2 REPLACE INTO

#### 3.2.1 基础用法

```sql
-- 单条替换
REPLACE INTO users (id, username, email) 
VALUES (1, 'john', 'john@example.com');

-- 批量替换
REPLACE INTO users (id, username, email) 
VALUES 
    (1, 'john', 'john@example.com'),
    (2, 'jane', 'jane@example.com');
```

#### 3.2.2 实现原理

`REPLACE INTO` 的执行逻辑是：
1. 如果记录不存在，直接插入
2. 如果记录存在（根据主键或唯一索引判断），先删除旧记录，再插入新记录

**技术说明**：
- ⚠️ **注意**：会触发 `DELETE` 和 `INSERT` 操作，可能影响自增ID
- ⚠️ **注意**：如果有外键约束，可能因为删除操作而失败
- 返回的 `affected_rows` 为 2（删除1条 + 插入1条）

### 3.3 ON DUPLICATE KEY UPDATE

#### 3.3.1 基础用法

```sql
-- 单条插入或更新
INSERT INTO users (id, username, email, update_time) 
VALUES (1, 'john', 'john@example.com', NOW())
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email),
    update_time = NOW();

-- 批量插入或更新
INSERT INTO users (id, username, email, update_time) 
VALUES 
    (1, 'john', 'john@example.com', NOW()),
    (2, 'jane', 'jane@example.com', NOW())
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email),
    update_time = NOW();
```

#### 3.3.2 高级用法

```sql
-- 使用字段引用（MySQL 8.0.19+）
INSERT INTO users (id, username, email, update_time) 
VALUES (1, 'john', 'john@example.com', NOW())
ON DUPLICATE KEY UPDATE 
    username = VALUES(username),
    email = VALUES(email),
    update_time = NOW(),
    version = version + 1;  -- 版本号自增

-- 条件更新
INSERT INTO users (id, username, email, update_time) 
VALUES (1, 'john', 'john@example.com', NOW())
ON DUPLICATE KEY UPDATE 
    username = IF(VALUES(username) != '', VALUES(username), username),
    email = VALUES(email),
    update_time = NOW();
```

#### 3.3.3 在MyBatis中的应用

```xml
<!-- MyBatis映射文件示例 -->
<insert id="insertOrUpdate">
    INSERT INTO users (id, username, email, update_time) 
    VALUES 
    <foreach collection="list" item="item" separator=",">
        (#{item.id}, #{item.username}, #{item.email}, NOW())
    </foreach>
    ON DUPLICATE KEY UPDATE 
        username = VALUES(username),
        email = VALUES(email),
        update_time = NOW()
</insert>
```

**技术说明**：
- 这是最灵活和常用的方案
- 可以自定义更新哪些字段
- 返回的 `affected_rows` 为 1（插入）或 2（更新）
- 不会删除旧记录，只是更新

### 3.4 先查询后插入

#### 3.4.1 基础实现

```java
// Java代码示例
public void insertIfNotExists(User user) {
    User existing = userMapper.selectById(user.getId());
    if (existing == null) {
        userMapper.insert(user);
    } else {
        // 已存在，可以选择更新或忽略
        log.info("用户已存在，ID: {}", user.getId());
    }
}
```

#### 3.4.2 使用SELECT ... FOR UPDATE防止并发

```sql
-- 使用事务和行锁
START TRANSACTION;
SELECT * FROM users WHERE id = 1 FOR UPDATE;
-- 如果不存在则插入
INSERT INTO users (id, username, email) VALUES (1, 'john', 'john@example.com');
COMMIT;
```

**技术说明**：
- ⚠️ **性能问题**：需要额外的查询操作，性能较差
- ⚠️ **并发问题**：在高并发场景下可能出现竞态条件
- ✅ **灵活性**：可以添加复杂的业务逻辑判断
- 建议使用 `SELECT ... FOR UPDATE` 或分布式锁来避免并发问题

### 3.5 唯一索引/主键约束

#### 3.5.1 创建唯一索引

```sql
-- 创建表时定义唯一索引
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    UNIQUE KEY uk_phone (phone)
);

-- 为已存在的表添加唯一索引
ALTER TABLE users ADD UNIQUE KEY uk_email (email);
```

#### 3.5.2 复合唯一索引

```sql
-- 创建复合唯一索引
CREATE TABLE user_roles (
    user_id INT,
    role_id INT,
    UNIQUE KEY uk_user_role (user_id, role_id)
);

-- 这样 user_id + role_id 的组合必须唯一
```

**技术说明**：
- 唯一索引是避免重复插入的基础
- 可以在数据库层面保证数据唯一性
- 建议在业务设计阶段就规划好唯一约束

## 四、注意事项

### 4.1 性能优化建议

❗️**批量操作优化**
> 对于批量插入场景，建议使用 `INSERT ... ON DUPLICATE KEY UPDATE` 或 `INSERT IGNORE`，避免循环单条插入

❗️**索引设计**
> 确保唯一索引字段的选择合理，避免过多唯一索引影响插入性能

❗️**事务控制**
> 批量操作时建议使用事务，保证数据一致性

### 4.2 常见陷阱

1. **REPLACE INTO 会删除旧记录**
   - 可能导致数据丢失
   - 会触发 DELETE 触发器
   - 自增ID会递增

2. **INSERT IGNORE 无法区分插入和忽略**
   - 需要通过 `affected_rows` 判断
   - 无法获取被忽略的数据信息

3. **ON DUPLICATE KEY UPDATE 的字段引用**
   - MySQL 8.0.19+ 可以使用 `VALUES()` 函数
   - 老版本需要使用字段名直接引用

4. **并发场景下的竞态条件**
   - 先查询后插入在高并发下可能失效
   - 建议使用数据库层面的约束或分布式锁

| 常见问题 | 排查建议 |
|----------|----------|
| 重复插入仍然发生 | 检查唯一索引是否正确创建 |
| 性能问题 | 检查是否使用了批量操作 |
| 数据丢失 | 检查是否误用了 REPLACE INTO |
| 并发问题 | 检查是否使用了合适的锁机制 |

> **检查清单**
>
> - [ ] 是否创建了合适的唯一索引
> - [ ] 是否选择了合适的插入策略
> - [ ] 是否考虑了并发场景
> - [ ] 是否处理了异常情况

## 五、拓展应用

### 5.1 分布式场景下的幂等性保证

在分布式系统中，除了数据库层面的约束，还可以结合以下方案：

```java
// 使用分布式锁保证幂等性
public void insertWithDistributedLock(User user) {
    String lockKey = "user:insert:" + user.getId();
    if (distributedLock.tryLock(lockKey, 5, TimeUnit.SECONDS)) {
        try {
            userMapper.insertOrUpdate(user);
        } finally {
            distributedLock.unlock(lockKey);
        }
    }
}
```

### 5.2 批量操作的优化策略

```java
// 批量插入或更新优化
public void batchInsertOrUpdate(List<User> users) {
    // 分批处理，避免单次SQL过大
    int batchSize = 1000;
    for (int i = 0; i < users.size(); i += batchSize) {
        int end = Math.min(i + batchSize, users.size());
        List<User> batch = users.subList(i, end);
        userMapper.batchInsertOrUpdate(batch);
    }
}
```

### 5.3 与消息队列结合

在消息队列场景中，可以通过唯一消息ID来避免重复消费：

```java
// 消息处理时的幂等性保证
@RabbitListener(queues = "user.queue")
public void handleUserMessage(UserMessage message) {
    // 使用消息ID作为唯一标识
    if (userMapper.existsByMessageId(message.getId())) {
        log.info("消息已处理，跳过: {}", message.getId());
        return;
    }
    userMapper.insertOrUpdate(message.getUser());
    userMapper.insertMessageLog(message.getId());
}
```

### 5.4 数据同步场景

在数据同步场景中，可以使用时间戳或版本号来判断是否需要更新：

```sql
-- 使用时间戳判断是否需要更新
INSERT INTO users (id, username, email, update_time) 
VALUES (1, 'john', 'john@example.com', '2025-06-05 10:00:00')
ON DUPLICATE KEY UPDATE 
    username = IF(VALUES(update_time) > update_time, VALUES(username), username),
    email = IF(VALUES(update_time) > update_time, VALUES(email), email),
    update_time = IF(VALUES(update_time) > update_time, VALUES(update_time), update_time);
```

## 六、延伸阅读

1. ^^[MySQL官方文档 - INSERT语法](https://dev.mysql.com/doc/refman/8.0/en/insert.html)^^
2. ^^[MySQL官方文档 - ON DUPLICATE KEY UPDATE](https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html)^^
3. ^^[高性能MySQL - 索引优化章节](https://book.douban.com/subject/23008813/)^^
4. ^^[阿里巴巴Java开发手册 - 数据库规约](https://github.com/alibaba/p3c)^^

> **技术检查点**
>
> - [ ] 是否理解了各种方案的适用场景
> - [ ] 是否考虑了性能影响
> - [ ] 是否处理了并发场景
> - [ ] 是否设计了合适的唯一约束

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-06-04 | 初始版本 |
