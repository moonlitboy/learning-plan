# MySQL Day 05 学习笔记

## 主题：聚合函数 + GROUP BY + HAVING

今天学习并完成：

- `COUNT()`
- `SUM()`
- `AVG()`
- `MAX()`
- `MIN()`
- `GROUP BY`
- `HAVING`
- `COUNT(*)` 与 `COUNT(column)` 的区别
- `WHERE` 与 `HAVING` 的区别
- 聚合结果排序
- SQL 的**书写顺序**
- SQL 的**逻辑执行顺序**

---

# 一、聚合函数

聚合函数用于对多行数据进行统计和计算。

## 1. COUNT()：统计数量

### 统计所有行

```sql
SELECT COUNT(*)
FROM students;
```

`COUNT(*)` 会统计表中的所有行。

例如：

```text
students 一共有 15 行
COUNT(*) = 15
```

### 统计某字段非 NULL 的行

```sql
SELECT COUNT(email)
FROM students;
```

`COUNT(email)` 只统计 `email` 不为 `NULL` 的行。

今天实际数据：

```text
COUNT(*)      = 15
COUNT(email)  = 13
email IS NULL = 2
```

因此：

```text
15 = 13 + 2
```

重点：

```text
COUNT(*)       → 统计所有行
COUNT(column)  → 统计该字段不为 NULL 的行
```

---

## 2. SUM()：求和

```sql
SELECT SUM(capacity) AS total_capacity
FROM courses;
```

今天结果：

```text
400
```

表示所有课程容量之和为 400。

---

## 3. AVG()：求平均值

```sql
SELECT AVG(credits) AS avg_credits
FROM courses;
```

今天结果：

```text
3.31250
```

表示所有课程平均学分为 `3.31250`。

---

## 4. MAX()：求最大值

```sql
SELECT MAX(credits) AS max_credits
FROM courses;
```

今天结果：

```text
4.0
```

---

## 5. MIN()：求最小值

```sql
SELECT MIN(credits) AS min_credits
FROM courses;
```

今天结果：

```text
2.0
```

---

# 二、GROUP BY：分组统计

`GROUP BY` 的作用：

> 按指定字段的值把数据分成多个组，再对每个组分别进行统计。

例如：

```sql
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year;
```

今天结果：

```text
2026 → 6 人
2025 → 5 人
2024 → 4 人
```

可以理解为：

```text
students
↓
按照 enroll_year 分组
↓
2024 一组
2025 一组
2026 一组
↓
每一组分别 COUNT(*)
```

重点：

```text
没有 GROUP BY
→ 对整个结果集统计一次

有 GROUP BY
→ 对每个分组分别统计
```

一句话记忆：

> 聚合函数负责“算”，GROUP BY 负责“按什么分类来算”。

---

# 三、GROUP BY + 其他聚合函数

## 按学分统计课程数量

```sql
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
GROUP BY credits;
```

今天结果：

```text
4.0 → 3 门
3.5 → 2 门
3.0 → 1 门
2.5 → 1 门
2.0 → 1 门
```

---

## 按学分计算平均容量

```sql
SELECT
    credits,
    AVG(capacity) AS avg_capacity
FROM courses
GROUP BY credits;
```

今天结果：

```text
4.0 → 53.3333
3.5 → 55.0000
3.0 → 45.0000
2.5 → 40.0000
2.0 → 45.0000
```

---

## 一次使用多个聚合函数

```sql
SELECT
    credits,
    COUNT(*) AS course_count,
    AVG(capacity) AS avg_capacity,
    MIN(capacity) AS min_capacity,
    MAX(capacity) AS max_capacity
FROM courses
GROUP BY credits;
```

这条 SQL 会同时得到：

- 每组课程数量
- 每组平均容量
- 每组最小容量
- 每组最大容量

---

# 四、HAVING：筛选分组

`HAVING` 用于：

> 在完成 `GROUP BY` 后，对分组结果进行筛选。

例如：

```sql
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
GROUP BY credits
HAVING COUNT(*) >= 2;
```

