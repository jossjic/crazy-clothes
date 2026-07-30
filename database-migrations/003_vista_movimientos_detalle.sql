-- Migración 003: Vista detallada de movimientos con valores
-- Fecha: 2026-07-30

-- Vista de movimientos detallados línea por línea
CREATE OR REPLACE VIEW v_movimientos_detalle AS
SELECT
    mov.id AS movimiento_id,
    mov.fecha,
    mov.tipo,
    s.codigo AS sku_codigo,
    pr.nombre AS producto,
    m.nombre AS marca,
    s.talla,
    s.color,
    mov.cantidad,
    -- Valor del movimiento
    CASE
        WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS') THEN
            COALESCE(pz.costo_usd, 0) * mov.cantidad
        WHEN mov.tipo = 'VENTA' THEN
            COALESCE(vl.precio_unitario_mxn, s.precio_lista_mxn, 0) * mov.cantidad
        ELSE 0
    END AS valor,
    CASE
        WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS') THEN 'USD'
        WHEN mov.tipo = 'VENTA' THEN 'MXN'
        ELSE NULL
    END AS moneda,
    -- Referencias
    mov.venta_id,
    v.folio AS venta_folio,
    mov.pieza_id,
    pz.descripcion AS pieza_descripcion,
    pq.guia AS paquete_guia,
    c.folio AS cruce_folio,
    -- Categorización
    CASE
        WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS', 'DEVOLUCION', 'TRASLADO_ENTRADA') THEN 'ENTRADA'
        WHEN mov.tipo IN ('VENTA', 'AJUSTE_MENOS', 'TRASLADO_SALIDA') THEN 'SALIDA'
        ELSE 'OTRO'
    END AS categoria,
    mov.notas
FROM movimiento mov
JOIN sku s ON s.id = mov.sku_id
JOIN producto pr ON pr.id = s.producto_id
JOIN marca m ON m.id = pr.marca_id
LEFT JOIN pieza pz ON pz.id = mov.pieza_id
LEFT JOIN paquete pq ON pq.id = pz.paquete_id
LEFT JOIN cruce c ON c.id = pq.cruce_id
LEFT JOIN venta v ON v.id = mov.venta_id
LEFT JOIN venta_linea vl ON vl.venta_id = v.id AND vl.sku_id = s.id
ORDER BY mov.fecha DESC, mov.id DESC;

-- Vista resumen por SKU con valores totales
CREATE OR REPLACE VIEW v_movimientos_sku_valores AS
SELECT
    s.id AS sku_id,
    s.codigo,
    pr.nombre AS producto,
    m.nombre AS marca,
    s.talla,
    s.color,
    -- Cantidades
    COALESCE(SUM(CASE WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS', 'DEVOLUCION') THEN mov.cantidad ELSE 0 END), 0) AS total_entradas,
    COALESCE(SUM(CASE WHEN mov.tipo IN ('VENTA', 'AJUSTE_MENOS') THEN mov.cantidad ELSE 0 END), 0) AS total_salidas,
    -- Valores
    COALESCE(SUM(CASE WHEN mov.tipo IN ('COMPRA', 'INICIAL', 'AJUSTE_MAS') THEN pz.costo_usd * mov.cantidad ELSE 0 END), 0) AS costo_total_usd,
    COALESCE(SUM(CASE WHEN mov.tipo = 'VENTA' THEN vl.precio_unitario_mxn * mov.cantidad ELSE 0 END), 0) AS venta_total_mxn,
    -- Stock
    vs.disponible,
    vs.reservado,
    -- Estado
    CASE
        WHEN vs.disponible > 0 THEN 'Disponible'
        WHEN vs.disponible = 0 THEN 'Sin stock'
        WHEN vs.disponible < 0 THEN 'Stock negativo'
    END AS estado_stock,
    -- Precio lista
    s.precio_lista_mxn
FROM sku s
JOIN producto pr ON pr.id = s.producto_id
JOIN marca m ON m.id = pr.marca_id
LEFT JOIN movimiento mov ON mov.sku_id = s.id
LEFT JOIN pieza pz ON pz.id = mov.pieza_id
LEFT JOIN venta_linea vl ON vl.sku_id = s.id
LEFT JOIN v_stock vs ON vs.sku_id = s.id
GROUP BY s.id, s.codigo, pr.nombre, m.nombre, s.talla, s.color,
         vs.disponible, vs.reservado, s.precio_lista_mxn
ORDER BY m.nombre, pr.nombre, s.talla, s.color;
