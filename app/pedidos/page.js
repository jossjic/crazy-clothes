import { q } from '@/lib/db'
import { Truck, Package, CheckCircle, XCircle, Clock, AlertTriangle } from 'lucide-react'
import Link from 'next/link'
import FormPedido from './FormPedido'
import { marcarPedidoEnviado, recibirPedido } from '@/lib/actions'

export const dynamic = 'force-dynamic'

export default async function PedidosPage() {
  // Resumen de pedidos
  const resumen = await q(`SELECT * FROM v_pedido_orden_resumen ORDER BY fecha_pedido DESC`)

  const pendientes = resumen.filter(p => p.estado === 'PENDIENTE')
  const enTransito = resumen.filter(p => p.estado === 'EN_TRANSITO')
  const recibidos = resumen.filter(p => p.estado === 'RECIBIDO')
  const alertas = resumen.filter(p => p.alerta_retraso)

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Pedidos a Proveedor</h1>
          <p className="text-sm text-stone-500 mt-1">
            {resumen.length} pedidos · {pendientes.length} pendientes · {enTransito.length} en tránsito
            {alertas.length > 0 && <span className="text-red-600 font-medium"> · {alertas.length} con retraso</span>}
          </p>
        </div>
        <FormPedido />
      </div>

      {/* Cards de estado */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-amber-100 rounded-lg">
              <Clock className="w-5 h-5 text-amber-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Pendientes</p>
              <p className="text-2xl font-semibold text-stone-900">{pendientes.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <Truck className="w-5 h-5 text-blue-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">En Tránsito</p>
              <p className="text-2xl font-semibold text-stone-900">{enTransito.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <CheckCircle className="w-5 h-5 text-green-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Recibidos</p>
              <p className="text-2xl font-semibold text-stone-900">{recibidos.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg border border-stone-200 p-5">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-100 rounded-lg">
              <AlertTriangle className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <p className="text-xs text-stone-500 uppercase tracking-wide">Con Retraso</p>
              <p className="text-2xl font-semibold text-red-600">{alertas.length}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Tabla de pedidos */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Todos los Pedidos</h2>
        </div>
        {resumen.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <Package className="w-12 h-12 mx-auto mb-3 text-stone-300" />
            <p className="text-stone-500">No hay pedidos registrados</p>
            <p className="text-sm text-stone-400 mt-1">Crea uno para empezar a trackear tus compras</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Folio</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha Pedido</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Proveedor</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Estado</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Piezas</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Monto</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Guía</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Días</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {resumen.map(p => {
                  const estadoConfig = {
                    PENDIENTE: { bg: 'bg-amber-100', text: 'text-amber-700', label: 'Pendiente' },
                    EN_TRANSITO: { bg: 'bg-blue-100', text: 'text-blue-700', label: 'En Tránsito' },
                    RECIBIDO: { bg: 'bg-green-100', text: 'text-green-700', label: 'Recibido' },
                    CANCELADO: { bg: 'bg-stone-100', text: 'text-stone-600', label: 'Cancelado' }
                  }[p.estado] || {}

                  return (
                    <tr key={p.id} className={`hover:bg-stone-50 transition-colors ${p.alerta_retraso ? 'bg-red-50' : ''}`}>
                      <td className="px-6 py-4 text-sm font-mono text-stone-900">
                        {p.folio || `PED-${p.id}`}
                      </td>
                      <td className="px-6 py-4 text-sm text-stone-600">
                        {new Date(p.fecha_pedido).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-sm font-medium text-stone-900">{p.proveedor}</td>
                      <td className="px-6 py-4 text-sm">
                        <span className={`inline-flex px-2 py-1 rounded text-xs font-medium ${estadoConfig.bg} ${estadoConfig.text}`}>
                          {estadoConfig.label}
                        </span>
                        {p.alerta_retraso && (
                          <span className="ml-2 inline-flex px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-700">
                            ⚠️ Retraso
                          </span>
                        )}
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-mono text-stone-600">
                        {p.total_piezas}
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-mono font-semibold text-stone-900">
                        {p.monto_total_usd ? `$${parseFloat(p.monto_total_usd).toFixed(0)}` : '—'}
                      </td>
                      <td className="px-6 py-4 text-sm text-stone-600">
                        {p.guia_envio || '—'}
                      </td>
                      <td className="px-6 py-4 text-sm text-right text-stone-600">
                        {p.dias_desde_pedido} días
                      </td>
                      <td className="px-6 py-4 text-sm text-right">
                        <div className="flex items-center justify-end gap-2">
                          {p.estado === 'PENDIENTE' && (
                            <form action={marcarPedidoEnviado} className="inline">
                              <input type="hidden" name="id" value={p.id} />
                              <button
                                type="submit"
                                className="inline-flex items-center gap-1 px-2 py-1 text-xs font-medium text-blue-700 bg-blue-100 rounded hover:bg-blue-200 transition-colors"
                              >
                                <Truck className="w-3 h-3" />
                                Enviado
                              </button>
                            </form>
                          )}
                          {p.estado === 'EN_TRANSITO' && (
                            <form action={recibirPedido} className="inline">
                              <input type="hidden" name="id" value={p.id} />
                              <button
                                type="submit"
                                className="inline-flex items-center gap-1 px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded hover:bg-green-200 transition-colors"
                              >
                                <CheckCircle className="w-3 h-3" />
                                Recibido
                              </button>
                            </form>
                          )}
                          <Link
                            href={`/pedidos/${p.id}`}
                            className="inline-flex items-center gap-1 px-2 py-1 text-xs font-medium text-stone-700 bg-stone-100 rounded hover:bg-stone-200 transition-colors"
                          >
                            Ver
                          </Link>
                        </div>
                      </td>
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
