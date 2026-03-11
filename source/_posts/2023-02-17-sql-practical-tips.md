---
layout: post
title: SQL 实用函数与技巧：Oracle/MySQL 常用操作速查
date: 2023-02-17 15:23:55 +0800
categories: [tech, backend]
tags: [SQL, Oracle, MySQL, 数据库, MyBatis]
description: 汇总 Oracle 和 MySQL 日常开发中常用的 SQL 函数与技巧，包括 NVL 空值处理、ROW_NUMBER 分组取首条、MERGE INTO 数据同步、MySQL 用户管理等。
toc: true
---

> 🎯 **一句话定位**：一篇覆盖 Oracle/MySQL 日常开发高频操作的实战速查手册，解决 80% 的常见 SQL 问题
> 💡 **核心理念**：不求大而全，只求精而准——每个技巧都来自真实项目中的高频场景

---

## 📖 3分钟速览版

<details>
<summary><strong>📊 点击展开速查表</strong></summary>

### SQL 函数与技巧速查表

| 技巧 | 数据库 | 用途 | 关键语法 |
|------|--------|------|----------|
| NVL / NVL2 | Oracle | 空值处理 | `NVL(E1, E2)` / `NVL2(E1, E2, E3)` |
| ROW_NUMBER | Oracle/MySQL 8+ | 分组取首条 | `ROW_NUMBER() OVER(PARTITION BY x ORDER BY y)` |
| MERGE INTO | Oracle | 存在则更新，否则插入 | `MERGE INTO ... USING ... ON ... WHEN MATCHED / NOT MATCHED` |
| ON DUPLICATE KEY | MySQL | 存在则更新，否则插入 | `INSERT ... ON DUPLICATE KEY UPDATE` |
| NUMBER 类型映射 | Oracle | Java 类型对应 | n>18→BigDecimal, 10-18→Long, 1-9→Integer |
| 用户管理 | MySQL | 创建用户与授权 | `CREATE USER` + `GRANT` + `FLUSH PRIVILEGES` |

### Oracle vs MySQL 功能对比

| 功能 | Oracle | MySQL |
|------|--------|-------|
| 空值处理 | `NVL(E1, E2)` / `NVL2(E1, E2, E3)` | `IFNULL(E1, E2)` / `COALESCE(E1, E2)` |
| 分组取首条 | `ROW_NUMBER() OVER(...)` | MySQL 8+ 支持窗口函数，低版本用变量模拟 |
| 存在则更新否则插入 | `MERGE INTO ... USING ... ON ...` | `INSERT ... ON DUPLICATE KEY UPDATE` |
| 获取当前时间 | `SYSDATE` / `SYSTIMESTAMP` | `NOW()` / `CURRENT_TIMESTAMP` |
| 日期格式化 | `TO_CHAR(date, 'YYYY-MM-DD')` | `DATE_FORMAT(date, '%Y-%m-%d')` |
| 从虚拟表查询 | `SELECT ... FROM DUAL` | 直接 `SELECT ...`（不需要 DUAL） |

### 常用操作速查

```text
┌───────────────────────────────────────────────────┐
│               日常 SQL 操作决策树                    │
├───────────────────────────────────────────────────┤
│                                                   │
│  需要处理空值？                                     │
│  ├─ Oracle → NVL / NVL2                           │
│  └─ MySQL  → IFNULL / COALESCE                   │
│                                                   │
│  需要分组取第一条？                                  │
│  └─ ROW_NUMBER() OVER(PARTITION BY ... ORDER BY)  │
│                                                   │
│  需要"存在则更新，否则插入"？                         │
│  ├─ Oracle → MERGE INTO                           │
│  └─ MySQL  → INSERT ... ON DUPLICATE KEY UPDATE   │
│                                                   │
│  需要批量数据同步？                                  │
│  ├─ 方案一：查询→删除→批量插入（简单但有风险）         │
│  └─ 方案二：MERGE INTO（推荐，原子操作）             │
│                                                   │
└───────────────────────────────────────────────────┘
```

</details>

---

