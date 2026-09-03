# MySQL 14 天系统学习计划
## Mac + Terminal + VS Code + SQLTools 双修版

学习时间：14 天  
每天时间：4～5 小时  
总学习时间：约 60～70 小时  

目标环境：

- macOS
- Homebrew 安装的 MySQL 8.4
- Terminal
- VS Code
- SQLTools
- `.sql` 文件管理学习代码

---

# 一、14 天最终目标

14 天结束后，不只是要求“会写 SQL”。

而是达到下面这个状态：

## 1. SQL 能力

能够独立写：

- CREATE DATABASE
- CREATE TABLE
- ALTER TABLE
- INSERT
- UPDATE
- DELETE
- SELECT
- WHERE
- ORDER BY
- LIMIT
- GROUP BY
- HAVING
- JOIN
- 子查询
- CTE
- VIEW
- INDEX
- TRANSACTION

能够理解：

- 主键
- 外键
- UNIQUE
- NOT NULL
- 数据类型
- 一对多
- 多对多
- 范式
- 索引
- EXPLAIN
- ACID
- 隔离级别
- 锁
- 用户权限
- 数据备份与恢复

---

# 二、Terminal 和 SQLTools 必须双修

这是整个计划最重要的要求之一。

不能出现：

> 离开 SQLTools，我就不会操作 MySQL。

也不能出现：

> 所有 SQL 都在终端里写，几十行 JOIN 写得很痛苦。

两个工具应该分工合作。

---

# 三、两个工具分别负责什么

## Terminal

Terminal 主要学习：

- MySQL Server 是否启动
- 启动 / 停止 MySQL
- mysql 客户端连接
- 数据库基本查看
- 临时执行 SQL
- 两个 Session 测试事务
- 用户权限操作
- mysqldump
- 数据恢复
- 执行 `.sql` 文件
- 排查连接问题

例如：

```bash
brew services list
```

连接：

```bash
mysql -u root -p
```

进入后：

```sql
SHOW DATABASES;
```

退出：

```sql
exit;
```

以后要求：

> 即使 VS Code 坏了，你依然可以使用 MySQL。

---

## SQLTools

SQLTools 主要负责：

- 写较长 SQL
- 保存 SQL
- 重复执行 SQL
- SELECT 查询
- JOIN
- 子查询
- GROUP BY
- CTE
- EXPLAIN
- 建表脚本
- 数据初始化脚本
- 日常开发

你以后实际开发最常见的状态就是：

```text
VS Code
    ↓
.sql 文件
    ↓
SQLTools
    ↓
MySQL Server
```

---

# 四、双修的核心训练方法

以后每学一个重要知识点，都执行一次：

```text
理论
↓
Terminal 手敲
↓
SQLTools 再写
↓
比较结果
↓
保存到 .sql
```

例如今天学习：

```sql
CREATE DATABASE test_db;
```

不能只在 SQLTools 中执行一次。

应该：

### Terminal

```bash
mysql -u root -p
```

然后：

```sql
CREATE DATABASE terminal_test;
SHOW DATABASES;
DROP DATABASE terminal_test;
```

然后 SQLTools：

```sql
CREATE DATABASE sqltools_test;
SHOW DATABASES;
DROP DATABASE sqltools_test;
```

这样：

```text
SQL 是核心
Terminal / SQLTools 只是执行 SQL 的不同工具
```

这个概念会慢慢形成。

---

# 五、每天固定学习时间

建议每天按照：

## 第 1 小时：理论

约 50～60 分钟。

理解：

- 为什么
- 原理
- 使用场景
- 常见错误

不要急着敲 SQL。

---

## 第 2 小时：Terminal 实验

约 40～50 分钟。

当天重要知识全部在 Terminal 做一遍。

目标：

> 脱离 VS Code 仍然会操作。

---

## 第 3～4 小时：SQLTools 正式练习

约 2 小时。

所有正式学习代码：

```text
day01.sql
day02.sql
...
```

在这里完成。

---

## 最后 40～60 分钟：独立任务

关闭教程。

不看答案。

自己完成当天任务。

---

# 六、项目目录

建立：

