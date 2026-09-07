-- =========================================
-- MySQL Day 04
-- SELECT 基础查询
-- =========================================


-- 查询所有2026年入学的学生
SELECT * FROM students
WHERE enroll_year = 2026;

-- 查询邮箱为空的学生
SELECT * FROM students
WHERE email IS NULL;

-- 查询邮箱不为空的学生
SELECT * FROM students
WHERE email IS NOT NULL;

-- 查询所有姓张的学生
SELECT * FROM students
WHERE name LIKE '张%';

-- 查询2025或2026年入学的学生
SELECT * FROM students
WHERE enroll_year IN (2025, 2026);

-- 查询学分在2～4之间的课程
SELECT * FROM courses
WHERE credits BETWEEN 2 AND 4;

-- 查询所有课程，并按学分从高到低排序
SELECT * FROM courses
ORDER BY credits DESC;

-- 查询前三条课程
SELECT * FROM courses
LIMIT 3;