## 🧠 深度剖析版

## 1. Oracle 字段属性与类型映射

### 1.1 DATETIME 和 TIMESTAMP 的区别

| 对比项 | DATETIME | TIMESTAMP |
|--------|----------|-----------|
| **时间范围** | 1001-9999 年 | 1970-2038 年 |
| **时区处理** | 与时区无关 | 与时区有关，显示值依赖于时区设置 |
| **存储空间** | 8 字节 | 4 字节（更高效） |
| **默认值** | `NULL` | `NOT NULL`，默认为 `CURRENT_TIMESTAMP` |
| **自动更新** | 不会自动更新 | 未指定更新值时，默认更新为当前时间 |

> 💡 **选择建议**：如果需要记录跨时区的时间（如国际化项目），使用 TIMESTAMP；如果需要更大的时间范围或明确的空值语义，使用 DATETIME。

### 1.2 NUMBER 长度对应 Java 属性

Oracle NUMBER 类型在 Java 中的映射规则：

| NUMBER 长度 (n) | Java 类型 | 示例 |
|-----------------|-----------|------|
| 未指定或 n > 18 | `java.math.BigDecimal` | `NUMBER`、`NUMBER(20)` |
| 10 <= n <= 18 | `java.lang.Long` | `NUMBER(15)` |
| 1 <= n <= 9 | `java.lang.Integer` | `NUMBER(5)` |

> 💡 **实际开发提示**：MyBatis 中建议在 `resultMap` 中显式指定 `javaType`，避免因自动映射导致精度丢失。

## 2. Oracle 函数与查询技巧

### 2.1 NVL 空值处理函数

NVL 函数用于将 NULL 值转换为指定的默认值，是 Oracle 中最常用的空值处理函数之一。

```sql
-- NVL(E1, E2)：如果 E1 为 NULL，则返回 E2，否则返回 E1 本身
SELECT NVL(commission, 0) FROM employees;

-- NVL2(E1, E2, E3)：如果 E1 为 NULL，则返回 E3；若 E1 不为 NULL，则返回 E2
SELECT NVL2(commission, salary + commission, salary) FROM employees;
```

**MySQL 等价写法**：

```sql
-- MySQL 使用 IFNULL 代替 NVL
SELECT IFNULL(commission, 0) FROM employees;

-- 或者使用标准 SQL 的 COALESCE（Oracle/MySQL 通用）
SELECT COALESCE(commission, 0) FROM employees;
```

### 2.2 ROW_NUMBER 分组取首条数据

使用 `ROW_NUMBER()` 窗口函数按指定字段分组，并获取每组中排序后的第一条数据。

```sql
SELECT * FROM (
    SELECT ROW_NUMBER() OVER(PARTITION BY x ORDER BY y DESC) rn,
    t1.* FROM table_test t1
) t
WHERE t.rn = 1
```

**语法解析**：

- `PARTITION BY x`：按字段 x 进行分组
- `ORDER BY y DESC`：在每个分组内按字段 y 倒序排序
- `WHERE t.rn = 1`：取每个分组的第一条数据

> 💡 **性能提示**：当数据量较大时，确保 `PARTITION BY` 和 `ORDER BY` 涉及的字段有合适的索引，否则全表扫描会导致性能瓶颈。

### 2.3 MERGE INTO：存在则更新，否则插入

`MERGE INTO` 是 Oracle 中实现 "UPSERT" 操作的标准语法，可以在一条语句中完成插入或更新。

#### 在 MyBatis 中批量使用 MERGE INTO

`useGeneratedKeys` 只针对 INSERT 语句，默认为 false。当设置为 true 时，表示如果插入的表以自增列为主键，则允许 JDBC 支持自动生成主键。在 MERGE INTO 中应设置为 false。

