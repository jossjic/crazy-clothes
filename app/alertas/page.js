import { q } from '@/lib/db'
import { AlertTriangle, Package, Ruler } from 'lucide-react'
import Link from 'next/link'

export const dynamic = 'force-dynamic'

export default async function AlertasPage() {
  // 1. Paquetes sin cruce asignado (guías perdidas)
  const paquetesSinCruce = await q(`
    SELECT
      pq.id,
      pq.guia,
      pq.fecha_llegada,
      pk.nombre as paqueteria,
      COUNT(p.id) as num_piezas,
      SUM(COALESCE(p.costo_usd, 0)) as costo_producto_usd,
      SUM(f.factor_total) as factor_total
    FROM paquete pq
    LEFT JOIN paqueteria pk ON pk.id = pq.paqueteria_id
    LEFT JOIN pieza p ON p.paquete_id = pq.id
    LEFT JOIN v_pieza_factor f ON f.paquete_id = pq.id
    WHERE pq.cruce_id IS NULL
    GROUP BY pq.id, pq.guia, pq.fecha_llegada, pk.nombre
  `)

  // 2. SKUs sin factor volumétrico definido
  const skusSinFactor = await q(`
    SELECT
      s.id,
      s.codigo,
      m.nombre as marca,
      tp.nombre as tipo,
      pr.nombre as producto,
      vs.disponible as stock
    FROM sku s
    JOIN producto pr ON pr.id = s.producto_id
    JOIN marca m ON m.id = pr.marca_id
    JOIN tipo_prenda tp ON tp.id = pr.tipo_prenda_id
    LEFT JOIN factor_volumetrico fv ON fv.marca_id = m.id AND fv.tipo_prenda_id = tp.id
    LEFT JOIN v_stock vs ON vs.sku_id = s.id
    WHERE fv.id IS NULL
    ORDER BY vs.disponible DESC
  `)

  // 3. Calcular costo promedio por factor
  const costoPorFactorResult = await q(`
    SELECT
      AVG(c.costo_mxn / NULLIF(s.factor_total, 0)) as costo_por_factor_promedio
    FROM cruce c
    JOIN (
      SELECT
        pq.cruce_id,
        SUM(f.factor_total) as factor_total
      FROM paquete pq
      JOIN v_pieza_factor f ON f.paquete_id = pq.id
      WHERE pq.cruce_id IS NOT NULL
      GROUP BY pq.cruce_id
    ) s ON s.cruce_id = c.id
  `)
  const costoPorFactor = parseFloat(costoPorFactorResult[0]?.costo_por_factor_promedio || 0)

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Alertas de Inventario</h1>
        <p className="text-sm text-stone-500 mt-1">
          Paquetes sin cruce asignado y SKUs sin factor volumétrico
        </p>
      </div>

      {/* Métrica: Costo promedio por factor */}
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-500 rounded-lg">
            <Ruler className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="text-sm text-blue-900 font-medium">Costo Promedio por Factor Volumétrico</p>
            <p className="text-2xl font-bold text-blue-600">
              ${costoPorFactor.toFixed(2)} MXN
            </p>
            <p className="text-xs text-blue-700 mt-1">
              Este valor se usa para estimar el costo de envío de guías perdidas
            </p>
          </div>
        </div>
      </div>

      {/* 1. Paquetes sin cruce */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200 bg-amber-50">
          <div className="flex items-center gap-3">
            <AlertTriangle className="w-5 h-5 text-amber-600" />
            <div>
              <h2 className="text-lg font-semibold text-stone-900">
                Paquetes sin Cruce Asignado ({paquetesSinCruce.length})
              </h2>
              <p className="text-sm text-stone-600 mt-1">
                Guías que llegaron pero no se sabe en qué cruce viajaron. Sus piezas tienen costo de producto pero NO costo de envío prorrateado.
              </p>
            </div>
          </div>
        </div>

        {paquetesSinCruce.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <Package className="w-12 h-12 text-stone-300 mx-auto mb-3" />
            <p className="text-stone-500">No hay paquetes sin cruce</p>
            <p className="text-sm text-stone-400 mt-1">Todos los paquetes están asignados</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Guía</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Paquetería</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Fecha Llegada</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Piezas</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Costo Producto</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Factor Total</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Costo Envío Estimado</th>
                  <th className="px-6 py-3 text-center text-xs font-medium text-stone-600">Acción</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {paquetesSinCruce.map(pq => {
                  const factorTotal = parseFloat(pq.factor_total || 0)
                  const costoEnvioEstimado = factorTotal * costoPorFactor
                  const costoProducto = parseFloat(pq.costo_producto_usd || 0)

                  return (
                    <tr key={pq.id} className="hover:bg-amber-50 transition-colors">
                      <td className="px-6 py-4 text-sm font-mono text-stone-900">{pq.guia}</td>
                      <td className="px-6 py-4 text-sm text-stone-600">{pq.paqueteria || '—'}</td>
                      <td className="px-6 py-4 text-sm text-stone-600">
                        {new Date(pq.fecha_llegada).toLocaleDateString('es-MX', { year: 'numeric', month: 'short', day: 'numeric' })}
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-medium text-stone-900">{pq.num_piezas}</td>
                      <td className="px-6 py-4 text-sm text-right font-mono text-stone-900">
                        ${costoProducto.toFixed(2)} USD
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-mono text-blue-600">
                        {factorTotal.toFixed(1)}
                      </td>
                      <td className="px-6 py-4 text-sm text-right font-mono font-semibold text-amber-700">
                        ${costoEnvioEstimado.toFixed(2)} MXN
                      </td>
                      <td className="px-6 py-4 text-center">
                        <Link
                          href={`/paquetes/${pq.id}`}
                          className="inline-flex items-center px-3 py-1 text-xs font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                        >
                          Ver Piezas
                        </Link>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
              <tfoot className="bg-stone-50 border-t border-stone-200">
                <tr>
                  <td colSpan="8" className="px-6 py-4">
                    <div className="flex items-start gap-3 text-xs text-stone-600">
                      <AlertTriangle className="w-4 h-4 text-amber-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="font-medium text-stone-900 mb-1">¿Cómo se calcula el costo estimado?</p>
                        <p>
                          <strong>Costo Envío Estimado</strong> = Factor Volumétrico Total × ${costoPorFactor.toFixed(2)} MXN/factor
                        </p>
                        <p className="mt-1">
                          El costo por factor (${costoPorFactor.toFixed(2)}) es el promedio histórico de todos los cruces registrados.
                          Se usa para estimar el costo de envío cuando no se sabe en qué cruce viajó el paquete.
                        </p>
                        <p className="mt-2 text-amber-700 font-medium">
                          ⚠️ Estas piezas actualmente solo tienen el costo del producto. Para reflejar el costo real,
                          debes crear un cruce estimado usando el botón de acción.
                        </p>
                      </div>
                    </div>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        )}
      </div>

      {/* 2. SKUs sin factor volumétrico */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200 bg-red-50">
          <div className="flex items-center gap-3">
            <Ruler className="w-5 h-5 text-red-600" />
            <div>
              <h2 className="text-lg font-semibold text-stone-900">
                SKUs sin Factor Volumétrico ({skusSinFactor.length})
              </h2>
              <p className="text-sm text-stone-600 mt-1">
                Combinaciones marca + tipo de prenda que no tienen factor definido.
                El prorrateo de envío no funcionará para nuevas compras.
              </p>
            </div>
          </div>
        </div>

        {skusSinFactor.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <Ruler className="w-12 h-12 text-stone-300 mx-auto mb-3" />
            <p className="text-stone-500">Todos los SKUs tienen factor definido</p>
            <p className="text-sm text-stone-400 mt-1">El prorrateo funcionará correctamente</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-stone-50 border-b border-stone-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">SKU</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Marca</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Tipo</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-stone-600">Producto</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-stone-600">Stock</th>
                  <th className="px-6 py-3 text-center text-xs font-medium text-stone-600">Acción</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-200">
                {skusSinFactor.map(sku => (
                  <tr key={sku.id} className="hover:bg-red-50 transition-colors">
                    <td className="px-6 py-4 text-sm font-mono text-stone-900">{sku.codigo}</td>
                    <td className="px-6 py-4 text-sm text-stone-900">{sku.marca}</td>
                    <td className="px-6 py-4 text-sm text-stone-600">{sku.tipo}</td>
                    <td className="px-6 py-4 text-sm text-stone-600">{sku.producto}</td>
                    <td className="px-6 py-4 text-sm text-right font-mono text-stone-900">
                      {parseInt(sku.stock || 0)}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <Link
                        href="/listas/factores"
                        className="inline-flex items-center px-3 py-1 text-xs font-medium bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                      >
                        Definir Factor
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot className="bg-stone-50 border-t border-stone-200">
                <tr>
                  <td colSpan="6" className="px-6 py-4">
                    <div className="flex items-start gap-3 text-xs text-stone-600">
                      <AlertTriangle className="w-4 h-4 text-red-600 flex-shrink-0 mt-0.5" />
                      <div>
                        <p className="font-medium text-stone-900 mb-1">¿Por qué importa el factor volumétrico?</p>
                        <p>
                          El factor volumétrico se usa para <strong>prorratear el costo del cruce</strong> entre todas las piezas.
                          Sin él, no se puede calcular cuánto del envío corresponde a cada pieza.
                        </p>
                        <p className="mt-2 text-red-700 font-medium">
                          ⚠️ Configura el factor antes de registrar nuevas compras de estos productos.
                        </p>
                      </div>
                    </div>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
