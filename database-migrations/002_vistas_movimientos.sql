-- Migración 002: Vistas para dashboard de movimientos y compras
-- Fecha: 2026-07-30

-- Vista 1: Resumen de movimientos por SKU
-- Muestra todo lo que se compró y vendió por cada SKU
CREATE OR REPLACE VIEW v_movimientos_sku AS
SELECT
    s.id AS sku_id,
    s.codigo,
    pr.nombre AS producto,
    m.nombre AS marca,
    tp.nombre AS tipo_prenda,
    s.talla,
    s.color,
    -- Movimientos
    COALESCE(SUM(CASE WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS', 'DEVOLUCION') THEN mov.cantidad ELSE 0 END), 0) AS total_entradas,
    COALESCE(SUM(CASE WHEN mov.tipo IN ('VENTA', 'AJUSTE_MENOS') THEN mov.cantidad ELSE 0 END), 0) AS total_salidas,
    -- Stock actual
    vs.disponible,
    vs.reservado,
    -- Conteo de piezas vinculadas
    (SELECT COUNT(*) FROM pieza pz WHERE pz.sku_id = s.id) AS piezas_vinculadas,
    -- Info adicional
    s.precio_lista_mxn,
    CASE
        WHEN vs.disponible > 0 THEN 'Disponible'
        WHEN vs.disponible = 0 THEN 'Sin stock'
        WHEN vs.disponible < 0 THEN 'Stock negativo'
    END AS estado_stock
FROM sku s
JOIN producto pr ON pr.id = s.producto_id
JOIN marca m ON m.id = pr.marca_id
JOIN tipo_prenda tp ON tp.id = pr.tipo_prenda_id
LEFT JOIN movimiento mov ON mov.sku_id = s.id
LEFT JOIN v_stock vs ON vs.sku_id = s.id
GROUP BY s.id, s.codigo, pr.nombre, m.nombre, tp.nombre, s.talla, s.color,
         vs.disponible, vs.reservado, s.precio_lista_mxn
ORDER BY m.nombre, pr.nombre, s.talla, s.color;

-- Vista 2: Piezas NEGOCIO sin SKU asignado
-- Muestra todo lo que falta por catalogar en inventario
CREATE OR REPLACE VIEW v_piezas_sin_sku AS
SELECT
    pz.id AS pieza_id,
    pq.guia,
    c.folio AS cruce,
    pz.descripcion,
    m.nombre AS marca,
    tp.nombre AS tipo_prenda,
    pz.cantidad,
    pz.costo_usd,
    pz.destino,
    CASE
        WHEN pz.notas LIKE '%PÉRDIDA%' OR pz.notas LIKE '%PERDIDA%' THEN 'Pérdida operativa'
        ELSE 'Pendiente catalogar'
    END AS estado,
    pz.notas,
    pq.fecha_llegada,
    paqr.nombre AS paqueteria
FROM pieza pz
JOIN paquete pq ON pq.id = pz.paquete_id
LEFT JOIN cruce c ON c.id = pq.cruce_id
JOIN marca m ON m.id = pz.marca_id
JOIN tipo_prenda tp ON tp.id = pz.tipo_prenda_id
LEFT JOIN paqueteria paqr ON paqr.id = pq.paqueteria_id
WHERE pz.destino = 'NEGOCIO' AND pz.sku_id IS NULL
ORDER BY
    CASE WHEN pz.notas LIKE '%PÉRDIDA%' OR pz.notas LIKE '%PERDIDA%' THEN 1 ELSE 0 END,
    c.folio DESC, pq.guia;

-- Vista 3: Dashboard general de inventario
-- Combina ambas vistas para tener una visión completa
CREATE OR REPLACE VIEW v_dashboard_inventario AS
SELECT
    'CON_SKU' AS tipo,
    codigo AS identificador,
    producto AS nombre,
    marca,
    tipo_prenda,
    talla,
    color,
    total_entradas AS entradas,
    total_salidas AS salidas,
    disponible,
    piezas_vinculadas,
    estado_stock AS estado,
    NULL AS notas
FROM v_movimientos_sku
UNION ALL
SELECT
    'SIN_SKU' AS tipo,
    guia AS identificador,
    descripcion AS nombre,
    marca,
    tipo_prenda,
    NULL AS talla,
    NULL AS color,
    NULL AS entradas,
    NULL AS salidas,
    cantidad AS disponible,
    NULL AS piezas_vinculadas,
    estado,
    notas
FROM v_piezas_sin_sku
ORDER BY tipo DESC, marca, nombre;
