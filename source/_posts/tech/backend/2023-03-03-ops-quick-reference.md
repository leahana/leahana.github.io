---
layout: post
title: 运维速查：Linux SFTP 配置 / Java FTP 操作 / Mac Gradle 安装
date: 2023-03-03 14:56:29 +0800
categories: [tech, backend]
tags: [Linux, SFTP, FTP, Gradle, 运维, Mac]
description: 三合一运维速查手册，涵盖 Linux 服务器 SFTP 用户配置、Java Commons Net FTP 文件操作工具类、macOS 下 Gradle 环境安装。
toc: true
---

> 🎯 **一句话定位**：三合一运维速查手册，覆盖文件传输配置与构建工具安装的常见场景
> 💡 **核心理念**：运维操作标准化 = 明确步骤 + 安全意识 + 故障排查能力

---

## 📖 3分钟速览版

<details>
<summary><strong>📊 点击展开速查表</strong></summary>

### 主题总览

| 主题 | 场景 | 核心工具 | 难度 |
|------|------|----------|------|
| Linux SFTP 配置 | 服务器文件传输通道搭建 | OpenSSH `internal-sftp` | ⭐⭐ |
| Java FTP 操作 | 程序化文件上传/下载/删除 | Apache Commons Net | ⭐⭐ |
| Mac Gradle 安装 | macOS 构建工具环境配置 | Gradle CLI | ⭐ |

### 🔑 SFTP 快速命令

```shell
# 1. 创建用户组和用户
groupadd sftp
useradd -g sftp -s /bin/false sftpuser01
passwd sftpuser01

# 2. 创建目录并指定 home
mkdir -p /data/sftp/sftpuser01
usermod -d /data/sftp/sftpuser01 sftpuser01

# 3. 编辑 /etc/ssh/sshd_config 添加 SFTP 配置
# 4. 重启 sshd 服务
systemctl restart sshd
```

### ☕ Java FTP Maven 依赖

```xml
<dependency>
    <groupId>commons-net</groupId>
    <artifactId>commons-net</artifactId>
    <version>3.9.0</version>
</dependency>
```

### 🍎 Gradle 安装核心步骤

```shell
# 下载 binary-only 包后解压，配置环境变量
export GRADLE_HOME="/path/to/gradle-x.x.x"
export PATH=$PATH:$GRADLE_HOME/bin
source ~/.bash_profile
gradle -v
```

</details>

---

## 🧠 深度剖析版

## 1. Linux 服务器开启 SFTP

SFTP（SSH File Transfer Protocol）基于 SSH 协议提供安全的文件传输能力。相比传统 FTP，SFTP 通过加密通道传输数据，无需额外开放端口，是服务器文件传输的首选方案。

### 1.1 创建 SFTP 用户组

创建专用用户组，用于后续在 `sshd_config` 中通过 `Match Group` 进行访问控制。

```shell
groupadd sftp
cat /etc/group
# sftp:x:1002:
```

> **说明**：创建完成后使用 `cat /etc/group` 查看组信息，确认组已成功创建。

### 1.2 创建 SFTP 用户并添加到用户组

创建用户 `sftpuser01` 并加入 `sftp` 用户组，同时设置密码。

```shell
useradd -g sftp -s /bin/false sftpuser01
passwd sftpuser01
```

**参数说明**：

- `-g sftp`：指定用户主组为 `sftp`
- `-s /bin/false`：禁止用户通过 Shell 登录，仅允许 SFTP 访问

### 1.3 新建目录并指定为用户 home 目录

```shell
# 新建 /data/sftp/sftpuser01 目录，并将它指定为 sftpuser01 用户的 home 目录
mkdir -p /data/sftp/sftpuser01
usermod -d /data/sftp/sftpuser01 sftpuser01
```

### 1.4 编辑 SSH 配置文件

编辑 `/etc/ssh/sshd_config`，配置 SFTP 服务。

```shell
vim /etc/ssh/sshd_config

# 1. 配置基本的 SSH 远程登录配置
PasswordAuthentication yes    # 开启验证
PermitEmptyPasswords no       # 禁止空密码登录
PermitRootLogin yes           # 开启远程登录

# 2. 配置 SFTP 使用系统自带的 internal-sftp 服务
# 注释掉下面这行
# Subsystem sftp /usr/lib/openssh/sftp-server
Subsystem sftp internal-sftp

# 3. 对登录用户的限定
# Match Group sftp 对匹配到的用户组起作用，且高于 SSH 的通项配置
Match Group sftp
# ChrootDirectory 指定用户验证后用于 chroot 环境的路径
ChrootDirectory /data/sftp/sftpuser01

# ForceCommand 强制使用 internal-sftp，用户只能使用 SFTP 模式登录
ForceCommand internal-sftp
AllowTcpForwarding no    # 禁止 TCP 端口转发
X11Forwarding no         # 禁止 X11 转发
```

