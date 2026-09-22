# Day 14｜CampusDB 最终综合项目与 MySQL 14 天学习收官总结

> **定位**：这一天不是再单独练习某个语法，而是把前 13 天的数据库设计、查询、索引、事务、备份与恢复整合进一个从零完成的校园选课系统。本文记录本次实际完成的操作、验证结果、遇到的疑问与核心理解。
>
> **环境**：macOS、Homebrew 安装的 MySQL 8.4、Terminal（两个独立 MySQL 会话）、VS Code + SQLTools。正式业务库为 `campus_db`，恢复验收库为 `campus_db_restore`。

## 一、最终项目目标与完成情况

| Part | 任务 | 本次结果 |
|---|---|---|
| 1 | Terminal 创建 `campus_db` | 完成；验证 `utf8mb4` |
| 2 | SQLTools 设计五张表 | 完成；主键、唯一约束、外键齐备 |
| 3 | 准备五张表的测试数据 | 完成；合计 158 条 |
| 4 | 20 类综合查询 | 完成；含 JOIN、子查询、EXISTS、CTE、LIMIT 等 |
| 5 | INDEX 与 EXPLAIN | 完成；建索引前后计划与 `EXPLAIN ANALYZE` 对照 |
| 6 | 双 Terminal 事务实验 | 完成；分别观察 `ROLLBACK`、`COMMIT` |
| 7 | `mysqldump` 备份 | 完成；`project/backup/campus_db.sql` |
| 8 | 新库恢复与验收 | 完成；验证数量、选课表约束、学生表索引、测试成绩 |

**说明**：今天没有单独创建 `day14.sql`。业务定义和数据分别写入 `project/schema.sql`、`project/data.sql`；今天在 Terminal 完成的查询集中整理到 `project/query.sql`。本文应保存到 `notes/day14.md`，作为整个最终项目的完整学习笔记。

## 二、项目目录与职责

```text
mysql-learning/
├── day01.sql ... day13.sql       # 前 13 天练习
├── notes/
│   ├── day01.md ... day13.md
│   └── day14.md                 # 本篇最终总结
└── project/
    ├── schema.sql               # 建表、约束、外键；建议补记后建的索引
    ├── data.sql                 # 五张表 158 条初始化数据
    ├── query.sql                # 本次 Terminal 查询和 EXPLAIN 的整理版
    └── backup/
        ├── study_mysql.sql
        ├── study_mysql_full.sql
        └── campus_db.sql        # Day 14 项目备份
```

`schema.sql`、`data.sql` 是已经存在的本地文件，不在这次下载包中重写，以免覆盖今天实际执行成功的版本。本次单独提供 `query.sql` 和 `day14.md`。

## 三、Part 1：Terminal 创建数据库

```sql
CREATE DATABASE campus_db
CHARACTER SET utf8mb4;

SHOW DATABASES;
SHOW CREATE DATABASE campus_db;
```

实际验证信息：

```text
CREATE DATABASE `campus_db`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci
```

- `utf8mb4` 是字符集；`utf8mb4_0900_ai_ci` 是本次 MySQL 8.4 显示的默认排序规则。
- 在 SQL 文件顶部加 `USE campus_db;`，避免后续语句操作错库。即使当前已经在 `campus_db`，再次执行 `USE campus_db;` 也不会因重复选择而报错。
- `SELECT DATABASE();` 是核对**当前会话**默认数据库的直接方法；SQLTools 的连接名称不等同于当前数据库。

## 四、Part 2：五张表的设计

### 4.1 关系图

```text
departments（学院）
  ├── 1:N → teachers（教师）
  │             └── 1:N → courses（课程）
  └── 1:N → students（学生）
                    └── 1:N → enrollments（选课记录）
                                       N:1 → courses
```

学生与课程之间的多对多关系，使用 `enrollments` 拆解成两条一对多关系。因外键依赖，建表/导入数据都按 `departments → teachers → students → courses → enrollments` 的顺序进行。

### 4.2 字段与约束

