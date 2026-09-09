-- =========================================
-- MySQL Day 06
-- Foreign Key + JOIN
-- =========================================

USE study_mysql;

-- 1. 查看基础表结构
DESC students;
DESC courses;

-- 2. 创建选课中间表
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

-- 3. 查看表结构与约束
SHOW TABLES;
DESC enrollments;
SHOW CREATE TABLE enrollments;

-- 4. 插入第一条选课记录
INSERT INTO enrollments
(student_id, course_id, score)
VALUES
(1, 1, 88.50);

SELECT * FROM enrollments;

-- 5. 外键约束测试（预期报错：student_id=9999 不存在）
-- INSERT INTO enrollments
-- (student_id, course_id, score)
-- VALUES
-- (9999, 1, 90.00);

-- 6. 联合 UNIQUE 测试（预期报错：(1, 1) 已存在）
-- INSERT INTO enrollments
-- (student_id, course_id, score)
-- VALUES
-- (1, 1, 95.00);

-- 7. 添加练习数据
INSERT INTO enrollments
(student_id, course_id, score)
VALUES
(1, 2, 92.00),
(3, 1, 85.50),
(3, 3, 89.00),
(4, 2, 76.00),
(5, 4, 91.50),
(6, 1, 88.00);

SELECT * FROM enrollments;

-- =========================================
-- JOIN
-- =========================================

-- 8. 两表 INNER JOIN：选课记录 + 学生
SELECT
    e.student_id,
    s.name,
    e.course_id,
    e.score
FROM enrollments AS e
INNER JOIN students AS s
    ON e.student_id = s.id;

-- 9. 三表 INNER JOIN：学生 + 选课 + 课程
SELECT
    s.name,
    c.course_name,
    e.score
FROM enrollments AS e
INNER JOIN students AS s
    ON e.student_id = s.id
INNER JOIN courses AS c
    ON e.course_id = c.id;

-- 10. LEFT JOIN：保留所有学生
SELECT
    s.name,
    e.course_id
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id;

-- 11. INNER JOIN：只保留有选课记录的学生
SELECT
    s.name,
    e.course_id
FROM students AS s
INNER JOIN enrollments AS e
    ON s.id = e.student_id;

-- 12. 查询没有选课的学生
SELECT
    s.id,
    s.name
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
WHERE e.student_id IS NULL;

-- 13. 三表 LEFT JOIN：所有学生 + 课程 + 成绩
SELECT
    s.name,
    c.course_name,
    e.score
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
LEFT JOIN courses AS c
    ON e.course_id = c.id;

-- =========================================
-- JOIN + GROUP BY + HAVING
-- =========================================

-- 14. 每个学生选了几门课（包括 0 门）
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name;

-- 15. 每门课程有多少学生选择（包括 0 人）
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name;

-- 16. 选课人数不少于 2 人的课程
SELECT
    c.course_name,
    COUNT(e.student_id) AS student_count
FROM courses AS c
LEFT JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING student_count >= 2;

-- 17. 平均成绩不低于 85 分的课程
SELECT
    c.course_name,
    AVG(e.score) AS avg_score
FROM courses AS c
INNER JOIN enrollments AS e
    ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING avg_score >= 85;

-- 18. 选了至少 2 门课程的学生
SELECT
    s.name,
    COUNT(e.course_id) AS course_count
FROM students AS s
INNER JOIN enrollments AS e
    ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING course_count >= 2;
