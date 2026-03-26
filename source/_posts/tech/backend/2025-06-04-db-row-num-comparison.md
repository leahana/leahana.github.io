---
title: 不同关系型数据库实现ROW_NUM函数的区别
date: 2025-06-05 10:12:57
tags: [数据库, SQL, 分页, 性能优化]
categories: [tech, backend]
---

## 不同关系型数据库实现ROW_NUM函数的区别

[[返回技术博客]](/)

## 目录

1. [应用场景](#一应用场景)
2. [核心知识点](#二核心知识点)
3. [代码实现](#三代码实现)
4. [注意事项](#四注意事项)
5. [拓展应用](#五拓展应用)
6. [延伸阅读](#六延伸阅读)

## 一、应用场景

### 1.1 分页查询场景

算法给的一张表存放了以告警信息为每行数据,以字段defect_id缺陷id区分所属缺陷,展示的时候需要以缺陷为纬度进行展示,从oracle数据库到mysql再到高斯数据库进行了几次版本更替.

### 1.2 数据排序场景

在需要对数据进行排序并获取特定排名范围的场景中，ROW_NUM函数同样发挥着重要作用。比如：

- 获取销售额前10名的商品
- 查询某个班级成绩排名第5-10名的学生

### 1.3 数据去重场景

在处理重复数据时，我们经常需要保留每组数据中的第一条或最后一条记录，ROW_NUM函数可以帮助我们实现这个需求。

## 二、核心知识点

### 2.1 ROW_NUM函数原理

ROW_NUM函数本质上是一个窗口函数，它按照指定的排序规则为结果集中的每一行分配一个唯一的序号。这个序号从1开始递增。

### 2.2 主流数据库实现对比

| 数据库 | 语法 | 特点 |
|--------|------|------|
| Oracle | ROW_NUMBER() OVER() | 原生支持，性能最优 |
| MySQL | ROW_NUMBER() OVER() | 8.0+版本支持 |
| SQL Server | ROW_NUMBER() OVER() | 原生支持，语法统一 |
| PostgreSQL | ROW_NUMBER() OVER() | 原生支持，功能丰富 |

## 三、代码实现

### 3.1 Oracle

#### 3.1.1 使用示例

```sql
-- 基础分页查询
SELECT *
FROM (
    SELECT a.*, ROWNUM rnum
    FROM (
        SELECT *
        FROM employees
        ORDER BY salary DESC
    ) a
    WHERE ROWNUM <= 20
)
WHERE rnum > 10;

-- 使用ROW_NUMBER()函数
SELECT *
FROM (
    SELECT e.*, ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees e
)
WHERE rn BETWEEN 11 AND 20;
```

#### 3.1.2 优化方案实现需求

> 实现需求: 告警表defect_id 分组的每组第一条数据

```sql
-- 方案1：使用ROW_NUMBER()（推荐）
SELECT *
FROM (
    SELECT a.*,
           ROW_NUMBER() OVER (PARTITION BY defect_id ORDER BY create_time DESC) as rn
    FROM alarm_info a
) t
WHERE rn = 1;

-- 方案2：使用ROWNUM（适用于老版本）
SELECT *
FROM (
    SELECT a.*
    FROM alarm_info a
    WHERE (defect_id, create_time) IN (
        SELECT defect_id, MAX(create_time)
        FROM alarm_info
        GROUP BY defect_id
    )
);
```

### 3.2 MySQL

#### 3.2.1 使用示例

```sql
-- MySQL 8.0+ 实现
SELECT *
FROM (
    SELECT e.*, ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees e
) t
WHERE rn BETWEEN 11 AND 20;

-- MySQL 5.7及以下版本实现
SELECT *
FROM employees e
ORDER BY salary DESC
LIMIT 10, 10;
```

#### 3.2.2 优化方案实现需求

```sql
-- MySQL 8.0+ 实现（推荐）
SELECT *
FROM (
    SELECT a.*,
           ROW_NUMBER() OVER (PARTITION BY defect_id ORDER BY create_time DESC) as rn
    FROM alarm_info a
) t
WHERE rn = 1;

-- MySQL 5.7及以下版本实现
SELECT a.*
FROM alarm_info a
INNER JOIN (
    SELECT defect_id, MAX(create_time) as max_time
    FROM alarm_info
    GROUP BY defect_id
) b ON a.defect_id = b.defect_id AND a.create_time = b.max_time;

```

3.2.3 其他方式

```sql
-- 使用用户变量实现（MySQL特有方案）
SELECT *
FROM (
    SELECT a.*,
           @rn := IF(@defect_id = defect_id, @rn + 1, 1) as rn,
           @defect_id := defect_id
    FROM alarm_info a,
         (SELECT @rn := 0, @defect_id := NULL) vars
    ORDER BY defect_id, create_time DESC
) t
WHERE rn = 1;
```

**技术说明**：

1. **实现原理**
   - 使用MySQL的用户变量（@rn, @defect_id）来维护分组状态
   - 通过IF语句判断当前行是否属于同一分组
   - 利用变量赋值和比较实现分组计数

2. **优点**
   - 性能较好，避免了子查询
   - 兼容MySQL 5.7及以下版本
   - 实现简单直观

3. **注意事项**
   - 依赖执行顺序，ORDER BY子句必须正确
   - 变量初始化的位置很重要
   - 在多表关联时需要注意变量作用域

4. **使用建议**
   - 适合单表查询场景
   - 建议添加适当的索引（defect_id, create_time）
   - 注意并发查询时的变量隔离

> **补充说明**：
> 这种实现方式在MySQL中是一个很巧妙的解决方案，特别是在需要兼容老版本MySQL的场景下。不过在使用时需要注意执行顺序和变量作用域的问题。这种方式虽然不如窗口函数直观，但在某些场景下可能会有更好的性能表现。

### 3.3 SQL Server实现

```sql
SELECT *
FROM (
    SELECT e.*, ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees e
) t
WHERE rn BETWEEN 11 AND 20;
```

## 四、注意事项

### 4.1 性能优化建议

❗️**索引使用**
> 确保ORDER BY子句中的字段已建立适当的索引

❗️**分页大小控制**
> 建议单页数据量控制在1000条以内

### 4.2 常见陷阱

1. 在子查询中使用ROW_NUMBER()时，注意性能影响
2. 大数据量分页时，避免使用OFFSET方式
3. 注意不同数据库版本的语法差异

## 五、拓展应用

### 5.1 高级分页方案

- 使用"键集分页"（Keyset Pagination）
- 实现无限滚动加载
- 缓存分页结果

### 5.2 性能优化技巧

- 使用覆盖索引
- 实现分页缓存
- 采用异步加载策略

## 六、延伸阅读

1. ^^[Oracle官方文档 - ROW_NUMBER函数](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/ROW_NUMBER.html)^^
2. ^^[MySQL 8.0参考手册 - 窗口函数](https://dev.mysql.com/doc/refman/8.0/en/window-functions.html)^^
3. ^^[SQL Server文档 - ROW_NUMBER函数](https://docs.microsoft.com/en-us/sql/t-sql/functions/row-number-transact-sql)^^

> **技术检查点**
>
> - [ ] 是否考虑了数据库版本兼容性
> - [ ] 分页查询是否使用了合适的索引
> - [ ] 是否实现了性能优化措施
> - [ ] 是否处理了边界情况

---

## 更新记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2025-06-04 | 初始版本 |
