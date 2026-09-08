-- =========================================
-- MySQL Day 05
-- 聚合函数 + GROUP BY + HAVING
-- =========================================


-- =========================================
-- 1. 基础聚合函数
-- =========================================

-- 统计学生总人数
SELECT COUNT(*) AS total_students
FROM students;


-- 计算课程平均学分
SELECT AVG(credits) AS avg_credits
FROM courses;


-- 查询最高课程学分
SELECT MAX(credits) AS max_credits
FROM courses;


-- 查询最低课程学分
SELECT MIN(credits) AS min_credits
FROM courses;


-- 统计所有课程容量总和
SELECT SUM(capacity) AS total_capacity
FROM courses;



-- =========================================
-- 2. COUNT(*) 与 COUNT(column)
-- =========================================

-- COUNT(*)：统计所有行
SELECT COUNT(*) AS total_students
FROM students;


-- COUNT(email)：只统计 email 不为 NULL 的行
SELECT COUNT(email) AS students_with_email
FROM students;


-- 统计 email 为 NULL 的学生
SELECT COUNT(*) AS students_without_email
FROM students
WHERE email IS NULL;



-- =========================================
-- 3. GROUP BY 分组统计
-- =========================================

-- 按入学年份统计学生人数
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year;


-- 按课程学分统计课程数量
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
GROUP BY credits;



-- =========================================
-- 4. GROUP BY + 其他聚合函数
-- =========================================

-- 按课程学分分组，计算每组平均容量
SELECT
    credits,
    AVG(capacity) AS avg_capacity
FROM courses
GROUP BY credits;


-- 按课程学分分组，同时统计：
-- 课程数量、平均容量、最小容量、最大容量
SELECT
    credits,
    COUNT(*) AS course_count,
    AVG(capacity) AS avg_capacity,
    MIN(capacity) AS min_capacity,
    MAX(capacity) AS max_capacity
FROM courses
GROUP BY credits;



-- =========================================
-- 5. HAVING 筛选分组
-- =========================================

-- 按课程学分分组
-- 只保留课程数量至少为 2 的学分组
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
GROUP BY credits
HAVING COUNT(*) >= 2;


-- 按入学年份分组
-- 只保留学生人数至少为 5 的年份
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year
HAVING COUNT(*) >= 5;



-- =========================================
-- 6. WHERE + GROUP BY + HAVING
-- =========================================

-- 先筛选 2025 年及以后入学的学生
-- 再按入学年份分组
-- 最后只保留人数至少为 6 的年份
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
WHERE enroll_year >= 2025
GROUP BY enroll_year
HAVING COUNT(*) >= 6;


-- 先筛选学分至少为 3 的课程
-- 再按照学分分组
-- 最后只保留课程数量至少为 2 的组
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
WHERE credits >= 3
GROUP BY credits
HAVING COUNT(*) >= 2;



-- =========================================
-- 7. GROUP BY + HAVING + ORDER BY
-- =========================================

-- 统计每个入学年份的学生人数
-- 按人数从多到少排序
SELECT
    enroll_year,
    COUNT(*) AS student_count
FROM students
GROUP BY enroll_year
ORDER BY student_count DESC;


-- 统计每种学分的课程数量
-- 只显示课程数量至少为 2 的组
-- 按课程数量从多到少排序
SELECT
    credits,
    COUNT(*) AS course_count
FROM courses
GROUP BY credits
HAVING COUNT(*) >= 2
ORDER BY course_count DESC;



-- =========================================
-- 8. 今日综合查询
-- =========================================

-- 只考虑学分至少为 3 的课程
-- 按学分分组
-- 统计每组课程数量
-- 计算每组平均容量
-- 只保留课程数量至少为 2 的组
-- 按平均容量从高到低排序
SELECT
    credits,
    COUNT(*) AS course_count,
    AVG(capacity) AS avg_capacity
FROM courses
WHERE credits >= 3
GROUP BY credits
HAVING COUNT(*) >= 2
ORDER BY avg_capacity DESC;



-- =========================================
-- Day 05 核心总结
-- =========================================

-- 聚合函数：
-- COUNT()  统计数量
-- SUM()    求和
-- AVG()    求平均值
-- MAX()    求最大值
-- MIN()    求最小值

-- COUNT(*)：
-- 统计所有行

-- COUNT(column)：
-- 只统计该字段不为 NULL 的行

-- WHERE：
-- 在 GROUP BY 之前筛选原始数据行

-- GROUP BY：
-- 按指定字段进行分组

-- HAVING：
-- 在 GROUP BY 之后筛选分组结果

-- SQL 书写顺序：
-- SELECT
-- FROM
-- WHERE
-- GROUP BY
-- HAVING
-- ORDER BY
-- LIMIT

-- SQL 逻辑执行顺序：
-- FROM
-- WHERE
-- GROUP BY
-- HAVING
-- SELECT
-- ORDER BY
-- LIMIT