# Day 09 - 数据库设计 + ALTER TABLE + 范式

## 今日目标

- 理解 1NF / 2NF / 3NF
- 理解部分函数依赖与传递函数依赖
- 掌握 `ALTER TABLE`
- 掌握 `ADD COLUMN` / `MODIFY COLUMN` / `DROP COLUMN`
- 掌握 `ADD CONSTRAINT`
- 给 `students` 增加学院外键
- 使用 `DESC` 和 `SHOW CREATE TABLE` 检查表结构

---

## 1. 第一范式 1NF

核心：

> 每个字段中的值应该是原子的、不可再拆成多个同类值。

例如：

```text
hobby = "篮球, 足球, 游泳"
```

不符合 1NF，因为一个字段里保存了多个值。

可以简单记：

```text
1NF -> 一格一个值
```

---

## 2. 第二范式 2NF

前提：先满足 1NF。

核心：

> 非主属性必须完全依赖整个候选键，不能只依赖联合键的一部分。

例如联合主键：

```text
(student_id, course_id)
```

依赖关系：

```text
student_id -> student_name
course_id  -> course_name
(student_id, course_id) -> score
```

其中：

- `student_name` 只依赖 `student_id`
- `course_name` 只依赖 `course_id`

它们属于部分函数依赖，不满足 2NF。

而：

```text
(student_id, course_id) -> score
```

属于完全函数依赖。

可以简单记：

```text
2NF -> 消灭部分函数依赖
```

---

## 3. 第三范式 3NF

前提：先满足 2NF。

核心：

> 不允许非主属性对候选键存在传递函数依赖。

例如：

```text
student_id -> department_id
department_id -> department_name
```

因此：

```text
student_id -> department_name
```

是传递函数依赖。

所以应该拆成：

```text
students
student_id | student_name | department_id
```

```text
departments
department_id | department_name
```

可以简单记：

```text
3NF -> 消灭非主属性对候选键的传递函数依赖
```

---

## 4. ALTER TABLE

### 增加字段

```sql
ALTER TABLE students
ADD COLUMN department_id INT;
```

### 修改字段定义

```sql
ALTER TABLE departments
MODIFY COLUMN phone VARCHAR(30);
```

### 删除字段

```sql
ALTER TABLE departments
DROP COLUMN phone;
```

### 增加约束

```sql
ALTER TABLE students
ADD CONSTRAINT FK_department_id
FOREIGN KEY (department_id)
REFERENCES departments(department_id);
```

---

## 5. 今日正式实验

创建学院表：

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE
);
```

给 `students` 增加学院字段：

```sql
ALTER TABLE students
ADD COLUMN department_id INT;
```

增加外键：

```sql
ALTER TABLE students
ADD CONSTRAINT FK_department_id
FOREIGN KEY (department_id)
REFERENCES departments(department_id);
```

检查：

```sql
DESC students;
SHOW CREATE TABLE students\G
```

---

## 6. 外键验证

插入学院：

```sql
INSERT INTO departments (department_name)
VALUES
('计算机学院'),
('数学学院');
```

给张三设置学院：

```sql
UPDATE students
SET department_id = 1
WHERE id = 1;
```

验证：

```sql
SELECT id, name, department_id
FROM students
WHERE id = 1;
```

结果：

```text
1 | 张三 | 1
```

故意设置不存在的学院：

```sql
UPDATE students
SET department_id = 999
WHERE id = 1;
```

MySQL 返回 `ERROR 1452`，说明外键约束已经生效。

核心理解：

```text
students.department_id
        ↓
必须能在
departments.department_id
中找到对应值
```

---

## 7. 今日总结

```text
1NF -> 字段原子化
2NF -> 消灭部分函数依赖
3NF -> 消灭传递函数依赖
```

今天实际完成：

- 创建 `departments`
- 给 `students` 增加 `department_id`
- 建立 `students.department_id -> departments.department_id` 外键
- 使用 `DESC` 检查结构
- 使用 `SHOW CREATE TABLE ...\G` 检查完整建表语句
- 实际验证外键约束
- 理解 `ADD COLUMN`
- 理解 `MODIFY COLUMN`
- 理解 `DROP COLUMN`
- 理解 `ADD CONSTRAINT`

## Day 09 状态

**完成。**
