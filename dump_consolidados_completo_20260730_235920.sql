-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: cc
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
-- Table structure for table `canal`
--

DROP TABLE IF EXISTS `canal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `canal` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canal`
--

LOCK TABLES `canal` WRITE;
/*!40000 ALTER TABLE `canal` DISABLE KEYS */;
INSERT INTO `canal` VALUES (9,'Facebook'),(1,'Instagram'),(7,'Otro'),(3,'Presencial'),(2,'WhatsApp');
/*!40000 ALTER TABLE `canal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capital_movimiento`
--

DROP TABLE IF EXISTS `capital_movimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `capital_movimiento` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `socio_id` smallint NOT NULL,
  `tipo` enum('APORTACION','RETIRO','REINVERSION','GANANCIA','RETIRO_COMISION') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `monto_mxn` decimal(10,2) NOT NULL,
  `concepto` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_capital_socio` (`socio_id`),
  CONSTRAINT `fk_capital_socio` FOREIGN KEY (`socio_id`) REFERENCES `socio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capital_movimiento`
--

LOCK TABLES `capital_movimiento` WRITE;
/*!40000 ALTER TABLE `capital_movimiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `capital_movimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cierre_mensual`
--

DROP TABLE IF EXISTS `cierre_mensual`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cierre_mensual` (
  `id` int NOT NULL AUTO_INCREMENT,
  `mes` int NOT NULL,
  `anio` int NOT NULL,
  `fecha_cierre` date NOT NULL,
  `ingresos_totales` decimal(10,2) NOT NULL,
  `costo_ventas` decimal(10,2) NOT NULL,
  `comisiones_totales` decimal(10,2) NOT NULL,
  `utilidad_neta` decimal(10,2) NOT NULL,
  `valor_inventario` decimal(10,2) NOT NULL,
  `num_ventas` int NOT NULL,
  `num_piezas_vendidas` int NOT NULL,
  `ticket_promedio` decimal(10,2) NOT NULL,
  `comisiones_json` json DEFAULT NULL,
  `capital_json` json DEFAULT NULL,
  `notas` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mes` (`mes`,`anio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cierre_mensual`
--

LOCK TABLES `cierre_mensual` WRITE;
/*!40000 ALTER TABLE `cierre_mensual` DISABLE KEYS */;
/*!40000 ALTER TABLE `cierre_mensual` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comision_tarifa`
--

DROP TABLE IF EXISTS `comision_tarifa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comision_tarifa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rol_venta_id` smallint NOT NULL,
  `pct` decimal(6,4) NOT NULL,
  `vigente_desde` date NOT NULL,
  `vigente_hasta` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ct` (`rol_venta_id`,`vigente_desde`),
  CONSTRAINT `fk_ct_rol` FOREIGN KEY (`rol_venta_id`) REFERENCES `rol_venta` (`id`),
  CONSTRAINT `ck_ct_pct` CHECK (((`pct` >= 0) and (`pct` <= 1)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comision_tarifa`
--

LOCK TABLES `comision_tarifa` WRITE;
/*!40000 ALTER TABLE `comision_tarifa` DISABLE KEYS */;
INSERT INTO `comision_tarifa` VALUES (1,1,0.0800,'2026-01-01',NULL),(2,2,0.0500,'2026-01-01',NULL);
/*!40000 ALTER TABLE `comision_tarifa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `config`
--

DROP TABLE IF EXISTS `config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `config` (
  `clave` varchar(60) NOT NULL,
  `valor` text NOT NULL,
  `descripcion` text,
  PRIMARY KEY (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `config`
--

LOCK TABLES `config` WRITE;
/*!40000 ALTER TABLE `config` DISABLE KEYS */;
/*!40000 ALTER TABLE `config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion`
--

DROP TABLE IF EXISTS `configuracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracion` (
  `clave` varchar(50) NOT NULL,
  `valor` text NOT NULL,
  `tipo` enum('TEXT','NUMBER','BOOLEAN','JSON') DEFAULT 'TEXT',
  `descripcion` varchar(200) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion`
--

LOCK TABLES `configuracion` WRITE;
/*!40000 ALTER TABLE `configuracion` DISABLE KEYS */;
INSERT INTO `configuracion` VALUES ('alertas_stock_minimo','2','NUMBER','Alerta cuando stock <= este valor','2026-07-30 04:31:58'),('comision_entrega_pct','0.05','NUMBER','ComisiÃ³n de entrega (decimal)','2026-07-30 04:31:58'),('comision_negociador_pct','0.08','NUMBER','ComisiÃ³n del negociador (decimal)','2026-07-30 04:31:58'),('costo_envio_promedio_usd','50.0','NUMBER','Costo promedio de envÃ­o por paquete','2026-07-30 04:31:58'),('tipo_cambio_usd_mxn','20.0','NUMBER','Tipo de cambio USD a MXN','2026-07-30 04:31:57');
/*!40000 ALTER TABLE `configuracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cruce`
--

DROP TABLE IF EXISTS `cruce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cruce` (
  `id` int NOT NULL AUTO_INCREMENT,
  `folio` varchar(40) NOT NULL,
  `fecha` date NOT NULL,
  `costo_mxn` decimal(12,2) DEFAULT NULL COMMENT 'NULL = pendiente de cálculo, no confundir con 0.00',
  `notas` text,
  `exchange_rate_usd_mxn` decimal(10,4) DEFAULT NULL COMMENT 'Tipo de cambio USD→MXN usado en este cruce',
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cruce`
--

LOCK TABLES `cruce` WRITE;
/*!40000 ALTER TABLE `cruce` DISABLE KEYS */;
INSERT INTO `cruce` VALUES (25,'CONS9928546710','2026-03-25',1100.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $1,100 MXN (5 paquetes, 4.21 kg)',NULL),(26,'CONS9943741515','2026-04-08',1400.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $1,400 MXN (9 paquetes, 7.26 kg)',NULL),(27,'CONS9943741691','2026-04-16',1200.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $1,200 MXN (6 paquetes, 5.44 kg)',NULL),(28,'CONS9943741870','2026-04-27',1400.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $1,400 MXN (8 paquetes, 7.13 kg)',NULL),(29,'CONS9943742286','2026-05-21',1100.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $1,100 MXN (5 paquetes, 4.37 kg)',NULL),(30,'CONS9962926323','2026-07-08',2000.00,'Consolidados 2026-07-30\nCosto importaciÃ³n: $2,000 MXN (14 paquetes, 13.02 kg)',NULL),(31,'CONS_FUERA_1Z08X89AYW00349426','2026-01-01',2686.50,'Consolidados 2026-07-30',18.0000),(32,'CONS_FUERA_380416815890','2026-01-01',NULL,'Consolidados 2026-07-30',NULL),(33,'CONS_FUERA_380419641012','2026-01-01',NULL,'Consolidados 2026-07-30',NULL),(34,'CONS_FUERA_382233588111','2026-01-01',NULL,'Consolidados 2026-07-30',NULL),(35,'CONS_SIN_ASIGNAR_202607','2026-01-01',2116.08,'Consolidados 2026-07-30',18.0000),(36,'SBAAAAQLJHVRGP222_FEDEX382233588111','2026-01-01',11608.74,'Consolidados 2026-07-30',18.0000);
/*!40000 ALTER TABLE `cruce` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deuda`
--

DROP TABLE IF EXISTS `deuda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deuda` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `deudor_id` smallint NOT NULL,
  `tipo` varchar(24) NOT NULL,
  `pieza_id` int DEFAULT NULL,
  `concepto` varchar(300) NOT NULL,
  `monto_mxn` decimal(12,2) NOT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'PENDIENTE',
  `pagado_mxn` decimal(12,2) NOT NULL DEFAULT '0.00',
  `notas` text,
  PRIMARY KEY (`id`),
  KEY `fk_deuda_pieza` (`pieza_id`),
  KEY `ix_deuda_deudor` (`deudor_id`,`estado`),
  CONSTRAINT `fk_deuda_pieza` FOREIGN KEY (`pieza_id`) REFERENCES `pieza` (`id`),
  CONSTRAINT `fk_deuda_socio` FOREIGN KEY (`deudor_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `ck_deuda_estado` CHECK ((`estado` in (_utf8mb4'PENDIENTE',_utf8mb4'PARCIAL',_utf8mb4'PAGADA',_utf8mb4'CONDONADA'))),
  CONSTRAINT `ck_deuda_tipo` CHECK ((`tipo` in (_utf8mb4'CRUCE_PERSONAL',_utf8mb4'MERCANCIA_PERSONAL',_utf8mb4'PRESTAMO',_utf8mb4'OTRO')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deuda`
--

LOCK TABLES `deuda` WRITE;
/*!40000 ALTER TABLE `deuda` DISABLE KEYS */;
/*!40000 ALTER TABLE `deuda` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `factor_volumetrico`
--

DROP TABLE IF EXISTS `factor_volumetrico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `factor_volumetrico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `marca_id` smallint NOT NULL,
  `tipo_prenda_id` smallint NOT NULL,
  `factor` decimal(6,3) NOT NULL,
  `vigente_desde` date NOT NULL DEFAULT '2026-01-01',
  `vigente_hasta` date DEFAULT NULL,
  `nota` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fv` (`marca_id`,`tipo_prenda_id`,`vigente_desde`),
  KEY `fk_fv_tipo` (`tipo_prenda_id`),
  CONSTRAINT `fk_fv_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_fv_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`),
  CONSTRAINT `ck_fv_factor` CHECK ((`factor` > 0)),
  CONSTRAINT `ck_fv_vigencia` CHECK (((`vigente_hasta` is null) or (`vigente_hasta` > `vigente_desde`)))
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factor_volumetrico`
--

LOCK TABLES `factor_volumetrico` WRITE;
/*!40000 ALTER TABLE `factor_volumetrico` DISABLE KEYS */;
INSERT INTO `factor_volumetrico` VALUES (1,1,9,0.600,'2026-01-01',NULL,NULL),(2,1,8,0.700,'2026-01-01',NULL,NULL),(3,1,2,0.900,'2026-01-01',NULL,NULL),(4,1,1,1.000,'2026-01-01',NULL,NULL),(5,1,3,1.100,'2026-01-01',NULL,NULL),(6,1,5,1.800,'2026-01-01',NULL,NULL),(7,1,6,2.500,'2026-01-01',NULL,NULL),(8,1,7,2.800,'2026-01-01',NULL,NULL),(9,2,1,0.600,'2026-01-01',NULL,NULL),(11,2,10,0.400,'2026-01-01',NULL,NULL),(12,2,8,0.600,'2026-01-01',NULL,NULL),(13,2,11,1.000,'2026-01-01',NULL,NULL),(14,2,4,1.200,'2026-01-01',NULL,NULL),(15,2,5,1.800,'2026-01-01',NULL,NULL),(16,2,6,2.500,'2026-01-01',NULL,NULL),(17,1,4,1.800,'2026-01-01',NULL,NULL),(19,2,7,0.600,'2026-01-01',NULL,NULL),(20,2,3,2.500,'2026-01-01',NULL,NULL);
/*!40000 ALTER TABLE `factor_volumetrico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `marca`
--

DROP TABLE IF EXISTS `marca`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marca` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marca`
--

LOCK TABLES `marca` WRITE;
/*!40000 ALTER TABLE `marca` DISABLE KEYS */;
INSERT INTO `marca` VALUES (16,'Breath Divinity'),(6,'Civil Regime'),(5,'Cockbear'),(2,'Gymshark'),(7,'Onyx'),(4,'Otro'),(1,'YoungLA');
/*!40000 ALTER TABLE `marca` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movimiento`
--

DROP TABLE IF EXISTS `movimiento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `movimiento` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `sku_id` int NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `cantidad` int NOT NULL,
  `ubicacion_origen_id` smallint DEFAULT NULL,
  `ubicacion_destino_id` smallint DEFAULT NULL,
  `pieza_id` int DEFAULT NULL,
  `venta_id` int DEFAULT NULL,
  `responsable_id` smallint DEFAULT NULL,
  `notas` text,
  PRIMARY KEY (`id`),
  KEY `fk_mov_uborigen` (`ubicacion_origen_id`),
  KEY `fk_mov_ubdest` (`ubicacion_destino_id`),
  KEY `fk_mov_pieza` (`pieza_id`),
  KEY `fk_mov_resp` (`responsable_id`),
  KEY `ix_mov_sku_tipo` (`sku_id`,`tipo`),
  KEY `fk_mov_venta` (`venta_id`),
  CONSTRAINT `fk_mov_pieza` FOREIGN KEY (`pieza_id`) REFERENCES `pieza` (`id`),
  CONSTRAINT `fk_mov_resp` FOREIGN KEY (`responsable_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `fk_mov_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_mov_ubdest` FOREIGN KEY (`ubicacion_destino_id`) REFERENCES `ubicacion` (`id`),
  CONSTRAINT `fk_mov_uborigen` FOREIGN KEY (`ubicacion_origen_id`) REFERENCES `ubicacion` (`id`),
  CONSTRAINT `fk_mov_venta` FOREIGN KEY (`venta_id`) REFERENCES `venta` (`id`),
  CONSTRAINT `ck_mov_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `ck_mov_tipo` CHECK ((`tipo` in (_utf8mb4'COMPRA',_utf8mb4'VENTA',_utf8mb4'TRASLADO_SALIDA',_utf8mb4'TRASLADO_ENTRADA',_utf8mb4'AJUSTE_MAS',_utf8mb4'AJUSTE_MENOS',_utf8mb4'DEVOLUCION')))
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento`
--

LOCK TABLES `movimiento` WRITE;
/*!40000 ALTER TABLE `movimiento` DISABLE KEYS */;
INSERT INTO `movimiento` VALUES (9,'2026-03-24',14,'COMPRA',1,NULL,1,NULL,NULL,NULL,'foundation cropped tee black Medium 36usd'),(10,'2026-03-24',12,'COMPRA',1,NULL,1,NULL,NULL,NULL,'flagship track pants black medium 50usd'),(11,'2026-03-24',15,'COMPRA',1,NULL,1,NULL,NULL,NULL,'immortal killer joggers black medium 50usd'),(12,'2026-03-24',7,'COMPRA',1,NULL,1,NULL,NULL,NULL,'supervillain black medium 38usd'),(13,'2026-03-24',13,'COMPRA',1,NULL,1,NULL,NULL,NULL,'flagship track pants burgundy medium 50usd'),(14,'2026-03-23',8,'COMPRA',1,NULL,1,NULL,NULL,NULL,'warrior red medium 42usd'),(15,'2026-03-23',10,'COMPRA',1,NULL,1,NULL,NULL,NULL,'batman black medium 48usd'),(16,'2026-03-23',9,'COMPRA',1,NULL,1,NULL,NULL,NULL,'batman black small 48usd'),(17,'2026-04-06',28,'COMPRA',1,NULL,1,NULL,NULL,NULL,'onyx hoodie red M 57.60usd'),(18,'2026-04-06',27,'COMPRA',1,NULL,1,NULL,NULL,NULL,'onyx hoodie purple M 57.60usd'),(19,'2026-03-31',26,'COMPRA',1,NULL,1,NULL,NULL,NULL,'demon slayer rengoku tee 42usd (Jacqui)'),(20,'2026-04-21',33,'COMPRA',1,NULL,1,NULL,NULL,NULL,'W472 Legacy Seamless Tank Dusty Blue / XSmall 18usd'),(21,'2026-04-21',32,'COMPRA',1,NULL,1,NULL,NULL,NULL,'W149 Curve Hourglass Biker Shorts 6.5\" Grey / Small 26usd'),(22,'2026-04-21',31,'COMPRA',1,NULL,1,NULL,NULL,NULL,'4255 Batman Midnight Tees Joker P / Medium 22usd'),(23,'2026-04-21',11,'COMPRA',1,NULL,1,NULL,NULL,NULL,'BATMAN WHITE M 48usd'),(24,'2026-04-21',41,'COMPRA',1,NULL,1,NULL,NULL,NULL,'BATMAN ZIPUP M 76usd'),(25,'2026-04-21',40,'COMPRA',1,NULL,1,NULL,NULL,NULL,'BATMAN SWEATS M 76usd'),(26,'2026-05-14',44,'COMPRA',1,NULL,1,NULL,NULL,NULL,'CBUM Washed Hoodie Bros Stone Grey Marl Medium 70.20usd'),(27,'2026-05-14',43,'COMPRA',1,NULL,1,NULL,NULL,NULL,'CBUM Hockey Jersey Black Medium 50.40usd'),(28,'2026-05-14',42,'COMPRA',1,NULL,1,NULL,NULL,NULL,'CBUM Straight Leg Jogger Black Medium 63.00usd'),(29,'2026-06-26',45,'COMPRA',1,NULL,1,NULL,NULL,NULL,'Vital 1/4 Zip Black/Silhouette Grey Large 39.60usd'),(41,'2026-05-07',31,'VENTA',1,NULL,NULL,NULL,14,NULL,'Venta V-1'),(42,'2026-03-28',9,'VENTA',1,NULL,NULL,NULL,15,NULL,'Venta V-2'),(43,'2026-04-16',10,'VENTA',1,NULL,NULL,NULL,16,NULL,'Venta V-3'),(44,'2026-05-08',14,'VENTA',1,NULL,NULL,NULL,17,NULL,'Venta V-4'),(45,'2026-04-16',17,'VENTA',1,NULL,NULL,NULL,18,NULL,'Venta V-5'),(47,'2026-04-18',28,'VENTA',1,NULL,NULL,NULL,20,NULL,'Venta V-7'),(48,'2026-05-06',22,'VENTA',1,NULL,NULL,NULL,21,NULL,'Venta V-8'),(49,'2026-04-23',26,'VENTA',1,NULL,NULL,NULL,22,NULL,'Venta V-9'),(50,'2026-06-15',16,'VENTA',1,NULL,NULL,NULL,23,NULL,'Venta V-10'),(51,'2026-06-15',19,'VENTA',1,NULL,NULL,NULL,24,NULL,'Venta V-11'),(52,'2026-04-16',27,'VENTA',1,NULL,NULL,NULL,19,NULL,'Venta'),(53,'2026-07-30',24,'COMPRA',1,NULL,2,80,NULL,NULL,'ONYX V5 LONGSLEEVE S PURPPLE'),(54,'2026-07-30',25,'COMPRA',1,NULL,2,81,NULL,NULL,'ONYX V5 LONGSLEEVE XS OG BLUE'),(55,'2026-07-30',17,'COMPRA',1,NULL,NULL,106,NULL,NULL,NULL),(56,'2026-07-30',22,'COMPRA',1,NULL,NULL,107,NULL,NULL,NULL),(57,'2026-07-30',16,'COMPRA',1,NULL,NULL,108,NULL,NULL,NULL),(58,'2026-07-30',19,'COMPRA',1,NULL,NULL,109,NULL,NULL,NULL),(62,'2026-04-06',29,'COMPRA',1,NULL,NULL,49,NULL,NULL,NULL),(63,'2026-07-30',18,'COMPRA',1,NULL,NULL,NULL,NULL,NULL,NULL),(64,'2026-07-30',20,'COMPRA',1,NULL,NULL,NULL,NULL,NULL,NULL),(65,'2026-07-30',21,'COMPRA',1,NULL,NULL,NULL,NULL,NULL,NULL),(67,'2026-07-30',23,'COMPRA',1,NULL,NULL,NULL,NULL,NULL,NULL),(68,'2026-07-30',36,'COMPRA',1,NULL,NULL,87,NULL,NULL,NULL),(69,'2026-07-30',39,'COMPRA',1,NULL,NULL,90,NULL,NULL,NULL),(70,'2026-07-30',37,'COMPRA',1,NULL,NULL,92,NULL,NULL,NULL),(71,'2026-07-30',35,'COMPRA',1,NULL,NULL,89,NULL,NULL,NULL),(72,'2026-07-30',38,'COMPRA',1,NULL,NULL,88,NULL,NULL,NULL),(73,'2026-07-30',34,'COMPRA',1,NULL,NULL,91,NULL,NULL,NULL),(75,'2026-07-30',48,'COMPRA',1,NULL,NULL,NULL,NULL,NULL,'Compra Fitbos - Campus Hoodie M Grey'),(76,'2026-07-30',41,'VENTA',1,NULL,NULL,NULL,25,NULL,'Venta');
/*!40000 ALTER TABLE `movimiento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paquete`
--

DROP TABLE IF EXISTS `paquete`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paquete` (
  `id` int NOT NULL AUTO_INCREMENT,
  `guia` varchar(60) NOT NULL,
  `paqueteria_id` smallint DEFAULT NULL,
  `cruce_id` int DEFAULT NULL,
  `pedido_proveedor_id` int DEFAULT NULL,
  `fecha_llegada` date DEFAULT NULL,
  `ubicacion_id` smallint DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'RECIBIDO',
  `notas` text,
  `guide_raw` varchar(120) DEFAULT NULL COMMENT 'Guía completa sin limpiar, preserva prefijos como CASI',
  `tracking_number` varchar(100) DEFAULT NULL COMMENT 'Número de tracking limpio, sin prefijos',
  `fecha_envio` date DEFAULT NULL COMMENT 'Fecha de envío del paquete',
  `largo_cm` decimal(10,2) DEFAULT NULL COMMENT 'Largo del paquete en centímetros',
  `ancho_cm` decimal(10,2) DEFAULT NULL COMMENT 'Ancho del paquete en centímetros',
  `alto_cm` decimal(10,2) DEFAULT NULL COMMENT 'Alto del paquete en centímetros',
  `peso_real_kg` decimal(10,4) DEFAULT NULL COMMENT 'Peso real del paquete en kilogramos',
  `peso_volumetrico_kg` decimal(10,4) DEFAULT NULL COMMENT 'Peso volumétrico calculado (L×W×H/5000)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `guia` (`guia`),
  KEY `fk_paquete_paqueteria` (`paqueteria_id`),
  KEY `fk_paquete_cruce` (`cruce_id`),
  KEY `fk_paquete_pedido` (`pedido_proveedor_id`),
  KEY `fk_paquete_ubicacion` (`ubicacion_id`),
  KEY `ix_paquete_tracking` (`tracking_number`),
  CONSTRAINT `fk_paquete_cruce` FOREIGN KEY (`cruce_id`) REFERENCES `cruce` (`id`),
  CONSTRAINT `fk_paquete_paqueteria` FOREIGN KEY (`paqueteria_id`) REFERENCES `paqueteria` (`id`),
  CONSTRAINT `fk_paquete_pedido` FOREIGN KEY (`pedido_proveedor_id`) REFERENCES `pedido_proveedor` (`id`),
  CONSTRAINT `fk_paquete_ubicacion` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicacion` (`id`),
  CONSTRAINT `ck_paquete_estado` CHECK ((`estado` in (_utf8mb4'PENDIENTE',_utf8mb4'EN_TRANSITO',_utf8mb4'RECIBIDO',_utf8mb4'CANCELADO')))
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paquete`
--

LOCK TABLES `paquete` WRITE;
/*!40000 ALTER TABLE `paquete` DISABLE KEYS */;
INSERT INTO `paquete` VALUES (51,'1Z08X89A0320535275',1,36,NULL,NULL,NULL,'RECIBIDO',NULL,'1Z08X89A0320535275','1Z08X89A0320535275',NULL,NULL,NULL,NULL,NULL,NULL),(52,'1Z08X89AYW00349426',1,31,NULL,NULL,NULL,'RECIBIDO',NULL,'1Z08X89AYW00349426','1Z08X89AYW00349426',NULL,NULL,NULL,NULL,NULL,NULL),(53,'1Z08X89AYW01891981',1,36,NULL,NULL,NULL,'RECIBIDO',NULL,'1Z08X89AYW01891981','1Z08X89AYW01891981',NULL,NULL,NULL,NULL,NULL,NULL),(54,'1Z08YY74YW30322345',1,36,NULL,NULL,NULL,'RECIBIDO',NULL,'1Z08YY74YW30322345','1Z08YY74YW30322345',NULL,NULL,NULL,NULL,NULL,NULL),(55,'380416815890',NULL,32,NULL,NULL,NULL,'RECIBIDO',NULL,'380416815890','380416815890',NULL,NULL,NULL,NULL,NULL,NULL),(56,'380419641012',NULL,33,NULL,NULL,NULL,'RECIBIDO',NULL,'380419641012','380419641012',NULL,NULL,NULL,NULL,NULL,NULL),(57,'382233588111',NULL,34,NULL,NULL,NULL,'RECIBIDO',NULL,'382233588111','382233588111',NULL,NULL,NULL,NULL,NULL,NULL),(58,'4207852170149334620826000001283829',2,35,NULL,NULL,NULL,'RECIBIDO',NULL,'4207852170149334620826000001283829','4207852170149334620826000001283829',NULL,NULL,NULL,NULL,NULL,NULL),(59,'1Z08X89A0300826855',1,29,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI1Z08X89A0300826855','1Z08X89A0300826855',NULL,NULL,NULL,NULL,NULL,NULL),(60,'1Z08X89A0301650873',1,30,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI1Z08X89A0301650873','1Z08X89A0301650873',NULL,NULL,NULL,NULL,NULL,NULL),(61,'1Z08X89A0320538281',1,26,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI1Z08X89A0320538281','1Z08X89A0320538281',NULL,NULL,NULL,NULL,NULL,NULL),(62,'1Z1F92320318576758',1,30,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI1Z1F92320318576758','1Z1F92320318576758',NULL,NULL,NULL,NULL,NULL,NULL),(63,'1ZC1R7210300545183',1,28,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI1ZC1R7210300545183','1ZC1R7210300545183',NULL,NULL,NULL,NULL,NULL,NULL),(64,'4207852170149400108106244117836182',2,29,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI4207852170149400108106244117836182','4207852170149400108106244117836182',NULL,NULL,NULL,NULL,NULL,NULL),(65,'4207852170149434908106245318083125',2,30,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI4207852170149434908106245318083125','4207852170149434908106245318083125',NULL,NULL,NULL,NULL,NULL,NULL),(66,'420785219200190244541414837086',2,27,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219200190244541414837086','420785219200190244541414837086',NULL,NULL,NULL,NULL,NULL,NULL),(67,'420785219200190244541419304040',2,30,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219200190244541419304040','420785219200190244541419304040',NULL,NULL,NULL,NULL,NULL,NULL),(68,'420785219205590267338805428145',2,29,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219205590267338805428145','420785219205590267338805428145',NULL,NULL,NULL,NULL,NULL,NULL),(69,'420785219205590267338808841279',2,30,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219205590267338808841279','420785219205590267338808841279',NULL,NULL,NULL,NULL,NULL,NULL),(70,'420785219400140109629002153594',2,26,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219400140109629002153594','420785219400140109629002153594',NULL,NULL,NULL,NULL,NULL,NULL),(71,'420785219434640109629005034571',2,25,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219434640109629005034571','420785219434640109629005034571',NULL,NULL,NULL,NULL,NULL,NULL),(72,'420785219434640109629005071033',2,25,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219434640109629005071033','420785219434640109629005071033',NULL,NULL,NULL,NULL,NULL,NULL),(73,'420785219434640109629005267580',2,26,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219434640109629005267580','420785219434640109629005267580',NULL,NULL,NULL,NULL,NULL,NULL),(74,'420785219434640109629005663979',2,28,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219434640109629005663979','420785219434640109629005663979',NULL,NULL,NULL,NULL,NULL,NULL),(75,'420785219434640109629006011632',2,28,NULL,NULL,NULL,'RECIBIDO',NULL,'CASI420785219434640109629006011632','420785219434640109629006011632',NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `paquete` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paqueteria`
--

DROP TABLE IF EXISTS `paqueteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paqueteria` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(40) NOT NULL,
  `prefijo_guia` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paqueteria`
--

LOCK TABLES `paqueteria` WRITE;
/*!40000 ALTER TABLE `paqueteria` DISABLE KEYS */;
INSERT INTO `paqueteria` VALUES (1,'UPS','1Z'),(2,'USPS','420'),(3,'FedEx','38');
/*!40000 ALTER TABLE `paqueteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `folio` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proveedor_id` smallint NOT NULL,
  `socio_comprador_id` smallint DEFAULT NULL,
  `fecha_pedido` date NOT NULL,
  `fecha_estimada` date DEFAULT NULL,
  `fecha_recepcion` date DEFAULT NULL,
  `estado` enum('PENDIENTE','EN_TRANSITO','RECIBIDO','CANCELADO') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `tracking` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `costo_estimado_usd` decimal(12,2) DEFAULT NULL,
  `notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_pedido_tracking_socio` (`socio_comprador_id`),
  KEY `idx_pedido_estado` (`estado`),
  KEY `idx_pedido_fecha` (`fecha_pedido`),
  KEY `idx_pedido_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_pedido_tracking_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedor` (`id`),
  CONSTRAINT `fk_pedido_tracking_socio` FOREIGN KEY (`socio_comprador_id`) REFERENCES `socio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido`
--

LOCK TABLES `pedido` WRITE;
/*!40000 ALTER TABLE `pedido` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_linea`
--

DROP TABLE IF EXISTS `pedido_linea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_linea` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `sku_id` int DEFAULT NULL,
  `descripcion` varchar(200) NOT NULL,
  `cantidad` int NOT NULL,
  `costo_unitario_usd` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `pedido_linea_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedido_proveedor` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pedido_linea_ibfk_2` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_linea`
--

LOCK TABLES `pedido_linea` WRITE;
/*!40000 ALTER TABLE `pedido_linea` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_linea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_orden`
--

DROP TABLE IF EXISTS `pedido_orden`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_orden` (
  `id` int NOT NULL AUTO_INCREMENT,
  `folio` varchar(50) DEFAULT NULL,
  `fecha_pedido` date NOT NULL,
  `proveedor` varchar(100) NOT NULL,
  `estado` enum('PENDIENTE','EN_TRANSITO','RECIBIDO','CANCELADO') DEFAULT 'PENDIENTE',
  `guia_envio` varchar(100) DEFAULT NULL,
  `fecha_envio` date DEFAULT NULL,
  `fecha_recepcion` date DEFAULT NULL,
  `monto_total_usd` decimal(10,2) DEFAULT NULL,
  `notas` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_orden`
--

LOCK TABLES `pedido_orden` WRITE;
/*!40000 ALTER TABLE `pedido_orden` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_orden` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_orden_linea`
--

DROP TABLE IF EXISTS `pedido_orden_linea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_orden_linea` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_orden_id` int NOT NULL,
  `sku_id` int DEFAULT NULL,
  `descripcion` varchar(200) NOT NULL,
  `cantidad` int NOT NULL,
  `costo_unitario_usd` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_orden_id` (`pedido_orden_id`),
  KEY `sku_id` (`sku_id`),
  CONSTRAINT `pedido_orden_linea_ibfk_1` FOREIGN KEY (`pedido_orden_id`) REFERENCES `pedido_orden` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pedido_orden_linea_ibfk_2` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_orden_linea`
--

LOCK TABLES `pedido_orden_linea` WRITE;
/*!40000 ALTER TABLE `pedido_orden_linea` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_orden_linea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_pieza`
--

DROP TABLE IF EXISTS `pedido_pieza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_pieza` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `marca_id` smallint NOT NULL,
  `tipo_prenda_id` smallint NOT NULL,
  `sku_id` int DEFAULT NULL,
  `descripcion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad_pedida` int NOT NULL DEFAULT '1',
  `cantidad_recibida` int NOT NULL DEFAULT '0',
  `talla` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `costo_unitario_usd` decimal(10,2) DEFAULT NULL,
  `notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_pedido_pieza_marca` (`marca_id`),
  KEY `fk_pedido_pieza_tipo` (`tipo_prenda_id`),
  KEY `idx_pedido_pieza_pedido` (`pedido_id`),
  KEY `idx_pedido_pieza_sku` (`sku_id`),
  CONSTRAINT `fk_pedido_pieza_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_pedido_pieza_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedido` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pedido_pieza_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_pedido_pieza_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_pieza`
--

LOCK TABLES `pedido_pieza` WRITE;
/*!40000 ALTER TABLE `pedido_pieza` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_pieza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_proveedor`
--

DROP TABLE IF EXISTS `pedido_proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido_proveedor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `proveedor_id` smallint NOT NULL,
  `fecha` date NOT NULL,
  `codigo_descuento` varchar(40) DEFAULT NULL,
  `subtotal_usd` decimal(12,2) DEFAULT NULL,
  `descuento_usd` decimal(12,2) NOT NULL DEFAULT '0.00',
  `envio_usa_usd` decimal(12,2) NOT NULL DEFAULT '0.00',
  `impuestos_usd` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total_usd` decimal(12,2) NOT NULL,
  `tipo_cambio` decimal(8,4) DEFAULT NULL,
  `notas` text,
  `shipping_protection_usd` decimal(12,2) DEFAULT NULL COMMENT 'Costo de protección de envío',
  `adjustment_usd` decimal(12,2) DEFAULT NULL COMMENT 'Ajustes varios (positivos o negativos)',
  `discount_already_applied` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Si el descuento ya está aplicado en subtotal_usd',
  PRIMARY KEY (`id`),
  KEY `fk_pedido_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_pedido_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedor` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_proveedor`
--

LOCK TABLES `pedido_proveedor` WRITE;
/*!40000 ALTER TABLE `pedido_proveedor` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_proveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pieza`
--

DROP TABLE IF EXISTS `pieza`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pieza` (
  `id` int NOT NULL AUTO_INCREMENT,
  `paquete_id` int NOT NULL,
  `descripcion` varchar(300) NOT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `marca_id` smallint NOT NULL,
  `tipo_prenda_id` smallint NOT NULL,
  `factor_manual` decimal(6,3) DEFAULT NULL,
  `destino` varchar(10) NOT NULL,
  `socio_id` smallint DEFAULT NULL,
  `sku_id` int DEFAULT NULL,
  `costo_usd` decimal(12,2) DEFAULT NULL,
  `costo_unitario_mxn` decimal(12,2) DEFAULT NULL,
  `notas` text,
  `color` varchar(60) DEFAULT NULL COMMENT 'Color de la pieza (esencial para matching de SKU)',
  `talla` varchar(30) DEFAULT NULL COMMENT 'Talla de la pieza (esencial para matching de SKU)',
  `pedido_proveedor_id` int DEFAULT NULL COMMENT 'Origen financiero. NULL solo durante migración de históricos',
  PRIMARY KEY (`id`),
  KEY `fk_pieza_paquete` (`paquete_id`),
  KEY `fk_pieza_marca` (`marca_id`),
  KEY `fk_pieza_tipo` (`tipo_prenda_id`),
  KEY `fk_pieza_socio` (`socio_id`),
  KEY `fk_pieza_sku` (`sku_id`),
  KEY `ix_pieza_destino_socio` (`destino`,`socio_id`),
  KEY `ix_pieza_color` (`color`),
  KEY `ix_pieza_talla` (`talla`),
  KEY `ix_pieza_matching` (`marca_id`,`tipo_prenda_id`,`talla`,`color`),
  KEY `ix_pieza_pedido` (`pedido_proveedor_id`),
  CONSTRAINT `fk_pieza_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_pieza_paquete` FOREIGN KEY (`paquete_id`) REFERENCES `paquete` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pieza_pedido` FOREIGN KEY (`pedido_proveedor_id`) REFERENCES `pedido_proveedor` (`id`),
  CONSTRAINT `fk_pieza_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_pieza_socio` FOREIGN KEY (`socio_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `fk_pieza_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`),
  CONSTRAINT `ck_pieza_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `ck_pieza_destino` CHECK ((`destino` in (_utf8mb4'NEGOCIO',_utf8mb4'PERSONAL'))),
  CONSTRAINT `ck_pieza_factor` CHECK (((`factor_manual` is null) or (`factor_manual` > 0))),
  CONSTRAINT `personal_sin_sku` CHECK (((`destino` = _utf8mb4'NEGOCIO') or (`sku_id` is null)))
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pieza`
--

LOCK TABLES `pieza` WRITE;
/*!40000 ALTER TABLE `pieza` DISABLE KEYS */;
INSERT INTO `pieza` VALUES (119,72,'foundation cropped tee',1,4,1,0.500,'NEGOCIO',NULL,91,26.26,472.64,NULL,'black','M',NULL),(120,72,'flagship track pants',1,4,5,1.400,'NEGOCIO',NULL,89,73.52,1323.39,NULL,'black','M',NULL),(121,72,'immortal killer joggers',1,4,5,1.400,'NEGOCIO',NULL,92,73.52,1323.39,NULL,'black','M',NULL),(122,72,'foundation cropped tee',1,4,1,0.500,'PERSONAL',6,NULL,26.26,472.64,NULL,'black','S',NULL),(123,72,'foundation cropped tee',1,4,1,0.500,'PERSONAL',5,NULL,36.00,NULL,NULL,'black','S',NULL),(124,72,'supervillain',1,4,1,0.500,'NEGOCIO',NULL,93,26.26,472.64,NULL,'black','M',NULL),(125,72,'flagship track pants',1,4,5,1.400,'NEGOCIO',NULL,90,50.00,NULL,NULL,'burgundy','M',NULL),(126,71,'warrior',1,4,1,0.500,'PERSONAL',4,NULL,45.13,812.36,NULL,'red','L',NULL),(127,71,'warrior',1,4,1,0.500,'NEGOCIO',NULL,98,45.13,812.36,NULL,'red','M',NULL),(128,71,'batman',1,5,1,0.500,'NEGOCIO',NULL,59,45.13,812.36,NULL,'black','M',NULL),(129,71,'batman',1,5,1,0.500,'NEGOCIO',NULL,60,48.00,NULL,NULL,'black','S',NULL),(130,61,'onyx hoodie',1,2,6,0.493,'NEGOCIO',NULL,88,69.33,1247.97,NULL,'red','M',NULL),(131,61,'onyx hoodie',1,2,6,0.493,'NEGOCIO',NULL,87,57.60,NULL,NULL,'light grey','S',NULL),(132,61,'onyx hoodie',1,2,6,0.493,'NEGOCIO',NULL,86,57.60,NULL,NULL,'purple','M',NULL),(133,70,'demon slayer rengoku tee',1,5,1,0.500,'NEGOCIO',NULL,64,45.35,816.26,NULL,'Rengoku Design','M',NULL),(134,70,'quarter zipup',1,4,6,0.700,'PERSONAL',4,NULL,63.49,1142.76,NULL,NULL,'NA',NULL),(135,73,'demon slayer sweats',1,5,5,1.400,'PERSONAL',4,NULL,108.20,1947.67,NULL,NULL,'L',NULL),(136,73,'tanjiro zipup',1,4,6,0.700,'PERSONAL',4,NULL,54.10,973.83,NULL,NULL,'NA',NULL),(137,73,'rengoku zipup',1,4,6,0.700,'PERSONAL',4,NULL,54.10,973.83,NULL,NULL,'NA',NULL),(138,66,'Mothra City Chaos \"Side By Side\" Everyday Basic Tee',1,5,1,0.500,'PERSONAL',6,NULL,130.31,2345.52,NULL,'black','S',NULL),(139,75,'W2230 camo cargo joggers',1,4,5,1.400,'NEGOCIO',NULL,95,57.23,1030.06,NULL,'pink barbed wire camo','S',NULL),(140,75,'W472 legacy seamless tank',1,4,9,1.000,'NEGOCIO',NULL,97,40.88,735.76,NULL,'dusty blue','XS',NULL),(141,75,'W149 curve hourglass biker shorts 6.5\"',1,4,8,0.700,'NEGOCIO',NULL,94,28.61,515.03,NULL,'grey','S',NULL),(142,75,'W233 curve seamless leggings',1,4,11,1.000,'NEGOCIO',NULL,96,40.88,735.76,NULL,'green','M',NULL),(143,75,'4255 Batman Midnight Tee',1,5,1,0.500,'NEGOCIO',NULL,58,20.44,367.88,NULL,'Joker Purple','M',NULL),(144,74,'batman tee',1,5,1,0.500,'NEGOCIO',NULL,62,37.93,682.72,NULL,'white','M',NULL),(145,74,'batman zipup',1,5,6,0.700,'NEGOCIO',NULL,63,53.10,955.81,NULL,'Black Wash','M',NULL),(146,74,'batman sweats',1,5,5,1.400,'NEGOCIO',NULL,61,106.20,1911.63,NULL,'Black Wash','M',NULL),(147,63,'AOT tee',1,4,1,0.500,'PERSONAL',4,NULL,28.67,516.10,NULL,'white','L',NULL),(148,63,'AOT joggers',1,4,5,1.421,'PERSONAL',4,NULL,81.47,1466.55,NULL,'red','L',NULL),(149,63,'batman sweats',1,5,5,1.400,'PERSONAL',4,NULL,80.28,1445.08,NULL,'Black Wash','M',NULL),(150,64,'N\'s Zekrom 31 Promo - PokÃ©mon Center Stamp',1,4,12,0.020,'PERSONAL',4,NULL,136.58,2458.45,NULL,NULL,'NA',NULL),(151,59,'Gymshark x CBUM Washed Hoodie - Bros',1,2,6,1.254,'NEGOCIO',NULL,74,93.84,1689.15,NULL,'stone grey marl','M',NULL),(152,59,'Gymshark x CBUM Hockey Jersey',1,2,1,0.462,'NEGOCIO',NULL,72,34.54,621.64,NULL,'black','M',NULL),(153,59,'Gymshark x CBUM Straight Leg Jogger',1,2,5,1.400,'NEGOCIO',NULL,73,104.77,1885.81,NULL,'black','M',NULL),(154,68,'Omega Breath Pants',1,16,5,1.400,'PERSONAL',6,NULL,147.68,2658.24,NULL,NULL,'XS',NULL),(155,68,'Breath Divinity Compression Shirt FIH',1,16,1,0.500,'PERSONAL',4,NULL,52.74,949.37,NULL,'Black','L',NULL),(156,68,'Breath Divinity Compression Shirt FIH',1,16,1,0.500,'PERSONAL',6,NULL,68.00,NULL,NULL,'Black','M',NULL),(157,65,'Meta Oculus Quest 3 128GB with controllers',1,4,12,1.000,'PERSONAL',4,NULL,349.66,6293.89,NULL,NULL,'NA',NULL),(158,60,'Gymshark Campus 7\" Shorts',1,2,8,0.700,'PERSONAL',6,NULL,28.28,509.04,NULL,'light grey','XS',NULL),(159,60,'Gymshark x Carlos Belcast Track Jacket',1,2,7,1.200,'PERSONAL',6,NULL,48.48,872.64,NULL,'grey','XS',NULL),(160,60,'Gymshark Vital 1/4 Zip',1,2,4,1.000,'NEGOCIO',NULL,69,40.40,727.20,NULL,'black/silhouette grey','L',NULL),(161,60,'Gymshark Campus Mesh Shorts',1,2,8,0.700,'PERSONAL',6,NULL,28.28,509.04,NULL,'black/conditioning red','S',NULL),(162,67,'Ghidorah City Chaos \"Side By Side\" Everyday Distressed Tee',1,5,1,0.500,'PERSONAL',6,NULL,66.92,1204.57,NULL,'black','S',NULL),(163,62,'Gymshark Power Straight Leg Pants',1,2,5,1.400,'PERSONAL',4,NULL,59.83,1076.91,NULL,'GS black/GS asphalt grey','L',NULL),(164,62,'Gymshark Crest Oversized Joggers',1,2,5,1.400,'PERSONAL',4,NULL,59.83,1076.91,NULL,'GS black','L',NULL),(165,62,'Gymshark Power Oversized Hoodie',1,2,6,0.700,'PERSONAL',4,NULL,29.91,538.45,NULL,'black/conditioning red','M',NULL),(166,62,'Gymshark x Carlos Belcast Track Pant',1,2,5,1.400,'PERSONAL',5,NULL,59.83,1076.91,NULL,'GS black','M',NULL),(167,62,'Gymshark Pumper Pants',1,2,5,1.400,'PERSONAL',5,NULL,59.83,1076.91,NULL,'black/grey','M',NULL),(168,69,'Executioner Banana Shape Uncuffed Sweatpants',1,4,5,1.400,'PERSONAL',6,NULL,115.85,2085.35,NULL,'darkness','XS',NULL),(169,58,'5197 Demon Slayer Kimetsu no Yaiba Quarter Zip',1,5,6,0.700,'PERSONAL',6,NULL,23.51,423.22,NULL,'warding masks','S',NULL),(170,58,'2064 Sideline Joggers',1,4,5,1.400,'PERSONAL',5,NULL,47.02,846.43,NULL,'black','M',NULL),(171,58,'2069 Elevated Essentials Baggy Joggers',1,4,5,1.400,'PERSONAL',6,NULL,47.02,846.43,NULL,'black wash','S',NULL),(172,56,'Godzilla Hell Forever Hoodie',1,5,6,0.700,'PERSONAL',5,NULL,0.00,0.00,NULL,'black','S',NULL),(173,56,'Godzilla Hell Lounger Sweat Pants',1,5,5,1.400,'PERSONAL',6,NULL,0.00,0.00,NULL,'black','S',NULL),(174,55,'Monsters In Time Lex Double Layer Hoodie',1,5,6,0.700,'PERSONAL',4,NULL,0.00,0.00,NULL,'black/black','M',NULL),(175,55,'Monsters In Time Eternal Wide Leg Pants',1,5,5,1.400,'PERSONAL',4,NULL,0.00,0.00,NULL,'black','L',NULL),(176,52,'Gymshark Vital Seamless 2.0 Leggings',1,2,11,1.000,'NEGOCIO',NULL,70,38.27,688.85,NULL,'cobalt purple marl','S',NULL),(177,52,'Gymshark Minimal Sports Bra',1,2,10,0.400,'NEGOCIO',NULL,68,15.31,275.54,NULL,'black','S',NULL),(178,52,'Gymshark Adapt Animal Seamless Sports Bra',1,2,10,0.400,'NEGOCIO',NULL,65,15.31,275.54,NULL,'cherry purple/reset pink','M',NULL),(179,52,'Gymshark Flex High Waisted Leggings',1,2,11,1.000,'NEGOCIO',NULL,67,38.27,688.85,NULL,'black','S',NULL),(180,52,'Gymshark Everyday Seamless Shorts 2.0',1,2,8,0.700,'NEGOCIO',NULL,66,26.79,482.19,NULL,'GS black','M',NULL),(181,52,'Gymshark Vital Sports Bra',1,2,10,0.400,'NEGOCIO',NULL,71,15.31,275.54,NULL,'cobalt purple marl','S',NULL),(182,57,'Civil Racing Biker Jacket',1,6,7,1.200,'PERSONAL',4,NULL,0.00,0.00,NULL,'red','M',NULL),(183,57,'Civil Racing Biker Jacket',1,6,7,1.200,'PERSONAL',6,NULL,127.50,NULL,NULL,'red','S',NULL),(184,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,82,43.84,789.10,NULL,'Black/Light Grey','S',NULL),(185,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,83,45.00,NULL,NULL,'Black/Light Grey','M',NULL),(186,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,84,45.00,NULL,NULL,'Black/Light Grey','L',NULL),(187,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,85,45.00,NULL,NULL,'Black/Carmine Red','S',NULL),(188,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,81,45.00,NULL,NULL,'Black/Carmine Red','M',NULL),(189,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,80,45.00,NULL,NULL,'Black/Carmine Red','L',NULL),(190,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,79,45.00,NULL,NULL,'Black/Onyx Grey','S',NULL),(191,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,78,45.00,NULL,NULL,'Black/Onyx Grey','M',NULL),(192,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'NEGOCIO',NULL,77,45.00,NULL,NULL,'Black/Onyx Grey','L',NULL),(193,51,'Onyx 5.0 Seamless T-Shirt',1,2,1,0.516,'PERSONAL',4,NULL,43.84,789.10,NULL,'OG blue','M',NULL),(194,54,'Onyx 5.0 Seamless Long Sleeve T-Shirt',1,2,1,0.522,'NEGOCIO',NULL,76,54.56,982.08,NULL,'purple','S',NULL),(195,54,'Onyx 5.0 Seamless Long Sleeve T-Shirt',1,2,1,0.522,'NEGOCIO',NULL,75,50.40,NULL,NULL,'OG blue','XS',NULL),(196,53,'Gymshark Power T-Shirt',1,2,1,0.500,'PERSONAL',4,NULL,31.22,562.04,NULL,'black/conditioning red','M',NULL),(197,53,'Gymshark Kettlebell Charm',1,2,12,0.020,'PERSONAL',4,NULL,1.25,22.48,NULL,'conditioning red','one size',NULL),(198,53,'Gymshark Kettlebell Charm',1,2,12,0.020,'PERSONAL',6,NULL,8.40,NULL,NULL,'conditioning red','one size',NULL),(199,53,'Gymshark Kettlebell Charm',1,2,12,0.020,'PERSONAL',5,NULL,8.40,NULL,NULL,'conditioning red','one size',NULL),(200,53,'Gymshark Charge T-Shirt',1,2,1,0.500,'PERSONAL',6,NULL,31.22,562.04,NULL,'black/wash','XS',NULL),(201,53,'Gymshark Charge T-Shirt',1,2,1,0.500,'PERSONAL',5,NULL,21.60,NULL,NULL,'black/wash','M',NULL);
/*!40000 ALTER TABLE `pieza` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prestamo`
--

DROP TABLE IF EXISTS `prestamo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prestamo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `socio_acreedor_id` smallint NOT NULL,
  `socio_deudor_id` smallint NOT NULL,
  `monto_mxn` decimal(10,2) NOT NULL,
  `motivo` varchar(200) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `pagado` tinyint(1) DEFAULT '0',
  `fecha_pago` date DEFAULT NULL,
  `notas` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `socio_acreedor_id` (`socio_acreedor_id`),
  KEY `socio_deudor_id` (`socio_deudor_id`),
  CONSTRAINT `prestamo_ibfk_1` FOREIGN KEY (`socio_acreedor_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `prestamo_ibfk_2` FOREIGN KEY (`socio_deudor_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `prestamo_chk_1` CHECK ((`socio_acreedor_id` <> `socio_deudor_id`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prestamo`
--

LOCK TABLES `prestamo` WRITE;
/*!40000 ALTER TABLE `prestamo` DISABLE KEYS */;
INSERT INTO `prestamo` VALUES (2,'2026-07-30',4,5,1528.17,'Pago Envios',NULL,0,NULL,NULL,'2026-07-30 04:07:45'),(3,'2026-07-30',6,5,3747.31,'noc pero eso decia',NULL,0,NULL,NULL,'2026-07-30 04:08:26');
/*!40000 ALTER TABLE `prestamo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `marca_id` smallint NOT NULL,
  `tipo_prenda_id` smallint NOT NULL,
  `nombre` varchar(160) NOT NULL,
  `codigo_proveedor` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_producto` (`marca_id`,`nombre`),
  KEY `fk_producto_tipo` (`tipo_prenda_id`),
  CONSTRAINT `fk_producto_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_producto_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (6,1,1,'SuperVillain Compression Tees','204.0'),(7,1,1,'Warrior X Compression Tees','8079.0'),(8,1,1,'Batman Compression Tees','4286.0'),(9,1,5,'Flagship Track Pants','233.0'),(10,1,2,'Foundation Cropped Tees','5094.0'),(11,1,5,'Immortal Killer Joggers','2064.0'),(12,2,1,'ONYX V5 SHORTSLEEVE',NULL),(13,2,1,'ONYX V5 LONGSLEEVE',NULL),(14,1,2,'Demon Slayer: Kimetsu no Yaiba - Anime Tees','5197.0'),(15,2,1,'ONYX HOODIE',NULL),(16,1,6,'Campus Hoodie',NULL),(17,1,3,'Batman Midnight Tees','4255.0'),(18,1,8,'Curve Hourglass Biker Shorts 6.5\"','W149'),(19,1,9,'Legacy Seamless Tank','W472'),(20,2,8,'Gymshark Light Hold Shorts',NULL),(21,2,10,'Gymshark adapt animal Seamless Sport bra',NULL),(22,2,11,'Gymshark vital seamless 2.0 Leggings',NULL),(23,2,10,'Gymshark vital sports bra',NULL),(24,2,10,'Gymshark Minimal sports bra',NULL),(25,2,11,'Gymshark Flex High Waisted Leggings',NULL),(26,1,5,'Batman Armored Sweats',NULL),(27,1,7,'Batman Armored Zip-Up',NULL),(28,2,5,'CBUM Straight Leg Jogger',NULL),(29,2,4,'CBUM Hockey Jersey',NULL),(30,2,6,'CBUM Washed Hoodie',NULL),(31,2,4,'Vital 1/4 Zip',NULL),(32,2,6,'Campus Hoodie',NULL),(33,2,2,'Power T-Shirt',NULL),(43,5,1,'4255 Batman Midnight Tee',NULL),(44,5,1,'Batman Compression Shirt',NULL),(45,5,5,'Batman Joggers',NULL),(46,5,1,'Batman Tee',NULL),(47,5,6,'Batman Zip-Up Hoodie',NULL),(48,5,1,'Demon Slayer Rengoku Tee',NULL),(49,2,10,'Gymshark Adapt Animal Seamless Sports Bra',NULL),(50,2,8,'Gymshark Everyday Seamless Shorts 2.0',NULL),(51,2,1,'Onyx 5.0 Seamless Long Sleeve T-Shirt',NULL),(52,2,1,'Onyx 5.0 Seamless T-Shirt',NULL),(53,1,1,'Foundation Cropped Tee',NULL),(54,1,1,'Supervillain Tee',NULL),(55,1,8,'W149 curve hourglass biker shorts 6.5\"',NULL),(56,1,5,'W2230 camo cargo joggers',NULL),(57,1,11,'W233 curve seamless leggings',NULL),(58,1,9,'W472 legacy seamless tank',NULL),(59,1,1,'Warrior Tee',NULL);
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor`
--

DROP TABLE IF EXISTS `proveedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proveedor` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `marca_id` smallint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `fk_proveedor_marca` (`marca_id`),
  CONSTRAINT `fk_proveedor_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor`
--

LOCK TABLES `proveedor` WRITE;
/*!40000 ALTER TABLE `proveedor` DISABLE KEYS */;
INSERT INTO `proveedor` VALUES (1,'YoungLA',1),(2,'Gymshark',2),(3,'Cock Bear',4),(4,'Meta',4),(5,'Pokemon Center',4),(6,'Executioner',4),(8,'YoungLA / ONYX',NULL),(9,'Cock Bear (Mothra)',NULL),(13,'Cock Bear (Ghidorah)',NULL),(15,'Fitbos',NULL);
/*!40000 ALTER TABLE `proveedor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol_venta`
--

DROP TABLE IF EXISTS `rol_venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol_venta` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(40) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_venta`
--

LOCK TABLES `rol_venta` WRITE;
/*!40000 ALTER TABLE `rol_venta` DISABLE KEYS */;
INSERT INTO `rol_venta` VALUES (2,'ENTREGA'),(1,'NEGOCIADOR');
/*!40000 ALTER TABLE `rol_venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku`
--

DROP TABLE IF EXISTS `sku`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(30) NOT NULL,
  `producto_id` int NOT NULL,
  `talla` varchar(30) NOT NULL,
  `color` varchar(60) NOT NULL,
  `codigo_proveedor` varchar(100) DEFAULT NULL,
  `ubicacion_id` smallint DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'ACTIVO',
  `precio_lista_mxn` decimal(12,2) DEFAULT NULL,
  `estado_comercial` varchar(50) DEFAULT NULL,
  `notas` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`),
  UNIQUE KEY `uq_sku_variante` (`producto_id`,`talla`,`color`),
  KEY `fk_sku_ubicacion` (`ubicacion_id`),
  CONSTRAINT `fk_sku_producto` FOREIGN KEY (`producto_id`) REFERENCES `producto` (`id`),
  CONSTRAINT `fk_sku_ubicacion` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicacion` (`id`),
  CONSTRAINT `ck_sku_estado` CHECK ((`estado` in (_utf8mb4'ACTIVO',_utf8mb4'DESCONTINUADO',_utf8mb4'BORRADOR')))
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku`
--

LOCK TABLES `sku` WRITE;
/*!40000 ALTER TABLE `sku` DISABLE KEYS */;
INSERT INTO `sku` VALUES (7,'JNG-0001',6,'Medium','Black','204.0',1,'ACTIVO',1000.00,'Disponible',NULL),(8,'JNG-0002',7,'Medium','Red','8079.0',1,'ACTIVO',1100.00,'Disponible',NULL),(9,'JNG-0003',8,'Small','Black','4286.0',1,'ACTIVO',1250.00,'Sin stock',NULL),(10,'JNG-0004',8,'Medium','Black','4286.0',1,'ACTIVO',1250.00,'Sin stock',NULL),(11,'JNG-0033',8,'Medium','White',NULL,1,'ACTIVO',1100.00,'Disponible',NULL),(12,'JNG-0005',9,'Medium','Black','233.0',1,'ACTIVO',1450.00,'Disponible',NULL),(13,'JNG-0006',9,'Medium','Red','233.0',1,'ACTIVO',1450.00,'Disponible',NULL),(14,'JNG-0007',10,'Medium','Black Wash','5094.0',1,'ACTIVO',950.00,'Sin stock',NULL),(15,'JNG-0008',11,'Medium','Black','2064.0',1,'ACTIVO',1450.00,'Disponible',NULL),(16,'JNG-0009',12,'Small','Red Carmine ',NULL,1,'ACTIVO',1500.00,'Sin stock',NULL),(17,'JNG-0010',12,'Medium','Red Carmine',NULL,1,'ACTIVO',1500.00,'Sin stock',NULL),(18,'JNG-0011',12,'Large','Red Carmine ',NULL,2,'ACTIVO',1500.00,'Disponible',NULL),(19,'JNG-0012',12,'Small ','Light Grey',NULL,2,'ACTIVO',1500.00,'Sin stock',NULL),(20,'JNG-0013',12,'Medium','Light Grey ',NULL,2,'ACTIVO',1500.00,'Disponible',NULL),(21,'JNG-0014',12,'Large','Light Grey ',NULL,1,'ACTIVO',1500.00,'Disponible',NULL),(22,'JNG-0015',12,'Small','OG Blue ',NULL,1,'ACTIVO',1500.00,'Sin stock',NULL),(23,'JNG-0016',12,'Large','OG Blue ',NULL,1,'ACTIVO',1500.00,'Disponible',NULL),(24,'JNG-0017',13,'Small','Athletic purple',NULL,2,'ACTIVO',1700.00,'Disponible',NULL),(25,'JNG-0018',13,'Extra Small','OG Blue',NULL,1,'ACTIVO',1700.00,'Disponible',NULL),(26,'JNG-0019',14,'Medium','Rengoku :v 🍩','5197.0',1,'ACTIVO',1150.00,'Sin stock',NULL),(27,'JNG-0020',15,'Medium','Purple',NULL,1,'ACTIVO',2300.00,'Sin stock',NULL),(28,'JNG-0021',15,'Medium','Red',NULL,1,'ACTIVO',2100.00,'Sin stock',NULL),(29,'JNG-0022',15,'Small','Grey',NULL,2,'ACTIVO',2200.00,'Disponible',NULL),(30,'JNG-0023',16,'Small','Grey',NULL,2,'ACTIVO',800.00,'Disponible',NULL),(31,'JNG-0024',17,'Medium','Joker P','4255.0',1,'ACTIVO',850.00,'Sin stock',NULL),(32,'JNG-0025',18,'Small','Grey','W149',1,'ACTIVO',600.00,'Disponible',NULL),(33,'JNG-0026',19,'XSmall','Dusty blue','W472',1,'ACTIVO',400.00,'Disponible',NULL),(34,'JNG-0027',20,'Medium','GS Black',NULL,1,'ACTIVO',450.00,'Sin stock',NULL),(35,'JNG-0028',21,'Medium','Cherry purple',NULL,1,'ACTIVO',650.00,'Sin stock',NULL),(36,'JNG-0029',22,'Small','Cobalt purple',NULL,1,'ACTIVO',650.00,'Sin stock',NULL),(37,'JNG-0030',23,'Small','Cobalt purple',NULL,1,'ACTIVO',350.00,'Sin stock',NULL),(38,'JNG-0031',24,'Small','White',NULL,1,'ACTIVO',400.00,'Sin stock',NULL),(39,'JNG-0032',25,'Small','Black',NULL,1,'ACTIVO',600.00,'Sin stock',NULL),(40,'JNG-0034',26,'Medium','Black Wash',NULL,1,'ACTIVO',1650.00,'Disponible',NULL),(41,'JNG-0035',27,'Medium','Black Wash',NULL,1,'ACTIVO',1650.00,'Disponible',NULL),(42,'JNG-0036',28,'Medium','Black',NULL,1,'ACTIVO',1650.00,'Disponible',NULL),(43,'JNG-0037',29,'Medium','Black',NULL,2,'ACTIVO',1350.00,'Disponible',NULL),(44,'JNG-0038',30,'Medium','Grey',NULL,2,'ACTIVO',1800.00,'Disponible',NULL),(45,'JNG-0039',31,'Large','Black',NULL,2,'ACTIVO',950.00,'Disponible',NULL),(48,'JNG-0040',32,'Medium','Grey',NULL,2,'ACTIVO',650.00,'Disponible',NULL),(58,'JNG-0041',43,'M','Joker Purple',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(59,'JNG-0042',44,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(60,'JNG-0043',44,'S','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(61,'JNG-0044',45,'M','Black Wash',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(62,'JNG-0045',46,'M','white',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(63,'JNG-0046',47,'M','Black Wash',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(64,'JNG-0047',48,'M','Rengoku Design',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(65,'JNG-0048',49,'M','cherry purple/reset pink',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(66,'JNG-0049',50,'M','GS black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(67,'JNG-0050',25,'S','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(68,'JNG-0051',24,'S','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(69,'JNG-0052',31,'L','black/silhouette grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(70,'JNG-0053',22,'S','cobalt purple marl',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(71,'JNG-0054',23,'S','cobalt purple marl',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(72,'JNG-0055',29,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(73,'JNG-0056',28,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(74,'JNG-0057',30,'M','stone grey marl',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(75,'JNG-0058',51,'XS','OG blue',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(76,'JNG-0059',51,'S','purple',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(77,'JNG-0060',52,'L','Black/Onyx Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(78,'JNG-0061',52,'M','Black/Onyx Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(79,'JNG-0062',52,'S','Black/Onyx Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(80,'JNG-0063',52,'L','Black/Carmine Red',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(81,'JNG-0064',52,'M','Black/Carmine Red',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(82,'JNG-0065',52,'S','Black/Light Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(83,'JNG-0066',52,'M','Black/Light Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(84,'JNG-0067',52,'L','Black/Light Grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(85,'JNG-0068',52,'S','Black/Carmine Red',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(86,'JNG-0069',15,'M','purple',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(87,'JNG-0070',15,'S','light grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(88,'JNG-0071',15,'M','red',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(89,'JNG-0072',9,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(90,'JNG-0073',9,'M','burgundy',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(91,'JNG-0074',53,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(92,'JNG-0075',11,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(93,'JNG-0076',54,'M','black',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(94,'JNG-0077',55,'S','grey',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(95,'JNG-0078',56,'S','pink barbed wire camo',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(96,'JNG-0079',57,'M','green',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(97,'JNG-0080',58,'XS','dusty blue',NULL,NULL,'ACTIVO',NULL,NULL,NULL),(98,'JNG-0081',59,'M','red',NULL,NULL,'ACTIVO',NULL,NULL,NULL);
/*!40000 ALTER TABLE `sku` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sku_costo`
--

DROP TABLE IF EXISTS `sku_costo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sku_costo` (
  `sku_id` int NOT NULL,
  `costo_producto_usd` decimal(10,2) DEFAULT NULL,
  `costo_envio_usd` decimal(10,2) DEFAULT NULL,
  `costo_total_usd` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`sku_id`),
  CONSTRAINT `sku_costo_ibfk_1` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku_costo`
--

LOCK TABLES `sku_costo` WRITE;
/*!40000 ALTER TABLE `sku_costo` DISABLE KEYS */;
INSERT INTO `sku_costo` VALUES (7,625.41,50.23,675.64),(8,696.36,91.67,788.03),(9,787.77,91.67,879.43),(10,787.77,91.67,879.43),(11,788.61,50.00,838.61),(12,808.22,90.41,898.63),(13,808.22,90.41,898.63),(14,594.95,45.21,640.15),(15,808.22,90.41,898.63),(16,867.26,50.00,917.26),(17,867.26,50.00,917.26),(18,867.26,50.00,917.26),(19,867.26,50.00,917.26),(20,867.26,50.00,917.26),(21,867.26,50.00,917.26),(22,867.26,50.00,917.26),(23,867.26,50.00,917.26),(24,1100.41,50.00,1150.41),(25,1100.41,50.00,1150.41),(26,676.00,116.67,792.66),(27,1107.01,116.67,1223.68),(28,1107.01,116.67,1223.68),(29,1107.01,50.00,1157.01),(30,600.00,50.00,650.00),(31,305.54,128.33,433.87),(32,403.44,81.67,485.11),(33,289.71,70.00,359.71),(40,1186.25,90.00,1276.25),(41,1186.24,140.00,1326.24),(42,1185.33,120.00,1305.33),(43,947.96,80.00,1027.96),(44,1320.03,166.67,1486.70),(45,663.25,285.71,948.96);
/*!40000 ALTER TABLE `sku_costo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `socio`
--

DROP TABLE IF EXISTS `socio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `socio` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  `porcentaje_propiedad` decimal(5,2) DEFAULT '33.33',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socio`
--

LOCK TABLES `socio` WRITE;
/*!40000 ALTER TABLE `socio` DISABLE KEYS */;
INSERT INTO `socio` VALUES (4,'JJ',33.33,1),(5,'Agusto',33.33,1),(6,'Luise',33.33,1);
/*!40000 ALTER TABLE `socio` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_costos_consolidados`
--

DROP TABLE IF EXISTS `temp_costos_consolidados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_costos_consolidados` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cruce` varchar(50) DEFAULT NULL,
  `guia` varchar(100) DEFAULT NULL,
  `descripcion` text,
  `precio_base_usd` decimal(10,2) DEFAULT NULL,
  `shipping_protection_usd` decimal(10,2) DEFAULT NULL,
  `taxes_usd` decimal(10,2) DEFAULT NULL,
  `costo_total_usd` decimal(10,2) DEFAULT NULL,
  `es_personal` tinyint(1) DEFAULT NULL,
  `aplicado` tinyint(1) DEFAULT '0',
  `notas` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_costos_consolidados`
--

LOCK TABLES `temp_costos_consolidados` WRITE;
/*!40000 ALTER TABLE `temp_costos_consolidados` DISABLE KEYS */;
INSERT INTO `temp_costos_consolidados` VALUES (1,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005071033','foundation cropped tee black Medium',36.00,1.17,3.46,40.63,0,0,NULL),(2,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005071033','flagship track pants black medium',50.00,1.17,3.46,54.63,0,0,NULL),(3,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005071033','immortal killer joggers black medium',50.00,1.17,3.46,54.63,0,0,NULL),(4,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005071033','supervillain black medium',38.00,1.17,3.46,42.63,0,0,NULL),(5,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005071033','flagship track pants burgundy medium',50.00,1.17,3.46,54.63,0,0,NULL),(7,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005034571','warrior red large (personal)',42.00,0.00,3.15,45.16,1,0,NULL),(8,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005034571','warrior red medium',42.00,0.00,3.15,45.16,0,0,NULL),(9,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005034571','batman black medium',48.00,0.00,3.15,51.16,0,0,NULL),(10,'CONS9928546710 Marzo 25, 2026','CASI420785219434640109629005034571','batman black small',48.00,0.00,3.15,51.16,0,0,NULL),(11,'CONS9943741515','CASI1','onyx hoodie red M',57.60,0.00,4.75,62.35,0,0,NULL),(12,'CONS9943741515','CASI1','onyx hoodie light grey S',57.60,0.00,4.75,62.35,0,0,NULL),(13,'CONS9943741515','CASI1','ONYX HOODIE PURPLE M',57.60,0.00,4.75,62.35,0,0,NULL),(14,'CONS9943741515','CASI420785219400140109629002153594','demon slayer rengoku tee',42.00,1.50,3.40,46.90,0,0,NULL),(15,'CONS9943741515','CASI420785219400140109629002153594','quarter zipup personal jj',55.00,1.50,3.40,59.90,1,0,NULL),(16,'CONS9943741515','CASI420785219434640109629005267580','demon slayer sweats lasrge',62.00,0.00,4.49,66.49,0,0,NULL),(17,'CONS9943741515','CASI420785219434640109629005267580','tanjiro zipup',65.00,0.00,4.49,69.49,0,0,NULL),(18,'CONS9943741515','CASI420785219434640109629005267580','rengoku zipup',65.00,0.00,4.49,69.49,0,0,NULL),(19,'CONS9943741515','CASI420785219434640109629005663979','BATMAN WHITE M',48.00,0.00,4.40,52.40,0,0,NULL),(20,'CONS9943741515','CASI420785219434640109629005663979','BATMAN ZIPUP M',76.00,0.00,4.40,80.40,0,0,NULL),(21,'CONS9943741515','CASI420785219434640109629005663979','BATMAN SWEATS M',76.00,0.00,4.40,80.40,0,0,NULL),(22,'CONS9943741515','CASI1','AOT WHITE TEE L',42.00,0.00,2.46,44.46,0,0,NULL),(23,'CONS9943741515','CASI1','AOT JOGGERS L RED',68.00,0.00,2.46,70.46,0,0,NULL),(24,'CONS9943741515','CASI1','BATMAN SWEATS M',76.00,0.00,2.46,78.46,0,0,NULL),(27,'CONS9943741515','CASI420785219205590267338805428145','OMEGA BREATH PANTS LUISCRUS XS',90.00,0.00,6.32,96.32,0,0,NULL),(28,'CONS9943741515','CASI420785219205590267338805428145','FIH L',68.00,0.00,6.32,74.32,0,0,NULL),(29,'CONS9943741515','CASI420785219205590267338805428145','FIH M',68.00,0.00,6.32,74.32,0,0,NULL);
/*!40000 ALTER TABLE `temp_costos_consolidados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_items_parseados`
--

DROP TABLE IF EXISTS `temp_items_parseados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temp_items_parseados` (
  `id` int NOT NULL AUTO_INCREMENT,
  `cruce_folio` varchar(40) NOT NULL,
  `cruce_fecha` date DEFAULT NULL,
  `guia` varchar(100) NOT NULL,
  `item_descripcion` varchar(300) NOT NULL,
  `item_color` varchar(60) DEFAULT NULL,
  `item_size` varchar(30) DEFAULT NULL,
  `item_qty` int NOT NULL DEFAULT '1',
  `item_personal` tinyint(1) NOT NULL DEFAULT '0',
  `item_owner` varchar(60) DEFAULT NULL,
  `item_precio_unitario` decimal(12,2) NOT NULL,
  `guia_shipping_protection` decimal(12,2) DEFAULT '0.00',
  `guia_shipping` decimal(12,2) DEFAULT '0.00',
  `guia_discount` decimal(12,2) DEFAULT '0.00',
  `guia_taxes` decimal(12,2) DEFAULT '0.00',
  `guia_adjustment` decimal(12,2) DEFAULT '0.00',
  `guia_total` decimal(12,2) DEFAULT '0.00',
  `guia_fecha_recibido` date DEFAULT NULL,
  `guia_status` varchar(30) DEFAULT NULL,
  `guia_nota` text,
  PRIMARY KEY (`id`),
  KEY `idx_cruce` (`cruce_folio`),
  KEY `idx_guia` (`guia`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_items_parseados`
--

LOCK TABLES `temp_items_parseados` WRITE;
/*!40000 ALTER TABLE `temp_items_parseados` DISABLE KEYS */;
INSERT INTO `temp_items_parseados` VALUES (1,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','foundation cropped tee','black','M',1,0,'',36.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(2,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','flagship track pants','black','M',1,0,'',50.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(3,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','immortal killer joggers','black','M',1,0,'',50.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(4,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','foundation cropped tee','black','S',2,0,'',36.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(5,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','supervillain','black','M',1,0,'',38.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(6,'CONS9928546710','2026-03-25','CASI420785219434640109629005071033','flagship track pants','burgundy','M',1,0,'',50.00,7.01,0.00,45.63,20.77,1.24,279.39,'2026-03-24','received','adjustment 1.24 usd inferred because listed items and charges total 278.15 usd, while source total is 279.39 usd'),(7,'CONS9928546710','2026-03-25','CASI420785219434640109629005034571','warrior','red','L',1,1,'unspecified',42.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(8,'CONS9928546710','2026-03-25','CASI420785219434640109629005034571','warrior','red','M',1,0,'',42.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(9,'CONS9928546710','2026-03-25','CASI420785219434640109629005034571','batman','black','M',1,0,'',48.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(10,'CONS9928546710','2026-03-25','CASI420785219434640109629005034571','batman','black','S',1,0,'',48.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(11,'CONS9943741515','2026-04-08','CASI1Z08X89A0320538281','onyx hoodie','red','M',1,0,'',57.60,0.00,0.00,19.20,14.25,19.15,187.00,'2026-04-06','received','adjustment 19.15 usd inferred; source omits a charge, likely shipping, needed to reconcile the total'),(12,'CONS9943741515','2026-04-08','CASI1Z08X89A0320538281','onyx hoodie','light grey','S',1,0,'',57.60,0.00,0.00,19.20,14.25,19.15,187.00,'2026-04-06','received','adjustment 19.15 usd inferred; source omits a charge, likely shipping, needed to reconcile the total'),(13,'CONS9943741515','2026-04-08','CASI1Z08X89A0320538281','onyx hoodie','purple','M',1,0,'',57.60,0.00,0.00,19.20,14.25,19.15,187.00,'2026-04-06','received','adjustment 19.15 usd inferred; source omits a charge, likely shipping, needed to reconcile the total'),(14,'CONS9943741515','2026-04-08','CASI420785219400140109629002153594','demon slayer rengoku tee','','NA',1,0,'',42.00,3.00,0.00,15.00,6.80,0.00,91.80,'2026-03-31','received','quarter zipup was reportedly sent by FedEx 399969598390 but reflected under this guide'),(15,'CONS9943741515','2026-04-08','CASI420785219400140109629002153594','quarter zipup','','NA',1,1,'JJ',55.00,3.00,0.00,15.00,6.80,0.00,91.80,'2026-03-31','received','quarter zipup was reportedly sent by FedEx 399969598390 but reflected under this guide'),(16,'CONS9943741515','2026-04-08','CASI420785219434640109629005267580','demon slayer sweats','','L',1,1,'JJ',62.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(17,'CONS9943741515','2026-04-08','CASI420785219434640109629005267580','tanjiro zipup','','NA',1,1,'JJ',65.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(18,'CONS9943741515','2026-04-08','CASI420785219434640109629005267580','rengoku zipup','','NA',1,1,'JJ',65.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(19,'CONS9943741691','2026-04-16','CASI420785219200190244541414837086','Mothra City Chaos \"Side By Side\" Everyday Basic Tee','black','S',1,1,'Luis',48.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(20,'CONS9943741870','2026-04-27','CASI420785219434640109629006011632','W2230 camo cargo joggers','pink barbed wire camo','S',1,1,'client order',52.00,5.25,0.00,35.65,11.42,0.00,154.02,'2026-04-21','received','FedEx 380449171210 is mentioned for two items'),(21,'CONS9943741870','2026-04-27','CASI420785219434640109629006011632','W472 legacy seamless tank','dusty blue','XS',1,1,'client order',18.00,5.25,0.00,35.65,11.42,0.00,154.02,'2026-04-21','received','FedEx 380449171210 is mentioned for two items'),(22,'CONS9943741870','2026-04-27','CASI420785219434640109629006011632','W149 curve hourglass biker shorts 6.5\"','grey','S',1,1,'client order',26.00,5.25,0.00,35.65,11.42,0.00,154.02,'2026-04-21','received','FedEx 380449171210 is mentioned for two items'),(23,'CONS9943741870','2026-04-27','CASI420785219434640109629006011632','W233 curve seamless leggings','green','M',1,1,'client order',55.00,5.25,0.00,35.65,11.42,0.00,154.02,'2026-04-21','received','FedEx 380449171210 is mentioned for two items'),(24,'CONS9943741870','2026-04-27','CASI420785219434640109629006011632','4255 Batman Midnight Tee','Joker P','M',1,1,'client order',22.00,5.25,0.00,35.65,11.42,0.00,154.02,'2026-04-21','received','FedEx 380449171210 is mentioned for two items'),(25,'CONS9943741870','2026-04-27','CASI420785219434640109629005663979','batman tee','white','M',1,0,'',48.00,6.00,0.00,41.20,13.21,0.00,178.01,'2026-04-21','received',''),(26,'CONS9943741870','2026-04-27','CASI420785219434640109629005663979','batman zipup','','M',1,0,'',76.00,6.00,0.00,41.20,13.21,0.00,178.01,'2026-04-21','received',''),(27,'CONS9943741870','2026-04-27','CASI420785219434640109629005663979','batman sweats','','M',1,0,'',76.00,6.00,0.00,41.20,13.21,0.00,178.01,'2026-04-21','received',''),(28,'CONS9943741870','2026-04-27','CASI1ZC1R7210300545183','AOT tee','white','L',1,1,'JJ',42.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(29,'CONS9943741870','2026-04-27','CASI1ZC1R7210300545183','AOT joggers','red','L',1,1,'JJ',68.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(30,'CONS9943741870','2026-04-27','CASI1ZC1R7210300545183','batman sweats','','M',1,1,'JJ',76.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(31,'CONS9943742286','2026-05-21','CASI4207852170149400108106244117836182','N\'s Zekrom 31 Promo - Ascended Heroes ETB - Pokemon Center Stamp','','NA',1,0,'',120.00,0.00,5.97,0.00,10.39,0.00,136.36,'2026-05-20','received',''),(32,'CONS9943742286','2026-05-21','CASI1Z08X89A0300826855','Gymshark x CBUM Washed Hoodie - Bros','stone grey marl','M',1,0,'',70.20,0.00,0.00,20.40,15.15,0.00,198.75,'2026-05-14','received','unit prices are net after per-item BELCAST10 discounts; discount is not repeated at order level'),(33,'CONS9943742286','2026-05-21','CASI1Z08X89A0300826855','Gymshark x CBUM Hockey Jersey','black','M',1,0,'',50.40,0.00,0.00,20.40,15.15,0.00,198.75,'2026-05-14','received','unit prices are net after per-item BELCAST10 discounts; discount is not repeated at order level'),(34,'CONS9943742286','2026-05-21','CASI1Z08X89A0300826855','Gymshark x CBUM Straight Leg Jogger','black','M',1,0,'',63.00,0.00,0.00,20.40,15.15,0.00,198.75,'2026-05-14','received','unit prices are net after per-item BELCAST10 discounts; discount is not repeated at order level'),(35,'CONS9943742286','2026-05-21','CASI420785219205590267338805428145','Omega Breath Pants','','XS',1,1,'Luis Cruz',90.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(36,'CONS9943742286','2026-05-21','CASI420785219205590267338805428145','FIH','','L',1,0,'',68.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(37,'CONS9943742286','2026-05-21','CASI420785219205590267338805428145','FIH','','M',1,0,'',68.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(38,'CONS9962926323','2026-07-08','CASI4207852170149434908106245318083125','Meta Oculus Quest 3 128GB with controllers','','NA',1,1,'JJ',305.00,0.00,9.99,0.00,25.99,0.00,340.98,'2026-07-03','received',''),(39,'CONS9962926323','2026-07-08','CASI1Z08X89A0301650873','Gymshark Campus 7\" Shorts','light grey','XS',1,0,'',12.60,0.00,0.00,11.72,8.71,0.00,114.19,'2026-06-26','received',''),(40,'CONS9962926323','2026-07-08','CASI1Z08X89A0301650873','Gymshark x Carlos Belcast Track Jacket','grey','XS',1,0,'',45.00,0.00,0.00,11.72,8.71,0.00,114.19,'2026-06-26','received',''),(41,'CONS9962926323','2026-07-08','CASI1Z08X89A0301650873','Gymshark Vital 1/4 Zip','black/silhouette grey','L',1,0,'',39.60,0.00,0.00,11.72,8.71,0.00,114.19,'2026-06-26','received',''),(42,'CONS9962926323','2026-07-08','CASI1Z08X89A0301650873','Gymshark Campus Mesh Shorts','black/conditioning red','S',1,0,'',20.00,0.00,0.00,11.72,8.71,0.00,114.19,'2026-06-26','received',''),(43,'CONS9962926323','2026-07-08','CASI420785219200190244541419304040','Ghidorah City Chaos \"Side By Side\" Everyday Distressed Tee','black','S',1,1,'Luis',60.00,0.00,9.95,12.00,4.63,0.00,62.58,'2026-06-26','received',''),(44,'CONS9962926323','2026-07-08','CASI1Z1F92320318576758','Gymshark Power Straight Leg Pants','GS black/GS asphalt grey','L',1,1,'JJ',37.44,0.00,0.00,19.82,16.36,0.00,214.54,'2026-06-24','received','source also shows discount 19.82 usd, but the displayed total already equals subtotal 198.18 plus tax 16.36; do not subtract it again'),(45,'CONS9962926323','2026-07-08','CASI1Z1F92320318576758','Gymshark Crest Oversized Joggers','GS black','L',1,1,'JJ',28.80,0.00,0.00,19.82,16.36,0.00,214.54,'2026-06-24','received','source also shows discount 19.82 usd, but the displayed total already equals subtotal 198.18 plus tax 16.36; do not subtract it again'),(46,'CONS9962926323','2026-07-08','CASI1Z1F92320318576758','Gymshark Power Oversized Hoodie','black/conditioning red','M',1,1,'JJ',39.06,0.00,0.00,19.82,16.36,0.00,214.54,'2026-06-24','received','source also shows discount 19.82 usd, but the displayed total already equals subtotal 198.18 plus tax 16.36; do not subtract it again'),(47,'CONS9962926323','2026-07-08','CASI1Z1F92320318576758','Gymshark x Carlos Belcast Track Pant','GS black','M',1,1,'Agusto',57.60,0.00,0.00,19.82,16.36,0.00,214.54,'2026-06-24','received','source also shows discount 19.82 usd, but the displayed total already equals subtotal 198.18 plus tax 16.36; do not subtract it again'),(48,'CONS9962926323','2026-07-08','CASI1Z1F92320318576758','Gymshark Pumper Pants','black/grey','M',1,1,'Agusto',35.28,0.00,0.00,19.82,16.36,0.00,214.54,'2026-06-24','received','source also shows discount 19.82 usd, but the displayed total already equals subtotal 198.18 plus tax 16.36; do not subtract it again'),(49,'CONS9962926323','2026-07-08','CASI420785219205590267338808841279','Executioner Banana Shape Uncuffed Sweatpants','darkness','XS',1,1,'Luis',90.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(50,'CONS_SIN_ASIGNAR_202607',NULL,'4207852170149334620826000001283829','5197 Demon Slayer Kimetsu no Yaiba Quarter Zip','warding masks','S',1,1,'Luis',24.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(51,'CONS_SIN_ASIGNAR_202607',NULL,'4207852170149334620826000001283829','2064 Sideline Joggers','black','M',1,1,'Luis',50.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(52,'CONS_SIN_ASIGNAR_202607',NULL,'4207852170149334620826000001283829','2069 Elevated Essentials Baggy Joggers','black wash','S',1,1,'Luis',58.00,0.00,0.00,0.00,0.00,0.00,0.00,NULL,'received',''),(53,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Vital Seamless 2.0 Leggings','cobalt purple marl','S',1,0,'',32.40,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(54,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Minimal Sports Bra','black','S',1,0,'',21.00,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(55,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Adapt Animal Seamless Sports Bra','cherry purple/reset pink','M',1,0,'',32.20,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(56,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Flex High Waisted Leggings','black','S',1,0,'',30.00,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(57,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Everyday Seamless Shorts 2.0','GS black','M',1,0,'',22.40,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(58,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Gymshark Vital Sports Bra','cobalt purple marl','S',1,0,'',15.20,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(59,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Civil Racing Biker Jacket','red','M',1,1,'Luis or Yves - verify',127.50,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(60,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW00349426','Civil Racing Biker Jacket','red','S',1,1,'Luis or Yves - verify',127.50,0.00,14.95,45.00,21.59,0.00,291.54,NULL,'received_outside_system','unit prices are net after two discounts of 22.50 usd; ownership by size is not identified'),(61,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89A0320535275','Onyx 5.0 Seamless T-Shirt','','UNKNOWN',9,0,'',45.00,0.00,0.00,40.50,33.39,0.00,438.39,NULL,'received_outside_system','source shows discount 40.50 usd, but displayed total already equals subtotal 405.00 plus tax 33.39; do not subtract it again'),(62,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08YY74YW30322345','Onyx 5.0 Seamless Long Sleeve T-Shirt','purple','S',1,0,'',50.40,0.00,0.00,10.08,8.32,0.00,109.12,NULL,'received_outside_system','source shows discount 10.08 usd, but displayed total already equals subtotal 100.80 plus tax 8.32; do not subtract it again'),(63,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08YY74YW30322345','Onyx 5.0 Seamless Long Sleeve T-Shirt','OG blue','XS',1,0,'',50.40,0.00,0.00,10.08,8.32,0.00,109.12,NULL,'received_outside_system','source shows discount 10.08 usd, but displayed total already equals subtotal 100.80 plus tax 8.32; do not subtract it again'),(64,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW01891981','Gymshark Power T-Shirt','black/conditioning red','M',1,0,'',28.80,0.00,0.00,3.60,7.42,0.00,97.42,NULL,'received_outside_system','source lists 33.60 usd next to the charm and discount 3.60 usd, but those figures do not reconcile with subtotal 90.00 and total 97.42'),(65,'CONS_FUERA_DE_SISTEMA',NULL,'1Z08X89AYW01891981','Gymshark Kettlebell Charm','conditioning red','one size',3,0,'',20.40,0.00,0.00,3.60,7.42,0.00,97.42,NULL,'received_outside_system','source lists 33.60 usd next to the charm and discount 3.60 usd, but those figures do not reconcile with subtotal 90.00 and total 97.42');
/*!40000 ALTER TABLE `temp_items_parseados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_cambio_historico`
--

DROP TABLE IF EXISTS `tipo_cambio_historico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_cambio_historico` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `usd_a_mxn` decimal(10,4) NOT NULL,
  `fuente` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Banxico',
  `notas` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fecha` (`fecha`),
  KEY `idx_fecha` (`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_cambio_historico`
--

LOCK TABLES `tipo_cambio_historico` WRITE;
/*!40000 ALTER TABLE `tipo_cambio_historico` DISABLE KEYS */;
INSERT INTO `tipo_cambio_historico` VALUES (1,'2026-03-23',17.1200,'Banxico','Marzo 2026 - Cruce CONS9928546710','2026-07-31 01:13:03'),(2,'2026-03-24',17.1300,'Banxico','Marzo 2026 - Cruce CONS9943741515','2026-07-31 01:13:03'),(3,'2026-04-15',17.4800,'Banxico','Abril 2026 - Cruce CONS9943741691','2026-07-31 01:13:03'),(4,'2026-05-10',17.5200,'Banxico','Mayo 2026 - Cruce CONS9943741870','2026-07-31 01:13:03'),(5,'2026-06-01',17.5500,'Banxico','Junio 2026 - Cruce CONS9943742286','2026-07-31 01:13:03'),(6,'2026-06-20',17.5800,'Banxico','Junio 2026 - Cruce CONS9962926323','2026-07-31 01:13:03'),(7,'2026-07-30',17.3300,'Banxico','Julio 2026 - Cruce FITBOS-001 (actual)','2026-07-31 01:13:03');
/*!40000 ALTER TABLE `tipo_cambio_historico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_prenda`
--

DROP TABLE IF EXISTS `tipo_prenda`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_prenda` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `es_prenda` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_prenda`
--

LOCK TABLES `tipo_prenda` WRITE;
/*!40000 ALTER TABLE `tipo_prenda` DISABLE KEYS */;
INSERT INTO `tipo_prenda` VALUES (1,'Camiseta compresión',1),(2,'Camisa manga corta',1),(3,'Camisa Oversize',1),(4,'Camisa manga larga',1),(5,'Jogger',1),(6,'Hoodie',1),(7,'Chamarra',1),(8,'Short mujer',1),(9,'Tank top mujer',1),(10,'Sport bra',1),(11,'Legging',1),(12,'No prenda',0),(13,'Pants',1),(14,'Jacket',1);
/*!40000 ALTER TABLE `tipo_prenda` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicacion`
--

DROP TABLE IF EXISTS `ubicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ubicacion` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicacion`
--

LOCK TABLES `ubicacion` WRITE;
/*!40000 ALTER TABLE `ubicacion` DISABLE KEYS */;
INSERT INTO `ubicacion` VALUES (2,'CDMX'),(1,'Puebla');
/*!40000 ALTER TABLE `ubicacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_alerta_negocio_sin_sku`
--

DROP TABLE IF EXISTS `v_alerta_negocio_sin_sku`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_negocio_sin_sku`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_negocio_sin_sku` AS SELECT 
 1 AS `id`,
 1 AS `guia`,
 1 AS `descripcion`,
 1 AS `costo_usd`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_alerta_paquete_sin_cruce`
--

DROP TABLE IF EXISTS `v_alerta_paquete_sin_cruce`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_paquete_sin_cruce`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_paquete_sin_cruce` AS SELECT 
 1 AS `id`,
 1 AS `guia`,
 1 AS `fecha_llegada`,
 1 AS `n_piezas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_alerta_paquete_sin_piezas`
--

DROP TABLE IF EXISTS `v_alerta_paquete_sin_piezas`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_paquete_sin_piezas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_paquete_sin_piezas` AS SELECT 
 1 AS `id`,
 1 AS `guia`,
 1 AS `folio`,
 1 AS `fecha_llegada`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_alerta_personal_sin_dueno`
--

DROP TABLE IF EXISTS `v_alerta_personal_sin_dueno`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_personal_sin_dueno`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_personal_sin_dueno` AS SELECT 
 1 AS `id`,
 1 AS `guia`,
 1 AS `descripcion`,
 1 AS `costo_usd`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_alerta_rol_sin_tarifa`
--

DROP TABLE IF EXISTS `v_alerta_rol_sin_tarifa`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_rol_sin_tarifa`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_rol_sin_tarifa` AS SELECT 
 1 AS `id`,
 1 AS `nombre`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_alerta_stock_negativo`
--

DROP TABLE IF EXISTS `v_alerta_stock_negativo`;
/*!50001 DROP VIEW IF EXISTS `v_alerta_stock_negativo`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_alerta_stock_negativo` AS SELECT 
 1 AS `sku_id`,
 1 AS `codigo`,
 1 AS `producto`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `disponible`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_capital_socio`
--

DROP TABLE IF EXISTS `v_capital_socio`;
/*!50001 DROP VIEW IF EXISTS `v_capital_socio`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_capital_socio` AS SELECT 
 1 AS `id`,
 1 AS `nombre`,
 1 AS `porcentaje_propiedad`,
 1 AS `aportaciones`,
 1 AS `retiros`,
 1 AS `reinversiones`,
 1 AS `utilidad_total_negocio`,
 1 AS `utilidad_proporcional`,
 1 AS `capital_actual`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_comparacion_costos`
--

DROP TABLE IF EXISTS `v_comparacion_costos`;
/*!50001 DROP VIEW IF EXISTS `v_comparacion_costos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_comparacion_costos` AS SELECT 
 1 AS `temp_id`,
 1 AS `cruce`,
 1 AS `guia`,
 1 AS `descripcion_doc`,
 1 AS `costo_doc`,
 1 AS `pieza_id`,
 1 AS `descripcion_bd`,
 1 AS `costo_bd_actual`,
 1 AS `estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_cruce_con_tc`
--

DROP TABLE IF EXISTS `v_cruce_con_tc`;
/*!50001 DROP VIEW IF EXISTS `v_cruce_con_tc`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_cruce_con_tc` AS SELECT 
 1 AS `id`,
 1 AS `folio`,
 1 AS `fecha`,
 1 AS `costo_mxn`,
 1 AS `tipo_cambio`,
 1 AS `costo_usd_equivalente`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_cruce_negocio_personal`
--

DROP TABLE IF EXISTS `v_cruce_negocio_personal`;
/*!50001 DROP VIEW IF EXISTS `v_cruce_negocio_personal`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_cruce_negocio_personal` AS SELECT 
 1 AS `folio`,
 1 AS `costo_cruce_mxn`,
 1 AS `mxn_negocio`,
 1 AS `mxn_personal`,
 1 AS `mxn_sin_clasificar`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_cruce_reparto`
--

DROP TABLE IF EXISTS `v_cruce_reparto`;
/*!50001 DROP VIEW IF EXISTS `v_cruce_reparto`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_cruce_reparto` AS SELECT 
 1 AS `paquete_id`,
 1 AS `guia`,
 1 AS `cruce_id`,
 1 AS `folio`,
 1 AS `costo_cruce_mxn`,
 1 AS `factor_total`,
 1 AS `factor_cruce`,
 1 AS `cruce_asignado_mxn`,
 1 AS `pct_negocio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_dashboard_inventario`
--

DROP TABLE IF EXISTS `v_dashboard_inventario`;
/*!50001 DROP VIEW IF EXISTS `v_dashboard_inventario`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_dashboard_inventario` AS SELECT 
 1 AS `tipo`,
 1 AS `identificador`,
 1 AS `nombre`,
 1 AS `marca`,
 1 AS `tipo_prenda`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `entradas`,
 1 AS `salidas`,
 1 AS `disponible`,
 1 AS `piezas_vinculadas`,
 1 AS `estado`,
 1 AS `notas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_deuda_balance`
--

DROP TABLE IF EXISTS `v_deuda_balance`;
/*!50001 DROP VIEW IF EXISTS `v_deuda_balance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_deuda_balance` AS SELECT 
 1 AS `socio_id`,
 1 AS `nombre`,
 1 AS `por_cobrar`,
 1 AS `por_pagar`,
 1 AS `balance_neto`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_deuda_personal_por_socio`
--

DROP TABLE IF EXISTS `v_deuda_personal_por_socio`;
/*!50001 DROP VIEW IF EXISTS `v_deuda_personal_por_socio`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_deuda_personal_por_socio` AS SELECT 
 1 AS `socio`,
 1 AS `n_piezas`,
 1 AS `cruce_mxn`,
 1 AS `mercancia_mxn`,
 1 AS `total_mxn`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_movimientos_detalle`
--

DROP TABLE IF EXISTS `v_movimientos_detalle`;
/*!50001 DROP VIEW IF EXISTS `v_movimientos_detalle`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_movimientos_detalle` AS SELECT 
 1 AS `movimiento_id`,
 1 AS `fecha`,
 1 AS `tipo`,
 1 AS `sku_codigo`,
 1 AS `producto`,
 1 AS `marca`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `cantidad`,
 1 AS `valor`,
 1 AS `moneda`,
 1 AS `venta_id`,
 1 AS `venta_folio`,
 1 AS `pieza_id`,
 1 AS `pieza_descripcion`,
 1 AS `paquete_guia`,
 1 AS `cruce_folio`,
 1 AS `categoria`,
 1 AS `notas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_movimientos_sku`
--

DROP TABLE IF EXISTS `v_movimientos_sku`;
/*!50001 DROP VIEW IF EXISTS `v_movimientos_sku`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_movimientos_sku` AS SELECT 
 1 AS `sku_id`,
 1 AS `codigo`,
 1 AS `producto`,
 1 AS `marca`,
 1 AS `tipo_prenda`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `total_entradas`,
 1 AS `total_salidas`,
 1 AS `disponible`,
 1 AS `reservado`,
 1 AS `piezas_vinculadas`,
 1 AS `precio_lista_mxn`,
 1 AS `estado_stock`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_movimientos_sku_valores`
--

DROP TABLE IF EXISTS `v_movimientos_sku_valores`;
/*!50001 DROP VIEW IF EXISTS `v_movimientos_sku_valores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_movimientos_sku_valores` AS SELECT 
 1 AS `sku_id`,
 1 AS `codigo`,
 1 AS `producto`,
 1 AS `marca`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `total_entradas`,
 1 AS `total_salidas`,
 1 AS `costo_total_usd`,
 1 AS `venta_total_mxn`,
 1 AS `disponible`,
 1 AS `reservado`,
 1 AS `estado_stock`,
 1 AS `precio_lista_mxn`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_paquete_split`
--

DROP TABLE IF EXISTS `v_paquete_split`;
/*!50001 DROP VIEW IF EXISTS `v_paquete_split`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_paquete_split` AS SELECT 
 1 AS `paquete_id`,
 1 AS `guia`,
 1 AS `cruce_id`,
 1 AS `fecha_llegada`,
 1 AS `n_piezas`,
 1 AS `factor_total`,
 1 AS `factor_negocio`,
 1 AS `factor_personal`,
 1 AS `pct_negocio`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pedido_orden_resumen`
--

DROP TABLE IF EXISTS `v_pedido_orden_resumen`;
/*!50001 DROP VIEW IF EXISTS `v_pedido_orden_resumen`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pedido_orden_resumen` AS SELECT 
 1 AS `id`,
 1 AS `folio`,
 1 AS `fecha_pedido`,
 1 AS `fecha_estimada`,
 1 AS `fecha_recepcion`,
 1 AS `estado`,
 1 AS `guia_envio`,
 1 AS `monto_total_usd`,
 1 AS `notas`,
 1 AS `proveedor`,
 1 AS `socio_comprador`,
 1 AS `total_piezas`,
 1 AS `dias_desde_pedido`,
 1 AS `alerta_retraso`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pieza_costo`
--

DROP TABLE IF EXISTS `v_pieza_costo`;
/*!50001 DROP VIEW IF EXISTS `v_pieza_costo`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pieza_costo` AS SELECT 
 1 AS `pieza_id`,
 1 AS `paquete_id`,
 1 AS `sku_id`,
 1 AS `destino`,
 1 AS `socio_id`,
 1 AS `factor_total`,
 1 AS `costo_usd`,
 1 AS `costo_prenda_mxn`,
 1 AS `cruce_pieza_mxn`,
 1 AS `costo_total_mxn`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pieza_factor`
--

DROP TABLE IF EXISTS `v_pieza_factor`;
/*!50001 DROP VIEW IF EXISTS `v_pieza_factor`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pieza_factor` AS SELECT 
 1 AS `pieza_id`,
 1 AS `paquete_id`,
 1 AS `destino`,
 1 AS `socio_id`,
 1 AS `sku_id`,
 1 AS `cantidad`,
 1 AS `costo_usd`,
 1 AS `factor`,
 1 AS `factor_total`,
 1 AS `origen_factor`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_piezas_sin_sku`
--

DROP TABLE IF EXISTS `v_piezas_sin_sku`;
/*!50001 DROP VIEW IF EXISTS `v_piezas_sin_sku`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_piezas_sin_sku` AS SELECT 
 1 AS `pieza_id`,
 1 AS `guia`,
 1 AS `cruce`,
 1 AS `descripcion`,
 1 AS `marca`,
 1 AS `tipo_prenda`,
 1 AS `cantidad`,
 1 AS `costo_usd`,
 1 AS `destino`,
 1 AS `estado`,
 1 AS `notas`,
 1 AS `fecha_llegada`,
 1 AS `paqueteria`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_salud_factores`
--

DROP TABLE IF EXISTS `v_salud_factores`;
/*!50001 DROP VIEW IF EXISTS `v_salud_factores`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_salud_factores` AS SELECT 
 1 AS `origen_factor`,
 1 AS `n_piezas`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_stock`
--

DROP TABLE IF EXISTS `v_stock`;
/*!50001 DROP VIEW IF EXISTS `v_stock`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_stock` AS SELECT 
 1 AS `sku_id`,
 1 AS `codigo`,
 1 AS `producto`,
 1 AS `talla`,
 1 AS `color`,
 1 AS `stock_inicial`,
 1 AS `entradas`,
 1 AS `salidas`,
 1 AS `disponible`,
 1 AS `reservado`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `folio` varchar(40) DEFAULT NULL,
  `fecha` date NOT NULL,
  `canal_id` smallint DEFAULT NULL,
  `cliente` varchar(160) DEFAULT NULL,
  `estado` varchar(20) NOT NULL DEFAULT 'CERRADA',
  `envio_cliente_mxn` decimal(10,2) DEFAULT '0.00',
  `notas` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`),
  KEY `fk_venta_canal` (`canal_id`),
  CONSTRAINT `fk_venta_canal` FOREIGN KEY (`canal_id`) REFERENCES `canal` (`id`),
  CONSTRAINT `ck_venta_estado` CHECK ((`estado` in (_utf8mb4'APARTADO',_utf8mb4'CERRADA',_utf8mb4'CANCELADO')))
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (14,'V-1','2026-05-07',1,'Calvin Klein (Alan Louvre)','CERRADA',0.00,NULL),(15,'V-2','2026-03-28',1,'Ali Atlixco','CERRADA',0.00,NULL),(16,'V-3','2026-04-16',1,'Crus','CERRADA',0.00,NULL),(17,'V-4','2026-05-08',7,'Klein','CERRADA',0.00,NULL),(18,'V-5','2026-04-16',1,'Alan Gonzalez Arce','CERRADA',0.00,NULL),(19,'V-6','2026-04-16',9,'Gamble Hiram','CERRADA',0.00,NULL),(20,'V-7','2026-04-18',9,'Angel','CERRADA',0.00,NULL),(21,'V-8','2026-05-06',1,'Ali Atlixco','CERRADA',0.00,NULL),(22,'V-9','2026-04-23',2,'Jakelin','CERRADA',0.00,NULL),(23,'V-10','2026-06-15',1,'cisneros22222','CERRADA',0.00,NULL),(24,'V-11','2026-06-15',1,'cisneros22222','CERRADA',0.00,NULL),(25,'CDMX-1','2026-07-30',9,'Jairo Arteaga Alvarado','CERRADA',0.00,'Primera entrega en cdmx');
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta_linea`
--

DROP TABLE IF EXISTS `venta_linea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta_linea` (
  `id` int NOT NULL AUTO_INCREMENT,
  `venta_id` int NOT NULL,
  `sku_id` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario_mxn` decimal(12,2) NOT NULL,
  `descuento_mxn` decimal(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `fk_vl_venta` (`venta_id`),
  KEY `fk_vl_sku` (`sku_id`),
  CONSTRAINT `fk_vl_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_vl_venta` FOREIGN KEY (`venta_id`) REFERENCES `venta` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ck_vl_cantidad` CHECK ((`cantidad` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_linea`
--

LOCK TABLES `venta_linea` WRITE;
/*!40000 ALTER TABLE `venta_linea` DISABLE KEYS */;
INSERT INTO `venta_linea` VALUES (15,14,31,1,850.00,0.00),(16,15,9,1,1200.00,0.00),(17,16,10,1,1250.00,0.00),(18,17,14,1,950.00,0.00),(19,18,17,1,1500.00,0.00),(21,20,28,1,2100.00,0.00),(22,21,22,1,1400.00,0.00),(23,22,26,1,1150.00,0.00),(24,23,16,1,1275.00,0.00),(25,24,19,1,1275.00,0.00),(26,19,27,1,2300.00,0.00),(27,25,41,1,1650.00,0.00);
/*!40000 ALTER TABLE `venta_linea` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta_rol`
--

DROP TABLE IF EXISTS `venta_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta_rol` (
  `venta_id` int NOT NULL,
  `rol_venta_id` smallint NOT NULL,
  `socio_id` smallint NOT NULL,
  PRIMARY KEY (`venta_id`,`rol_venta_id`),
  KEY `fk_vr_rol` (`rol_venta_id`),
  KEY `fk_vr_socio` (`socio_id`),
  CONSTRAINT `fk_vr_rol` FOREIGN KEY (`rol_venta_id`) REFERENCES `rol_venta` (`id`),
  CONSTRAINT `fk_vr_socio` FOREIGN KEY (`socio_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `fk_vr_venta` FOREIGN KEY (`venta_id`) REFERENCES `venta` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_rol`
--

LOCK TABLES `venta_rol` WRITE;
/*!40000 ALTER TABLE `venta_rol` DISABLE KEYS */;
INSERT INTO `venta_rol` VALUES (16,2,4),(18,2,4),(19,2,4),(20,2,4),(23,2,4),(25,2,4),(14,1,5),(14,2,5),(15,1,5),(15,2,5),(16,1,5),(17,1,5),(17,2,5),(18,1,5),(19,1,5),(20,1,5),(21,1,5),(21,2,5),(22,1,5),(22,2,5),(24,2,5),(23,1,6),(24,1,6),(25,1,6);
/*!40000 ALTER TABLE `venta_rol` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_alerta_negocio_sin_sku`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_negocio_sin_sku`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_negocio_sin_sku` AS select `p`.`id` AS `id`,`pq`.`guia` AS `guia`,`p`.`descripcion` AS `descripcion`,`p`.`costo_usd` AS `costo_usd` from (`pieza` `p` join `paquete` `pq` on((`pq`.`id` = `p`.`paquete_id`))) where ((`p`.`destino` = 'NEGOCIO') and (`p`.`sku_id` is null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_alerta_paquete_sin_cruce`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_paquete_sin_cruce`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_paquete_sin_cruce` AS select `pq`.`id` AS `id`,`pq`.`guia` AS `guia`,`pq`.`fecha_llegada` AS `fecha_llegada`,count(`p`.`id`) AS `n_piezas` from (`paquete` `pq` left join `pieza` `p` on((`p`.`paquete_id` = `pq`.`id`))) where (`pq`.`cruce_id` is null) group by `pq`.`id`,`pq`.`guia`,`pq`.`fecha_llegada` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_alerta_paquete_sin_piezas`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_paquete_sin_piezas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_paquete_sin_piezas` AS select `pq`.`id` AS `id`,`pq`.`guia` AS `guia`,`c`.`folio` AS `folio`,`pq`.`fecha_llegada` AS `fecha_llegada` from (`paquete` `pq` left join `cruce` `c` on((`c`.`id` = `pq`.`cruce_id`))) where exists(select 1 from `pieza` `p` where (`p`.`paquete_id` = `pq`.`id`)) is false */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_alerta_personal_sin_dueno`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_personal_sin_dueno`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_personal_sin_dueno` AS select `p`.`id` AS `id`,`pq`.`guia` AS `guia`,`p`.`descripcion` AS `descripcion`,`p`.`costo_usd` AS `costo_usd` from (`pieza` `p` join `paquete` `pq` on((`pq`.`id` = `p`.`paquete_id`))) where ((`p`.`destino` = 'PERSONAL') and (`p`.`socio_id` is null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_alerta_rol_sin_tarifa`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_rol_sin_tarifa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_rol_sin_tarifa` AS select `rv`.`id` AS `id`,`rv`.`nombre` AS `nombre` from `rol_venta` `rv` where exists(select 1 from `comision_tarifa` `ct` where ((`ct`.`rol_venta_id` = `rv`.`id`) and (`ct`.`vigente_hasta` is null))) is false */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_alerta_stock_negativo`
--

/*!50001 DROP VIEW IF EXISTS `v_alerta_stock_negativo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_alerta_stock_negativo` AS select `v_stock`.`sku_id` AS `sku_id`,`v_stock`.`codigo` AS `codigo`,`v_stock`.`producto` AS `producto`,`v_stock`.`talla` AS `talla`,`v_stock`.`color` AS `color`,`v_stock`.`disponible` AS `disponible` from `v_stock` where (`v_stock`.`disponible` < 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_capital_socio`
--

/*!50001 DROP VIEW IF EXISTS `v_capital_socio`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_capital_socio` AS select `s`.`id` AS `id`,`s`.`nombre` AS `nombre`,`s`.`porcentaje_propiedad` AS `porcentaje_propiedad`,coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'APORTACION'))),0) AS `aportaciones`,coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'RETIRO'))),0) AS `retiros`,coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'REINVERSION'))),0) AS `reinversiones`,(select coalesce(sum(((((`vl`.`cantidad` * `vl`.`precio_unitario_mxn`) - (`vl`.`cantidad` * `vpc`.`costo_total_mxn`)) - (select coalesce(sum(((`ct`.`pct` * `vl`.`cantidad`) * `vl`.`precio_unitario_mxn`)),0) from (`venta_rol` `vr` join `comision_tarifa` `ct` on((`vr`.`rol_venta_id` = `ct`.`rol_venta_id`))) where ((`vr`.`venta_id` = `v`.`id`) and (`ct`.`vigente_desde` <= `v`.`fecha`) and ((`ct`.`vigente_hasta` is null) or (`ct`.`vigente_hasta` >= `v`.`fecha`))))) - coalesce(`v`.`envio_cliente_mxn`,0))),0) from ((`venta` `v` join `venta_linea` `vl` on((`vl`.`venta_id` = `v`.`id`))) left join `v_pieza_costo` `vpc` on((`vpc`.`sku_id` = `vl`.`sku_id`)))) AS `utilidad_total_negocio`,((select coalesce(sum(((((`vl`.`cantidad` * `vl`.`precio_unitario_mxn`) - (`vl`.`cantidad` * `vpc`.`costo_total_mxn`)) - (select coalesce(sum(((`ct`.`pct` * `vl`.`cantidad`) * `vl`.`precio_unitario_mxn`)),0) from (`venta_rol` `vr` join `comision_tarifa` `ct` on((`vr`.`rol_venta_id` = `ct`.`rol_venta_id`))) where ((`vr`.`venta_id` = `v`.`id`) and (`ct`.`vigente_desde` <= `v`.`fecha`) and ((`ct`.`vigente_hasta` is null) or (`ct`.`vigente_hasta` >= `v`.`fecha`))))) - coalesce(`v`.`envio_cliente_mxn`,0))),0) from ((`venta` `v` join `venta_linea` `vl` on((`vl`.`venta_id` = `v`.`id`))) left join `v_pieza_costo` `vpc` on((`vpc`.`sku_id` = `vl`.`sku_id`)))) * (`s`.`porcentaje_propiedad` / 100)) AS `utilidad_proporcional`,(((coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'APORTACION'))),0) - coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'RETIRO'))),0)) + coalesce((select sum(`capital_movimiento`.`monto_mxn`) from `capital_movimiento` where ((`capital_movimiento`.`socio_id` = `s`.`id`) and (`capital_movimiento`.`tipo` = 'REINVERSION'))),0)) + ((select coalesce(sum(((((`vl`.`cantidad` * `vl`.`precio_unitario_mxn`) - (`vl`.`cantidad` * `vpc`.`costo_total_mxn`)) - (select coalesce(sum(((`ct`.`pct` * `vl`.`cantidad`) * `vl`.`precio_unitario_mxn`)),0) from (`venta_rol` `vr` join `comision_tarifa` `ct` on((`vr`.`rol_venta_id` = `ct`.`rol_venta_id`))) where ((`vr`.`venta_id` = `v`.`id`) and (`ct`.`vigente_desde` <= `v`.`fecha`) and ((`ct`.`vigente_hasta` is null) or (`ct`.`vigente_hasta` >= `v`.`fecha`))))) - coalesce(`v`.`envio_cliente_mxn`,0))),0) from ((`venta` `v` join `venta_linea` `vl` on((`vl`.`venta_id` = `v`.`id`))) left join `v_pieza_costo` `vpc` on((`vpc`.`sku_id` = `vl`.`sku_id`)))) * (`s`.`porcentaje_propiedad` / 100))) AS `capital_actual` from `socio` `s` where (`s`.`activo` = 1) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_comparacion_costos`
--

/*!50001 DROP VIEW IF EXISTS `v_comparacion_costos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_comparacion_costos` AS select `t`.`id` AS `temp_id`,`t`.`cruce` AS `cruce`,`t`.`guia` AS `guia`,`t`.`descripcion` AS `descripcion_doc`,`t`.`costo_total_usd` AS `costo_doc`,`pz`.`id` AS `pieza_id`,`pz`.`descripcion` AS `descripcion_bd`,`pz`.`costo_usd` AS `costo_bd_actual`,(case when (`pz`.`id` is null) then 'NO_ENCONTRADA' when (`pz`.`costo_usd` is null) then 'SIN_COSTO' when (abs((`pz`.`costo_usd` - `t`.`costo_total_usd`)) < 0.01) then 'OK' else 'DIFERENTE' end) AS `estado` from (`temp_costos_consolidados` `t` left join `pieza` `pz` on(((lower(`pz`.`descripcion`) like concat('%',lower(substr(`t`.`descripcion`,1,15)),'%')) or (lower(replace(`pz`.`descripcion`,' ','')) like concat('%',lower(replace(substr(`t`.`descripcion`,1,20),' ','')),'%'))))) where ((`t`.`es_personal` = false) and (`t`.`descripcion` not in ('45 .','SHIP PROTE','CODIGO'))) order by `t`.`cruce`,`t`.`guia`,`t`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_cruce_con_tc`
--

/*!50001 DROP VIEW IF EXISTS `v_cruce_con_tc`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_cruce_con_tc` AS select `c`.`id` AS `id`,`c`.`folio` AS `folio`,`c`.`fecha` AS `fecha`,`c`.`costo_mxn` AS `costo_mxn`,`tc`.`usd_a_mxn` AS `tipo_cambio`,round((`c`.`costo_mxn` / `tc`.`usd_a_mxn`),2) AS `costo_usd_equivalente` from (`cruce` `c` left join `tipo_cambio_historico` `tc` on((`tc`.`fecha` = `c`.`fecha`))) order by `c`.`fecha` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_cruce_negocio_personal`
--

/*!50001 DROP VIEW IF EXISTS `v_cruce_negocio_personal`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_cruce_negocio_personal` AS select `v_cruce_reparto`.`folio` AS `folio`,`v_cruce_reparto`.`costo_cruce_mxn` AS `costo_cruce_mxn`,sum((case when (`v_cruce_reparto`.`pct_negocio` is not null) then (`v_cruce_reparto`.`cruce_asignado_mxn` * `v_cruce_reparto`.`pct_negocio`) end)) AS `mxn_negocio`,sum((case when (`v_cruce_reparto`.`pct_negocio` is not null) then (`v_cruce_reparto`.`cruce_asignado_mxn` * (1 - `v_cruce_reparto`.`pct_negocio`)) end)) AS `mxn_personal`,sum((case when (`v_cruce_reparto`.`pct_negocio` is null) then `v_cruce_reparto`.`cruce_asignado_mxn` end)) AS `mxn_sin_clasificar` from `v_cruce_reparto` group by `v_cruce_reparto`.`folio`,`v_cruce_reparto`.`costo_cruce_mxn` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_cruce_reparto`
--

/*!50001 DROP VIEW IF EXISTS `v_cruce_reparto`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_cruce_reparto` AS with `tot` as (select `v_paquete_split`.`cruce_id` AS `cruce_id`,sum(`v_paquete_split`.`factor_total`) AS `factor_cruce` from `v_paquete_split` where (`v_paquete_split`.`cruce_id` is not null) group by `v_paquete_split`.`cruce_id`) select `s`.`paquete_id` AS `paquete_id`,`s`.`guia` AS `guia`,`c`.`id` AS `cruce_id`,`c`.`folio` AS `folio`,`c`.`costo_mxn` AS `costo_cruce_mxn`,`s`.`factor_total` AS `factor_total`,`t`.`factor_cruce` AS `factor_cruce`,(case when (`t`.`factor_cruce` > 0) then ((`c`.`costo_mxn` * `s`.`factor_total`) / `t`.`factor_cruce`) else (`c`.`costo_mxn` / count(0) OVER (PARTITION BY `c`.`id` ) ) end) AS `cruce_asignado_mxn`,`s`.`pct_negocio` AS `pct_negocio` from ((`v_paquete_split` `s` join `cruce` `c` on((`c`.`id` = `s`.`cruce_id`))) left join `tot` `t` on((`t`.`cruce_id` = `c`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_dashboard_inventario`
--

/*!50001 DROP VIEW IF EXISTS `v_dashboard_inventario`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_dashboard_inventario` AS select 'CON_SKU' AS `tipo`,`v_movimientos_sku`.`codigo` AS `identificador`,`v_movimientos_sku`.`producto` AS `nombre`,`v_movimientos_sku`.`marca` AS `marca`,`v_movimientos_sku`.`tipo_prenda` AS `tipo_prenda`,`v_movimientos_sku`.`talla` AS `talla`,`v_movimientos_sku`.`color` AS `color`,`v_movimientos_sku`.`total_entradas` AS `entradas`,`v_movimientos_sku`.`total_salidas` AS `salidas`,`v_movimientos_sku`.`disponible` AS `disponible`,`v_movimientos_sku`.`piezas_vinculadas` AS `piezas_vinculadas`,`v_movimientos_sku`.`estado_stock` AS `estado`,NULL AS `notas` from `v_movimientos_sku` union all select 'SIN_SKU' AS `tipo`,`v_piezas_sin_sku`.`guia` AS `identificador`,`v_piezas_sin_sku`.`descripcion` AS `nombre`,`v_piezas_sin_sku`.`marca` AS `marca`,`v_piezas_sin_sku`.`tipo_prenda` AS `tipo_prenda`,NULL AS `talla`,NULL AS `color`,NULL AS `entradas`,NULL AS `salidas`,`v_piezas_sin_sku`.`cantidad` AS `disponible`,NULL AS `piezas_vinculadas`,`v_piezas_sin_sku`.`estado` AS `estado`,`v_piezas_sin_sku`.`notas` AS `notas` from `v_piezas_sin_sku` order by `tipo` desc,`marca`,`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_deuda_balance`
--

/*!50001 DROP VIEW IF EXISTS `v_deuda_balance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_deuda_balance` AS select `s`.`id` AS `socio_id`,`s`.`nombre` AS `nombre`,coalesce(sum((case when ((`p`.`socio_acreedor_id` = `s`.`id`) and (`p`.`pagado` = false)) then `p`.`monto_mxn` else 0 end)),0) AS `por_cobrar`,coalesce(sum((case when ((`p`.`socio_deudor_id` = `s`.`id`) and (`p`.`pagado` = false)) then `p`.`monto_mxn` else 0 end)),0) AS `por_pagar`,(coalesce(sum((case when ((`p`.`socio_acreedor_id` = `s`.`id`) and (`p`.`pagado` = false)) then `p`.`monto_mxn` else 0 end)),0) - coalesce(sum((case when ((`p`.`socio_deudor_id` = `s`.`id`) and (`p`.`pagado` = false)) then `p`.`monto_mxn` else 0 end)),0)) AS `balance_neto` from (`socio` `s` left join `prestamo` `p` on(((`p`.`socio_acreedor_id` = `s`.`id`) or (`p`.`socio_deudor_id` = `s`.`id`)))) where (`s`.`activo` = 1) group by `s`.`id`,`s`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_deuda_personal_por_socio`
--

/*!50001 DROP VIEW IF EXISTS `v_deuda_personal_por_socio`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_deuda_personal_por_socio` AS select `s`.`nombre` AS `socio`,count(`pc`.`pieza_id`) AS `n_piezas`,sum(`pc`.`cruce_pieza_mxn`) AS `cruce_mxn`,sum(`pc`.`costo_prenda_mxn`) AS `mercancia_mxn`,sum(`pc`.`costo_total_mxn`) AS `total_mxn` from (`v_pieza_costo` `pc` join `socio` `s` on((`s`.`id` = `pc`.`socio_id`))) where (`pc`.`destino` = 'PERSONAL') group by `s`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_movimientos_detalle`
--

/*!50001 DROP VIEW IF EXISTS `v_movimientos_detalle`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_movimientos_detalle` AS select `mov`.`id` AS `movimiento_id`,`mov`.`fecha` AS `fecha`,`mov`.`tipo` AS `tipo`,`s`.`codigo` AS `sku_codigo`,`pr`.`nombre` AS `producto`,`m`.`nombre` AS `marca`,`s`.`talla` AS `talla`,`s`.`color` AS `color`,`mov`.`cantidad` AS `cantidad`,(case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS')) then (coalesce(`pz`.`costo_usd`,0) * `mov`.`cantidad`) when (`mov`.`tipo` = 'VENTA') then (coalesce(`vl`.`precio_unitario_mxn`,`s`.`precio_lista_mxn`,0) * `mov`.`cantidad`) else 0 end) AS `valor`,(case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS')) then 'USD' when (`mov`.`tipo` = 'VENTA') then 'MXN' else NULL end) AS `moneda`,`mov`.`venta_id` AS `venta_id`,`v`.`folio` AS `venta_folio`,`mov`.`pieza_id` AS `pieza_id`,`pz`.`descripcion` AS `pieza_descripcion`,`pq`.`guia` AS `paquete_guia`,`c`.`folio` AS `cruce_folio`,(case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS','DEVOLUCION','TRASLADO_ENTRADA')) then 'ENTRADA' when (`mov`.`tipo` in ('VENTA','AJUSTE_MENOS','TRASLADO_SALIDA')) then 'SALIDA' else 'OTRO' end) AS `categoria`,`mov`.`notas` AS `notas` from ((((((((`movimiento` `mov` join `sku` `s` on((`s`.`id` = `mov`.`sku_id`))) join `producto` `pr` on((`pr`.`id` = `s`.`producto_id`))) join `marca` `m` on((`m`.`id` = `pr`.`marca_id`))) left join `pieza` `pz` on((`pz`.`id` = `mov`.`pieza_id`))) left join `paquete` `pq` on((`pq`.`id` = `pz`.`paquete_id`))) left join `cruce` `c` on((`c`.`id` = `pq`.`cruce_id`))) left join `venta` `v` on((`v`.`id` = `mov`.`venta_id`))) left join `venta_linea` `vl` on(((`vl`.`venta_id` = `v`.`id`) and (`vl`.`sku_id` = `s`.`id`)))) order by `mov`.`fecha` desc,`mov`.`id` desc */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_movimientos_sku`
--

/*!50001 DROP VIEW IF EXISTS `v_movimientos_sku`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_movimientos_sku` AS select `s`.`id` AS `sku_id`,`s`.`codigo` AS `codigo`,`pr`.`nombre` AS `producto`,`m`.`nombre` AS `marca`,`tp`.`nombre` AS `tipo_prenda`,`s`.`talla` AS `talla`,`s`.`color` AS `color`,coalesce(sum((case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS','DEVOLUCION')) then `mov`.`cantidad` else 0 end)),0) AS `total_entradas`,coalesce(sum((case when (`mov`.`tipo` in ('VENTA','AJUSTE_MENOS')) then `mov`.`cantidad` else 0 end)),0) AS `total_salidas`,`vs`.`disponible` AS `disponible`,`vs`.`reservado` AS `reservado`,(select count(0) from `pieza` `pz` where (`pz`.`sku_id` = `s`.`id`)) AS `piezas_vinculadas`,`s`.`precio_lista_mxn` AS `precio_lista_mxn`,(case when (`vs`.`disponible` > 0) then 'Disponible' when (`vs`.`disponible` = 0) then 'Sin stock' when (`vs`.`disponible` < 0) then 'Stock negativo' end) AS `estado_stock` from (((((`sku` `s` join `producto` `pr` on((`pr`.`id` = `s`.`producto_id`))) join `marca` `m` on((`m`.`id` = `pr`.`marca_id`))) join `tipo_prenda` `tp` on((`tp`.`id` = `pr`.`tipo_prenda_id`))) left join `movimiento` `mov` on((`mov`.`sku_id` = `s`.`id`))) left join `v_stock` `vs` on((`vs`.`sku_id` = `s`.`id`))) group by `s`.`id`,`s`.`codigo`,`pr`.`nombre`,`m`.`nombre`,`tp`.`nombre`,`s`.`talla`,`s`.`color`,`vs`.`disponible`,`vs`.`reservado`,`s`.`precio_lista_mxn` order by `m`.`nombre`,`pr`.`nombre`,`s`.`talla`,`s`.`color` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_movimientos_sku_valores`
--

/*!50001 DROP VIEW IF EXISTS `v_movimientos_sku_valores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_movimientos_sku_valores` AS select `s`.`id` AS `sku_id`,`s`.`codigo` AS `codigo`,`pr`.`nombre` AS `producto`,`m`.`nombre` AS `marca`,`s`.`talla` AS `talla`,`s`.`color` AS `color`,coalesce(sum((case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS','DEVOLUCION')) then `mov`.`cantidad` else 0 end)),0) AS `total_entradas`,coalesce(sum((case when (`mov`.`tipo` in ('VENTA','AJUSTE_MENOS')) then `mov`.`cantidad` else 0 end)),0) AS `total_salidas`,coalesce(sum((case when (`mov`.`tipo` in ('COMPRA','INICIAL','AJUSTE_MAS')) then (`pz`.`costo_usd` * `mov`.`cantidad`) else 0 end)),0) AS `costo_total_usd`,coalesce(sum((case when (`mov`.`tipo` = 'VENTA') then (`vl`.`precio_unitario_mxn` * `mov`.`cantidad`) else 0 end)),0) AS `venta_total_mxn`,`vs`.`disponible` AS `disponible`,`vs`.`reservado` AS `reservado`,(case when (`vs`.`disponible` > 0) then 'Disponible' when (`vs`.`disponible` = 0) then 'Sin stock' when (`vs`.`disponible` < 0) then 'Stock negativo' end) AS `estado_stock`,`s`.`precio_lista_mxn` AS `precio_lista_mxn` from ((((((`sku` `s` join `producto` `pr` on((`pr`.`id` = `s`.`producto_id`))) join `marca` `m` on((`m`.`id` = `pr`.`marca_id`))) left join `movimiento` `mov` on((`mov`.`sku_id` = `s`.`id`))) left join `pieza` `pz` on((`pz`.`id` = `mov`.`pieza_id`))) left join `venta_linea` `vl` on((`vl`.`sku_id` = `s`.`id`))) left join `v_stock` `vs` on((`vs`.`sku_id` = `s`.`id`))) group by `s`.`id`,`s`.`codigo`,`pr`.`nombre`,`m`.`nombre`,`s`.`talla`,`s`.`color`,`vs`.`disponible`,`vs`.`reservado`,`s`.`precio_lista_mxn` order by `m`.`nombre`,`pr`.`nombre`,`s`.`talla`,`s`.`color` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_paquete_split`
--

/*!50001 DROP VIEW IF EXISTS `v_paquete_split`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_paquete_split` AS select `pq`.`id` AS `paquete_id`,`pq`.`guia` AS `guia`,`pq`.`cruce_id` AS `cruce_id`,`pq`.`fecha_llegada` AS `fecha_llegada`,count(`f`.`pieza_id`) AS `n_piezas`,coalesce(sum(`f`.`factor_total`),0) AS `factor_total`,coalesce(sum((case when (`f`.`destino` = 'NEGOCIO') then `f`.`factor_total` end)),0) AS `factor_negocio`,coalesce(sum((case when (`f`.`destino` = 'PERSONAL') then `f`.`factor_total` end)),0) AS `factor_personal`,(case when (coalesce(sum(`f`.`factor_total`),0) > 0) then (coalesce(sum((case when (`f`.`destino` = 'NEGOCIO') then `f`.`factor_total` end)),0) / sum(`f`.`factor_total`)) end) AS `pct_negocio` from (`paquete` `pq` left join `v_pieza_factor` `f` on((`f`.`paquete_id` = `pq`.`id`))) group by `pq`.`id`,`pq`.`guia`,`pq`.`cruce_id`,`pq`.`fecha_llegada` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pedido_orden_resumen`
--

/*!50001 DROP VIEW IF EXISTS `v_pedido_orden_resumen`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pedido_orden_resumen` AS select `p`.`id` AS `id`,`p`.`folio` AS `folio`,`p`.`fecha_pedido` AS `fecha_pedido`,`p`.`fecha_estimada` AS `fecha_estimada`,`p`.`fecha_recepcion` AS `fecha_recepcion`,`p`.`estado` AS `estado`,`p`.`tracking` AS `guia_envio`,`p`.`costo_estimado_usd` AS `monto_total_usd`,`p`.`notas` AS `notas`,`prov`.`nombre` AS `proveedor`,`s`.`nombre` AS `socio_comprador`,coalesce(sum(`pp`.`cantidad_pedida`),0) AS `total_piezas`,(to_days(curdate()) - to_days(`p`.`fecha_pedido`)) AS `dias_desde_pedido`,(case when ((`p`.`estado` in ('PENDIENTE','EN_TRANSITO')) and ((to_days(curdate()) - to_days(`p`.`fecha_pedido`)) > 30)) then 1 else 0 end) AS `alerta_retraso` from (((`pedido` `p` join `proveedor` `prov` on((`prov`.`id` = `p`.`proveedor_id`))) left join `socio` `s` on((`s`.`id` = `p`.`socio_comprador_id`))) left join `pedido_pieza` `pp` on((`pp`.`pedido_id` = `p`.`id`))) group by `p`.`id`,`p`.`folio`,`p`.`fecha_pedido`,`p`.`fecha_estimada`,`p`.`fecha_recepcion`,`p`.`estado`,`p`.`tracking`,`p`.`costo_estimado_usd`,`p`.`notas`,`prov`.`nombre`,`s`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pieza_costo`
--

/*!50001 DROP VIEW IF EXISTS `v_pieza_costo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pieza_costo` AS select `f`.`pieza_id` AS `pieza_id`,`f`.`paquete_id` AS `paquete_id`,`f`.`sku_id` AS `sku_id`,`f`.`destino` AS `destino`,`f`.`socio_id` AS `socio_id`,`f`.`factor_total` AS `factor_total`,`f`.`costo_usd` AS `costo_usd`,(`f`.`costo_usd` * coalesce(`pp`.`tipo_cambio`,1)) AS `costo_prenda_mxn`,(case when (`s`.`factor_total` > 0) then ((`r`.`cruce_asignado_mxn` * `f`.`factor_total`) / `s`.`factor_total`) else 0 end) AS `cruce_pieza_mxn`,((`f`.`costo_usd` * coalesce(`pp`.`tipo_cambio`,1)) + coalesce((case when (`s`.`factor_total` > 0) then ((`r`.`cruce_asignado_mxn` * `f`.`factor_total`) / `s`.`factor_total`) end),0)) AS `costo_total_mxn` from ((((`v_pieza_factor` `f` join `paquete` `pq` on((`pq`.`id` = `f`.`paquete_id`))) left join `pedido_proveedor` `pp` on((`pp`.`id` = `pq`.`pedido_proveedor_id`))) left join `v_paquete_split` `s` on((`s`.`paquete_id` = `f`.`paquete_id`))) left join `v_cruce_reparto` `r` on((`r`.`paquete_id` = `f`.`paquete_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pieza_factor`
--

/*!50001 DROP VIEW IF EXISTS `v_pieza_factor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pieza_factor` AS select `p`.`id` AS `pieza_id`,`p`.`paquete_id` AS `paquete_id`,`p`.`destino` AS `destino`,`p`.`socio_id` AS `socio_id`,`p`.`sku_id` AS `sku_id`,`p`.`cantidad` AS `cantidad`,`p`.`costo_usd` AS `costo_usd`,coalesce(`p`.`factor_manual`,`fv`.`factor`,1.0) AS `factor`,(`p`.`cantidad` * coalesce(`p`.`factor_manual`,`fv`.`factor`,1.0)) AS `factor_total`,(case when (`p`.`factor_manual` is not null) then 'MANUAL' when (`fv`.`factor` is not null) then 'TABLA' else 'DEFAULT_1.0' end) AS `origen_factor` from (`pieza` `p` left join `factor_volumetrico` `fv` on(((`fv`.`marca_id` = `p`.`marca_id`) and (`fv`.`tipo_prenda_id` = `p`.`tipo_prenda_id`) and (`fv`.`vigente_hasta` is null)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_piezas_sin_sku`
--

/*!50001 DROP VIEW IF EXISTS `v_piezas_sin_sku`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_piezas_sin_sku` AS select `pz`.`id` AS `pieza_id`,`pq`.`guia` AS `guia`,`c`.`folio` AS `cruce`,`pz`.`descripcion` AS `descripcion`,`m`.`nombre` AS `marca`,`tp`.`nombre` AS `tipo_prenda`,`pz`.`cantidad` AS `cantidad`,`pz`.`costo_usd` AS `costo_usd`,`pz`.`destino` AS `destino`,(case when ((`pz`.`notas` like '%PÉRDIDA%') or (`pz`.`notas` like '%PERDIDA%')) then 'Pérdida operativa' else 'Pendiente catalogar' end) AS `estado`,`pz`.`notas` AS `notas`,`pq`.`fecha_llegada` AS `fecha_llegada`,`paqr`.`nombre` AS `paqueteria` from (((((`pieza` `pz` join `paquete` `pq` on((`pq`.`id` = `pz`.`paquete_id`))) left join `cruce` `c` on((`c`.`id` = `pq`.`cruce_id`))) join `marca` `m` on((`m`.`id` = `pz`.`marca_id`))) join `tipo_prenda` `tp` on((`tp`.`id` = `pz`.`tipo_prenda_id`))) left join `paqueteria` `paqr` on((`paqr`.`id` = `pq`.`paqueteria_id`))) where ((`pz`.`destino` = 'NEGOCIO') and (`pz`.`sku_id` is null)) order by (case when ((`pz`.`notas` like '%PÉRDIDA%') or (`pz`.`notas` like '%PERDIDA%')) then 1 else 0 end),`c`.`folio` desc,`pq`.`guia` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_salud_factores`
--

/*!50001 DROP VIEW IF EXISTS `v_salud_factores`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_salud_factores` AS select `v_pieza_factor`.`origen_factor` AS `origen_factor`,count(0) AS `n_piezas` from `v_pieza_factor` group by `v_pieza_factor`.`origen_factor` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_stock`
--

/*!50001 DROP VIEW IF EXISTS `v_stock`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_stock` AS select `sk`.`id` AS `sku_id`,`sk`.`codigo` AS `codigo`,`pr`.`nombre` AS `producto`,`sk`.`talla` AS `talla`,`sk`.`color` AS `color`,0 AS `stock_inicial`,coalesce(sum((case when (`m`.`tipo` in ('COMPRA','TRASLADO_ENTRADA','AJUSTE_MAS','DEVOLUCION')) then `m`.`cantidad` end)),0) AS `entradas`,coalesce(sum((case when (`m`.`tipo` in ('VENTA','TRASLADO_SALIDA','AJUSTE_MENOS')) then `m`.`cantidad` end)),0) AS `salidas`,(coalesce(sum((case when (`m`.`tipo` in ('COMPRA','TRASLADO_ENTRADA','AJUSTE_MAS','DEVOLUCION')) then `m`.`cantidad` end)),0) - coalesce(sum((case when (`m`.`tipo` in ('VENTA','TRASLADO_SALIDA','AJUSTE_MENOS')) then `m`.`cantidad` end)),0)) AS `disponible`,0 AS `reservado` from ((`sku` `sk` join `producto` `pr` on((`pr`.`id` = `sk`.`producto_id`))) left join `movimiento` `m` on((`m`.`sku_id` = `sk`.`id`))) group by `sk`.`id`,`sk`.`codigo`,`pr`.`nombre`,`sk`.`talla`,`sk`.`color` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-31  5:59:20
