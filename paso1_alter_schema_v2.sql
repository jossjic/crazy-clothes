-- =====================================================================
-- PASO 1: Modificaciones al esquema para Consolidados (v2)
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
  ADD COLUMN shipping_protection_usd DECIMAL(12,2)
    AFTER envio_usa_usd
    COMMENT 'Costo de protección de envío',

  ADD COLUMN adjustment_usd DECIMAL(12,2)
    AFTER impuestos_usd
    COMMENT 'Ajustes varios (positivos o negativos)',

  ADD COLUMN discount_already_applied BOOLEAN NOT NULL DEFAULT FALSE
    AFTER codigo_descuento
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
  ADD COLUMN guide_raw VARCHAR(120)
    AFTER guia
    COMMENT 'Guía completa sin limpiar, preserva prefijos como CASI',

  ADD COLUMN tracking_number VARCHAR(100)
    AFTER guide_raw
    COMMENT 'Número de tracking limpio, sin prefijos',

  ADD COLUMN fecha_envio DATE
    AFTER pedido_proveedor_id
    COMMENT 'Fecha de envío del paquete',

  ADD COLUMN largo_cm DECIMAL(10,2)
    AFTER ubicacion_id
    COMMENT 'Largo del paquete en centímetros',

  ADD COLUMN ancho_cm DECIMAL(10,2)
    AFTER largo_cm
    COMMENT 'Ancho del paquete en centímetros',

  ADD COLUMN alto_cm DECIMAL(10,2)
    AFTER ancho_cm
    COMMENT 'Alto del paquete en centímetros',

  ADD COLUMN peso_real_kg DECIMAL(10,4)
    AFTER alto_cm
    COMMENT 'Peso real del paquete en kilogramos',

  ADD COLUMN peso_volumetrico_kg DECIMAL(10,4)
    AFTER peso_real_kg
    COMMENT 'Peso volumétrico calculado (L×W×H/5000)';

-- NOTA: NO agregamos carrier VARCHAR(30) porque duplicaría paqueteria_id.
-- Usar solo paqueteria_id para evitar inconsistencias.

-- ---------------------------------------------------------------------
-- TABLA: pieza
-- Agregar color, talla y relación directa con pedido_proveedor
-- ---------------------------------------------------------------------

ALTER TABLE pieza
  ADD COLUMN color VARCHAR(60)
    AFTER descripcion
    COMMENT 'Color de la pieza (esencial para matching de SKU)',

  ADD COLUMN talla VARCHAR(30)
    AFTER color
    COMMENT 'Talla de la pieza (esencial para matching de SKU)',

  ADD COLUMN pedido_proveedor_id INT NULL
    AFTER paquete_id
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
    AFTER costo_mxn
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

-- =====================================================================
-- NOTAS DE DISEÑO IMPORTANTES
-- =====================================================================

-- 1. COSTOS EN PEDIDO, NO EN PAQUETE
--    Un pedido puede dividirse en múltiples paquetes sin duplicar costos.
--    Ejemplo: Pedido Gymshark $90 USD → 3 paquetes físicos
--    El total de $90 está en pedido_proveedor.total_usd, NO repetido 3 veces.

-- 2. DOBLE RELACIÓN DE PIEZA
--    - pieza.pedido_proveedor_id → origen financiero (qué se compró)
--    - pieza.paquete_id → contenedor físico (cómo llegó)
--    Una pieza puede existir desde la compra aunque no conozca su guía.
--    Durante la migración, pedido_proveedor_id puede ser NULL temporalmente.

-- 3. MATCHING DE SKUS
--    El índice ix_pieza_matching permite buscar eficientemente:
--    WHERE marca_id = ? AND tipo_prenda_id = ? AND talla = ? AND color LIKE ?
--    El orden es crucial para evitar matches incorrectos.

-- 4. NULL vs 0.00
--    - cruce.costo_mxn = NULL → pendiente de cálculo
--    - cruce.costo_mxn = 0.00 → calculado y efectivamente cero
--    Nunca confundir ausencia de dato con valor cero.

-- 5. PAQUETERIA_ID vs CARRIER
--    NO duplicamos el dato del carrier. Usar paqueteria_id (FK) para
--    mantener consistencia. Si el nombre en paqueteria no es suficiente,
--    agregar columnas a la tabla paqueteria, no a paquete.

-- =====================================================================
-- MIGRACIÓN GRADUAL DE RENOMBRADO (ejecutar después, no ahora)
-- =====================================================================

-- CUANDO estés listo para renombrar envio_usa_usd → envio_proveedor_usd:
--
-- 1. Buscar dependencias:
--    grep -R "envio_usa_usd" .
--
--    SELECT TABLE_NAME, VIEW_DEFINITION
--    FROM information_schema.VIEWS
--    WHERE VIEW_DEFINITION LIKE '%envio_usa_usd%';
--
--    SELECT ROUTINE_NAME
--    FROM information_schema.ROUTINES
--    WHERE ROUTINE_DEFINITION LIKE '%envio_usa_usd%';
--
-- 2. Agregar nueva columna:
--    ALTER TABLE pedido_proveedor
--    ADD COLUMN envio_proveedor_usd DECIMAL(12,2) NULL;
--
-- 3. Copiar datos:
--    UPDATE pedido_proveedor
--    SET envio_proveedor_usd = envio_usa_usd
--    WHERE envio_proveedor_usd IS NULL;
--
-- 4. Actualizar código, vistas, reportes para usar el nuevo nombre.
--
-- 5. Confirmar que no quedan referencias a envio_usa_usd.
--
-- 6. Eliminar columna antigua:
--    ALTER TABLE pedido_proveedor
--    DROP COLUMN envio_usa_usd;

-- =====================================================================
-- VALIDACIÓN POST-APLICACIÓN (ejecutar manualmente)
-- =====================================================================

-- Verificar columnas nuevas:
--   DESCRIBE pedido_proveedor;
--   DESCRIBE paquete;
--   DESCRIBE pieza;
--   DESCRIBE cruce;

-- Verificar índices:
--   SHOW INDEX FROM pieza;
--   SHOW INDEX FROM paquete;

-- Verificar integridad:
--   SELECT COUNT(*) FROM pieza WHERE color IS NULL;
--   SELECT COUNT(*) FROM pieza WHERE talla IS NULL;
--   SELECT COUNT(*) FROM pieza WHERE pedido_proveedor_id IS NULL;
--   SELECT COUNT(*) FROM paquete WHERE guide_raw IS NULL;
--   SELECT COUNT(*) FROM cruce WHERE costo_mxn IS NULL;

-- Listar piezas sin pedido asignado (para normalizar):
--   SELECT id, descripcion, destino, marca_id, tipo_prenda_id
--   FROM pieza
--   WHERE pedido_proveedor_id IS NULL
--   ORDER BY destino, marca_id;
