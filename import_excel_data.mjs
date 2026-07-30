import mysql from 'mysql2/promise';
import fs from 'fs';

const pool = mysql.createPool({
  host: 'localhost', port: 33306, user: 'root',
  password: 'test', database: 'cc'
});

const data = JSON.parse(fs.readFileSync('/tmp/crazy_clothes_data.json', 'utf8'));

console.log('\n📥 IMPORTANDO DATOS DEL EXCEL v2.5\n');
console.log('='.repeat(70));

// 1. Limpiar datos existentes
console.log('\n1️⃣  Limpiando datos previos...');
await pool.query('SET FOREIGN_KEY_CHECKS=0');
await pool.query('DELETE FROM venta_rol');
await pool.query('DELETE FROM venta_linea');
await pool.query('DELETE FROM venta');
await pool.query('DELETE FROM movimiento');
await pool.query('DELETE FROM pieza');
await pool.query('DELETE FROM paquete');
await pool.query('DELETE FROM cruce');
await pool.query('DELETE FROM sku');
await pool.query('DELETE FROM producto');
await pool.query('SET FOREIGN_KEY_CHECKS=1');
console.log('   ✅ Tablas limpias');

// 2. Extraer cruces únicos
const cruces = [...new Set(data.casi.map(g => g.folio_cruce).filter(Boolean))];
console.log(`\n2️⃣  Creando ${cruces.length} cruces...`);
const cruceIds = {};

for (const folio of cruces) {
  const [result] = await pool.query(`
    INSERT INTO cruce (folio, fecha, costo_mxn, notas)
    VALUES (?, '2026-01-01', 2000.00, 'Importado del Excel v2.5')
  `, [folio]);
  cruceIds[folio] = result.insertId;
  console.log(`   ${folio} → ID ${result.insertId}`);
}

// 3. Paqueterías
console.log(`\n3️⃣  Verificando paqueterías...`);
const paqueterias = [...new Set(data.casi.map(g => g.paqueteria).filter(Boolean))];
for (const paq of paqueterias) {
  await pool.query(`INSERT IGNORE INTO paqueteria (nombre, prefijo_guia) VALUES (?, NULL)`, [paq]);
}
console.log(`   ✅ ${paqueterias.size} paqueterías OK`);

// 4. Proveedores
console.log(`\n4️⃣  Verificando proveedores...`);
const proveedores = [...new Set(data.casi.map(g => g.proveedor).filter(Boolean))];
for (const prov of proveedores) {
  await pool.query(`INSERT IGNORE INTO proveedor (nombre, marca_id) VALUES (?, NULL)`, [prov]);
}
console.log(`   ✅ ${proveedores.length} proveedores OK`);

// 5. Paquetes
console.log(`\n5️⃣  Creando ${data.casi.length} paquetes...`);
const paqueteIds = {};

for (const g of data.casi) {
  const [paq] = await pool.query('SELECT id FROM paqueteria WHERE nombre=?', [g.paqueteria]);
  const paqId = paq.length > 0 ? paq[0].id : null;
  const cruceId = g.folio_cruce ? cruceIds[g.folio_cruce] : null;
  let fecha = null;
  if (g.fecha_llegada && g.fecha_llegada.includes('-')) {
    fecha = g.fecha_llegada.split(' ')[0];
  }
  
  const [result] = await pool.query(`
    INSERT INTO paquete (guia, paqueteria_id, cruce_id, fecha_llegada, estado, notas)
    VALUES (?, ?, ?, ?, 'RECIBIDO', ?)
  `, [g.guia, paqId, cruceId, fecha, `Prov: ${g.proveedor || 'N/A'}, %Neg: ${g.pct_negocio || 'N/A'}`]);
  
  paqueteIds[g.guia] = result.insertId;
}
console.log(`   ✅ ${data.casi.length} paquetes creados`);

// 6. Productos y SKUs
console.log(`\n6️⃣  Creando productos y SKUs...`);

const [marcas] = await pool.query('SELECT id, nombre FROM marca');
const marcaMap = {};
for (const m of marcas) marcaMap[m.nombre] = m.id;

const [tipos] = await pool.query('SELECT id, nombre FROM tipo_prenda');
const tipoMap = {};
for (const t of tipos) tipoMap[t.nombre] = t.id;

