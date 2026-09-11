# MySQL Day 07 学习笔记
## 第一周综合考试

日期：2026-09-11  
数据库：`week1_test`  
环境：macOS + Terminal + VS Code + SQLTools

---

# 一、今日目标

Day 7 主要用于第一周综合验收，基本不学习新知识。

今天重点复习并串联：

- Terminal 基础操作
- 建库、建表
- INSERT / UPDATE / DELETE / SELECT
- 主键、唯一约束、外键
- 多对多关系
- INNER JOIN
- LEFT JOIN
- GROUP BY
- COUNT / AVG
- HAVING
- ORDER BY
- LIMIT

---

# 二、Terminal 综合练习

## 1. 创建考试数据库

```sql
CREATE DATABASE week1_test
CHARACTER SET utf8mb4;
```

验证：

```sql
SHOW DATABASES;
```

切换数据库：

```sql
USE week1_test;
```

确认当前数据库：

```sql
SELECT DATABASE();
```

---

## 2. 创建 students 表

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

查看结构：

```sql
DESC students;
```

---

# 三、CRUD 综合复习

## 1. INSERT

插入学生：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260001', '张三', 'zhang@example.com', 2026),
('20260002', '李四', 'li@example.com', 2026),
('20250003', '王五', 'wang@example.com', 2025);
```

验证：

```sql
SELECT * FROM students;
```

---

## 2. UPDATE

修改前先查询：

```sql
SELECT *
FROM students
WHERE student_no = '20260002';
```

修改：

```sql
UPDATE students
SET email = 'lisi@example.com'
WHERE student_no = '20260002';
```

修改后验证：

```sql
SELECT *
FROM students
WHERE student_no = '20260002';
```

### 安全习惯

UPDATE 前：

```text
先 SELECT
↓
确认 WHERE 命中的记录
↓
再 UPDATE
↓
最后再次 SELECT 验证
```

---

## 3. DELETE

删除前先查询：

```sql
SELECT *
FROM students
WHERE student_no = '20250003';
```

删除：

```sql
DELETE FROM students
WHERE student_no = '20250003';
```

删除后验证：

```sql
SELECT * FROM students;
```

### 安全习惯

DELETE 前：

```text
先 SELECT
↓
确认 WHERE 条件
↓
再 DELETE
↓
最后查询验证
```

---

# 四、SQLTools 建表综合练习

## teachers

```sql
CREATE TABLE teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_no VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## courses

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

## enrollments

```sql
CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    score DECIMAL(5,2),

    CONSTRAINT fk_enrollments_student
    FOREIGN KEY (student_id)
    REFERENCES students(id),

    CONSTRAINT fk_enrollments_course
    FOREIGN KEY (course_id)
    REFERENCES courses(id),

    CONSTRAINT uq_enrollments_student_course
    UNIQUE (student_id, course_id)
);
```

验证：

```sql
SHOW TABLES;
```

最终：

```text
courses
enrollments
students
teachers
```

---

# 五、CONSTRAINT 的理解

写法：

```sql
CONSTRAINT 约束名 约束规则
```

例如：

```sql
CONSTRAINT fk_enrollments_student
FOREIGN KEY (student_id)
REFERENCES students(id)
```

表示给这个外键约束起名：

```text
fk_enrollments_student
```

`CONSTRAINT` 不是必须写。

不写：

```sql
FOREIGN KEY (student_id)
REFERENCES students(id)
```

MySQL 也可以创建外键，只是约束名由 MySQL 自动生成。

显式命名的优点：

- 结构更清晰
- 后续查看约束更方便
- 删除约束时更容易定位

---

# 六、准备 JOIN 测试数据

## 插入课程

```sql
INSERT INTO courses
(course_code, course_name, credits)
VALUES
('C001', 'C语言程序设计', 4.0),
('C002', '数据库原理', 3.5),
('C003', '计算机网络', 3.0);
```

因为：

```sql
capacity INT DEFAULT 50
```

所以不写 `capacity` 时自动使用默认值 50。

---

## 插入选课记录

今天尝试了把子查询直接作为 INSERT 的值：

```sql
INSERT INTO enrollments (student_id, course_id, score)
VALUES
(
    (SELECT id FROM students WHERE name = '张三'),
    (SELECT id FROM courses WHERE course_code = 'C001'),
    90.0
),
(
    (SELECT id FROM students WHERE name = '张三'),
    (SELECT id FROM courses WHERE course_code = 'C002'),
    85.0
),
(
    (SELECT id FROM students WHERE name = '李四'),
    (SELECT id FROM courses WHERE course_code = 'C001'),
    88.0
);
```