```text
mysql-learning/
│
├── day01.sql
├── day02.sql
├── day03.sql
├── day04.sql
├── day05.sql
├── day06.sql
├── day07.sql
├── day08.sql
├── day09.sql
├── day10.sql
├── day11.sql
├── day12.sql
├── day13.sql
├── day14.sql
│
├── project/
│   ├── schema.sql
│   ├── data.sql
│   ├── query.sql
│   └── backup/
│
└── notes/
    ├── day01.md
    ├── day02.md
    └── ...
```

---

# 七、贯穿两周的数据库项目

整个两周只练一个主要项目：

# study_mysql

校园选课系统。

最终包含：

```text
departments
     │
     ├── teachers
     │       │
     │       └── courses
     │
students
     │
     └── enrollments
             │
             └── courses
```

也就是：

```text
学院
教师
学生
课程
选课记录
```

两周内不断扩充这个数据库。

---

# Day 1
# MySQL 基本结构 + Terminal / SQLTools 环境彻底搞懂

## 理论

理解：

```text
MySQL Server
```

和：

```text
mysql Client
```

不是一个东西。

整体结构：

```text
Terminal
   │
mysql 客户端
   │
   ↓
MySQL Server
   │
   ├── database
   │     ├── table
   │     └── table
   │
   └── database
```

SQLTools也是一个客户端：

```text
SQLTools
   ↓
MySQL Server
```

所以：

```text
Terminal mysql 客户端
```

和：

```text
SQLTools
```

本质上都是：

> 操作 MySQL Server 的工具。

---

## Terminal 必修

查看 MySQL：

```bash
brew services list
```

启动：

```bash
brew services start mysql@8.4
```

停止：

```bash
brew services stop mysql@8.4
```

重启：

```bash
brew services restart mysql@8.4
```

连接：

```bash
mysql -u root -p
```

理解：

```text
mysql
```

客户端程序。

```text
-u root
```

root 用户。

```text
-p
```

要求输入密码。

然后执行：

```sql
SELECT VERSION();

SHOW DATABASES;

SELECT DATABASE();
```

退出：

```sql
exit;
```

---

## SQLTools 必修

确认连接：

```text
Host
Port
Username
Password
Database
```

理解：

```text
127.0.0.1 / localhost
```

表示本机。

```text
3306
```

是 MySQL 默认端口。

建立：

```text
day01.sql
```

写：

```sql
SHOW DATABASES;

SELECT VERSION();

SELECT DATABASE();
```

使用：

```text
Run on Active Connection
```

执行。

---

## 双修任务

Terminal：

```sql
CREATE DATABASE terminal_test;
DROP DATABASE terminal_test;
```

SQLTools：

```sql
CREATE DATABASE sqltools_test;
DROP DATABASE sqltools_test;
```

最后创建：

```sql
CREATE DATABASE study_mysql
CHARACTER SET utf8mb4;

USE study_mysql;
```

---

## Day 1 验收

必须能解释：

```text
MySQL Server 是什么？
mysql 命令是什么？
SQLTools是什么？
3306是什么？
root是什么？
database是什么？
```

并能：

```text
Terminal连接数据库
SQLTools连接数据库
```

---

# Day 2
# Table + Data Type + Constraint

## 理论

理解：

```text
Database
 ↓
Table
 ↓
Row
 ↓
Column
```

掌握：

```text
INT
BIGINT
DECIMAL
CHAR
VARCHAR
TEXT
DATE
DATETIME
TIMESTAMP
```

约束：

```text
PRIMARY KEY
AUTO_INCREMENT
NOT NULL
UNIQUE
DEFAULT
CHECK
```

---

## Terminal

进入：

```bash
mysql -u root -p
```

```sql
USE study_mysql;
```

临时建表：

```sql
CREATE TABLE terminal_students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);
```

查看：

```sql
SHOW TABLES;

DESC terminal_students;

SHOW CREATE TABLE terminal_students;
```

删除：

```sql
DROP TABLE terminal_students;
```

---

## SQLTools

正式建立：

```sql
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_no VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    enroll_year INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

课程：

```sql
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits DECIMAL(3,1) NOT NULL,
    capacity INT DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 独立任务

自己建立：

```text
teachers
```

要求至少包含：

