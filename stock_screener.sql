-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: stock_screener
-- ------------------------------------------------------
-- Server version	8.0.46

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
-- Table structure for table `balance_sheets`
--

DROP TABLE IF EXISTS `balance_sheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `balance_sheets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `period_id` int NOT NULL,
  `total_assets` decimal(20,2) DEFAULT NULL,
  `total_equity` decimal(20,2) DEFAULT NULL,
  `total_debt` decimal(20,2) DEFAULT NULL,
  `cash_and_equivalents` decimal(20,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_balance` (`company_id`,`period_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `balance_sheets_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `balance_sheets_ibfk_2` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `balance_sheets`
--

LOCK TABLES `balance_sheets` WRITE;
/*!40000 ALTER TABLE `balance_sheets` DISABLE KEYS */;
INSERT INTO `balance_sheets` VALUES (1,1,1,200000.00,120000.00,30000.00,15000.00);
/*!40000 ALTER TABLE `balance_sheets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cash_flows`
--

DROP TABLE IF EXISTS `cash_flows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cash_flows` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `period_id` int NOT NULL,
  `operating_cash_flow` decimal(20,2) DEFAULT NULL,
  `investing_cash_flow` decimal(20,2) DEFAULT NULL,
  `financing_cash_flow` decimal(20,2) DEFAULT NULL,
  `capital_expenditure` decimal(20,2) DEFAULT NULL,
  `free_cash_flow` decimal(20,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cash` (`company_id`,`period_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `cash_flows_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cash_flows_ibfk_2` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_flows`
--

LOCK TABLES `cash_flows` WRITE;
/*!40000 ALTER TABLE `cash_flows` DISABLE KEYS */;
INSERT INTO `cash_flows` VALUES (1,1,1,18000.00,-9000.00,-4000.00,7000.00,11000.00);
/*!40000 ALTER TABLE `cash_flows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `symbol` varchar(30) NOT NULL,
  `name` varchar(255) NOT NULL,
  `isin` varchar(20) DEFAULT NULL,
  `exchange` varchar(20) DEFAULT NULL,
  `sector` varchar(100) DEFAULT NULL,
  `industry` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `symbol` (`symbol`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,'DEMO1','Demo Company Ltd','INE000000001','NSE','Technology','Software');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_periods`
--

DROP TABLE IF EXISTS `financial_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_periods` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `period_type` varchar(20) NOT NULL,
  `fiscal_year` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_period` (`company_id`,`period_type`,`fiscal_year`),
  CONSTRAINT `financial_periods_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_periods`
--

LOCK TABLES `financial_periods` WRITE;
/*!40000 ALTER TABLE `financial_periods` DISABLE KEYS */;
INSERT INTO `financial_periods` VALUES (1,1,'annual',2026);
/*!40000 ALTER TABLE `financial_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_ratios`
--

DROP TABLE IF EXISTS `financial_ratios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_ratios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `period_id` int NOT NULL,
  `pe_ratio` decimal(14,4) DEFAULT NULL,
  `pb_ratio` decimal(14,4) DEFAULT NULL,
  `peg_ratio` decimal(14,4) DEFAULT NULL,
  `ev_to_ebitda` decimal(14,4) DEFAULT NULL,
  `ev_to_sales` decimal(14,4) DEFAULT NULL,
  `price_to_sales` decimal(14,4) DEFAULT NULL,
  `dividend_yield` decimal(14,4) DEFAULT NULL,
  `roe` decimal(14,4) DEFAULT NULL,
  `roce` decimal(14,4) DEFAULT NULL,
  `roa` decimal(14,4) DEFAULT NULL,
  `opm` decimal(14,4) DEFAULT NULL,
  `npm` decimal(14,4) DEFAULT NULL,
  `gross_margin` decimal(14,4) DEFAULT NULL,
  `ebitda_margin` decimal(14,4) DEFAULT NULL,
  `revenue_growth` decimal(14,4) DEFAULT NULL,
  `profit_growth` decimal(14,4) DEFAULT NULL,
  `eps_growth` decimal(14,4) DEFAULT NULL,
  `debt_to_equity` decimal(14,4) DEFAULT NULL,
  `interest_coverage` decimal(14,4) DEFAULT NULL,
  `current_ratio` decimal(14,4) DEFAULT NULL,
  `quick_ratio` decimal(14,4) DEFAULT NULL,
  `debt_to_ebitda` decimal(14,4) DEFAULT NULL,
  `cfo_to_pat` decimal(14,4) DEFAULT NULL,
  `cfo_to_revenue` decimal(14,4) DEFAULT NULL,
  `fcf_margin` decimal(14,4) DEFAULT NULL,
  `capex_to_revenue` decimal(14,4) DEFAULT NULL,
  `altman_z` decimal(14,4) DEFAULT NULL,
  `piotroski_score` decimal(14,4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ratios` (`company_id`,`period_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `financial_ratios_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `financial_ratios_ibfk_2` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_ratios`
--

LOCK TABLES `financial_ratios` WRITE;
/*!40000 ALTER TABLE `financial_ratios` DISABLE KEYS */;
INSERT INTO `financial_ratios` VALUES (1,1,1,18.5000,3.2000,1.1000,NULL,NULL,NULL,NULL,18.0000,22.0000,NULL,25.0000,15.0000,NULL,NULL,12.0000,14.0000,13.0000,0.2500,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4.1000,7.0000);
/*!40000 ALTER TABLE `financial_ratios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `income_statements`
--

DROP TABLE IF EXISTS `income_statements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `income_statements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `period_id` int NOT NULL,
  `revenue` decimal(20,2) DEFAULT NULL,
  `operating_profit` decimal(20,2) DEFAULT NULL,
  `ebit` decimal(20,2) DEFAULT NULL,
  `profit_before_tax` decimal(20,2) DEFAULT NULL,
  `net_profit` decimal(20,2) DEFAULT NULL,
  `eps` decimal(12,4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_income` (`company_id`,`period_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `income_statements_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `income_statements_ibfk_2` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `income_statements`
--

LOCK TABLES `income_statements` WRITE;
/*!40000 ALTER TABLE `income_statements` DISABLE KEYS */;
INSERT INTO `income_statements` VALUES (1,1,1,100000.00,25000.00,22000.00,20000.00,15000.00,12.5000);
/*!40000 ALTER TABLE `income_statements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `market_data`
--

DROP TABLE IF EXISTS `market_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `market_data` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int NOT NULL,
  `last_price` decimal(14,2) DEFAULT NULL,
  `previous_close` decimal(14,2) DEFAULT NULL,
  `volume` bigint DEFAULT NULL,
  `market_cap` decimal(22,2) DEFAULT NULL,
  `week_52_high` decimal(14,2) DEFAULT NULL,
  `week_52_low` decimal(14,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `company_id` (`company_id`),
  CONSTRAINT `market_data_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `market_data`
--

LOCK TABLES `market_data` WRITE;
/*!40000 ALTER TABLE `market_data` DISABLE KEYS */;
INSERT INTO `market_data` VALUES (1,1,231.25,228.90,1250000,150000000.00,260.00,180.00);
/*!40000 ALTER TABLE `market_data` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-11 12:20:41
