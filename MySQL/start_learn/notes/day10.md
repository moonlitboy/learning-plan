# Day 10 - INDEX + EXPLAIN

## 今日目标

今天学习并实际练习：

- 主键索引
- 唯一索引
- 普通索引
- 联合索引
- `SHOW INDEX`
- `EXPLAIN`
- `EXPLAIN ANALYZE`
- 建索引前后执行计划对比
- 联合索引最左前缀基础
- 索引什么时候值得建
- 常见不利于普通 B-tree 索引的写法

---

## 1. 索引是什么

索引的核心作用：

> 帮助 MySQL 更快定位符合条件的数据。

索引不会减少表中的数据量，反而会额外占用存储空间。

索引也不是越多越好，因为：

- `INSERT`
- `UPDATE`
- `DELETE`

执行时，MySQL 还需要维护相关索引。

---

## 2. 四种常见索引

### 主键索引

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

`PRIMARY KEY` 会自动对应主键索引。

特点：

- 不允许 `NULL`
- 主键值不能重复
- 一张表只有一个主键，但可以是联合主键

---

### 唯一索引

例如：

```sql
student_no VARCHAR(20) NOT NULL UNIQUE
```

`UNIQUE` 会对应唯一索引。

MySQL 中：

- 非 `NULL` 值不能重复
- `NULL` 可以出现多次

---

### 普通索引

```sql
CREATE INDEX idx_students_name
ON students(name);
```

普通索引允许重复值。

---

### 联合索引

```sql
CREATE INDEX idx_year_name
ON students(enroll_year, name);
```

这是一个索引，但包含两个字段：

```text
(enroll_year, name)
```

---

## 3. SHOW INDEX

查看已有索引：

```sql
SHOW INDEX FROM students;
```

今天实际看到 `students` 原本有：

- `PRIMARY` -> `id`
- `student_no` -> 唯一索引
- `email` -> 唯一索引
- `FK_department_id` -> `department_id`

创建 `idx_students_name` 后，又增加：

- `idx_students_name` -> `name`

创建联合索引后：

```text
Key_name: idx_year_name
Seq_in_index: 1
Column_name: enroll_year

Key_name: idx_year_name
Seq_in_index: 2
Column_name: name
```

说明：

> 一个联合索引包含几个字段，`SHOW INDEX` 中通常就会显示几行。

---

## 4. Non_unique

```text
Non_unique: 0
```

表示索引值要求唯一。

常见于：

- `PRIMARY KEY`
- `UNIQUE`

```text
Non_unique: 1
```

表示允许重复值。

普通索引通常如此。

---

## 5. 建索引前的 EXPLAIN

执行：

```sql
EXPLAIN
SELECT *
FROM students
WHERE name = '张三';
```

实际结果核心部分：

```text
type: ALL
possible_keys: NULL
key: NULL
rows: 15
Extra: Using where
```

理解：

```text
type: ALL
-> 全表扫描

possible_keys: NULL
-> 没有合适的候选索引

key: NULL
-> 最终没有使用索引

rows: 15
-> 优化器估计需要检查约 15 行

Extra: Using where
-> 还需要根据 WHERE 条件筛选
```

---

## 6. 创建 name 索引

```sql
CREATE INDEX idx_students_name
ON students(name);
```

然后再次：

```sql
EXPLAIN
SELECT *
FROM students
WHERE name = '张三';
```

实际结果：

```text
type: ref
possible_keys: idx_students_name
key: idx_students_name
rows: 1
Extra: NULL
```

对比：

```text
建索引前：
type: ALL
key: NULL
rows: 15

建索引后：
type: ref
key: idx_students_name
rows: 1
```

这次实验真正验证了索引对执行计划的影响。

---

## 7. possible_keys 和 key

```text
possible_keys
-> 优化器认为可以考虑的索引

key
-> 优化器最终实际选择使用的索引
```

例如：

```text
possible_keys: idx_students_name,idx_year_name
key: idx_students_name
```

说明：

- 两个索引都可以考虑
- 最终选择了 `idx_students_name`
- `idx_year_name` 已存在，只是本次没有被选中

---

## 8. type: ref

今天看到：

```text
type: ref
```

可以先理解为：

> MySQL 使用非唯一索引，或联合索引中的非唯一前缀，进行等值查找。

例如：

```sql
WHERE name = '张三'
```

因为 `name` 允许重复，所以可能匹配多行。

---

## 9. EXPLAIN 和 EXPLAIN ANALYZE

### EXPLAIN

```sql
EXPLAIN
SELECT *
FROM students
WHERE name = '张三';
```

主要查看：

> MySQL 准备怎么执行查询。

---

### EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT *
FROM students
WHERE name = '张三';
```

今天实际结果：

```text
Index lookup on students using idx_students_name (name='张三')
(cost=0.35 rows=1)
(actual time=0.0568..0.0604 rows=1 loops=1)
```

理解：

```text
(cost=0.35 rows=1)
-> 优化器执行前的估计

