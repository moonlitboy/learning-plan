# MySQL Day 03 学习笔记
## INSERT / UPDATE / DELETE

> 学习环境：macOS + MySQL 8.4 + Terminal + VS Code + SQLTools  
> 今日目标：掌握 CRUD 中的数据增、查、改、删，并养成 UPDATE / DELETE 前先 SELECT 确认范围的习惯。

---

# 一、今日学习目标

今天主要学习：

```text
CRUD
```

CRUD 是数据库中最基础的四种数据操作：

```text
C = Create  → INSERT
R = Read    → SELECT
U = Update  → UPDATE
D = Delete  → DELETE
```

可以直接记成：

```text
增 → INSERT
查 → SELECT
改 → UPDATE
删 → DELETE
```

今天实际使用到的三张表：

```text
students
teachers
courses
```

今日数据准备目标：

```text
students >= 15
teachers >= 5
courses  >= 8
```

---

# 二、INSERT：插入数据

## 1. 单行 INSERT

基本语法：

```sql
INSERT INTO 表名
(字段1, 字段2, 字段3)
VALUES
(值1, 值2, 值3);
```

今天在 Terminal 中插入第一名学生：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260001', '张三', 'zhang@example.com', 2026);
```

插入成功后：

```sql
SELECT * FROM students;
```

结果中自动生成：

```text
id
created_at
```

原因：

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

`id` 会自动递增。

而：

```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

会自动使用当前时间。

---

## 2. 批量 INSERT

SQLTools 中一次插入多条学生数据：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260002', '李四', 'li@example.com', 2026),
('20260003', '王五', 'wang@example.com', 2025),
('20260004', '赵六', 'zhao@example.com', 2025),
('20260005', '陈晨', 'chen@example.com', 2024),
('20260006', '刘洋', 'liu@example.com', 2026);
```

批量 INSERT 的特点：

```text
一个 INSERT
+
一个 VALUES
+
多组 (...)
```

适合：

```text
初始化测试数据
一次插入多条记录
准备开发数据
```

---

# 三、NULL 数据

今天继续补学生数据时，故意加入了空邮箱：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260007', '张伟', 'zhangwei@example.com', 2024),
('20260008', '孙悦', 'sun@example.com', 2025),
('20260009', '周杰', NULL, 2026),
('20260010', '吴桐', 'wu@example.com', 2024),
('20260011', '郑凯', 'zheng@example.com', 2025),
('20260012', '张敏', 'zhangmin@example.com', 2026),
('20260013', '冯雪', NULL, 2025),
('20260014', '何宇', 'he@example.com', 2024),
('20260015', '高峰', 'gao@example.com', 2026);
```

因为 `email` 字段没有：

```sql
NOT NULL
```

所以允许：

```sql
NULL
```

这些数据以后可以用于练习：

```sql
WHERE email IS NULL;
```

以及：

```sql
WHERE email IS NOT NULL;
```

---

# 四、统计数据行数

今天第一次使用：

```sql
SELECT COUNT(*) FROM students;
```

结果：

```text
15
```

教师：

```sql
SELECT COUNT(*) FROM teachers;
```

结果：

```text
5
```

课程：

```sql
SELECT COUNT(*) FROM courses;
```

结果：

```text
8
```

---

# 五、teachers 数据

今天插入了 5 位教师：

```sql
INSERT INTO teachers
(teacher_no, name, email)
VALUES
('T001', '李明', 'liming@school.com'),
('T002', '王芳', 'wangfang@school.com'),
('T003', '张强', 'zhangqiang@school.com'),
('T004', '陈静', 'chenjing@school.com'),
('T005', '刘伟', 'liuwei@school.com');
```

验证：

```sql
SELECT COUNT(*) FROM teachers;
```

---

# 六、courses 数据

今天插入了 8 门课程：

```sql
INSERT INTO courses
(course_code, course_name, credits, capacity)
VALUES
('C001', 'C语言程序设计', 4.0, 60),
('C002', '数据结构', 4.0, 50),
('C003', '计算机网络', 3.5, 50),
('C004', '数据库原理', 3.0, 45),
('C005', '操作系统', 4.0, 50),
('C006', 'Java程序设计', 3.5, 60),
('C007', 'Web前端开发', 2.5, 40),
('C008', 'Linux基础', 2.0, 40);
```

