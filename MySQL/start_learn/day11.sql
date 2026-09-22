-- ============================================
-- Day 11
-- Transaction + ACID + Isolation + Lock
-- ============================================

USE study_mysql;

-- ============================================
-- 1. 基线数据
-- ============================================

SELECT id, name, enroll_year
FROM students
WHERE id = 1;


-- ============================================
-- 2. COMMIT 实验
-- Terminal A
-- ============================================

START TRANSACTION;

UPDATE students
SET enroll_year = 2025
WHERE id = 1;

SELECT id, name, enroll_year
FROM students
WHERE id = 1;

-- 此时去 Terminal B 查询同一行，
-- 在 A 未提交时，B 不应直接看到 A 的未提交修改。

COMMIT;


-- ============================================
-- 3. ROLLBACK 实验
-- Terminal A
-- ============================================

START TRANSACTION;

UPDATE students
SET enroll_year = 2026
WHERE id = 1;

SELECT id, name, enroll_year
FROM students
WHERE id = 1;

ROLLBACK;

SELECT id, name, enroll_year
FROM students
WHERE id = 1;


-- ============================================
-- 4. 查看当前事务隔离级别
-- ============================================

SELECT @@transaction_isolation;


-- ============================================
-- 5. 设置事务隔离级别
-- 注意：以下语句用于学习和实验
-- ============================================

-- READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;


-- ============================================
-- 6. 恢复到 MySQL InnoDB 常用默认级别
-- ============================================

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;


-- ============================================
-- 7. 锁等待实验
-- Terminal A
-- ============================================

START TRANSACTION;

UPDATE students
SET enroll_year = 2026
WHERE id = 1;

-- 不要立刻 COMMIT / ROLLBACK
-- 此时去 Terminal B 执行：
--
-- START TRANSACTION;
--
-- UPDATE students
-- SET enroll_year = 2024
-- WHERE id = 1;
--
-- B 会等待 A 释放相关锁。

ROLLBACK;


-- ============================================
-- 8. Terminal B
-- A 释放锁后，B 的 UPDATE 会继续执行
-- 最后在 B 中回滚，避免真的修改数据
-- ============================================

-- ROLLBACK;


-- ============================================
-- 9. S Lock / Shared Lock
-- ============================================

START TRANSACTION;

SELECT *
FROM students
WHERE id = 1
FOR SHARE;

ROLLBACK;


-- ============================================
-- 10. SELECT ... FOR UPDATE
-- ============================================

START TRANSACTION;

SELECT *
FROM students
WHERE id = 1
FOR UPDATE;

ROLLBACK;


-- ============================================
-- 11. 普通一致性读
-- ============================================

SELECT *
FROM students
WHERE id = 1;


-- ============================================
-- Day 11 核心记忆
-- ============================================

-- START TRANSACTION : 开始事务
-- COMMIT            : 提交事务
-- ROLLBACK          : 回滚未提交事务
--
-- ACID:
-- A = Atomicity     原子性
-- C = Consistency   一致性
-- I = Isolation     隔离性
-- D = Durability    持久性
--
-- Isolation:
-- READ UNCOMMITTED
-- READ COMMITTED
-- REPEATABLE READ
-- SERIALIZABLE
--
-- MySQL InnoDB 默认：
-- REPEATABLE READ
--
-- 脏读：
-- 读取到了其他事务还没有 COMMIT 的数据
--
-- 不可重复读：
-- 同一个事务中，同一条记录两次读取结果不同
--
-- 幻读：
-- 同一个事务中，相同条件两次查询得到的记录集合不同
--
-- Lock:
-- 普通 SELECT      -> 一致性读 / 快照读
-- FOR SHARE        -> S 锁
-- UPDATE / DELETE  -> X 锁
--
-- S + S  -> 可以共存
-- S + X  -> 冲突
-- X + X  -> 冲突
--
-- Deadlock:
-- 多个事务形成循环锁等待
