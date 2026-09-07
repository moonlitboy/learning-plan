# MySQL Day 04 — SELECT 基础查询

## 今日目标

今天重点彻底掌握 `SELECT` 基础查询，包括：

- `SELECT`
- `FROM`
- `WHERE`
- `AND`
- `OR`
- `NOT`
- `IN`
- `BETWEEN`
- `LIKE`
- `IS NULL`
- `IS NOT NULL`
- `DISTINCT`
- `ORDER BY`
- `LIMIT`

工具继续保持：

- Terminal：练短查询，保持 SQL 手感
- VS Code + SQLTools：完成正式 `day04.sql`

---

# 一、SELECT 与 FROM

最基本的查询：

```sql
SELECT *
FROM students;
```

含义：

- `SELECT`：决定查询哪些列
- `FROM`：决定从哪张表查询
- `*`：表示所有列

只查询指定列：

```sql
SELECT name
FROM students;
```

查询多列：

```sql
SELECT student_no, name, enroll_year
FROM students;
```

## 核心理解

```text
SELECT → 控制显示哪些列
FROM   → 指定从哪张表查询
```

---

# 二、WHERE 条件查询

`WHERE` 用来筛选行。

例如查询 2026 年入学的学生：

```sql
SELECT *
FROM students
WHERE enroll_year = 2026;
```

只显示部分字段：

```sql
SELECT student_no, name, enroll_year
FROM students
WHERE enroll_year = 2025;
```

按照学号查询：

```sql
SELECT *
FROM students
WHERE student_no = '20260012';
```

## 字符串和数字

`student_no` 是 `VARCHAR`：

```sql
WHERE student_no = '20260012'
```

需要单引号。

`enroll_year` 是 `INT`：

```sql
WHERE enroll_year = 2026
```

不需要单引号。

---

# 三、AND / OR / NOT

## 1. AND

`AND` 表示多个条件必须同时成立。

```sql
SELECT *
FROM students
WHERE enroll_year = 2026
AND name = '张敏';
```

意思：

```text
既是 2026 年入学
并且
姓名是张敏
```

---

## 2. OR

`OR` 表示多个条件满足其中一个即可。

```sql
SELECT name, enroll_year
FROM students
WHERE enroll_year = 2024
OR enroll_year = 2025;
```

---

## 3. NOT

`NOT` 表示条件取反。

```sql
SELECT name, enroll_year
FROM students
WHERE NOT enroll_year = 2026;
```

表示查询不是 2026 年入学的学生。

也可以使用：

```sql
WHERE enroll_year <> 2026;
```

或：

```sql
WHERE enroll_year != 2026;
```

---

# 四、语法错误和逻辑错误

例如：

```sql
WHERE enroll_year = 2025
AND enroll_year = 2026;
```

这条 SQL：

- 语法正确
- 逻辑条件无法同时成立
- 会正常执行
- 查询结果通常为 `Empty set`

因为同一行里的 `enroll_year` 不可能既等于 2025 又等于 2026。

## 重要区别

```text
语法错误
→ SQL 无法正常执行

逻辑条件无法成立
→ SQL 可以执行
→ 但结果可能是 Empty set
```

---

# 五、IN

`IN` 用来判断一个字段是否属于给定的一组值之一。

例如：

```sql
WHERE enroll_year = 2025
OR enroll_year = 2026
```

可以简写为：

```sql
WHERE enroll_year IN (2025, 2026);
```

查询 2025 或 2026 年入学的学生：

```sql
SELECT name, enroll_year
FROM students
WHERE enroll_year IN (2025, 2026);
```

字符串也可以使用 `IN`：

```sql
SELECT student_no, name
FROM students
WHERE name IN ('张三', '张伟', '张敏');
```

---

# 六、BETWEEN

`BETWEEN` 用来查询一个范围。

基本语法：

```sql
WHERE 字段 BETWEEN 最小值 AND 最大值;
```

例如查询学分在 2～4 之间的课程：

```sql
SELECT course_code, course_name, credits
FROM courses
WHERE credits BETWEEN 2 AND 4;
```

## BETWEEN 包含边界

```text
BETWEEN 2 AND 4
```

包含：

```text
2
4
```

大致等价于：

```sql
WHERE credits >= 2
AND credits <= 4;
```

## NOT BETWEEN

