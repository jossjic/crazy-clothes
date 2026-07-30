import { q } from '@/lib/db'
import { ArrowLeft, Package } from 'lucide-react'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function InventarioCompletoPage({ searchParams }) {
  const buscar = searchParams.q || ''
  const marca = searchParams.marca || ''
  const soloStock = searchParams.stock === 'true'

  // Query COMPLETO con TODAS las columnas del Excel
  let where = [`(s.codigo LIKE ? OR pr.nombre LIKE ?)`]
  let params = [`%${buscar}%`, `%${buscar}%`]

  if (marca) {
    where.push(`m.nombre = ?`)
    params.push(marca)
  }
  if (soloStock) {
    where.push(`vs.disponible > 0`)
  }

  const stock = await q(
    `SELECT
      s.id as sku_id,
      s.codigo,
      s.estado,
      s.codigo_proveedor,
      u.nombre as ubicacion,
      s.estado_comercial,
      m.nombre as marca,
      pr.nombre as producto,
      tp.nombre as tipo,
      s.talla,
      s.color,
      s.notas,
      vs.stock_inicial,
      vs.entradas,
      vs.salidas,
      vs.reservado,
      vs.disponible as stock_disponible,
      -- Estado comercial calculado
      CASE
        WHEN vs.disponible > 0 THEN 'Disponible'
        WHEN vs.reservado > 0 THEN 'Reservado'
        ELSE 'Sin stock'
      END as estado_comercial_calculado,
      s.precio_lista_mxn,
      -- Costos: primero de piezas (v_pieza_costo), sino de sku_costo (ya en MXN)
      COALESCE(vpc.costo_prenda_mxn, sc.costo_producto_usd) as costo_producto_mxn,
      COALESCE(vpc.cruce_pieza_mxn, sc.costo_envio_usd) as costo_envio_mxn,
      COALESCE(vpc.costo_total_mxn, sc.costo_total_usd) as costo_total_mxn,
      (s.precio_lista_mxn - COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) as margen_bruto_mxn,
      CASE
        WHEN s.precio_lista_mxn > 0 THEN ((s.precio_lista_mxn - COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) / s.precio_lista_mxn)
        ELSE 0
      END as margen_bruto_pct,
      (COALESCE(vpc.costo_total_mxn, sc.costo_total_usd) * 1.2) as precio_minimo_sugerido,
      fv.factor,
      -- Movimientos desglosados
      COALESCE((SELECT SUM(m2.cantidad) FROM movimiento m2
                WHERE m2.sku_id = s.id AND m2.tipo = 'COMPRA'), 0) as entradas,
      COALESCE((SELECT SUM(m2.cantidad) FROM movimiento m2
                WHERE m2.sku_id = s.id AND m2.tipo = 'VENTA'), 0) as salidas
    FROM sku s
    JOIN producto pr ON pr.id = s.producto_id
    JOIN marca m ON m.id = pr.marca_id
    JOIN tipo_prenda tp ON tp.id = pr.tipo_prenda_id
    LEFT JOIN ubicacion u ON u.id = s.ubicacion_id
    LEFT JOIN v_stock vs ON vs.sku_id = s.id
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = s.id
    LEFT JOIN sku_costo sc ON sc.sku_id = s.id
    LEFT JOIN factor_volumetrico fv ON fv.tipo_prenda_id = tp.id AND fv.marca_id = m.id
    WHERE ${where.join(' AND ')}
    ORDER BY vs.disponible DESC, vs.disponible < 0 DESC, pr.nombre, s.talla, s.color
    LIMIT 200`,
    params
  )

  const marcas = await q('SELECT id, nombre FROM marca ORDER BY nombre')

  const totalUnidades = stock.reduce((sum, s) => sum + parseInt(s.stock_disponible || 0), 0)
  const skusConStock = stock.filter(s => parseInt(s.stock_disponible) > 0).length
  const valorInventario = stock.reduce((sum, s) =>
    sum + (parseFloat(s.costo_total_mxn || 0) * parseInt(s.stock_disponible || 0)), 0)

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/inventario" className="p-2 hover:bg-stone-100 rounded-lg transition-colors">
          <ArrowLeft className="w-5 h-5 text-stone-600" />
        </Link>
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Inventario Completo</h1>
          <p className="text-sm text-stone-500 mt-1">
            {stock.length} SKUs · {skusConStock} con stock · {totalUnidades} unidades ·
            ${valorInventario.toLocaleString('es-MX', {minimumFractionDigits: 2})} en inventario
          </p>
        </div>
      </div>

      {/* Filtros */}
      <form className="bg-white rounded-lg border border-stone-200 p-4">
        <div className="flex gap-3 mb-3">
          <input
            type="search"
            name="q"
            defaultValue={buscar}
            placeholder="Buscar por código o producto..."
            className="flex-1 px-3 py-2 rounded-lg border border-stone-300"
          />
          <select name="marca" defaultValue={marca} className="px-3 py-2 rounded-lg border border-stone-300">
            <option value="">Todas las marcas</option>
            {marcas.map(m => <option key={m.id} value={m.nombre}>{m.nombre}</option>)}
          </select>
          <label className="flex items-center gap-2 px-3 py-2 border border-stone-300 rounded-lg">
            <input type="checkbox" name="stock" value="true" defaultChecked={soloStock} />
            <span className="text-sm">Solo con stock</span>
          </label>
          <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded-lg">
            Buscar
          </button>
        </div>
      </form>

      {/* Tabla COMPLETA */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-xs">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-2 py-2 text-left font-semibold text-stone-700 sticky left-0 bg-stone-50">SKU</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Estado SKU</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Marca</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Producto</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Tipo</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Talla</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Color</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Cód. Prov</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Ubicación</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Stock</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Compras</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Ventas</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Reservado</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Disponible</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Costo Prod</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Costo Envío</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Costo Total</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Precio Lista</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Margen $</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Margen %</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Precio Mín</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Est. Comercial</th>
                <th className="px-2 py-2 text-right font-semibold text-stone-700">Factor</th>
                <th className="px-2 py-2 text-left font-semibold text-stone-700">Notas</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {stock.length === 0 ? (
                <tr>
                  <td colSpan="24" className="text-center py-12">
                    <Package className="w-12 h-12 mx-auto mb-3 text-stone-300" />
                    <p className="text-stone-500">No se encontraron productos</p>
                  </td>
                </tr>
              ) : (
                stock.map(s => {
                  const margenPct = parseFloat(s.margen_bruto_pct || 0)
                  const stockNum = parseInt(s.stock_disponible || 0)

                  return (
                    <tr key={s.sku_id} className={`hover:bg-stone-50 ${stockNum < 0 ? 'bg-red-50' : ''}`}>
                      <td className="px-2 py-2 font-mono sticky left-0 bg-white">{s.codigo}</td>
                      <td className="px-2 py-2">
                        <span className={`inline-flex px-1.5 py-0.5 text-[10px] font-medium rounded ${
                          s.estado === 'ACTIVO' ? 'bg-green-100 text-green-700' : 'bg-stone-100 text-stone-500'
                        }`}>
                          {s.estado || 'ACTIVO'}
                        </span>
                      </td>
                      <td className="px-2 py-2">{s.marca}</td>
                      <td className="px-2 py-2 max-w-[180px] truncate" title={s.producto}>{s.producto}</td>
                      <td className="px-2 py-2 text-stone-600">{s.tipo}</td>
                      <td className="px-2 py-2">{s.talla}</td>
                      <td className="px-2 py-2">{s.color}</td>
                      <td className="px-2 py-2 text-stone-500 text-[10px]">{s.codigo_proveedor || '—'}</td>
                      <td className="px-2 py-2 text-stone-600">{s.ubicacion || '—'}</td>
                      <td className="px-2 py-2 text-right">
                        <span className={`inline-flex px-2 py-0.5 font-medium rounded ${
                          (parseInt(s.stock_disponible || 0) + parseInt(s.reservado || 0)) > 0 ? 'bg-blue-100 text-blue-700' :
                          (parseInt(s.stock_disponible || 0) + parseInt(s.reservado || 0)) < 0 ? 'bg-red-100 text-red-700' :
                          'bg-stone-100 text-stone-500'
                        }`}>
                          {(parseInt(s.stock_disponible || 0) + parseInt(s.reservado || 0))}
                        </span>
                      </td>
                      <td className="px-2 py-2 text-right text-green-600">{s.entradas || 0}</td>
                      <td className="px-2 py-2 text-right text-red-600">{s.salidas || 0}</td>
                      <td className="px-2 py-2 text-right">
                        {parseInt(s.reservado || 0) > 0 ? (
                          <span className="inline-flex px-2 py-0.5 font-medium rounded bg-amber-100 text-amber-700">
                            {s.reservado}
                          </span>
                        ) : (
                          <span className="text-stone-400">—</span>
                        )}
                      </td>
                      <td className="px-2 py-2 text-right">
                        <span className={`inline-flex px-2 py-0.5 font-medium rounded ${
                          stockNum > 0 ? 'bg-green-100 text-green-700' :
                          stockNum < 0 ? 'bg-red-100 text-red-700' :
                          'bg-stone-100 text-stone-500'
                        }`}>
                          {stockNum}
                        </span>
                      </td>
                      <td className="px-2 py-2 text-right font-mono">
                        {s.costo_producto_mxn ? `$${parseFloat(s.costo_producto_mxn).toFixed(2)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-right font-mono">
                        {s.costo_envio_mxn ? `$${parseFloat(s.costo_envio_mxn).toFixed(2)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-right font-mono font-semibold">
                        {s.costo_total_mxn ? `$${parseFloat(s.costo_total_mxn).toFixed(2)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-right font-mono">
                        {s.precio_lista_mxn ? `$${parseFloat(s.precio_lista_mxn).toFixed(0)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-right font-mono text-blue-600">
                        {s.margen_bruto_mxn ? `$${parseFloat(s.margen_bruto_mxn).toFixed(2)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-right font-mono">
                        <span className={`${margenPct > 0.3 ? 'text-green-600' : margenPct > 0.15 ? 'text-amber-600' : 'text-red-600'}`}>
                          {(margenPct * 100).toFixed(1)}%
                        </span>
                      </td>
                      <td className="px-2 py-2 text-right font-mono text-stone-500">
                        {s.precio_minimo_sugerido ? `$${parseFloat(s.precio_minimo_sugerido).toFixed(0)}` : '—'}
                      </td>
                      <td className="px-2 py-2 text-[10px]">
                        <span className={`inline-flex px-1.5 py-0.5 text-[10px] font-medium rounded ${
                          s.estado_comercial_calculado === 'Disponible' ? 'bg-green-100 text-green-700' :
                          s.estado_comercial_calculado === 'Reservado' ? 'bg-amber-100 text-amber-700' :
                          'bg-stone-100 text-stone-500'
                        }`}>
                          {s.estado_comercial_calculado || s.estado_comercial || 'Sin stock'}
                        </span>
                      </td>
                      <td className="px-2 py-2 text-right text-stone-500">
                        {s.factor ? parseFloat(s.factor).toFixed(1) : '—'}
                      </td>
                      <td className="px-2 py-2 text-xs text-stone-500 max-w-[100px] truncate" title={s.notas}>
                        {s.notas || '—'}
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