```text
id
teacher_no
name
email
created_at
```

---

# Day 3
# INSERT / UPDATE / DELETE

理论：

```text
CRUD
```

其中：

```text
Create → INSERT
Read → SELECT
Update → UPDATE
Delete → DELETE
```

---

## Terminal

练简单 INSERT：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260001', '张三', 'zhang@example.com', 2026);
```

查询：

```sql
SELECT * FROM students;
```

修改：

```sql
UPDATE students
SET email = 'new@example.com'
WHERE student_no = '20260001';
```

---

## SQLTools

批量 INSERT：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260002', '李四', 'li@example.com', 2026),
('20260003', '王五', 'wang@example.com', 2025),
('20260004', '赵六', 'zhao@example.com', 2025);
```

今天准备：

```text
学生 ≥ 15
教师 ≥ 5
课程 ≥ 8
```

---

## 必须形成的安全习惯

UPDATE 之前：

```sql
SELECT *
FROM students
WHERE student_no = '20260001';
```

确认结果。

然后才：

```sql
UPDATE ...
```

DELETE 同理。

---

# Day 4
# SELECT 基础彻底掌握

学习：

```text
SELECT
FROM
WHERE
AND
OR
NOT
IN
BETWEEN
LIKE
IS NULL
DISTINCT
ORDER BY
LIMIT
```

---

## Terminal

每天随机完成 3～5 个短查询。

例如：

```sql
SELECT * FROM students;

SELECT name FROM students;

SELECT *
FROM students
WHERE enroll_year = 2026;
```

目的不是效率。

目的是保持终端 SQL 手感。

---

## SQLTools

主要练复杂查询。

例如：

```sql
SELECT
    student_no,
    name,
    enroll_year
FROM students
WHERE enroll_year IN (2025, 2026)
ORDER BY enroll_year DESC
LIMIT 5;
```

---

## 当天任务

完成：

```text
2026学生
邮箱为空
邮箱不为空
姓张学生
2025或2026学生
课程学分2～4
课程按学分倒序
前3条课程
```

---

# Day 5
# 聚合 + GROUP BY + HAVING

掌握：

```text
COUNT
SUM
AVG
MAX
MIN
GROUP BY
HAVING
```

理解：

```text
WHERE
```

筛选行。

```text
HAVING
```

筛选分组。

---

## Terminal

完成：

```sql
SELECT COUNT(*) FROM students;

SELECT AVG(credits) FROM courses;

SELECT MAX(credits) FROM courses;
```

---

## SQLTools

完成：

```sql
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year
HAVING COUNT(*) >= 2;
```

理解 SQL 逻辑顺序：

```text
FROM
↓
WHERE
↓
GROUP BY
↓
HAVING
↓
SELECT
↓
ORDER BY
↓
LIMIT
```

---

# Day 6
# 外键 + 一对多 + 多对多 + JOIN

第一周最重要的一天。

## 理论

理解：

```text
teacher
1
↓
N
courses
```

一对多。

学生和课程：

```text
students
N
↓
enrollments
↑
N
courses
```

多对多。

---

## SQLTools 建表

```sql
CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,

    student_id INT NOT NULL,
    course_id INT NOT NULL,

    score DECIMAL(5,2),

    UNIQUE(student_id, course_id),

    FOREIGN KEY (student_id)
        REFERENCES students(id),

    FOREIGN KEY (course_id)
        REFERENCES courses(id)
);
```

---

## JOIN

```sql
SELECT
    s.name,
    c.course_name
FROM enrollments AS e
JOIN students AS s
    ON e.student_id = s.id
JOIN courses AS c
    ON e.course_id = c.id;
```

---

## Terminal

Terminal 不适合大量写 JOIN。

所以今天采用：

```text
SQLTools 写 JOIN
↓
保存
↓
复制一个 JOIN 到 Terminal
↓
运行
```

目标只是确保：

> Terminal 也可以执行复杂 SQL。

---

## 必会

```text
INNER JOIN
LEFT JOIN
```

先不必花大量时间研究：

```text
RIGHT JOIN
```

因为实际写 SQL 时往往通过调换表顺序使用 LEFT JOIN。

---

# Day 7
# 第一周综合考试

