-- =====================================================================
-- Day 14 · CampusDB 最终综合查询
-- 文件位置：project/query.sql
-- 说明：整理了 Day 14 在 Terminal 中实际完成的查询与验收实验。
-- 本文件的主体是只读 SELECT，适合在 SQLTools 中分段执行。
-- 建索引属于一次性 DDL，保留为注释，避免重跑时报 Duplicate key name。
-- =====================================================================

USE campus_db;

-- ---------------------------------------------------------------------
-- Part 4：20 类综合查询（编号对应 14 天计划的 Day 14 清单）
-- ---------------------------------------------------------------------

-- 01. 查询所有学生（实际返回 30 行）
SELECT *
FROM students;

-- 02. 查询 2026 年入学的学生（实际返回 10 行）
SELECT *
FROM students
WHERE enroll_year = 2026;

-- 03. 查询所有并列最高学分课程（实际返回 4 门，均为 4.0 学分）
SELECT *
FROM courses
WHERE credits = (
    SELECT MAX(credits)
    FROM courses
);

-- 04. 统计学生人数（实际 30 人）
SELECT COUNT(*) AS student_count
FROM students;

-- 05. 每届学生人数（2024/2025/2026 各 10 人）
SELECT enroll_year, COUNT(*) AS total
FROM students
GROUP BY enroll_year
ORDER BY enroll_year;

-- 06. 所有课程平均学分（原始 AVG 结果 3.13333，四舍五入后 3.13）
SELECT ROUND(AVG(credits), 2) AS avg_credits
FROM courses;

-- 07. 每个已选课学生选了哪些课程（实际 100 条选课记录）
SELECT
    s.student_id,
    s.student_name,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
JOIN courses AS c
    ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;

-- 08. 每门课程有哪些学生（同样 100 条，按课程、学生编号排序）
SELECT
    c.course_id,
    c.course_name,
    s.student_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
JOIN courses AS c
    ON e.course_id = c.course_id
ORDER BY c.course_id, s.student_id;

-- 09. 没有选课的学生（实际 26～30，共 5 人）
SELECT
    s.student_id,
    s.student_name
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
WHERE e.course_id IS NULL
ORDER BY s.student_id;

-- 10. 至少选 3 门课程的学生（实际 1～20，共 20 人）
-- 这里“3 门及以上”明确使用 >= 3；如果题意是严格超过 3 门，则改成 > 3。
SELECT
    s.student_id,
    s.student_name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(e.course_id) >= 3
ORDER BY s.student_id;

-- 11. 每门课程的平均成绩，保留两位小数（实际覆盖 15 门）
SELECT
    c.course_id,
    c.course_name,
    ROUND(AVG(e.score), 2) AS avg_score
FROM courses AS c
JOIN enrollments AS e
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY c.course_id;

-- 12. 成绩高于所有选课记录平均成绩的“学生-课程记录”（实际 52 行）
-- 注意：这是高于“全体选课记录平均分”，不是高于“各自课程平均分”。
SELECT
    s.student_name,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
JOIN courses AS c
    ON e.course_id = c.course_id
WHERE e.score > (
    SELECT AVG(score)
    FROM enrollments
)
ORDER BY s.student_id, c.course_id;

-- 13. 子查询专项：学分高于全体课程平均学分的课程
-- 与第 03 / 12 题的标量子查询是同一知识点的另一个应用。
SELECT
    course_id,
    course_name,
    credits
FROM courses
WHERE credits > (
    SELECT AVG(credits)
    FROM courses
)
ORDER BY credits DESC, course_id ASC;

-- 14. EXISTS：至少选过一门课的学生（实际 1～25，共 25 人）
SELECT
    s.student_id,
    s.student_name
FROM students AS s
WHERE EXISTS (
    SELECT 1
    FROM enrollments AS e
    WHERE e.student_id = s.student_id
)
ORDER BY s.student_id;

-- 15. CTE：先统计选课数量，再查询至少选 4 门课的学生（实际 20 人）
WITH student_course_stats AS (
    SELECT
        student_id,
        COUNT(course_id) AS course_count
    FROM enrollments
    GROUP BY student_id
)
SELECT
    s.student_id,
    s.student_name,
    scs.course_count
