---
title: MySQL 时间字段最佳实践
date: 2026-01-06 00:00:00 +0800
tags: [MySQL, 数据库, 时区, MyBatis]
categories: [tech, backend]
---

# 对话存档：MySQL 时间字段最佳实践

## 一、添加时间字段的 ALTER 语句

在 MySQL 5.7.38 中，可以使用以下 ALTER 语句来添加创建时间和更新时间字段：

```sql
ALTER TABLE t_alarm
ADD COLUMN create_time_dt DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
ADD COLUMN update_time_dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';
```

**说明：**

- `create_time_dt`：创建时自动记录当前时间，之后不会自动变化
- `update_time_dt`：创建时记录当前时间，每次更新记录时自动更新为当前时间
- `DATETIME` 类型格式即为 `2021-12-03 12:21:21`

**执行前建议：**

```sql
-- 先检查表结构，确认字段名不冲突
DESC t_alarm;

-- 如果表有数据，可以在测试环境先执行验证
```

---

## 二、时间参数前后端传递最佳实践

### 完整数据流架构

```
Vue (前端) → Controller (接收) → Service (处理) → MyBatis Mapper (持久化)
```

---

### Vue 前端传参

**传参格式：ISO 8601 标准字符串**

```javascript
// 方式一：使用 moment/dayjs
import dayjs from 'dayjs';

// 传给后端
const params = {
  createTime: dayjs().format('YYYY-MM-DD HH:mm:ss'),  // '2021-12-03 12:21:21'
  updateTime: new Date().toISOString(),                // '2021-12-03T12:21:21.000Z'
  startTime: '2021-12-03 12:21:21'
};

// 方式二：使用 timestamp (不推荐，可读性差)
const params = {
  createTime: Date.now()  // 1638505281000
};
```

**推荐：** 使用 `YYYY-MM-DD HH:mm:ss` 格式字符串，与 MySQL DATETIME 格式一致

---

### Controller 层接收

```java
import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;
import java.time.LocalDateTime;
import java.time.LocalDate;

@RestController
@RequestMapping("/alarm")
public class AlarmController {

    // 方案一：使用 String 接收（推荐，灵活）
    @PostMapping("/create")
    public Result create(
        @RequestParam("createTime")
        @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") String createTime,

        @RequestParam("updateTime")
        @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") String updateTime
    ) {
        // 传递给 Service 层处理
        return alarmService.create(createTime, updateTime);
    }

    // 方案二：使用 LocalDateTime 接收（推荐，类型安全）
    @PostMapping("/create2")
    public Result create2(
        @RequestParam("createTime")
        @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime createTime,

        @RequestParam("updateTime")
        @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime updateTime
    ) {
        return alarmService.create(createTime, updateTime);
    }

    // 方案三：使用 DTO 对象接收（最佳实践）
    @PostMapping("/create3")
    public Result create3(@Valid @RequestBody AlarmDTO alarmDTO) {
        return alarmService.create(alarmDTO);
    }
}
```

---

### DTO 参数校验

```java
import javax.validation.constraints.*;
import org.springframework.format.annotation.DateTimeFormat;
import java.time.LocalDateTime;

public class AlarmDTO {

    @NotBlank(message = "告警名称不能为空")
    private String alarmName;

    @NotNull(message = "创建时间不能为空")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @NotNull(message = "更新时间不能为空")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    // 时间范围查询示例
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;

    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;

    // getter/setter...
}
```

---

### 应用层转换

```java
@Service
public class AlarmService {

    @Autowired
    private AlarmMapper alarmMapper;

    public Result create(AlarmDTO dto) {
        // LocalDateTime 转 String（用于 MyBatis）
        String createTimeStr = formatDateTime(dto.getCreateTime());
        String updateTimeStr = formatDateTime(dto.getUpdateTime());

        // 业务逻辑处理
        Alarm alarm = new Alarm();
        alarm.setCreateTimeDt(createTimeStr);
        alarm.setUpdateTimeDt(updateTimeStr);

        // 如果需要自动设置时间
        if (alarm.getCreateTimeDt() == null) {
            alarm.setCreateTimeDt(formatDateTime(LocalDateTime.now()));
        }

        alarmMapper.insert(alarm);
        return Result.success();
    }

    // 格式化工具方法
    private String formatDateTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return null;
        }
        return dateTime.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    // String 转 LocalDateTime
    private LocalDateTime parseDateTime(String dateTimeStr) {
        if (dateTimeStr == null) {
            return null;
        }
        return LocalDateTime.parse(dateTimeStr,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
}
```

---

### Entity 实体类