```xml
<insert id="insert" parameterType="java.util.ArrayList" useGeneratedKeys="false">
merge into table_name_1 t1
using(
  <foreach collection="list" item="item" index="index" separator="union">
    select #{item.id,jdbcType=VARCHAR} ID,
           #{item.name,jdbcType=VARCHAR} NAME,
           #{item.age,jdbcType=NUMERIC} AGE,
           to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') CREATE_TIME,
           to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') UPDATE_TIME
    from DUAL
  </foreach>) t2
  on (t1.id = t2.id)
  when matched then
    update
      set t1.NAME = t2.NAME,
          t1.AGE = t2.AGE,
          t1.UPDATE_TIME = to_char(sysdate,'YYYY-MM-DD HH24:MI:SS')
  when not matched then
    insert(NAME, AGE, CREATE_TIME, UPDATE_TIME)
    values(t2.NAME, t2.AGE, t2.CREATE_TIME, t2.UPDATE_TIME)
</insert>
```

**MySQL 等价语法**：

```sql
INSERT INTO table_name_1 (id, name, age, create_time, update_time)
VALUES ('001', 'zhangsan', 25, NOW(), NOW())
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    age = VALUES(age),
    update_time = NOW();
```

## 3. Oracle 数据同步方案

在实际项目中，经常需要将 A 表的数据同步到 B 表。以下是两种常用方案的对比。

### 3.1 方案一：查询-删除-插入

**步骤**：

1. 查询 A 表中的所有数据
2. 删除 B 表中的所有数据
3. 将步骤一查询出的数据批量插入到 B 表中

> ⚠️ **注意**：此方案在步骤 2 和步骤 3 之间存在数据空窗期，如果批量插入失败，可能导致 B 表数据丢失。生产环境建议使用事务包裹或采用方案二。

### 3.2 方案二：MERGE INTO（推荐）

利用 MERGE INTO 语法根据 ID 判断记录是否存在，如果不存在 INSERT，如果存在 UPDATE。

**示例 1**：同一数据库内，将 A 表数据同步到 B 表

```sql
MERGE INTO B b        -- B 表是要更新的表
USING A a             -- 关联表
ON (b.id = a.id)      -- 关联条件
WHEN MATCHED THEN     -- 匹配关联条件执行更新操作
  UPDATE SET
    b.name = a.name,
    b.age = a.age
WHEN NOT MATCHED THEN -- 不匹配关联条件执行插入
  INSERT VALUES(a.name, a.age);
```

**示例 2**：跨数据库，将远程 A 表数据同步到本地 B 表

```sql
MERGE INTO B
USING (SELECT COUNT(*) count FROM B WHERE id = '123') t1
ON (t1.count <> 0)
WHEN MATCHED THEN
  UPDATE SET
    name = 'zhangsan',
    age = 12
  WHERE id = '123'
WHEN NOT MATCHED THEN
  INSERT (id, age, name) VALUES('123', 12, 'zhangsan');
```

## 4. Oracle 服务器启动

Oracle 数据库服务的标准启动流程：

```shell
# 先切换到 oracle 用户
$ lsnrctl start
$ sqlplus /nolog
SQL> conn / as sysdba
Connected to an idle instance
SQL> startup
ORACLE instance started
```

> 💡 **提示**：启动顺序为监听器（lsnrctl）先于数据库实例（startup），关闭时则相反。

## 5. MySQL 用户管理

### 5.1 创建用户

```sql
CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';
```

- `'%'` 表示允许从任何主机连接
- 如果仅允许本地连接，使用 `'localhost'`

### 5.2 授予权限

```sql
-- 授予指定数据库的所有权限
GRANT ALL PRIVILEGES ON databasename.* TO 'newuser'@'%';

-- 授予只读权限（更安全的做法）
GRANT SELECT ON databasename.* TO 'newuser'@'%';
```

### 5.3 使权限生效

```sql
FLUSH PRIVILEGES;
```

### 5.4 注意事项

- **语法错误**：确保命令的语法正确，没有多余的空格或拼写错误
- **权限问题**：确保以 root 等有足够权限的用户登录
- **重复用户**：可以通过 `SELECT user FROM mysql.user;` 确认用户是否已存在

在命令行中执行时：

```bash
mysql -u root -p -e "CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';"
```