```sql
SELECT course_name, credits
FROM courses
WHERE credits NOT BETWEEN 2 AND 4;
```

表示查询学分不在 2～4 之间的课程。

今天当前 `courses` 表中的所有课程学分都在 2～4 之间，因此执行后返回：

```text
Empty set
```

这不是报错，只是没有符合条件的数据。

---

# 七、LIKE 模糊查询

`LIKE` 用于模糊匹配。

## 1. `%`

`%` 表示任意数量的字符。

查询所有姓张的学生：

```sql
SELECT student_no, name
FROM students
WHERE name LIKE '张%';
```

查询姓名以“敏”结尾的学生：

```sql
SELECT name
FROM students
WHERE name LIKE '%敏';
```

查询课程名中包含“程序”的课程：

```sql
SELECT course_code, course_name
FROM courses
WHERE course_name LIKE '%程序%';
```

---

## 2. `_`

`_` 表示恰好一个字符。

```sql
SELECT name
FROM students
WHERE name LIKE '张_';
```

表示：

```text
张 + 恰好一个字符
```

例如：

```text
张三   ✅
张伟   ✅
张敏   ✅
张小明 ❌
```

---

# 八、IS NULL / IS NOT NULL

`NULL` 不能使用普通的：

```sql
= NULL
```

或：

```sql
!= NULL
```

进行判断。

正确方式：

```sql
IS NULL
```

和：

```sql
IS NOT NULL
```

## 查询邮箱为空

```sql
SELECT student_no, name, email
FROM students
WHERE email IS NULL;
```

当前查到：

```text
周杰
冯雪
```

## 查询邮箱不为空

```sql
SELECT name, email
FROM students
WHERE email IS NOT NULL;
```

## 与 AND 组合

查询 2026 年入学且邮箱不为空的学生：

```sql
SELECT name, email, enroll_year
FROM students
WHERE enroll_year = 2026
AND email IS NOT NULL;
```

---

# 九、DISTINCT 去重

`DISTINCT` 用于去除重复查询结果。

原始查询：

```sql
SELECT enroll_year
FROM students;
```

会出现很多重复年份。

使用：

```sql
SELECT DISTINCT enroll_year
FROM students;
```

当前结果只有：

```text
2026
2025
2024
```

课程学分去重：

```sql
SELECT DISTINCT credits
FROM courses;
```

当前不同学分：

```text
4.0
3.5
3.0
2.5
2.0
```

## 注意

如果写：

```sql
SELECT DISTINCT name, enroll_year
FROM students;
```

`DISTINCT` 判断的是：

```text
name + enroll_year
```

这个整体组合是否重复。

---

# 十、ORDER BY 排序

`ORDER BY` 用于排序查询结果。

## ASC 升序

```sql
SELECT course_name, credits
FROM courses
ORDER BY credits ASC;
```

`ASC`：

```text
ascending
升序
数字：小 → 大
```

---

## DESC 降序

```sql
SELECT course_name, credits
FROM courses
ORDER BY credits DESC;
```

`DESC`：

```text
descending
降序
数字：大 → 小
```

---

## WHERE + ORDER BY

```sql
SELECT name, enroll_year
FROM students
WHERE enroll_year IN (2025, 2026)
ORDER BY enroll_year DESC;
```

---

## 多字段排序

```sql
SELECT course_name, credits, capacity
FROM courses
ORDER BY credits DESC, capacity DESC;
```

优先：

1. 按 `credits` 降序
2. 如果学分相同，再按 `capacity` 降序

---

# 十一、LIMIT

`LIMIT` 用于限制返回行数。

查询前 3 条：

```sql
SELECT *
FROM courses
LIMIT 3;
```

## ORDER BY + LIMIT

查询学分最高的 3 门课程：

```sql
SELECT course_name, credits
FROM courses
ORDER BY credits DESC
LIMIT 3;
```

逻辑：

```text
先排序
↓
再截取前 3 条
```

查询入学年份最新的 5 名学生：

```sql
SELECT name, enroll_year
FROM students
ORDER BY enroll_year DESC
LIMIT 5;
```

综合查询：

```sql
SELECT student_no, name, enroll_year
FROM students
WHERE enroll_year IN (2025, 2026)
ORDER BY enroll_year DESC
LIMIT 5;
```

---