今天结果：

```text
4.0 → 3 门
3.5 → 2 门
```

课程数量只有 1 门的学分组被过滤掉。

---

# 五、WHERE 与 HAVING 的区别

这是今天的核心知识之一。

## WHERE

```text
WHERE → 筛选原始数据行
```

例如：

```sql
WHERE credits >= 3
```

含义：

> 先把学分小于 3 的课程过滤掉。

---

## HAVING

```text
HAVING → 筛选 GROUP BY 之后的分组
```

例如：

```sql
HAVING COUNT(*) >= 2
```

含义：

> 分组统计完成后，只保留课程数量至少为 2 的组。

---

## 对比

```text
WHERE
↓
筛选“行”
↓
GROUP BY
↓
HAVING
↓
筛选“组”
```

最重要的记忆：

```text
WHERE   → 分组前筛选行
HAVING  → 分组后筛选组
```

---

# 六、WHERE + GROUP BY + HAVING

今天完成的综合查询：

```sql
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
WHERE enroll_year >= 2025
GROUP BY enroll_year
HAVING COUNT(*) >= 6;
```

逻辑：

```text
FROM students
↓
WHERE enroll_year >= 2025
先筛掉 2024 年学生
↓
GROUP BY enroll_year
按照入学年份分组
↓
COUNT(*)
统计每组人数
↓
HAVING COUNT(*) >= 6
只保留人数至少为 6 的组
```

今天结果：

```text
2026 → 6 人
```

---

# 七、聚合结果排序

例如：

```sql
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year
ORDER BY student_count DESC;
```

今天结果：

```text
2026 → 6
2025 → 5
2024 → 4
```

这里可以直接使用 `SELECT` 中定义的别名：

```sql
COUNT(*) AS student_count
```

然后：

```sql
ORDER BY student_count DESC;
```

---

# 八、今日综合查询

今天最终完成：

```sql
SELECT
    credits,
    COUNT(*) AS course_count,
    AVG(capacity) AS avg_capacity
FROM courses
WHERE credits >= 3
GROUP BY credits
HAVING COUNT(*) >= 2
ORDER BY avg_capacity DESC;
```

结果：

```text
3.5 → 2 门 → 平均容量 55.0000
4.0 → 3 门 → 平均容量 53.3333
```

这条 SQL 同时使用了：

```text
WHERE
GROUP BY
COUNT
AVG
HAVING
ORDER BY
```

---

# 九、重点：SQL 的书写顺序与逻辑执行顺序

这是 Day 05 必须重点区分的知识。

## 1. SQL 的书写顺序

我们实际写 SQL 时，通常按照：

```text
SELECT
↓
FROM
↓
WHERE
↓
GROUP BY
↓
HAVING
↓
ORDER BY
↓
LIMIT
```

例如：

```sql
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
WHERE credits >= 3
GROUP BY credits
HAVING COUNT(*) >= 2
ORDER BY course_count DESC
LIMIT 2;
```

所以：

> **书写时 SELECT 在最前面。**

---

## 2. SQL 的逻辑执行顺序

虽然 `SELECT` 写在第一行，但 SQL 在逻辑上并不是先处理 `SELECT`。

逻辑顺序是：

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

解释：

### 第 1 步：FROM

```text
确定从哪张表获取数据
```

### 第 2 步：WHERE

```text
筛选原始数据行
```

### 第 3 步：GROUP BY

```text
把剩余数据进行分组
```

### 第 4 步：HAVING

```text
筛选分组结果
```

### 第 5 步：SELECT

```text
决定最终显示哪些列、表达式和聚合结果
```

### 第 6 步：ORDER BY

```text
对最终结果进行排序
```

### 第 7 步：LIMIT

```text
限制最终返回的行数
```

---

## 3. 两种顺序对比

### SQL 书写顺序

