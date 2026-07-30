import mysql from 'mysql2/promise';
import fs from 'fs';

const pool = mysql.createPool({
  host: 'localhost', port: 33306, user: 'root',
  password: 'test', database: 'cc'
});

const piezasData = JSON.parse(fs.readFileSync('/tmp/piezas_por_guia.json', 'utf8'));

console.log('\n📦 IMPORTANDO PIEZAS DE LAS GUÍAS\n');
console.log('='.repeat(70));

// 1. Obtener IDs de paquetes
const [paquetes] = await pool.query('SELECT id, guia FROM paquete');
const paqueteMap = {};
for (const p of paquetes) {
  paqueteMap[p.guia] = p.id;
}

// 2. Obtener IDs de marcas y tipos
const [marcas] = await pool.query('SELECT id, nombre FROM marca');
const marcaMap = {};
for (const m of marcas) marcaMap[m.nombre] = m.id;

const [tipos] = await pool.query('SELECT id, nombre FROM tipo_prenda');
const tipoMap = {};
for (const t of tipos) tipoMap[t.nombre] = t.id;

// 3. Procesar cada guía
let piezasCreadas = 0;
let guiasConPiezas = 0;
let piezasNegocio = 0;
let piezasPersonal = 0;

for (const [guia, datos] of Object.entries(piezasData)) {
  const paqueteId = paqueteMap[guia];
  if (!paqueteId) {
    console.log(`⚠️  Guía ${guia.substring(0,30)} no encontrada en BD`);
    continue;
  }
  
  guiasConPiezas++;
  
  for (const [descripcion, tipo, sku] of datos.piezas) {
    // Obtener marca_id y tipo_prenda_id
    // Para simplificar, uso YoungLA y Camiseta compresión como defaults
    const marcaId = marcaMap['YoungLA'] || 1;
    const tipoId = tipoMap['Camiseta compresión'] || 1;
    
    // SKU ID si existe
    let skuId = null;
    if (sku) {
      const [skuRow] = await pool.query('SELECT id FROM sku WHERE codigo=?', [sku]);
      if (skuRow.length > 0) {
        skuId = skuRow[0].id;
      }
    }
    
    // destino: NEGOCIO o PERSONAL
    const destino = tipo === 'N' ? 'NEGOCIO' : 'PERSONAL';
    
    // Crear pieza
    await pool.query(`
      INSERT INTO pieza (paquete_id, descripcion, cantidad, marca_id, tipo_prenda_id, 
                         destino, sku_id, costo_usd)
      VALUES (?, ?, 1, ?, ?, ?, ?, NULL)
    `, [paqueteId, descripcion, marcaId, tipoId, destino, skuId]);
    
    piezasCreadas++;
    if (destino === 'NEGOCIO') piezasNegocio++;
    else piezasPersonal++;
  }
}

console.log(`\n✅ ${piezasCreadas} piezas creadas`);
console.log(`   ${piezasNegocio} NEGOCIO + ${piezasPersonal} PERSONAL`);
console.log(`   ${guiasConPiezas} guías con piezas`);

// 4. Verificar prorrateo
console.log('\n' + '='.repeat(70));
console.log('\n💰 PRORRATEO VOLUMÉTRICO\n');

const [prorrateo] = await pool.query(`
  SELECT 
    folio,
    CAST(costo_cruce_mxn AS CHAR) as costo_cruce,
    CAST(mxn_negocio AS CHAR) as mxn_negocio,
    CAST(mxn_personal AS CHAR) as mxn_personal
  FROM v_cruce_negocio_personal
  ORDER BY folio
`);

for (const p of prorrateo) {
  if (!p.mxn_negocio || !p.mxn_personal) {
    console.log(`${p.folio.padEnd(20)} | ⚠️  Sin prorrateo (faltan factores volumétricos)`);
    continue;
  }
  
  const cruce = parseFloat(p.costo_cruce);
  const neg = parseFloat(p.mxn_negocio);
  const per = parseFloat(p.mxn_personal);
  const diff = Math.abs(cruce - (neg + per));
  const ok = diff < 0.01 ? '✅' : '❌';
  
  console.log(`${p.folio.padEnd(20)} | $${cruce.toFixed(2).padStart(8)} = $${neg.toFixed(2).padStart(8)} + $${per.toFixed(2).padStart(8)} ${ok}`);
}

// 5. Stock actualizado
const [stock] = await pool.query(`
  SELECT p.nombre, s.talla, s.color, vs.disponible
  FROM v_stock vs
  JOIN sku s ON vs.sku_id = s.id
  JOIN producto p ON s.producto_id = p.id
  WHERE vs.disponible > 0
  ORDER BY vs.disponible DESC
  LIMIT 15
`);

console.log('\n📦 STOCK ACTUALIZADO (top 15):\n');
for (const s of stock) {
  console.log(`   ${s.nombre.substring(0,35).padEnd(35)} | ${s.talla.padEnd(7)} ${s.color.substring(0,18).padEnd(18)} | ${s.disponible} unid`);
}

console.log('\n');
await pool.end();
