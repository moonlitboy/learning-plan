-- Day 01
-- SQLTools 基础连接测试

SHOW DATABASES;

SELECT VERSION();

SELECT DATABASE();

-- SQLTools 创建 / 删除数据库实验

CREATE DATABASE sqltools_test;

SHOW DATABASES;

DROP DATABASE sqltools_test;

SHOW DATABASES;

-- 正式创建学习数据库

CREATE DATABASE study_mysql
CHARACTER SET utf8mb4;

SHOW DATABASES;

USE study_mysql;

SELECT DATABASE();