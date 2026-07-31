import { q } from '@/lib/db'
import { Package, AlertTriangle, TrendingUp, TrendingDown } from 'lucide-react'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function MovimientosPage({ searchParams }) {
  const params = await searchParams
  const filtro = params?.filtro || 'todos'
  // Vista completa de movimientos por SKU con costos reales
  const movimientos = await q(`
    SELECT
      s.id AS sku_id,
      s.codigo,
      pr.nombre AS producto,
      m.nombre AS marca,
      s.talla,
      s.color,
      COALESCE(vs.stock_inicial, 0) + COALESCE(vs.entradas, 0) AS total_entradas,
      COALESCE(vs.salidas, 0) AS total_salidas,
      COALESCE(SUM(DISTINCT vpc.costo_total_mxn), 0) AS costo_total_mxn,
      COALESCE((SELECT SUM(vl.cantidad * vl.precio_unitario_mxn)
                FROM venta_linea vl WHERE vl.sku_id = s.id), 0) AS venta_total_mxn,
      COALESCE(vs.disponible, 0) AS disponible,
      COALESCE(vs.reservado, 0) AS reservado,
      CASE
        WHEN COALESCE(vs.disponible, 0) > 0 THEN 'Disponible'
        WHEN COALESCE(vs.disponible, 0) = 0 THEN 'Sin stock'
        WHEN COALESCE(vs.disponible, 0) < 0 THEN 'Stock negativo'
      END AS estado_stock
    FROM sku s
    JOIN producto pr ON pr.id = s.producto_id
    JOIN marca m ON m.id = pr.marca_id
    LEFT JOIN v_stock vs ON vs.sku_id = s.id
    LEFT JOIN pieza pz ON pz.sku_id = s.id AND pz.destino = 'NEGOCIO'
    LEFT JOIN v_pieza_costo vpc ON vpc.pieza_id = pz.id
    GROUP BY s.id, s.codigo, pr.nombre, m.nombre, s.talla, s.color,
             vs.stock_inicial, vs.entradas, vs.salidas, vs.disponible, vs.reservado
    ORDER BY m.nombre, pr.nombre, s.talla
  `)

  // Piezas sin SKU (todas, separadas por estado)
  const todasSinSku = await q(`SELECT * FROM v_piezas_sin_sku`)
  const sinSku = todasSinSku.filter(p => p.estado === 'Pendiente catalogar')
  // Fix encoding: MySQL devuelve "PÃ©rdida" por problema de charset
  const perdidas = todasSinSku.filter(p => p.estado.includes('rdida operativa'))

  console.log('DEBUG todasSinSku:', todasSinSku.length)
  console.log('DEBUG estados:', todasSinSku.map(p => `"${p.estado}"`))
  console.log('DEBUG perdidas:', perdidas.length, perdidas.map(p => p.descripcion))

  // Estadísticas
  const stats = {
    conStock: movimientos.filter(m => Number(m.disponible) > 0).length,
    sinStock: movimientos.filter(m => Number(m.disponible) === 0).length,
    negativos: movimientos.filter(m => Number(m.disponible) < 0).length,
    pendientes: sinSku.length,
    perdidas: perdidas.length
  }

  // Filtrar movimientos según el filtro activo
  const movimientosFiltrados = (() => {
    switch(filtro) {
      case 'con-stock': return movimientos.filter(m => Number(m.disponible) > 0)
      case 'sin-stock': return movimientos.filter(m => Number(m.disponible) === 0)
      case 'negativos': return movimientos.filter(m => Number(m.disponible) < 0)
      default: return movimientos
    }
  })()

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Dashboard de Movimientos</h1>
        <p className="text-stone-500 mt-1">Vista general de compras, ventas e inventario</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-5 gap-4">
        <Link href="/movimientos?filtro=con-stock"
              className={`card card-body transition-all cursor-pointer ${
                filtro === 'con-stock'
                  ? 'bg-green-600 text-white shadow-lg'
                  : 'hover:shadow-md hover:scale-105'
              }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className={`text-sm ${filtro === 'con-stock' ? 'text-green-100' : 'text-stone-500'}`}>
                Con Stock
              </p>
              <p className={`text-2xl font-semibold ${filtro === 'con-stock' ? 'text-white' : 'text-green-600'}`}>
                {stats.conStock}
              </p>
            </div>
            <TrendingUp className={`w-8 h-8 ${filtro === 'con-stock' ? 'text-white' : 'text-green-600'}`} />
          </div>
        </Link>

        <Link href="/movimientos?filtro=sin-stock"
              className={`card card-body transition-all cursor-pointer ${
                filtro === 'sin-stock'
                  ? 'bg-stone-600 text-white shadow-lg'
                  : 'hover:shadow-md hover:scale-105'
              }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className={`text-sm ${filtro === 'sin-stock' ? 'text-stone-100' : 'text-stone-500'}`}>
                Sin Stock
              </p>
              <p className={`text-2xl font-semibold ${filtro === 'sin-stock' ? 'text-white' : 'text-stone-600'}`}>
                {stats.sinStock}
              </p>
            </div>
            <TrendingDown className={`w-8 h-8 ${filtro === 'sin-stock' ? 'text-white' : 'text-stone-600'}`} />
          </div>
        </Link>

        <Link href="/movimientos?filtro=negativos"
              className={`card card-body transition-all cursor-pointer ${
                filtro === 'negativos'
                  ? 'bg-red-600 text-white shadow-lg'
                  : stats.negativos > 0
                    ? 'bg-red-50 hover:shadow-md hover:scale-105'
                    : 'opacity-50 pointer-events-none'
              }`}>
          <div className="flex items-center justify-between">
            <div>
              <p className={`text-sm ${filtro === 'negativos' ? 'text-red-100' : 'text-red-600'}`}>
                Stock Negativo
              </p>
              <p className={`text-2xl font-semibold ${filtro === 'negativos' ? 'text-white' : 'text-red-700'}`}>
                {stats.negativos}
              </p>
            </div>
            <AlertTriangle className={`w-8 h-8 ${filtro === 'negativos' ? 'text-white' : 'text-red-600'}`} />
          </div>
        </Link>

        <div className="card card-body">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-stone-500">Pendientes</p>
              <p className="text-2xl font-semibold text-amber-600">{stats.pendientes}</p>
            </div>
            <Package className="w-8 h-8 text-amber-600" />
          </div>
        </div>

        <div className="card card-body">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-stone-500">Pérdidas Op.</p>
              <p className="text-2xl font-semibold text-stone-500">{stats.perdidas}</p>
            </div>
            <AlertTriangle className="w-8 h-8 text-stone-500" />
          </div>
        </div>
      </div>

      {/* Filtro activo */}
      {filtro !== 'todos' && (
        <div className="flex items-center gap-3">
          <span className="text-sm text-stone-600">Mostrando:</span>
          <span className="px-3 py-1 bg-accent-100 text-accent-700 text-sm rounded-full">
            {filtro === 'con-stock' && 'Con Stock'}
            {filtro === 'sin-stock' && 'Sin Stock'}
            {filtro === 'negativos' && 'Stock Negativo'}
          </span>
          <Link href="/movimientos" className="text-sm text-blue-600 hover:underline">
            Ver todos
          </Link>
        </div>
      )}

      {/* Piezas Sin SKU */}
      {sinSku.length > 0 && (
        <div className="card">
          <div className="card-header">
            <h2 className="text-lg font-semibold">Pendientes de Catalogar</h2>
          </div>
          <div className="card-body">
            <div className="table-wrapper">
              <table className="table">
                <thead>
                  <tr>
                    <th>Guía</th>
                    <th>Descripción</th>
                    <th>Marca</th>
                    <th>Tipo</th>
                    <th>Cantidad</th>
                    <th className="text-right">Costo USD</th>
                  </tr>
                </thead>
                <tbody>
                  {sinSku.map(p => (
                    <tr key={p.pieza_id}>
                      <td className="font-mono text-xs">{p.guia}</td>
                      <td>{p.descripcion}</td>
                      <td>{p.marca}</td>
                      <td className="text-sm text-stone-600">{p.tipo_prenda}</td>
                      <td>{p.cantidad}</td>
                      <td className="text-right">${p.costo_usd || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Movimientos por SKU */}
      <div className="card">
        <div className="card-header">
          <h2 className="text-lg font-semibold">Movimientos por SKU</h2>
        </div>
        <div className="card-body">
          <div className="table-wrapper">
            <table className="table">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Producto</th>
                  <th>Marca</th>
                  <th>Talla</th>
                  <th>Color</th>
                  <th className="text-right">Entradas</th>
                  <th className="text-right">Salidas</th>
                  <th className="text-right">Costo MXN</th>
                  <th className="text-right">Venta MXN</th>
                  <th className="text-right">Disponible</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                {movimientosFiltrados.map(m => {
                  const disp = Number(m.disponible)
                  return (
                  <tr key={m.sku_id} className={disp < 0 ? 'bg-red-50' : ''}>
                    <td className="font-mono text-xs">{m.codigo}</td>
                    <td>{m.producto}</td>
                    <td className="text-sm text-stone-600">{m.marca}</td>
                    <td>{m.talla}</td>
                    <td className="text-sm">{m.color}</td>
                    <td className="text-right text-green-600">{m.total_entradas}</td>
                    <td className="text-right text-red-600">{m.total_salidas}</td>
                    <td className="text-right text-xs text-stone-600">
                      ${Number(m.costo_total_mxn || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="text-right text-xs text-stone-600">
                      ${Number(m.venta_total_mxn || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="text-right font-semibold">
                      <span className={`inline-flex px-2 py-1 text-xs rounded ${
                        disp > 0 ? 'bg-green-100 text-green-700' :
                        disp < 0 ? 'bg-red-100 text-red-700' :
                        'bg-stone-100 text-stone-500'
                      }`}>
                        {disp}
                      </span>
                    </td>
                    <td>
                      <span className={`text-xs ${
                        m.estado_stock === 'Disponible' ? 'text-green-600' :
                        m.estado_stock === 'Stock negativo' ? 'text-red-600' :
                        'text-stone-500'
                      }`}>
                        {m.estado_stock}
                      </span>
                    </td>
                  </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Pérdidas Operativas */}
      {perdidas.length > 0 && (
        <div className="card">
          <div className="card-header">
            <h2 className="text-lg font-semibold text-stone-500">Pérdidas Operativas</h2>
          </div>
          <div className="card-body">
            <div className="table-wrapper">
              <table className="table">
                <thead>
                  <tr>
                    <th>Guía</th>
                    <th>Descripción</th>
                    <th>Cantidad</th>
                    <th>Notas</th>
                  </tr>
                </thead>
                <tbody>
                  {perdidas.map(p => (
                    <tr key={p.pieza_id} className="text-stone-500">
                      <td className="font-mono text-xs">{p.guia}</td>
                      <td>{p.descripcion}</td>
                      <td>{p.cantidad}</td>
                      <td className="text-xs">{p.notas}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
