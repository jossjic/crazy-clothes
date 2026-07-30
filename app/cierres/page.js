import { q } from '@/lib/db'
import { Calendar, TrendingUp, DollarSign, Package, ChevronRight } from 'lucide-react'
import FormCierre from './FormCierre'

export const dynamic = 'force-dynamic'

export default async function CierresPage() {
  const cierres = await q(`
    SELECT * FROM cierre_mensual
    ORDER BY anio DESC, mes DESC
  `)

  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Cierres Mensuales</h1>
          <p className="text-sm text-stone-500 mt-1">
            Histórico de snapshots financieros · {cierres.length} cierres registrados
          </p>
        </div>
        <FormCierre />
      </div>

      {/* Último cierre destacado */}
      {cierres.length > 0 && (
        <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-lg border-2 border-blue-200 p-6">
          <div className="flex items-center gap-2 mb-4">
            <Calendar className="w-5 h-5 text-blue-600" />
            <h2 className="text-lg font-semibold text-blue-900">
              Último Cierre: {meses[cierres[0].mes - 1]} {cierres[0].anio}
            </h2>
            <span className="text-sm text-blue-600">
              Cerrado el {new Date(cierres[0].fecha_cierre).toLocaleDateString('es-MX')}
            </span>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-white rounded-lg p-4">
              <p className="text-xs text-stone-500 uppercase tracking-wide mb-1">Ingresos</p>
              <p className="text-xl font-bold text-blue-600">
                ${parseFloat(cierres[0].ingresos_totales).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
            <div className="bg-white rounded-lg p-4">
              <p className="text-xs text-stone-500 uppercase tracking-wide mb-1">Utilidad</p>
              <p className="text-xl font-bold text-green-600">
                ${parseFloat(cierres[0].utilidad_neta).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
            <div className="bg-white rounded-lg p-4">
              <p className="text-xs text-stone-500 uppercase tracking-wide mb-1">Inventario</p>
              <p className="text-xl font-bold text-purple-600">
                ${parseFloat(cierres[0].valor_inventario).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
              </p>
            </div>
            <div className="bg-white rounded-lg p-4">
              <p className="text-xs text-stone-500 uppercase tracking-wide mb-1">Ventas</p>
              <p className="text-xl font-bold text-stone-900">
                {cierres[0].num_ventas}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Gráfico de evolución (simple con barras CSS) */}
      {cierres.length > 1 && (
        <div className="bg-white rounded-lg border border-stone-200 p-6">
          <h2 className="text-lg font-semibold text-stone-900 mb-4">Evolución de Ingresos</h2>
          <div className="space-y-3">
            {cierres.slice(0, 12).reverse().map(c => {
              const maxIngresos = Math.max(...cierres.map(x => parseFloat(x.ingresos_totales)))
              const pct = (parseFloat(c.ingresos_totales) / maxIngresos) * 100

              return (
                <div key={c.id} className="flex items-center gap-3">
                  <span className="text-xs font-medium text-stone-600 w-16">
                    {meses[c.mes - 1]} {c.anio}
                  </span>
                  <div className="flex-1 bg-stone-100 rounded-full h-8 overflow-hidden">
                    <div
                      className="bg-blue-500 h-full rounded-full flex items-center justify-end pr-2"
                      style={{ width: `${pct}%` }}
                    >
                      {pct > 20 && (
                        <span className="text-xs font-semibold text-white">
                          ${parseFloat(c.ingresos_totales).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                        </span>
                      )}
                    </div>
                  </div>
                  {pct <= 20 && (
                    <span className="text-xs font-semibold text-stone-600 w-24 text-right">
                      ${parseFloat(c.ingresos_totales).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </span>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* Lista de cierres */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Todos los Cierres</h2>
        </div>
        {cierres.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <Calendar className="w-12 h-12 mx-auto mb-3 text-stone-300" />
            <p className="text-stone-500">No hay cierres registrados</p>
            <p className="text-sm text-stone-400 mt-1">Cierra un mes para crear un snapshot histórico</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Mes/Año</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Ingresos</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Costos</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Comisiones</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Utilidad</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Inventario</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Ventas</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Ticket Prom.</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Cerrado</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {cierres.map(c => (
                  <tr key={c.id} className="hover:bg-stone-50 transition-colors">
                    <td className="px-6 py-4 text-sm font-semibold text-stone-900">
                      {meses[c.mes - 1]} {c.anio}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-900">
                      ${parseFloat(c.ingresos_totales).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-red-600">
                      ${parseFloat(c.costo_ventas).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-amber-600">
                      ${parseFloat(c.comisiones_totales).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono font-semibold text-green-600">
                      ${parseFloat(c.utilidad_neta).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-purple-600">
                      ${parseFloat(c.valor_inventario).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-right text-stone-600">
                      {c.num_ventas}
                    </td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-600">
                      ${parseFloat(c.ticket_promedio).toLocaleString('es-MX', { minimumFractionDigits: 0 })}
                    </td>
                    <td className="px-6 py-4 text-sm text-stone-500">
                      {new Date(c.fecha_cierre).toLocaleDateString('es-MX', { month: 'short', day: 'numeric' })}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