| 表 | 关键字段与规则 |
|---|---|
| `departments` | `department_id` 自增主键，`department_name` 非空且唯一，`created_at` 默认当前时间 |
| `teachers` | `teacher_id` 自增主键，`teacher_no` 唯一，`teacher_name` 非空，`email` 非空且唯一，`department_id` 非空并关联学院 |
| `students` | `student_id` 自增主键，`student_no` 唯一，`student_name` 非空，`email` 非空且唯一，`enroll_year YEAR NOT NULL`，`department_id` 非空并关联学院 |
| `courses` | `course_id` 自增主键，`course_code` 唯一，`course_name` 非空，`credits DECIMAL(3,1)`，`capacity` 默认 50，`teacher_id` 外键 |
| `enrollments` | `id` 自增主键，`student_id`、`course_id` 非空且是外键，`score DECIMAL(5,2)` 可为空，`UNIQUE(student_id, course_id)` 防止重复选课 |

> **设计抉择 1：为什么不在学院表存“学生人数”？** 学生人数可通过 `students` 实时聚合。直接维护冗余人数可能因新增/转学院/删除学生而与真实数据不一致。
>
> **设计抉择 2：为什么名称不用作主键？** 学院名在业务上可能改名。整数自增 ID 短且稳定，其他表用它作为外键更方便；学院名另加 `UNIQUE` 保证业务唯一。
>
> **设计抉择 3：选课表为何选“自增 ID + 联合唯一约束”？** `id` 唯一标识这条选课记录，`UNIQUE(student_id, course_id)` 另行禁止一个学生重复选同一门课。用 `(student_id, course_id)` 直接做联合主键也成立，但本次采用 Day 6 原设计。
>
> **设计抉择 4：成绩为什么 `DECIMAL(5,2)` 并允许 `NULL`？** `DECIMAL(3,1)` 的最大正值是 `99.9`，不能容纳 `100.0`；成绩可能尚未公布，因此允许 `NULL`。

### 4.3 读懂 `SHOW CREATE TABLE`

恢复库中 `enrollments` 已验证存在：

```sql
PRIMARY KEY (`id`),
UNIQUE KEY `student_id` (`student_id`, `course_id`),
KEY `course_id` (`course_id`),
FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
```

- `PRIMARY KEY (id)`：主键索引。
- `UNIQUE KEY student_id (student_id, course_id)`：第一个 `student_id` 是 MySQL 自动取的**索引名**，括号内的两个字段才是联合唯一索引的组成列。该约束限制的是**组合唯一**，并非 `student_id` 单独唯一。
- `KEY course_id (course_id)`：`KEY` 在这段建表语法中表示普通索引；前面是索引名，括号内是索引列。它不是主键。
- InnoDB 的外键列需要相应索引。本次 `(student_id, course_id)` 联合索引符合 `student_id` 的最左前缀，因而不必再单独为它创建一个重复索引；`course_id` 则有单列索引支持。
- `AUTO_INCREMENT=101`：恢复表中自增序列显示的下一个起始值，与目前 100 条选课记录相符；不要把它当成精确行数统计。

## 五、Part 3：测试数据设计与实际验收

| 表 | 实际记录数 | 设计目的 |
|---|---:|---|
| departments | 3 | 计算机学院、数学学院、外国语学院 |
| teachers | 10 | `T001`～`T010`；分属三个学院 |
| students | 30 | `S001`～`S030`，2024/2025/2026 各 10 人 |
| courses | 15 | C/M/E 三类课程，2.0～4.0 学分 |
| enrollments | 100 | 用于 JOIN、聚合、子查询、未选课与排名实验 |
| **合计** | **158** | **全部达到原定数据量** |

选课记录刻意分配为：

```text
学生 1～10    每人 5 门，共 50 条
学生 11～20   每人 4 门，共 40 条
学生 21～25   每人 2 门，共 10 条
学生 26～30   没有选课，共 0 条
合计                    100 条
```

这样可以同时检验：有选课/没选课、至少 3 门/至少 4 门、课程平均成绩、高于总平均分、`LEFT JOIN` 的 0 值等题目。

```sql
SELECT COUNT(*) AS enrollment_count FROM enrollments;
SELECT enroll_year, COUNT(*) AS total
FROM students
GROUP BY enroll_year
ORDER BY enroll_year;
```

实际返回：`enrollment_count=100`；三届人数分别为 `10 / 10 / 10`。

## 六、Part 4：20 类综合查询总览

本次在 Terminal 实际完成了核心 20 类查询；各条可重复运行的 SQL 已按原计划编号整理到 `project/query.sql`，避免把整套 SQL 重复抄进笔记。下表记录重点及实际观察：

