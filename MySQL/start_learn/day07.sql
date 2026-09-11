USE week1_test;

SELECT DATABASE();

CREATE TABLE teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    teacher_no VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(100) NOT NULL,
    credits DECIMAL(3,1) NOT NULL,
    capacity INT DEFAULT 50,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    score DECIMAL(5,2),

    CONSTRAINT fk_enrollments_student
    FOREIGN KEY (student_id)
    REFERENCES students(id),

    CONSTRAINT fk_enrollments_course
    FOREIGN KEY (course_id)
    REFERENCES courses(id),

    CONSTRAINT uq_enrollments_student_course
    UNIQUE (student_id, course_id)
);

SHOW TABLES;

INSERT INTO courses
(course_code, course_name, credits)
VALUES
('C001', 'C语言程序设计', 4.0),
('C002', '数据库原理', 3.5),
('C003', '计算机网络', 3.0);

SELECT * FROM courses;

DESC enrollments;

-- 然后继续完成选课数据：

-- 张三：C001、C002
-- 李四：C001
-- 成绩你自己定

INSERT INTO enrollments (student_id, course_id, score)
VALUES
((SELECT id FROM students WHERE name='张三'), (SELECT id FROM courses WHERE course_code='C001'), 90.0),
((SELECT id FROM students WHERE name='张三'), (SELECT id FROM courses WHERE course_code='C002'), 85.0),
((SELECT id FROM students WHERE name='李四'), (SELECT id FROM courses WHERE course_code='C001'), 88.0);

SELECT * FROM enrollments;

SELECT s.name, c.course_name, e.score
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id;

SELECT c.course_name, s.name
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
LEFT JOIN students s ON e.student_id = s.id;

SELECT s.name, COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
GROUP BY s.name;

SELECT s.name, AVG(e.score) AS average_score
FROM students s
INNER JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING average_score >= 87
ORDER BY average_score DESC;

SELECT s.name, COUNT(e.course_id) AS course_count
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY course_count DESC
LIMIT 1;

SELECT c.course_name, AVG(e.score) AS average_score
FROM courses c
INNER JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.course_name
HAVING average_score >= 88
ORDER BY average_score DESC;