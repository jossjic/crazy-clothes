import { q } from '@/lib/db'
import { TrendingUp, DollarSign, Package, ShoppingCart, Users, AlertCircle } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function ReportesPage() {
  // Métricas principales del Dashboard
  const ventasTotalesResult = await q(`
    SELECT COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn - vl.descuento_mxn), 0) as total
    FROM venta_linea vl
  `)
  const ventasTotales = ventasTotalesResult[0] || { total: 0 }

  const stockTotalResult = await q(`
    SELECT COUNT(DISTINCT sku_id) as skus, COALESCE(SUM(disponible), 0) as unidades
    FROM v_stock WHERE disponible > 0
  `)
  const stockTotal = stockTotalResult[0] || { skus: 0, unidades: 0 }

  const numVentasResult = await q(`SELECT COUNT(*) as total FROM venta`)
  const numVentas = numVentasResult[0] || { total: 0 }

  // Ticket promedio
  const ticketPromedioResult = await q(`
    SELECT COALESCE(AVG(venta_total), 0) as promedio
    FROM (
      SELECT SUM(vl.cantidad * vl.precio_unitario_mxn) as venta_total
      FROM venta v
      JOIN venta_linea vl ON v.id = vl.venta_id
      GROUP BY v.id
    ) as ventas_agrupadas
  `)
  const ticketPromedio = ticketPromedioResult[0] || { promedio: 0 }

  // Valor total del inventario (stock * costo)
  const valorInventarioResult = await q(`
    SELECT COALESCE(SUM(vs.disponible * vpc.costo_total_mxn), 0) as valor
    FROM v_stock vs
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vs.sku_id
    WHERE vs.disponible > 0
  `)
  const valorInventario = valorInventarioResult[0] || { valor: 0 }

  // SKUs sin stock
  const sinStockResult = await q(`
    SELECT COUNT(*) as total
    FROM v_stock
    WHERE disponible <= 0
  `)
  const sinStock = sinStockResult[0] || { total: 0 }

  // Comisiones totales, pagadas y pendientes
  const comisionesResult = await q(`
    SELECT
      COALESCE(SUM(
        (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
         FROM venta_rol vr
         JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
         WHERE vr.venta_id = v.id
           AND ct.vigente_desde <= v.fecha
           AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
      ), 0) as total_generado,
      COALESCE(SUM(
        CASE WHEN v.estado = 'PAGADO'
        THEN (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
              FROM venta_rol vr
              JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
              WHERE vr.venta_id = v.id
                AND ct.vigente_desde <= v.fecha
                AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
        ELSE 0 END
      ), 0) as pagadas,
      COALESCE(SUM(
        CASE WHEN v.estado != 'PAGADO'
        THEN (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
              FROM venta_rol vr
              JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
              WHERE vr.venta_id = v.id
                AND ct.vigente_desde <= v.fecha
                AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
        ELSE 0 END
      ), 0) as pendientes
    FROM venta v
    JOIN venta_linea vl ON vl.venta_id = v.id
  `)
  const comisiones = comisionesResult[0] || { total_generado: 0, pagadas: 0, pendientes: 0 }

  // Utilidad neta total
  const utilidadNetaResult = await q(`
    SELECT COALESCE(SUM(
      (vl.cantidad * vl.precio_unitario_mxn) -
      (vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) -
      (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
       FROM venta_rol vr
       JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
       WHERE vr.venta_id = v.id
         AND ct.vigente_desde <= v.fecha
         AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)) -
      COALESCE(v.envio_cliente_mxn, 0)
    ), 0) as utilidad_neta
    FROM venta v
    JOIN venta_linea vl ON vl.venta_id = v.id
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vl.sku_id
  `)
  const utilidadNeta = utilidadNetaResult[0] || { utilidad_neta: 0 }

  // Comisiones por socio
  const comisionesPorSocio = await q(`
    SELECT
      s.nombre,
      COALESCE(SUM(
        CASE WHEN rv.nombre = 'NEGOCIADOR'
        THEN (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
              FROM comision_tarifa ct
              WHERE ct.rol_venta_id = vr.rol_venta_id
                AND ct.vigente_desde <= v.fecha
                AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
        ELSE 0 END
      ), 0) as comision_negociar,
      COALESCE(SUM(
        CASE WHEN rv.nombre = 'ENTREGA'
        THEN (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
              FROM comision_tarifa ct
              WHERE ct.rol_venta_id = vr.rol_venta_id
                AND ct.vigente_desde <= v.fecha
                AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
        ELSE 0 END
      ), 0) as comision_entrega
    FROM socio s
    LEFT JOIN venta_rol vr ON vr.socio_id = s.id
    LEFT JOIN venta v ON v.id = vr.venta_id
    LEFT JOIN venta_linea vl ON vl.venta_id = v.id
    LEFT JOIN rol_venta rv ON rv.id = vr.rol_venta_id
    GROUP BY s.id, s.nombre
    ORDER BY (comision_negociar + comision_entrega) DESC
  `)

  // Alertas
  const alertasResult = await q(`
    SELECT
      (SELECT COUNT(*) FROM v_alerta_stock_negativo) as stock_negativo,
      (SELECT COUNT(*) FROM v_alerta_negocio_sin_sku) as sin_sku,
      (SELECT COUNT(*) FROM v_alerta_paquete_sin_piezas) as paquetes_vacios
  `)
  const alertas = alertasResult[0] || { stock_negativo: 0, sin_sku: 0, paquetes_vacios: 0 }

  // Ventas por mes
  const ventasPorMes = await q(`
    SELECT
      DATE_FORMAT(v.fecha, '%Y-%m') as mes,
      COUNT(DISTINCT v.id) as num_ventas,
      COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn), 0) as total
    FROM venta v
    LEFT JOIN venta_linea vl ON v.id = vl.venta_id
    GROUP BY DATE_FORMAT(v.fecha, '%Y-%m')
    ORDER BY mes DESC
    LIMIT 12
  `)

  // Productos más vendidos
  const masVendidos = await q(`
    SELECT
      p.nombre as producto,
      m.nombre as marca,
      SUM(vl.cantidad) as cantidad_vendida,
      SUM(vl.cantidad * vl.precio_unitario_mxn) as ingresos
    FROM venta_linea vl
    JOIN sku s ON vl.sku_id = s.id
    JOIN producto p ON s.producto_id = p.id
    JOIN marca m ON p.marca_id = m.id
    GROUP BY p.id, p.nombre, m.nombre
    ORDER BY cantidad_vendida DESC
    LIMIT 10
  `)

  // Stock por marca
  const stockPorMarca = await q(`
    SELECT
      m.nombre as marca,
      COUNT(DISTINCT vs.sku_id) as skus,
      SUM(vs.disponible) as unidades
    FROM v_stock vs
    JOIN sku s ON vs.sku_id = s.id
    JOIN producto p ON s.producto_id = p.id
    JOIN marca m ON p.marca_id = m.id
    WHERE vs.disponible > 0
    GROUP BY m.nombre
    ORDER BY unidades DESC
  `)

  // Ventas recientes
  const ventasRecientes = await q(`
    SELECT
      v.folio,
      v.fecha,
      v.cliente,
      COUNT(vl.id) as lineas,
      COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn), 0) as total
    FROM venta v
    LEFT JOIN venta_linea vl ON v.id = vl.venta_id
    GROUP BY v.id, v.folio, v.fecha, v.cliente
    ORDER BY v.fecha DESC
    LIMIT 10
  `)

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Reportes y Dashboard</h1>
        <p className="text-sm text-stone-500 mt-1">Métricas y análisis del negocio</p>
      </div>

      {/* Métricas principales - Sección Ventas */}
      <div>
        <h2 className="text-lg font-semibold text-stone-900 mb-3">📊 Ventas</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 rounded-lg">
                <DollarSign className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Ventas Totales</p>
                <p className="text-2xl font-semibold text-stone-900">
                  ${parseFloat(ventasTotales.total || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <ShoppingCart className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Número de Ventas</p>
                <p className="text-2xl font-semibold text-stone-900">{numVentas.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-indigo-100 rounded-lg">
                <TrendingUp className="w-5 h-5 text-indigo-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Ticket Promedio</p>
                <p className="text-2xl font-semibold text-stone-900">
                  ${parseFloat(ticketPromedio.promedio || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className={`p-2 rounded-lg ${parseFloat(utilidadNeta.utilidad_neta) > 0 ? 'bg-green-100' : 'bg-red-100'}`}>
                <DollarSign className={`w-5 h-5 ${parseFloat(utilidadNeta.utilidad_neta) > 0 ? 'text-green-600' : 'text-red-600'}`} />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Utilidad Neta</p>
                <p className={`text-2xl font-semibold ${parseFloat(utilidadNeta.utilidad_neta) > 0 ? 'text-green-600' : 'text-red-600'}`}>
                  ${parseFloat(utilidadNeta.utilidad_neta || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Métricas de Inventario */}
      <div>
        <h2 className="text-lg font-semibold text-stone-900 mb-3">📦 Inventario</h2>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 rounded-lg">
                <Package className="w-5 h-5 text-purple-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Stock Disponible</p>
                <p className="text-2xl font-semibold text-stone-900">{stockTotal.unidades}</p>
                <p className="text-xs text-stone-400">{stockTotal.skus} SKUs con stock</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-stone-100 rounded-lg">
                <Package className="w-5 h-5 text-stone-500" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Sin Stock</p>
                <p className="text-2xl font-semibold text-stone-900">{sinStock.total}</p>
                <p className="text-xs text-stone-400">SKUs agotados</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-emerald-100 rounded-lg">
                <DollarSign className="w-5 h-5 text-emerald-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Valor Inventario</p>
                <p className="text-2xl font-semibold text-stone-900">
                  ${parseFloat(valorInventario.valor || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
                <p className="text-xs text-stone-400">Al costo</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-amber-100 rounded-lg">
                <AlertCircle className="w-5 h-5 text-amber-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Alertas</p>
                <p className="text-2xl font-semibold text-stone-900">
                  {parseInt(alertas.stock_negativo) + parseInt(alertas.sin_sku) + parseInt(alertas.paquetes_vacios)}
                </p>
                <p className="text-xs text-stone-400">
                  {alertas.stock_negativo > 0 && `${alertas.stock_negativo} stock neg`}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Métricas de Comisiones */}
      <div>
        <h2 className="text-lg font-semibold text-stone-900 mb-3">💰 Comisiones</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 rounded-lg">
                <DollarSign className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Total Generado</p>
                <p className="text-2xl font-semibold text-stone-900">
                  ${parseFloat(comisiones.total_generado || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 rounded-lg">
                <DollarSign className="w-5 h-5 text-green-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Pagadas</p>
                <p className="text-2xl font-semibold text-green-600">
                  ${parseFloat(comisiones.pagadas || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg border border-stone-200 p-5">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-amber-100 rounded-lg">
                <DollarSign className="w-5 h-5 text-amber-600" />
              </div>
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide">Pendientes</p>
                <p className="text-2xl font-semibold text-amber-600">
                  ${parseFloat(comisiones.pendientes || 0).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Comisiones por socio */}
      <div className="bg-white rounded-lg border border-stone-200 p-6">
        <h2 className="text-lg font-semibold text-stone-900 mb-4">Comisiones por Socio</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {comisionesPorSocio.map(s => {
            const total = parseFloat(s.comision_negociar || 0) + parseFloat(s.comision_entrega || 0)
            return (
              <div key={s.nombre} className="border border-stone-200 rounded-lg p-4">
                <h3 className="font-semibold text-stone-900 mb-3">{s.nombre}</h3>
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-stone-600">Negociar:</span>
                    <span className="font-mono text-blue-600">
                      ${parseFloat(s.comision_negociar || 0).toFixed(2)}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-stone-600">Entrega:</span>
                    <span className="font-mono text-blue-600">
                      ${parseFloat(s.comision_entrega || 0).toFixed(2)}
                    </span>
                  </div>
                  <div className="flex justify-between pt-2 border-t border-stone-200 font-semibold">
                    <span>Total:</span>
                    <span className="font-mono text-green-600">${total.toFixed(2)}</span>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* Gráficos y tablas */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Ventas por mes */}
        <div className="bg-white rounded-lg border border-stone-200 p-6">
          <h2 className="text-lg font-semibold text-stone-900 mb-4">Ventas por Mes</h2>
          <div className="space-y-3">
            {ventasPorMes.map((v, i) => {
              const mesNombre = new Date(v.mes + '-01').toLocaleDateString('es-MX', { month: 'long', year: 'numeric' })
              const maxTotal = Math.max(...ventasPorMes.map(x => parseFloat(x.total)))
              const percent = maxTotal > 0 ? (parseFloat(v.total) / maxTotal) * 100 : 0

              return (
                <div key={v.mes}>
                  <div className="flex items-center justify-between text-sm mb-1">
                    <span className="text-stone-600 capitalize">{mesNombre}</span>
                    <span className="font-medium text-stone-900">
                      ${parseFloat(v.total).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </span>
                  </div>
                  <div className="h-2 bg-stone-100 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-blue-500 rounded-full transition-all"
                      style={{ width: `${percent}%` }}
                    />
                  </div>
                  <p className="text-xs text-stone-400 mt-1">{v.num_ventas} ventas</p>
                </div>
              )
            })}
          </div>
        </div>

        {/* Stock por marca */}
        <div className="bg-white rounded-lg border border-stone-200 p-6">
          <h2 className="text-lg font-semibold text-stone-900 mb-4">Stock por Marca</h2>
          <div className="space-y-3">
            {stockPorMarca.map((s, i) => {
              const maxUnidades = Math.max(...stockPorMarca.map(x => parseInt(x.unidades)))
              const percent = maxUnidades > 0 ? (parseInt(s.unidades) / maxUnidades) * 100 : 0

              return (
                <div key={s.marca}>
                  <div className="flex items-center justify-between text-sm mb-1">
                    <span className="text-stone-600">{s.marca}</span>
                    <span className="font-medium text-stone-900">{s.unidades} unidades</span>
                  </div>
                  <div className="h-2 bg-stone-100 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-purple-500 rounded-full transition-all"
                      style={{ width: `${percent}%` }}
                    />
                  </div>
                  <p className="text-xs text-stone-400 mt-1">{s.skus} SKUs</p>
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Productos más vendidos */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Productos Más Vendidos</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">#</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Marca</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Cantidad</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Ingresos</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-200">
              {masVendidos.map((p, i) => (
                <tr key={i} className="hover:bg-stone-50 transition-colors">
                  <td className="px-6 py-4 text-sm text-stone-500">{i + 1}</td>
                  <td className="px-6 py-4 text-sm text-stone-900 font-medium">{p.producto}</td>
                  <td className="px-6 py-4 text-sm text-stone-600">{p.marca}</td>
                  <td className="px-6 py-4 text-sm text-stone-900 text-right">{p.cantidad_vendida}</td>
                  <td className="px-6 py-4 text-sm text-stone-900 text-right font-medium">
                    ${parseFloat(p.ingresos).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Ventas recientes */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Ventas Recientes</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Folio</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Cliente</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Líneas</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Total</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-200">
              {ventasRecientes.map((v) => {
                const fecha = new Date(v.fecha)
                return (
                  <tr key={v.folio} className="hover:bg-stone-50 transition-colors">
                    <td className="px-6 py-4 text-sm font-mono text-stone-900">{v.folio}</td>
                    <td className="px-6 py-4 text-sm text-stone-600">
                      {fecha.toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                    </td>
                    <td className="px-6 py-4 text-sm text-stone-900">{v.cliente}</td>
                    <td className="px-6 py-4 text-sm text-stone-600 text-right">{v.lineas}</td>
                    <td className="px-6 py-4 text-sm text-stone-900 text-right font-medium">
                      ${parseFloat(v.total).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