当前数据中可以正常执行。

### 注意

`name` 不是 UNIQUE。

如果以后存在两个同名学生：

```text
张三
张三
```

那么：

```sql
SELECT id FROM students WHERE name = '张三';
```

可能返回多行。

更稳妥的是使用：

```sql
student_no
```

因为：

```sql
student_no VARCHAR(20) NOT NULL UNIQUE
```

---

# 七、INNER JOIN 三表查询

目标：

```text
学生姓名 | 课程名称 | 成绩
```

SQL：

```sql
SELECT
    s.name,
    c.course_name,
    e.score
FROM enrollments e
JOIN students s
    ON e.student_id = s.id
JOIN courses c
    ON e.course_id = c.id;
```

结果：

```text
张三 | C语言程序设计 | 90.00
张三 | 数据库原理    | 85.00
李四 | C语言程序设计 | 88.00
```

### 理解

```sql
JOIN
```

默认就是：

```sql
INNER JOIN
```

INNER JOIN：

> 只保留两边都能匹配上的记录。

---

# 八、LEFT JOIN

题目：

> 显示所有课程，以及选择这些课程的学生。

SQL：

```sql
SELECT
    c.course_name,
    s.name
FROM courses c
LEFT JOIN enrollments e
    ON c.id = e.course_id
LEFT JOIN students s
    ON e.student_id = s.id;
```

结果：

```text
C语言程序设计 | 张三
C语言程序设计 | 李四
数据库原理    | 张三
计算机网络    | NULL
```

### 核心理解

LEFT JOIN：

> 保留左表全部记录。

如果右表没有符合连接条件的数据：

```text
右表字段 → NULL
```

本题要求保留所有课程，因此：

```text
courses
```

应该放左边。

---

# 九、GROUP BY + COUNT

题目：

> 统计每个学生选了几门课程。

SQL：

```sql
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e
    ON s.id = e.student_id
GROUP BY s.id, s.name;
```

结果：

```text
张三 | 2
李四 | 1
```

### 为什么需要 GROUP BY

因为需要：

> 分别统计每个学生的选课数量。

所以：

```text
先按学生分组
↓
再对每组 COUNT
```

### 为什么推荐

```sql
GROUP BY s.id, s.name
```

而不是：

```sql
GROUP BY s.name
```

因为以后可能存在同名学生。

`id` 是唯一的，更稳妥。

---

# 十、COUNT(*) 与 COUNT(字段)

区别：

```text
COUNT(*)      → 统计行数
COUNT(字段)   → 只统计该字段非 NULL 的值
```

在：

```sql
students
LEFT JOIN enrollments
```

场景中，如果学生没有选课：

```text
e.course_id = NULL
```

此时：

```sql
COUNT(*)
```

仍然可能得到：

```text
1
```

而：

```sql
COUNT(e.course_id)
```

得到：

```text
0
```

所以统计所有学生选课数量时：

```sql
COUNT(e.course_id)
```

更合适。

---

# 十一、AVG + GROUP BY + HAVING + ORDER BY

题目：

> 查询平均成绩至少 87 分的学生，并按平均成绩从高到低排序。

SQL：

```sql
SELECT
    s.name,
    AVG(e.score) AS average_score
FROM students s
INNER JOIN enrollments e
    ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING average_score >= 87
ORDER BY average_score DESC;
```

结果：

```text
李四 | 88.000000
张三 | 87.500000
```

### 为什么使用 INNER JOIN

因为题目是在统计：

```text
有成绩记录的学生
```

没有选课：

```text
没有 score
```

因此无需保留。

### 为什么使用 HAVING

因为：

```sql
AVG(e.score)
```

是聚合结果。

WHERE：

> 分组前筛选行。

HAVING：

> 分组后筛选分组。

因此：

```sql
HAVING AVG(e.score) >= 87
```

才符合逻辑。

---

# 十二、SQL 逻辑执行顺序复习

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

注意：

SQL 的书写顺序和逻辑执行顺序不同。

---

# 十三、COUNT + GROUP BY + ORDER BY + LIMIT

题目：

> 查询选课数量最多的学生，只显示第 1 名。

SQL：

```sql
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e
    ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY course_count DESC
LIMIT 1;
```

结果：

```text
张三 | 2
```

这里综合使用：

```text
JOIN
COUNT
GROUP BY
ORDER BY
LIMIT
```

---

# 十四、最终综合题

题目：

> 查询每门已被选择课程的平均成绩，只显示平均成绩至少 88 分的课程，并按平均成绩从高到低排序。

SQL：

