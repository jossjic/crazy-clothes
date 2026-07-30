import { q } from '@/lib/db'
import { DollarSign, TrendingUp, TrendingDown, Wallet } from 'lucide-react'

export const dynamic = 'force-dynamic'

export default async function ComisionesPage() {
  // Comisiones generadas por cada socio
  const comisionesPorSocio = await q(`
    SELECT
      s.id,
      s.nombre,
      -- Comisión Negociar
      COALESCE(SUM(
        CASE WHEN rv.nombre = 'NEGOCIADOR'
        THEN (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
              FROM comision_tarifa ct
              WHERE ct.rol_venta_id = vr.rol_venta_id
                AND ct.vigente_desde <= v.fecha
                AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha))
        ELSE 0 END
      ), 0) as comision_negociar,
      -- Comisión Entrega
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
    ORDER BY s.nombre
  `)

  // Movimientos de capital por socio (retiros y reinversiones)
  const movimientosPorSocio = await q(`
    SELECT
      s.id,
      s.nombre,
      COALESCE(SUM(CASE WHEN cm.tipo = 'RETIRO_COMISION' THEN cm.monto_mxn ELSE 0 END), 0) as retirado,
      COALESCE(SUM(CASE WHEN cm.tipo = 'REINVERSION' THEN cm.monto_mxn ELSE 0 END), 0) as reinvertido
    FROM socio s
    LEFT JOIN capital_movimiento cm ON cm.socio_id = s.id
    GROUP BY s.id, s.nombre
    ORDER BY s.nombre
  `)

  // Combinar datos
  const socios = comisionesPorSocio.map(c => {
    const mov = movimientosPorSocio.find(m => m.id === c.id) || { retirado: 0, reinvertido: 0 }
    const totalGenerado = parseFloat(c.comision_negociar || 0) + parseFloat(c.comision_entrega || 0)
    const retirado = parseFloat(mov.retirado || 0)
    const reinvertido = parseFloat(mov.reinvertido || 0)
    const disponible = totalGenerado - retirado - reinvertido

    return {
      ...c,
      totalGenerado,
      retirado,
      reinvertido,
      disponible
    }
  })

  // Últimos movimientos
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
    WHERE cm.tipo IN ('RETIRO_COMISION', 'REINVERSION')
    ORDER BY cm.fecha DESC, cm.id DESC
    LIMIT 20
  `)

  const totalDisponible = socios.reduce((sum, s) => sum + s.disponible, 0)

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Comisiones por Socio</h1>
        <p className="text-sm text-stone-500 mt-1">
          Detalle de comisiones generadas, retiradas y disponibles
        </p>
      </div>

      {/* Cards por socio */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {socios.map(s => (
          <div key={s.id} className="bg-white rounded-lg border border-stone-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold text-stone-900">{s.nombre}</h2>
              <div className={`p-2 rounded-lg ${s.disponible > 0 ? 'bg-green-100' : 'bg-stone-100'}`}>
                <Wallet className={`w-5 h-5 ${s.disponible > 0 ? 'text-green-600' : 'text-stone-400'}`} />
              </div>
            </div>

            <div className="space-y-3">
              {/* Comisiones generadas */}
              <div>
                <p className="text-xs text-stone-500 uppercase tracking-wide mb-1">Comisiones Generadas</p>
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600">Negociar (8%):</span>
                    <span className="font-mono text-blue-600">
                      ${parseFloat(s.comision_negociar || 0).toFixed(2)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-stone-600">Entrega (5%):</span>
                    <span className="font-mono text-blue-600">
                      ${parseFloat(s.comision_entrega || 0).toFixed(2)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-sm pt-1 border-t border-stone-200">
                    <span className="font-medium text-stone-900">Total:</span>
                    <span className="font-mono font-semibold text-stone-900">
                      ${s.totalGenerado.toFixed(2)}
                    </span>
                  </div>
                </div>
              </div>

              {/* Movimientos */}
              <div className="pt-3 border-t border-stone-200">
                <div className="flex items-center justify-between text-sm mb-1">
                  <span className="text-stone-600 flex items-center gap-1">
                    <TrendingDown className="w-3 h-3" />
                    Retirado:
                  </span>
                  <span className="font-mono text-red-600">
                    ${s.retirado.toFixed(2)}
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600 flex items-center gap-1">
                    <TrendingUp className="w-3 h-3" />
                    Reinvertido:
                  </span>
                  <span className="font-mono text-green-600">
                    ${s.reinvertido.toFixed(2)}
                  </span>
                </div>
              </div>

              {/* Disponible */}
              <div className={`p-3 rounded-lg ${s.disponible > 0 ? 'bg-green-50' : 'bg-stone-50'}`}>
                <p className="text-xs text-stone-600 mb-1">Disponible para retirar</p>
                <p className={`text-2xl font-bold ${s.disponible > 0 ? 'text-green-600' : 'text-stone-400'}`}>
                  ${s.disponible.toFixed(2)}
                </p>
              </div>

              {/* Botones de acción */}
              {s.disponible > 0 && (
                <div className="pt-2 space-y-2">
                  <button className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors">
                    Registrar Retiro
                  </button>
                  <button className="w-full px-4 py-2 bg-green-600 text-white rounded-lg text-sm font-medium hover:bg-green-700 transition-colors">
                    Reinvertir
                  </button>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {/* Resumen total */}
      <div className="bg-gradient-to-r from-blue-50 to-green-50 rounded-lg border border-blue-200 p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-stone-600 mb-1">Total Disponible para Retiro</p>
            <p className="text-3xl font-bold text-green-600">
              ${totalDisponible.toFixed(2)}
            </p>
          </div>
          <div className="p-3 bg-white rounded-lg">
            <DollarSign className="w-8 h-8 text-green-600" />
          </div>
        </div>
      </div>

      {/* Últimos movimientos */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Historial de Movimientos</h2>
        </div>
        {ultimosMovimientos.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <p className="text-stone-500">No hay movimientos registrados</p>
            <p className="text-sm text-stone-400 mt-1">Los retiros y reinversiones aparecerán aquí</p>
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
                          m.tipo === 'RETIRO_COMISION' ? 'bg-red-100 text-red-700' :
                          m.tipo === 'REINVERSION' ? 'bg-green-100 text-green-700' :
                          'bg-blue-100 text-blue-700'
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
