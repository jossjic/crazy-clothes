import mysql from 'mysql2/promise';
import fs from 'fs';

const pool = mysql.createPool({
  host: 'localhost', port: 33306, user: 'root',
  password: 'test', database: 'cc'
});

const ventasData = JSON.parse(fs.readFileSync('/tmp/ventas_completas.json', 'utf8'));

console.log('\n💰 RE-IMPORTANDO VENTAS CON DATOS CORRECTOS\n');
console.log('='.repeat(70));

// Limpiar ventas previas
await pool.query('SET FOREIGN_KEY_CHECKS=0');
await pool.query('DELETE FROM venta_rol');
await pool.query('DELETE FROM venta_linea');
await pool.query('DELETE FROM venta WHERE id > 0');
await pool.query('DELETE FROM movimiento WHERE tipo="VENTA"');
await pool.query('SET FOREIGN_KEY_CHECKS=1');

// Crear canales si no existen
const canalMap = {};
for (const v of ventasData) {
  if (v.canal && !canalMap[v.canal]) {
    await pool.query('INSERT IGNORE INTO canal (nombre) VALUES (?)', [v.canal]);
  }
}

const [canales] = await pool.query('SELECT id, nombre FROM canal');
for (const c of canales) canalMap[c.nombre] = c.id;

const [ubicaciones] = await pool.query('SELECT id, nombre FROM ubicacion');
const ubMap = {};
for (const u of ubicaciones) ubMap[u.nombre] = u.id;

const [socios] = await pool.query('SELECT id, nombre FROM socio');
const socioMap = {};
for (const s of socios) socioMap[s.nombre] = s.id;

// Agrupar por ID de venta
const ventasPorId = {};
for (const v of ventasData) {
  if (!ventasPorId[v.id_venta]) ventasPorId[v.id_venta] = [];
  ventasPorId[v.id_venta].push(v);
}

console.log(`\nProcesando ${Object.keys(ventasPorId).length} ventas...\n`);

let ventasCreadas = 0;
let lineasCreadas = 0;

for (const [vid, lineas] of Object.entries(ventasPorId)) {
  const primeraLinea = lineas[0];
  
  let fecha = '2026-01-01';
  if (primeraLinea.fecha && primeraLinea.fecha.includes('-')) {
    fecha = primeraLinea.fecha.split(' ')[0];
  }
  
  // Canal correcto del Excel
  const canalNombre = primeraLinea.canal || 'Instagram';
  const canalId = canalMap[canalNombre] || canalMap['Instagram'] || 1;
  
  // Cliente correcto del Excel
  const cliente = primeraLinea.cliente || `Cliente V-${vid}`;
  
  // Crear venta
  const [resultVenta] = await pool.query(`
    INSERT INTO venta (folio, fecha, canal_id, cliente, estado)
    VALUES (?, ?, ?, ?, 'CERRADA')
  `, [`V-${vid}`, fecha, canalId, cliente]);
  
  const ventaId = resultVenta.insertId;
  ventasCreadas++;
  
  console.log(`✅ V-${vid.toString().padEnd(3)} | ${fecha} | ${(cliente || '').substring(0,25).padEnd(25)} | ${canalNombre.padEnd(10)} | $${primeraLinea.venta_total || 0}`);
  
  // Crear líneas de venta
  for (const linea of lineas) {
    const [skuRow] = await pool.query('SELECT id FROM sku WHERE codigo=?', [linea.sku]);
    if (skuRow.length === 0) {
      console.log(`   ⚠️  SKU ${linea.sku} no encontrado`);
      continue;
    }
    const skuId = skuRow[0].id;
    
    await pool.query(`
      INSERT INTO venta_linea (venta_id, sku_id, cantidad, precio_unitario_mxn, descuento_mxn)
      VALUES (?, ?, ?, ?, 0)
    `, [ventaId, skuId, linea.cantidad, linea.precio_unitario]);
    
    lineasCreadas++;
    
    // Crear movimiento VENTA
    await pool.query(`
      INSERT INTO movimiento (fecha, sku_id, tipo, cantidad, venta_id, notas)
      VALUES (?, ?, 'VENTA', ?, ?, ?)
    `, [fecha, skuId, linea.cantidad, ventaId, `Venta V-${vid}`]);
  }
  
  // Crear roles
  const [roles] = await pool.query('SELECT id, nombre FROM rol_venta');
  const rolMap = {};
  for (const r of roles) rolMap[r.nombre.toUpperCase()] = r.id;
  
  if (primeraLinea.vendedor && socioMap[primeraLinea.vendedor]) {
    const rolId = rolMap['NEGOCIADOR'] || 1;
    await pool.query(`
      INSERT INTO venta_rol (venta_id, rol_venta_id, socio_id)
      VALUES (?, ?, ?)
    `, [ventaId, rolId, socioMap[primeraLinea.vendedor]]);
  }
  
  if (primeraLinea.repartidor && socioMap[primeraLinea.repartidor]) {
    const rolId = rolMap['ENTREGA'] || 2;
    await pool.query(`
      INSERT INTO venta_rol (venta_id, rol_venta_id, socio_id)
      VALUES (?, ?, ?)
    `, [ventaId, rolId, socioMap[primeraLinea.repartidor]]);
  }
}

// Verificar total
const [[total]] = await pool.query(`
  SELECT COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn - vl.descuento_mxn), 0) as total
  FROM venta_linea vl
`);

console.log(`\n${'='.repeat(70)}`);
console.log(`\n✅ IMPORTACIÓN COMPLETA:`);
console.log(`   ${ventasCreadas} ventas`);
console.log(`   ${lineasCreadas} líneas de venta`);
console.log(`   💰 TOTAL: $${parseFloat(total.total).toLocaleString('es-MX', {minimumFractionDigits: 2})} MXN`);
console.log(`\n`);

await pool.end();
