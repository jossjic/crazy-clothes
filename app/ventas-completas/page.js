import { q } from '@/lib/db'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function VentasCompletasPage() {
  // Query completo con TODAS las columnas del Excel
  const ventas = await q(`
    SELECT
      v.id,
      v.folio,
      v.fecha,
      v.cliente,
      v.estado,
      v.envio_cliente_mxn,
      c.nombre as canal,
      s.codigo as sku,
      p.nombre as producto,
      s.talla,
      s.color,
      vl.cantidad,
      vl.precio_unitario_mxn,
      (vl.cantidad * vl.precio_unitario_mxn) as venta_total,
      -- Costos
      vpc.costo_total_mxn as costo_unitario,
      (vl.cantidad * vpc.costo_total_mxn) as costo_total,
      -- Comisiones
      (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
       FROM venta_rol vr
       JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
       WHERE vr.venta_id = v.id
         AND vr.rol_venta_id = (SELECT id FROM rol_venta WHERE nombre='NEGOCIADOR' LIMIT 1)
         AND ct.vigente_desde <= v.fecha
         AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
       LIMIT 1) as comision_negociar,
      (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
       FROM venta_rol vr
       JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
       WHERE vr.venta_id = v.id
         AND vr.rol_venta_id = (SELECT id FROM rol_venta WHERE nombre='ENTREGA' LIMIT 1)
         AND ct.vigente_desde <= v.fecha
         AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
       LIMIT 1) as comision_entrega,
      -- Utilidad neta = Venta - Costo - Comisiones - Envío cliente
      (
        (vl.cantidad * vl.precio_unitario_mxn) -
        (vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)) -
        (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
         FROM venta_rol vr
         JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
         WHERE vr.venta_id = v.id
           AND vr.rol_venta_id = (SELECT id FROM rol_venta WHERE nombre='NEGOCIADOR' LIMIT 1)
           AND ct.vigente_desde <= v.fecha
           AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
         LIMIT 1) -
        (SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0)
         FROM venta_rol vr
         JOIN comision_tarifa ct ON vr.rol_venta_id = ct.rol_venta_id
         WHERE vr.venta_id = v.id
           AND vr.rol_venta_id = (SELECT id FROM rol_venta WHERE nombre='ENTREGA' LIMIT 1)
           AND ct.vigente_desde <= v.fecha
           AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
         LIMIT 1) -
        COALESCE(v.envio_cliente_mxn, 0)
      ) as utilidad_neta,
      -- Socios
      (SELECT GROUP_CONCAT(s2.nombre SEPARATOR ', ')
       FROM venta_rol vr
       JOIN socio s2 ON vr.socio_id = s2.id
       JOIN rol_venta rv ON vr.rol_venta_id = rv.id
       WHERE vr.venta_id = v.id AND rv.nombre = 'NEGOCIADOR') as vendedor,
      (SELECT GROUP_CONCAT(s2.nombre SEPARATOR ', ')
       FROM venta_rol vr
       JOIN socio s2 ON vr.socio_id = s2.id
       JOIN rol_venta rv ON vr.rol_venta_id = rv.id
       WHERE vr.venta_id = v.id AND rv.nombre = 'ENTREGA') as repartidor
    FROM venta v
    LEFT JOIN canal c ON c.id = v.canal_id
    JOIN venta_linea vl ON vl.venta_id = v.id
    JOIN sku s ON vl.sku_id = s.id
    JOIN producto p ON s.producto_id = p.id
    LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = s.id
    LEFT JOIN sku_costo sc ON sc.sku_id = s.id
    ORDER BY v.fecha DESC, v.id DESC, vl.id
    LIMIT 200
  `)

  // Calcular totales
  const totalVentas = ventas.reduce((sum, v) => sum + parseFloat(v.venta_total || 0), 0)
  const totalCostos = ventas.reduce((sum, v) => sum + parseFloat(v.costo_total || 0), 0)
  const totalComisiones = ventas.reduce((sum, v) =>
    sum + parseFloat(v.comision_negociar || 0) + parseFloat(v.comision_entrega || 0), 0)
  const totalUtilidad = ventas.reduce((sum, v) => sum + parseFloat(v.utilidad_neta || 0), 0)

  // Agrupar por folio para resumen
  const ventasPorFolio = {}
  ventas.forEach(v => {
    if (!ventasPorFolio[v.folio]) {
      ventasPorFolio[v.folio] = []
    }
    ventasPorFolio[v.folio].push(v)
  })

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/ventas" className="p-2 hover:bg-stone-100 rounded-lg transition-colors">
          <ArrowLeft className="w-5 h-5 text-stone-600" />
        </Link>
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Ventas Completas</h1>
          <p className="text-sm text-stone-500 mt-1">
            {Object.keys(ventasPorFolio).length} ventas · {ventas.length} líneas ·
            ${totalVentas.toLocaleString('es-MX', {minimumFractionDigits: 2})} ventas ·
            ${totalCostos.toLocaleString('es-MX', {minimumFractionDigits: 2})} costos ·
            ${totalComisiones.toLocaleString('es-MX', {minimumFractionDigits: 2})} comisiones ·
            <span className={totalUtilidad > 0 ? 'text-green-600 font-semibold' : 'text-red-600 font-semibold'}>
              ${totalUtilidad.toLocaleString('es-MX', {minimumFractionDigits: 2})} utilidad
            </span>
          </p>
        </div>
      </div>

      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Folio</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Fecha</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Cliente</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Canal</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">SKU</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Producto</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Talla</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Color</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Cant.</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">P. Unit.</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Venta</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Costo U.</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Costo T.</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Vendedor</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Com. Neg.</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Repartidor</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Com. Ent.</th>
                <th className="px-3 py-2 text-right text-xs font-medium text-stone-600">Utilidad</th>
                <th className="px-3 py-2 text-left text-xs font-medium text-stone-600">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-200">
              {ventas.map((v, idx) => {
                const fecha = new Date(v.fecha)
                const comisionTotal = parseFloat(v.comision_negociar || 0) + parseFloat(v.comision_entrega || 0)

                return (
                  <tr key={`${v.id}-${idx}`} className="hover:bg-stone-50 transition-colors">
                    <td className="px-3 py-2 font-mono text-xs">{v.folio}</td>
                    <td className="px-3 py-2 text-xs text-stone-600">
                      {fecha.toLocaleDateString('es-MX', { month: 'short', day: 'numeric' })}
                    </td>
                    <td className="px-3 py-2 text-xs">{v.cliente}</td>
                    <td className="px-3 py-2 text-xs text-stone-600">{v.canal}</td>
                    <td className="px-3 py-2 font-mono text-xs">{v.sku}</td>
                    <td className="px-3 py-2 text-xs max-w-[150px] truncate" title={v.producto}>{v.producto}</td>
                    <td className="px-3 py-2 text-xs text-stone-600">{v.talla}</td>
                    <td className="px-3 py-2 text-xs text-stone-600">{v.color}</td>
                    <td className="px-3 py-2 text-right text-xs">{v.cantidad}</td>
                    <td className="px-3 py-2 text-right text-xs font-mono">
                      ${parseFloat(v.precio_unitario_mxn).toLocaleString('es-MX', {minimumFractionDigits: 2})}
                    </td>
                    <td className="px-3 py-2 text-right text-xs font-mono font-medium">
                      ${parseFloat(v.venta_total).toLocaleString('es-MX', {minimumFractionDigits: 2})}
                    </td>
                    <td className="px-3 py-2 text-right text-xs font-mono text-stone-600">
                      {v.costo_unitario ? `$${parseFloat(v.costo_unitario).toFixed(2)}` : '—'}
                    </td>
                    <td className="px-3 py-2 text-right text-xs font-mono text-stone-600">
                      {v.costo_total ? `$${parseFloat(v.costo_total).toFixed(2)}` : '—'}
                    </td>
                    <td className="px-3 py-2 text-xs text-blue-600">{v.vendedor || '—'}</td>
                    <td className="px-3 py-2 text-right text-xs font-mono text-green-600">
                      {v.comision_negociar > 0 ? `$${parseFloat(v.comision_negociar).toFixed(2)}` : '—'}
                    </td>
                    <td className="px-3 py-2 text-xs text-blue-600">{v.repartidor || '—'}</td>
                    <td className="px-3 py-2 text-right text-xs font-mono text-green-600">
                      {v.comision_entrega > 0 ? `$${parseFloat(v.comision_entrega).toFixed(2)}` : '—'}
                    </td>
                    <td className="px-3 py-2 text-right text-xs font-mono">
                      <span className={`${parseFloat(v.utilidad_neta || 0) > 0 ? 'text-green-600 font-semibold' : parseFloat(v.utilidad_neta || 0) < 0 ? 'text-red-600 font-semibold' : 'text-stone-500'}`}>
                        ${parseFloat(v.utilidad_neta || 0).toFixed(2)}
                      </span>
                    </td>
                    <td className="px-3 py-2 text-xs">
                      <span className={`inline-flex px-2 py-0.5 rounded text-[10px] font-medium ${
                        v.estado === 'PAGADO' ? 'bg-green-100 text-green-700' :
                        v.estado === 'APARTADO' ? 'bg-amber-100 text-amber-700' :
                        v.estado === 'CERRADA' ? 'bg-blue-100 text-blue-700' :
                        'bg-stone-100 text-stone-600'
                      }`}>
                        {v.estado}
                      </span>
                    </td>
                  </tr>
                )
              })}
            </tbody>
            <tfoot className="bg-stone-50 border-t border-stone-200 font-semibold">
              <tr>
                <td colSpan="10" className="px-3 py-3 text-right text-sm">TOTALES:</td>
                <td className="px-3 py-3 text-right text-sm font-mono">
                  ${totalVentas.toLocaleString('es-MX', {minimumFractionDigits: 2})}
                </td>
                <td className="px-3 py-3 text-right text-sm font-mono text-stone-600">
                  ${ventas.reduce((s, v) => s + parseFloat(v.costo_total || 0), 0).toFixed(2)}
                </td>
                <td className="px-3 py-3"></td>
                <td className="px-3 py-3 text-right text-sm font-mono text-green-600">
                  ${ventas.reduce((s, v) => s + parseFloat(v.comision_negociar || 0), 0).toFixed(2)}
                </td>
                <td className="px-3 py-3"></td>
                <td className="px-3 py-3 text-right text-sm font-mono text-green-600">
                  ${ventas.reduce((s, v) => s + parseFloat(v.comision_entrega || 0), 0).toFixed(2)}
                </td>
                <td className="px-3 py-3 text-right text-sm font-mono">
                  <span className={`${ventas.reduce((s, v) => s + parseFloat(v.utilidad_neta || 0), 0) > 0 ? 'text-green-600' : 'text-red-600'}`}>
                    ${ventas.reduce((s, v) => s + parseFloat(v.utilidad_neta || 0), 0).toFixed(2)}
                  </span>
                </td>
                <td className="px-3 py-3"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      {/* Resumen por socio */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {['JJ', 'Agusto', 'Luise'].map(socio => {
          const comisionNeg = ventas
            .filter(v => v.vendedor && v.vendedor.includes(socio))
            .reduce((sum, v) => sum + parseFloat(v.comision_negociar || 0), 0)

          const comisionEnt = ventas
            .filter(v => v.repartidor && v.repartidor.includes(socio))
            .reduce((sum, v) => sum + parseFloat(v.comision_entrega || 0), 0)

          const total = comisionNeg + comisionEnt

          return (
            <div key={socio} className="bg-white rounded-lg border border-stone-200 p-4">
              <h3 className="font-semibold text-stone-900 mb-3">{socio}</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-stone-600">Negociar:</span>
                  <span className="font-mono">${comisionNeg.toFixed(2)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-stone-600">Entrega:</span>
                  <span className="font-mono">${comisionEnt.toFixed(2)}</span>
                </div>
                <div className="flex justify-between pt-2 border-t border-stone-200 font-semibold">
                  <span>Total:</span>
                  <span className="font-mono text-green-600">${total.toFixed(2)}</span>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