今天基本不学新知识。

## 第一部分 Terminal

创建：

```sql
CREATE DATABASE week1_test;
```

然后在 Terminal 独立：

```text
建表
插入几条数据
修改
删除
简单查询
```

---

## 第二部分 SQLTools

重新建立：

```text
students
teachers
courses
enrollments
```

然后：

```text
JOIN
GROUP BY
WHERE
ORDER BY
LIMIT
```

全部不查答案。

---

## 第三部分

最后：

```sql
DROP DATABASE week1_test;
```

---

# Day 8
# Subquery + EXISTS + CTE

## 子查询

```sql
SELECT *
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
);
```

---

## EXISTS

```sql
SELECT *
FROM students AS s
WHERE EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.id
);
```

---

## CTE

```sql
WITH course_count AS (
    SELECT
        student_id,
        COUNT(*) AS total
    FROM enrollments
    GROUP BY student_id
)
SELECT *
FROM course_count
WHERE total >= 2;
```

---

## 双修方式

Terminal：

```text
执行简单子查询
```

SQLTools：

```text
完成复杂子查询
EXISTS
CTE
```

---

# Day 9
# 数据库设计 + ALTER TABLE + 范式

今天重点不在 SQL 数量。

而是：

> 为什么表应该这样设计？

学习：

```text
1NF
2NF
3NF
```

重点掌握第三范式的实际思想：

```text
避免重复数据
避免字段之间错误依赖
```

---

## SQLTools

建立：

```sql
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE
);
```

学习：

```text
ALTER TABLE
ADD COLUMN
MODIFY COLUMN
DROP COLUMN
ADD CONSTRAINT
```

---

## Terminal

每天完成一次：

```sql
DESC table_name;

SHOW CREATE TABLE table_name;
```

这是非常重要的终端数据库检查能力。

---

# Day 10
# INDEX + EXPLAIN

第二周最重要的一天。

学习：

```text
主键索引
唯一索引
普通索引
联合索引
```

---

## SQLTools

```sql
CREATE INDEX idx_students_name
ON students(name);
```

查看：

```sql
SHOW INDEX FROM students;
```

查询：

```sql
EXPLAIN
SELECT *
FROM students
WHERE name = '张三';
```

再：

```sql
EXPLAIN ANALYZE
SELECT *
FROM students
WHERE name = '张三';
```

---

## Terminal

Terminal 中必须完成：

```sql
SHOW INDEX FROM students;
```

以及至少运行一次：

```sql
EXPLAIN SELECT ...;
```

---

## 今天特别实验

```text
查询
↓
EXPLAIN
↓
建索引
↓
EXPLAIN
↓
比较
```

不要只背：

> 索引可以提高速度。

必须亲眼看到执行计划变化。

---

# Day 11
# TRANSACTION + ACID + Isolation + Lock

这是 Terminal 双修价值最高的一天。

今天 SQLTools 反而不是重点。

---

## 开两个 Terminal

Terminal A：

```bash
mysql -u root -p
```

Terminal B：

```bash
mysql -u root -p
```

这两个连接：

```text
Session A

Session B
```

是两个独立数据库会话。

---

## Terminal A

```sql
START TRANSACTION;

UPDATE ...
```

不提交。

---

## Terminal B

```sql
SELECT ...
```

观察数据。

---

再回 A：

```sql
COMMIT;
```

或者：

```sql
ROLLBACK;
```

然后 B 再查询。

---

## 今天掌握

```text
ACID
```

以及：

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

理解：

```text
脏读
不可重复读
幻读
```

---

## SQLTools

主要用于：

```text
准备测试数据
查看表内容
保存实验 SQL
```

---

# Day 12
# VIEW + Procedure + Function + Trigger

重点顺序：

```text
VIEW
>
Procedure
>
Trigger
>
Function
```

实际开发阶段 VIEW 比后几个更值得优先掌握。

---

## VIEW

```sql
CREATE VIEW student_course_view AS
SELECT
    s.name,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.id = e.student_id
JOIN courses AS c
    ON c.id = e.course_id;
```

查询：

```sql
SELECT *
FROM student_course_view;
```

---

## 双修方式

Terminal：

```sql
SHOW FULL TABLES;
```

