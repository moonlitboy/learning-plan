-- ============================================
-- MySQL Day 08
-- Subquery + EXISTS + CTE
-- Database: study_mysql
-- ============================================

USE study_mysql;

-- ============================================
-- 1. 标量子查询
-- ============================================

-- 查看课程平均学分
SELECT AVG(credits)
FROM courses;

-- 查询学分高于平均学分的课程
SELECT *
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
);

-- 独立练习：只显示课程编号、课程名、学分
SELECT
    course_code,
    course_name,
    credits
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
);


-- ============================================
-- 2. IN + 子查询
-- ============================================

-- 查看 enrollments 中出现过的 student_id
SELECT student_id
FROM enrollments;

-- 查询有选课记录的学生
SELECT *
FROM students
WHERE id IN (
    SELECT student_id
    FROM enrollments
);

-- 独立练习：只显示学号和姓名
SELECT
    student_no,
    name
FROM students
WHERE id IN (
    SELECT student_id
    FROM enrollments
);


-- ============================================
-- 3. EXISTS
-- ============================================

-- 查询有选课记录的学生
SELECT *
FROM students AS s
WHERE EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.id
);


-- ============================================
-- 4. NOT EXISTS
-- ============================================

-- 查询没有选课记录的学生
SELECT *
FROM students AS s
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.id
);

-- 独立练习：只显示学号和姓名
SELECT
    student_no,
    name
FROM students
WHERE NOT EXISTS (
    SELECT 1
    FROM enrollments
    WHERE students.id = enrollments.student_id
);


-- ============================================
-- 5. CTE
-- ============================================

-- 统计每个学生的选课数量，只保留至少 2 门的学生
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


-- ============================================
-- 6. CTE + JOIN
-- ============================================

-- 显示选课至少 2 门学生的姓名和选课数量
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


-- ============================================
-- 7. 独立综合练习
-- ============================================

-- 使用 COUNT(course_id) 统计每个学生选课数
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


-- 显示学号、姓名、选课数量，并按选课数量倒序
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


-- ============================================
-- Day 08 完成
-- ============================================
