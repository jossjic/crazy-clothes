import { q } from '@/lib/db'
import { notFound } from 'next/navigation'
import { Plus, ArrowLeft, Package2, ChevronRight, Edit } from 'lucide-react'
import Link from 'next/link'
import FormPaquete from '../FormPaquete'
import ActionButton from '@/components/ActionButton'
import { borrarPaquete } from '@/lib/actions'

export default async function CrucePage({ params }) {
  const { id } = await params
  const cruceId = Number(id)
  const [cruce] = await q('SELECT * FROM cruce WHERE id = ?', [cruceId])
  if (!cruce) notFound()

  const paquetes = await q(
    `SELECT pq.*, paq.nombre paqueteria, u.nombre ubicacion,
            COUNT(DISTINCT pz.id) n_piezas,
            COALESCE(ps.pct_negocio * 100, 0) pct_negocio
     FROM paquete pq
     LEFT JOIN paqueteria paq ON paq.id = pq.paqueteria_id
     LEFT JOIN ubicacion u ON u.id = pq.ubicacion_id
     LEFT JOIN pieza pz ON pz.paquete_id = pq.id
     LEFT JOIN v_paquete_split ps ON ps.paquete_id = pq.id
     WHERE pq.cruce_id = ?
     GROUP BY pq.id
     ORDER BY pq.fecha_llegada DESC`,
    [cruceId])

  const paqueterias = await q('SELECT id, nombre FROM paqueteria ORDER BY nombre')
  const ubicaciones = await q('SELECT id, nombre FROM ubicacion ORDER BY nombre')

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/compras" className="btn-ghost p-2">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div className="flex-1">
          <h1 className="text-2xl font-semibold text-stone-900">{cruce.folio}</h1>
          <p className="text-stone-500 mt-1">
            {cruce.fecha} · ${Number(cruce.costo_mxn).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
          </p>
        </div>
        <Link
          href={`/compras/${cruceId}/editar`}
          className="px-4 py-2 text-stone-700 bg-stone-100 hover:bg-stone-200 rounded-lg transition-colors flex items-center gap-2"
        >
          <Edit className="w-4 h-4" />
          Editar Cruce
        </Link>
        <FormPaquete cruceId={cruceId} paqueterias={paqueterias} ubicaciones={ubicaciones} />
      </div>

      <div className="space-y-3">
        {paquetes.map(pq => (
          <Link
            key={pq.id}
            href={`/compras/${cruceId}/paquete/${pq.id}`}
            className="card card-body hover:shadow-lift transition-shadow duration-200 block"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <Package2 className="w-5 h-5 text-stone-600" />
                  <span className="font-mono text-sm text-stone-900">{pq.guia}</span>
                  {pq.paqueteria && (
                    <span className="px-2 py-0.5 bg-stone-100 text-stone-700 text-xs rounded">
                      {pq.paqueteria}
                    </span>
                  )}
                </div>
                <div className="flex gap-6 text-sm text-stone-600">
                  <span>{pq.n_piezas} piezas</span>
                  {pq.ubicacion && <span>{pq.ubicacion}</span>}
                  {pq.fecha_llegada && <span>{pq.fecha_llegada}</span>}
                  {Number(pq.pct_negocio) > 0 && (
                    <span className="font-medium text-accent-700">
                      {Number(pq.pct_negocio).toFixed(1)}% negocio
                    </span>
                  )}
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-stone-400" />
            </div>
          </Link>
        ))}
      </div>

      {paquetes.length === 0 && (
        <div className="card card-body text-center py-12">
          <p className="text-stone-500">No hay paquetes en este cruce.</p>
          <FormPaquete cruceId={id} paqueterias={paqueterias} ubicaciones={ubicaciones} className="mt-4 inline-flex" />
        </div>
      )}
    </div>
  )
}
