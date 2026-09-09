# MySQL Day 06

## 主题

**外键 + 一对多 + 多对多 + INNER JOIN + LEFT JOIN**

---

## 1. 今天的核心关系

### 一对多

一个老师可以教多门课程：

```text
teacher
1
↓
N
courses
```

### 多对多

一个学生可以选多门课，一门课也可以被多个学生选：

```text
students
N
↓
enrollments
↑
N
courses
```

因此需要 `enrollments` 作为中间表。

---

## 2. enrollments 表

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

### 字段含义

- `id`：选课记录自己的主键
- `student_id`：引用 `students.id`
- `course_id`：引用 `courses.id`
- `score`：该学生这门课的成绩
- `UNIQUE(student_id, course_id)`：防止同一个学生重复选择同一门课

---

## 3. PRIMARY KEY 与 FOREIGN KEY

### PRIMARY KEY

标识自己。

```text
students.id
```

唯一标识一个学生。

### FOREIGN KEY

引用别人。

```text
enrollments.student_id
        ↓
students.id
```

```text
enrollments.course_id
        ↓
courses.id
```

外键可以阻止无效关联数据进入数据库。

例如不存在 `students.id = 9999` 时：

```sql
INSERT INTO enrollments
(student_id, course_id, score)
VALUES
(9999, 1, 90.00);
```

会因为外键约束失败而被拒绝。

---

## 4. 联合 UNIQUE

```sql
UNIQUE(student_id, course_id)
```

表示 `(student_id, course_id)` 这个组合不能重复。

例如已经存在：

```text
student_id = 1
course_id = 1
```

再次插入 `(1, 1)` 会报重复错误。

---

# 5. INNER JOIN

`JOIN` 默认就是 `INNER JOIN`。

核心：

> **两边能匹配上的数据才显示。**

### 两表 JOIN

```sql
SELECT
    e.student_id,
    s.name,
    e.course_id,
    e.score
FROM enrollments AS e
INNER JOIN students AS s
    ON e.student_id = s.id;
```

### 三表 JOIN

```sql
SELECT
    s.name,
    c.course_name,
    e.score
FROM enrollments AS e
INNER JOIN students AS s
    ON e.student_id = s.id
INNER JOIN courses AS c
    ON e.course_id = c.id;
```

逻辑关系：

```text
students ← enrollments → courses
```

---

# 6. LEFT JOIN

核心：

> **左表全部保留，右表匹配不到时补 NULL。**

```sql
SELECT
    s.name,
    e.course_id
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id;
```

有选课记录的学生能匹配到 `course_id`。

没有选课记录的学生：

```text
course_id = NULL
```

---

## 7. 查询没有选课的学生

```sql
SELECT
    s.id,
    s.name
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
WHERE e.student_id IS NULL;
```

逻辑：

```text
students 全部保留
↓
没有选课的学生匹配不到 enrollments
↓
e.student_id = NULL
↓
WHERE e.student_id IS NULL
↓
只留下没有选课的学生
```

---

# 8. INNER JOIN 与 LEFT JOIN 对比

## INNER JOIN

```text
只保留两边能匹配上的记录
```

## LEFT JOIN

```text
左表全部保留
右表匹配不到 → NULL
```

今天暂时不需要深入 `RIGHT JOIN`。

---

# 9. JOIN + GROUP BY

## 每个学生选了几门课（包括 0 门）

```sql
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name;
```

### 为什么是 COUNT(e.course_id)？

因为 `COUNT(字段)` 不统计 `NULL`。

对于没有选课的学生：

```text
e.course_id = NULL
```

所以结果自然是：

```text
0
```

如果使用：

```sql
COUNT(*)
```

LEFT JOIN 保留下来的那一行也会被计算，因此可能得到错误的 `1`。

---

## 10. 每门课程有多少学生选择（包括 0 人）

```sql
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name;
```

题目要求“包括 0 人选择的课程”，所以 `courses` 必须作为左表。

---

# 11. JOIN + HAVING

## 选课人数不少于 2 人的课程

```sql
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING student_count >= 2;
```

`HAVING` 用来筛选分组后的结果。

---

## 12. 平均成绩不低于 85 分的课程

```sql
SELECT
    c.course_name,
    AVG(e.score) AS avg_score
FROM courses AS c
INNER JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING avg_score >= 85;
```

这里用 `INNER JOIN` 很合适，因为没有选课记录的课程没有成绩可平均。

---

## 13. 选了至少 2 门课程的学生

```sql
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students AS s
INNER JOIN enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING course_count >= 2;
```

---

# 14. GROUP BY s.id 与 GROUP BY s.id, s.name

当前 `students.id` 是主键，因此：

```sql
GROUP BY s.id
```

在当前 MySQL 场景下通常可以工作。

但学习阶段更推荐：

```sql
GROUP BY s.id, s.name
```

优点：

- 更直观
- 可读性更好
- 避免只按姓名分组导致同名学生被合并

不要只写：

```sql
GROUP BY s.name
```

因为可能存在同名学生。

---

# 15. Day 06 验收结论

今天已经掌握：

- 一对多
- 多对多
- 中间表
- `FOREIGN KEY`
- `REFERENCES`
- 联合 `UNIQUE`
- `INNER JOIN`
- `LEFT JOIN`
- 三表 JOIN
- `LEFT JOIN + IS NULL`
- `JOIN + GROUP BY`
- `JOIN + HAVING`
- `COUNT(字段)` 与 `COUNT(*)` 在 LEFT JOIN 场景下的区别

---

# 16. 今天最重要的几句话

```text
PRIMARY KEY
→ 标识自己

FOREIGN KEY
→ 引用别人
```

```text
INNER JOIN
→ 只保留两边匹配的数据

LEFT JOIN
→ 左表全部保留
→ 右表匹配不到就补 NULL
```

```text
多对多
→ 建立中间表
```

```text
LEFT JOIN + COUNT(右表字段)
→ 可以统计 0 条关联记录
```

```text
WHERE
→ 筛选行

HAVING
→ 筛选分组
```