| 题号 | 查询内容 | 本次关键结果 / 技术点 |
|---|---|---|
| 01 | 所有学生 | 30 行 |
| 02 | 2026 年学生 | 10 行，`WHERE enroll_year = 2026` |
| 03 | 最高学分课程 | 4 门并列 4.0 分；`MAX` 标量子查询 |
| 04 | 学生总人数 | 30 |
| 05 | 各届人数 | 2024/2025/2026 各 10 |
| 06 | 平均课程学分 | `3.13333`；`ROUND(...,2)` 为 `3.13` |
| 07 | 每个学生所选课程 | 三表 JOIN，100 条选课记录 |
| 08 | 每门课程有哪些学生 | 三表 JOIN，按课程编号排序 |
| 09 | 没选课的学生 | 26～30，共 5 人；`LEFT JOIN ... IS NULL` |
| 10 | 至少选 3 门课程的学生 | 20 人；`GROUP BY + HAVING >= 3` |
| 11 | 每门课程平均成绩 | 15 门；`ROUND(AVG(e.score),2)` |
| 12 | 成绩高于全体平均分的选课记录 | 52 条；三表 JOIN + 标量子查询 |
| 13 | 子查询 | `MAX(credits)` / `AVG(score)` 均在实际操作中使用；文件另给平均学分例题 |
| 14 | EXISTS | 有选课的学生 1～25，共 25 人 |
| 15 | CTE | 至少选 4 门课，返回 1～20 共 20 人 |
| 16 | 三表 JOIN | `students → enrollments → courses` |
| 17 | LEFT JOIN | 30 人全部保留；26～30 的选课数为 0 |
| 18 | GROUP BY | 按届、按学生、按课程做聚合 |
| 19 | HAVING | 对分组后的 `COUNT` 施加条件 |
| 20 | LIMIT | 前 3 条最高学分课程（不包含全部并列者） |

### 6.1 LEFT JOIN + COUNT：为什么 26～30 能显示 0？

```sql
SELECT
    s.student_id,
    s.student_name,
    COUNT(e.course_id) AS course_count
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name;
```

直接从 `enrollments` `GROUP BY student_id`，没有选课的学生根本不会产生分组。改用 `students LEFT JOIN enrollments` 才能保留所有 30 人。右表无匹配时，`COUNT(*)` 会把保留下来的左表行算作 1，故这里用 `COUNT(e.course_id)`（不统计 `NULL`）。

找出**只有未选课学生**则使用：

```sql
SELECT s.student_id, s.student_name
FROM students AS s
LEFT JOIN enrollments AS e
    ON s.student_id = e.student_id
WHERE e.course_id IS NULL;
```

实际结果为 26 刘洋、27 孙浩、28 周雪、29 郑宇、30 林晨。

### 6.2 JOIN、聚合、筛选各司其职

- `WHERE` 筛选参与分组的行；`HAVING` 筛选已经聚合的组。
- 查询“选课数至少 3 门”可以用 `HAVING COUNT(e.course_id) >= 3`；因为无选课者必被过滤，这题用普通 `JOIN` 也可以，不一定非用 `LEFT JOIN`。
- `AVG(e.score)` 先计算平均成绩，`ROUND(AVG(e.score), 2)` 再将它四舍五入到两位小数。
- 当前数据每门课程都有选课记录，因此普通 `JOIN` 的课程平均成绩查询覆盖了全部 15 门；如果以后存在无人选的课程，要用 `courses LEFT JOIN enrollments` 才能保留它们，平均分将为 `NULL`。

### 6.3 子查询与 DISTINCT 的精确含义

```sql
SELECT s.student_name, c.course_name, e.score
FROM students AS s
JOIN enrollments AS e ON s.student_id = e.student_id
JOIN courses AS c ON e.course_id = c.course_id
WHERE e.score > (
    SELECT AVG(score) FROM enrollments
);
```

实际返回 **52 条高于全体选课记录平均分的学生-课程记录**，并非 52 名学生。改成只查 `DISTINCT s.student_id, s.student_name` 后，本次得到 **25 名不重复的学生**。`DISTINCT` 对所有选出列的**完整组合**去重；如果把不同的 `e.score` 也选出来，同一个学生仍可能出现多行。

### 6.4 EXISTS 和 CTE

`EXISTS` 只判断相关子查询有没有匹配记录，不依赖 `SELECT 1` 的数值。该题结果 1～25 号学生有至少一条选课记录。

