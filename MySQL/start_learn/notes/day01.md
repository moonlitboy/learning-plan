# Day 01 - MySQL 基本结构与 Terminal / SQLTools 环境

## 一、今天的学习目标

今天主要解决两个问题：

1. 搞清楚 MySQL Server、mysql Client、SQLTools 之间的关系
2. 学会分别通过 Terminal 和 SQLTools 操作 MySQL Server

今天的核心认识：

```text
SQL 才是核心
Terminal 和 SQLTools 只是不同的操作工具
```

---

## 二、MySQL 的整体结构

MySQL 的基本结构可以理解为：

```text
MySQL Server
│
├── database
│   ├── table
│   ├── table
│   └── ...
│
├── database
│   └── ...
│
└── ...
```

其中：

- MySQL Server：真正负责管理数据库、表和数据
- database：数据库，一个 Server 可以有多个 database
- table：表，一个 database 可以有多张表

当前学习数据库：

```text
study_mysql
```

之后两周的主要练习都会围绕这个数据库展开。

---

## 三、MySQL Server

### 1. MySQL Server 是什么

MySQL Server 是真正运行在电脑上的数据库服务程序。

可以把它类比成银行后台管理系统：

```text
MySQL Server
      ↓
管理 database
      ↓
管理 table
      ↓
管理真正的数据
```

Terminal 和 SQLTools 都不是数据库本身。

它们只是客户端，用来连接和操作 MySQL Server。

---

## 四、mysql Client

在 Terminal 中执行：

```bash
mysql -u root -p
```

其中的：

```text
mysql
```

是 MySQL 的命令行客户端程序。

它和 MySQL Server 不是同一个东西。

关系：

```text
Terminal
   ↓
mysql Client
   ↓
MySQL Server
```

成功连接以后会看到：

```text
mysql>
```

说明当前已经进入 mysql Client。

---

## 五、mysql -u root -p

命令：

```bash
mysql -u root -p
```

拆解：

```text
mysql
```

启动 mysql Client。

```text
-u
```

指定登录用户。

```text
root
```

使用 MySQL 中的 root 用户。

```text
-p
```

要求输入密码进行身份验证。

所以完整含义是：

> 使用 mysql Client，以 root 用户身份通过密码验证连接 MySQL Server。

注意：

MySQL 的 root 是 MySQL 自己的数据库用户，不等于 macOS 的 root 用户。

---

## 六、通过 Homebrew 管理 MySQL Server

查看 Homebrew 服务：

```bash
brew services list
```

今天看到：

```text
mysql@8.4  started
```

说明 MySQL Server 当前正在运行。

### 启动 MySQL

```bash
brew services start mysql@8.4
```

### 停止 MySQL

```bash
brew services stop mysql@8.4
```

### 重启 MySQL

```bash
brew services restart mysql@8.4
```

当前安装的 MySQL Server 版本：

```text
MySQL 8.4.11
```

---

## 七、常用状态查询

### 查看 MySQL 版本

```sql
SELECT VERSION();
```

今天返回：

```text
8.4.11
```

### 查看所有数据库

```sql
SHOW DATABASES;
```

最初看到的数据库：

```text
information_schema
mysql
performance_schema
sys
```

之后创建了：

```text
study_mysql
```

### 查看当前正在使用的数据库

```sql
SELECT DATABASE();
```

如果还没有选择数据库，会返回：

```text
NULL
```

这不代表连接失败。

它表示：

```text
已经连接 MySQL Server
但是当前没有选择 database
```

---

## 八、database 与 USE

### database 是什么

database 是 MySQL Server 中组织和管理表的一层单位。

关系：

```text
MySQL Server
│
├── database
│   ├── table
│   └── table
│
└── database
```

一个 MySQL Server 可以有多个 database。

### USE

切换当前数据库：

```sql
USE study_mysql;
```

执行后：

```text
Database changed
```

再次查询：

```sql
SELECT DATABASE();
```

返回：

```text
study_mysql
```

说明当前连接正在使用：

```text
study_mysql
```

---

## 九、USE 只对当前连接生效

今天发现一个很重要的问题：

执行：

```sql
USE study_mysql;
```

以后：

```sql
SELECT DATABASE();
```

