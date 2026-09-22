# Day 13 - User + Permission + Backup + Restore

> 环境：macOS + MySQL 8.4 + Terminal  
> 项目数据库：`study_mysql`

---

## 1. 今日目标

Day 13 的核心不是继续堆查询语法，而是开始学习一些 **MySQL 管理与运维基础**：

- MySQL 用户
- 权限管理
- `CREATE USER`
- `GRANT`
- `REVOKE`
- `SHOW GRANTS`
- `mysqldump`
- 数据库备份
- 数据库恢复
- Terminal 执行 `.sql` 文件

今天的核心思想：

```text
root 不应该作为普通程序的日常账号

普通用户
↓
只授予真正需要的权限
```

---

# 2. MySQL 用户

查看当前 MySQL 用户：

```sql
SELECT user, host
FROM mysql.user;
```

结果中包含：

```text
root             localhost
mysql.infoschema localhost
mysql.session    localhost
mysql.sys        localhost
```

随后创建学习账号：

```sql
CREATE USER 'study_user'@'localhost'
IDENTIFIED BY 'Study123!';
```

再次查询后可以看到：

```text
study_user localhost
```

---

## 3. `user@host`

MySQL 中一个账户不只由用户名决定，而是：

```text
'user'@'host'
```

例如：

```text
'study_user'@'localhost'
```

表示：

> 用户名为 `study_user`，从本机 `localhost` 登录。

因此：

```text
'test'@'localhost'
```

和：

```text
'test'@'%'
```

属于不同的账户定义。

---

# 4. `USE` 与 `mysql.user`

查询：

```sql
SELECT user, host
FROM mysql.user;
```

不需要先：

```sql
USE mysql;
```

因为：

```text
mysql.user
```

已经写明：

```text
数据库名.表名
```

规律：

```text
SELECT * FROM 数据库名.表名;
```

不依赖当前默认数据库。

而：

```text
SELECT * FROM 表名;
```

通常需要当前已经选择对应数据库。

---

# 5. `SHOW GRANTS`

创建 `study_user` 后执行：

```sql
SHOW GRANTS FOR 'study_user'@'localhost';
```

最初结果：

```text
GRANT USAGE ON *.* TO `study_user`@`localhost`
```

这里可以先理解为：

```text
账号已经存在
但还没有额外授予实际数据库操作权限
```

---

# 6. `GRANT` 授权

授予：

```sql
GRANT SELECT, INSERT, UPDATE
ON study_mysql.*
TO 'study_user'@'localhost';
```

其中：

```text
study_mysql.*
```

表示：

```text
study_mysql 数据库下的所有表
```

几个常见范围：

```text
*.*                    所有数据库的所有对象
study_mysql.*          study_mysql 下所有表
study_mysql.students   只针对 students 表
```

授权后：

```sql
SHOW GRANTS FOR 'study_user'@'localhost';
```

可以看到：

```text
SELECT
INSERT
UPDATE
```

---

# 7. 实际验证权限

使用普通用户登录：

```bash
mysql -u study_user -p
```

查看数据库：

```sql
SHOW DATABASES;
```

可以看到：

```text
information_schema
performance_schema
study_mysql
```

进入：

```sql
USE study_mysql;
```

测试 SELECT：

```sql
SELECT * FROM students LIMIT 3;
```

成功。

再测试没有授予的 DELETE：

```sql
DELETE FROM students
WHERE id = 999999;
```

结果：

```text
ERROR 1142 (42000):
DELETE command denied to user 'study_user'@'localhost'
for table 'students'
```

说明：

```text
被授予什么权限
↓
才能执行什么操作
```

---

# 8. `REVOKE` 收回权限

root 用户执行：

```sql
REVOKE UPDATE
ON study_mysql.*
FROM 'study_user'@'localhost';
```

再查看：

```sql
SHOW GRANTS FOR 'study_user'@'localhost';
```

结果只剩：

```text
SELECT
INSERT
```

说明 `UPDATE` 已经成功收回。

---

## 9. 数据库级权限与已有 Session