```sql
WITH student_course_stats AS (
    SELECT student_id, COUNT(course_id) AS course_count
    FROM enrollments
    GROUP BY student_id
)
SELECT s.student_id, s.student_name, scs.course_count
FROM students AS s
JOIN student_course_stats AS scs
    ON s.student_id = scs.student_id
WHERE scs.course_count >= 4;
```

本次 CTE 查询返回 20 人。`course_count` 同时作为 CTE 名与列名在语法上允许，但为了可读性，本总结采用 `student_course_stats` 作为 CTE 名、`course_count` 作为统计列名，并给 CTE 起别名 `scs`。尽量不要 `SELECT *` 导致连接结果有两个 `student_id` 字段。

### 6.5 ORDER BY + LIMIT：注意并列

实际最高学分为 4.0，共有 C 语言程序设计、数据结构、操作系统、高等数学 **4 门**。`ORDER BY credits DESC LIMIT 3` 只给其中 **3 条**；不加第二排序条件时，并列记录的先后不保证固定。为得到稳定的三行结果：

```sql
SELECT *
FROM courses
ORDER BY credits DESC, course_id ASC
LIMIT 3;
```

如果题意是**所有并列最高的课程**，则应采用 `credits = (SELECT MAX(credits) FROM courses)`，而不是 `LIMIT 3`。

## 七、Part 5：索引、EXPLAIN 和实测性能

### 7.1 建索引前后

目标查询：

```sql
SELECT * FROM students WHERE enroll_year = 2026;
```

建索引之前：

```text
type          = ALL
possible_keys = NULL
key           = NULL
rows          = 30
filtered      = 10.00   # 优化器估计，不是实际 10/30 的真实比例
Extra         = Using where
```

执行：

```sql
CREATE INDEX idx_students_enroll_year
ON students(enroll_year);
```

建索引后：

```text
type          = ref
possible_keys = idx_students_enroll_year
key           = idx_students_enroll_year
key_len       = 1
ref           = const
rows          = 10
filtered      = 100.00
Extra         = NULL
```

**阅读顺序**：`type` 看访问方式 → `possible_keys` 看候选索引 → `key` 看实际采用索引 → `rows` 看预计检查行数 → `Extra` 看附加执行信息。`rows` 和 `filtered` 都是估计值。此次 `ref: const` 是 `enroll_year = 2026` 与常量等值比较；`key_len: 1` 与 `YEAR` 的索引键长度相符。

### 7.2 SHOW INDEX：五个索引如何产生？

| Key_name | 类型 | 形成原因 | 本次 Cardinality |
|---|---|---|---:|
| PRIMARY | 主键索引，`student_id` | 主键约束 | 30 |
| student_no | 唯一索引 | `UNIQUE` 约束 | 30 |
| email | 唯一索引 | `UNIQUE` 约束 | 30 |
| department_id | 普通索引 | 为学院外键提供支持 | 3 |
| idx_students_enroll_year | 普通索引 | 本次手动创建 | 3 |

`Non_unique=0` 表示唯一索引（包括主键），`Non_unique=1` 表示允许重复。`Cardinality` 为估计的不同键值数量，不保证一直与实际数据精确相等。五个索引在本次输出中均为 `BTREE` 类型。

### 7.3 EXPLAIN ANALYZE 真实结果

下面是本次终端实验的**单次观测值**，单位毫秒：

```text
使用索引：
Index lookup on students using idx_students_enroll_year
(cost=1.75 rows=10)
(actual time=0.0557..0.0827 rows=10 loops=1)

忽略该索引：
Filter: (students.enroll_year = 2026)
(cost=3.25 rows=10)
(actual time=0.0825..0.0929 rows=10 loops=1)
  └─ Table scan on students
     (cost=3.25 rows=30)
     (actual time=0.0537..0.0859 rows=30 loops=1)
```

- `EXPLAIN` 告诉我们优化器计划如何执行；`EXPLAIN ANALYZE` 真正执行并报告实测行数与各执行节点耗时。
- `actual time=A..B` 的 A 为该节点首次产出行的大致时间，B 为完成产出的大致时间；`loops=1` 表示本次节点执行一次。
- 执行树父节点 `Filter` 的 `0.0929 ms` **已经包含**其子节点 `Table scan` 的工作，不能再与 `0.0859 ms` 相加。两者流水式配合，不是必须扫完整张表后才开始过滤。
- 本次索引路径顶层结束约 `0.0827 ms`，忽略索引后顶层结束约 `0.0929 ms`；这**只是一次测量**，30 行小表的差距仅约 `0.0102 ms`，不足以宣称有稳定、显著的加速效果。
- `enroll_year` 目前只有 3 个不同年份（每个年份 10 人），区分度低。**索引被使用 ≠ 索引值得长期保留**；最终还要看查询频率、表规模、过滤比例、回表成本与写入代价。