会返回：

```text
study_mysql
```

但是断开连接再重新连接以后，当前数据库可能又发生变化。

原因：

> `USE` 改变的是当前数据库连接的状态。

例如 Terminal：

```text
mysql -u root -p
        ↓
当前数据库 NULL
        ↓
USE study_mysql;
        ↓
当前数据库 study_mysql
        ↓
退出连接
        ↓
本次连接结束
```

下一次重新连接时，需要重新选择数据库。

---

## 十、SQLTools

SQLTools 是 VS Code 中使用的数据库客户端。

关系：

```text
VS Code
   ↓
SQLTools
   ↓
MySQL Server
```

Terminal 中的 mysql Client：

```text
Terminal
   ↓
mysql Client
   ↓
MySQL Server
```

所以：

```text
mysql Client
和
SQLTools
```

虽然操作方式不同，但最终连接的是同一个 MySQL Server。

---

## 十一、SQLTools 连接参数

当前 SQLTools 连接主要参数：

```text
Server Address: localhost
Port: 3306
Username: root
Database: study_mysql
```

### localhost

```text
localhost
```

表示当前电脑。

通常也可以写：

```text
127.0.0.1
```

可以理解为：

```text
localhost
=
127.0.0.1
=
当前这台 Mac
```

### 3306

```text
3306
```

是 MySQL Server 默认使用的端口。

可以简单理解：

```text
localhost → 找到当前电脑
3306      → 找到这台电脑上的 MySQL 服务
```

---

## 十二、SQLTools 的默认 Database

SQLTools 的 Connection Settings 中有：

```text
Database
```

如果设置：

```text
Database: study_mysql
```

那么重新打开 VS Code、重新连接 SQLTools 后：

```sql
SELECT DATABASE();
```

会直接返回：

```text
study_mysql
```

这和执行：

```sql
USE study_mysql;
```

不是完全同一个概念。

区别：

```text
Connection Settings
Database = study_mysql
```

表示：

> 每次建立 SQLTools 新连接时，默认使用 study_mysql。

而：

```sql
USE study_mysql;
```

表示：

> 当前已经建立的连接临时切换到 study_mysql。

---

## 十三、Connection Name 与 Database 的区别

SQLTools 中：

```text
Connection name: study_mysql
```

只是 SQLTools 给这个连接配置起的名字。

而：

```text
Database: study_mysql
```

才是真正指定连接后默认使用的 MySQL database。

两者现在虽然同名，但概念完全不同。

---

## 十四、创建数据库

基本语法：

```sql
CREATE DATABASE database_name;
```

例如今天 Terminal 中：

```sql
CREATE DATABASE terminal_test;
```

SQLTools 中：

```sql
CREATE DATABASE sqltools_test;
```

正式创建学习数据库：

```sql
CREATE DATABASE study_mysql
CHARACTER SET utf8mb4;
```

---

## 十五、CHARACTER SET utf8mb4

今天创建数据库时使用：

```sql
CHARACTER SET utf8mb4
```

它表示给数据库指定默认字符集：

```text
utf8mb4
```

今天先记住：

```text
study_mysql
默认字符集
→ utf8mb4
```

字符集的更深入原理以后再学习。

---

## 十六、删除数据库

基本语法：

```sql
DROP DATABASE database_name;
```

今天 Terminal：

```sql
DROP DATABASE terminal_test;
```

SQLTools：

```sql
DROP DATABASE sqltools_test;
```

注意：

`DROP DATABASE` 会删除整个数据库。

以后操作真实数据库时必须谨慎。

---

## 十七、Terminal / SQLTools 双修实验

### Terminal

创建：

```sql
CREATE DATABASE terminal_test;
```

检查：

```sql
SHOW DATABASES;
```

删除：

```sql
DROP DATABASE terminal_test;
```

### SQLTools

创建：

```sql
CREATE DATABASE sqltools_test;
```

检查：

```sql
SHOW DATABASES;
```

删除：

```sql
DROP DATABASE sqltools_test;
```

### 实验结论

Terminal 创建数据库以后：

```sql
SHOW DATABASES;
```

可以看到。

SQLTools 创建数据库以后，Terminal：