实验过程中发现：

root 已经执行：

```sql
REVOKE UPDATE ...
```

并且：

```sql
SHOW GRANTS
```

已经确认没有 `UPDATE`。

但之前已经连接并进入 `study_mysql` 的旧 `study_user` Session，一开始仍然能够执行：

```sql
UPDATE students
SET name = name
WHERE id = 1;
```

随后执行：

```sql
USE information_schema;
USE study_mysql;
```

再测试：

```sql
UPDATE students
SET name = name
WHERE id = 1;
```

得到：

```text
ERROR 1142 (42000):
UPDATE command denied ...
```

本次实验需要记住：

```text
数据库级权限发生变化
↓
旧连接可能需要重新选择数据库
↓
新的数据库级权限状态才体现出来
```

---

## 10. `SET name = name` 是什么意思？

实验 SQL：

```sql
UPDATE students
SET name = name
WHERE id = 1;
```

并不是：

```text
把姓名改成字符串 "name"
```

而是：

```text
把 name 字段设置成它当前自己的值
```

例如：

```text
张三 → 张三
```

因此之前出现：

```text
Rows matched: 1
Changed: 0
```

含义：

```text
Rows matched: 1
→ WHERE 找到了 1 行

Changed: 0
→ 新值与旧值相同，没有实际修改
```

如果真的想设置成字符串 `name`：

```sql
SET name = 'name'
```

---

# 11. Backup：`mysqldump`

项目结构：

```text
project/
└── backup/
```

普通备份：

```bash
mysqldump -u root -p study_mysql \
> project/backup/study_mysql.sql
```

生成：

```text
project/backup/study_mysql.sql
```

查看：

```bash
ls -lh project/backup/study_mysql.sql
```

本次文件大小约：

```text
11K
```

---

## 12. `>` 输出重定向

命令：

```bash
mysqldump -u root -p study_mysql \
> project/backup/study_mysql.sql
```

其中：

```text
>
```

不是 MySQL SQL 语法。

它属于 Shell 的 **输出重定向**：

```text
mysqldump 产生的输出
↓
>
↓
写入 study_mysql.sql
```

---

# 13. 查看备份内容

查看前 40 行：

```bash
head -n 40 project/backup/study_mysql.sql
```

可以看到：

```sql
DROP TABLE IF EXISTS ...
CREATE TABLE ...
```

以及一些：

```sql
SET ...
```

这些内容用于帮助恢复数据库结构与执行环境。

搜索数据：

```bash
grep -n "INSERT INTO" project/backup/study_mysql.sql
```

看到了：

```text
courses
departments
enrollments
student_logs
students
teachers
```

对应的数据 `INSERT INTO`。

因此可以形成这个理解：

```text
mysqldump
↓
生成一份可以重新执行的 SQL 脚本
```

里面主要包含：

```text
恢复环境设置
+
DROP / CREATE TABLE
+
INSERT INTO
+
其他数据库对象定义
```

---

# 14. Trigger 中也可能出现 `INSERT INTO`

`grep` 结果中还出现：

```sql
INSERT INTO student_logs (student_name)
```

这不是 dump 出来的表数据，而是 Day 12 Trigger：

```text
after_student_insert
```

内部本身包含的 SQL。

`grep` 只负责匹配文本，并不知道这条 `INSERT` 属于：

```text
数据恢复 SQL
```

还是：

```text
Trigger 定义
```

---

# 15. Restore：普通恢复

先创建恢复库：

```sql
CREATE DATABASE study_mysql_restore
CHARACTER SET utf8mb4;
```

然后 Shell：

```bash
mysql -u root -p study_mysql_restore \
< project/backup/study_mysql.sql
```

其中：

```text
<
```

表示：

```text
文件内容
↓
交给 mysql 客户端执行
```

与备份方向相反：

```text
备份：

数据库 → 文件
        >

恢复：

文件 → 数据库
       <
```

---

# 16. 恢复验证

进入：

```sql
USE study_mysql_restore;
```

查看：

```sql
SHOW TABLES;
```