```java
public class Alarm {

    private Long id;
    private String alarmName;

    // 对应数据库 create_time_dt DATETIME
    private String createTimeDt;

    // 对应数据库 update_time_dt DATETIME
    private String updateTimeDt;

    // getter/setter...
}
```

---

### MyBatis Mapper

**Mapper XML**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.example.mapper.AlarmMapper">

    <resultMap id="BaseResultMap" type="com.example.entity.Alarm">
        <id column="id" property="id"/>
        <result column="alarm_name" property="alarmName"/>
        <result column="create_time_dt" property="createTimeDt"/>
        <result column="update_time_dt" property="updateTimeDt"/>
    </resultMap>

    <!-- 插入 -->
    <insert id="insert" parameterType="com.example.entity.Alarm">
        INSERT INTO t_alarm (alarm_name, create_time_dt, update_time_dt)
        VALUES (#{alarmName}, #{createTimeDt}, #{updateTimeDt})
    </insert>

    <!-- 时间范围查询 -->
    <select id="selectByTimeRange" resultMap="BaseResultMap">
        SELECT * FROM t_alarm
        WHERE create_time_dt >= #{startTime}
          AND create_time_dt <= #{endTime}
        ORDER BY create_time_dt DESC
    </select>

</mapper>
```

**Mapper 接口**

```java
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface AlarmMapper {

    int insert(Alarm alarm);

    List<Alarm> selectByTimeRange(
        @Param("startTime") String startTime,
        @Param("endTime") String endTime
    );
}
```

---

### 完整最佳实践总结

| 层级 | 推荐类型 | 说明 |
|------|----------|------|
| **Vue 前端** | `String` | 格式：`'2021-12-03 12:21:21'` |
| **Controller** | `LocalDateTime` | 使用 `@DateTimeFormat` 自动转换 |
| **DTO** | `LocalDateTime` | 类型安全，支持 JSR303 校验 |
| **Service** | `LocalDateTime` | 业务逻辑处理 |
| **Entity** | `String` | 与数据库 DATETIME 格式一致 |
| **MyBatis** | `String` | 无需类型处理器，直传直用 |

---

### 工具类推荐

```java
public class DateTimeUtils {

    private static final DateTimeFormatter DATETIME_FORMATTER =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    // LocalDateTime → String
    public static String format(LocalDateTime dateTime) {
        return dateTime != null ? dateTime.format(DATETIME_FORMATTER) : null;
    }

    // String → LocalDateTime
    public static LocalDateTime parse(String dateTimeStr) {
        return dateTimeStr != null ?
            LocalDateTime.parse(dateTimeStr, DATETIME_FORMATTER) : null;
    }

    // 获取当前时间字符串
    public static String now() {
        return LocalDateTime.now().format(DATETIME_FORMATTER);
    }
}
```

---

### 注意事项

1. **时区问题**：确保服务器和数据库时区一致
2. **空值处理**：前后端都要做好 null 值处理
3. **格式统一**：全项目统一使用 `yyyy-MM-dd HH:mm:ss` 格式
4. **数据库自动更新**：如果配置了 `ON UPDATE CURRENT_TIMESTAMP`，应用层不需要手动更新 `update_time_dt`

---

## 三、时区检查与动态适配

### 检查 MySQL 时区

```sql
-- 查看 MySQL 全局时区
SELECT @@global.time_zone;

-- 查看 MySQL 会话时区
SELECT @@session.time_zone;

-- 查看当前时间（验证时区）
SELECT NOW(), CURRENT_TIMESTAMP(), UTC_TIMESTAMP();

-- 查看 MySQL 系统时区
SHOW VARIABLES LIKE '%time_zone%';

-- 查看时区偏移
SELECT TIMEDIFF(NOW(), UTC_TIMESTAMP());
```

**结果示例：**
- `SYSTEM` - 表示使用系统时区
- `+08:00` - 东八区
- `UTC` - 协调世界时

### 检查应用层（JVM）时区

```java
// 方式一：代码检查
System.out.println(TimeZone.getDefault());
System.out.println(System.getProperty("user.timezone"));

// 方式二：启动参数查看
// java -XX:+PrintFlagsFinal -version | grep TimeZone
```

---

## 四、应用层动态时区适配方案

### 方案一：JVM 启动参数指定时区（推荐）

```bash
# 启动时指定时区
java -Duser.timezone=Asia/Shanghai -jar your-app.jar

# 或者在环境变量中设置
export TZ='Asia/Shanghai'
java -jar your-app.jar

# Docker 容器中
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
```

---

### 方案二：Spring Boot 配置文件

**application.yml**

```yaml
spring:
  jackson:
    time-zone: Asia/Shanghai
    date-format: yyyy-MM-dd HH:mm:ss
  datasource:
    url: jdbc:mysql://localhost:3306/your_db?serverTimezone=Asia/Shanghai
```

---

### 方案三：数据库连接 URL 时区参数（推荐）

```yaml
spring:
  datasource:
    # 方式一：指定时区
    url: jdbc:mysql://localhost:3306/your_db?serverTimezone=Asia/Shanghai

    # 方式二：使用 UTC 并在应用层转换
    url: jdbc:mysql://localhost:3306/your_db?serverTimezone=UTC

    # 方式三：强制使用数据库时区
    url: jdbc:mysql://localhost:3306/your_db?useTimezone=true&serverTimezone=Asia/Shanghai

    # 完整配置示例
    url: jdbc:mysql://localhost:3306/your_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false
```

---

### 方案四：自定义时区转换工具类

```java
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.TimeZone;

public class TimeZoneUtils {

    // 数据库时区（根据实际情况配置）
    private static final String DB_TIMEZONE = "UTC";

    // 应用时区
    private static final String APP_TIMEZONE = "Asia/Shanghai";

    private static final DateTimeFormatter DATETIME_FORMATTER =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    /**
     * 应用时间 → 数据库时间（写入时转换）
     */
    public static String toDbTime(LocalDateTime appTime) {
        if (appTime == null) {
            return null;
        }
        ZonedDateTime appZoned = appTime.atZone(ZoneId.of(APP_TIMEZONE));
        ZonedDateTime dbZoned = appZoned.withZoneSameInstant(ZoneId.of(DB_TIMEZONE));
        return dbZoned.format(DATETIME_FORMATTER);
    }

    /**
     * 数据库时间 → 应用时间（读取时转换）
     */
    public static LocalDateTime fromDbTime(String dbTimeStr) {
        if (dbTimeStr == null) {
            return null;
        }
        LocalDateTime dbTime = LocalDateTime.parse(dbTimeStr, DATETIME_FORMATTER);
        return dbTime.atZone(ZoneId.of(DB_TIMEZONE))
                     .withZoneSameInstant(ZoneId.of(APP_TIMEZONE))
                     .toLocalDateTime();
    }

    /**
     * 获取当前应用时间（字符串格式）
     */
    public static String now() {
        return LocalDateTime.now(ZoneId.of(APP_TIMEZONE))
                           .format(DATETIME_FORMATTER);
    }

    /**
     * 获取当前数据库时间（字符串格式）
     */
    public static String dbNow() {
        return ZonedDateTime.now(ZoneId.of(DB_TIMEZONE))
                           .format(DATETIME_FORMATTER);
    }
}
```

---

### 方案五：MyBatis TypeHandler 自动转换（推荐）

```java
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedTypes;
import java.sql.*;
import java.time.*;
import java.time.format.DateTimeFormatter;

@MappedTypes(LocalDateTime.class)
public class LocalDateTimeTypeHandler extends BaseTypeHandler<LocalDateTime> {

    private static final String APP_TIMEZONE = "Asia/Shanghai";
    private static final String DB_TIMEZONE = "UTC";
    private static final DateTimeFormatter FORMATTER =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i,
                                    LocalDateTime parameter, JdbcType jdbcType) throws SQLException {
        // 应用时间转数据库时间
        ZonedDateTime appZoned = parameter.atZone(ZoneId.of(APP_TIMEZONE));
        ZonedDateTime dbZoned = appZoned.withZoneSameInstant(ZoneId.of(DB_TIMEZONE));
        ps.setString(i, dbZoned.format(FORMATTER));
    }

    @Override
    public LocalDateTime getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String dbTimeStr = rs.getString(columnName);
        return convertToAppTime(dbTimeStr);
    }

    @Override
    public LocalDateTime getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String dbTimeStr = rs.getString(columnIndex);
        return convertToAppTime(dbTimeStr);
    }

    @Override
    public LocalDateTime getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String dbTimeStr = cs.getString(columnIndex);
        return convertToAppTime(dbTimeStr);
    }

    private LocalDateTime convertToAppTime(String dbTimeStr) {
        if (dbTimeStr == null) {
            return null;
        }
        LocalDateTime dbTime = LocalDateTime.parse(dbTimeStr, FORMATTER);
        return dbTime.atZone(ZoneId.of(DB_TIMEZONE))
                     .withZoneSameInstant(ZoneId.of(APP_TIMEZONE))
                     .toLocalDateTime();
    }
}
```

**配置 TypeHandler**

```yaml
# application.yml
mybatis:
  type-handlers-package: com.example.config.typehandler
