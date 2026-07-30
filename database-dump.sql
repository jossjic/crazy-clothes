-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: cc
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `canal`
--

LOCK TABLES `canal` WRITE;
/*!40000 ALTER TABLE `canal` DISABLE KEYS */;
INSERT INTO `canal` VALUES (1,'Instagram'),(3,'Presencial'),(2,'WhatsApp');
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
  `tipo` varchar(20) NOT NULL,
  `monto_mxn` decimal(12,2) NOT NULL,
  `notas` text,
  PRIMARY KEY (`id`),
  KEY `fk_cm_socio` (`socio_id`),
  CONSTRAINT `fk_cm_socio` FOREIGN KEY (`socio_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `ck_cm_tipo` CHECK ((`tipo` in (_utf8mb4'APORTACION',_utf8mb4'RETIRO',_utf8mb4'REINVERSION',_utf8mb4'PRESTAMO')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capital_movimiento`
--

LOCK TABLES `capital_movimiento` WRITE;
/*!40000 ALTER TABLE `capital_movimiento` DISABLE KEYS */;
/*!40000 ALTER TABLE `capital_movimiento` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
-- Table structure for table `cruce`
--

DROP TABLE IF EXISTS `cruce`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cruce` (
  `id` int NOT NULL AUTO_INCREMENT,
  `folio` varchar(40) NOT NULL,
  `fecha` date NOT NULL,
  `costo_mxn` decimal(12,2) NOT NULL,
  `notas` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cruce`
--

LOCK TABLES `cruce` WRITE;
/*!40000 ALTER TABLE `cruce` DISABLE KEYS */;
INSERT INTO `cruce` VALUES (1,'CONS9962926323','2026-07-08',2000.00,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factor_volumetrico`
--

LOCK TABLES `factor_volumetrico` WRITE;
/*!40000 ALTER TABLE `factor_volumetrico` DISABLE KEYS */;
INSERT INTO `factor_volumetrico` VALUES (1,1,2,0.900,'2026-01-01',NULL,NULL),(2,1,1,1.000,'2026-01-01',NULL,NULL),(3,1,4,1.800,'2026-01-01',NULL,NULL),(4,1,3,2.500,'2026-01-01',NULL,NULL),(5,1,8,2.800,'2026-01-01',NULL,NULL),(6,3,1,0.600,'2026-01-01',NULL,NULL),(7,3,3,1.000,'2026-01-01',NULL,NULL),(8,2,5,0.400,'2026-01-01',NULL,NULL),(9,2,7,0.600,'2026-01-01',NULL,NULL),(10,2,6,1.000,'2026-01-01',NULL,NULL),(11,2,4,1.800,'2026-01-01',NULL,NULL),(12,2,3,2.500,'2026-01-01',NULL,NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marca`
--

LOCK TABLES `marca` WRITE;
/*!40000 ALTER TABLE `marca` DISABLE KEYS */;
INSERT INTO `marca` VALUES (2,'Gymshark'),(1,'YoungLA'),(3,'YoungLA / ONYX');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movimiento`
--

LOCK TABLES `movimiento` WRITE;
/*!40000 ALTER TABLE `movimiento` DISABLE KEYS */;
INSERT INTO `movimiento` VALUES (1,'2026-07-10',1,'COMPRA',2,NULL,1,1,NULL,NULL,'Seed'),(2,'2026-07-10',2,'COMPRA',1,NULL,1,2,NULL,NULL,'Seed'),(3,'2026-07-15',1,'VENTA',1,NULL,NULL,NULL,1,NULL,'Venta V-001'),(4,'2026-07-30',1,'COMPRA',10,NULL,NULL,NULL,NULL,NULL,'Pedido recibido - Batman Tee Black M');
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `guia` (`guia`),
  KEY `fk_paquete_paqueteria` (`paqueteria_id`),
  KEY `fk_paquete_cruce` (`cruce_id`),
  KEY `fk_paquete_pedido` (`pedido_proveedor_id`),
  KEY `fk_paquete_ubicacion` (`ubicacion_id`),
  CONSTRAINT `fk_paquete_cruce` FOREIGN KEY (`cruce_id`) REFERENCES `cruce` (`id`),
  CONSTRAINT `fk_paquete_paqueteria` FOREIGN KEY (`paqueteria_id`) REFERENCES `paqueteria` (`id`),
  CONSTRAINT `fk_paquete_pedido` FOREIGN KEY (`pedido_proveedor_id`) REFERENCES `pedido_proveedor` (`id`),
  CONSTRAINT `fk_paquete_ubicacion` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicacion` (`id`),
  CONSTRAINT `ck_paquete_estado` CHECK ((`estado` in (_utf8mb4'PENDIENTE',_utf8mb4'EN_TRANSITO',_utf8mb4'RECIBIDO',_utf8mb4'CANCELADO')))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paquete`
--

LOCK TABLES `paquete` WRITE;
/*!40000 ALTER TABLE `paquete` DISABLE KEYS */;
INSERT INTO `paquete` VALUES (1,'1Z08X89A0301650873',1,1,NULL,'2026-07-10',1,'RECIBIDO',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
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
  `folio` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proveedor_id` smallint NOT NULL,
  `socio_comprador_id` smallint DEFAULT NULL,
  `fecha_pedido` date NOT NULL,
  `fecha_estimada` date DEFAULT NULL,
  `fecha_recepcion` date DEFAULT NULL,
  `estado` enum('PENDIENTE','EN_TRANSITO','RECIBIDO','CANCELADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `tracking` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `costo_estimado_usd` decimal(12,2) DEFAULT NULL,
  `notas` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_pedido_tracking_socio` (`socio_comprador_id`),
  KEY `idx_pedido_estado` (`estado`),
  KEY `idx_pedido_fecha` (`fecha_pedido`),
  KEY `idx_pedido_proveedor` (`proveedor_id`),
  CONSTRAINT `fk_pedido_tracking_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedor` (`id`),
  CONSTRAINT `fk_pedido_tracking_socio` FOREIGN KEY (`socio_comprador_id`) REFERENCES `socio` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido`
--

LOCK TABLES `pedido` WRITE;
/*!40000 ALTER TABLE `pedido` DISABLE KEYS */;
INSERT INTO `pedido` VALUES (1,'PED-001',1,NULL,'2026-07-15','2026-08-15',NULL,'EN_TRANSITO',NULL,850.00,'Pedido de camisetas YoungLA','2026-07-30 18:50:32','2026-07-30 18:50:32'),(2,'PED-002',2,NULL,'2026-07-20','2026-08-20','2026-07-30','RECIBIDO','1234567890',1200.00,'Pedido de hoodies Gymshark','2026-07-30 18:50:32','2026-07-30 19:03:12'),(3,'PED-003',1,NULL,'2026-06-10','2026-07-10',NULL,'RECIBIDO',NULL,650.00,'Pedido recibido - sport bras','2026-07-30 18:50:32','2026-07-30 18:50:32'),(4,'PED-TEST',1,NULL,'2026-07-30',NULL,'2026-07-30','RECIBIDO',NULL,500.00,'Pedido de prueba','2026-07-30 19:04:29','2026-07-30 19:04:43'),(5,'PED-VIEJO',1,NULL,'2026-06-25',NULL,NULL,'PENDIENTE',NULL,300.00,NULL,'2026-07-30 19:04:57','2026-07-30 19:04:57'),(6,'PED-NIKE',3,NULL,'2026-07-30',NULL,NULL,'PENDIENTE',NULL,1500.00,'Pedido Nike','2026-07-30 19:05:23','2026-07-30 19:05:23');
/*!40000 ALTER TABLE `pedido` ENABLE KEYS */;
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
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad_pedida` int NOT NULL DEFAULT '1',
  `cantidad_recibida` int NOT NULL DEFAULT '0',
  `talla` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(60) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `costo_unitario_usd` decimal(10,2) DEFAULT NULL,
  `notas` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `fk_pedido_pieza_marca` (`marca_id`),
  KEY `fk_pedido_pieza_tipo` (`tipo_prenda_id`),
  KEY `idx_pedido_pieza_pedido` (`pedido_id`),
  KEY `idx_pedido_pieza_sku` (`sku_id`),
  CONSTRAINT `fk_pedido_pieza_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_pedido_pieza_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedido` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pedido_pieza_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_pedido_pieza_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_pieza`
--

LOCK TABLES `pedido_pieza` WRITE;
/*!40000 ALTER TABLE `pedido_pieza` DISABLE KEYS */;
INSERT INTO `pedido_pieza` VALUES (1,1,1,1,NULL,'YoungLA Compression Tee Black',10,0,'M','Black',NULL,NULL),(2,1,1,1,NULL,'YoungLA Compression Tee White',10,0,'L','White',NULL,NULL),(3,2,2,3,NULL,'Gymshark Hoodie Grey',5,0,'XL','Grey',NULL,NULL),(4,3,1,5,NULL,'YoungLA Sport Bra',15,0,'S','Black',NULL,NULL),(5,4,1,1,1,'Batman Tee Black M',10,0,'M','Black',NULL,NULL);
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
  `notas` text,
  PRIMARY KEY (`id`),
  KEY `fk_pieza_paquete` (`paquete_id`),
  KEY `fk_pieza_marca` (`marca_id`),
  KEY `fk_pieza_tipo` (`tipo_prenda_id`),
  KEY `fk_pieza_socio` (`socio_id`),
  KEY `fk_pieza_sku` (`sku_id`),
  KEY `ix_pieza_destino_socio` (`destino`,`socio_id`),
  CONSTRAINT `fk_pieza_marca` FOREIGN KEY (`marca_id`) REFERENCES `marca` (`id`),
  CONSTRAINT `fk_pieza_paquete` FOREIGN KEY (`paquete_id`) REFERENCES `paquete` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pieza_sku` FOREIGN KEY (`sku_id`) REFERENCES `sku` (`id`),
  CONSTRAINT `fk_pieza_socio` FOREIGN KEY (`socio_id`) REFERENCES `socio` (`id`),
  CONSTRAINT `fk_pieza_tipo` FOREIGN KEY (`tipo_prenda_id`) REFERENCES `tipo_prenda` (`id`),
  CONSTRAINT `ck_pieza_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `ck_pieza_destino` CHECK ((`destino` in (_utf8mb4'NEGOCIO',_utf8mb4'PERSONAL'))),
  CONSTRAINT `ck_pieza_factor` CHECK (((`factor_manual` is null) or (`factor_manual` > 0))),
  CONSTRAINT `personal_sin_sku` CHECK (((`destino` = _utf8mb4'NEGOCIO') or (`sku_id` is null)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pieza`
--

LOCK TABLES `pieza` WRITE;
/*!40000 ALTER TABLE `pieza` DISABLE KEYS */;
INSERT INTO `pieza` VALUES (1,1,'Batman Compression Tees Black Medium',2,1,1,NULL,'NEGOCIO',NULL,1,48.00,NULL),(2,1,'Batman Compression Tees Black Small',1,1,1,NULL,'NEGOCIO',NULL,2,48.00,NULL),(3,1,'Batman Compression Tee from existing SKU',5,1,1,NULL,'NEGOCIO',NULL,1,25.00,NULL),(4,1,'Nueva pieza sin SKU todavÃ­a',3,1,2,NULL,'NEGOCIO',NULL,NULL,15.00,NULL);
/*!40000 ALTER TABLE `pieza` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,1,1,'Batman Compression Tees','4286'),(2,2,3,'CBUM Washed Hoodie',NULL),(3,2,4,'CBUM Straight Leg Jogger',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor`
--

LOCK TABLES `proveedor` WRITE;
/*!40000 ALTER TABLE `proveedor` DISABLE KEYS */;
INSERT INTO `proveedor` VALUES (1,'YoungLA',1),(2,'Gymshark',2),(3,'Nike Store',NULL);
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
  `estado` varchar(20) NOT NULL DEFAULT 'ACTIVO',
  `precio_lista_mxn` decimal(12,2) DEFAULT NULL,
  `notas` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`),
  UNIQUE KEY `uq_sku_variante` (`producto_id`,`talla`,`color`),
  CONSTRAINT `fk_sku_producto` FOREIGN KEY (`producto_id`) REFERENCES `producto` (`id`),
  CONSTRAINT `ck_sku_estado` CHECK ((`estado` in (_utf8mb4'ACTIVO',_utf8mb4'DESCONTINUADO',_utf8mb4'BORRADOR')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sku`
--

LOCK TABLES `sku` WRITE;
/*!40000 ALTER TABLE `sku` DISABLE KEYS */;
INSERT INTO `sku` VALUES (1,'JNG-0001',1,'Medium','Black','ACTIVO',1200.00,NULL),(2,'JNG-0002',1,'Small','Black','ACTIVO',1200.00,NULL),(3,'JNG-0003',2,'Medium','Grey','ACTIVO',1800.00,NULL),(4,'JNG-0004',3,'Medium','Black','ACTIVO',1500.00,NULL);
/*!40000 ALTER TABLE `sku` ENABLE KEYS */;
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
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `socio`
--

LOCK TABLES `socio` WRITE;
/*!40000 ALTER TABLE `socio` DISABLE KEYS */;
INSERT INTO `socio` VALUES (1,'JJ',1),(2,'Agusto',1),(3,'Luise',1);
/*!40000 ALTER TABLE `socio` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_prenda`
--

LOCK TABLES `tipo_prenda` WRITE;
/*!40000 ALTER TABLE `tipo_prenda` DISABLE KEYS */;
INSERT INTO `tipo_prenda` VALUES (1,'Camiseta compresión',1),(2,'Camisa manga corta',1),(3,'Hoodie',1),(4,'Jogger',1),(5,'Sport bra',1),(6,'Legging',1),(7,'Short mujer',1),(8,'Chamarra',1);
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
 1 AS `disponible`*/;
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
  `notas` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `folio` (`folio`),
  KEY `fk_venta_canal` (`canal_id`),
  CONSTRAINT `fk_venta_canal` FOREIGN KEY (`canal_id`) REFERENCES `canal` (`id`),
  CONSTRAINT `ck_venta_estado` CHECK ((`estado` in (_utf8mb4'APARTADO',_utf8mb4'CERRADA',_utf8mb4'CANCELADO')))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,'V-001','2026-07-15',1,'Cliente ejemplo','CERRADA',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_linea`
--

LOCK TABLES `venta_linea` WRITE;
/*!40000 ALTER TABLE `venta_linea` DISABLE KEYS */;
INSERT INTO `venta_linea` VALUES (1,1,1,1,1200.00,0.00);
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
INSERT INTO `venta_rol` VALUES (1,1,1),(1,2,2);
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
/*!50001 VIEW `v_stock` AS select `sk`.`id` AS `sku_id`,`sk`.`codigo` AS `codigo`,`pr`.`nombre` AS `producto`,`sk`.`talla` AS `talla`,`sk`.`color` AS `color`,(coalesce(sum((case when (`m`.`tipo` in ('COMPRA','TRASLADO_ENTRADA','AJUSTE_MAS','DEVOLUCION')) then `m`.`cantidad` end)),0) - coalesce(sum((case when (`m`.`tipo` in ('VENTA','TRASLADO_SALIDA','AJUSTE_MENOS')) then `m`.`cantidad` end)),0)) AS `disponible` from ((`sku` `sk` join `producto` `pr` on((`pr`.`id` = `sk`.`producto_id`))) left join `movimiento` `m` on((`m`.`sku_id` = `sk`.`id`))) group by `sk`.`id`,`sk`.`codigo`,`pr`.`nombre`,`sk`.`talla`,`sk`.`color` */;
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

-- Dump completed on 2026-07-30 19:14:14
