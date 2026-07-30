import { q } from '@/lib/db'
import { Plus, Search, Filter, Package } from 'lucide-react'
import Link from 'next/link'
import FormSku from './FormSku'
import FormProducto from './FormProducto'
import FormAjuste from './FormAjuste'
import ActionButton from '@/components/ActionButton'
import { borrarSku } from '@/lib/actions'

export const dynamic = 'force-dynamic'

export default async function InventarioPage({ searchParams }) {
  const buscar = searchParams.q || ''
  const marca = searchParams.marca || ''
  const tipo = searchParams.tipo || ''
  const color = searchParams.color || ''
  const soloStock = searchParams.stock === 'true'

  // Query con filtros
  let where = [`(s.codigo LIKE ? OR pr.nombre LIKE ? OR s.color LIKE ?)`]
  let params = [`%${buscar}%`, `%${buscar}%`, `%${buscar}%`]

  if (marca) {
    where.push(`m.nombre = ?`)
    params.push(marca)
  }
  if (tipo) {
    where.push(`tp.nombre = ?`)
    params.push(tipo)
  }
  if (color) {
    where.push(`s.color LIKE ?`)
    params.push(`%${color}%`)
  }
  if (soloStock) {
    where.push(`s.disponible > 0`)
  }

  const stock = await q(
    `SELECT s.*, pr.nombre producto, pr.marca_id, pr.tipo_prenda_id,
            m.nombre marca, tp.nombre tipo, sk.precio_lista_mxn
     FROM v_stock s
     JOIN sku sk ON sk.id = s.sku_id
     JOIN producto pr ON pr.id = sk.producto_id
     JOIN marca m ON m.id = pr.marca_id
     JOIN tipo_prenda tp ON tp.id = pr.tipo_prenda_id
     WHERE ${where.join(' AND ')}
     ORDER BY s.disponible DESC, s.disponible < 0 DESC, pr.nombre, s.talla, s.color
     LIMIT 200`,
    params)

  const productos = await q(
    `SELECT p.id, p.nombre, m.nombre marca, tp.nombre tipo
     FROM producto p
     JOIN marca m ON m.id = p.marca_id
     JOIN tipo_prenda tp ON tp.id = p.tipo_prenda_id
     ORDER BY p.nombre`)
  const marcas = await q('SELECT id, nombre FROM marca ORDER BY nombre')
  const tipos = await q('SELECT id, nombre FROM tipo_prenda WHERE es_prenda = 1 ORDER BY nombre')
  const ubicaciones = await q('SELECT id, nombre FROM ubicacion ORDER BY nombre')
  const colores = await q(`SELECT DISTINCT color FROM sku WHERE color IS NOT NULL AND color != '' ORDER BY color`)

  const totalUnidades = stock.reduce((sum, s) => sum + parseInt(s.disponible || 0), 0)
  const skusConStock = stock.filter(s => parseInt(s.disponible) > 0).length

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">Inventario</h1>
          <p className="text-stone-500 mt-1">
            {stock.length} SKUs · {skusConStock} con stock · {totalUnidades} unidades totales
          </p>
        </div>
        <div className="flex gap-3">
          <Link href="/inventario-completo" className="btn-ghost">
            Ver completo
          </Link>
          <FormProducto marcas={marcas} tipos={tipos} />
          <FormSku productos={productos} />
        </div>
      </div>

      <form className="card card-body space-y-4">
        <div className="flex gap-3">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
            <input
              type="search"
              name="q"
              defaultValue={buscar}
              placeholder="Buscar por código, producto o color..."
              className="input pl-10"
            />
          </div>
          <button type="submit" className="btn-primary">Buscar</button>
        </div>

        <div className="grid grid-cols-4 gap-3">
          <div>
            <label className="block text-xs font-medium text-stone-700 mb-1">Marca</label>
            <select name="marca" defaultValue={marca} className="input text-sm">
              <option value="">Todas</option>
              {marcas.map(m => <option key={m.id} value={m.nombre}>{m.nombre}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-stone-700 mb-1">Tipo</label>
            <select name="tipo" defaultValue={tipo} className="input text-sm">
              <option value="">Todos</option>
              {tipos.map(t => <option key={t.id} value={t.nombre}>{t.nombre}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-stone-700 mb-1">Color</label>
            <select name="color" defaultValue={color} className="input text-sm">
              <option value="">Todos</option>
              {colores.map(c => <option key={c.color} value={c.color}>{c.color}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-xs font-medium text-stone-700 mb-1">Filtro</label>
            <label className="flex items-center gap-2 px-3 py-2 border border-stone-300 rounded cursor-pointer hover:bg-stone-50">
              <input type="checkbox" name="stock" value="true" defaultChecked={soloStock} className="w-4 h-4" />
              <span className="text-sm">Solo con stock</span>
            </label>
          </div>
        </div>

        {(buscar || marca || tipo || color || soloStock) && (
          <div className="flex items-center gap-2 flex-wrap">
            <Filter className="w-4 h-4 text-stone-400" />
            <span className="text-sm text-stone-600">Activos:</span>
            {buscar && <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">"{buscar}"</span>}
            {marca && <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">{marca}</span>}
            {tipo && <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">{tipo}</span>}
            {color && <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">{color}</span>}
            {soloStock && <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded">Con stock</span>}
            <Link href="/inventario" className="text-xs text-blue-600 hover:underline ml-auto">Limpiar</Link>
          </div>
        )}
      </form>

      <div className="table-wrapper">
        <table className="table">
          <thead>
            <tr>
              <th>Código</th>
              <th>Producto</th>
              <th>Marca / Tipo</th>
              <th>Talla</th>
              <th>Color</th>
              <th className="text-right">Precio</th>
              <th className="text-right">Stock</th>
              <th className="text-right">Acciones</th>
            </tr>
          </thead>
          <tbody>
            {stock.length === 0 ? (
              <tr>
                <td colSpan="8" className="text-center py-12">
                  <Package className="w-12 h-12 mx-auto mb-3 text-stone-300" />
                  <p className="text-stone-500">No se encontraron productos</p>
                </td>
              </tr>
            ) : (
              stock.map(s => (
                <tr key={s.sku_id} className={Number(s.disponible) < 0 ? 'bg-red-50' : ''}>
                  <td className="font-mono text-xs">{s.codigo}</td>
                  <td>
                    <div className="font-medium text-sm">{s.producto}</div>
                  </td>
                  <td>
                    <div className="text-sm text-stone-600">{s.marca}</div>
                    <div className="text-xs text-stone-400">{s.tipo}</div>
                  </td>
                  <td className="text-sm">{s.talla}</td>
                  <td className="text-sm">{s.color}</td>
                  <td className="text-right text-sm">
                    {s.precio_lista_mxn ? `$${parseFloat(s.precio_lista_mxn).toFixed(2)}` : '—'}
                  </td>
                  <td className="text-right">
                    <span className={`inline-flex px-2 py-1 text-xs font-medium rounded ${
                      Number(s.disponible) > 0 ? 'bg-green-100 text-green-700' :
                      Number(s.disponible) < 0 ? 'bg-red-100 text-red-700' :
                      'bg-stone-100 text-stone-500'
                    }`}>
                      {s.disponible}
                    </span>
                  </td>
                  <td className="text-right">
                    <div className="flex items-center justify-end gap-2">
                      <FormAjuste skuId={s.sku_id} codigo={s.codigo} ubicaciones={ubicaciones} />
                      <FormSku
                        sku={{
                          id: s.sku_id,
                          codigo: s.codigo,
                          producto_id: productos.find(p => p.nombre === s.producto)?.id,
                          talla: s.talla,
                          color: s.color,
                        }}
                        productos={productos}
                      />
                      <ActionButton
                        action={borrarSku.bind(null, s.sku_id)}
                        variant="danger"
                        confirm={`¿Borrar ${s.codigo}?`}
                        size="sm"
                      >
                        Borrar
                      </ActionButton>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