SQLTools：

```text
CREATE VIEW
CREATE PROCEDURE
CREATE TRIGGER
```

因为过程和触发器代码较长，更适合编辑器。

---

# Day 13
# User + Permission + Backup + Restore

这一天 Terminal 是主角。

---

## 用户

连接 root：

```bash
mysql -u root -p
```

学习：

```sql
CREATE USER;

GRANT;

REVOKE;

SHOW GRANTS;
```

理解：

```text
root
```

不应该成为普通程序日常使用账号。

---

# Backup

Terminal：

```bash
mysqldump -u root -p study_mysql > study_mysql.sql
```

查看文件：

```bash
ls
```

可以：

```bash
less study_mysql.sql
```

或者：

```bash
head study_mysql.sql
```

理解里面为什么有：

```text
CREATE TABLE
INSERT INTO
```

---

# Restore

先 SQLTools 或 Terminal：

```sql
CREATE DATABASE study_mysql_restore;
```

Terminal：

```bash
mysql -u root -p study_mysql_restore < study_mysql.sql
```

然后：

```bash
mysql -u root -p
```

```sql
USE study_mysql_restore;

SHOW TABLES;

SELECT * FROM students;
```

---

# 执行 SQL 文件

这一天还要学习：

```bash
mysql -u root -p study_mysql < day01.sql
```

以后你就知道：

```text
.sql 文件
```

不一定非得 SQLTools 执行。

Terminal 也能执行整个脚本。

---

# Day 14
# 最终综合项目

项目：

# CampusDB

从零开始。

---

## Part 1：Terminal 建库

必须 Terminal：

```bash
mysql -u root -p
```

```sql
CREATE DATABASE campus_db;
```

---

## Part 2：SQLTools 建表

建立：

```text
departments
teachers
students
courses
enrollments
```

---

## Part 3：SQLTools 创建数据

至少：

```text
departments      3
teachers        10
students        30
courses         15
enrollments    100
```

---

## Part 4：查询

完成：

1. 查询所有学生
2. 查询 2026 年学生
3. 查询最高学分课程
4. 统计学生人数
5. 每届学生人数
6. 平均课程学分
7. 每个学生选的课程
8. 每门课程有哪些学生
9. 没有选课的学生
10. 选三门以上课程的学生
11. 每门课程平均成绩
12. 高于平均成绩的学生
13. 子查询
14. EXISTS
15. CTE
16. 三表 JOIN
17. LEFT JOIN
18. GROUP BY
19. HAVING
20. LIMIT

---

## Part 5：Index

执行：

```sql
EXPLAIN ...
```

建立索引：

```sql
CREATE INDEX ...
```

再次：

```sql
EXPLAIN ...
```

自己说明：

> 为什么这个字段值得建立索引？

---

## Part 6：事务

两个 Terminal 同时打开。

模拟：

```text
学生选课
```

或：

```text
修改成绩
```

完成：

```text
START TRANSACTION
UPDATE / INSERT
COMMIT
ROLLBACK
```

---

## Part 7：备份

Terminal：

```bash
mysqldump -u root -p campus_db > campus_db.sql
```

---

## Part 8：恢复

创建：

```text
campus_db_restore
```

然后：

```bash
mysql -u root -p campus_db_restore < campus_db.sql
```

验证：

```text
表
数据
外键
索引
```

全部正常。

---

# 八、每天的 Terminal 必做清单

不管当天学什么，每天最少碰 Terminal 15～30 分钟。

固定训练：

```bash
mysql -u root -p
```

然后随机执行：

```sql
SHOW DATABASES;

USE study_mysql;

SHOW TABLES;

DESC students;

SELECT DATABASE();

SELECT VERSION();
```

结束：

```sql
exit;
```

两周之后：

```bash
mysql -u root -p
```

应该跟你输入：

```bash
cd
ls
git status
```

一样自然。

---

# 九、每天 SQLTools 必做清单

每一天必须产生：

```text
dayXX.sql
```

例如：

```sql
-- =================================
-- Day 06 JOIN
-- =================================


-- 1. INNER JOIN


-- 2. LEFT JOIN


-- 3. 学生选课


-- 4. 没有选课的学生


-- 5. 今日独立练习
```

