import { q } from '@/lib/db'
import { Banknote, TrendingUp, TrendingDown, Plus, CheckCircle } from 'lucide-react'
import FormDeuda from './FormDeuda'
import { marcarDeudaPagada } from '@/lib/actions'

export const dynamic = 'force-dynamic'

export default async function DeudasPage() {
  // Balance por socio
  const balances = await q(`SELECT * FROM v_deuda_balance ORDER BY nombre`)

  // Deudas activas
  const deudasActivas = await q(`
    SELECT
      p.id,
      p.fecha,
      sa.nombre as acreedor,
      sd.nombre as deudor,
      p.monto_mxn,
      p.motivo,
      p.fecha_vencimiento,
      DATEDIFF(p.fecha_vencimiento, CURDATE()) as dias_para_vencer
    FROM prestamo p
    JOIN socio sa ON sa.id = p.socio_acreedor_id
    JOIN socio sd ON sd.id = p.socio_deudor_id
    WHERE p.pagado = FALSE
    ORDER BY p.fecha_vencimiento ASC, p.fecha DESC
  `)

  // Historial de deudas pagadas
  const historial = await q(`
    SELECT
      p.id,
      p.fecha,
      sa.nombre as acreedor,
      sd.nombre as deudor,
      p.monto_mxn,
      p.motivo,
      p.fecha_pago
    FROM prestamo p
    JOIN socio sa ON sa.id = p.socio_acreedor_id
    JOIN socio sd ON sd.id = p.socio_deudor_id
    WHERE p.pagado = TRUE
    ORDER BY p.fecha_pago DESC
    LIMIT 20
  `)

  const totalActivo = deudasActivas.reduce((sum, d) => sum + parseFloat(d.monto_mxn), 0)
  const deudasVencidas = deudasActivas.filter(d => d.dias_para_vencer < 0).length

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Deudas entre Socios</h1>
          <p className="text-sm text-stone-500 mt-1">
            {deudasActivas.length} activas · ${totalActivo.toLocaleString('es-MX', { minimumFractionDigits: 0 })} en circulación
            {deudasVencidas > 0 && <span className="text-red-600 font-medium"> · {deudasVencidas} vencidas</span>}
          </p>
        </div>
        <FormDeuda />
      </div>

      {/* Balance por socio */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {balances.map(b => {
          const porCobrar = parseFloat(b.por_cobrar || 0)
          const porPagar = parseFloat(b.por_pagar || 0)
          const balance = parseFloat(b.balance_neto || 0)

          return (
            <div key={b.socio_id} className="bg-white rounded-lg border border-stone-200 p-5">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-stone-900">{b.nombre}</h3>
                <Banknote className="w-5 h-5 text-stone-400" />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600 flex items-center gap-1">
                    <TrendingUp className="w-4 h-4 text-green-600" />
                    Por cobrar:
                  </span>
                  <span className="font-mono text-green-600">
                    ${porCobrar.toFixed(0)}
                  </span>
                </div>

                <div className="flex items-center justify-between text-sm">
                  <span className="text-stone-600 flex items-center gap-1">
                    <TrendingDown className="w-4 h-4 text-red-600" />
                    Por pagar:
                  </span>
                  <span className="font-mono text-red-600">
                    ${porPagar.toFixed(0)}
                  </span>
                </div>

                <div className="pt-3 border-t border-stone-200">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-semibold text-stone-900">Balance neto:</span>
                    <span className={`text-lg font-bold ${
                      balance > 0 ? 'text-green-600' :
                      balance < 0 ? 'text-red-600' :
                      'text-stone-500'
                    }`}>
                      {balance > 0 ? '+' : ''}{balance === 0 ? '$0' : `$${balance.toFixed(0)}`}
                    </span>
                  </div>
                  <p className="text-xs text-stone-500 mt-1">
                    {balance > 0 ? 'Le deben dinero' : balance < 0 ? 'Debe dinero' : 'Cuentas saldadas'}
                  </p>
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Deudas activas */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Deudas Activas</h2>
        </div>
        {deudasActivas.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <Banknote className="w-12 h-12 mx-auto mb-3 text-stone-300" />
            <p className="text-stone-500">No hay deudas activas</p>
            <p className="text-sm text-stone-400 mt-1">Todas las cuentas están saldadas</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Acreedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Deudor</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Monto</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Motivo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Vence</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {deudasActivas.map(d => {
                  const vencida = d.dias_para_vencer < 0
                  const proxima = d.dias_para_vencer >= 0 && d.dias_para_vencer <= 7

                  return (
                    <tr key={d.id} className={`hover:bg-stone-50 transition-colors ${vencida ? 'bg-red-50' : ''}`}>
                      <td className="px-6 py-4 text-sm text-stone-600">
                        {new Date(d.fecha).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-sm font-medium text-green-700">{d.acreedor}</td>
                      <td className="px-6 py-4 text-sm font-medium text-red-700">{d.deudor}</td>
                      <td className="px-6 py-4 text-sm text-right font-mono font-semibold text-stone-900">
                        ${parseFloat(d.monto_mxn).toFixed(0)}
                      </td>
                      <td className="px-6 py-4 text-sm text-stone-600">{d.motivo || '—'}</td>
                      <td className="px-6 py-4 text-sm">
                        {d.fecha_vencimiento ? (
                          <div>
                            <p className={vencida ? 'text-red-600 font-medium' : proxima ? 'text-amber-600 font-medium' : 'text-stone-600'}>
                              {new Date(d.fecha_vencimiento).toLocaleDateString('es-MX', { month: 'short', day: 'numeric' })}
                            </p>
                            <p className="text-xs text-stone-500">
                              {vencida ? `Vencida hace ${Math.abs(d.dias_para_vencer)} días` :
                               proxima ? `En ${d.dias_para_vencer} días` :
                               `Faltan ${d.dias_para_vencer} días`}
                            </p>
                          </div>
                        ) : (
                          <span className="text-stone-400">Sin vencimiento</span>
                        )}
                      </td>
                      <td className="px-6 py-4 text-sm text-right">
                        <form action={marcarDeudaPagada}>
                          <input type="hidden" name="id" value={d.id} />
                          <button
                            type="submit"
                            className="inline-flex items-center gap-1 px-3 py-1 text-xs font-medium text-green-700 bg-green-100 rounded hover:bg-green-200 transition-colors"
                          >
                            <CheckCircle className="w-3 h-3" />
                            Marcar Pagada
                          </button>
                        </form>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Historial */}
      {historial.length > 0 && (
        <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-200">
            <h2 className="text-lg font-semibold text-stone-900">Historial (Últimas 20 pagadas)</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha Préstamo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Acreedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Deudor</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Monto</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Motivo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Pagado</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {historial.map(d => (
                  <tr key={d.id} className="hover:bg-stone-50 transition-colors opacity-60">
                    <td className="px-6 py-4 text-sm text-stone-600">
                      {new Date(d.fecha).toLocaleDateString('es-MX', { month: 'short', day: 'numeric' })}
                    </td>
                    <td className="px-6 py-4 text-sm text-stone-600">{d.acreedor}</td>
                    <td className="px-6 py-4 text-sm text-stone-600">{d.deudor}</td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-900">
                      ${parseFloat(d.monto_mxn).toFixed(0)}
                    </td>
                    <td className="px-6 py-4 text-sm text-stone-600">{d.motivo || '—'}</td>
                    <td className="px-6 py-4 text-sm text-green-600">
                      {new Date(d.fecha_pago).toLocaleDateString('es-MX', { month: 'short', day: 'numeric' })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
