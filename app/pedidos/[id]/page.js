import { q } from '@/lib/db'
import { notFound } from 'next/navigation'
import { ArrowLeft, Package, Calendar, Truck, User, CheckCircle2 } from 'lucide-react'
import Link from 'next/link'
import ActionButton from '@/components/ActionButton'
import { actualizarEstadoPedido } from '@/lib/actions'

export default async function PedidoDetallePage({ params }) {
  const { id } = await params
  const pedidoId = Number(id)

  const [pedido] = await q(
    `SELECT p.*, prov.nombre proveedor, s.nombre socio_comprador
     FROM pedido p
     JOIN proveedor prov ON prov.id = p.proveedor_id
     LEFT JOIN socio s ON s.id = p.socio_comprador_id
     WHERE p.id = ?`,
    [pedidoId])
  if (!pedido) notFound()

  const piezas = await q(
    `SELECT pp.*, m.nombre marca, tp.nombre tipo, sk.codigo sku_codigo, sk.talla, sk.color
     FROM pedido_pieza pp
     JOIN marca m ON m.id = pp.marca_id
     JOIN tipo_prenda tp ON tp.id = pp.tipo_prenda_id
     LEFT JOIN sku sk ON sk.id = pp.sku_id
     WHERE pp.pedido_id = ?
     ORDER BY pp.id`,
    [pedidoId])

  const estados = [
    { value: 'PENDIENTE', label: 'Pendiente', color: 'stone' },
    { value: 'EN_TRANSITO', label: 'En tránsito', color: 'blue' },
    { value: 'RECIBIDO', label: 'Recibido', color: 'green' }
  ]

  const estadoActual = estados.find(e => e.value === pedido.estado)

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Link href="/pedidos" className="btn-ghost p-2">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div className="flex-1">
          <h1 className="text-xl font-semibold text-stone-900">Pedido #{pedido.id}</h1>
          <p className="text-stone-500 mt-1">{pedido.proveedor}</p>
        </div>
        <span className={`px-3 py-1.5 rounded-lg text-sm font-medium ${
          pedido.estado === 'RECIBIDO' ? 'bg-green-100 text-green-800' :
          pedido.estado === 'EN_TRANSITO' ? 'bg-blue-100 text-blue-800' :
          'bg-stone-100 text-stone-700'
        }`}>
          {estadoActual?.label}
        </span>
      </div>

      {/* Info del pedido */}
      <div className="card">
        <div className="card-body">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <div className="flex items-center gap-2 text-stone-500 text-sm mb-1">
                <Calendar className="w-4 h-4" />
                Fecha de pedido
              </div>
              <p className="text-stone-900 font-medium">{pedido.fecha_pedido || '—'}</p>
            </div>

            <div>
              <div className="flex items-center gap-2 text-stone-500 text-sm mb-1">
                <Truck className="w-4 h-4" />
                Fecha estimada
              </div>
              <p className="text-stone-900 font-medium">{pedido.fecha_estimada || '—'}</p>
            </div>

            {pedido.fecha_recepcion && (
              <div>
                <div className="flex items-center gap-2 text-stone-500 text-sm mb-1">
                  <CheckCircle2 className="w-4 h-4" />
                  Fecha de recepción
                </div>
                <p className="text-stone-900 font-medium">{pedido.fecha_recepcion}</p>
              </div>
            )}

            {pedido.socio_comprador && (
              <div>
                <div className="flex items-center gap-2 text-stone-500 text-sm mb-1">
                  <User className="w-4 h-4" />
                  Comprador
                </div>
                <p className="text-stone-900 font-medium">{pedido.socio_comprador}</p>
              </div>
            )}

            {pedido.tracking && (
              <div>
                <div className="flex items-center gap-2 text-stone-500 text-sm mb-1">
                  <Package className="w-4 h-4" />
                  Tracking
                </div>
                <p className="text-stone-900 font-medium font-mono">{pedido.tracking}</p>
              </div>
            )}

            {pedido.costo_estimado_usd && (
              <div>
                <div className="text-stone-500 text-sm mb-1">Costo estimado</div>
                <p className="text-stone-900 font-medium font-mono">
                  ${Number(pedido.costo_estimado_usd).toFixed(2)} USD
                </p>
              </div>
            )}
          </div>

          {pedido.notas && (
            <div className="mt-4 pt-4 border-t border-stone-200">
              <p className="text-sm text-stone-600">{pedido.notas}</p>
            </div>
          )}
        </div>
      </div>

      {/* Acciones rápidas */}
      {pedido.estado !== 'RECIBIDO' && (
        <div className="flex gap-3">
          {pedido.estado === 'PENDIENTE' && (
            <ActionButton
              action={actualizarEstadoPedido.bind(null, pedidoId, 'EN_TRANSITO')}
              variant="primary"
              confirm="¿Marcar como en tránsito?"
            >
              Marcar en tránsito
            </ActionButton>
          )}
          {pedido.estado === 'EN_TRANSITO' && (
            <ActionButton
              action={actualizarEstadoPedido.bind(null, pedidoId, 'RECIBIDO')}
              variant="primary"
              confirm="¿Marcar como recibido? Esto actualizará la fecha de recepción."
            >
              Marcar recibido
            </ActionButton>
          )}
        </div>
      )}

      {/* Lista de piezas */}
      <div>
        <h2 className="text-lg font-semibold text-stone-900 mb-3">
          Piezas del pedido ({piezas.length})
        </h2>
        <div className="space-y-3">
          {piezas.map(pz => (
            <div key={pz.id} className="card card-body">
              <div className="flex items-start gap-4">
                <div className="flex-1">
                  {pz.sku_codigo && (
                    <span className="font-mono text-xs text-stone-600 bg-stone-100 px-2 py-0.5 rounded">
                      {pz.sku_codigo}
                    </span>
                  )}
                  <p className="text-stone-900 font-medium mt-1">{pz.descripcion}</p>
                  <div className="flex gap-6 text-sm text-stone-600 mt-2">
                    <span>{pz.marca} · {pz.tipo}</span>
                    {pz.talla && <span>Talla: {pz.talla}</span>}
                    {pz.color && <span>Color: {pz.color}</span>}
                    <span>Cantidad: {pz.cantidad_pedida}</span>
                  </div>
                  {pz.notas && (
                    <p className="text-xs text-stone-500 mt-2">{pz.notas}</p>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {piezas.length === 0 && (
          <div className="card card-body text-center py-12">
            <p className="text-stone-500">No hay piezas en este pedido.</p>
          </div>
        )}
      </div>
    </div>
  )
}
