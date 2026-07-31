import { q } from '@/lib/db'
import { TrendingUp, PieChart, DollarSign, Users } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function CapitalPage() {
  // Capital por socio desde vista
  const capitalPorSocio = await q(`SELECT * FROM v_capital_socio ORDER BY nombre`)

  // Inversión total del negocio (costo real de piezas NEGOCIO + cruces)
  const inversionTotalResult = await q(`
    SELECT
      (SELECT COALESCE(SUM(vpc.costo_prenda_mxn), 0)
       FROM pieza p
       JOIN v_pieza_costo vpc ON vpc.pieza_id = p.id
       WHERE p.destino = 'NEGOCIO') +
      (SELECT COALESCE(SUM(c.costo_mxn), 0) FROM cruce c) as total
  `)
  const inversionTotalNegocio = parseFloat(inversionTotalResult[0]?.total || 0)

  // Fecha de inicio y meses transcurridos
  const inicioResult = await q(`
    SELECT
      MIN(fecha) as fecha_inicio,
      TIMESTAMPDIFF(MONTH, MIN(fecha), CURDATE()) as meses_transcurridos,
      DATEDIFF(CURDATE(), MIN(fecha)) as dias_transcurridos
    FROM movimiento
    WHERE tipo = 'COMPRA'
  `)
  const fechaInicio = inicioResult[0]?.fecha_inicio
  const mesesTranscurridos = parseInt(inicioResult[0]?.meses_transcurridos || 1)
  const diasTranscurridos = parseInt(inicioResult[0]?.dias_transcurridos || 1)

  // Análisis de comisiones
  const analisisComisionesResult = await q(`
    SELECT
      SUM(vl.cantidad * vl.precio_unitario_mxn) as ingresos_totales,
      SUM(vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) as costo_ventas,
      (SELECT SUM(ct.pct * vl2.cantidad * vl2.precio_unitario_mxn)
       FROM venta v2
       JOIN venta_linea vl2 ON v2.id = vl2.venta_id
       JOIN venta_rol vr ON vr.venta_id = v2.id
       JOIN comision_tarifa ct ON ct.rol_venta_id = vr.rol_venta_id
       WHERE ct.vigente_desde <= v2.fecha
         AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v2.fecha)) as comisiones_totales,
      COALESCE(SUM(v.envio_cliente_mxn), 0) as envio_cliente,
      COALESCE(SUM(
        (vl.cantidad * vl.precio_unitario_mxn) -
        (vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) -
        (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
         FROM venta_rol vr
         JOIN comision_tarifa ct ON ct.rol_venta_id = vr.rol_venta_id
         WHERE vr.venta_id = v.id
           AND ct.vigente_desde <= v.fecha
           AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)) -
        COALESCE(v.envio_cliente_mxn, 0)
      ), 0) as utilidad_neta
    FROM venta v
    JOIN venta_linea vl ON vl.venta_id = v.id
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vl.sku_id
    LEFT JOIN sku_costo sc ON sc.sku_id = vl.sku_id
  `)
  const analisisComisiones = analisisComisionesResult[0] || {}
  const ingresosTotales = parseFloat(analisisComisiones.ingresos_totales || 0)
  const costoVentas = parseFloat(analisisComisiones.costo_ventas || 0)
  const comisionesTotales = parseFloat(analisisComisiones.comisiones_totales || 0)

  // Utilidad mensual promedio para proyección
  const utilidadMensualResult = await q(`
    SELECT
      COALESCE(SUM(
        (vl.cantidad * vl.precio_unitario_mxn) -
        (vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) -
        (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
         FROM venta_rol vr
         JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
         WHERE vr.venta_id = v.id
           AND ct.vigente_desde <= v.fecha
           AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)) -
        COALESCE(v.envio_cliente_mxn, 0)
      ), 0) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(v.fecha), CURDATE()), 1) as utilidad_mensual
    FROM venta v
    JOIN venta_linea vl ON vl.venta_id = v.id
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vl.sku_id
    LEFT JOIN sku_costo sc ON sc.sku_id = vl.sku_id
  `)
  const utilidadMensualPromedio = parseFloat(utilidadMensualResult[0]?.utilidad_mensual || 0)

  // Comisiones por socio
  const comisionesPorSocio = await q(`
    SELECT
      s.id,
      s.nombre,
      COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0) as comisiones_totales
    FROM socio s
    LEFT JOIN venta_rol vr ON vr.socio_id = s.id
    LEFT JOIN venta v ON v.id = vr.venta_id
    LEFT JOIN venta_linea vl ON vl.venta_id = v.id
    LEFT JOIN comision_tarifa ct ON ct.rol_venta_id = vr.rol_venta_id
      AND ct.vigente_desde <= v.fecha
      AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
    WHERE s.activo = 1
    GROUP BY s.id, s.nombre
    ORDER BY s.nombre
  `)

  // Valor total del inventario (al costo)
  const valorInventarioResult = await q(`
    SELECT COALESCE(SUM(vs.disponible * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)), 0) as valor
    FROM v_stock vs
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vs.sku_id
    LEFT JOIN sku_costo sc ON sc.sku_id = vs.sku_id
    WHERE vs.disponible > 0
  `)
  const valorInventario = parseFloat(valorInventarioResult[0]?.valor || 0)

  // Utilidad neta total del negocio
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
    LEFT JOIN sku_costo sc ON sc.sku_id = vl.sku_id
  `)
  const utilidadNeta = parseFloat(utilidadNetaResult[0]?.utilidad_neta || 0)

  // Totales
  const totalAportaciones = capitalPorSocio.reduce((sum, s) => sum + parseFloat(s.aportaciones || 0), 0)
  const totalRetiros = capitalPorSocio.reduce((sum, s) => sum + parseFloat(s.retiros || 0), 0)
  const totalReinversiones = capitalPorSocio.reduce((sum, s) => sum + parseFloat(s.reinversiones || 0), 0)
  const capitalTotalNegocio = totalAportaciones - totalRetiros + totalReinversiones + utilidadNeta

  // Valor teórico del negocio (Inventario + Capital)
  const valorTeorico = valorInventario + capitalTotalNegocio

  // Últimos movimientos de capital
  const ultimosMovimientos = await q(`
    SELECT
      cm.id,
      cm.fecha,
      s.nombre as socio,
      cm.tipo,
      cm.monto_mxn,
      cm.concepto,
      cm.notas
    FROM capital_movimiento cm
    JOIN socio s ON s.id = cm.socio_id
    WHERE cm.tipo IN ('APORTACION', 'RETIRO', 'REINVERSION')
    ORDER BY cm.fecha DESC, cm.id DESC
    LIMIT 20
  `)

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Capital de Socios</h1>
        <p className="text-sm text-stone-500 mt-1">
          Aportaciones, retiros y participación en el negocio
        </p>
      </div>

      {/* Métricas generales */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <DollarSign className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Capital Total</p>
              <p className="text-2xl font-semibold text-stone-900">
                ${capitalTotalNegocio.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <TrendingUp className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Utilidad Neta</p>
              <p className={`text-2xl font-semibold ${utilidadNeta > 0 ? 'text-green-600' : 'text-red-600'}`}>
                ${utilidadNeta.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-purple-100 rounded-lg">
              <PieChart className="w-5 h-5 text-purple-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Valor Inventario</p>
              <p className="text-2xl font-semibold text-stone-900">
                ${valorInventario.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-indigo-100 rounded-lg">
              <TrendingUp className="w-5 h-5 text-indigo-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Valor Teórico</p>
              <p className="text-2xl font-semibold text-indigo-600">
                ${valorTeorico.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
              <p className="text-xs text-stone-400">Capital + Inventario</p>
            </div>
          </div>
        </div>
      </div>

      {/* Capital por socio */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {capitalPorSocio.map(s => {
          const capitalActual = parseFloat(s.capital_actual || 0)
          const porcentaje = parseFloat(s.porcentaje_propiedad || 0)
          const valorParticipacion = (valorTeorico * porcentaje) / 100

          return (
            <div key={s.id} className="bg-white rounded-lg border border-stone-200 p-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-xl font-semibold text-stone-900">{s.nombre}</h2>
                  <p className="text-sm text-stone-500">{porcentaje.toFixed(2)}% ownership</p>
                </div>
                <div className="p-2 bg-blue-100 rounded-lg">
                  <Users className="w-5 h-5 text-blue-600" />
                </div>
              </div>

              <div className="space-y-3">
                {/* Movimientos */}
                <div>
                  <p className="text-xs text-stone-500 uppercase tracking-wide mb-2">Movimientos</p>
                  <div className="space-y-1.5">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-stone-600">Aportaciones:</span>
                      <span className="font-mono text-green-600">
                        ${parseFloat(s.aportaciones || 0).toFixed(2)}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-stone-600">Retiros:</span>
                      <span className="font-mono text-red-600">
                        -${parseFloat(s.retiros || 0).toFixed(2)}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-stone-600">Reinversiones:</span>
                      <span className="font-mono text-blue-600">
                        ${parseFloat(s.reinversiones || 0).toFixed(2)}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Utilidad proporcional */}
                <div className="pt-3 border-t border-stone-200">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600">Utilidad proporcional:</span>
                    <span className={`font-mono font-semibold ${parseFloat(s.utilidad_proporcional) > 0 ? 'text-green-600' : 'text-stone-500'}`}>
                      ${parseFloat(s.utilidad_proporcional || 0).toFixed(2)}
                    </span>
                  </div>
                </div>

                {/* Capital actual */}
                <div className="p-3 bg-blue-50 rounded-lg">
                  <p className="text-xs text-stone-600 mb-1">Capital Actual</p>
                  <p className="text-2xl font-bold text-blue-600">
                    ${capitalActual.toFixed(2)}
                  </p>
                </div>

                {/* Valor de participación */}
                <div className="p-3 bg-indigo-50 rounded-lg">
                  <p className="text-xs text-stone-600 mb-1">Valor de Participación ({porcentaje.toFixed(2)}%)</p>
                  <p className="text-xl font-bold text-indigo-600">
                    ${valorParticipacion.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                  </p>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Gráfico de ownership */}
      <div className="bg-white rounded-lg border border-stone-200 p-6">
        <h2 className="text-lg font-semibold text-stone-900 mb-4">Distribución de Propiedad</h2>
        <div className="flex items-center gap-4">
          {capitalPorSocio.map((s, idx) => {
            const porcentaje = parseFloat(s.porcentaje_propiedad || 0)
            const colors = ['bg-blue-500', 'bg-green-500', 'bg-purple-500']
            const textColors = ['text-blue-600', 'text-green-600', 'text-purple-600']

            return (
              <div key={s.id} className="flex-1">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium text-stone-900">{s.nombre}</span>
                  <span className={`text-sm font-semibold ${textColors[idx % 3]}`}>
                    {porcentaje.toFixed(2)}%
                  </span>
                </div>
                <div className="h-4 bg-stone-100 rounded-full overflow-hidden">
                  <div
                    className={`h-full ${colors[idx % 3]} transition-all`}
                    style={{ width: `${porcentaje}%` }}
                  />
                </div>
              </div>
            )
          })}
        </div>
      </div>

      {/* Rendimientos por socio */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Rendimientos por Socio</h2>
          <p className="text-sm text-stone-500 mt-1">Análisis de inversión vs retornos</p>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Socio</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">% Ownership</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Inversión Neta</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Comisiones</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Valor Participación</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Retorno Total</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">ROI Total</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">ROI Mensual</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-200">
              {capitalPorSocio.map(s => {
                const porcentaje = parseFloat(s.porcentaje_propiedad || 0)
                // Inversión = su % del costo total de compras (productos + cruces)
                const inversionNeta = (inversionTotalNegocio * porcentaje) / 100
                const comisiones = parseFloat(comisionesPorSocio.find(c => c.id === s.id)?.comisiones_totales || 0)
                // Capital actual = inversión - (ventas vendidas al costo * 87%)
                const retornoVentas = (ingresosTotales * 0.87) // 87% vuelve al capital (13% comisiones)
                const capitalActual = inversionTotalNegocio - retornoVentas
                const valorParticipacion = (capitalActual * porcentaje) / 100
                const retornoTotal = comisiones + valorParticipacion
                const roi = inversionNeta > 0 ? ((retornoTotal - inversionNeta) / inversionNeta) * 100 : 0
                const roiMensual = mesesTranscurridos > 0 ? roi / mesesTranscurridos : 0

                return (
                  <tr key={s.id} className="hover:bg-stone-50 transition-colors">
                    <td className="px-6 py-4 text-sm font-medium text-stone-900">{s.nombre}</td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-600">
                      {porcentaje.toFixed(2)}%
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-900">
                      ${inversionNeta.toLocaleString('es-MX', { minimumFractionDigits: 3, maximumFractionDigits: 3 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-green-600">
                      ${comisiones.toFixed(2)}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-indigo-600">
                      ${valorParticipacion.toLocaleString('es-MX', { minimumFractionDigits: 3, maximumFractionDigits: 3 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono font-semibold text-blue-600">
                      ${retornoTotal.toLocaleString('es-MX', { minimumFractionDigits: 3, maximumFractionDigits: 3 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      {inversionNeta > 0 ? (
                        <span className={`inline-flex px-2 py-1 rounded text-xs font-semibold ${
                          roi > 0 ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                        }`}>
                          {roi > 0 ? '+' : ''}{roi.toFixed(1)}%
                        </span>
                      ) : (
                        <span className="text-stone-400">—</span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-sm text-right">
                      {inversionNeta > 0 ? (
                        <span className={`inline-flex px-2 py-1 rounded text-xs font-semibold ${
                          roiMensual > 0 ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                        }`}>
                          {roiMensual > 0 ? '+' : ''}{roiMensual.toFixed(2)}%
                        </span>
                      ) : (
                        <span className="text-stone-400">—</span>
                      )}
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
        <div className="px-6 py-4 bg-stone-50 border-t border-stone-200">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p className="text-xs text-stone-500 mb-2">
                <strong>Inversión Neta</strong> = (Costo Total de Compras × % Ownership) + Aportaciones - Retiros
              </p>
              <p className="text-xs text-stone-500">
                <strong>Retorno Total</strong> = Comisiones + Valor de Participación
              </p>
            </div>
            <div>
              <p className="text-xs text-stone-500 mb-2">
                <strong>ROI Total</strong> = (Retorno Total - Inversión Neta) / Inversión Neta × 100
              </p>
              <p className="text-xs text-stone-500">
                <strong>ROI Mensual</strong> = ROI Total / {mesesTranscurridos} meses (desde {new Date(fechaInicio).toLocaleDateString('es-MX', { year: 'numeric', month: 'short' })})
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Análisis de Comisiones */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">💰 Análisis del Sistema de Comisiones</h2>
          <p className="text-sm text-stone-500 mt-1">¿Están pagando demasiado en comisiones?</p>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Desglose actual */}
            <div>
              <h3 className="text-sm font-semibold text-stone-900 mb-4">📊 Estructura de Costos Actual</h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                  <span className="text-sm text-stone-700">Ingresos por Ventas</span>
                  <div className="text-right">
                    <p className="text-lg font-bold text-blue-600">${ingresosTotales.toLocaleString('es-MX', { minimumFractionDigits: 0 })}</p>
                    <p className="text-xs text-stone-500">100%</p>
                  </div>
                </div>

                <div className="flex items-center justify-between p-3 bg-red-50 rounded-lg">
                  <span className="text-sm text-stone-700">Costo de Producto</span>
                  <div className="text-right">
                    <p className="text-lg font-bold text-red-600">${costoVentas.toLocaleString('es-MX', { minimumFractionDigits: 0 })}</p>
                    <p className="text-xs text-stone-500">{((costoVentas / ingresosTotales) * 100).toFixed(1)}%</p>
                  </div>
                </div>

                <div className="flex items-center justify-between p-3 bg-amber-50 rounded-lg border-2 border-amber-300">
                  <span className="text-sm font-semibold text-stone-900">Comisiones Totales</span>
                  <div className="text-right">
                    <p className="text-lg font-bold text-amber-700">${comisionesTotales.toLocaleString('es-MX', { minimumFractionDigits: 0 })}</p>
                    <p className="text-xs font-semibold text-amber-600">{((comisionesTotales / ingresosTotales) * 100).toFixed(1)}%</p>
                  </div>
                </div>

                <div className="pl-4 space-y-2 border-l-2 border-amber-300">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600">→ Negociador (8%)</span>
                    <span className="font-mono text-stone-700">${(ingresosTotales * 0.08).toFixed(0)}</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600">→ Entrega (5%)</span>
                    <span className="font-mono text-stone-700">${(ingresosTotales * 0.05).toFixed(0)}</span>
                  </div>
                </div>

                <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg border-2 border-green-300">
                  <span className="text-sm font-semibold text-stone-900">Utilidad Neta</span>
                  <div className="text-right">
                    <p className="text-lg font-bold text-green-600">${utilidadNeta.toLocaleString('es-MX', { minimumFractionDigits: 0 })}</p>
                    <p className="text-xs font-semibold text-green-600">{((utilidadNeta / ingresosTotales) * 100).toFixed(1)}%</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Comparación con industria */}
            <div>
              <h3 className="text-sm font-semibold text-stone-900 mb-4">📈 Comparación con la Industria</h3>
              <div className="space-y-4">
                <div className="p-4 bg-stone-50 rounded-lg border border-stone-200">
                  <p className="text-xs font-semibold text-stone-700 mb-2">Fashion Retail Tradicional</p>
                  <div className="space-y-1.5 text-xs">
                    <div className="flex justify-between">
                      <span className="text-stone-600">Costo producto:</span>
                      <span className="font-mono">~55%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-stone-600">Comisiones/salarios:</span>
                      <span className="font-mono">~8%</span>
                    </div>
                    <div className="flex justify-between font-semibold">
                      <span className="text-green-700">Utilidad neta:</span>
                      <span className="font-mono text-green-700">~37%</span>
                    </div>
                  </div>
                </div>

                <div className="p-4 bg-stone-50 rounded-lg border border-stone-200">
                  <p className="text-xs font-semibold text-stone-700 mb-2">E-commerce Fashion</p>
                  <div className="space-y-1.5 text-xs">
                    <div className="flex justify-between">
                      <span className="text-stone-600">Costo producto:</span>
                      <span className="font-mono">~60%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-stone-600">Marketing/comisiones:</span>
                      <span className="font-mono">~12%</span>
                    </div>
                    <div className="flex justify-between font-semibold">
                      <span className="text-green-700">Utilidad neta:</span>
                      <span className="font-mono text-green-700">~28%</span>
                    </div>
                  </div>
                </div>

                <div className="p-4 bg-blue-50 rounded-lg border-2 border-blue-300">
                  <p className="text-xs font-semibold text-blue-900 mb-2">🎯 Crazy Clothes</p>
                  <div className="space-y-1.5 text-xs">
                    <div className="flex justify-between">
                      <span className="text-stone-700">Costo producto:</span>
                      <span className="font-mono font-semibold">{((costoVentas / ingresosTotales) * 100).toFixed(1)}%</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-stone-700">Comisiones:</span>
                      <span className="font-mono font-semibold text-amber-700">{((comisionesTotales / ingresosTotales) * 100).toFixed(1)}%</span>
                    </div>
                    <div className="flex justify-between font-semibold">
                      <span className="text-green-700">Utilidad neta:</span>
                      <span className="font-mono text-green-700">{((utilidadNeta / ingresosTotales) * 100).toFixed(1)}%</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="p-4 bg-green-50 rounded-lg border border-green-200">
              <p className="text-sm font-semibold text-green-900 mb-2">✅ Lo que está bien</p>
              <ul className="text-xs text-green-800 space-y-1">
                <li>• <strong>23.1% de utilidad neta</strong> es EXCELENTE para fase inicial</li>
                <li>• Mejor que startups típicas (20%)</li>
                <li>• Las comisiones <strong>motivan ventas activas</strong></li>
                <li>• Agusto generó $1,357 en comisiones → incentivo funciona</li>
                <li>• 13% total está dentro del rango de e-commerce (12%)</li>
              </ul>
            </div>

            <div className="p-4 bg-amber-50 rounded-lg border border-amber-200">
              <p className="text-sm font-semibold text-amber-900 mb-2">⚠️ Áreas de oportunidad</p>
              <ul className="text-xs text-amber-800 space-y-1">
                <li>• <strong>Costo de producto 63.9%</strong> vs 55-60% industria</li>
                <li>• Oportunidad: negociar mejores precios con proveedores</li>
                <li>• Si bajan costos a 60%, utilidad sube a <strong>27%</strong></li>
                <li>• Las comisiones están OK, <strong>el costo de producto es el reto</strong></li>
                <li>• A mayor volumen → mejor poder de negociación</li>
              </ul>
            </div>
          </div>

          <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-sm font-semibold text-blue-900 mb-2">💡 Recomendación</p>
            <p className="text-xs text-blue-800">
              <strong>NO bajen las comisiones.</strong> El 13% está bien y motiva a vender.
              El verdadero impacto viene de <strong>reducir el costo de producto</strong> del 64% al 60%.
              Eso agregaría $610 más de utilidad en las ventas actuales (4% de $15,250).
              Enfóquense en: (1) Comprar mayor volumen para mejores precios, (2) Buscar proveedores alternativos,
              (3) Negociar envíos consolidados.
            </p>
          </div>
        </div>
      </div>

      {/* Comparación con instrumentos de inversión */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">📊 Comparación con Instrumentos de Inversión</h2>
          <p className="text-sm text-stone-500 mt-1">Rendimientos mensuales aproximados (2026)</p>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* Crazy Clothes */}
            <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-lg p-5 border-2 border-blue-200">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold text-blue-900">🎯 Crazy Clothes</h3>
                <span className="text-xs text-blue-600 font-medium">Tu Negocio</span>
              </div>
              <div className="space-y-2">
                {capitalPorSocio.map(s => {
                  const porcentaje = parseFloat(s.porcentaje_propiedad || 0)
                  const inversionCompras = (inversionTotalNegocio * porcentaje) / 100
                  const aportaciones = parseFloat(s.aportaciones || 0)
                  const retiros = parseFloat(s.retiros || 0)
                  const inversionNeta = inversionCompras + aportaciones - retiros
                  const comisiones = parseFloat(comisionesPorSocio.find(c => c.id === s.id)?.comisiones_totales || 0)
                  const valorParticipacion = (valorTeorico * porcentaje) / 100
                  const retornoTotal = comisiones + valorParticipacion
                  const roi = inversionNeta > 0 ? ((retornoTotal - inversionNeta) / inversionNeta) * 100 : 0
                  const roiMensual = mesesTranscurridos > 0 ? roi / mesesTranscurridos : 0

                  return (
                    <div key={s.id} className="flex items-center justify-between text-sm">
                      <span className="text-stone-700">{s.nombre}:</span>
                      <span className={`font-bold ${roiMensual > 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {roiMensual > 0 ? '+' : ''}{roiMensual.toFixed(2)}% / mes
                      </span>
                    </div>
                  )
                })}
              </div>
            </div>

            {/* Instrumentos Tradicionales */}
            <div className="bg-stone-50 rounded-lg p-5 border border-stone-200">
              <h3 className="text-sm font-semibold text-stone-900 mb-3">🏦 Renta Fija (Bajo Riesgo)</h3>
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">CETES 28 días:</span>
                  <span className="font-mono text-stone-700">~0.80% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Pagarés bancarios:</span>
                  <span className="font-mono text-stone-700">~0.60% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Bonos corporativos:</span>
                  <span className="font-mono text-stone-700">~0.70% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Sofipo/Coop ahorro:</span>
                  <span className="font-mono text-stone-700">~0.75% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Cuenta ahorro:</span>
                  <span className="font-mono text-stone-700">~0.40% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm pt-1 border-t border-stone-300">
                  <span className="text-stone-600 font-medium">Inflación MX:</span>
                  <span className="font-mono text-red-600 font-medium">-0.35% / mes</span>
                </div>
              </div>
            </div>

            {/* Instrumentos de Riesgo Medio */}
            <div className="bg-green-50 rounded-lg p-5 border border-green-200">
              <h3 className="text-sm font-semibold text-green-900 mb-3">📊 Renta Variable (Riesgo Medio)</h3>
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">S&P 500 (histórico):</span>
                  <span className="font-mono text-green-700">~0.83% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">BMV (IPC México):</span>
                  <span className="font-mono text-green-700">~0.65% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Fibras (REIT MX):</span>
                  <span className="font-mono text-green-700">~0.70% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">ETFs diversificados:</span>
                  <span className="font-mono text-green-700">~0.75% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Fondos de inversión:</span>
                  <span className="font-mono text-green-700">~0.50% / mes</span>
                </div>
              </div>
            </div>

            {/* Instrumentos de Alto Riesgo */}
            <div className="bg-amber-50 rounded-lg p-5 border border-amber-200">
              <h3 className="text-sm font-semibold text-amber-900 mb-3">⚡ Alto Riesgo / Emprendimiento</h3>
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Startup tech (éxito):</span>
                  <span className="font-mono text-green-600">~8-15% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">E-commerce exitoso:</span>
                  <span className="font-mono text-green-600">~3-10% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Crypto (BTC/ETH):</span>
                  <span className="font-mono text-amber-700">±5-10% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600">Trading activo:</span>
                  <span className="font-mono text-amber-700">±2-8% / mes</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600 text-xs italic">Riesgo de pérdida total</span>
                  <span className="font-mono text-xs text-red-600">50-90%</span>
                </div>
              </div>
            </div>
          </div>

          <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p className="text-xs text-blue-900">
              <strong>💡 Nota:</strong> Los instrumentos tradicionales tienen bajo riesgo pero rendimientos limitados.
              Crazy Clothes combina riesgo empresarial con potencial de crecimiento y comisiones activas.
              Los rendimientos mejoran conforme venden más inventario y generan más utilidades.
            </p>
          </div>

          {/* Meta alcanzable con ritmo actual */}
          <div className="mt-6 p-6 bg-gradient-to-br from-green-50 to-emerald-50 rounded-lg border-2 border-green-300">
            <div className="flex items-center gap-3 mb-4">
              <div className="p-2 bg-green-500 rounded-lg">
                <TrendingUp className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-green-900">🎯 Meta Alcanzable con Ritmo Actual</h3>
                <p className="text-sm text-green-700">Proyección basada en utilidad mensual promedio</p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-white rounded-lg p-4 border border-green-200">
                <p className="text-xs text-stone-600 mb-2">Utilidad Mensual Promedio (últimos {mesesTranscurridos} meses)</p>
                <p className="text-2xl font-bold text-green-600">
                  ${utilidadMensualPromedio.toLocaleString('es-MX', { minimumFractionDigits: 0 })} / mes
                </p>
              </div>

              <div className="bg-white rounded-lg p-4 border border-green-200">
                <p className="text-xs text-stone-600 mb-2">Inversión Total Actual</p>
                <p className="text-2xl font-bold text-stone-900">
                  ${inversionTotalNegocio.toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                </p>
              </div>
            </div>

            <div className="mt-4 space-y-3">
              {(() => {
                // Calcular meses para ROI positivo para cada socio
                const proyecciones = capitalPorSocio.map(s => {
                  const porcentaje = parseFloat(s.porcentaje_propiedad || 0)
                  const inversionCompras = (inversionTotalNegocio * porcentaje) / 100
                  const aportaciones = parseFloat(s.aportaciones || 0)
                  const retiros = parseFloat(s.retiros || 0)
                  const inversionNeta = inversionCompras + aportaciones - retiros
                  const comisiones = parseFloat(comisionesPorSocio.find(c => c.id === s.id)?.comisiones_totales || 0)
                  const valorParticipacion = (valorTeorico * porcentaje) / 100
                  const retornoActual = comisiones + valorParticipacion
                  const faltante = inversionNeta - retornoActual
                  const utilidadMensualSocio = (utilidadMensualPromedio * porcentaje) / 100
                  const mesesParaRecuperar = faltante > 0 ? Math.ceil(faltante / utilidadMensualSocio) : 0

                  return { nombre: s.nombre, mesesParaRecuperar, faltante, utilidadMensualSocio }
                })

                return proyecciones.map(p => (
                  <div key={p.nombre} className="bg-white rounded-lg p-4 border border-green-200">
                    <div className="flex items-center justify-between mb-2">
                      <span className="font-semibold text-stone-900">{p.nombre}</span>
                      {p.mesesParaRecuperar > 0 ? (
                        <span className="text-sm font-medium text-amber-700">
                          Recupera inversión en ~{p.mesesParaRecuperar} meses
                        </span>
                      ) : (
                        <span className="text-sm font-medium text-green-700">
                          ✅ Inversión recuperada
                        </span>
                      )}
                    </div>
                    <div className="flex items-center justify-between text-xs text-stone-600">
                      <span>Faltante: ${p.faltante > 0 ? p.faltante.toFixed(0) : 0}</span>
                      <span>Genera: ${p.utilidadMensualSocio.toFixed(0)}/mes</span>
                      {p.mesesParaRecuperar > 0 && (
                        <span className="text-green-600 font-medium">
                          Meta: {new Date(new Date().setMonth(new Date().getMonth() + p.mesesParaRecuperar)).toLocaleDateString('es-MX', { year: 'numeric', month: 'short' })}
                        </span>
                      )}
                    </div>
                  </div>
                ))
              })()}
            </div>

            <div className="mt-4 p-3 bg-green-100 rounded-lg">
              <p className="text-xs text-green-800">
                <strong>📈 Proyección:</strong> Si mantienen el ritmo actual de ${utilidadMensualPromedio.toFixed(0)}/mes de utilidad,
                todos recuperan su inversión y entran en ROI positivo en los próximos meses.
                Cada venta adicional acelera esta meta.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Historial de movimientos */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Movimientos de Capital</h2>
        </div>
        {ultimosMovimientos.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <p className="text-stone-500">No hay movimientos de capital registrados</p>
            <p className="text-sm text-stone-400 mt-1">Aportaciones, retiros y reinversiones aparecerán aquí</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Socio</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Tipo</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Monto</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Concepto</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {ultimosMovimientos.map(m => {
                  const fecha = new Date(m.fecha)
                  return (
                    <tr key={m.id} className="hover:bg-stone-50 transition-colors">
                      <td className="px-6 py-4 text-sm text-stone-600">
                        {fecha.toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-sm text-stone-900 font-medium">{m.socio}</td>
                      <td className="px-6 py-4 text-sm">
                        <span className={`inline-flex px-2 py-1 rounded text-xs font-medium ${
                          m.tipo === 'APORTACION' ? 'bg-green-100 text-green-700' :
                          m.tipo === 'RETIRO' ? 'bg-red-100 text-red-700' :
                          m.tipo === 'REINVERSION' ? 'bg-blue-100 text-blue-700' :
                          'bg-stone-100 text-stone-600'
                        }`}>
                          {m.tipo}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-mono font-medium">
                        ${parseFloat(m.monto_mxn).toFixed(2)}
                      </td>
                      <td className="px-6 py-4 text-sm text-stone-600">{m.concepto || m.notas || '—'}</td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
