import { q } from '@/lib/db'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'
import FormCruceEditar from './FormCruceEditar'

export const dynamic = 'force-dynamic'

export default async function EditarCrucePage({ params }) {
  const { id } = await params

  const cruce = await q(
    `SELECT * FROM cruce WHERE id = ?`,
    [id]
  )

  if (!cruce.length) {
    return <div className="p-6 text-center">Cruce no encontrado</div>
  }

  const cruceData = cruce[0]

  // Info adicional del cruce
  const stats = await q(
    `SELECT
      COUNT(DISTINCT pq.id) as n_paquetes,
      COUNT(DISTINCT pz.id) as n_piezas
    FROM cruce c
    LEFT JOIN paquete pq ON pq.cruce_id = c.id
    LEFT JOIN pieza pz ON pz.paquete_id = pq.id
    WHERE c.id = ?`,
    [id]
  )

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href={`/compras/${id}`} className="p-2 hover:bg-stone-100 rounded-lg transition-colors">
          <ArrowLeft className="w-5 h-5 text-stone-600" />
        </Link>
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Editar Cruce</h1>
          <p className="text-sm text-stone-500 mt-1">
            {cruceData.folio} · {stats[0]?.n_paquetes || 0} paquetes · {stats[0]?.n_piezas || 0} piezas
          </p>
        </div>
      </div>

      <FormCruceEditar cruce={cruceData} />
    </div>
  )
}
