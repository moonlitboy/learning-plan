# Day 11 — Transaction + ACID + Isolation + Lock

## 1. 今日目标

掌握：

- Transaction（事务）
- `START TRANSACTION`
- `COMMIT`
- `ROLLBACK`
- ACID
- 四种事务隔离级别
- 脏读 / 不可重复读 / 幻读
- S 锁 / X 锁
- 普通锁等待
- Deadlock（死锁）

---

## 2. Transaction 事务

事务可以把多条 SQL 当成一个整体处理。

```sql
START TRANSACTION;

-- 执行若干 SQL

COMMIT;
```

或者：

```sql
ROLLBACK;
```

### COMMIT

提交事务，保存本次事务中的修改。

### ROLLBACK

回滚当前还没有提交的事务，撤销本次事务中的修改。

已经 `COMMIT` 的事务不能再通过后面的 `ROLLBACK` 撤销。

---

## 3. 实验：COMMIT

Terminal A：

```sql
USE study_mysql;

SELECT id, name, enroll_year
FROM students
WHERE id = 1;
```

初始数据：

```text
id = 1
name = 张三
enroll_year = 2026
```

然后：

```sql
START TRANSACTION;

UPDATE students
SET enroll_year = 2025
WHERE id = 1;
```

A 中可以看到：

```text
2025
```

此时 Terminal B 查询仍然看到：

```text
2026
```

A 执行：

```sql
COMMIT;
```

B 再查询：

```text
2025
```

结论：

> 未提交修改不会直接对其他事务可见；`COMMIT` 后修改正式生效。

---

## 4. 实验：ROLLBACK

Terminal A：

```sql
START TRANSACTION;

UPDATE students
SET enroll_year = 2026
WHERE id = 1;

SELECT id, name, enroll_year
FROM students
WHERE id = 1;
```

事务内部可以看到：

```text
2026
```

然后：

```sql
ROLLBACK;
```

再次查询：

```text
2025
```

结论：

> `ROLLBACK` 会撤销当前事务中还没有提交的修改。

---

## 5. ACID

### A — Atomicity 原子性

一个事务中的操作：

> 要么全部成功，要么全部失败。

例如转账时，扣款和加款应该作为一个整体完成。

### C — Consistency 一致性

事务执行前后，数据库都应该满足原有的规则、约束和业务一致性要求。

### I — Isolation 隔离性

多个事务并发执行时，要控制它们彼此能看到什么、如何互相影响。

### D — Durability 持久性

事务一旦 `COMMIT` 成功，结果应该被持久保存。

---

## 6. 四种事务隔离级别

从弱到强：

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

MySQL InnoDB 默认：

```text
REPEATABLE READ
```

可查看：

```sql
SELECT @@transaction_isolation;
```

### READ UNCOMMITTED

可以读取其他事务还没有提交的数据。

可能发生：

```text
脏读
```

### READ COMMITTED

只能读取已经提交的数据。

可以防止脏读，但同一个事务中两次查询之间，如果其他事务提交了修改，结果可能发生变化。

### REPEATABLE READ

同一个事务中的普通一致性读取保持稳定的读取视角。

MySQL InnoDB 默认使用该隔离级别。

普通 `SELECT` 主要依靠 MVCC / 一致性快照。

### SERIALIZABLE

隔离最强。

并发事务之间的冲突操作更容易发生等待，可以防止脏读、不可重复读和幻读，但并发能力更低。

---

## 7. 三种并发读取问题

### 脏读 Dirty Read

读取到了其他事务还没有 `COMMIT` 的数据。

```text
A 修改 2025 → 2026
A 没提交
B 已经读到 2026
A ROLLBACK
```

B 读到的 `2026` 就是脏数据。

### 不可重复读 Non-repeatable Read

同一个事务里，对同一条记录读取两次，结果不同。

```text
第一次：2025
第二次：2026
```

重点：

> 同一行的值发生变化。

### 幻读 Phantom Read

同一个事务里，用同样的查询条件执行两次查询，记录集合发生变化。

```text
第一次：5 行
第二次：6 行
```

重点：

> 多了或少了符合条件的记录。

---

## 8. Lock 锁

锁主要用于控制多个事务同时操作相同数据时的冲突。

### X Lock — Exclusive Lock 排他锁

`UPDATE` / `DELETE` 等修改操作会自动需要排他锁。

例如：

```sql
UPDATE students
SET enroll_year = 2026
WHERE id = 1;
```

如果 Terminal A 已经修改 `id = 1` 且事务未结束，Terminal B 再修改同一行时会等待。

---

## 9. 锁等待实验

Terminal A：

```sql
START TRANSACTION;

UPDATE students
SET enroll_year = 2026
WHERE id = 1;
```

不要提交。

Terminal B：

```sql
START TRANSACTION;

UPDATE students
SET enroll_year = 2024
WHERE id = 1;
```

B 会等待。

然后 A：

```sql
ROLLBACK;
```

A 释放锁后，B 的 `UPDATE` 继续执行并出现 `Query OK`。

最后 B：

```sql
ROLLBACK;
```

撤销 B 自己的修改。

结论：

```text
A 持有冲突锁
↓
B 修改同一行
↓
B 等待
↓
A COMMIT / ROLLBACK
↓
锁释放
↓
B 继续
```

---

## 10. S Lock — Shared Lock 共享锁

使用：

```sql
SELECT *
FROM students
WHERE id = 1
FOR SHARE;
```

可以理解为：

> 我要读取并保护这条数据；其他事务也可以一起共享读取，但冲突修改需要等待。

兼容关系：

```text
S + S  → 可以共存
S + X  → 冲突
X + X  → 冲突
```

---

## 11. 普通 SELECT / FOR SHARE / UPDATE

```sql
SELECT * FROM students WHERE id = 1;
```

默认更接近：

```text
普通一致性读 / 快照读
```

```sql
SELECT * FROM students
WHERE id = 1
FOR SHARE;
```

更接近：

```text
S 锁
```

```sql
UPDATE students
SET name = '测试'
WHERE id = 1;
```

会自动需要：

```text
X 锁
```

---

## 12. Deadlock 死锁

普通锁等待：

```text
A 等 B
B 最后释放锁
A 继续
```

死锁：

```text
A 持有 id = 1，等待 id = 2
B 持有 id = 2，等待 id = 1
```

形成：

```text
A 等 B
B 又等 A
```

这就是 Deadlock。

---

## 13. 今日总结

```text
Transaction
├── START TRANSACTION
├── COMMIT
└── ROLLBACK

ACID
├── A Atomicity      原子性
├── C Consistency    一致性
├── I Isolation      隔离性
└── D Durability     持久性

Isolation
├── READ UNCOMMITTED
├── READ COMMITTED
├── REPEATABLE READ   ← MySQL InnoDB 默认
└── SERIALIZABLE

Read Problems
├── 脏读
├── 不可重复读
└── 幻读

Lock
├── 普通 SELECT       → 快照读
├── FOR SHARE         → S 锁
├── UPDATE / DELETE   → X 锁
└── Deadlock          → 循环等待
```

Day 11 完成。