FROM students AS s
JOIN student_course_stats AS scs
    ON s.student_id = scs.student_id
WHERE scs.course_count >= 4
ORDER BY s.student_id;

-- 16. 三表 JOIN 专项：学生、选课、课程（与第 07 题同一三表关系）
SELECT
    s.student_id,
    s.student_name,
    c.course_id,
    c.course_name,
    e.score
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
JOIN courses AS c
    ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;

-- 17. LEFT JOIN：所有 30 人的选课数，没选课的显示 0
-- 不能用 COUNT(*) 统计没有匹配右表记录的情况。
SELECT
    s.student_id,
    s.student_name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name
ORDER BY s.student_id;

-- 18. GROUP BY 专项：按学院统计学生人数
SELECT
    d.department_id,
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM departments AS d
LEFT JOIN students AS s
    ON d.department_id = s.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_id;

-- 19. HAVING 专项：至少选 3 门课程的学生（复习第 10 题）
SELECT
    e.student_id,
    COUNT(*) AS course_count
FROM enrollments AS e
GROUP BY e.student_id
HAVING COUNT(*) >= 3
ORDER BY e.student_id;

-- 20. LIMIT：学分最高的前 3 条（并列时按 course_id 稳定排序）
-- 该题与第 03 题不同：LIMIT 3 只返回 3 行，不包含全部并列最高课程。
SELECT *
FROM courses
ORDER BY credits DESC, course_id ASC
LIMIT 3;

-- ---------------------------------------------------------------------
-- 当天额外完成的查询
-- ---------------------------------------------------------------------

-- DISTINCT：52 条高于全体平均分的选课记录中，实际涉及 25 个不同学生。
SELECT DISTINCT
    s.student_id,
    s.student_name
FROM students AS s
JOIN enrollments AS e
    ON s.student_id = e.student_id
WHERE e.score > (
    SELECT AVG(score)
    FROM enrollments
)
ORDER BY s.student_id;

-- UNION ALL：将五张表的计数结果纵向拼接；恢复库验收实际为 3/10/30/15/100。
-- 如需核对恢复库，请先单独执行 USE campus_db_restore; 再执行这条统计。
SELECT 'departments' AS table_name, COUNT(*) AS total
FROM departments
UNION ALL
SELECT 'teachers', COUNT(*) FROM teachers
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'courses', COUNT(*) FROM courses
UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments;

-- ---------------------------------------------------------------------
-- Part 5：索引 + EXPLAIN（本项目已实际验证）
-- ---------------------------------------------------------------------

-- 已实际创建：
-- CREATE INDEX idx_students_enroll_year ON students(enroll_year);
-- 只在该索引尚不存在时执行上面这条 DDL，重跑已有索引会报错。

SHOW INDEX FROM students;

-- 不建索引时观测到：type=ALL，possible_keys/key=NULL，rows=30。
-- 建索引后观测到：type=ref，key=idx_students_enroll_year，rows=10。
EXPLAIN
SELECT *
FROM students
WHERE enroll_year = 2026;

-- 当前已建索引的真实执行数据（某次运行）：
-- Index lookup，actual time=0.0557..0.0827 ms，rows=10，loops=1。
EXPLAIN ANALYZE
SELECT *
FROM students
WHERE enroll_year = 2026;

-- 强制忽略新索引，同一次实验观测：
-- Table scan rows=30；上层 Filter 输出 rows=10，最终约 0.0929 ms。
EXPLAIN ANALYZE
SELECT *
FROM students IGNORE INDEX (idx_students_enroll_year)
WHERE enroll_year = 2026;

-- 索引方案在这一次运行中略快，但 30 行的小表不足以证明稳定的性能提升。
-- enroll_year 只有 3 个不同年份，区分度偏低；是否保留应结合真实查询频率、
-- 数据规模、命中比例、回表成本、组合查询及写入维护成本判断。

-- ---------------------------------------------------------------------
-- Part 6～8：事务、备份、恢复命令详见 notes/day14.md。
-- 事务需要两个独立 Session；mysqldump / 重定向需要在系统 Terminal 执行。
-- 保持本 query.sql 主体为可重复执行的只读查询，避免误改项目数据。
-- ---------------------------------------------------------------------
