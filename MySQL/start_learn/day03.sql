INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260002', '李四', 'li@example.com', 2026),
('20260003', '王五', 'wang@example.com', 2025),
('20260004', '赵六', 'zhao@example.com', 2025),
('20260005', '陈晨', 'chen@example.com', 2024),
('20260006', '刘洋', 'liu@example.com', 2026);

SELECT * FROM students;

INSERT INTO students
(student_no, name, email, enroll_year)
VALUES
('20260007', '张伟', 'zhangwei@example.com', 2024),
('20260008', '孙悦', 'sun@example.com', 2025),
('20260009', '周杰', NULL, 2026),
('20260010', '吴桐', 'wu@example.com', 2024),
('20260011', '郑凯', 'zheng@example.com', 2025),
('20260012', '张敏', 'zhangmin@example.com', 2026),
('20260013', '冯雪', NULL, 2025),
('20260014', '何宇', 'he@example.com', 2024),
('20260015', '高峰', 'gao@example.com', 2026);

SELECT * FROM students;

SELECT COUNT(*) FROM students;

INSERT INTO teachers
(teacher_no, name, email)
VALUES
('T001', '李明', 'liming@school.com'),
('T002', '王芳', 'wangfang@school.com'),
('T003', '张强', 'zhangqiang@school.com'),
('T004', '陈静', 'chenjing@school.com'),
('T005', '刘伟', 'liuwei@school.com');

SELECT * FROM teachers;

SELECT COUNT(*) FROM teachers;

INSERT INTO courses
(course_code, course_name, credits, capacity)
VALUES
('C001', 'C语言程序设计', 4.0, 60),
('C002', '数据结构', 4.0, 50),
('C003', '计算机网络', 3.5, 50),
('C004', '数据库原理', 3.0, 45),
('C005', '操作系统', 4.0, 50),
('C006', 'Java程序设计', 3.5, 60),
('C007', 'Web前端开发', 2.5, 40),
('C008', 'Linux基础', 2.0, 40);

SELECT * FROM courses;

SELECT COUNT(*) FROM courses;

