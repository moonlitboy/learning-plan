# Day 12 — VIEW + Procedure + Trigger + Function

## 今日重点

优先级：

```text
VIEW > Procedure > Trigger > Function
```

今天完成了 4 个部分：

1. VIEW（视图）
2. Procedure（存储过程）
3. Trigger（触发器）
4. Function（函数）

---

# 1. VIEW（视图）

## 核心理解

**VIEW 保存的是 SELECT 查询逻辑，不是查询结果本身。**

可以把 VIEW 理解成：

> 给一条复杂、经常重复使用的 SELECT 查询起一个名字。

示例：

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

## 查看 VIEW

```sql
SHOW FULL TABLES;
```

区别：

```text
普通表 → BASE TABLE
视图   → VIEW
```

查看定义：

```sql
SHOW CREATE VIEW student_course_view;
```

## 修改 VIEW

```sql
CREATE OR REPLACE VIEW student_course_view AS
SELECT
    s.name,
    c.course_name
FROM students AS s
JOIN enrollments AS e
    ON s.id = e.student_id
JOIN courses AS c
    ON c.id = e.course_id;
```

## 删除 VIEW

```sql
DROP VIEW student_course_view;
```

注意：

**DROP VIEW 只删除视图定义，不会删除底层表和底层数据。**

## 什么时候适合使用 VIEW

适合：

```text
复杂查询
+
经常重复使用
+
希望封装查询逻辑
```

例如经常查询：

```text
学生姓名 + 课程名称 + 成绩
```

需要反复写三表 JOIN 时，很适合创建 VIEW。

不适合：

- 只执行一次的简单查询
- 为了使用 VIEW 而创建 VIEW
- 把 VIEW 当成自动性能优化工具

---

# 2. Procedure（存储过程）

## 核心理解

**Procedure = 把一组可以执行的 SQL 操作保存到 MySQL 中，以后通过 CALL 调用。**

示例：

```sql
DELIMITER //

CREATE PROCEDURE show_students()
BEGIN
    SELECT * FROM students;

    SELECT COUNT(*) AS total
    FROM students;
END //

DELIMITER ;
```

调用：

```sql
CALL show_students();
```

一次调用可以执行多条 SQL，并返回多个结果集。

---

## DELIMITER

创建 Procedure / Trigger / Function 时，`BEGIN ... END` 内部有多个 `;`。

所以在 mysql Terminal 中可以先：

```sql
DELIMITER //
```

临时把整条命令的结束符改成：

```text
//
```

这样内部 SQL 仍然使用：

```text
;
```

整个对象定义最后使用：

```sql
END //
```

完成后恢复：

```sql
DELIMITER ;
```

### 今日实际发现

当前使用的 SQLTools 环境直接执行：

```sql
DELIMITER //
```

会报语法错误。

因此今天：

```text
VIEW
→ SQLTools

Procedure / Trigger / Function
→ mysql Terminal
```

注意：`DELIMITER` 是 mysql 客户端命令，不是普通的 MySQL Server SQL 语句。

---

## Procedure 输入参数

创建：

```sql
DELIMITER //

CREATE PROCEDURE show_students_by_year(IN p_year INT)
BEGIN
    SELECT *
    FROM students
    WHERE enroll_year = p_year;
END //

DELIMITER ;
```

调用：

```sql
CALL show_students_by_year(2026);
CALL show_students_by_year(2025);
```

理解：

```text
IN      → 输入参数
p_year  → 参数名
INT     → 参数类型
```

今天实际结果：

```text
2026 → 5 名学生
2025 → 6 名学生
```

查看定义：

```sql
SHOW CREATE PROCEDURE show_students_by_year\G
```

删除：

```sql
DROP PROCEDURE IF EXISTS show_students_by_year;
```

---

# 3. Trigger（触发器）

## 核心理解

**Trigger = 当某个表发生指定的 INSERT / UPDATE / DELETE 事件时，MySQL 自动执行的一段 SQL。**

和 Procedure 最大区别：

```text
Procedure → 主动 CALL
Trigger   → 满足事件后自动执行
```

---

## 今日实验：新增学生后自动记录日志

### 1. 创建日志表

```sql
CREATE TABLE student_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

检查：

```sql
DESC student_logs;
SELECT * FROM student_logs;
```

初始日志表为空。

### 2. 创建 Trigger

```sql
DELIMITER //

CREATE TRIGGER after_student_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_logs (student_name)
    VALUES (NEW.name);
END //

DELIMITER ;
```

逐句理解：

```text
CREATE TRIGGER after_student_insert
→ 创建名为 after_student_insert 的触发器

AFTER INSERT ON students
→ students 表 INSERT 成功之后触发

FOR EACH ROW
→ 每影响一行，触发一次

NEW.name
→ 刚刚 INSERT 进去的新行的 name
```

### 3. 查看 Trigger

```sql
SHOW TRIGGERS\G
```

今日实际看到：

```text
Trigger: after_student_insert
Event:   INSERT
Table:   students
Timing:  AFTER
```

### 4. 测试

只向 students 插入：

```sql
INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260020', '测试学生', 'test20@example.com', 2026);
```

然后查询：

```sql
SELECT *
FROM student_logs;
```

结果自动出现：

```text
测试学生
```

说明：

```text
INSERT students
      ↓
AFTER INSERT Trigger
      ↓
NEW.name = 测试学生
      ↓
自动 INSERT student_logs
```

---

## NEW 和 OLD

记忆：

```text
INSERT → NEW
DELETE → OLD
UPDATE → OLD + NEW
```

例如：

```sql
NEW.name
```

表示新数据。

```sql
OLD.name
```

表示修改或删除前的旧数据。

查看 Trigger 定义：

```sql
SHOW CREATE TRIGGER after_student_insert\G
```

---

# 4. Function（函数）

## 核心理解

**Function = 接收参数，进行处理，并返回一个值。**

示例：

```sql
DELIMITER //

CREATE FUNCTION add_one(n INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN n + 1;
END //

DELIMITER ;
```

调用：

```sql
SELECT add_one(10);
SELECT add_one(99) AS ok;
```

今日实际结果：

```text
add_one(10) → 11
add_one(99) → 100
```

---

## DETERMINISTIC

理解：

```text
相同输入 → 相同输出
```

例如：

```text
add_one(10) → 11
add_one(10) → 11
```

因此 `add_one()` 可以声明：

```sql
DETERMINISTIC
```

而像：

```sql
RAND()
NOW()
```

这类结果可能变化的逻辑，不属于典型的确定性计算。

---

# 5. 四者核心区别

```text
VIEW
→ 保存 SELECT 查询逻辑
→ SELECT 查询

Procedure
→ 保存一组 SQL 操作
→ CALL 调用

Trigger
→ 表发生指定事件后自动执行
→ 不需要 CALL

Function
→ 接收参数并返回一个值
→ 可以在 SELECT 中使用
```

---

# 6. Day 12 验收结论

今天验收题：

```text
10 / 10
```

全部答对。

已经掌握：

- VIEW 保存的是 SELECT 查询逻辑
- VIEW 适合封装复杂、重复查询
- Procedure 使用 CALL
- Procedure 可以接收 IN 参数
- DELIMITER 的作用
- Trigger 自动执行机制
- AFTER INSERT
- FOR EACH ROW
- NEW / OLD
- Function 使用 SELECT
- Function 必须返回值
- DETERMINISTIC 的基本含义

## Day 12 完成

```text
VIEW       ✅
Procedure  ✅
Trigger    ✅
Function   ✅
```
