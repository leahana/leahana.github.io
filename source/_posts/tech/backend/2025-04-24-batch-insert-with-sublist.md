---
layout: post
title: Java分批处理实战：基于subList实现数据分片入库
date: 2025-04-24 14:30:00 +0800
categories: [tech, backend]
tags: [Java, 集合操作, 分批处理]
toc: true
---

## 目录

1. [应用场景](#一应用场景)  
2. [核心知识点](#二核心知识点)  
3. [代码实现](#三代码实现)  
   - 3.1 [基础分片](#31-基础分片)  
   - 3.2 [动态分片](#32-动态分片)  
4. [注意事项](#四注意事项)  
5. [拓展应用](#五拓展应用)  
6. [延伸阅读](#六延伸阅读)  

---
>需求描述：
>批量告警入库/更新，假设我们有一个包含100000个元素的List，我们需要将其分成100个批次，每个批次包含1000个元素。

## 一、应用场景

✅ 大数据量写入数据库时的内存控制  
✅ 批量接口的请求限制规避  
✅ 流式处理中的批次管理  

---

## 二、核心知识点

### 2.1 关键技术原理

- **集合分片原理**（subList实现机制）
[Oracle Java文档 - List.subList](https://docs.oracle.com/javase/8/docs/api/java/util/List.html#subList-int-int-)
- **Spring Boot事务控制机制**：@Transactional注解实现声明式事务，支持多种事务传播行为（如REQUIRED、REQUIRES_NEW），遇到RuntimeException自动回滚，保证批次操作的原子性（如银行转账，所有步骤都成功才算转账完成，否则全部回滚）。建议每个分片批次独立事务，避免单批失败影响全局一致性。
[Spring官方文档-事务管理](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative.html)^[阿里巴巴Java开发手册-事务控制]
- **分片算法的时间复杂度分析**（O(1)视图生成，O(n)遍历）
- **并发与事务一致性风险**（如ConcurrentModificationException，事务边界设计）

### 2.2 技术选型对比

- **推荐主流方案：subList**（适用于绝大多数批量分片场景，原生API，性能优，代码简洁）
- **Stream分组**（适合需要并行处理或分组逻辑更复杂的场景，JDK8+，如大数据量并发入库）
- **手动for分片**（适合对分片边界有特殊控制需求的极端场景，代码更灵活但维护成本高）

> 技术隐喻：subList就像快递分拣站的传送带，适合标准化批量处理；Stream分组则像多条流水线并行作业，效率更高但对设备有要求；手动for分片类似人工分拣，灵活但效率低。

---

## 三、代码实现

### 3.1 功能模块分解

- 批量分片算法
- 批量入库接口
- 监控与补偿机制

<div class ="mermaid">
flowchart TD
    subgraph 数据处理流程
        A[数据输入]:::blue --> B[批量分片算法]:::yellow
        B --> C[批量入库接口]:::green
        C --> D[监控与补偿机制]:::red
        D -.->|异常/失败| E(重试队列)
    end
</div>

> 技术隐喻：整个流程如同快递分拣中心，数据输入是包裹入库，分片算法像分拣传送带，批量入库接口是装车发货，监控与补偿机制则是异常包裹的人工复核区。

### 3.2 核心逻辑实现

```java
// JDK8+，异常处理与性能注释
public void batchInsert(List<Data> dataList, int batchSize) {
    if (dataList == null || dataList.isEmpty() || batchSize <= 0) {
        throw new IllegalArgumentException("参数非法");
    }
    int total = dataList.size();
    int batchCount = (total + batchSize - 1) / batchSize; // 分片数量
    for (int i = 0; i < batchCount; i++) {
        int fromIndex = i * batchSize;
        int toIndex = Math.min(fromIndex + batchSize, total);
        List<Data> batchList = dataList.subList(fromIndex, toIndex);
        try {
            // 数据库批量入库操作
            saveBatch(batchList);
        } catch (Exception e) {
            // 监控与补偿机制（如重试、告警）
            log.error("批次{}入库失败，from:{} to:{}", i, fromIndex, toIndex, e);
            // 可选：失败批次记录到补偿队列
        }
    }
}
```

🔗 与Stream API结合实现并行处理：

```java
split(data, 500).parallelStream()
    .forEach(batch -> repository.bulkInsert(batch));
```

🔗 在MyBatis批量插入中的应用：
我这边业务遇到的是保存告警,为了防止告警重复推送,我这边还使用了on duplicate,防止主键重复

```xml
<!-- MyBatis映射文件示例 -->
<insert id="batchInsert">
    INSERT INTO table VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.field})
    </foreach>
  ON DUPLICATE KEY UPDATE
  obj_id=values(obj_id)
</insert>
```

---

## 四、注意事项

❗️​**并发修改风险**
> 分片操作与原始集合的修改需要同步处理，避免ConcurrentModificationException（类似快递分拣站，分拣时不能随意增删包裹）

❗️**事务一致性建议**
> 建议每个批次独立事务，防止单批失败影响全局

❗️**内存优化建议**
> 建议分片大小根据堆内存配置动态计算，避免OOM（如分片=总数/可用内存MB*安全系数）

❗️**监控与补偿机制**
> 失败批次应有重试与告警机制，提升系统健壮性

❗️**性能陷阱**：超大列表的分片视图内存占用  

| 常见问题 | 排查建议 |
|----------|----------|
| OOM | 检查分片大小与JVM内存 |
| 并发异常 | 检查集合是否被多线程修改 |
| 数据丢失 | 检查补偿与重试逻辑 |

> ​**检查清单**  
>
> - [ ] 是否考虑并发修改异常  
> - [ ] 分片大小计算公式是否验证  
> - [ ] 监控与补偿机制是否完善  

---

## 五、拓展应用

🔄 相似技术迁移（如字符串分割、分页查询）

🔄 分布式批处理（如Spring Batch分片器、MapReduce分片）

🔄 幂等性与失败重试机制设计

### 5.1分片策略优化

```java
// 动态调整分片大小
// 动态分片算法（根据系统负载调整）
public static <T> List<List<T>> adaptiveSplit(List<T> list, int baseSize) {
    int currentLoad = getSystemLoad(); // 获取当前系统负载
    int adjustedSize = currentLoad > 70 ? baseSize / 2 : baseSize;
    return split(list, adjustedSize);
}
```

### 5.2 事务补偿机制

对于批量分片入库的事务补偿，推荐做法如下：

- 每个批次操作包裹在 @Transactional 方法中，确保原子性。
- 失败时通过重试、补偿队列等机制保证数据最终一致性。
- 如果需要分布式事务，可考虑使用 Seata、TCC 等框架。
技术隐喻 ：事务就像银行转账的保险箱，只有所有步骤都完成，钱才会真正转账，否则全部回滚。

```java
// 带事务补偿的分批处理
public void batchInsertWithRetry(List<Data> data) {
    List<List<Data>> batches = split(data, 1000);
    
    batches.forEach(batch -> {
        int retryCount = 0;
        while (retryCount < 3) {
            try {
                transactionalTemplate.execute(status -> {
                    repository.batchInsert(batch);
                    return Boolean.TRUE;
                });
                break;
            } catch (DataAccessException e) {
                retryCount++;
                log.warn("批次插入失败，重试次数: {}", retryCount);
            }
        }
    });
}
```

---

## 六、延伸阅读

1. [Effective Java - 集合处理最佳实践](https://book.douban.com/subject/27028517/)
2. [Java性能权威指南 - 内存管理章节](https://book.douban.com/subject/24722612/)
3. [阿里巴巴Java开发手册 - 集合操作](https://github.com/alibaba/p3c)
4. [Spring Batch官方文档 - 分片处理](https://docs.spring.io/spring-batch/docs/current/reference/html/index-single.html#partitioning)

[返回顶部](#top)