验证：

```sql
SELECT COUNT(*) FROM courses;
```

结果：

```text
8
```

---

# 七、UPDATE：修改数据

## 1. 基本语法

```sql
UPDATE 表名
SET 字段 = 新值
WHERE 条件;
```

今天修改学生邮箱：

```sql
UPDATE students
SET email = 'new@example.com'
WHERE student_no = '20260001';
```

修改课程容量：

```sql
UPDATE courses
SET capacity = 45
WHERE course_code = 'C008';
```

---

## 2. UPDATE 安全习惯

修改之前必须先查询：

```sql
SELECT *
FROM courses
WHERE course_code = 'C008';
```

确认只命中目标数据后，再：

```sql
UPDATE courses
SET capacity = 45
WHERE course_code = 'C008';
```

修改后再验证：

```sql
SELECT *
FROM courses
WHERE course_code = 'C008';
```

推荐形成固定流程：

```text
SELECT + WHERE
↓
确认范围
↓
UPDATE + 相同 WHERE
↓
SELECT + 相同 WHERE
↓
验证结果
```

---

# 八、UPDATE 中遇到的错误

## 错误 1：字符串没有加单引号

错误：

```sql
SELECT *
FROM courses
WHERE course_code = C008;
```

报错：

```text
Unknown column 'C008' in 'where clause'
```

原因：

MySQL 把：

```text
C008
```

当成了字段名。

正确：

```sql
SELECT *
FROM courses
WHERE course_code = 'C008';
```

规则：

字符串通常加单引号：

```sql
WHERE course_code = 'C008';
WHERE name = '张三';
WHERE email = 'abc@example.com';
```

数字通常不加引号：

```sql
WHERE id = 1;
WHERE capacity = 40;
WHERE credits = 2.0;
```

---

## 错误 2：UPDATE 后错误地写 TABLE

错误：

```sql
UPDATE TABLE courses
SET capacity = 45
WHERE course_code = 'C008';
```

正确：

```sql
UPDATE courses
SET capacity = 45
WHERE course_code = 'C008';
```

需要记住：

```text
CREATE TABLE
DROP TABLE
ALTER TABLE
```

但是：

```text
UPDATE courses
DELETE FROM courses
SELECT ... FROM courses
```

`UPDATE` 后面直接跟表名，没有 `TABLE`。

---

# 九、Rows matched / Changed

UPDATE 成功后可能看到：

```text
Rows matched: 1
Changed: 1
Warnings: 0
```

含义：

```text
Rows matched: 1
```

WHERE 条件命中了 1 行。

```text
Changed: 1
```

这一行的数据实际发生了修改。

```text
Warnings: 0
```

没有警告。

如果再次把同一个值更新成相同值：

```sql
UPDATE students
SET email = 'new@example.com'
WHERE student_no = '20260001';
```

可能出现：

```text
Rows matched: 1
Changed: 0
```

说明：

```text
找到了 1 行
但数据没有实际变化
```

---

# 十、DELETE：删除数据

## 1. 基本语法

```sql
DELETE FROM 表名
WHERE 条件;
```

今天插入测试课程：

```sql
INSERT INTO courses
(course_code, course_name, credits, capacity)
VALUES
('TEST001', '测试课程', 1.0, 10);
```

删除之前先查询：

```sql
SELECT *
FROM courses
WHERE course_code = 'TEST001';
```

确认只查到测试课程后：

```sql
DELETE FROM courses
WHERE course_code = 'TEST001';
```

最后验证：

```sql
SELECT *
FROM courses
WHERE course_code = 'TEST001';
```

如果已经删除，应得到空结果。

---

# 十一、DELETE 的安全习惯

推荐固定流程：

```text
SELECT + WHERE
↓
确认 DELETE 会命中哪些数据
↓
DELETE + 相同 WHERE
↓
SELECT + 相同 WHERE
↓
验证数据已经不存在
```

例如：

```sql
SELECT *
FROM students
WHERE student_no = '20260010';
```

确认后：