恢复出了：

```text
courses
departments
enrollments
student_course_view
student_logs
students
teachers
```

查询：

```sql
SELECT * FROM students;
```

恢复：

```text
16 rows
```

再：

```sql
SELECT COUNT(*) FROM students;
```

结果：

```text
16
```

说明数据恢复成功。

---

## 17. 表结构、索引、外键也恢复了

执行：

```sql
SHOW CREATE TABLE students\G
```

确认恢复了：

```text
PRIMARY KEY
UNIQUE(student_no)
UNIQUE(email)

idx_students_name
idx_year_name

FK_department_id
```

所以普通恢复不仅恢复：

```text
表 + 数据
```

还恢复了：

```text
索引
外键
约束
```

---

# 18. Day 12 对象恢复情况

普通命令：

```bash
mysqldump -u root -p study_mysql \
> project/backup/study_mysql.sql
```

恢复后检查：

```sql
SHOW TRIGGERS;
```

发现：

```text
after_student_insert
```

存在。

`SHOW TABLES` 中也出现：

```text
student_course_view
```

所以：

```text
VIEW     ✅
TRIGGER  ✅
```

但是：

```sql
SHOW PROCEDURE STATUS
WHERE Db = 'study_mysql_restore';
```

结果：

```text
Empty set
```

以及：

```sql
SHOW FUNCTION STATUS
WHERE Db = 'study_mysql_restore';
```

也是：

```text
Empty set
```

因此普通 dump 本次验证结果：

```text
VIEW       ✅
TRIGGER    ✅
PROCEDURE  ❌
FUNCTION   ❌
```

---

# 19. `--routines` 完整备份

为了把 Day 12 的 Procedure 和 Function 也带上：

```bash
mysqldump -u root -p --routines study_mysql \
> project/backup/study_mysql_full.sql
```

项目中现在有：

```text
project/backup/
├── study_mysql.sql
└── study_mysql_full.sql
```

验证：

```bash
grep -n "CREATE.*PROCEDURE" project/backup/study_mysql_full.sql
```

找到了：

```text
show_students()
show_students_by_year(IN p_year INT)
```

验证 Function：

```bash
grep -n "CREATE.*FUNCTION" project/backup/study_mysql_full.sql
```

找到了：

```text
add_one(n INT)
```

---

# 20. 完整恢复

创建：

```sql
CREATE DATABASE study_mysql_full_restore
CHARACTER SET utf8mb4;
```

恢复：

```bash
mysql -u root -p study_mysql_full_restore \
< project/backup/study_mysql_full.sql
```

---

# 21. 验证 Procedure

```sql
SHOW PROCEDURE STATUS
WHERE Db = 'study_mysql_full_restore'\G
```

成功恢复：

```text
show_students
show_students_by_year
```

执行：

```sql
CALL show_students();
```

成功返回 16 行学生以及：

```text
total = 16
```

参数过程需要传参数：

```sql
CALL show_students_by_year(2026);
```

不能写：

```sql
CALL show_students_by_year();
```

否则会报：

```text
expected 1, got 0
```

---

# 22. 验证 Function

执行：

```sql
SHOW FUNCTION STATUS
WHERE Db = 'study_mysql_full_restore'\G
```

找到：

```text
add_one
```

测试：

```sql
SELECT add_one(10);
```

结果：

```text
11
```

说明 Function 恢复成功且可正常执行。

---

# 23. 完整备份最终验证

最终确认：

```text
Table        ✅
Data         ✅
Index        ✅
Foreign Key  ✅
View         ✅
Trigger      ✅
Procedure    ✅
Function     ✅
```

关键命令：

```bash
mysqldump -u root -p --routines study_mysql \
> project/backup/study_mysql_full.sql
```

---

# 24. Shell 中的 `\` 续行

例如：

```bash
mysql -u root -p study_mysql_full_restore \
< project/backup/study_mysql_full.sql
```

行尾：

```text
\
```

表示：

> 当前 Shell 命令还没结束，下一行继续。

因此：

