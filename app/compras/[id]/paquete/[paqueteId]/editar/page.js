import { q } from '@/lib/db'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'
import FormPaqueteEditar from './FormPaqueteEditar'

export const dynamic = 'force-dynamic'

export default async function EditarPaquetePage({ params }) {
  const { id, paqueteId: paqueteIdParam } = await params
  const cruceId = Number(id)
  const paqueteId = Number(paqueteIdParam)

  const [paquete] = await q(
    `SELECT pq.*, c.folio as cruce_folio
     FROM paquete pq
     LEFT JOIN cruce c ON c.id = pq.cruce_id
     WHERE pq.id = ?`,
    [paqueteId]
  )

  if (!paquete) {
    return <div className="p-6 text-center">Paquete no encontrado</div>
  }

  // Obtener listas para los selects
  const paqueterias = await q('SELECT id, nombre FROM paqueteria ORDER BY nombre')
  const ubicaciones = await q('SELECT id, nombre FROM ubicacion ORDER BY nombre')
  const cruces = await q('SELECT id, folio FROM cruce ORDER BY fecha DESC LIMIT 50')

  // Info adicional
  const stats = await q(
    `SELECT COUNT(*) as n_piezas FROM pieza WHERE paquete_id = ?`,
    [paqueteId]
  )

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href={`/compras/${cruceId}/paquete/${paqueteId}`} className="p-2 hover:bg-stone-100 rounded-lg transition-colors">
          <ArrowLeft className="w-5 h-5 text-stone-600" />
        </Link>
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Editar Paquete</h1>
          <p className="text-sm text-stone-500 mt-1">
            {paquete.guia} · {stats[0]?.n_piezas || 0} piezas
          </p>
        </div>
      </div>

      <FormPaqueteEditar
        paquete={paquete}
        cruceId={cruceId}
        paqueterias={paqueterias}
        ubicaciones={ubicaciones}
        cruces={cruces}
      />
    </div>
  )
}
