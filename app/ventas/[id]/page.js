import { q } from '@/lib/db'
import { notFound } from 'next/navigation'
import FormVenta from '../FormVenta'

export default async function EditarVentaPage({ params }) {
  const id = params.id === 'nueva' ? null : Number(params.id)

  let venta = null
  if (id) {
    const [v] = await q('SELECT * FROM venta WHERE id = ?', [id])
    if (!v) notFound()

    const lineas = await q(
      `SELECT vl.*, sk.codigo, pr.nombre producto
       FROM venta_linea vl
       JOIN sku sk ON sk.id = vl.sku_id
       JOIN producto pr ON pr.id = sk.producto_id
       WHERE vl.venta_id = ?`,
      [id])

    const roles = await q(
      `SELECT vr.rol_venta_id, vr.socio_id
       FROM venta_rol vr WHERE vr.venta_id = ?`,
      [id])

    venta = { ...v, lineas, roles: Object.fromEntries(roles.map(r => [r.rol_venta_id, r.socio_id])) }
  }

  const stock = await q(
    `SELECT s.sku_id, s.codigo, pr.nombre producto, s.talla, s.color, s.disponible, sk.precio_lista_mxn
     FROM v_stock s
     JOIN sku sk ON sk.id = s.sku_id
     JOIN producto pr ON pr.id = sk.producto_id
     WHERE s.disponible > 0 OR ? IS NOT NULL
     ORDER BY pr.nombre, s.talla`,
    [id])
  const canales = await q('SELECT id, nombre FROM canal ORDER BY nombre')
  const socios = await q('SELECT id, nombre FROM socio WHERE activo = 1 ORDER BY nombre')
  const rolesVenta = await q('SELECT id, nombre FROM rol_venta ORDER BY nombre')

  return (
    <div className="max-w-4xl mx-auto">
      <FormVenta
        venta={venta}
        stock={stock}
        canales={canales}
        socios={socios}
        rolesVenta={rolesVenta}
      />
    </div>
  )
}