> **项目文件一致性提醒**：`idx_students_enroll_year` 是初次建表后在 Terminal 里额外创建的，最终恢复库已经证实备份包含它。请核对自己的 `project/schema.sql`：如果里面还没有这条索引定义，应将它以注释说明或一次性建索引语句补记，确保将来从 `schema.sql + data.sql` 从零重建时也能复现完整结构。不要对已存在此索引的库重复执行该语句。

## 八、Part 6：双 Terminal 事务实验

两端分别建立独立会话：

```bash
mysql -u root -p
```

```sql
USE campus_db;
```

测试对象是 `enrollments` 中 `student_id=1 AND course_id=1` 的成绩，初始值 `92.50`。

### 8.1 第一轮：ROLLBACK

Terminal A：

```sql
START TRANSACTION;
UPDATE enrollments
SET score = 60.00
WHERE student_id = 1 AND course_id = 1;
SELECT score FROM enrollments
WHERE student_id = 1 AND course_id = 1;
-- A 看到 60.00；此时先不要提交。
```

Terminal B：

```sql
SELECT score FROM enrollments
WHERE student_id = 1 AND course_id = 1;
-- B 观察到 92.50（若此查询在 A 回滚前执行，可验证未发生脏读）。
```

Terminal A：

```sql
ROLLBACK;
SELECT score FROM enrollments
WHERE student_id = 1 AND course_id = 1;
-- 恢复 92.50
```

**实际验收**：A 修改后 `60.00`，A 回滚后恢复 `92.50`；B 查询输出 `92.50`。若要严格证明 B 没有脏读，确保 B 的查询确实发生在 A 尚未回滚、也尚未提交的时间窗口。

### 8.2 第二轮：COMMIT

A 再开启事务，将相同记录修改为 `95.00`，B 在 A 未提交时查询旧值 `92.50`，A 执行 `COMMIT` 后 B 再查询新值 `95.00`。这里默认 B 每次查询都是新的自动提交事务；**如果 B 一直处在一个已建立快照的 REPEATABLE READ 事务里，重新 SELECT 仍可能看到旧快照**。

为恢复预设测试数据，备份前又把该条成绩改回 `92.50`。恢复库最终查询也证实为 `92.50`。

### 8.3 本次真正复习到的知识

- `START TRANSACTION`：开启事务；A 能读到自身未提交修改。
- `ROLLBACK`：撤销当前事务未提交的修改。
- `COMMIT`：使当前事务修改正式提交。
- 默认 InnoDB 的一致性读取和事务隔离，让其他会话通常不会读到未提交修改；实验结论必须结合**两个 Session 的操作顺序和隔离级别**。

## 九、Part 7：mysqldump 备份

在项目根目录、**系统 Terminal**（不是 `mysql>` 交互提示符）执行：

```bash
mysqldump -u root -p campus_db > project/backup/campus_db.sql
ls -lh project/backup/campus_db.sql
```

- `mysqldump` 导出数据库结构及数据到 SQL 脚本；`>` 是 Shell 输出重定向。
- 备份时必须知道当前工作目录；不要把脚本意外放到其他目录。
- 本次原有 `project/backup/study_mysql.sql` 与 `study_mysql_full.sql` 予以保留，不与 CampusDB 的备份混淆。

## 十、Part 8：恢复与最终验收

先创建与业务库独立的恢复库：

```sql
CREATE DATABASE campus_db_restore CHARACTER SET utf8mb4;
```

然后回到项目根目录的系统 Terminal 执行：

```bash
mysql -u root -p campus_db_restore < project/backup/campus_db.sql
```

`<` 是 Shell 输入重定向，表示让 MySQL 客户端执行备份文件中的 SQL。恢复后：

```sql
USE campus_db_restore;
SELECT DATABASE();
SHOW TABLES;
```

### 10.1 UNION ALL 一次性检查五张表

```sql
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
```

本次在 **`campus_db_restore`** 实际运行结果：

```text
departments       3
teachers         10
students         30
courses          15
enrollments     100
-------------------
合计             158
```