```

或者在 Mapper XML 中指定：

```xml
<resultMap id="BaseResultMap" type="com.example.entity.Alarm">
    <id column="id" property="id"/>
    <result column="create_time_dt" property="createTimeDt"
            typeHandler="com.example.config.typehandler.LocalDateTimeTypeHandler"/>
    <result column="update_time_dt" property="updateTimeDt"
            typeHandler="com.example.config.typehandler.LocalDateTimeTypeHandler"/>
</resultMap>
```

---

### 方案六：Service 层统一处理

```java
@Service
public class AlarmService {

    @Value("${app.timezone:Asia/Shanghai}")
    private String appTimezone;

    @Value("${db.timezone:UTC}")
    private String dbTimezone;

    public Result create(AlarmDTO dto) {
        Alarm alarm = new Alarm();

        // 设置创建时间（当前应用时区时间）
        alarm.setCreateTimeDt(getCurrentDbTime());

        // 转换前端传入的时间
        if (dto.getUpdateTime() != null) {
            alarm.setUpdateTimeDt(convertToDbTime(dto.getUpdateTime()));
        } else {
            alarm.setUpdateTimeDt(getCurrentDbTime());
        }

        alarmMapper.insert(alarm);
        return Result.success();
    }

    /**
     * 获取当前数据库时区对应的时间字符串
     */
    private String getCurrentDbTime() {
        return ZonedDateTime.now(ZoneId.of(dbTimezone))
                           .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    /**
     * 应用时区时间 → 数据库时区时间
     */
    private String convertToDbTime(LocalDateTime appTime) {
        ZonedDateTime appZoned = appTime.atZone(ZoneId.of(appTimezone));
        ZonedDateTime dbZoned = appZoned.withZoneSameInstant(ZoneId.of(dbTimezone));
        return dbZoned.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }

    /**
     * 数据库时区时间 → 应用时区时间
     */
    private LocalDateTime convertFromDbTime(String dbTimeStr) {
        LocalDateTime dbTime = LocalDateTime.parse(dbTimeStr,
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        return dbTime.atZone(ZoneId.of(dbTimezone))
                     .withZoneSameInstant(ZoneId.of(appTimezone))
                     .toLocalDateTime();
    }
}
```

---

## 五、完整配置示例

**application.yml**

```yaml
# 时区配置
app:
  timezone: Asia/Shanghai
  db-timezone: UTC

spring:
  jackson:
    time-zone: ${app.timezone}
    date-format: yyyy-MM-dd HH:mm:ss

  datasource:
    url: jdbc:mysql://localhost:3306/your_db?serverTimezone=${app.db-timezone}
```

**启动类添加时区**

```java
@SpringBootApplication
public class Application {

    @Value("${app.timezone:Asia/Shanghai}")
    private String timezone;

    @PostConstruct
    public void init() {
        TimeZone.setDefault(TimeZone.getTimeZone(timezone));
        System.out.println("应用时区设置为: " + timezone);
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

---

## 六、最佳实践推荐

| 方案 | 适用场景 | 优先级 |
|------|----------|--------|
| **JVM 启动参数** | 统一时区，简单直接 | ⭐⭐⭐⭐⭐ |
| **数据库 URL 时区参数** | 数据库时区不一致 | ⭐⭐⭐⭐⭐ |
| **TypeHandler 自动转换** | 跨时区应用，自动处理 | ⭐⭐⭐⭐ |
| **Spring Boot 配置** | 项目级配置 | ⭐⭐⭐⭐ |
| **Service 层手动转换** | 特殊业务场景 | ⭐⭐⭐ |

**推荐组合：** JVM 参数 + 数据库 URL 时区参数 + Spring Boot 配置

---

## 七、通用 SQL 脚本模板

```sql
-- =============================================
-- 通用时间字段添加脚本
-- 用法：将 your_table_name 替换为实际表名
-- =============================================

ALTER TABLE your_table_name
ADD COLUMN create_time_dt DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
ADD COLUMN update_time_dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间';

-- 验证添加结果
DESC your_table_name;
```

**使用步骤：**

1. **替换表名**
   ```bash
   # 方式一：手动编辑
   vim add_datetime_columns.sql

   # 方式二：使用 sed 批量替换
   sed 's/your_table_name/t_user/g' add_datetime_columns.sql > add_t_user.sql
   ```

2. **执行脚本**
   ```bash
   mysql -u root -p your_database < add_datetime_columns.sql
   ```

3. **验证结果**
   ```sql
   DESC your_table_name;
   ```
