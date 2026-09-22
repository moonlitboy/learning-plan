USE campus_db;
SELECT DATABASE();
DESC departments;

INSERT INTO departments (department_name)
VALUES 
('计算机学院'),
('数学学院'),
('外国语学院');

SELECT *
FROM departments;

DESC teachers;

-- ========================================
-- teachers：10 条
-- ========================================

INSERT INTO teachers
(teacher_no, teacher_name, email, department_id)
VALUES
('T001', '张三', 'zhangsan@example.com', 1),
('T002', '李四', 'lisi@example.com', 2),
('T003', '王五', 'wangwu@example.com', 3),
('T004', '赵六', 'zhaoliu@example.com', 1),
('T005', '陈晨', 'chenchen@example.com', 1),
('T006', '刘洋', 'liuyang@example.com', 2),
('T007', '孙悦', 'sunyue@example.com', 3),
('T008', '周杰', 'zhoujie@example.com', 1),
('T009', '郑凯', 'zhengkai@example.com', 2),
('T010', '林雪', 'linxue@example.com', 3);

SELECT * FROM teachers;

-- ========================================
-- students：30 条
-- ========================================

INSERT INTO students
(student_no, student_name, email, enroll_year, department_id)
VALUES
('S001', '张伟', 'zhangwei@example.com', 2024, 1),
('S002', '李娜', 'lina@example.com', 2024, 2),
('S003', '王强', 'wangqiang@example.com', 2024, 3),
('S004', '赵敏', 'zhaomin@example.com', 2024, 1),
('S005', '陈浩', 'chenhao@example.com', 2024, 2),
('S006', '刘婷', 'liuting@example.com', 2024, 3),
('S007', '孙磊', 'sunlei@example.com', 2024, 1),
('S008', '周颖', 'zhouying@example.com', 2024, 2),
('S009', '郑涛', 'zhengtao@example.com', 2024, 3),
('S010', '林悦', 'linyue@example.com', 2024, 1),

('S011', '何宇', 'heyu@example.com', 2025, 1),
('S012', '高峰', 'gaofeng@example.com', 2025, 2),
('S013', '吴桐', 'wutong@example.com', 2025, 3),
('S014', '冯雪', 'fengxue@example.com', 2025, 1),
('S015', '许晨', 'xuchen@example.com', 2025, 2),
('S016', '马超', 'machao@example.com', 2025, 3),
('S017', '唐欣', 'tangxin@example.com', 2025, 1),
('S018', '宋阳', 'songyang@example.com', 2025, 2),
('S019', '韩梅', 'hanmei@example.com', 2025, 3),
('S020', '罗杰', 'luojie@example.com', 2025, 1),

('S021', '王宇轩', 'wangyuxuan@example.com', 2026, 1),
('S022', '张敏', 'zhangmin@example.com', 2026, 2),
('S023', '李晨', 'lichen@example.com', 2026, 3),
('S024', '赵凯', 'zhaokai@example.com', 2026, 1),
('S025', '陈雨', 'chenyu@example.com', 2026, 2),
('S026', '刘洋', 'liuyang.student@example.com', 2026, 3),
('S027', '孙浩', 'sunhao@example.com', 2026, 1),
('S028', '周雪', 'zhouxue@example.com', 2026, 2),
('S029', '郑宇', 'zhengyu@example.com', 2026, 3),
('S030', '林晨', 'linchen@example.com', 2026, 1);

SELECT * FROM students;

SELECT COUNT(*) AS student_count
FROM students;

SELECT enroll_year, COUNT(*) AS total
FROM students
GROUP BY enroll_year
ORDER BY enroll_year;

DESC courses;

-- ========================================
-- courses：15 条
-- ========================================

INSERT INTO courses
(course_code, course_name, credits, capacity, teacher_id)
VALUES
('C001', 'C语言程序设计', 4.0, 60, 1),
('C002', '数据结构', 4.0, 50, 1),
('C003', '计算机网络', 3.5, 45, 4),
('C004', '数据库原理', 3.5, 50, 5),
('C005', '操作系统', 4.0, 45, 8),

('M001', '高等数学', 4.0, 80, 2),
('M002', '线性代数', 3.0, 70, 6),
('M003', '概率论与数理统计', 3.0, 60, 9),
('M004', '离散数学', 3.5, 55, 2),
('M005', '数学建模', 2.5, 40, 6),