### 1.5 重启 SSH 服务

配置完成后需要重启 `sshd` 服务使配置生效。

```shell
systemctl restart sshd
```

### 1.6 注意事项

1. **chroot 路径权限**：chroot 路径上的所有目录，所有者必须是 root，权限最大为 `0755`。如果以非 root 用户登录，需要在 chroot 下新建一个登录用户有权限操作的目录。

2. **chroot 对 SSH 的影响**：chroot 一旦设定，登录用户的会话根目录 `/` 切换为此目录。如果使用 SSH 而非 SFTP 协议登录，会提示：`/bin/bash: No such file or directory`

3. **ForceCommand 限制**：如果配置了此项，Match 到的用户只能使用 SFTP 协议登录，无法使用 SSH 登录，会被提示：`This service allows sftp connections only.`

### 1.7 安全建议

- **禁用 root 远程登录**：生产环境建议将 `PermitRootLogin` 设置为 `no`，使用普通用户登录后再 `su` 或 `sudo`
- **使用密钥认证**：条件允许时，使用 SSH Key 替代密码认证，在 `sshd_config` 中设置 `PasswordAuthentication no`
- **限制登录 IP**：在 `Match Group` 中添加 `AllowUsers sftpuser01@192.168.1.*` 限制来源 IP
- **定期审计日志**：查看 `/var/log/auth.log`（Debian/Ubuntu）或 `/var/log/secure`（CentOS/RHEL）监控异常登录

### 1.8 故障排查

| 现象 | 可能原因 | 解决方案 |
|------|----------|----------|
| `Permission denied` | chroot 目录权限不正确 | 确保 chroot 路径所有目录属主为 root，权限 `0755` |
| `Connection refused` | sshd 未重启或端口被防火墙拦截 | `systemctl restart sshd` 并检查防火墙规则 |
| `/bin/bash: No such file or directory` | 使用 SSH 而非 SFTP 连接 chroot 用户 | 改用 SFTP 客户端连接 |
| `Write failed: ... Permission denied` | 用户对目标目录没有写权限 | 在 chroot 下创建子目录并赋予用户写权限 |

---

## 2. Java FTP 文件操作工具类

基于 Apache Commons Net 封装的 FTP 操作工具类，支持文件上传、下载、删除等常用操作。

### 2.1 Maven 依赖

在 `pom.xml` 中添加 Apache Commons Net 依赖：

```xml
<dependency>
    <groupId>commons-net</groupId>
    <artifactId>commons-net</artifactId>
    <version>3.9.0</version>
</dependency>
```

