import { q } from '@/lib/db'
import { ArrowLeft, Package, AlertTriangle } from 'lucide-react'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function PaqueteDetallePage({ params }) {
  const { id: paqueteId } = await params

  // Info del paquete
  const paquete = await q(
    `SELECT
      pq.id,
      pq.guia,
      pq.fecha_llegada,
      pq.cruce_id,
      c.folio as cruce_folio,
      c.fecha as cruce_fecha,
      c.costo_mxn as cruce_costo_mxn,
      pk.nombre as paqueteria
    FROM paquete pq
    LEFT JOIN cruce c ON c.id = pq.cruce_id
    LEFT JOIN paqueteria pk ON pk.id = pq.paqueteria_id
    WHERE pq.id = ?`,
    [paqueteId]
  )

  if (!paquete.length) {
    return <div className="p-6 text-center">Paquete no encontrado</div>
  }

  const pkg = paquete[0]

  // Piezas del paquete
  const piezas = await q(
    `SELECT
      p.id,
      p.destino,
      p.costo_usd,
      p.descripcion,
      s.codigo as sku_codigo,
      s.id as sku_id,
      -- Para NEGOCIO: datos del SKU/producto. Para PERSONAL: datos directos de pieza
      COALESCE(pr.nombre, p.descripcion) as producto,
      COALESCE(m_sku.nombre, m_pieza.nombre) as marca,
      COALESCE(tp_sku.nombre, tp_pieza.nombre) as tipo,
      s.talla,
      s.color,
      so.nombre as socio,
      vpc.costo_prenda_mxn,
      vpc.cruce_pieza_mxn,
      vpc.costo_total_mxn,
      vpce.cruce_pieza_estimado_mxn,
      vpce.costo_total_estimado_mxn,
      vpce.es_costo_estimado,
      f.factor_total
    FROM pieza p
    LEFT JOIN sku s ON s.id = p.sku_id
    LEFT JOIN producto pr ON pr.id = s.producto_id
    LEFT JOIN marca m_sku ON m_sku.id = pr.marca_id
    LEFT JOIN tipo_prenda tp_sku ON tp_sku.id = pr.tipo_prenda_id
    -- Marca y tipo directos de la pieza (para PERSONAL)
    LEFT JOIN marca m_pieza ON m_pieza.id = p.marca_id
    LEFT JOIN tipo_prenda tp_pieza ON tp_pieza.id = p.tipo_prenda_id
    LEFT JOIN socio so ON so.id = p.socio_id
    LEFT JOIN v_pieza_costo vpc ON vpc.pieza_id = p.id
    LEFT JOIN v_pieza_costo_con_estimado vpce ON vpce.pieza_id = p.id
    LEFT JOIN v_pieza_factor f ON f.pieza_id = p.id
    WHERE p.paquete_id = ?
    ORDER BY p.destino, COALESCE(pr.nombre, p.descripcion)`,
    [paqueteId]
  )

  const totalProducto = piezas.reduce((sum, p) => sum + parseFloat(p.costo_usd || 0), 0)
  const factorTotal = piezas.reduce((sum, p) => sum + parseFloat(p.factor_total || 0), 0)

  // Calcular costo promedio por factor (para mostrar el estimado)
  const costoPorFactorResult = await q(`
    SELECT AVG(c.costo_mxn / NULLIF(s.factor_total, 0)) as costo_por_factor_promedio
    FROM cruce c
    JOIN (
      SELECT pq.cruce_id, SUM(f.factor_total) as factor_total
      FROM paquete pq
      JOIN v_pieza_factor f ON f.paquete_id = pq.id
      WHERE pq.cruce_id IS NOT NULL
      GROUP BY pq.cruce_id
    ) s ON s.cruce_id = c.id
  `)
  const costoPorFactor = parseFloat(costoPorFactorResult[0]?.costo_por_factor_promedio || 0)
  const costoEnvioEstimado = factorTotal * costoPorFactor

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/alertas" className="p-2 hover:bg-stone-100 rounded-lg transition-colors">
          <ArrowLeft className="w-5 h-5 text-stone-600" />
        </Link>
        <div className="flex-1">
          <h1 className="text-2xl font-semibold text-stone-900">Paquete {pkg.guia}</h1>
          <p className="text-sm text-stone-500 mt-1">
            {piezas.length} piezas · Llegó {new Date(pkg.fecha_llegada).toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' })}
          </p>
        </div>
      </div>

      {/* Alerta si no tiene cruce */}
      {!pkg.cruce_id && (
        <div className="bg-amber-50 border border-amber-200 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-sm font-semibold text-amber-900">Guía Perdida - Sin Cruce Asignado</p>
              <p className="text-sm text-amber-800 mt-1">
                Este paquete llegó pero no se sabe en qué cruce viajó. Los costos de envío mostrados son
                <strong> estimados</strong> basados en el promedio histórico (${costoPorFactor.toFixed(2)} MXN/factor).
              </p>
              <div className="mt-3 grid grid-cols-3 gap-4 text-xs">
                <div>
                  <p className="text-amber-700">Costo Producto:</p>
                  <p className="font-mono font-semibold text-amber-900">${totalProducto.toFixed(2)} USD</p>
                </div>
                <div>
                  <p className="text-amber-700">Factor Total:</p>
                  <p className="font-mono font-semibold text-amber-900">{factorTotal.toFixed(1)}</p>
                </div>
                <div>
                  <p className="text-amber-700">Costo Envío Estimado:</p>
                  <p className="font-mono font-semibold text-amber-900">${costoEnvioEstimado.toFixed(2)} MXN</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Info del cruce (si existe) */}
      {pkg.cruce_id && (
        <div className="bg-white rounded-lg border border-stone-200 p-4">
          <div className="flex items-center gap-3">
            <Package className="w-5 h-5 text-blue-600" />
            <div>
              <p className="text-sm font-semibold text-stone-900">Cruce: {pkg.cruce_folio}</p>
              <p className="text-xs text-stone-500">
                {new Date(pkg.cruce_fecha).toLocaleDateString('es-MX')} · Costo: ${parseFloat(pkg.cruce_costo_mxn).toFixed(2)} MXN
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Tabla de piezas */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Piezas del Paquete</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-stone-50 border-b border-stone-200">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Destino</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">SKU</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Producto</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Marca</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Tipo</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Talla</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Color</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-stone-600">Socio</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-stone-600">Factor</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-stone-600">Costo Producto</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-stone-600">Costo Envío</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-stone-600">Costo Total</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-200">
              {piezas.map(p => {
                const costoEnvio = p.es_costo_estimado
                  ? parseFloat(p.cruce_pieza_estimado_mxn || 0)
                  : parseFloat(p.cruce_pieza_mxn || 0)

                const costoTotal = p.es_costo_estimado
                  ? parseFloat(p.costo_total_estimado_mxn || 0)
                  : parseFloat(p.costo_total_mxn || 0)

                return (
                  <tr key={p.id} className="hover:bg-stone-50 transition-colors">
                    <td className="px-4 py-3">
                      <span className={`inline-flex px-2 py-1 rounded text-xs font-medium ${
                        p.destino === 'NEGOCIO' ? 'bg-blue-100 text-blue-700' : 'bg-purple-100 text-purple-700'
                      }`}>
                        {p.destino}
                      </span>
                    </td>
                    <td className="px-4 py-3 font-mono text-xs text-stone-900">
                      {p.sku_codigo || '—'}
                    </td>
                    <td className="px-4 py-3 text-stone-900">{p.producto || '—'}</td>
                    <td className="px-4 py-3 text-stone-600">{p.marca}</td>
                    <td className="px-4 py-3 text-stone-600">{p.tipo}</td>
                    <td className="px-4 py-3 text-stone-600">{p.talla || '—'}</td>
                    <td className="px-4 py-3 text-stone-600">{p.color || '—'}</td>
                    <td className="px-4 py-3 text-stone-600">{p.socio || '—'}</td>
                    <td className="px-4 py-3 text-right font-mono text-stone-900">
                      {parseFloat(p.factor_total || 0).toFixed(1)}
                    </td>
                    <td className="px-4 py-3 text-right font-mono text-stone-900">
                      ${parseFloat(p.costo_usd || 0).toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-right font-mono">
                      {p.es_costo_estimado ? (
                        <span className="text-amber-700" title="Costo estimado (sin cruce asignado)">
                          ~${costoEnvio.toFixed(2)}*
                        </span>
                      ) : (
                        <span className="text-stone-900">
                          ${costoEnvio.toFixed(2)}
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right font-mono font-semibold">
                      {p.es_costo_estimado ? (
                        <span className="text-amber-700" title="Costo estimado (sin cruce asignado)">
                          ~${costoTotal.toFixed(2)}*
                        </span>
                      ) : (
                        <span className="text-stone-900">
                          ${costoTotal.toFixed(2)}
                        </span>
                      )}
                    </td>
                  </tr>
                )
              })}
            </tbody>
            {piezas.some(p => p.es_costo_estimado) && (
              <tfoot className="bg-amber-50 border-t border-amber-200">
                <tr>
                  <td colSpan="12" className="px-4 py-3 text-xs text-amber-800">
                    <strong>*</strong> Costos marcados con ~ son estimados porque el paquete no tiene cruce asignado.
                    Basados en promedio de ${costoPorFactor.toFixed(2)} MXN por unidad de factor volumétrico.
                  </td>
                </tr>
              </tfoot>
            )}
          </table>
        </div>
      </div>
    </div>
  )
}
