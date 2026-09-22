-- =========================================================
-- Day 13 - User + Permission + Backup + Restore
-- MySQL 8.4
-- =========================================================
-- 说明：
-- 1. 本文件主要记录 Day 13 的 SQL 操作。
-- 2. mysqldump / mysql < xxx.sql 属于 Shell 命令，不要在 mysql> 中执行。
-- 3. 用户与权限命令重复执行可能报“用户已存在”或改变当前权限，
--    建议理解后分段执行，不要无脑整份重跑。
-- =========================================================


-- =========================================================
-- 1. 查看 MySQL 用户
-- =========================================================

SELECT user, host
FROM mysql.user;


-- =========================================================
-- 2. 创建普通用户
-- =========================================================
-- 测试账号，仅用于本地学习。

CREATE USER 'study_user'@'localhost'
IDENTIFIED BY 'Study123!';


-- =========================================================
-- 3. 查看用户权限
-- =========================================================

SHOW GRANTS FOR 'study_user'@'localhost';

-- 新创建的用户通常只有：
-- GRANT USAGE ON *.* TO 'study_user'@'localhost'


-- =========================================================
-- 4. GRANT 授权
-- =========================================================
-- 给 study_user study_mysql 下所有表的：
-- SELECT / INSERT / UPDATE 权限。

GRANT SELECT, INSERT, UPDATE
ON study_mysql.*
TO 'study_user'@'localhost';

SHOW GRANTS FOR 'study_user'@'localhost';


-- =========================================================
-- 5. 权限验证
-- =========================================================
-- 下面部分应使用 study_user 登录后执行：
--
-- mysql -u study_user -p
--
-- USE study_mysql;

SELECT * FROM students LIMIT 3;

-- study_user 没有 DELETE 权限，因此下面语句应被拒绝：
DELETE FROM students
WHERE id = 999999;


-- =========================================================
-- 6. REVOKE 收回权限
-- =========================================================
-- 回到 root 会话执行：

REVOKE UPDATE
ON study_mysql.*
FROM 'study_user'@'localhost';

SHOW GRANTS FOR 'study_user'@'localhost';

-- 此时应只剩：
-- SELECT, INSERT


-- =========================================================
-- 7. 数据库级权限变更的会话验证
-- =========================================================
-- 如果 study_user 是已经存在的旧会话，
-- 数据库级权限变化可能需要重新选择数据库后体现。
--
-- 在 study_user 会话中：
--
-- USE information_schema;
-- USE study_mysql;
--
-- 再执行：

UPDATE students
SET name = name
WHERE id = 1;

-- 预期：
-- ERROR 1142 (42000):
-- UPDATE command denied to user 'study_user'@'localhost'
--
-- 注意：
-- SET name = name 表示把字段设置为它当前自己的值，
-- 并不是把 name 改成字符串 'name'。


-- =========================================================
-- 8. Restore 后验证数据库对象
-- =========================================================

-- 普通恢复库：
USE study_mysql_restore;

SHOW TABLES;

SELECT * FROM students;

SELECT COUNT(*) AS student_count
FROM students;

SHOW CREATE TABLE students\G


-- =========================================================
-- 9. 完整备份恢复后的 Day 12 对象验证
-- =========================================================

USE study_mysql_full_restore;

-- 查看表和视图
SHOW FULL TABLES;

-- Trigger
SHOW TRIGGERS;

-- Procedure
SHOW PROCEDURE STATUS
WHERE Db = 'study_mysql_full_restore';

CALL show_students();

CALL show_students_by_year(2026);

-- Function
SHOW FUNCTION STATUS
WHERE Db = 'study_mysql_full_restore';

SELECT add_one(10);


-- =========================================================
-- 10. Terminal 执行 .sql 文件测试内容
-- =========================================================
-- execute_test.sql 中的内容可以写成：
--
-- SELECT DATABASE();
-- SELECT COUNT(*) AS student_count FROM students;
--
-- Shell 中执行：
--
-- mysql -u root -p study_mysql < execute_test.sql
--
-- 命令中已经指定 study_mysql，
-- 因此 execute_test.sql 内部不需要再写 USE study_mysql;
