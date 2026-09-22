-- =========================================================
-- Day 12
-- VIEW + Procedure + Trigger + Function
-- Database: study_mysql
-- =========================================================

USE study_mysql;

-- =========================================================
-- Part 1: VIEW
-- 推荐：SQLTools
-- =========================================================

-- 创建学生-课程-成绩视图
CREATE OR REPLACE VIEW student_course_view AS
SELECT
    s.name,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.id = e.student_id
JOIN courses AS c
    ON c.id = e.course_id;

-- 查询视图
SELECT *
FROM student_course_view;

-- 查看普通表 / VIEW 类型
SHOW FULL TABLES;

-- 查看 VIEW 定义
SHOW CREATE VIEW student_course_view;

-- 修改 VIEW：示例，临时去掉 score
CREATE OR REPLACE VIEW student_course_view AS
SELECT
    s.name,
    c.course_name
FROM students AS s
JOIN enrollments AS e
    ON s.id = e.student_id
JOIN courses AS c
    ON c.id = e.course_id;

SELECT *
FROM student_course_view;

-- 恢复 score
CREATE OR REPLACE VIEW student_course_view AS
SELECT
    s.name,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.id = e.student_id
JOIN courses AS c
    ON c.id = e.course_id;

-- 删除 VIEW（需要时再执行）
-- DROP VIEW student_course_view;


-- =========================================================
-- Part 2: Procedure
-- 注意：
-- 当前 SQLTools 环境直接执行 DELIMITER 会报错。
-- 以下带 DELIMITER 的内容请在 mysql Terminal 中执行。
-- =========================================================

-- 无参数 Procedure
DROP PROCEDURE IF EXISTS show_students;

DELIMITER //

CREATE PROCEDURE show_students()
BEGIN
    SELECT * FROM students;

    SELECT COUNT(*) AS total
    FROM students;
END //

DELIMITER ;

CALL show_students();


-- 带 IN 参数 Procedure
DROP PROCEDURE IF EXISTS show_students_by_year;

DELIMITER //

CREATE PROCEDURE show_students_by_year(IN p_year INT)
BEGIN
    SELECT *
    FROM students
    WHERE enroll_year = p_year;
END //

DELIMITER ;

CALL show_students_by_year(2026);
CALL show_students_by_year(2025);

SHOW CREATE PROCEDURE show_students_by_year;


-- =========================================================
-- Part 3: Trigger
-- mysql Terminal
-- =========================================================

-- 日志表
CREATE TABLE IF NOT EXISTS student_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DESC student_logs;
SELECT * FROM student_logs;

-- 如需重新创建 Trigger，可先删除
DROP TRIGGER IF EXISTS after_student_insert;

DELIMITER //

CREATE TRIGGER after_student_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO student_logs (student_name)
    VALUES (NEW.name);
END //

DELIMITER ;

-- 查看 Trigger
SHOW TRIGGERS;
SHOW CREATE TRIGGER after_student_insert;

-- 测试 Trigger
-- 注意：如果 student_no='20260020' 已存在，不要重复执行下面 INSERT。
-- INSERT INTO students
-- (student_no, name, email, enroll_year)
-- VALUES
-- ('20260020', '测试学生', 'test20@example.com', 2026);

-- 查看 Trigger 自动生成的日志
SELECT *
FROM student_logs;

-- NEW / OLD 记忆：
-- INSERT -> NEW
-- DELETE -> OLD
-- UPDATE -> OLD + NEW


-- =========================================================
-- Part 4: Function
-- mysql Terminal
-- =========================================================

DROP FUNCTION IF EXISTS add_one;

DELIMITER //

CREATE FUNCTION add_one(n INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN n + 1;
END //

DELIMITER ;

-- 调用 Function
SELECT add_one(10);
SELECT add_one(99) AS ok;

-- 查看函数定义
SHOW CREATE FUNCTION add_one;

-- 删除 Function（需要时再执行）
-- DROP FUNCTION IF EXISTS add_one;


-- =========================================================
-- Day 12 Summary
-- =========================================================
-- VIEW       -> 保存 SELECT 查询逻辑
-- Procedure  -> CALL 调用一组 SQL
-- Trigger    -> 指定事件发生后自动执行
-- Function   -> SELECT 中调用，并返回一个值