(actual time=... rows=1 loops=1)
-> 真正执行后的实际统计
```

`EXPLAIN ANALYZE` 会真正执行查询，但不会像普通 `SELECT` 那样打印结果表。

---

## 10. 联合索引与最左前缀

联合索引：

```sql
CREATE INDEX idx_year_name
ON students(enroll_year, name);
```

基础上可以理解成：

```text
(enroll_year, name)
```

符合最左前缀的典型查询：

```sql
WHERE enroll_year = 2026;
```

以及：

```sql
WHERE enroll_year = 2026
  AND name = '张三';
```

如果只有这个联合索引：

```sql
WHERE name = '张三';
```

则没有从最左边的 `enroll_year` 开始。

对于：

```text
(A, B, C)
```

基础记忆：

```text
A        -> 可以
A, B     -> 可以
A, B, C  -> 可以
B        -> 不符合最左前缀
B, C     -> 不符合最左前缀
```

---

## 11. 联合索引实际实验

执行：

```sql
EXPLAIN
SELECT *
FROM students
WHERE enroll_year = 2026
  AND name = '张三';
```

实际看到：

```text
possible_keys: idx_students_name,idx_year_name
key: idx_students_name
```

说明：

> 即使联合索引符合条件，优化器也不一定选择它。

MySQL 会根据成本选择它认为更合适的执行方案。

---

只查：

```sql
EXPLAIN
SELECT *
FROM students
WHERE enroll_year = 2026;
```

实际看到：

```text
type: ref
possible_keys: idx_year_name
key: idx_year_name
rows: 6
Extra: NULL
```

说明：

> 联合索引 `(enroll_year, name)` 可以只使用最左侧的 `enroll_year`。

---

## 12. 索引什么时候更值得建

通常更值得考虑索引的字段：

- 经常出现在 `WHERE`
- 经常用于 `JOIN`
- 经常用于 `ORDER BY`
- 查询频率较高
- 区分度较高

例如：

```text
student_no
```

通常区分度很高。

而像：

```text
enroll_year
gender
```

如果只有很少几个不同值，单列索引收益未必很高。

---

## 13. 索引不是越多越好

索引的代价：

```text
查询可能更方便
+
INSERT / UPDATE / DELETE 维护成本增加
+
额外占用存储空间
```

所以：

> 建索引前，先看已有索引和真实查询需求。

可以先：

```sql
SHOW INDEX FROM students;
```

再决定是否新建。

---

## 14. 避免重复索引

如果已经有：

```text
idx_year_name(enroll_year, name)
```

又建立：

```text
idx_year(enroll_year)
```

很多情况下功能会有重叠。

因为联合索引已经可以利用最左侧的：

```text
enroll_year
```

但真实项目是否保留两个索引，最终仍应结合查询模式和 `EXPLAIN` 判断。

---

## 15. LIKE 与索引

普通 B-tree 索引下，可以先记：

```text
name = '张三'
-> 索引友好

name LIKE '张%'
-> 通常更容易利用索引

name LIKE '%张'
-> 通常难以有效利用普通索引

name LIKE '%张%'
-> 通常难以有效利用普通索引
```

原因是：

> 前导 `%` 会让 MySQL 难以从索引开头直接定位范围。

---

## 16. 对索引列做函数

例如已有：

```sql
CREATE INDEX idx_students_name
ON students(name);
```

下面：

```sql
WHERE name = '张三'
```

通常更容易直接利用普通索引。

而：

```sql
WHERE UPPER(name) = '张三'
```

对索引列进行了函数运算，普通 `name` 索引通常不能像前者那样直接发挥作用。

---

## 17. 删除索引

语法：

```sql
DROP INDEX idx_students_name
ON students;
```

删除索引：

- 不会删除字段
- 不会删除表
- 不会删除数据

只会删除索引结构。

---

## 18. 今日核心结论

```text
PRIMARY KEY
-> 主键索引

UNIQUE
-> 唯一索引

普通 INDEX
-> 普通索引

联合 INDEX
-> 多个字段组成一个索引

SHOW INDEX
-> 查看已有索引

EXPLAIN
-> 看准备怎么执行

EXPLAIN ANALYZE
-> 真正执行并显示实际执行统计

possible_keys
-> 候选索引

key
-> 最终实际使用索引

type: ALL
-> 全表扫描

type: ref
-> 通过非唯一索引等方式进行等值查找
```

---

## 19. 今日最重要实验

```text
建 name 索引前：

type: ALL
key: NULL
rows: 15

        ↓

CREATE INDEX idx_students_name
ON students(name);

        ↓

建 name 索引后：

type: ref
key: idx_students_name
rows: 1
```

今天真正掌握的不是一句：

> 索引可以提高查询速度。

而是：

> 能够使用 `EXPLAIN` 观察 MySQL 是否使用索引，并比较建索引前后的执行计划变化。

---

# Day 10 完成 ✅

下一天：

# Day 11 - TRANSACTION + ACID + Isolation + Lock

重点：

- 两个 Terminal Session
- `START TRANSACTION`
- `COMMIT`
- `ROLLBACK`
- ACID
- 隔离级别
- 脏读
- 不可重复读
- 幻读
- 锁
