-- =====================================================================
-- PASO 1: Modificaciones al esquema para Consolidados (v2 - FIXED)
-- Fecha: 2026-07-30
--
-- Jerarquía correcta:
--   pedido_proveedor (transacción financiera)
--     └─> paquete (caja física con guía)
--           └─> pieza (item individual)
--
-- Los costos financieros viven en pedido_proveedor, NO en paquete.
-- Un pedido puede dividirse en múltiples paquetes sin duplicar costos.
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- TABLA: pedido_proveedor
-- Completar campos financieros faltantes
-- ---------------------------------------------------------------------

ALTER TABLE pedido_proveedor
  ADD COLUMN shipping_protection_usd DECIMAL(12,2) COMMENT 'Costo de protección de envío';

ALTER TABLE pedido_proveedor
  ADD COLUMN adjustment_usd DECIMAL(12,2) COMMENT 'Ajustes varios (positivos o negativos)';

ALTER TABLE pedido_proveedor
  ADD COLUMN discount_already_applied BOOLEAN NOT NULL DEFAULT FALSE
    COMMENT 'Si el descuento ya está aplicado en subtotal_usd';

-- NOTA: NO renombramos envio_usa_usd → envio_proveedor_usd todavía.
-- Requiere búsqueda de dependencias (vistas, código, reportes) antes de
-- hacer la migración gradual. Ver sección de migración al final.

-- ---------------------------------------------------------------------
-- TABLA: paquete
-- Agregar SOLO datos logísticos (tracking, dimensiones, pesos)
-- NO agregar costos financieros (esos van en pedido_proveedor)
-- ---------------------------------------------------------------------

ALTER TABLE paquete
  ADD COLUMN guide_raw VARCHAR(120) COMMENT 'Guía completa sin limpiar, preserva prefijos como CASI';

ALTER TABLE paquete
  ADD COLUMN tracking_number VARCHAR(100) COMMENT 'Número de tracking limpio, sin prefijos';

ALTER TABLE paquete
  ADD COLUMN fecha_envio DATE COMMENT 'Fecha de envío del paquete';

ALTER TABLE paquete
  ADD COLUMN largo_cm DECIMAL(10,2) COMMENT 'Largo del paquete en centímetros';

ALTER TABLE paquete
  ADD COLUMN ancho_cm DECIMAL(10,2) COMMENT 'Ancho del paquete en centímetros';

ALTER TABLE paquete
  ADD COLUMN alto_cm DECIMAL(10,2) COMMENT 'Alto del paquete en centímetros';

ALTER TABLE paquete
  ADD COLUMN peso_real_kg DECIMAL(10,4) COMMENT 'Peso real del paquete en kilogramos';

ALTER TABLE paquete
  ADD COLUMN peso_volumetrico_kg DECIMAL(10,4) COMMENT 'Peso volumétrico calculado (L×W×H/5000)';

-- ---------------------------------------------------------------------
-- TABLA: pieza
-- Agregar color, talla y relación directa con pedido_proveedor
-- ---------------------------------------------------------------------

ALTER TABLE pieza
  ADD COLUMN color VARCHAR(60) COMMENT 'Color de la pieza (esencial para matching de SKU)';

ALTER TABLE pieza
  ADD COLUMN talla VARCHAR(30) COMMENT 'Talla de la pieza (esencial para matching de SKU)';

ALTER TABLE pieza
  ADD COLUMN pedido_proveedor_id INT NULL
    COMMENT 'Origen financiero. NULL solo durante migración de históricos';

-- IMPORTANTE: pedido_proveedor_id es NULL solo temporalmente (migración).
-- Una vez normalizados los históricos, migrar a NOT NULL:
--   ALTER TABLE pieza MODIFY pedido_proveedor_id INT NOT NULL;
--
-- Validar piezas sin asignar:
--   SELECT id, descripcion, destino
--   FROM pieza
--   WHERE pedido_proveedor_id IS NULL;

-- Agregar FK para pedido_proveedor_id
ALTER TABLE pieza
  ADD CONSTRAINT fk_pieza_pedido
    FOREIGN KEY (pedido_proveedor_id)
    REFERENCES pedido_proveedor(id);

-- ---------------------------------------------------------------------
-- TABLA: cruce
-- Permitir NULL en costo_mxn (pendiente ≠ 0.00)
-- Agregar tipo de cambio del cruce
-- ---------------------------------------------------------------------

ALTER TABLE cruce
  MODIFY COLUMN costo_mxn DECIMAL(12,2) NULL
    COMMENT 'NULL = pendiente de cálculo, no confundir con 0.00';

ALTER TABLE cruce
  ADD COLUMN exchange_rate_usd_mxn DECIMAL(10,4)
    COMMENT 'Tipo de cambio USD→MXN usado en este cruce';

-- ---------------------------------------------------------------------
-- Índices para optimizar consultas
-- ---------------------------------------------------------------------

-- Tracking de paquetes
CREATE INDEX ix_paquete_tracking ON paquete(tracking_number);

-- Búsquedas individuales de color y talla
CREATE INDEX ix_pieza_color ON pieza(color);
CREATE INDEX ix_pieza_talla ON pieza(talla);

-- Índice compuesto para matching de SKUs
-- Orden: marca → tipo → talla → color (orden lógico de filtrado)
-- Evita matches absurdos como "chamarra gris" con "sports bra gris"
CREATE INDEX ix_pieza_matching ON pieza(
    marca_id,
    tipo_prenda_id,
    talla,
    color
);

-- Relación pieza → pedido (para rastrear origen financiero)
CREATE INDEX ix_pieza_pedido ON pieza(pedido_proveedor_id);
