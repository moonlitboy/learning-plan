-- MySQL dump 10.13  Distrib 8.4.11, for macos26.6 (arm64)
--
-- Host: localhost    Database: campus_db
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `course_id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `credits` decimal(3,1) NOT NULL,
  `capacity` int DEFAULT '50',
  `teacher_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `course_code` (`course_code`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'C001','C语言程序设计',4.0,60,1,'2026-09-22 08:19:43'),(2,'C002','数据结构',4.0,50,1,'2026-09-22 08:19:43'),(3,'C003','计算机网络',3.5,45,4,'2026-09-22 08:19:43'),(4,'C004','数据库原理',3.5,50,5,'2026-09-22 08:19:43'),(5,'C005','操作系统',4.0,45,8,'2026-09-22 08:19:43'),(6,'M001','高等数学',4.0,80,2,'2026-09-22 08:19:43'),(7,'M002','线性代数',3.0,70,6,'2026-09-22 08:19:43'),(8,'M003','概率论与数理统计',3.0,60,9,'2026-09-22 08:19:43'),(9,'M004','离散数学',3.5,55,2,'2026-09-22 08:19:43'),(10,'M005','数学建模',2.5,40,6,'2026-09-22 08:19:43'),(11,'E001','大学英语',3.0,80,3,'2026-09-22 08:19:43'),(12,'E002','英语口语',2.0,40,7,'2026-09-22 08:19:43'),(13,'E003','英语写作',2.5,45,10,'2026-09-22 08:19:43'),(14,'E004','英美文化',2.0,50,3,'2026-09-22 08:19:43'),(15,'E005','科技英语',2.5,40,7,'2026-09-22 08:19:43');
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `department_id` int NOT NULL AUTO_INCREMENT,
  `department_name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `department_name` (`department_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,'计算机学院','2026-09-22 07:57:23'),(2,'数学学院','2026-09-22 07:57:23'),(3,'外国语学院','2026-09-22 07:57:23');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollments`
--

DROP TABLE IF EXISTS `enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_id` (`student_id`,`course_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES (1,1,1,92.50),(2,1,2,88.00),(3,1,3,90.50),(4,1,6,86.00),(5,1,11,91.00),(6,2,2,85.50),(7,2,4,93.00),(8,2,6,89.50),(9,2,7,87.00),(10,2,11,94.00),(11,3,1,78.50),(12,3,3,84.00),(13,3,5,82.50),(14,3,11,90.00),(15,3,12,88.00),(16,4,1,95.00),(17,4,2,91.50),(18,4,4,96.00),(19,4,6,89.00),(20,4,10,87.50),(21,5,3,82.00),(22,5,6,86.50),(23,5,7,90.00),(24,5,8,88.50),(25,5,13,92.00),(26,6,4,76.50),(27,6,5,81.00),(28,6,9,85.00),(29,6,11,89.50),(30,6,14,87.00),(31,7,1,90.00),(32,7,2,92.50),(33,7,3,88.00),(34,7,7,84.50),(35,7,15,91.00),(36,8,2,79.50),(37,8,5,83.00),(38,8,6,86.00),(39,8,8,90.50),(40,8,12,88.00),(41,9,3,94.00),(42,9,4,92.00),(43,9,9,89.50),(44,9,10,91.00),(45,9,13,87.00),(46,10,1,88.50),(47,10,5,90.00),(48,10,7,85.50),(49,10,11,93.00),(50,10,15,89.00),(51,11,1,82.00),(52,11,4,87.50),(53,11,6,91.00),(54,11,11,86.00),(55,12,2,90.00),(56,12,5,88.50),(57,12,7,92.00),(58,12,12,84.00),(59,13,3,86.50),(60,13,6,89.00),(61,13,8,91.50),(62,13,13,87.00),(63,14,1,93.00),(64,14,4,90.50),(65,14,9,88.00),(66,14,14,92.00),(67,15,2,80.00),(68,15,5,85.50),(69,15,10,89.00),(70,15,15,87.50),(71,16,3,91.00),(72,16,6,94.00),(73,16,7,88.50),(74,16,11,90.00),(75,17,1,84.50),(76,17,5,89.00),(77,17,8,86.00),(78,17,12,92.50),(79,18,2,95.00),(80,18,4,93.50),(81,18,9,90.00),(82,18,13,88.00),(83,19,3,81.50),(84,19,6,85.00),(85,19,10,87.50),(86,19,14,90.00),(87,20,1,89.50),(88,20,5,91.00),(89,20,11,93.50),(90,20,15,88.00),(91,21,2,92.00),(92,21,6,88.50),(93,22,3,85.00),(94,22,11,90.50),(95,23,4,94.00),(96,23,12,89.00),(97,24,5,87.50),(98,24,13,91.00),(99,25,1,86.00),(100,25,14,93.00);
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `student_id` int NOT NULL AUTO_INCREMENT,
  `student_no` varchar(50) NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `enroll_year` year NOT NULL,
  `department_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `student_no` (`student_no`),
  UNIQUE KEY `email` (`email`),
  KEY `department_id` (`department_id`),
  KEY `idx_students_enroll_year` (`enroll_year`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,'S001','张伟','zhangwei@example.com',2024,1,'2026-09-22 08:11:18'),(2,'S002','李娜','lina@example.com',2024,2,'2026-09-22 08:11:18'),(3,'S003','王强','wangqiang@example.com',2024,3,'2026-09-22 08:11:18'),(4,'S004','赵敏','zhaomin@example.com',2024,1,'2026-09-22 08:11:18'),(5,'S005','陈浩','chenhao@example.com',2024,2,'2026-09-22 08:11:18'),(6,'S006','刘婷','liuting@example.com',2024,3,'2026-09-22 08:11:18'),(7,'S007','孙磊','sunlei@example.com',2024,1,'2026-09-22 08:11:18'),(8,'S008','周颖','zhouying@example.com',2024,2,'2026-09-22 08:11:18'),(9,'S009','郑涛','zhengtao@example.com',2024,3,'2026-09-22 08:11:18'),(10,'S010','林悦','linyue@example.com',2024,1,'2026-09-22 08:11:18'),(11,'S011','何宇','heyu@example.com',2025,1,'2026-09-22 08:11:18'),(12,'S012','高峰','gaofeng@example.com',2025,2,'2026-09-22 08:11:18'),(13,'S013','吴桐','wutong@example.com',2025,3,'2026-09-22 08:11:18'),(14,'S014','冯雪','fengxue@example.com',2025,1,'2026-09-22 08:11:18'),(15,'S015','许晨','xuchen@example.com',2025,2,'2026-09-22 08:11:18'),(16,'S016','马超','machao@example.com',2025,3,'2026-09-22 08:11:18'),(17,'S017','唐欣','tangxin@example.com',2025,1,'2026-09-22 08:11:18'),(18,'S018','宋阳','songyang@example.com',2025,2,'2026-09-22 08:11:18'),(19,'S019','韩梅','hanmei@example.com',2025,3,'2026-09-22 08:11:18'),(20,'S020','罗杰','luojie@example.com',2025,1,'2026-09-22 08:11:18'),(21,'S021','王宇轩','wangyuxuan@example.com',2026,1,'2026-09-22 08:11:18'),(22,'S022','张敏','zhangmin@example.com',2026,2,'2026-09-22 08:11:18'),(23,'S023','李晨','lichen@example.com',2026,3,'2026-09-22 08:11:18'),(24,'S024','赵凯','zhaokai@example.com',2026,1,'2026-09-22 08:11:18'),(25,'S025','陈雨','chenyu@example.com',2026,2,'2026-09-22 08:11:18'),(26,'S026','刘洋','liuyang.student@example.com',2026,3,'2026-09-22 08:11:18'),(27,'S027','孙浩','sunhao@example.com',2026,1,'2026-09-22 08:11:18'),(28,'S028','周雪','zhouxue@example.com',2026,2,'2026-09-22 08:11:18'),(29,'S029','郑宇','zhengyu@example.com',2026,3,'2026-09-22 08:11:18'),(30,'S030','林晨','linchen@example.com',2026,1,'2026-09-22 08:11:18');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teachers` (
  `teacher_id` int NOT NULL AUTO_INCREMENT,
  `teacher_no` varchar(50) NOT NULL,
  `teacher_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `department_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`teacher_id`),
  UNIQUE KEY `teacher_no` (`teacher_no`),
  UNIQUE KEY `email` (`email`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (1,'T001','张三','zhangsan@example.com',1,'2026-09-22 08:04:26'),(2,'T002','李四','lisi@example.com',2,'2026-09-22 08:04:26'),(3,'T003','王五','wangwu@example.com',3,'2026-09-22 08:04:26'),(4,'T004','赵六','zhaoliu@example.com',1,'2026-09-22 08:04:26'),(5,'T005','陈晨','chenchen@example.com',1,'2026-09-22 08:04:26'),(6,'T006','刘洋','liuyang@example.com',2,'2026-09-22 08:04:26'),(7,'T007','孙悦','sunyue@example.com',3,'2026-09-22 08:04:26'),(8,'T008','周杰','zhoujie@example.com',1,'2026-09-22 08:04:26'),(9,'T009','郑凯','zhengkai@example.com',2,'2026-09-22 08:04:26'),(10,'T010','林雪','linxue@example.com',3,'2026-09-22 08:04:26');
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-22  3:56:50
