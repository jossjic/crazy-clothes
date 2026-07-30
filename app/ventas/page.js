import { q } from '@/lib/db'
import { Plus, Calendar, User } from 'lucide-react'
import Link from 'next/link'
import ActionButton from '@/components/ActionButton'
import { borrarVenta } from '@/lib/actions'

export const dynamic = 'force-dynamic'

export default async function VentasPage() {
  const ventas = await q(
    `SELECT v.*,
            c.nombre canal,
            GROUP_CONCAT(DISTINCT s.nombre SEPARATOR ', ') socios,
            (SELECT COALESCE(SUM(vl2.cantidad * vl2.precio_unitario_mxn - vl2.descuento_mxn), 0)
             FROM venta_linea vl2
             WHERE vl2.venta_id = v.id) as total
     FROM venta v
     LEFT JOIN canal c ON c.id = v.canal_id
     LEFT JOIN venta_rol vr ON vr.venta_id = v.id
     LEFT JOIN socio s ON s.id = vr.socio_id
     GROUP BY v.id, v.folio, v.fecha, v.cliente, v.estado, v.canal_id, c.nombre
     ORDER BY v.fecha DESC, v.id DESC
     LIMIT 100`)

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Ventas</h1>
          <p className="text-stone-500 mt-1">{ventas.length} ventas</p>
        </div>
        <div className="flex gap-3">
          <Link href="/ventas-completas" className="btn-ghost">
            Ver con comisiones
          </Link>
          <Link href="/ventas/nueva" className="btn-primary">
            <Plus className="w-4 h-4" />
            Nueva venta
          </Link>
        </div>
      </div>

      <div className="table-wrapper">
        <table className="table">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Canal</th>
              <th>Socios</th>
              <th className="text-right">Total</th>
              <th>Estado</th>
              <th className="text-right">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {ventas.map(v => (
              <tr key={v.id}>
                <td className="font-mono text-xs">{v.folio || '—'}</td>
                <td>
                  <div className="flex items-center gap-2">
                    <Calendar className="w-4 h-4 text-stone-400" />
                    <span className="text-sm">{v.fecha}</span>
                  </div>
                </td>
                <td>{v.cliente || '—'}</td>
                <td>{v.canal || '—'}</td>
                <td className="text-xs text-stone-600">{v.socios || '—'}</td>
                <td className="text-right font-mono">
                  ${Number(v.total).toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                </td>
                <td>
                  <span
                    className={`inline-flex items-center px-2 py-1 rounded text-xs font-medium ${
                      v.estado === 'CERRADA'
                        ? 'bg-green-100 text-green-800'
                        : v.estado === 'APARTADO'
                        ? 'bg-amber-100 text-amber-800'
                        : 'bg-stone-100 text-stone-600'
                    }`}
                  >
                    {v.estado}
                  </span>
                </td>
                <td className="text-right">
                  <div className="flex items-center justify-end gap-2">
                    <Link href={`/ventas/${v.id}`} className="btn-ghost text-xs">
                      Editar
                    </Link>
                    <ActionButton
                      action={borrarVenta.bind(null, v.id)}
                      variant="danger"
                      size="sm"
                      confirm={`¿Borrar venta ${v.folio || v.id}?`}
                    >
                      Borrar
                    </ActionButton>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {ventas.length === 0 && (
        <div className="card card-body text-center py-12">
          <p className="text-stone-500">No hay ventas registradas.</p>
          <Link href="/ventas/nueva" className="btn-primary mt-4 inline-flex">
            <Plus className="w-4 h-4" />
            Crear primera venta
          </Link>
        </div>
      )}
    </div>
  )
}