> **版本说明**：`3.9.0` 为撰写时的稳定版本，可前往 [Maven Central](https://search.maven.org/artifact/commons-net/commons-net) 查看最新版本。

### 2.2 工具类完整代码

```java
import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import java.io.*;

public class FtpOperation {
    private String server;
    private int port;
    private String user;
    private String password;
    private FTPClient ftp;

    public FtpOperation(String server, int port, String user, String password) {
        this.server = server;
        this.port = port;
        this.user = user;
        this.password = password;
    }

    /** 建立 FTP 连接并登录 */
    public boolean connect() {
        ftp = new FTPClient();
        try {
            ftp.connect(server, port);
            ftp.login(user, password);
            ftp.enterLocalPassiveMode();       // 被动模式，适合有防火墙/NAT 的环境
            ftp.setFileType(FTP.BINARY_FILE_TYPE); // 二进制传输，避免文件损坏
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 上传本地文件到 FTP 服务器 */
    public boolean uploadFile(String remoteFilePath, String localFilePath) {
        try (InputStream input = new FileInputStream(new File(localFilePath))) {
            return ftp.storeFile(remoteFilePath, input);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 从 FTP 服务器下载文件到本地 */
    public boolean downloadFile(String remoteFilePath, String localFilePath) {
        try (OutputStream output = new FileOutputStream(new File(localFilePath))) {
            return ftp.retrieveFile(remoteFilePath, output);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 删除 FTP 服务器上的文件 */
    public boolean deleteFile(String remoteFilePath) {
        try {
            return ftp.deleteFile(remoteFilePath);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    /** 断开 FTP 连接 */
    public boolean disconnect() {
        try {
            ftp.logout();
            ftp.disconnect();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
}
```

### 2.3 代码说明

**核心方法一览**：

| 方法 | 功能 | 参数 |
|------|------|------|
| `connect()` | 建立连接并登录 | 无（使用构造参数） |
| `uploadFile()` | 上传文件 | 远程路径, 本地路径 |
| `downloadFile()` | 下载文件 | 远程路径, 本地路径 |
| `deleteFile()` | 删除远程文件 | 远程路径 |
| `disconnect()` | 断开连接 | 无 |

**关键设计点**：

- **被动模式**（`enterLocalPassiveMode`）：由客户端发起数据连接，适合客户端在防火墙/NAT 后的场景
- **二进制传输**（`BINARY_FILE_TYPE`）：避免文本模式下换行符转换导致文件损坏

### 2.4 使用示例

```java
public class Main {
    public static void main(String[] args) {
        FtpOperation ftpOp = new FtpOperation("192.168.1.100", 21, "ftpuser", "password");

        if (ftpOp.connect()) {
            // 上传文件
            boolean uploaded = ftpOp.uploadFile("/remote/data.csv", "/local/data.csv");
            System.out.println("上传结果: " + uploaded);

            // 下载文件
            boolean downloaded = ftpOp.downloadFile("/remote/report.pdf", "/local/report.pdf");
            System.out.println("下载结果: " + downloaded);

            // 删除远程文件
            boolean deleted = ftpOp.deleteFile("/remote/old-file.txt");
            System.out.println("删除结果: " + deleted);

            ftpOp.disconnect();
        }
    }
}
```

### 2.5 改进建议

在生产环境中使用时，建议对此工具类做以下增强：

- **连接超时设置**：通过 `ftp.setConnectTimeout()` 和 `ftp.setDataTimeout()` 避免长时间阻塞
- **重试机制**：对网络不稳定场景增加自动重连逻辑
- **日志替代 `printStackTrace`**：使用 SLF4J / Logback 等日志框架记录异常
- **连接池**：高并发场景下使用连接池管理 FTPClient 实例
- **FTPS 支持**：如需加密传输，可改用 `FTPSClient` 替代 `FTPClient`

---

## 3. Mac 安装 Gradle

Gradle 是一个基于 JVM 的现代化构建工具，广泛用于 Java、Kotlin、Android 等项目。以下介绍在 macOS 上手动安装 Gradle 的方法。

### 3.1 下载 Gradle

前往官方发布页面下载：[https://gradle.org/releases/](https://gradle.org/releases/)

选择 **binary-only** 版本下载（无需源码和文档，体积更小）。

### 3.2 配置环境变量

将 Gradle 解压到指定目录后，编辑 Shell 配置文件添加环境变量。

```shell
vim ~/.bash_profile

# 添加路径（"=" 号前后不能有空格）
export GRADLE_HOME="/Users/username/DevTools/JavaDev/gradle/gradle-7.6.1"
export PATH=$PATH:$GRADLE_HOME/bin

# 保存后重新加载配置文件
source ~/.bash_profile
```

> **注意**：如果使用 zsh（macOS 默认），请编辑 `~/.zshrc` 而非 `~/.bash_profile`。

### 3.3 验证安装

```shell
gradle -v

# 输出示例：
# Welcome to Gradle 7.6.1!
# Build time:   2023-02-24 13:54:42 UTC
# Kotlin:       1.7.10
# Groovy:       3.0.13
# JVM:          1.8.0_332
# OS:           Mac OS X 13.2.1 aarch64
```

### 3.4 替代方案：使用 SDKMAN 安装

[SDKMAN](https://sdkman.io/) 是 JVM 生态的版本管理工具，可以更方便地安装和切换多个 Gradle 版本。

```shell
# 安装 SDKMAN（如未安装）
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

# 安装 Gradle
sdk install gradle 7.6.1

# 切换版本
sdk use gradle 8.5

# 查看已安装版本
sdk list gradle
```

**优势**：

- 无需手动配置 `PATH`
- 支持多版本并存和快速切换
- 同时管理 Java、Maven、Kotlin 等工具

### 3.5 Gradle Wrapper 推荐

在实际项目中，推荐使用 **Gradle Wrapper**（`gradlew`）而非全局安装的 Gradle。

```shell
# 项目根目录下使用 wrapper
./gradlew build

# 升级 wrapper 版本
./gradlew wrapper --gradle-version 8.5
```

**为什么推荐 Wrapper**：

- 团队成员无需单独安装 Gradle
- 确保所有人使用相同的 Gradle 版本
- CI/CD 环境无需预装 Gradle
- 跟随项目代码版本控制

---

## 💬 常见问题（FAQ）

### Q1: SFTP 配置后连接失败，提示 Permission denied 怎么办？

**A:** 最常见的原因是 chroot 目录权限配置不正确。检查以下几点：

1. chroot 路径上的**所有目录**（如 `/data`、`/data/sftp`、`/data/sftp/sftpuser01`）属主必须是 `root`
2. 这些目录的权限不能超过 `0755`（即不能有组写权限或其他写权限）
3. 用户需要在 chroot 目录内有一个可写的子目录用于上传文件

```shell
# 检查并修复权限
chown root:root /data /data/sftp /data/sftp/sftpuser01
chmod 755 /data /data/sftp /data/sftp/sftpuser01

# 创建用户可写的子目录
mkdir /data/sftp/sftpuser01/upload
chown sftpuser01:sftp /data/sftp/sftpuser01/upload
```

### Q2: Java FTP 上传文件为 0 字节，内容丢失？

**A:** 通常是因为没有使用被动模式或没有设置二进制传输类型：

- 确保调用了 `ftp.enterLocalPassiveMode()`（被动模式）
- 确保调用了 `ftp.setFileType(FTP.BINARY_FILE_TYPE)`（二进制模式）
- 检查 FTP 服务器端的存储路径是否存在且有写权限

### Q3: macOS 上配置 `~/.bash_profile` 后 `gradle -v` 仍然提示 command not found？

**A:** macOS Catalina（10.15）及以后版本默认 Shell 为 zsh，而非 bash。解决方案：

- 将环境变量配置到 `~/.zshrc` 而非 `~/.bash_profile`
- 或者执行 `source ~/.bash_profile` 确保当前终端加载了配置
- 或者改用 SDKMAN 安装，自动处理 Shell 兼容问题

### Q4: SFTP 和 FTP 有什么区别？应该选哪个？

**A:** 两者是完全不同的协议：

| 特性 | SFTP | FTP |
|------|------|-----|
| 协议基础 | 基于 SSH | 独立协议 |
| 加密 | 全程加密 | 明文传输（除 FTPS） |
| 端口 | 22（SSH 端口） | 21 + 动态数据端口 |
| 防火墙友好度 | 高（单端口） | 低（需开放多端口） |
| 推荐场景 | 服务器间传输、安全敏感场景 | 遗留系统兼容 |

**建议**：新项目优先使用 SFTP。只有在对接不支持 SFTP 的遗留系统时才考虑 FTP。

### Q5: Gradle Wrapper 和全局安装的 Gradle 冲突了怎么办？

**A:** Gradle Wrapper（`./gradlew`）和全局 `gradle` 命令是独立的，不会冲突：

- `./gradlew` 使用项目 `gradle/wrapper/gradle-wrapper.properties` 中指定的版本
- `gradle` 使用全局安装的版本
- 在项目中始终使用 `./gradlew` 确保版本一致性
- 如果 IDE 使用了错误的 Gradle 版本，在项目设置中指定使用 "Gradle Wrapper" 即可

---

## ✨ 总结

本文覆盖了三个常见的运维操作场景，核心要点回顾：

1. **Linux SFTP 配置**：通过 `internal-sftp` + `ChrootDirectory` + `Match Group` 实现安全的文件传输通道，注意 chroot 目录权限必须由 root 拥有且不超过 `0755`
2. **Java FTP 工具类**：基于 Apache Commons Net 封装，关键是启用被动模式和二进制传输，生产环境需加入超时、重试和日志机制
3. **Mac Gradle 安装**：手动安装需配置 `GRADLE_HOME` 和 `PATH`，推荐使用 SDKMAN 管理版本，项目中优先使用 Gradle Wrapper

> **运维最佳实践**：标准化操作流程、重视安全配置、做好故障排查预案。

---

## 更新记录

- 2023-03-03：初始版本
- 2026-03-11：优化文档结构，添加速查表、安全建议和 FAQ
