# Day 02：Table + Data Type + Constraint

> MySQL 14 天系统学习计划  
> 今日主题：**表（Table）+ 数据类型（Data Type）+ 约束（Constraint）**  
> 环境：macOS + MySQL 8.4 + Terminal + VS Code + SQLTools

---

# 1. 今天的学习目标

今天主要掌握：

- Database / Table / Row / Column
- 常用数据类型：`INT`、`BIGINT`、`DECIMAL`、`CHAR`、`VARCHAR`、`TEXT`、`DATE`、`DATETIME`、`TIMESTAMP`
- 常用约束：`PRIMARY KEY`、`AUTO_INCREMENT`、`NOT NULL`、`UNIQUE`、`DEFAULT`、`CHECK`
- 使用 Terminal 建临时表并检查表结构
- 使用 SQLTools 正式创建 `students`、`courses`、`teachers`

---

# 2. Database → Table → Row → Column

数据库结构：

```text
Database
   ↓
Table
   ↓
Row
   ↓
Column
```

以 `study_mysql` 为例：

```text
study_mysql
│
├── students
├── courses
└── teachers
```

- `study_mysql`：Database，数据库
- `students`：Table，表
- 一名学生的一整条记录：Row，行
- `id`、`student_no`、`name`：Column，列 / 字段

---

# 3. 数据类型 Data Type

数据类型决定：

> 这一列可以存什么类型的数据？

## 3.1 INT

```sql
INT
```

用于普通整数，例如：

```sql
enroll_year INT
capacity INT
```

---

## 3.2 BIGINT

```sql
BIGINT
```

也是整数类型，但可以表示比 `INT` 更大的整数。

```text
INT
→ 普通整数

BIGINT
→ 更大的整数
```

---

## 3.3 DECIMAL

```sql
DECIMAL(M, D)
```

其中：

```text
M → 总数字位数
D → 小数位数
```

例如：

```sql
credits DECIMAL(3,1)
```

表示：

- 最多 3 位数字
- 小数点后 1 位

可以存：

```text
3.0
3.5
12.5
99.9
```

不能存：

```text
100.0
```

因为 `100.0` 一共有 4 位数字。

---

## 3.4 VARCHAR

```sql
VARCHAR(50)
```

表示：

> 最大 50 个字符的可变长度字符串。

注意：不是“可变字符常量”。

适合：

- 姓名
- 学号
- 教师编号
- 课程编号
- 邮箱

---

## 3.5 CHAR

```sql
CHAR(10)
```

适合长度比较固定的数据。

```text
CHAR(n)
→ 固定长度字符串类型，更适合长度固定的数据

VARCHAR(n)
→ 可变长度字符串，最多 n 个字符
```

不要简单理解为 `CHAR(10)` 必须手动输入刚好 10 个字符。

---

## 3.6 TEXT

```sql
TEXT
```

适合保存较长文本，例如：

```sql
description TEXT
```

常见用途：

- 课程介绍
- 文章正文
- 长备注

---

# 4. 日期和时间类型

## 4.1 DATE

```sql
DATE
```

只保存日期，例如：

```text
2026-09-05
```

适合：

```sql
birthday DATE
publish_date DATE
```

## 4.2 DATETIME

```sql
DATETIME
```

保存日期 + 时间：

```text
2026-09-05 12:30:00
```

## 4.3 TIMESTAMP

```sql
TIMESTAMP
```

也保存日期和时间，目前先形成开发直觉：

```text
DATE
→ 只需要日期

DATETIME
→ 明确的日期 + 时间

TIMESTAMP
→ 常用于 created_at、updated_at 等记录时间
```

例如：

```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

表示插入数据时，如果没有提供 `created_at`，默认使用当前时间。

---

# 5. Constraint：约束

约束决定：

> 数据除了类型正确以外，还必须遵守什么规则？

## 5.1 PRIMARY KEY

```sql
PRIMARY KEY
```

主键用于唯一标识表中的一行数据。

特点：

- 唯一
- 不能为 `NULL`

例如：

```sql
id INT PRIMARY KEY
```

---

## 5.2 AUTO_INCREMENT

```sql
AUTO_INCREMENT
```

表示自动递增编号。

例如：

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

MySQL 可以自动生成：

```text
1
2
3
4
...
```

区别：

```text
PRIMARY KEY
→ 唯一标识

AUTO_INCREMENT
→ 自动编号
```

---

## 5.3 NOT NULL

```sql
NOT NULL
```

表示不允许为 `NULL`。

例如：

```sql
name VARCHAR(50) NOT NULL
```

`NULL` 不是空字符串 `''`，也不是数字 `0`，它表示“没有值 / 未知值”。

---

## 5.4 UNIQUE

```sql
UNIQUE
```

表示非 `NULL` 值不能重复。

例如：

```sql
student_no VARCHAR(20) NOT NULL UNIQUE
```

说明：

- 学号不能为空
- 学号不能重复

---

## 5.5 DEFAULT

```sql
DEFAULT
```

表示插入数据时，如果不提供这个字段，就使用默认值。

例如：

```sql
capacity INT DEFAULT 50
```

如果没有提供 `capacity`：

```text
→ 自动使用 50
```

再例如：

```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

如果没有提供创建时间：

```text
→ 自动使用当前时间
```

非常重要：

```text
DEFAULT ≠ NOT NULL
```

如果要求绝对不能为空：

```sql
capacity INT NOT NULL DEFAULT 50
```

---

## 5.6 CHECK

```sql
CHECK
```

表示数据必须满足指定条件。

例如：

