-- =========================================
-- Day 09
-- 数据库设计 + ALTER TABLE + 范式
-- =========================================

USE study_mysql;

-- =========================================
-- 1. 创建 departments 表
-- =========================================

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- =========================================
-- 2. 给 students 增加 department_id
-- =========================================

ALTER TABLE students
ADD COLUMN department_id INT;

-- =========================================
-- 3. 增加外键约束
-- =========================================

ALTER TABLE students
ADD CONSTRAINT FK_department_id
FOREIGN KEY (department_id)
REFERENCES departments(department_id);

-- =========================================
-- 4. 检查表结构
-- =========================================

DESC students;

-- Terminal 中可执行：
-- SHOW CREATE TABLE students\G

-- =========================================
-- 5. 插入学院数据
-- =========================================

INSERT INTO departments (department_name)
VALUES
('计算机学院'),
('数学学院');

SELECT *
FROM departments
ORDER BY department_id ASC;

-- =========================================
-- 6. 给学生设置学院
-- =========================================

UPDATE students
SET department_id = 1
WHERE id = 1;

SELECT id, name, department_id
FROM students
WHERE id = 1;

-- =========================================
-- 7. 外键失败测试
-- =========================================
-- 下面这条会因为 departments 中不存在 999 而失败。
-- 预期：ERROR 1452
--
-- UPDATE students
-- SET department_id = 999
-- WHERE id = 1;

-- =========================================
-- 8. ALTER TABLE 语法练习
-- =========================================

-- 增加字段
-- ALTER TABLE departments
-- ADD COLUMN phone VARCHAR(20);

-- 修改字段定义
-- ALTER TABLE departments
-- MODIFY COLUMN phone VARCHAR(30);

-- 删除字段
-- ALTER TABLE departments
-- DROP COLUMN phone;

-- =========================================
-- Day 09 核心
-- =========================================
--
-- 1NF：字段值原子化
-- 2NF：消灭部分函数依赖
-- 3NF：消灭非主属性对候选键的传递函数依赖
--
-- =========================================
