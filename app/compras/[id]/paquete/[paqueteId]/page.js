import { q } from '@/lib/db'
import { notFound } from 'next/navigation'
import { Plus, ArrowLeft, User } from 'lucide-react'
import Link from 'next/link'
import FormPieza from '../../../FormPieza'
import ActionButton from '@/components/ActionButton'
import { borrarPieza } from '@/lib/actions'

export default async function PaquetePage({ params }) {
  const cruceId = Number(params.id)
  const paqueteId = Number(params.paqueteId)

  const [paquete] = await q(
    `SELECT pq.*, c.folio cruce_folio, paq.nombre paqueteria
     FROM paquete pq
     LEFT JOIN cruce c ON c.id = pq.cruce_id
     LEFT JOIN paqueteria paq ON paq.id = pq.paqueteria_id
     WHERE pq.id = ?`,
    [paqueteId])
  if (!paquete) notFound()

  const piezas = await q(
    `SELECT pz.*, m.nombre marca, tp.nombre tipo, s.nombre socio, sk.codigo sku_codigo
     FROM pieza pz
     JOIN marca m ON m.id = pz.marca_id
     JOIN tipo_prenda tp ON tp.id = pz.tipo_prenda_id
     LEFT JOIN socio s ON s.id = pz.socio_id
     LEFT JOIN sku sk ON sk.id = pz.sku_id
     WHERE pz.paquete_id = ?
     ORDER BY pz.destino, pz.id`,
    [paqueteId])

  const marcas = await q('SELECT id, nombre FROM marca ORDER BY nombre')
  const tipos = await q('SELECT id, nombre FROM tipo_prenda WHERE es_prenda = 1 ORDER BY nombre')
  const socios = await q('SELECT id, nombre FROM socio WHERE activo = 1 ORDER BY nombre')
  const skus = await q(
    `SELECT sk.id, sk.codigo, pr.nombre producto, sk.talla, sk.color,
            pr.marca_id, pr.tipo_prenda_id
     FROM sku sk JOIN producto pr ON pr.id = sk.producto_id
     WHERE sk.estado = 'ACTIVO'
     ORDER BY pr.nombre, sk.talla`)

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href={`/compras/${cruceId}`} className="btn-ghost p-2">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div className="flex-1">
          <h1 className="text-xl font-semibold text-stone-900 font-mono">{paquete.guia}</h1>
          <p className="text-stone-500 mt-1">
            {paquete.cruce_folio} · {paquete.paqueteria || 'Sin paquetería'} · {paquete.fecha_llegada || '—'}
          </p>
        </div>
        <FormPieza paqueteId={paqueteId} marcas={marcas} tipos={tipos} socios={socios} skus={skus} />
      </div>

      <div className="space-y-3">
        {piezas.map(pz => (
          <div key={pz.id} className="card card-body">
            <div className="flex items-start justify-between gap-4">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <span className={`px-2 py-1 rounded text-xs font-medium ${
                    pz.destino === 'NEGOCIO'
                      ? 'bg-green-100 text-green-800'
                      : 'bg-amber-100 text-amber-800'
                  }`}>
                    {pz.destino}
                  </span>
                  {pz.socio && (
                    <span className="flex items-center gap-1 text-sm text-stone-600">
                      <User className="w-4 h-4" />
                      {pz.socio}
                    </span>
                  )}
                  {pz.sku_codigo && (
                    <span className="font-mono text-xs text-stone-600">{pz.sku_codigo}</span>
                  )}
                </div>
                <p className="text-stone-900 font-medium">{pz.descripcion}</p>
                <div className="flex gap-6 text-sm text-stone-600 mt-2">
                  <span>{pz.marca} · {pz.tipo}</span>
                  <span>Cantidad: {pz.cantidad}</span>
                  {pz.costo_usd && (
                    <span className="font-mono">${Number(pz.costo_usd).toFixed(2)} USD</span>
                  )}
                </div>
                {pz.notas && (
                  <p className="text-xs text-stone-500 mt-2">{pz.notas}</p>
                )}
              </div>
              <div className="flex gap-2">
                <FormPieza
                  pieza={pz}
                  paqueteId={paqueteId}
                  marcas={marcas}
                  tipos={tipos}
                  socios={socios}
                  skus={skus}
                />
                <ActionButton
                  action={borrarPieza.bind(null, pz.id)}
                  variant="danger"
                  size="sm"
                  confirm={`¿Borrar esta pieza?`}
                >
                  Borrar
                </ActionButton>
              </div>
            </div>
          </div>
        ))}
      </div>

      {piezas.length === 0 && (
        <div className="card card-body text-center py-12">
          <p className="text-stone-500">No hay piezas en este paquete.</p>
          <FormPieza
            paqueteId={paqueteId}
            marcas={marcas}
            tipos={tipos}
            socios={socios}
            skus={skus}
            className="mt-4 inline-flex"
          />
        </div>
      )}
    </div>
  )
}