('E001', '大学英语', 3.0, 80, 3),
('E002', '英语口语', 2.0, 40, 7),
('E003', '英语写作', 2.5, 45, 10),
('E004', '英美文化', 2.0, 50, 3),
('E005', '科技英语', 2.5, 40, 7);

SELECT * FROM courses;

SELECT COUNT(*) AS course_count
FROM courses;

SELECT
    course_code,
    course_name,
    credits,
    teacher_id
FROM courses;

DESC enrollments;

-- ========================================
-- enrollments：100 条
-- ========================================

INSERT INTO enrollments (student_id, course_id, score)
VALUES
-- student 1
(1, 1, 92.50),
(1, 2, 88.00),
(1, 3, 90.50),
(1, 6, 86.00),
(1, 11, 91.00),

-- student 2
(2, 2, 85.50),
(2, 4, 93.00),
(2, 6, 89.50),
(2, 7, 87.00),
(2, 11, 94.00),

-- student 3
(3, 1, 78.50),
(3, 3, 84.00),
(3, 5, 82.50),
(3, 11, 90.00),
(3, 12, 88.00),

-- student 4
(4, 1, 95.00),
(4, 2, 91.50),
(4, 4, 96.00),
(4, 6, 89.00),
(4, 10, 87.50),

-- student 5
(5, 3, 82.00),
(5, 6, 86.50),
(5, 7, 90.00),
(5, 8, 88.50),
(5, 13, 92.00),

-- student 6
(6, 4, 76.50),
(6, 5, 81.00),
(6, 9, 85.00),
(6, 11, 89.50),
(6, 14, 87.00),

-- student 7
(7, 1, 90.00),
(7, 2, 92.50),
(7, 3, 88.00),
(7, 7, 84.50),
(7, 15, 91.00),

-- student 8
(8, 2, 79.50),
(8, 5, 83.00),
(8, 6, 86.00),
(8, 8, 90.50),
(8, 12, 88.00),

-- student 9
(9, 3, 94.00),
(9, 4, 92.00),
(9, 9, 89.50),
(9, 10, 91.00),
(9, 13, 87.00),

-- student 10
(10, 1, 88.50),
(10, 5, 90.00),
(10, 7, 85.50),
(10, 11, 93.00),
(10, 15, 89.00),

-- student 11
(11, 1, 82.00),
(11, 4, 87.50),
(11, 6, 91.00),
(11, 11, 86.00),

-- student 12
(12, 2, 90.00),
(12, 5, 88.50),
(12, 7, 92.00),
(12, 12, 84.00),

-- student 13
(13, 3, 86.50),
(13, 6, 89.00),
(13, 8, 91.50),
(13, 13, 87.00),

-- student 14
(14, 1, 93.00),
(14, 4, 90.50),
(14, 9, 88.00),
(14, 14, 92.00),

-- student 15
(15, 2, 80.00),
(15, 5, 85.50),
(15, 10, 89.00),
(15, 15, 87.50),

-- student 16
(16, 3, 91.00),
(16, 6, 94.00),
(16, 7, 88.50),
(16, 11, 90.00),

-- student 17
(17, 1, 84.50),
(17, 5, 89.00),
(17, 8, 86.00),
(17, 12, 92.50),

-- student 18
(18, 2, 95.00),
(18, 4, 93.50),
(18, 9, 90.00),
(18, 13, 88.00),

-- student 19
(19, 3, 81.50),
(19, 6, 85.00),
(19, 10, 87.50),
(19, 14, 90.00),

-- student 20
(20, 1, 89.50),
(20, 5, 91.00),
(20, 11, 93.50),
(20, 15, 88.00),

-- student 21
(21, 2, 92.00),
(21, 6, 88.50),

-- student 22
(22, 3, 85.00),
(22, 11, 90.50),

-- student 23
(23, 4, 94.00),
(23, 12, 89.00),

-- student 24
(24, 5, 87.50),
(24, 13, 91.00),

-- student 25
(25, 1, 86.00),
(25, 14, 93.00);

SELECT COUNT(*) AS enrollment_count
FROM enrollments;

SELECT
    student_id,
    COUNT(*) AS course_count
FROM enrollments
GROUP BY student_id
ORDER BY student_id;