```sql
SHOW DATABASES;
```

也可以看到。

说明：

```text
Terminal ───────┐
                ↓
             MySQL Server
                ↑
SQLTools ───────┘
```

两者操作的是同一个 MySQL Server。

---

## 十八、SQLTools 执行 SQL

今天创建了：

```text
day01.sql
```

用于保存当天实际练习的 SQL。

### 执行整个文件

可以使用：

```text
Run on Active Connection
```

执行当前 SQL 文件中的多条 SQL。

### 只执行选中的 SQL

今天使用的快捷方式：

```text
选中 SQL
↓
Command + E
↓
Command + E
```

以后 `dayXX.sql` 越来越长时，主要使用这种方式执行单独的 SQL。

---

## 十九、为什么 CREATE / DROP 右侧没有表格

例如：

```sql
CREATE DATABASE sqltools_test;
```

或者：

```sql
DROP DATABASE sqltools_test;
```

SQLTools 右侧可能没有数据显示。

这是正常的。

因为它们主要是在修改数据库结构，而不是查询数据。

可以使用：

```sql
SHOW DATABASES;
```

检查操作结果。

例如：

```text
CREATE DATABASE
↓
SHOW DATABASES
↓
看到数据库
```

以及：

```text
DROP DATABASE
↓
SHOW DATABASES
↓
数据库消失
```

---

## 二十、忘记分号时的现象

今天 Terminal 中输入：

```sql
DROP DATABASE terminal_test
```

因为忘记写：

```text
;
```

mysql Client 显示：

```text
->
```

这表示：

> 当前 SQL 语句还没有结束，mysql Client 正在等待继续输入。

补上：

```sql
;
```

以后才真正执行。

所以：

```text
mysql>
```

一般表示可以开始输入新的 SQL。

而：

```text
->
```

通常说明上一条 SQL 还没有结束。

---

## 二十一、今天掌握的命令

### Terminal

```bash
brew services list

brew services start mysql@8.4

brew services stop mysql@8.4

brew services restart mysql@8.4

mysql -u root -p
```

### SQL

```sql
SELECT VERSION();

SHOW DATABASES;

SELECT DATABASE();

CREATE DATABASE database_name;

DROP DATABASE database_name;

USE database_name;
```

正式学习数据库：

```sql
CREATE DATABASE study_mysql
CHARACTER SET utf8mb4;

USE study_mysql;
```

---

## 二十二、Day 1 核心概念总结

### MySQL Server

真正负责管理数据库、表和数据的服务程序。

### mysql

Terminal 中使用的 MySQL 命令行客户端。

不是 MySQL Server。

### SQLTools

VS Code 中的数据库客户端。

### 3306

MySQL Server 的默认端口。

### root

MySQL 中的数据库用户。

### database

MySQL Server 中用于组织和管理表的一层单位。

### USE

切换当前连接默认使用的数据库。

---

## 二十三、最终结构

```text
Mac
│
├── Homebrew
│   └── MySQL Server 8.4
│       │
│       └── study_mysql
│
├── Terminal
│   └── mysql Client
│       │
│       └──────────────┐
│                      │
└── VS Code            │
    └── SQLTools       │
        │              │
        └──────────────┤
                       ↓
                  MySQL Server
```

最终应该牢记：

```text
SQL 是核心

Terminal
和
SQLTools

只是执行 SQL、操作 MySQL Server 的不同客户端。
```

---

## 二十四、Day 1 完成情况

- [x] 查看 MySQL Server 状态
- [x] Terminal 连接 MySQL
- [x] 理解 mysql Client
- [x] 理解 MySQL Server
- [x] 查看 MySQL 版本
- [x] 查看所有数据库
- [x] 查看当前数据库
- [x] Terminal 创建 / 删除测试数据库
- [x] SQLTools 创建 / 删除测试数据库
- [x] 创建 study_mysql
- [x] 使用 utf8mb4
- [x] 使用 USE 切换数据库
- [x] SQLTools 默认数据库改为 study_mysql
- [x] 理解 localhost
- [x] 理解 3306
- [x] 理解 root
- [x] 完成 Terminal / SQLTools 交叉验证
- [x] 完成 Day 1 验收

# Day 1：完成