```bash
mysql -u root -p study_mysql_full_restore \
< project/backup/study_mysql_full.sql
```

和：

```bash
mysql -u root -p study_mysql_full_restore < project/backup/study_mysql_full.sql
```

完全等价。

注意：

```text
\ 后面不要再留空格
```

---

# 25. Terminal 执行 `.sql` 文件

创建测试文件：

```text
execute_test.sql
```

内容：

```sql
SELECT DATABASE();

SELECT COUNT(*) AS student_count
FROM students;
```

执行：

```bash
mysql -u root -p study_mysql < execute_test.sql
```

输出：

```text
DATABASE()
study_mysql

student_count
16
```

说明：

```text
.sql 文件
并不是 SQLTools 专属
```

Terminal 中的 `mysql` 客户端一样可以直接执行。

---

## 26. 为什么不用 `USE study_mysql`？

因为命令：

```bash
mysql -u root -p study_mysql < execute_test.sql
```

已经指定：

```text
study_mysql
```

作为默认数据库。

所以脚本内部可以直接：

```sql
SELECT * FROM students;
```

如果写：

```bash
mysql -u root -p < execute_test.sql
```

且 `.sql` 文件内部也没有：

```sql
USE study_mysql;
```

那么涉及 `students` 这样的未限定表名时会遇到：

```text
No database selected
```

---

# 27. Day 13 命令速查

## 用户

```sql
CREATE USER 'study_user'@'localhost'
IDENTIFIED BY 'Study123!';
```

## 查看权限

```sql
SHOW GRANTS FOR 'study_user'@'localhost';
```

## 授权

```sql
GRANT SELECT, INSERT, UPDATE
ON study_mysql.*
TO 'study_user'@'localhost';
```

## 收回权限

```sql
REVOKE UPDATE
ON study_mysql.*
FROM 'study_user'@'localhost';
```

## 普通备份

```bash
mysqldump -u root -p study_mysql \
> project/backup/study_mysql.sql
```

## 包含 Procedure / Function 的备份

```bash
mysqldump -u root -p --routines study_mysql \
> project/backup/study_mysql_full.sql
```

## 恢复

```bash
mysql -u root -p study_mysql_restore \
< project/backup/study_mysql.sql
```

## Terminal 执行 SQL 文件

```bash
mysql -u root -p study_mysql < execute_test.sql
```

---

# 28. Day 13 总结

今天已经完整跑通：

```text
CREATE USER
↓
SHOW GRANTS
↓
GRANT
↓
普通用户实际登录
↓
权限成功 / 拒绝实验
↓
REVOKE
↓
数据库级权限刷新实验
↓
mysqldump
↓
查看 dump 文件
↓
普通 Restore
↓
验证表 / 数据 / 索引 / 外键
↓
发现 Procedure / Function 未包含
↓
mysqldump --routines
↓
完整 Restore
↓
验证 View / Trigger / Procedure / Function
↓
mysql < xxx.sql
```

---

# 29. 今天最重要的结论

```text
1. MySQL 用户 ≠ macOS 用户。

2. MySQL 账户由 user + host 共同确定。

3. CREATE USER 只是创建账号，
   真正能做什么由权限决定。

4. GRANT 给权限，REVOKE 收权限，
   SHOW GRANTS 用来检查权限。

5. 普通应用不应该长期使用 root，
   应遵循“只给需要的权限”。

6. mysqldump 的逻辑备份本质上是一份可重新执行的 SQL。

7. > 是把输出写入文件；
   < 是把文件内容交给命令执行。

8. 普通 mysqldump 可以恢复表、数据、视图、触发器等，
   Procedure / Function 需要额外使用 --routines。

9. 备份成功不代表备份可靠，
   真正恢复并验证成功才算可靠。

10. .sql 文件既可以用 SQLTools 执行，
    也可以使用 Terminal 的 mysql 客户端执行。
```

---

## Day 13 完成 ✅

当前进度：

```text
13 / 14
```

下一天：

```text
Day 14 - CampusDB 最终综合项目
```