```sql
DELETE FROM students
WHERE student_no = '20260010';
```

最后：

```sql
SELECT *
FROM students
WHERE student_no = '20260010';
```

---

# 十二、没有 WHERE 的危险

下面的语句：

```sql
DELETE FROM students;
```

不是删除 `students` 表。

它会：

```text
删除 students 表中的所有行数据
```

但是：

```text
表本身仍然存在
字段仍然存在
主键仍然存在
约束仍然存在
```

也就是：

```text
表还在
数据变成 0 行
```

真正删除整张表的是：

```sql
DROP TABLE students;
```

区别：

```text
DELETE FROM students;
→ 删除表中的所有数据，表还在

DROP TABLE students;
→ 表和数据一起删除
```

---

# 十三、AUTO_INCREMENT 不保证连续

今天测试时曾插入：

```text
id = 2
```

删除后再次插入，新的 id 通常不会重新使用 2。

例如：

```text
1
3
4
5
6
7
```

这是正常现象。

`AUTO_INCREMENT` 的主要作用是：

```text
自动生成递增主键
```

而不是保证：

```text
ID 永远连续
```

同样，课程测试数据：

```text
TEST001 → id = 9
```

删除后，下次新增课程通常会继续使用更大的 id，而不是重新填补 9。

---

# 十四、SQLTools 使用习惯

`day03.sql` 会保存今天所有 SQL。

但是已经执行过的 INSERT 不应该反复整份重新执行。

例如：

```text
student_no
teacher_no
course_code
email
```

其中很多字段有：

```sql
UNIQUE
```

如果再次执行相同 INSERT，可能发生重复值错误。

因此 SQLTools 中推荐：

```text
选中当前需要执行的 SQL
↓
Run Selected / Run on Active Connection
```

`.sql` 文件是：

```text
学习记录 + 可重复使用脚本
```

不代表每次必须从第一行执行到最后一行。

---

# 十五、Terminal 与 SQLTools 双修

今天两边都实际使用了 SQL。

## Terminal

完成：

```text
INSERT
SELECT
UPDATE
DELETE
```

适合：

```text
短 SQL
临时查询
快速实验
保持命令行手感
```

## SQLTools

完成：

```text
批量 INSERT
保存 day03.sql
准备正式测试数据
```

适合：

```text
较长 SQL
批量 SQL
保存脚本
日常开发
```

核心结论：

```text
SQL 本身没有区别
Terminal 和 SQLTools 只是不同的执行工具
```

---

# 十六、今日最终数据

今天结束时：

```text
students = 15
teachers = 5
courses  = 8
```

其中：

```text
students
```

包含多个不同入学年份、多个姓张学生，以及部分 `NULL` 邮箱。

这些数据会直接用于 Day 4 的 SELECT 查询练习。

---

# 十七、今日必须记住

## CRUD

```text
Create → INSERT
Read   → SELECT
Update → UPDATE
Delete → DELETE
```

## 字符串

```sql
'C008'
'张三'
'abc@example.com'
```

通常使用单引号。

## UPDATE

```sql
UPDATE 表名
SET 字段 = 值
WHERE 条件;
```

不是：

```sql
UPDATE TABLE 表名
```

## DELETE

```sql
DELETE FROM 表名
WHERE 条件;
```

## 安全习惯

```text
UPDATE 前先 SELECT
DELETE 前先 SELECT
```

并且：

```text
SELECT 和 UPDATE / DELETE 使用相同 WHERE
```

---

# 十八、Day 3 验收结果

今日验收通过。

已经能够解释：

```text
CRUD 是什么
字符串为什么需要单引号
UPDATE 为什么没有 TABLE
DELETE 不写 WHERE 为什么危险
DELETE FROM 与 DROP TABLE 的区别
```

已经能够独立完成：

```text
单行 INSERT
批量 INSERT
SELECT 验证
UPDATE
DELETE
COUNT(*)
Terminal 操作
SQLTools 操作
```

---

# 十九、Day 4 预告

下一天正式进入 SELECT 基础强化：

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

今天准备的 15 名学生、5 位教师和 8 门课程，将直接作为 Day 4 的查询数据。