`'departments' AS table_name` 里的 `'departments'` 是字符串常量，不是列名。`UNION ALL` 按列位置**纵向合并**各个 `SELECT` 的结果并保留重复行；最终显示的列名由第一条 `SELECT` 决定，因此后面无须重复写 `AS table_name`、`AS total`。与 `UNION` 自动去重的行为不同。

### 10.2 表结构、索引和实际数据均已核对

- `SELECT DATABASE();` 实际返回 `campus_db_restore`，确认操作库正确。
- `SHOW CREATE TABLE enrollments\G`：恢复表中自增主键、`UNIQUE(student_id, course_id)`、两个外键和 `course_id` 普通索引均存在；显示 `AUTO_INCREMENT=101`。
- `SHOW INDEX FROM students\G`：实际可见 5 个索引，含实验新增的 `idx_students_enroll_year`。
- `SELECT score FROM enrollments WHERE student_id=1 AND course_id=1;` 实际为 `92.50`，与备份前恢复后的目标成绩一致。

以上检查支持**本次要求的关键数据、选课表约束和学生表索引恢复成功**。其他表的每一条外键/约束没有在会话中逐项打印验证，不能将其描述成已单独逐条检查。

## 十一、今天踩过的坑与关键认识

1. **`KEY` 不是主键**：`KEY index_name (column)` 是普通索引，`PRIMARY KEY (...)` 才是主键。
2. **索引名前后相同不等于单列唯一**：`UNIQUE KEY student_id (student_id, course_id)` 中前者是索引名，唯一规则约束后面的**两列组合**。
3. **低区分度索引不应盲目长期保留**：`enroll_year` 在当前库中只有三个年份，即使本次查找确实用上索引，也要结合业务负载判断。
4. **`possible_keys` ≠ `key`**：前者是可选索引，后者是优化器实际选中的索引。
5. **`rows` 与 `filtered` 通常是估算**，不能用来直接断言实际耗时或精确命中率。
6. **执行树父子节点时间不可相加**：顶层 `Filter` 结束耗时包含底层表扫描的工作。
7. **没有匹配右表记录时，`COUNT(*)` 与 `COUNT(e.course_id)` 不等价**；查询未选课学生的 0 值应数非空右表列。
8. **`DISTINCT` 去重完整结果行**，不是只按某个未明示的字段去重。
9. **CTE 表名可以与列名相同**，但使用 `student_course_stats.course_count` 等更清晰的命名有助于维护。
10. **`LIMIT` 会截断并列记录**；如要所有并列第一，用 `= (SELECT MAX(...))`，如要稳定地选 3 行，应补充二级排序键。
11. **`UNION ALL` 纵向拼接、保留重复**，结果列名跟第一条 `SELECT` 一致。
12. **`USE campus_db` 允许重复执行**；避免错库应主动运行 `SELECT DATABASE()`。
13. **复制一个完整 SQL 文件不等于完成可重复部署**：初建表后手动追加的索引，也应补记到项目的结构脚本或部署步骤中。

## 十二、最终能力地图与收官

```text
建库与字符集
  ↓
关系建模 / 主键 / UNIQUE / 外键 / 范式
  ↓
插入可验证的测试数据
  ↓
SELECT / WHERE / ORDER BY / LIMIT
  ↓
JOIN / LEFT JOIN / GROUP BY / HAVING
  ↓
子查询 / EXISTS / CTE / UNION ALL
  ↓
INDEX / SHOW INDEX / EXPLAIN / EXPLAIN ANALYZE
  ↓
双 Session 事务 / COMMIT / ROLLBACK
  ↓
mysqldump 备份 → 新库恢复 → 数据与关键结构验收
```

**本次 Day 14 的实证成果**：从零创建 `campus_db`，完成 5 张表与 158 条记录、20 类综合查询训练；索引实验从 `ALL / rows=30` 变化为 `ref / rows=10`；事务分别验证提交与回滚；备份文件恢复到 `campus_db_restore` 后，五张表数量、选课表约束、学生索引和测试成绩均通过核验。

**下一步可选，不属于今天的必修**：让项目变得可重复初始化（核对 `schema.sql` 是否包含后建索引）、给 `query.sql` 加运行说明，以及在 README 中记录“如何从零部署/如何从备份恢复”。

> 这一天最重要的收获不是记住 20 条 SQL，而是可以自己提出问题、设计数据、独立写查询、质疑索引是否值得建、读懂真实执行计划，并用恢复实验验证备份确实可用。