```sql
SELECT
    c.course_name,
    AVG(e.score) AS average_score
FROM courses c
INNER JOIN enrollments e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING average_score >= 88
ORDER BY average_score DESC;
```

结果：

```text
C语言程序设计 | 89.000000
```

计算：

```text
C语言程序设计：
(90 + 88) / 2 = 89
```

数据库原理：

```text
85
```

没有达到 88。

计算机网络：

```text
没有选课记录
```

INNER JOIN 后不会参与统计。

---

# 十五、今天出现的错误与修正

## 1. INSERT 拼写错误

错误：

```sql
ISERT INTO students
```

正确：

```sql
INSERT INTO students
```

---

## 2. VALUES 中漏逗号

错误：

```sql
'wang@example.com' 2025
```

正确：

```sql
'wang@example.com', 2025
```

---

## 3. 数据编号看错

题目要求：

```text
20250001
```

实际输入：

```text
20250003
```

SQL 本身没有问题，但需要提高输入数据时的核对习惯。

---

## 4. 表名单复数错误

错误：

```sql
SELECT * FROM student;
```

正确：

```sql
SELECT * FROM students;
```

MySQL 报错：

```text
Table 'week1_test.student' doesn't exist
```

看到报错后能够自行定位并修正。

---

## 5. 忘记 ORDER BY

最初完成平均成绩查询时，已经完成：

```text
GROUP BY
HAVING
```

但漏了题目要求：

```text
按平均成绩降序
```

补充：

```sql
ORDER BY average_score DESC;
```

后完整通过。

---

# 十六、今天最重要的理解

## 1. INNER JOIN

```text
只保留符合连接条件的数据
```

适合：

```text
查询已有成绩的学生
统计已有选课记录的课程平均分
```

---

## 2. LEFT JOIN

```text
保留左侧表所有记录
```

适合：

```text
统计所有学生的选课数量
显示所有课程，包括无人选择的课程
```

---

## 3. WHERE 与 HAVING

```text
WHERE  → 分组前筛选行
HAVING → 分组后筛选分组
```

聚合函数条件：

```sql
AVG(...)
COUNT(...)
SUM(...)
```

通常需要在分组后使用：

```sql
HAVING
```

---

## 4. GROUP BY

需要：

```text
每个学生
每门课程
每个年份
```

分别统计时，就要考虑 GROUP BY。

---

## 5. COUNT

```text
COUNT(*)        → 行
COUNT(column)   → column 非 NULL 值
```

LEFT JOIN 场景下尤其要注意。

---

# 十七、Day 7 最终口头验收

## Q1：INNER JOIN 和 LEFT JOIN 的区别

回答：

```text
LEFT JOIN 会保留左侧表不符合连接条件的数据。
INNER JOIN 必须符合连接条件。
```

实际场景：

```text
INNER JOIN：
查询已有成绩的学生。

LEFT JOIN：
统计所有学生的选课数量。
```

通过。

---

## Q2：WHERE 和 HAVING 的区别

回答：

```text
WHERE 在未分组前筛选行。
HAVING 在分组后筛选符合条件的分组。
```

为什么 AVG 要用 HAVING：

```text
因为 AVG 是分组后使用的聚合函数。
```

通过。

---

## Q3：COUNT(*) 和 COUNT(字段)

回答：

```text
COUNT(*) 会统计行。
COUNT(字段) 只统计非 NULL。
```

在 LEFT JOIN 中：

```text
如果 e.course_id 为 NULL，
COUNT(*) 仍可能 +1，
COUNT(e.course_id) 不会。
```

通过。

---

# 十八、Day 7 最终结论

## 今日状态

```text
Day 7：通过 ✅
```

今天已经完成第一周综合验收：

```text
Terminal CRUD        ✅
建表与约束           ✅
外键                 ✅
多对多               ✅
INNER JOIN           ✅
LEFT JOIN            ✅
GROUP BY             ✅
COUNT / AVG          ✅
HAVING               ✅
ORDER BY              ✅
LIMIT                 ✅
综合查询             ✅
口头验收             ✅
```

目前主要需要继续提高的是：

```text
SQL 输入细节
字段 / 表名拼写
数据编号核对
题目条件完整性
```

不是主要知识点理解问题。

---

# 十九、week1_test

原计划 Day 7 最后可以删除：

```sql
DROP DATABASE week1_test;
```

今天选择：

```text
保留 week1_test
```

作为以后复习：

```text
CRUD
JOIN
GROUP BY
HAVING
```

的练习数据库。

---

# 二十、下一步

Day 8：

```text
Subquery
EXISTS
CTE
```

第一周综合考试结束。