```text
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

### SQL 逻辑执行顺序

```text
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
LIMIT
```

最重要的记忆：

> **写 SQL：SELECT 先写。**

> **理解 SQL：FROM 先想。**

也可以记成：

```text
书写规范 ≠ 逻辑执行顺序
```

---

# 十、为什么这个区别重要

例如：

```sql
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
WHERE credits >= 3
GROUP BY credits
HAVING COUNT(*) >= 2
ORDER BY course_count DESC;
```

虽然代码第一行是：

```sql
SELECT
```

但是理解时应该从：

```text
FROM courses
```

开始：

```text
FROM courses
↓
找到 courses 表

WHERE credits >= 3
↓
只留下学分至少为 3 的课程

GROUP BY credits
↓
按照学分进行分组

HAVING COUNT(*) >= 2
↓
只保留至少有 2 门课程的组

SELECT credits, COUNT(*)
↓
决定最终显示学分和课程数量

ORDER BY course_count DESC
↓
按照课程数量从多到少排序
```

因此遇到复杂 SQL 时：

> 不要只按照代码从上到下机械阅读。

应该按照逻辑执行顺序分析。

---

# 十一、今天遇到的错误

## 1. HAVING BY

错误：

```sql
HAVING BY COUNT(*) >= 2;
```

正确：

```sql
HAVING COUNT(*) >= 2;
```

记住：

```text
GROUP BY  → 有 BY
ORDER BY  → 有 BY

WHERE     → 没有 BY
HAVING    → 没有 BY
LIMIT     → 没有 BY
```

---

## 2. 中文逗号

错误：

```sql
COUNT(*) AS course_count， AVG(capacity)
```

这里使用了中文：

```text
，
```

正确：

```sql
COUNT(*) AS course_count, AVG(capacity)
```

SQL 中应使用英文半角符号。

---

## 3. SELECT 多个字段漏逗号

错误：

```sql
SELECT
    COUNT(*) AS course_count
    AVG(capacity) AS avg_capacity
```

正确：

```sql
SELECT
    COUNT(*) AS course_count,
    AVG(capacity) AS avg_capacity
```

---

## 4. 字段名拼写错误

例如：

```text
capactiy
```

正确字段：

```text
capacity
```

---

## 5. 聚合查询忘记 GROUP BY

错误思路：

```sql
SELECT enroll_year, COUNT(*)
FROM students
HAVING COUNT(*) >= 5;
```

如果既要显示：

```text
enroll_year
```

又要统计每个年份的人数，就需要明确：

```sql
GROUP BY enroll_year
```

正确：

```sql
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year
HAVING COUNT(*) >= 5;
```

---

# 十二、MySQL Terminal 实用技巧

如果一条 SQL 还没有用 `;` 执行，但是已经敲错了，可以输入：

```text
\c
```

取消当前输入。

例如：

```text
mysql> SELECT
    -> credits,
    -> ...
    -> \c
mysql>
```

重新回到：

```text
mysql>
```

---

# 十三、Day 05 验收

今天已经能够独立解释：

## COUNT(*) 与 COUNT(column)

```text
COUNT(*)       → 统计所有行
COUNT(column)  → 统计该字段非 NULL 的行
```

## WHERE 与 HAVING

```text
WHERE   → 筛选行
HAVING  → 筛选分组
```

## GROUP BY enroll_year

```text
按照入学年份进行分组
```

## SQL 书写顺序

```text
SELECT
FROM
WHERE
GROUP BY
HAVING
ORDER BY
LIMIT
```

## SQL 逻辑执行顺序

```text
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
LIMIT
```

---

# 十四、Day 05 总结

今天完成：

```text
COUNT
SUM
AVG
MAX
MIN
GROUP BY
HAVING
WHERE + GROUP BY
GROUP BY + 聚合函数
WHERE + GROUP BY + HAVING
聚合结果排序
COUNT 与 NULL
SQL 书写顺序
SQL 逻辑执行顺序
```

最重要的三句话：

> **聚合函数负责统计，GROUP BY 负责按照什么分类统计。**

> **WHERE 筛选行，HAVING 筛选组。**

> **写 SQL 时 SELECT 在前；理解 SQL 时 FROM 在前。**

---

**MySQL Day 05：完成 ✅**
