-- =========================================
-- Day 10 - INDEX + EXPLAIN
-- Database: study_mysql
-- =========================================

USE study_mysql;

-- =========================================
-- 1. 查看 students 当前已有索引
-- =========================================

SHOW INDEX FROM students;


-- =========================================
-- 2. 建索引前：查看 name 查询的执行计划
-- =========================================

EXPLAIN
SELECT *
FROM students
WHERE name = '张三';


-- =========================================
-- 3. 为 name 创建普通索引
-- =========================================

CREATE INDEX idx_students_name
ON students(name);


-- =========================================
-- 4. 建索引后：再次查看执行计划
-- =========================================

EXPLAIN
SELECT *
FROM students
WHERE name = '张三';


-- =========================================
-- 5. 使用 EXPLAIN ANALYZE
--    会真正执行查询，并显示实际执行信息
-- =========================================

EXPLAIN ANALYZE
SELECT *
FROM students
WHERE name = '张三';


-- =========================================
-- 6. 再次查看索引
-- =========================================

SHOW INDEX FROM students;


-- =========================================
-- 7. 创建联合索引
--    索引顺序：enroll_year -> name
-- =========================================

CREATE INDEX idx_year_name
ON students(enroll_year, name);


-- =========================================
-- 8. 查看联合索引
--    SHOW INDEX 中会显示两行：
--    Seq_in_index = 1 -> enroll_year
--    Seq_in_index = 2 -> name
-- =========================================

SHOW INDEX FROM students;


-- =========================================
-- 9. 联合索引实验
-- =========================================

-- 两个字段都参与条件
EXPLAIN
SELECT *
FROM students
WHERE enroll_year = 2026
  AND name = '张三';


-- 只使用联合索引最左列 enroll_year
EXPLAIN
SELECT *
FROM students
WHERE enroll_year = 2026;


-- =========================================
-- 10. LIKE 与索引（概念实验，可选）
-- =========================================

-- 通常更容易利用普通 B-tree 索引
EXPLAIN
SELECT *
FROM students
WHERE name LIKE '张%';

-- 前导通配符通常不利于普通 B-tree 索引查找
EXPLAIN
SELECT *
FROM students
WHERE name LIKE '%张%';


-- =========================================
-- 11. 删除索引（仅语法练习）
-- 注意：如果后续还想保留今天创建的索引，
-- 不要执行下面两条。
-- =========================================

-- DROP INDEX idx_students_name ON students;
-- DROP INDEX idx_year_name ON students;