> ⚠️ **安全提醒**：生产环境中避免使用 `ALL PRIVILEGES`，应遵循最小权限原则，只授予实际需要的权限。

---

## 💬 常见问题（FAQ）

### Q1: MERGE INTO 中 WHEN MATCHED 和 WHEN NOT MATCHED 可以只写一个吗？

**A:** 可以。`WHEN MATCHED` 和 `WHEN NOT MATCHED` 两个子句都是可选的，可以只写其中一个。例如只需要"不存在则插入、存在则跳过"的场景，可以只写 `WHEN NOT MATCHED THEN INSERT`。但至少需要包含一个子句，否则 MERGE INTO 语句没有意义。

### Q2: DATETIME 和 TIMESTAMP 该如何选择？

**A:** 选择取决于具体场景：

- **TIMESTAMP**：适合记录操作时间（如 `create_time`、`update_time`），自动处理时区转换，存储空间更小
- **DATETIME**：适合记录业务时间（如生日、合同到期日），时间范围更大，不受 2038 年限制

经验法则：技术字段用 TIMESTAMP，业务字段用 DATETIME。

### Q3: ROW_NUMBER 在大数据量下性能如何优化？

**A:** 几个关键优化策略：

1. **建立复合索引**：在 `PARTITION BY` 和 `ORDER BY` 的字段上建立复合索引
2. **减少返回列**：子查询中只选择需要的列，避免 `SELECT *`
3. **提前过滤**：在子查询内部添加 WHERE 条件，减少参与窗口计算的数据量
4. **考虑替代方案**：如果只需要每组最新一条，MySQL 中可以用 `GROUP BY` + `MAX()` 的关联子查询替代

### Q4: MySQL 的 INSERT ... ON DUPLICATE KEY UPDATE 和 REPLACE INTO 有什么区别？

**A:** 两者都能实现"存在则更新"的效果，但机制不同：

- **ON DUPLICATE KEY UPDATE**：检测到重复键时执行 UPDATE，保留原记录的主键 ID
- **REPLACE INTO**：检测到重复键时先 DELETE 再 INSERT，会生成新的自增 ID

建议使用 `ON DUPLICATE KEY UPDATE`，因为它不会改变主键值，也不会触发 DELETE 触发器。

### Q5: NVL 和 COALESCE 有什么区别？该用哪个？

**A:** 主要区别：

| 对比项 | NVL | COALESCE |
|--------|-----|----------|
| 标准性 | Oracle 专有 | SQL 标准，跨数据库通用 |
| 参数数量 | 固定 2 个参数 | 支持多个参数，返回第一个非 NULL 值 |
| 类型转换 | 自动将第二个参数转为第一个参数的类型 | 要求所有参数类型兼容 |
| 性能 | 两个参数都会被计算 | 短路求值，遇到非 NULL 即停止 |

**建议**：如果项目可能迁移到其他数据库，优先使用 `COALESCE`；如果确定只用 Oracle 且只需处理两个值，`NVL` 更简洁。

---

## ✨ 总结

本文涵盖了 Oracle 和 MySQL 日常开发中最常用的 SQL 操作技巧：

1. **空值处理**：Oracle 用 NVL/NVL2，MySQL 用 IFNULL/COALESCE
2. **分组取首条**：ROW_NUMBER() 窗口函数是最通用的方案
3. **UPSERT 操作**：Oracle 用 MERGE INTO，MySQL 用 ON DUPLICATE KEY UPDATE
4. **数据同步**：优先使用 MERGE INTO 方案，避免删除-插入的数据空窗风险
5. **用户管理**：MySQL 用户创建遵循创建→授权→刷新三步流程

### 🎯 行动建议

- **收藏速查表**：将 3分钟速览版中的对比表格收藏备用
- **注意性能**：使用 ROW_NUMBER 时务必检查索引
- **安全优先**：MySQL 授权遵循最小权限原则
- **跨库兼容**：优先使用 COALESCE 等 SQL 标准函数

---

## 更新记录

- 2023-02-17：初始版本
- 2026-03-11：优化文档结构，添加速查表和 FAQ
