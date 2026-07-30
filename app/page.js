import { q } from '@/lib/db'
import { Package, ShoppingCart, AlertTriangle, TrendingUp } from 'lucide-react'
import Link from 'next/link'

export default async function HomePage() {
  const [stock] = await q(
    `SELECT COUNT(DISTINCT sku_id) skus, SUM(disponible) unidades
     FROM v_stock WHERE disponible > 0`)
  const [ventas] = await q(
    `SELECT COUNT(*) ventas, COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn - vl.descuento_mxn), 0) total
     FROM venta v LEFT JOIN venta_linea vl ON vl.venta_id = v.id
     WHERE v.estado = 'CERRADA' AND MONTH(v.fecha) = MONTH(CURDATE())`)
  const alertas = await q(
    `SELECT 'Stock negativo' t, COUNT(*) n FROM v_alerta_stock_negativo
     UNION ALL SELECT 'Negocio sin SKU', COUNT(*) FROM v_alerta_negocio_sin_sku
     UNION ALL SELECT 'Paquetes sin piezas', COUNT(*) FROM v_alerta_paquete_sin_piezas
     UNION ALL SELECT 'Guías perdidas', COUNT(*) FROM v_alerta_paquete_sin_cruce`)
  const alertasActivas = alertas.filter(a => Number(a.n) > 0)

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-semibold text-stone-900 tracking-tight">Dashboard</h1>
        <p className="text-stone-500 mt-1">Vista general del negocio</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <StatCard
          icon={Package}
          label="SKUs en stock"
          value={stock.skus}
          subtitle={`${stock.unidades} unidades`}
          href="/inventario"
        />
        <StatCard
          icon={ShoppingCart}
          label="Ventas del mes"
          value={ventas.ventas}
          subtitle={`$${Number(ventas.total).toLocaleString('es-MX', { minimumFractionDigits: 2 })}`}
          href="/ventas"
        />
        <StatCard
          icon={TrendingUp}
          label="Ticket promedio"
          value={ventas.ventas > 0 ? `$${(Number(ventas.total) / ventas.ventas).toFixed(0)}` : '—'}
          subtitle={ventas.ventas > 0 ? 'este mes' : 'sin ventas'}
        />
      </div>

      {alertasActivas.length > 0 && (
        <div className="card">
          <div className="card-header flex items-center gap-2">
            <AlertTriangle className="w-5 h-5 text-amber-600" />
            <h2 className="text-lg font-semibold">Alertas</h2>
          </div>
          <div className="card-body">
            <ul className="space-y-2">
              {alertasActivas.map(a => (
                <li key={a.t} className="flex items-center justify-between py-2 border-b border-stone-100 last:border-0">
                  <span className="text-stone-700">{a.t}</span>
                  <span className="font-semibold text-amber-600">{a.n}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  )
}

function StatCard({ icon: Icon, label, value, subtitle, href }) {
  const Wrapper = href ? Link : 'div'
  return (
    <Wrapper href={href || '#'} className={href ? 'group' : ''}>
      <div className="card card-body hover:shadow-lift transition-shadow duration-200">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <p className="text-stone-500 text-sm font-medium mb-1">{label}</p>
            <p className="text-3xl font-semibold text-stone-900 tracking-tight">{value}</p>
            {subtitle && <p className="text-stone-500 text-sm mt-1">{subtitle}</p>}
          </div>
          <div className="p-3 bg-accent-50 rounded-lg group-hover:bg-accent-100 transition-colors">
            <Icon className="w-6 h-6 text-accent-600" />
          </div>
        </div>
      </div>
    </Wrapper>
  )
}