# 十二、LIMIT 与结果顺序

单独写：

```sql
SELECT *
FROM courses
LIMIT 3;
```

可以返回 3 条数据。

但是：

```text
没有 ORDER BY
→ 不应该依赖数据库当前返回顺序
```

如果题目要求：

```text
学分最高的前三门课程
```

必须明确写：

```sql
SELECT *
FROM courses
ORDER BY credits DESC
LIMIT 3;
```

---

# 十三、LIMIT OFFSET

MySQL 可以跳过若干行后再取数据。

```sql
LIMIT 3 OFFSET 2;
```

表示：

```text
先跳过 2 行
再取 3 行
```

MySQL 也支持：

```sql
LIMIT 2, 3;
```

其中：

```text
2 → 跳过 2 行
3 → 返回 3 行
```

以后分页查询会经常用到。

---

# 十四、SELECT 基本书写顺序

今天已经形成：

```sql
SELECT ...
FROM ...
WHERE ...
ORDER BY ...
LIMIT ...;
```

例如：

```sql
SELECT name, enroll_year
FROM students
WHERE enroll_year IN (2025, 2026)
ORDER BY enroll_year DESC
LIMIT 5;
```

目前可以记：

```text
SELECT
↓
FROM
↓
WHERE
↓
ORDER BY
↓
LIMIT
```

Day 5 学习 `GROUP BY` 和 `HAVING` 后，这个结构还会继续扩充。

---

# 十五、今日典型错误

## 1. 字段名拼写错误

错误：

```sql
SELECT course_code, course_mane
FROM courses;
```

报错：

```text
Unknown column 'course_mane'
```

正确：

```sql
SELECT course_code, course_name
FROM courses;
```

---

## 2. 字段和表对应错误

错误：

```sql
SELECT *
FROM students
WHERE credits BETWEEN 2 AND 4;
```

原因：

```text
credits 属于 courses 表
students 表中没有 credits 字段
```

正确：

```sql
SELECT *
FROM courses
WHERE credits BETWEEN 2 AND 4;
```

## 重要习惯

写 SQL 前先思考：

```text
我要查询什么数据？
↓
数据在哪张表？
↓
需要哪些字段？
↓
字段是否真的属于这张表？
```

这个习惯在以后学习 `JOIN` 时非常重要。

---

# 十六、Day 04 最终 SQL

```sql
-- =========================================
-- MySQL Day 04
-- SELECT 基础查询
-- =========================================


-- 查询所有2026年入学的学生

SELECT * FROM students
WHERE enroll_year = 2026;


-- 查询邮箱为空的学生

SELECT * FROM students
WHERE email IS NULL;


-- 查询邮箱不为空的学生

SELECT * FROM students
WHERE email IS NOT NULL;


-- 查询所有姓张的学生

SELECT * FROM students
WHERE name LIKE '张%';


-- 查询2025或2026年入学的学生

SELECT * FROM students
WHERE enroll_year IN (2025, 2026);


-- 查询学分在2～4之间的课程

SELECT * FROM courses
WHERE credits BETWEEN 2 AND 4;


-- 查询所有课程，并按学分从高到低排序

SELECT * FROM courses
ORDER BY credits DESC;


-- 查询前三条课程

SELECT * FROM courses
LIMIT 3;
```

---

# 十七、Day 04 验收

今日要求：

```text
查询 2026 年学生              ✅
查询邮箱为空                  ✅
查询邮箱不为空                ✅
查询姓张学生                  ✅
查询 2025 或 2026 年学生      ✅
查询课程学分 2～4             ✅
课程按学分倒序                ✅
查询前 3 条课程               ✅
```

今日核心知识：

```text
SELECT        ✅
FROM          ✅
WHERE         ✅
AND           ✅
OR            ✅
NOT           ✅
IN            ✅
BETWEEN       ✅
LIKE          ✅
IS NULL       ✅
IS NOT NULL   ✅
DISTINCT      ✅
ORDER BY      ✅
LIMIT         ✅
```

# Day 04 完成

今天已经完成 SELECT 基础查询训练。

下一天：

# Day 05 — 聚合函数 + GROUP BY + HAVING

将学习：

```text
COUNT
SUM
AVG
MAX
MIN
GROUP BY
HAVING
```

开始从“查询具体记录”进入“统计和分组数据”。
