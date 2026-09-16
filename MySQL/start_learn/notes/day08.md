# MySQL Day 08：Subquery + EXISTS + CTE

## 今日目标

Day 08 主要学习：

- Subquery（子查询）
- `IN + 子查询`
- `EXISTS`
- `NOT EXISTS`
- CTE（Common Table Expression）
- CTE + JOIN

数据库：

```sql
USE study_mysql;
```

---

# 1. 标量子查询

先查询课程平均学分：

```sql
SELECT AVG(credits)
FROM courses;
```

当前结果：

```text
3.31250
```

查询学分高于平均值的课程：

```sql
SELECT *
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
);
```

理解：

```text
先执行内层查询
↓
得到一个值
↓
外层查询使用这个值继续筛选
```

像：

```sql
SELECT AVG(credits)
FROM courses;
```

这种只返回 **1 行 1 列** 的子查询，可以理解为标量子查询。

因此可以直接配合：

```text
=
>
<
>=
<=
```

使用。

---

# 2. IN + 子查询

先查看选课记录中的学生 id：

```sql
SELECT student_id
FROM enrollments;
```

当前数据：

```text
1
1
3
3
4
5
6
```

查询有选课记录的学生：

```sql
SELECT *
FROM students
WHERE id IN (
    SELECT student_id
    FROM enrollments
);
```

理解：

```text
IN
→ 判断一个值是否存在于子查询返回的一组值中
```

即使子查询中：

```text
1
1
3
3
4
5
6
```

存在重复值，外层 `students` 中同一个学生也不会因为重复值而返回多次。

可以理解成：

```text
id 是否属于 {1, 3, 4, 5, 6}
```

---

# 3. EXISTS

查询有选课记录的学生：

```sql
SELECT *
FROM students AS s
WHERE EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.id
);
```

核心理解：

```text
EXISTS
→ 不关心子查询具体返回什么值
→ 只关心有没有符合条件的记录
```

这里：

```sql
SELECT 1
```

中的 `1` 并不是：

```text
student_id = 1
```

它只是一个常量。

例如：

```sql
SELECT 1
FROM students;
```

如果 `students` 有 15 行，就会返回 15 个 `1`。

在 `EXISTS` 中，真正重要的是：

```sql
WHERE e.student_id = s.id
```

如果能够找到至少一条记录：

```text
EXISTS = TRUE
```

如果一条都找不到：

```text
EXISTS = FALSE
```

---

# 4. NOT EXISTS

查询没有选课记录的学生：

```sql
SELECT *
FROM students AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.id
);
```

当前查询结果对应学生 id：

```text
7 ~ 16
```

理解：

```text
EXISTS
→ 子查询有记录，保留

NOT EXISTS
→ 子查询没有记录，保留
```

---

# 5. EXISTS 常见错误

错误：

```sql
WHERE id NOT EXISTS (
    ...
);
```

原因：

```text
NOT EXISTS 前面不需要字段
```

正确：

```sql
WHERE NOT EXISTS (
    ...
);
```

对比：

```text
IN
→ 字段 IN (子查询)

EXISTS
→ EXISTS (子查询)

NOT EXISTS
→ NOT EXISTS (子查询)
```

---

# 6. CTE

CTE 基本结构：

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

当前结果：

```text
student_id | total
-----------+------
1          | 2
3          | 2
```

理解：

```text
先执行一段查询
↓
给查询结果起一个临时名字
↓
后面的 SQL 再继续使用这个结果
```

`course_count`：

- 不是永久表
- 不是数据库中真正创建出来的一张表
- 是一个临时命名结果集
- 只在当前这一条 SQL 中有效
- SQL 执行完后就不存在

---

# 7. CTE + JOIN

只看到：

```text
student_id = 1
student_id = 3
```

不够直观。

可以继续和 `students` 连接：

```sql
WITH course_count AS (
    SELECT
        student_id,
        COUNT(*) AS total
    FROM enrollments
    GROUP BY student_id
)
SELECT
    s.name,
    cc.total
FROM course_count AS cc
JOIN students AS s
    ON cc.student_id = s.id
WHERE cc.total >= 2;
```

结果：

```text
张三 | 2
李四 | 2
```

逻辑：

```text
enrollments
↓
GROUP BY student_id
↓
COUNT
↓
形成 CTE
↓
和 students JOIN
↓
得到学生姓名
↓
筛选 total >= 2
```

---

# 8. 今日独立练习

## 练习 1：高于平均学分的课程

```sql
SELECT
    course_code,
    course_name,
    credits
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
);
```

结果：5 门课程。

---

## 练习 2：有选课记录的学生

```sql
SELECT
    student_no,
    name
FROM students
WHERE id IN (
    SELECT student_id
    FROM enrollments
);
```

结果：5 名学生。

---

## 练习 3：没有选课记录的学生

```sql
SELECT
    student_no,
    name
FROM students
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments
    WHERE students.id = enrollments.student_id
);
```

结果：10 名学生。

---

## 练习 4：CTE 统计选课数量

```sql
WITH count_student AS (
    SELECT
        student_id,
        COUNT(course_id) AS total
    FROM enrollments
    GROUP BY student_id
)
SELECT
    s.name,
    cs.total
FROM students AS s
JOIN count_student AS cs
    ON s.id = cs.student_id
WHERE cs.total >= 2;
```

结果：

```text
张三 | 2
李四 | 2
```

---

## 练习 5：CTE + JOIN + ORDER BY

```sql
WITH count_student AS (
    SELECT
        student_id,
        COUNT(course_id) AS total
    FROM enrollments
    GROUP BY student_id
)
SELECT
    s.student_no,
    s.name,
    cs.total
FROM students AS s
JOIN count_student AS cs
    ON s.id = cs.student_id
WHERE cs.total >= 2
ORDER BY cs.total DESC;
```

结果：

```text
20260001 | 张三 | 2
20260002 | 李四 | 2
```

---

# 9. 今日易错点

## 易错 1：`NOT EXISTS` 前面错误加字段

错误：

```sql
WHERE id NOT EXISTS (...)
```

正确：

```sql
WHERE NOT EXISTS (...)
```

---

## 易错 2：SELECT 多字段漏逗号

错误：

```sql
SELECT s.student_no s.name, cs.total
```

正确：

```sql
SELECT
    s.student_no,
    s.name,
    cs.total
```

---

# 10. 今日核心区别

## 标量子查询

```text
返回一个值
```

例如：

```sql
SELECT AVG(credits)
FROM courses;
```

适合：

```text
=
>
<
>=
<=
```

---

## IN + 子查询

```text
关注子查询返回的一组值
```

记忆：

```text
值在不在集合里
```

---

## EXISTS

```text
不关心具体返回值
只关心有没有符合条件的记录
```

记忆：

```text
记录存不存在
```

---

## CTE

```text
给一段查询结果起临时名字
再继续查询
```

适合把复杂 SQL 拆成多个清晰步骤。

---

# 11. Day 08 验收

今日完成：

```text
标量子查询        ✅
IN + 子查询       ✅
EXISTS            ✅
NOT EXISTS        ✅
CTE               ✅
CTE + JOIN        ✅
独立综合练习      ✅
```

核心记忆：

```text
标量子查询
→ 一个值

IN
→ 值在不在结果集合里

EXISTS
→ 有没有符合条件的记录

CTE
→ 临时命名结果集
```

Day 08 完成。