```sql
credits DECIMAL(3,1) CHECK (credits > 0)
```

表示学分必须大于 0。

---

# 6. 常见约束对比

```text
NOT NULL
→ 不能没有值

UNIQUE
→ 非 NULL 值不能重复

DEFAULT
→ 没有提供值时使用默认值

CHECK
→ 值必须满足某个条件
```

---

# 7. PRIMARY KEY 与业务编号

例如老师：

```text
id = 17
teacher_no = T2026008
```

```text
id
→ 数据库内部主键

teacher_no
→ 业务系统中的教师编号
```

同理：

```text
student_no
→ 学号

teacher_no
→ 教师编号

course_code
→ 课程编号
```

其中 `no` 通常表示 `number`。

---

# 8. Terminal 实验

进入 MySQL：

```bash
mysql -u root -p
```

切换数据库：

```sql
USE study_mysql;
```

确认当前数据库：

```sql
SELECT DATABASE();
```

建立临时表：

```sql
CREATE TABLE terminal_students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL
);
```

查看当前表：

```sql
SHOW TABLES;
```

查看表结构：

```sql
DESC terminal_students;
```

`DESC` 常见字段：

```text
Field   → 字段名
Type    → 数据类型
Null    → 是否允许 NULL
Key     → 键 / 索引信息
Default → 默认值
Extra   → 额外属性
```

查看完整建表语句：

```sql
SHOW CREATE TABLE terminal_students;
```

Terminal 中结果太宽时可以：

```sql
SHOW CREATE TABLE terminal_students\G
```

`\G` 会把结果改成竖向显示。

删除临时表：

```sql
DROP TABLE terminal_students;
```

---

# 9. SQLTools：students 表

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

字段含义：

```text
id
→ 整数 / 主键 / 自动编号

student_no
→ 学号 / 必填 / 唯一

name
→ 姓名 / 必填

email
→ 邮箱 / 可以为空 / 非 NULL 时唯一

enroll_year
→ 入学年份 / INT / 必填

created_at
→ 创建时间 / 默认当前时间
```

检查：

```sql
DESC students;
```

---

# 10. SQLTools：courses 表

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

重点观察：

```text
course_code
→ UNI

credits
→ decimal(3,1)

capacity
→ Default = 50

created_at
→ Default = CURRENT_TIMESTAMP
```

---

# 11. 独立完成 teachers 表

```sql
CREATE TABLE teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_no VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

检查：

```sql
DESC teachers;
```

完整查看：

```sql
SHOW CREATE TABLE teachers\G
```

MySQL 展开后会看到：

```text
PRIMARY KEY (`id`)
→ 主键

UNIQUE KEY `teacher_no`
→ teacher_no 唯一约束

UNIQUE KEY `email`
→ email 唯一约束
```

今天只需要知道：`UNIQUE` 在 MySQL 中会以唯一键 / 唯一索引的形式体现。索引原理 Day 10 再深入。

---

# 12. InnoDB / utf8mb4 / COLLATE

`SHOW CREATE TABLE` 还会看到：

```text
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci
```

目前只需要认识：

```text
InnoDB
→ MySQL 常用存储引擎

utf8mb4
→ 字符集

utf8mb4_0900_ai_ci
→ 字符比较 / 排序规则
```

---

# 13. MySQL Terminal 提示信息

执行：

```sql
USE study_mysql;
```

可能看到：

```text
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A
```

这不是报错，只是 MySQL 客户端在读取表和字段信息，用于命令补全。

---

# 14. 今天最终数据库状态

执行：

```sql
SHOW TABLES;
```

今天结束后应该有 3 张正式表：

```text
students
courses
teachers
```

临时表：

```text
terminal_students
```

已经通过：

```sql
DROP TABLE terminal_students;
```

删除。

---

# 15. 今天容易出错的地方

## VARCHAR 的正确说法

错误：

```text
可变字符常量
```

正确：

```text
可变长度字符串
```

## CHAR 不要理解得太死

更准确地记：

```text
CHAR(n)
→ 固定长度字符串类型，更适合长度固定的数据
```

## 每个普通字段都需要数据类型

错误：

```sql
id PRIMARY KEY AUTO_INCREMENT
```

正确：

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

## CHECK 拼写

正确：

```sql
CHECK
```

不是：

```sql
CHICK
```

---

# 16. 综合示例：books

```sql
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(5,2) CHECK (price > 0),
    publish_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

# 17. Day 02 复习清单

应该能独立解释：

```text
Database
Table
Row
Column

INT
BIGINT
DECIMAL
CHAR
VARCHAR
TEXT
DATE
DATETIME
TIMESTAMP

PRIMARY KEY
AUTO_INCREMENT
NOT NULL
UNIQUE
DEFAULT
CHECK
```

还应该会：

```sql
SHOW TABLES;
DESC students;
SHOW CREATE TABLE teachers\G
```

---

# 18. Day 02 核心总结

今天最重要的三个思想：

## ① 数据类型

决定：

> 这一列可以存什么？

## ② 约束

决定：

> 存进去的数据还必须遵守什么规则？

## ③ SQL 才是核心

```text
Terminal
和
SQLTools
```

只是两种不同的客户端工具。

最终目标：

```text
日常写 SQL
→ SQLTools

数据库检查 / 调试
→ Terminal

SQL 能力
→ 两边通用
```

---

# Day 02 完成

当前数据库：

```text
study_mysql
│
├── students
├── courses
└── teachers
```

下一天：

```text
Day 03
INSERT / UPDATE / DELETE
```

开始真正向表中写入、修改和删除数据。
