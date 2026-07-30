import mysql from 'mysql2/promise';
import fs from 'fs';

const pool = mysql.createPool({
  host: 'localhost', port: 33306, user: 'root',
  password: 'test', database: 'cc'
});

const ventasData = JSON.parse(fs.readFileSync('/tmp/ventas_excel.json', 'utf8'));

console.log('\n💰 IMPORTANDO VENTAS DEL EXCEL\n');
console.log('='.repeat(70));

// Limpiar ventas previas
await pool.query('SET FOREIGN_KEY_CHECKS=0');
await pool.query('DELETE FROM venta_rol');
await pool.query('DELETE FROM venta_linea');
await pool.query('DELETE FROM venta WHERE id > 0');
await pool.query('DELETE FROM movimiento WHERE tipo="VENTA"');
await pool.query('SET FOREIGN_KEY_CHECKS=1');

// Obtener IDs necesarios
const [canales] = await pool.query('SELECT id, nombre FROM canal');
const canalMap = {};
for (const c of canales) canalMap[c.nombre] = c.id;

const [ubicaciones] = await pool.query('SELECT id, nombre FROM ubicacion');
const ubMap = {};
for (const u of ubicaciones) ubMap[u.nombre] = u.id;

// Crear socios si no existen
await pool.query(`INSERT IGNORE INTO socio (nombre, activo) VALUES ('JJ', 1), ('Agusto', 1), ('Luise', 1)`);

const [socios] = await pool.query('SELECT id, nombre FROM socio');
const socioMap = {};
for (const s of socios) socioMap[s.nombre] = s.id;

// Agrupar por ID de venta
const ventasPorId = {};
for (const v of ventasData) {
  const vid = v.id_venta;
  if (!ventasPorId[vid]) {
    ventasPorId[vid] = [];
  }
  ventasPorId[vid].push(v);
}

console.log(`\n1️⃣  Procesando ${Object.keys(ventasPorId).length} ventas...\n`);

let ventasCreadas = 0;
let lineasCreadas = 0;
let movimientosCreados = 0;

for (const [vid, lineas] of Object.entries(ventasPorId)) {
  const primeraLinea = lineas[0];
  
  // Fecha
  let fecha = '2026-01-01';
  if (primeraLinea.fecha && primeraLinea.fecha.includes('-')) {
    fecha = primeraLinea.fecha.split(' ')[0];
  }
  
  // Canal
  const canalNombre = primeraLinea.canal || 'Instagram';
  const canalId = canalMap[canalNombre] || canalMap['Instagram'] || 1;
  
  // Cliente (de la columna 22 si existe, sino "Cliente V-X")
  const cliente = primeraLinea.cliente || `Cliente V-${vid}`;
  
  // Crear venta
  const [resultVenta] = await pool.query(`
    INSERT INTO venta (folio, fecha, canal_id, cliente, estado)
    VALUES (?, ?, ?, ?, 'CERRADA')
  `, [`V-${vid}`, fecha, canalId, cliente]);
  
  const ventaId = resultVenta.insertId;
  ventasCreadas++;
  
  // Crear líneas de venta
  for (const linea of lineas) {
    // Buscar SKU
    const [skuRow] = await pool.query('SELECT id FROM sku WHERE codigo=?', [linea.sku]);
    if (skuRow.length === 0) {
      console.log(`   ⚠️  SKU ${linea.sku} no encontrado, saltando`);
      continue;
    }
    const skuId = skuRow[0].id;
    
    // Crear línea
    await pool.query(`
      INSERT INTO venta_linea (venta_id, sku_id, cantidad, precio_unitario_mxn, descuento_mxn)
      VALUES (?, ?, ?, ?, 0)
    `, [ventaId, skuId, linea.cantidad, linea.precio_unitario]);
    
    lineasCreadas++;
    
    // Crear movimiento VENTA (resta stock)
    await pool.query(`
      INSERT INTO movimiento (fecha, sku_id, tipo, cantidad, venta_id, notas)
      VALUES (?, ?, 'VENTA', ?, ?, ?)
    `, [fecha, skuId, linea.cantidad, ventaId, `Venta ${linea.folio || 'V-'+vid}`]);
    
    movimientosCreados++;
  }
  
  // Crear roles si hay vendedor/repartidor
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
  
  console.log(`   V-${vid.toString().padEnd(3)} | ${fecha} | ${cliente.substring(0,25).padEnd(25)} | ${lineas.length} línea(s)`);
}

console.log(`\n✅ Importación completa:`);
console.log(`   ${ventasCreadas} ventas`);
console.log(`   ${lineasCreadas} líneas de venta`);
console.log(`   ${movimientosCreados} movimientos VENTA`);

// Stock actualizado
const [stock] = await pool.query(`
  SELECT COUNT(*) as total, SUM(disponible) as unidades
  FROM v_stock
  WHERE disponible > 0
`);

console.log(`\n📦 Stock después de ventas:`);
console.log(`   ${stock[0].total} SKUs con stock`);
console.log(`   ${stock[0].unidades} unidades totales`);

console.log('\n');
await pool.end();