要求：

> 重要 SQL 不要执行完就没了。

保存下来。

---

# 十、Terminal 与 SQLTools 最终应该达到的区别

最终应该做到：

## Terminal

你能独立：

```text
启动数据库
停止数据库
连接数据库
进入数据库
检查数据库
执行SQL
执行SQL文件
开多个Session
做事务实验
创建用户
检查权限
备份
恢复
排查连接
```

---

## SQLTools

你能独立：

```text
创建连接
选择Active Connection
创建.sql
执行整份SQL
执行选中SQL
建库
建表
CRUD
JOIN
子查询
CTE
GROUP BY
VIEW
INDEX
EXPLAIN
```

---

# 十一、工具切换训练法

这是我特别建议你执行的方法。

每天最后找一道 SQL。

例如：

```sql
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name;
```

先在：

```text
SQLTools
```

运行成功。

然后打开：

```bash
mysql -u root -p
```

进入：

```sql
USE study_mysql;
```

再执行同一条 SQL。

然后问自己：

> 两边执行的 SQL 有区别吗？

答案：

```text
没有。
```

只有工具不同。

这一点练 14 天后，你对数据库工具就不会产生依赖。

---

# 十二、终端额外训练

学习过程中顺便熟悉：

```bash
mysql --version
```

```bash
which mysql
```

```bash
brew services list
```

```bash
mysql -u root -p
```

```bash
mysqldump --version
```

```bash
mysqldump -u root -p database > backup.sql
```

```bash
mysql -u root -p database < backup.sql
```

以及 shell 的：

```bash
ls
pwd
cd
mkdir
cp
mv
rm
cat
less
head
tail
```

这些不是 MySQL 本身。

但数据库开发离不开这些基本终端能力。

---

# 十三、两周内暂时不要过度研究

不要现在深入：

```text
主从复制
Group Replication
InnoDB Cluster
高可用
分库分表
读写分离
redo log源码
undo log源码
Buffer Pool源码
Performance Schema深度调优
MySQL源码
```

可以知道名字。

暂时不要研究。

两周核心是：

```text
SQL
+
数据库设计
+
索引
+
事务
+
Terminal
+
SQLTools
```

---

# 十四、14 天重要程度

如果时间不够，按照：

```text
★★★★★ Day 4 SELECT

★★★★★ Day 6 JOIN

★★★★★ Day 7 综合练习

★★★★★ Day 10 Index + EXPLAIN

★★★★★ Day 11 Transaction

★★★★☆ Day 9 数据库设计

★★★★☆ Day 8 Subquery / CTE

★★★★☆ Day 13 Backup / Restore

★★★☆☆ Day 12 Procedure / Trigger
```

绝对不要为了学 Trigger，把 JOIN 搞得半懂不懂。

---

# 十五、真正判断自己会不会 MySQL

不是：

> 我知道 SELECT 是查询。

而是看到：

> 找出每个学院平均成绩最高的三门课程。

你能开始思考：

```text
需要哪些表？
↓
JOIN关系是什么？
↓
WHERE是否需要？
↓
GROUP BY什么？
↓
需要AVG吗？
↓
子查询还是CTE？
↓
有没有索引可以利用？
```

这才是真正开始会数据库。

---

# 十六、最终能力地图

```text
Mac
│
├── Homebrew
│   └── MySQL Server
│
├── Terminal
│   │
│   ├── brew services
│   ├── mysql client
│   ├── Session
│   ├── transaction
│   ├── user
│   ├── mysqldump
│   └── restore
│
└── VS Code
    │
    └── SQLTools
        │
        ├── .sql
        ├── DDL
        ├── DML
        ├── SELECT
        ├── JOIN
        ├── GROUP BY
        ├── Subquery
        ├── CTE
        ├── Index
        └── EXPLAIN
```

最终目标不是让：

```text
Terminal
```

取代：

```text
SQLTools
```

也不是 SQLTools 取代 Terminal。

而是形成：

```text
日常开发
→ VS Code + SQLTools

数据库管理 / 调试 / 运维
→ Terminal

SQL能力
→ 两边通用
```

这才是最适合开发者的 MySQL 使用方式。