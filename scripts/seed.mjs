import mysql from 'mysql2/promise'

const conn = await mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 33306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'test',
  database: process.env.DB_NAME || 'cc',
  charset: 'utf8mb4',
})

console.log('🌱 Seeding database...')

await conn.execute('SET NAMES utf8mb4')

// Catálogos
await conn.execute(`INSERT IGNORE INTO socio (id, nombre) VALUES (1,'JJ'),(2,'Agusto'),(3,'Luise')`)
await conn.execute(`INSERT IGNORE INTO marca (id, nombre) VALUES (1,'YoungLA'),(2,'Gymshark'),(3,'YoungLA / ONYX')`)
await conn.execute(`INSERT IGNORE INTO tipo_prenda (id, nombre, es_prenda) VALUES
  (1,'Camiseta compresión',1),(2,'Camisa manga corta',1),(3,'Hoodie',1),(4,'Jogger',1),
  (5,'Sport bra',1),(6,'Legging',1),(7,'Short mujer',1),(8,'Chamarra',1)`)
await conn.execute(`INSERT IGNORE INTO ubicacion (id, nombre) VALUES (1,'Puebla'),(2,'CDMX')`)
await conn.execute(`INSERT IGNORE INTO paqueteria (id, nombre, prefijo_guia) VALUES (1,'UPS','1Z'),(2,'USPS','420'),(3,'FedEx','38')`)
await conn.execute(`INSERT IGNORE INTO proveedor (id, nombre, marca_id) VALUES (1,'YoungLA',1),(2,'Gymshark',2)`)
await conn.execute(`INSERT IGNORE INTO canal (id, nombre) VALUES (1,'Instagram'),(2,'WhatsApp'),(3,'Presencial')`)
await conn.execute(`INSERT IGNORE INTO rol_venta (id, nombre) VALUES (1,'NEGOCIADOR'),(2,'ENTREGA')`)
await conn.execute(`INSERT IGNORE INTO comision_tarifa (rol_venta_id, pct, vigente_desde) VALUES (1, 0.08, '2026-01-01'),(2, 0.05, '2026-01-01')`)

// Factores volumétricos
await conn.execute(`INSERT IGNORE INTO factor_volumetrico (marca_id, tipo_prenda_id, factor) VALUES
  (1,2,0.9),(1,1,1.0),(1,4,1.8),(1,3,2.5),(1,8,2.8),
  (3,1,0.6),(3,3,1.0),
  (2,5,0.4),(2,7,0.6),(2,6,1.0),(2,4,1.8),(2,3,2.5)`)

// Productos y SKUs de ejemplo
await conn.execute(`INSERT IGNORE INTO producto (id, marca_id, tipo_prenda_id, nombre, codigo_proveedor) VALUES
  (1, 1, 1, 'Batman Compression Tees', '4286'),
  (2, 2, 3, 'CBUM Washed Hoodie', NULL),
  (3, 2, 4, 'CBUM Straight Leg Jogger', NULL)`)

await conn.execute(`INSERT IGNORE INTO sku (id, codigo, producto_id, talla, color, precio_lista_mxn) VALUES
  (1, 'JNG-0001', 1, 'Medium', 'Black', 1200.00),
  (2, 'JNG-0002', 1, 'Small', 'Black', 1200.00),
  (3, 'JNG-0003', 2, 'Medium', 'Grey', 1800.00),
  (4, 'JNG-0004', 3, 'Medium', 'Black', 1500.00)`)

// Un cruce con paquetes y piezas
await conn.execute(`INSERT IGNORE INTO cruce (id, folio, fecha, costo_mxn) VALUES (1, 'CONS9962926323', '2026-07-08', 2000)`)
await conn.execute(`INSERT IGNORE INTO paquete (id, guia, paqueteria_id, cruce_id, fecha_llegada, ubicacion_id) VALUES
  (1, '1Z08X89A0301650873', 1, 1, '2026-07-10', 1)`)
await conn.execute(`INSERT IGNORE INTO pieza (paquete_id, descripcion, marca_id, tipo_prenda_id, destino, sku_id, cantidad, costo_usd) VALUES
  (1, 'Batman Compression Tees Black Medium', 1, 1, 'NEGOCIO', 1, 2, 48.00),
  (1, 'Batman Compression Tees Black Small', 1, 1, 'NEGOCIO', 2, 1, 48.00)`)

// Movimientos COMPRA para meter stock
await conn.execute(`INSERT IGNORE INTO movimiento (fecha, sku_id, tipo, cantidad, ubicacion_destino_id, pieza_id, notas) VALUES
  ('2026-07-10', 1, 'COMPRA', 2, 1, 1, 'Seed'),
  ('2026-07-10', 2, 'COMPRA', 1, 1, 2, 'Seed')`)

// Una venta de ejemplo
await conn.execute(`INSERT IGNORE INTO venta (id, folio, fecha, canal_id, cliente, estado) VALUES
  (1, 'V-001', '2026-07-15', 1, 'Cliente ejemplo', 'CERRADA')`)
await conn.execute(`INSERT IGNORE INTO venta_linea (venta_id, sku_id, cantidad, precio_unitario_mxn, descuento_mxn) VALUES
  (1, 1, 1, 1200.00, 0)`)
await conn.execute(`INSERT IGNORE INTO venta_rol (venta_id, rol_venta_id, socio_id) VALUES (1, 1, 1),(1, 2, 2)`)
await conn.execute(`INSERT IGNORE INTO movimiento (fecha, sku_id, tipo, cantidad, venta_id, notas) VALUES
  ('2026-07-15', 1, 'VENTA', 1, 1, 'Venta V-001')`)

await conn.end()
console.log('✅ Seed complete')