// Agrupar por producto
const productosUnicos = {};
for (const sku of data.inventario) {
  const key = `${sku.marca}|${sku.producto}|${sku.tipo}`;
  if (!productosUnicos[key]) {
    productosUnicos[key] = {
      marca: sku.marca,
      producto: sku.producto,
      tipo: sku.tipo,
      codigo_prov: sku.codigo_prov,
      skus: []
    };
  }
  productosUnicos[key].skus.push(sku);
}

let skusCreados = 0;
for (const prod of Object.values(productosUnicos)) {
  let marcaId = marcaMap[prod.marca];
  if (!marcaId) {
    const [r] = await pool.query('INSERT INTO marca (nombre) VALUES (?)', [prod.marca]);
    marcaId = r.insertId;
    marcaMap[prod.marca] = marcaId;
  }
  
  let tipoId = tipoMap[prod.tipo];
  if (!tipoId) {
    const [r] = await pool.query('INSERT INTO tipo_prenda (nombre, es_prenda) VALUES (?, 1)', [prod.tipo]);
    tipoId = r.insertId;
    tipoMap[prod.tipo] = tipoId;
  }
  
  const [prodResult] = await pool.query(`
    INSERT INTO producto (marca_id, tipo_prenda_id, nombre, codigo_proveedor)
    VALUES (?, ?, ?, ?)
  `, [marcaId, tipoId, prod.producto, prod.codigo_prov]);
  
  const productoId = prodResult.insertId;
  
  for (const sku of prod.skus) {
    await pool.query(`
      INSERT INTO sku (codigo, producto_id, talla, color, estado, precio_lista_mxn)
      VALUES (?, ?, ?, ?, ?, NULL)
    `, [sku.sku, productoId, sku.talla, sku.color, sku.estado]);
    skusCreados++;
  }
}

console.log(`   ✅ ${Object.keys(productosUnicos).length} productos, ${skusCreados} SKUs`);

// 7. Movimientos
console.log(`\n7️⃣  Creando ${data.movimientos.length} movimientos...`);

const [ubicaciones] = await pool.query('SELECT id, nombre FROM ubicacion');
const ubMap = {};
for (const u of ubicaciones) ubMap[u.nombre] = u.id;

let movsCreados = 0;
for (const mov of data.movimientos) {
  const [skuRow] = await pool.query('SELECT id FROM sku WHERE codigo=?', [mov.sku]);
  if (skuRow.length === 0) continue;
  
  const ubDestinoId = ubMap[mov.ub_destino] || ubMap['Puebla'];
  let fecha = '2026-01-01';
  if (mov.fecha && mov.fecha.includes('-')) fecha = mov.fecha.split(' ')[0];
  
  await pool.query(`
    INSERT INTO movimiento (fecha, sku_id, tipo, cantidad, ubicacion_destino_id, notas)
    VALUES (?, ?, 'COMPRA', ?, ?, ?)
  `, [fecha, skuRow[0].id, mov.cantidad, ubDestinoId, mov.notas]);
  movsCreados++;
}

console.log(`   ✅ ${movsCreados} movimientos creados`);

// Resumen
console.log('\n' + '='.repeat(70));
console.log('\n✅ IMPORTACIÓN COMPLETA\n');

const [r] = await pool.query(`
  SELECT 
    (SELECT COUNT(*) FROM cruce) as cruces,
    (SELECT COUNT(*) FROM paquete) as paquetes,
    (SELECT COUNT(*) FROM producto) as productos,
    (SELECT COUNT(*) FROM sku) as skus,
    (SELECT COUNT(*) FROM movimiento) as movimientos
`);

console.log(`📊 Resumen:`);
console.log(`   Cruces: ${r[0].cruces}`);
console.log(`   Paquetes: ${r[0].paquetes}`);
console.log(`   Productos: ${r[0].productos}`);
console.log(`   SKUs: ${r[0].skus}`);
console.log(`   Movimientos: ${r[0].movimientos}`);

const [stock] = await pool.query(`
  SELECT p.nombre, s.talla, s.color, vs.disponible
  FROM v_stock vs
  JOIN sku s ON vs.sku_id = s.id
  JOIN producto p ON s.producto_id = p.id
  WHERE vs.disponible > 0
  ORDER BY vs.disponible DESC
  LIMIT 15
`);

console.log(`\n📦 SKUs con stock (top 15):`);
for (const s of stock) {
  console.log(`   ${s.nombre.substring(0,35).padEnd(35)} | ${s.talla.padEnd(7)} ${s.color.substring(0,18).padEnd(18)} | ${s.disponible} unid`);
}

console.log('\n🌐 Ver en: http://localhost:3939\n');
await pool.end();
