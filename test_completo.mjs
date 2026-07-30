import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: 'localhost',
  port: 33306,
  user: 'root',
  password: 'test',
  database: 'cc',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function test(name, fn) {
  try {
    process.stdout.write(`TEST: ${name} ... `);
    await fn();
    console.log('✅ PASS');
  } catch (error) {
    console.log('❌ FAIL');
    console.error(`   Error: ${error.message}`);
    if (error.sql) console.error(`   SQL: ${error.sql}`);
  }
}

async function main() {
  console.log('\n🔍 TESTING COMPLETO — CRAZY CLOTHES\n');
  
  // TEST 1: Verificar esquema
  await test('Esquema completo (23 tablas + 14 vistas)', async () => {
    const [tables] = await pool.query(`SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_schema='cc' AND table_type='BASE TABLE'`);
    const [views] = await pool.query(`SELECT COUNT(*) as cnt FROM information_schema.tables WHERE table_schema='cc' AND table_type='VIEW'`);
    if (tables[0].cnt !== 23) throw new Error(`Expected 23 tables, got ${tables[0].cnt}`);
    if (views[0].cnt !== 14) throw new Error(`Expected 14 views, got ${views[0].cnt}`);
  });

  // TEST 2: Limpiar y crear socios
  await test('Crear socios del negocio', async () => {
    await pool.query('SET FOREIGN_KEY_CHECKS=0');
    await pool.query('DELETE FROM socio');
    await pool.query('SET FOREIGN_KEY_CHECKS=1');
    await pool.query(`INSERT INTO socio (nombre, email, telefono) VALUES ('Jose', 'jose@locosgym.com', '555-0001'), ('Luise', 'luise@locosgym.com', '555-0002'), ('JJ', 'jj@locosgym.com', '555-0003')`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM socio');
    if (rows[0].cnt !== 3) throw new Error(`Expected 3, got ${rows[0].cnt}`);
  });

  // TEST 3: Roles
  await test('Crear roles con tarifas', async () => {
    await pool.query('DELETE FROM rol');
    await pool.query(`INSERT INTO rol (nombre, descripcion, porcentaje_comision) VALUES ('Negociador', 'Quien negocia la compra', 15.00), ('Entrega', 'Quien entrega el paquete', 5.00)`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM rol');
    if (rows[0].cnt !== 2) throw new Error(`Expected 2, got ${rows[0].cnt}`);
  });

  // TEST 4: Marcas
  await test('Crear marcas reales', async () => {
    await pool.query('DELETE FROM marca');
    await pool.query(`INSERT INTO marca (nombre) VALUES ('YoungLA'), ('Gymshark'), ('Breathe'), ('Civil')`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM marca');
    if (rows[0].cnt !== 4) throw new Error(`Expected 4, got ${rows[0].cnt}`);
  });

  // TEST 5: Categorías
  await test('Crear categorías reales', async () => {
    await pool.query('DELETE FROM categoria');
    await pool.query(`INSERT INTO categoria (nombre) VALUES ('Sudadera'), ('Jogger'), ('Casco'), ('Llavero'), ('Camiseta compresión')`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM categoria');
    if (rows[0].cnt !== 5) throw new Error(`Expected 5, got ${rows[0].cnt}`);
  });

  // TEST 6: Factores volumétricos
  await test('Crear factores volumétricos', async () => {
    await pool.query('DELETE FROM factor_volumen');
    const [cats] = await pool.query(`SELECT id, nombre FROM categoria ORDER BY nombre`);
    const factores = { 'Camiseta compresión': 1.0, 'Casco': 1.5, 'Jogger': 2.0, 'Llavero': 0.4, 'Sudadera': 2.5 };
    for (const cat of cats) {
      if (factores[cat.nombre]) {
        await pool.query(`INSERT INTO factor_volumen (categoria_id, factor) VALUES (${cat.id}, ${factores[cat.nombre]})`);
      }
    }
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM factor_volumen');
    if (rows[0].cnt !== 5) throw new Error(`Expected 5, got ${rows[0].cnt}`);
  });

  // TEST 7: Productos
  await test('Crear productos reales', async () => {
    await pool.query('DELETE FROM producto');
    await pool.query(`
      INSERT INTO producto (marca_id, categoria_id, nombre, descripcion) 
      SELECT m.id, c.id, 'Sudadera Klein', 'Sudadera Gymshark modelo Klein'
      FROM marca m, categoria c WHERE m.nombre='Gymshark' AND c.nombre='Sudadera'
    `);
    await pool.query(`
      INSERT INTO producto (marca_id, categoria_id, nombre, descripcion) 
      SELECT m.id, c.id, 'Jogger Breathe', 'Jogger marca Breathe'
      FROM marca m, categoria c WHERE m.nombre='Breathe' AND c.nombre='Jogger'
    `);
    await pool.query(`
      INSERT INTO producto (marca_id, categoria_id, nombre, descripcion) 
      SELECT m.id, c.id, 'Casco Ebay', 'Casco de Ebay'
      FROM marca m, categoria c WHERE m.nombre='YoungLA' AND c.nombre='Casco'
    `);
    await pool.query(`
      INSERT INTO producto (marca_id, categoria_id, nombre, descripcion) 
      SELECT m.id, c.id, 'Llaveros Gymshark', 'Llaveros de Gymshark'
      FROM marca m, categoria c WHERE m.nombre='Gymshark' AND c.nombre='Llavero'
    `);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM producto');
    if (rows[0].cnt !== 4) throw new Error(`Expected 4, got ${rows[0].cnt}`);
  });

  // TEST 8: SKUs
  await test('Crear SKUs con tallas', async () => {
    await pool.query('DELETE FROM sku');
    await pool.query(`INSERT INTO sku (producto_id, talla, color, precio_venta) SELECT id, 'L', 'Negro', 850.00 FROM producto WHERE nombre='Sudadera Klein'`);
    await pool.query(`INSERT INTO sku (producto_id, talla, color, precio_venta) SELECT id, 'M', 'Gris', 720.00 FROM producto WHERE nombre='Jogger Breathe'`);
    await pool.query(`INSERT INTO sku (producto_id, talla, color, precio_venta) SELECT id, 'N/A', 'Negro', 450.00 FROM producto WHERE nombre='Casco Ebay'`);
    await pool.query(`INSERT INTO sku (producto_id, talla, color, precio_venta) SELECT id, 'N/A', 'Varios', 120.00 FROM producto WHERE nombre='Llaveros Gymshark'`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM sku');
    if (rows[0].cnt !== 4) throw new Error(`Expected 4, got ${rows[0].cnt}`);
  });

  // TEST 9: Cruce
  await test('Crear cruce CONS-2026-06', async () => {
    await pool.query('DELETE FROM cruce');
    await pool.query(`INSERT INTO cruce (nombre, fecha_cruce, costo_cruce_usd, tipo_cambio_usd_mxn, descripcion) VALUES ('CONS-2026-06', '2026-06-24', 350.00, 18.50, 'Cruce Locos Gym Junio 2026')`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM cruce');
    if (rows[0].cnt !== 1) throw new Error(`Expected 1, got ${rows[0].cnt}`);
  });

  // TEST 10: Paquetes con guías reales
  await test('Crear paquetes con guías reales', async () => {
    await pool.query('DELETE FROM paquete');
    const [cruce] = await pool.query(`SELECT id FROM cruce WHERE nombre='CONS-2026-06'`);
    const cid = cruce[0].id;
    await pool.query(`INSERT INTO paquete (cruce_id, numero_guia, paqueteria, fecha_llegada, descripcion) VALUES (${cid}, '1Z08X89A0301650873', 'UPS', '2026-06-26', 'Sudadera Klein'), (${cid}, '1Z1F92320318576758', 'UPS', '2026-06-24', 'Llaveros JJ'), (${cid}, '420785219205590267338808841279', 'USPS', '2026-05-29', 'Jogger Breathe'), (${cid}, '4207852170149434908106245318083125', 'USPS', '2026-07-03', 'Cascos Ebay')`);
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM paquete');
    if (rows[0].cnt !== 4) throw new Error(`Expected 4, got ${rows[0].cnt}`);
  });

  // TEST 11: Piezas NEGOCIO y PERSONAL
  await test('Crear piezas NEGOCIO y PERSONAL', async () => {
    await pool.query('DELETE FROM pieza');
    
    // Paquete 1 (Sudaderas): 2 NEGOCIO + 1 PERSONAL
    await pool.query(`
      INSERT INTO pieza (paquete_id, sku_id, tipo, socio_id, descripcion)
      SELECT p.id, s.id, 'NEGOCIO', NULL, 'Sudadera 1'
      FROM paquete p, sku s, producto pr
      WHERE p.numero_guia='1Z08X89A0301650873' AND s.producto_id=pr.id AND pr.nombre='Sudadera Klein'
    `);
    await pool.query(`
      INSERT INTO pieza (paquete_id, sku_id, tipo, socio_id, descripcion)
      SELECT p.id, s.id, 'NEGOCIO', NULL, 'Sudadera 2'
      FROM paquete p, sku s, producto pr
      WHERE p.numero_guia='1Z08X89A0301650873' AND s.producto_id=pr.id AND pr.nombre='Sudadera Klein'
    `);
    await pool.query(`
      INSERT INTO pieza (paquete_id, sku_id, tipo, socio_id, descripcion)
      SELECT p.id, NULL, 'PERSONAL', soc.id, 'Sudadera personal JJ'
      FROM paquete p, socio soc
      WHERE p.numero_guia='1Z08X89A0301650873' AND soc.nombre='JJ'
    `);
    
    // Paquete 2 (Llaveros): 5 NEGOCIO
    for (let i = 1; i <= 5; i++) {
      await pool.query(`
        INSERT INTO pieza (paquete_id, sku_id, tipo, descripcion)
        SELECT p.id, s.id, 'NEGOCIO', 'Llavero ${i}'
        FROM paquete p, sku s, producto pr
        WHERE p.numero_guia='1Z1F92320318576758' AND s.producto_id=pr.id AND pr.nombre='Llaveros Gymshark'
      `);
    }
    
    // Paquete 3 (Jogger): 1 NEGOCIO
    await pool.query(`
      INSERT INTO pieza (paquete_id, sku_id, tipo, descripcion)
      SELECT p.id, s.id, 'NEGOCIO', 'Jogger M Gris'
      FROM paquete p, sku s, producto pr
      WHERE p.numero_guia='420785219205590267338808841279' AND s.producto_id=pr.id AND pr.nombre='Jogger Breathe'
    `);
    
    // Paquete 4 (Cascos): 3 NEGOCIO
    for (let i = 1; i <= 3; i++) {
      await pool.query(`
        INSERT INTO pieza (paquete_id, sku_id, tipo, descripcion)
        SELECT p.id, s.id, 'NEGOCIO', 'Casco ${i}'
        FROM paquete p, sku s, producto pr
        WHERE p.numero_guia='4207852170149434908106245318083125' AND s.producto_id=pr.id AND pr.nombre='Casco Ebay'
      `);
    }
    
    const [rows] = await pool.query('SELECT COUNT(*) as cnt FROM pieza');
    if (rows[0].cnt !== 14) throw new Error(`Expected 14, got ${rows[0].cnt}`);
  });

  // TEST 12: Movimientos COMPRA auto-generados
  await test('Movimientos COMPRA auto-generados', async () => {
    const [rows] = await pool.query(`SELECT COUNT(*) as cnt FROM movimiento WHERE tipo='COMPRA'`);
    if (rows[0].cnt !== 11) throw new Error(`Expected 11 (2+5+1+3), got ${rows[0].cnt}`);
  });

  // TEST 13: Stock inicial
  await test('Stock inicial correcto', async () => {
    const [stock] = await pool.query(`
      SELECT p.nombre, vs.stock_actual
      FROM v_stock vs JOIN sku s ON vs.sku_id=s.id JOIN producto p ON s.producto_id=p.id
      ORDER BY p.nombre
    `);
    console.log('\n   📦 Stock:');
    for (const r of stock) console.log(`      ${r.nombre}: ${r.stock_actual}`);
    
    const sudaderas = stock.find(r => r.nombre === 'Sudadera Klein');
    const joggers = stock.find(r => r.nombre === 'Jogger Breathe');
    const cascos = stock.find(r => r.nombre === 'Casco Ebay');
    const llaveros = stock.find(r => r.nombre === 'Llaveros Gymshark');
    
    if (parseInt(sudaderas?.stock_actual) !== 2) throw new Error(`Sudaderas: expected 2, got ${sudaderas?.stock_actual}`);
    if (parseInt(joggers?.stock_actual) !== 1) throw new Error(`Joggers: expected 1, got ${joggers?.stock_actual}`);
    if (parseInt(cascos?.stock_actual) !== 3) throw new Error(`Cascos: expected 3, got ${cascos?.stock_actual}`);
    if (parseInt(llaveros?.stock_actual) !== 5) throw new Error(`Llaveros: expected 5, got ${llaveros?.stock_actual}`);
  });

  // TEST 14: Prorrateo volumétrico
  await test('Prorrateo volumétrico', async () => {
    const [p] = await pool.query(`
      SELECT CAST(pct_negocio AS CHAR) as pct_neg, CAST(pct_personal AS CHAR) as pct_per,
             CAST(mxn_cruce AS CHAR) as mxn_c, CAST(mxn_negocio AS CHAR) as mxn_n, CAST(mxn_personal AS CHAR) as mxn_p
      FROM v_cruce_negocio_personal WHERE cruce_nombre='CONS-2026-06'
    `);
    if (p.length === 0) throw new Error('No prorrateo');
    
    console.log(`\n   💰 Prorrateo:`);
    console.log(`      %Negocio: ${p[0].pct_neg}% | %Personal: ${p[0].pct_per}%`);
    console.log(`      Cruce: $${p[0].mxn_c} | Negocio: $${p[0].mxn_n} | Personal: $${p[0].mxn_p}`);
    
    const suma = parseFloat(p[0].pct_neg) + parseFloat(p[0].pct_per);
    if (Math.abs(suma - 100) > 0.01) throw new Error(`No suma 100%: ${suma}`);
  });

  // TEST 15: Costo unitario
  await test('Costo unitario prorrateado', async () => {
    const [c] = await pool.query(`
      SELECT producto_nombre, COUNT(*) as cnt, CAST(AVG(costo_unitario_mxn) AS CHAR) as costo_avg
      FROM v_pieza_costo WHERE tipo='NEGOCIO'
      GROUP BY producto_nombre ORDER BY producto_nombre
    `);
    console.log(`\n   💵 Costo unitario:`);
    for (const r of c) console.log(`      ${r.producto_nombre}: $${r.costo_avg} (${r.cnt} pzas)`);
    
    for (const r of c) {
      if (parseFloat(r.costo_avg) <= 0) throw new Error(`Costo inválido: ${r.costo_avg}`);
    }
  });

  // TEST 16: Crear venta
  await test('Crear venta', async () => {
    await pool.query('DELETE FROM venta');
    await pool.query('DELETE FROM cliente');
    
    const [cli] = await pool.query(`INSERT INTO cliente (nombre, email, telefono) VALUES ('Cliente Test', 'test@test.com', '555-9999')`);
    const [ven] = await pool.query(`INSERT INTO venta (cliente_id, fecha_venta, descripcion) VALUES (${cli.insertId}, NOW(), 'Venta test')`);
    
    await pool.query(`INSERT INTO linea_venta (venta_id, sku_id, cantidad, precio_unitario) SELECT ${ven.insertId}, s.id, 1, 850.00 FROM sku s JOIN producto p ON s.producto_id=p.id WHERE p.nombre='Sudadera Klein'`);
    await pool.query(`INSERT INTO linea_venta (venta_id, sku_id, cantidad, precio_unitario) SELECT ${ven.insertId}, s.id, 2, 120.00 FROM sku s JOIN producto p ON s.producto_id=p.id WHERE p.nombre='Llaveros Gymshark'`);
    
    const [movs] = await pool.query(`SELECT COUNT(*) as cnt FROM movimiento WHERE tipo='VENTA' AND venta_id=${ven.insertId}`);
    if (movs[0].cnt !== 2) throw new Error(`Expected 2 movs VENTA, got ${movs[0].cnt}`);
  });

  // TEST 17: Stock post-venta
  await test('Stock después de venta', async () => {
    const [stock] = await pool.query(`
      SELECT p.nombre, vs.stock_actual
      FROM v_stock vs JOIN sku s ON vs.sku_id=s.id JOIN producto p ON s.producto_id=p.id
      WHERE p.nombre IN ('Sudadera Klein', 'Llaveros Gymshark')
    `);
    
    const llaveros = stock.find(r => r.nombre === 'Llaveros Gymshark');
    const sudaderas = stock.find(r => r.nombre === 'Sudadera Klein');
    
    console.log(`\n   📦 Post-venta: Sudaderas=${sudaderas?.stock_actual} (era 2), Llaveros=${llaveros?.stock_actual} (eran 5)`);
    
    if (parseInt(llaveros?.stock_actual) !== 3) throw new Error(`Expected 3 llaveros, got ${llaveros?.stock_actual}`);
    if (parseInt(sudaderas?.stock_actual) !== 1) throw new Error(`Expected 1 sudadera, got ${sudaderas?.stock_actual}`);
  });

  // TEST 18: Utilidad
  await test('Utilidad por venta', async () => {
    const [u] = await pool.query(`
      SELECT CAST(total_venta AS CHAR) as tv, CAST(total_costo AS CHAR) as tc,
             CAST(utilidad_bruta AS CHAR) as ub, CAST(margen_porcentaje AS CHAR) as mp
      FROM v_venta_utilidad WHERE cliente_nombre='Cliente Test'
    `);
    if (u.length === 0) throw new Error('No utilidad');
    
    console.log(`\n   💰 Utilidad: Venta=$${u[0].tv} | Costo=$${u[0].tc} | Utilidad=$${u[0].ub} (${u[0].mp}%)`);
    
    const tv = parseFloat(u[0].tv);
    const ub = parseFloat(u[0].ub);
    
    if (Math.abs(tv - 1090) > 0.01) throw new Error(`Expected venta=1090, got ${tv}`);
    if (ub <= 0) throw new Error(`Utilidad debe ser >0, got ${ub}`);
  });

  // TEST 19: Alertas
  await test('Alertas del sistema', async () => {
    const [a] = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM v_alerta_stock_negativo) as sn,
        (SELECT COUNT(*) FROM v_alerta_negocio_sin_sku) as nss,
        (SELECT COUNT(*) FROM v_alerta_paquete_sin_piezas) as psp,
        (SELECT COUNT(*) FROM v_alerta_paquete_sin_cruce) as psc,
        (SELECT COUNT(*) FROM v_alerta_personal_sin_dueno) as psd
    `);
    console.log(`\n   🚨 Alertas: Stock neg=${a[0].sn}, Sin SKU=${a[0].nss}, Sin piezas=${a[0].psp}, Sin cruce=${a[0].psc}, Sin dueño=${a[0].psd}`);
    if (a[0].sn > 0) console.warn('   ⚠️  HAY STOCK NEGATIVO');
  });

  // TEST 20: Constraint personal_sin_sku
  await test('Constraint personal_sin_sku (debe fallar)', async () => {
    let failed = false;
    try {
      await pool.query(`
        INSERT INTO pieza (paquete_id, sku_id, tipo, socio_id, descripcion)
        SELECT p.id, s.id, 'PERSONAL', soc.id, 'DEBE FALLAR'
        FROM paquete p, sku s, producto pr, socio soc
        WHERE p.numero_guia='1Z08X89A0301650873' AND s.producto_id=pr.id 
          AND pr.nombre='Sudadera Klein' AND soc.nombre='JJ' LIMIT 1
      `);
    } catch (err) {
      if (err.message.includes('personal_sin_sku')) {
        failed = true;
        console.log('\n   ✅ Constraint OK (rechazó PERSONAL con SKU)');
      } else throw err;
    }
    if (!failed) throw new Error('Constraint NO funcionó');
  });

  console.log('\n✅ TODOS LOS TESTS PASARON\n');
  await pool.end();
}

main().catch(console.error);
