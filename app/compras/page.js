import { q } from '@/lib/db'
import { Plus, Package, ChevronRight } from 'lucide-react'
import Link from 'next/link'
import FormCruce from './FormCruce'

export default async function ComprasPage() {
  const cruces = await q(
    `SELECT c.*, COUNT(DISTINCT pq.id) n_paquetes, COUNT(DISTINCT pz.id) n_piezas,
            COALESCE(MAX(vnp.mxn_negocio), 0) negocio, COALESCE(MAX(vnp.mxn_personal), 0) personal
     FROM cruce c
     LEFT JOIN paquete pq ON pq.cruce_id = c.id
     LEFT JOIN pieza pz ON pz.paquete_id = pq.id
     LEFT JOIN v_cruce_negocio_personal vnp ON vnp.folio = c.folio
     GROUP BY c.id, c.folio, c.fecha, c.costo_mxn, c.notas
     ORDER BY c.fecha DESC
     LIMIT 50`)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Compras</h1>
          <p className="text-stone-500 mt-1">Cruces → Paquetes → Piezas</p>
        </div>
        <FormCruce />
      </div>

      <div className="space-y-4">
        {cruces.map(c => (
          <Link
            key={c.id}
            href={`/compras/${c.id}`}
            className="card card-body hover:shadow-lift transition-shadow duration-200 block"
          >
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <Package className="w-5 h-5 text-accent-600" />
                  <h3 className="text-lg font-semibold text-stone-900">{c.folio}</h3>
                  <span className="text-sm text-stone-500">
                    {new Date(c.fecha).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                  </span>
                </div>
                <div className="flex gap-6 text-sm text-stone-600">
                  <span>{c.n_paquetes} paquetes</span>
                  <span>{c.n_piezas} piezas</span>
                  <span className="font-mono">
                    ${Number(c.costo_mxn).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                  </span>
                </div>
                {Number(c.negocio) + Number(c.personal) > 0 && (
                  <div className="flex gap-4 mt-2 text-xs">
                    <span className="text-green-700">
                      Negocio: ${Number(c.negocio).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </span>
                    <span className="text-amber-700">
                      Personal: ${Number(c.personal).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                    </span>
                  </div>
                )}
              </div>
              <ChevronRight className="w-5 h-5 text-stone-400" />
            </div>
          </Link>
        ))}
      </div>

      {cruces.length === 0 && (
        <div className="card card-body text-center py-12">
          <p className="text-stone-500">No hay cruces registrados.</p>
          <FormCruce className="mt-4 inline-flex" />
        </div>
      )}
    </div>
  )
}
