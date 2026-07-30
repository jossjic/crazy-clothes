'use server'
import { revalidatePath } from 'next/cache'
import { q, tx } from './db'

/** Vacío -> NULL, para no meter '' en columnas numéricas o FK. */
const nn = (v) => (v === '' || v === undefined || v === null ? null : v)
const num = (v) => (nn(v) === null ? null : Number(v))

// ==========================================================
// INVENTARIO  (producto + sku)
// ==========================================================

export async function guardarSku(_prev, fd) {
  const id = nn(fd.get('id'))
  const payload = {
    codigo: String(fd.get('codigo') ?? '').trim(),
    producto_id: num(fd.get('producto_id')),
    talla: String(fd.get('talla') ?? '').trim(),
    color: String(fd.get('color') ?? '').trim(),
    estado: fd.get('estado') || 'ACTIVO',
    precio_lista_mxn: num(fd.get('precio_lista_mxn')),
    notas: nn(fd.get('notas')),
  }
  if (!payload.codigo) return { error: 'El código SKU es obligatorio.' }
  if (!payload.producto_id) return { error: 'Elige un producto.' }
  if (!payload.talla || !payload.color) return { error: 'Talla y color son obligatorios.' }

  try {
    if (id) {
      await q(
        `UPDATE sku SET codigo=?, producto_id=?, talla=?, color=?, estado=?,
                precio_lista_mxn=?, notas=? WHERE id=?`,
        [payload.codigo, payload.producto_id, payload.talla, payload.color,
         payload.estado, payload.precio_lista_mxn, payload.notas, id])
    } else {
      await q(
        `INSERT INTO sku (codigo,producto_id,talla,color,estado,precio_lista_mxn,notas)
         VALUES (?,?,?,?,?,?,?)`,
        [payload.codigo, payload.producto_id, payload.talla, payload.color,
         payload.estado, payload.precio_lista_mxn, payload.notas])
    }
  } catch (e) {
    // Traduzco los errores de MySQL a algo que un humano entienda.
    if (e.code === 'ER_DUP_ENTRY') {
      return e.message.includes('uq_sku_variante')
        ? { error: 'Ese producto ya tiene un SKU con esa talla y color.' }
        : { error: `El código ${payload.codigo} ya existe.` }
    }
    return { error: e.message }
  }
  revalidatePath('/inventario')
  return { ok: true }
}

export async function borrarSku(id) {
  try {
    await q('DELETE FROM sku WHERE id=?', [id])
  } catch (e) {
    if (e.code === 'ER_ROW_IS_REFERENCED_2')
      return { error: 'No se puede borrar: tiene ventas o movimientos. Márcalo DESCONTINUADO.' }
    return { error: e.message }
  }
  revalidatePath('/inventario')
  return { ok: true }
}

export async function guardarProducto(_prev, fd) {
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!nombre) return { error: 'El nombre del producto es obligatorio.' }
  try {
    await q(
      `INSERT INTO producto (marca_id,tipo_prenda_id,nombre,codigo_proveedor)
       VALUES (?,?,?,?)`,
      [num(fd.get('marca_id')), num(fd.get('tipo_prenda_id')), nombre,
       nn(fd.get('codigo_proveedor'))])
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Esa marca ya tiene un producto con ese nombre.' }
    return { error: e.message }
  }
  revalidatePath('/inventario')
  return { ok: true }
}

/** Ajuste manual de stock. Queda como movimiento, nunca se sobrescribe. */
export async function ajustarStock(_prev, fd) {
  const sku_id = num(fd.get('sku_id'))
  const cantidad = num(fd.get('cantidad'))
  const sentido = fd.get('sentido') === 'MENOS' ? 'AJUSTE_MENOS' : 'AJUSTE_MAS'
  if (!sku_id || !cantidad || cantidad <= 0) return { error: 'Cantidad debe ser mayor a 0.' }
  await q(
    `INSERT INTO movimiento (fecha,sku_id,tipo,cantidad,ubicacion_destino_id,notas)
     VALUES (?,?,?,?,?,?)`,
    [fd.get('fecha') || new Date().toISOString().slice(0, 10), sku_id, sentido,
     cantidad, num(fd.get('ubicacion_id')), nn(fd.get('notas')) ?? 'Ajuste manual'])
  revalidatePath('/inventario')
  return { ok: true }
}

// ==========================================================
// VENTAS
// ==========================================================

/**
 * Una venta = cabecera + líneas + roles + un movimiento VENTA por línea.
 * Todo en una transacción: una venta a medias descuadra el stock, y ese
 * fue justo el problema del Excel.
 */
export async function guardarVenta(_prev, fd) {
  const id = nn(fd.get('id'))
  let lineas
  try {
    lineas = JSON.parse(fd.get('lineas') || '[]')
  } catch { return { error: 'Las líneas de la venta no se pudieron leer.' } }

  lineas = lineas.filter((l) => l.sku_id && Number(l.cantidad) > 0)
  if (!lineas.length) return { error: 'Agrega al menos una prenda a la venta.' }

  const fecha = fd.get('fecha') || new Date().toISOString().slice(0, 10)
  const estado = fd.get('estado') || 'CERRADA'
  const roles = JSON.parse(fd.get('roles') || '{}')

  // Aviso de sobreventa: no bloqueo (puede ser preventa), pero lo informo.
  const avisos = []
  for (const l of lineas) {
    const [s] = await q('SELECT codigo, disponible FROM v_stock WHERE sku_id=?', [l.sku_id])
    if (s && Number(s.disponible) < Number(l.cantidad) && estado === 'CERRADA')
      avisos.push(`${s.codigo}: hay ${s.disponible}, vendes ${l.cantidad}`)
  }

  try {
    await tx(async (run) => {
      let ventaId = id
      if (id) {
        await run(`UPDATE venta SET folio=?,fecha=?,canal_id=?,cliente=?,estado=?,notas=? WHERE id=?`,
          [nn(fd.get('folio')), fecha, num(fd.get('canal_id')), nn(fd.get('cliente')),
           estado, nn(fd.get('notas')), id])
        // Reemplazo líneas/roles/movimientos: más simple y sin estados huérfanos.
        await run('DELETE FROM venta_linea WHERE venta_id=?', [id])
        await run('DELETE FROM venta_rol WHERE venta_id=?', [id])
        await run('DELETE FROM movimiento WHERE venta_id=?', [id])
      } else {
        const r = await run(
          `INSERT INTO venta (folio,fecha,canal_id,cliente,estado,notas) VALUES (?,?,?,?,?,?)`,
          [nn(fd.get('folio')), fecha, num(fd.get('canal_id')), nn(fd.get('cliente')),
           estado, nn(fd.get('notas'))])
        ventaId = r.insertId
      }

      for (const l of lineas) {
        await run(
          `INSERT INTO venta_linea (venta_id,sku_id,cantidad,precio_unitario_mxn,descuento_mxn)
           VALUES (?,?,?,?,?)`,
          [ventaId, l.sku_id, l.cantidad, l.precio_unitario_mxn || 0, l.descuento_mxn || 0])
        // CANCELADO y APARTADO no descuentan stock todavía.
        if (estado === 'CERRADA')
          await run(
            `INSERT INTO movimiento (fecha,sku_id,tipo,cantidad,venta_id,notas)
             VALUES (?,?,'VENTA',?,?,?)`,
            [fecha, l.sku_id, l.cantidad, ventaId, 'Venta'])
      }
      for (const [rol_venta_id, socio_id] of Object.entries(roles)) {
        if (socio_id) await run(
          `INSERT INTO venta_rol (venta_id,rol_venta_id,socio_id) VALUES (?,?,?)`,
          [ventaId, rol_venta_id, socio_id])
      }
    })
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY' && e.message.includes('folio'))
      return { error: 'Ese folio de venta ya existe.' }
    return { error: e.message }
  }
  revalidatePath('/ventas'); revalidatePath('/inventario')
  return { ok: true, avisos }
}

export async function borrarVenta(id) {
  try {
    // Los movimientos no caen por cascada (la FK es RESTRICT), van primero.
    await tx(async (run) => {
      await run('DELETE FROM movimiento WHERE venta_id=?', [id])
      await run('DELETE FROM venta WHERE id=?', [id])
    })
  } catch (e) { return { error: e.message } }
  revalidatePath('/ventas'); revalidatePath('/inventario')
  return { ok: true }
}

// ==========================================================
// COMPRAS  (cruce -> paquete -> pieza)
// ==========================================================

export async function guardarCruce(_prev, fd) {
  const id = nn(fd.get('id'))
  const folio = String(fd.get('folio') ?? '').trim()
  if (!folio) return { error: 'El folio del cruce es obligatorio.' }
  const args = [folio, fd.get('fecha') || new Date().toISOString().slice(0, 10),
                num(fd.get('costo_mxn')) ?? 0, nn(fd.get('notas'))]
  try {
    if (id) await q('UPDATE cruce SET folio=?,fecha=?,costo_mxn=?,notas=? WHERE id=?', [...args, id])
    else await q('INSERT INTO cruce (folio,fecha,costo_mxn,notas) VALUES (?,?,?,?)', args)
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: `El cruce ${folio} ya existe.` }
    return { error: e.message }
  }
  revalidatePath('/compras')
  return { ok: true }
}

export async function guardarPaquete(_prev, fd) {
  const id = nn(fd.get('id'))
  const guia = String(fd.get('guia') ?? '').trim()
  if (!guia) return { error: 'La guía es obligatoria.' }
  // cruce_id vacío es válido y significativo: guía "perdida".
  const args = [guia, num(fd.get('paqueteria_id')), num(fd.get('cruce_id')),
                nn(fd.get('fecha_llegada')), num(fd.get('ubicacion_id')),
                fd.get('estado') || 'RECIBIDO', nn(fd.get('notas'))]
  try {
    if (id) await q(
      `UPDATE paquete SET guia=?,paqueteria_id=?,cruce_id=?,fecha_llegada=?,
              ubicacion_id=?,estado=?,notas=? WHERE id=?`, [...args, id])
    else await q(
      `INSERT INTO paquete (guia,paqueteria_id,cruce_id,fecha_llegada,ubicacion_id,estado,notas)
       VALUES (?,?,?,?,?,?,?)`, args)
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: `La guía ${guia} ya está registrada.` }
    return { error: e.message }
  }
  revalidatePath('/compras')
  return { ok: true }
}

export async function borrarPaquete(id) {
  try {
    // pieza cae por ON DELETE CASCADE, pero sus movimientos no.
    await tx(async (run) => {
      await run(`DELETE FROM movimiento WHERE pieza_id IN (SELECT id FROM pieza WHERE paquete_id=?)`, [id])
      await run('DELETE FROM paquete WHERE id=?', [id])
    })
  } catch (e) { return { error: e.message } }
  revalidatePath('/compras'); revalidatePath('/inventario')
  return { ok: true }
}

/**
 * Alta de pieza. Aquí viven las dos reglas del negocio:
 *   - PERSONAL nunca lleva SKU ni entra a inventario (lo fuerza el CHECK,
 *     pero lo valido antes para dar un mensaje decente).
 *   - Si es NEGOCIO y trae SKU, se genera el movimiento COMPRA que la
 *     mete a stock, ligado a la pieza para trazabilidad.
 */
export async function guardarPieza(_prev, fd) {
  const id = nn(fd.get('id'))
  const destino = fd.get('destino') === 'PERSONAL' ? 'PERSONAL' : 'NEGOCIO'
  const sku_id = destino === 'PERSONAL' ? null : num(fd.get('sku_id'))
  const socio_id = destino === 'PERSONAL' ? num(fd.get('socio_id')) : null
  const paquete_id = num(fd.get('paquete_id'))
  const descripcion = String(fd.get('descripcion') ?? '').trim()

  if (!paquete_id) return { error: 'La pieza necesita una guía.' }
  if (!descripcion) return { error: 'Describe la pieza (como venga en el pedido).' }
  if (!num(fd.get('marca_id')) || !num(fd.get('tipo_prenda_id')))
    return { error: 'Marca y tipo definen el factor volumétrico: son obligatorios.' }

  const cantidad = num(fd.get('cantidad')) || 1
  const fecha = fd.get('fecha_compra') || new Date().toISOString().slice(0, 10)
  const args = [paquete_id, descripcion, cantidad, num(fd.get('marca_id')),
                num(fd.get('tipo_prenda_id')), num(fd.get('factor_manual')),
                destino, socio_id, sku_id, num(fd.get('costo_usd')), nn(fd.get('notas'))]
  try {
    await tx(async (run) => {
      let piezaId = id
      if (id) {
        await run(
          `UPDATE pieza SET paquete_id=?,descripcion=?,cantidad=?,marca_id=?,tipo_prenda_id=?,
                  factor_manual=?,destino=?,socio_id=?,sku_id=?,costo_usd=?,notas=? WHERE id=?`,
          [...args, id])
        await run('DELETE FROM movimiento WHERE pieza_id=?', [id])
      } else {
        const r = await run(
          `INSERT INTO pieza (paquete_id,descripcion,cantidad,marca_id,tipo_prenda_id,
                  factor_manual,destino,socio_id,sku_id,costo_usd,notas)
           VALUES (?,?,?,?,?,?,?,?,?,?,?)`, args)
        piezaId = r.insertId
      }
      if (destino === 'NEGOCIO' && sku_id) {
        const [pq] = await run('SELECT ubicacion_id FROM paquete WHERE id=?', [paquete_id])
        await run(
          `INSERT INTO movimiento (fecha,sku_id,tipo,cantidad,ubicacion_destino_id,pieza_id,notas)
           VALUES (?,?,'COMPRA',?,?,?,?)`,
          [fecha, sku_id, cantidad, pq?.ubicacion_id ?? null, piezaId, descripcion.slice(0, 240)])
      }
    })
  } catch (e) {
    if (e.code === 'ER_CHECK_CONSTRAINT_VIOLATED' && e.message.includes('personal_sin_sku'))
      return { error: 'Una pieza personal no puede llevar SKU: no es inventario vendible.' }
    return { error: e.message }
  }
  revalidatePath('/compras'); revalidatePath('/inventario')
  return { ok: true }
}

export async function borrarPieza(id) {
  try {
    await tx(async (run) => {
      await run('DELETE FROM movimiento WHERE pieza_id=?', [id])
      await run('DELETE FROM pieza WHERE id=?', [id])
    })
  } catch (e) { return { error: e.message } }
  revalidatePath('/compras'); revalidatePath('/inventario')
  return { ok: true }
}

// ==========================================================
// DEUDAS entre socios
// ==========================================================

export async function guardarDeuda(_prev, fd) {
  const id = nn(fd.get('id'))
  const fecha = nn(fd.get('fecha'))
  const socio_acreedor_id = num(fd.get('socio_acreedor_id'))
  const socio_deudor_id = num(fd.get('socio_deudor_id'))
  const monto_mxn = num(fd.get('monto_mxn'))
  const motivo = nn(fd.get('motivo'))
  const fecha_vencimiento = nn(fd.get('fecha_vencimiento'))
  const notas = nn(fd.get('notas'))

  if (!fecha) return { error: 'La fecha es obligatoria.' }
  if (!socio_acreedor_id) return { error: 'Elige quién presta (acreedor).' }
  if (!socio_deudor_id) return { error: 'Elige quién debe (deudor).' }
  if (!monto_mxn || monto_mxn <= 0) return { error: 'El monto debe ser mayor a 0.' }
  if (socio_acreedor_id === socio_deudor_id) return { error: 'El acreedor y deudor no pueden ser la misma persona.' }

  try {
    if (id) {
      await q(
        `UPDATE prestamo SET fecha=?, socio_acreedor_id=?, socio_deudor_id=?, monto_mxn=?,
                motivo=?, fecha_vencimiento=?, notas=? WHERE id=?`,
        [fecha, socio_acreedor_id, socio_deudor_id, monto_mxn, motivo, fecha_vencimiento, notas, id])
    } else {
      await q(
        `INSERT INTO prestamo (fecha, socio_acreedor_id, socio_deudor_id, monto_mxn, motivo, fecha_vencimiento, notas)
         VALUES (?,?,?,?,?,?,?)`,
        [fecha, socio_acreedor_id, socio_deudor_id, monto_mxn, motivo, fecha_vencimiento, notas])
    }
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/deudas')
  return { ok: true }
}

export async function marcarDeudaPagada(fd) {
  const id = fd.get('id')
  const fecha_pago = new Date().toISOString().split('T')[0]
  try {
    await q('UPDATE prestamo SET pagado = TRUE, fecha_pago = ? WHERE id = ?', [fecha_pago, id])
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/deudas')
  return { ok: true }
}

export async function borrarDeuda(id) {
  try {
    await q('DELETE FROM prestamo WHERE id=?', [id])
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/deudas')
  return { ok: true }
}

// ==========================================================
// PEDIDOS a proveedor
// ==========================================================

export async function guardarPedidoOrden(_prev, fd) {
  const id = nn(fd.get('id'))
  const folio = nn(fd.get('folio'))
  const fecha_pedido = nn(fd.get('fecha_pedido'))
  const proveedor = nn(fd.get('proveedor'))
  const monto_total_usd = num(fd.get('monto_total_usd'))
  const notas = nn(fd.get('notas'))

  if (!fecha_pedido) return { error: 'La fecha del pedido es obligatoria.' }
  if (!proveedor) return { error: 'El proveedor es obligatorio.' }

  try {
    // Buscar o crear proveedor
    let [prov] = await q('SELECT id FROM proveedor WHERE nombre = ?', [proveedor])
    if (!prov) {
      const r = await q('INSERT INTO proveedor (nombre) VALUES (?)', [proveedor])
      prov = { id: r.insertId }
    }

    let pedidoId
    if (id) {
      await q(
        `UPDATE pedido SET folio=?, fecha_pedido=?, proveedor_id=?, costo_estimado_usd=?, notas=? WHERE id=?`,
        [folio, fecha_pedido, prov.id, monto_total_usd, notas, id])
      pedidoId = id
    } else {
      const r = await q(
        `INSERT INTO pedido (folio, fecha_pedido, proveedor_id, costo_estimado_usd, notas)
         VALUES (?,?,?,?,?)`,
        [folio, fecha_pedido, prov.id, monto_total_usd, notas])
      pedidoId = r.insertId
    }
    revalidatePath('/pedidos')
    return { ok: true, pedidoId }
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Ese folio ya existe.' }
    return { error: e.message }
  }
}

export async function marcarPedidoEnviado(fd) {
  const id = fd.get('id')
  const guia_envio = nn(fd.get('guia_envio'))

  try {
    await q(
      `UPDATE pedido SET estado='EN_TRANSITO', tracking=? WHERE id=?`,
      [guia_envio, id])
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/pedidos')
  return { ok: true }
}

export async function recibirPedido(fd) {
  const id = fd.get('id')
  const fecha_recepcion = fd.get('fecha_recepcion') || new Date().toISOString().split('T')[0]

  try {
    await tx(async (run) => {
      // Obtener líneas del pedido
      const lineas = await run('SELECT * FROM pedido_pieza WHERE pedido_id = ?', [id])

      // Crear movimientos COMPRA para cada línea que tenga SKU
      for (const linea of lineas) {
        if (linea.sku_id) {
          await run(
            `INSERT INTO movimiento (fecha, sku_id, tipo, cantidad, notas)
             VALUES (?, ?, 'COMPRA', ?, ?)`,
            [fecha_recepcion, linea.sku_id, linea.cantidad_pedida, `Pedido recibido - ${linea.descripcion}`])
        }
      }

      // Actualizar estado del pedido
      await run(
        `UPDATE pedido SET estado='RECIBIDO', fecha_recepcion=? WHERE id=?`,
        [fecha_recepcion, id])
    })
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/pedidos')
  revalidatePath('/inventario')
  return { ok: true }
}

export async function cancelarPedido(id) {
  try {
    await q(`UPDATE pedido_orden SET estado='CANCELADO' WHERE id=?`, [id])
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/pedidos')
  return { ok: true }
}

export async function agregarLineaPedido(pedidoId, linea) {
  try {
    await q(
      `INSERT INTO pedido_orden_linea (pedido_orden_id, sku_id, descripcion, cantidad, costo_unitario_usd)
       VALUES (?,?,?,?,?)`,
      [pedidoId, linea.sku_id || null, linea.descripcion, linea.cantidad, linea.costo_unitario_usd])
  } catch (e) {
    return { error: e.message }
  }
  revalidatePath('/pedidos')
  return { ok: true }
}

// ==========================================================
// CIERRE MENSUAL
// ==========================================================

export async function cerrarMes(_prev, fd) {
  const mes = parseInt(fd.get('mes'))
  const anio = parseInt(fd.get('anio'))
  const fecha_cierre = fd.get('fecha_cierre') || new Date().toISOString().split('T')[0]
  const notas = nn(fd.get('notas'))

  if (!mes || mes < 1 || mes > 12) return { error: 'Mes inválido' }
  if (!anio) return { error: 'Año inválido' }

  try {
    // Calcular todas las métricas del mes
    const fechaInicio = `${anio}-${String(mes).padStart(2, '0')}-01`
    const fechaFin = mes === 12 
      ? `${anio + 1}-01-01` 
      : `${anio}-${String(mes + 1).padStart(2, '0')}-01`

    // Ingresos totales
    const [ingresos] = await q(`
      SELECT COALESCE(SUM(vl.cantidad * vl.precio_unitario_mxn), 0) as total
      FROM venta v
      JOIN venta_linea vl ON vl.venta_id = v.id
      WHERE v.fecha >= ? AND v.fecha < ?
    `, [fechaInicio, fechaFin])

    // Costo de ventas
    const [costos] = await q(`
      SELECT COALESCE(SUM(vl.cantidad * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)), 0) as total
      FROM venta v
      JOIN venta_linea vl ON vl.venta_id = v.id
      LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vl.sku_id
      LEFT JOIN sku_costo sc ON sc.sku_id = vl.sku_id
      WHERE v.fecha >= ? AND v.fecha < ?
    `, [fechaInicio, fechaFin])

    // Comisiones totales
    const [comisiones] = await q(`
      SELECT COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0) as total
      FROM venta v
      JOIN venta_linea vl ON vl.venta_id = v.id
      JOIN venta_rol vr ON vr.venta_id = v.id
      JOIN comision_tarifa ct ON ct.rol_venta_id = vr.rol_venta_id
      WHERE v.fecha >= ? AND v.fecha < ?
        AND ct.vigente_desde <= v.fecha
        AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
    `, [fechaInicio, fechaFin])

    // Utilidad neta
    const utilidadNeta = parseFloat(ingresos.total) - parseFloat(costos.total) - parseFloat(comisiones.total)

    // Valor del inventario (al cierre del mes)
    const [inventario] = await q(`
      SELECT COALESCE(SUM(vs.disponible * COALESCE(vpc.costo_total_mxn, sc.costo_total_usd)), 0) as valor
      FROM v_stock vs
      LEFT JOIN v_pieza_costo vpc ON vpc.sku_id = vs.sku_id
      LEFT JOIN sku_costo sc ON sc.sku_id = vs.sku_id
      WHERE vs.disponible > 0
    `)

    // Número de ventas y piezas
    const [stats] = await q(`
      SELECT 
        COUNT(DISTINCT v.id) as num_ventas,
        COALESCE(SUM(vl.cantidad), 0) as num_piezas
      FROM venta v
      JOIN venta_linea vl ON vl.venta_id = v.id
      WHERE v.fecha >= ? AND v.fecha < ?
    `, [fechaInicio, fechaFin])

    const ticketPromedio = stats.num_ventas > 0 ? parseFloat(ingresos.total) / stats.num_ventas : 0

    // Comisiones por socio (JSON)
    const comisionesPorSocio = await q(`
      SELECT
        s.nombre,
        COALESCE(SUM(ct.pct * vl.cantidad * vl.precio_unitario_mxn), 0) as total
      FROM socio s
      LEFT JOIN venta_rol vr ON vr.socio_id = s.id
      LEFT JOIN venta v ON v.id = vr.venta_id AND v.fecha >= ? AND v.fecha < ?
      LEFT JOIN venta_linea vl ON vl.venta_id = v.id
      LEFT JOIN comision_tarifa ct ON ct.rol_venta_id = vr.rol_venta_id
        AND ct.vigente_desde <= v.fecha
        AND (ct.vigente_hasta IS NULL OR ct.vigente_hasta >= v.fecha)
      WHERE s.activo = 1
      GROUP BY s.nombre
    `, [fechaInicio, fechaFin])

    // Capital por socio (JSON)
    const capitalPorSocio = await q(`SELECT * FROM v_capital_socio`)

    // Insertar cierre
    await q(`
      INSERT INTO cierre_mensual 
        (mes, anio, fecha_cierre, ingresos_totales, costo_ventas, comisiones_totales, 
         utilidad_neta, valor_inventario, num_ventas, num_piezas_vendidas, ticket_promedio,
         comisiones_json, capital_json, notas)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    `, [
      mes, anio, fecha_cierre,
      ingresos.total, costos.total, comisiones.total,
      utilidadNeta, inventario.valor,
      stats.num_ventas, stats.num_piezas, ticketPromedio,
      JSON.stringify(comisionesPorSocio),
      JSON.stringify(capitalPorSocio),
      notas
    ])

  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: `Ya existe un cierre para ${mes}/${anio}` }
    return { error: e.message }
  }

  revalidatePath('/cierres')
  return { ok: true }
}

// ==========================================================
// CONFIGURACIÓN
// ==========================================================

export async function actualizarConfig(_prev, fd) {
  const clave = nn(fd.get('clave'))
  const valor = nn(fd.get('valor'))

  if (!clave || !valor) return { error: 'Clave y valor son obligatorios' }

  try {
    await q('UPDATE configuracion SET valor = ? WHERE clave = ?', [valor, clave])
  } catch (e) {
    return { error: e.message }
  }

  revalidatePath('/config')
  return { ok: true }
}

// ==========================================================
// LISTAS (CRUD genérico)
// ==========================================================

export async function crearMarca(_prev, fd) {
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!nombre) return { error: 'El nombre es obligatorio' }

  try {
    await q('INSERT INTO marca (nombre) VALUES (?)', [nombre])
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Esa marca ya existe' }
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

export async function actualizarMarca(_prev, fd) {
  const id = num(fd.get('id'))
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!id || !nombre) return { error: 'ID y nombre son obligatorios' }

  try {
    await q('UPDATE marca SET nombre = ? WHERE id = ?', [nombre, id])
  } catch (e) {
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

export async function eliminarMarca(id) {
  try {
    await q('DELETE FROM marca WHERE id = ?', [id])
  } catch (e) {
    if (e.code === 'ER_ROW_IS_REFERENCED_2') {
      return { error: 'No se puede eliminar: tiene productos asociados' }
    }
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

export async function crearTipoPrenda(_prev, fd) {
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!nombre) return { error: 'El nombre es obligatorio' }

  try {
    await q('INSERT INTO tipo_prenda (nombre) VALUES (?)', [nombre])
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Ese tipo ya existe' }
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

export async function crearUbicacion(_prev, fd) {
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!nombre) return { error: 'El nombre es obligatorio' }

  try {
    await q('INSERT INTO ubicacion (nombre) VALUES (?)', [nombre])
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Esa ubicación ya existe' }
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

export async function crearCanal(_prev, fd) {
  const nombre = String(fd.get('nombre') ?? '').trim()
  if (!nombre) return { error: 'El nombre es obligatorio' }

  try {
    await q('INSERT INTO canal (nombre) VALUES (?)', [nombre])
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') return { error: 'Ese canal ya existe' }
    return { error: e.message }
  }

  revalidatePath('/listas')
  return { ok: true }
}

// ==========================================================
// PEDIDOS - actualizar estado
// ==========================================================

export async function actualizarEstadoPedido(pedidoId, nuevoEstado) {
  try {
    const updates = { estado: nuevoEstado }
    if (nuevoEstado === 'RECIBIDO') {
      updates.fecha_recepcion = new Date().toISOString().split('T')[0]
    }

    const setClauses = Object.keys(updates).map(k => `${k}=?`).join(', ')
    const values = [...Object.values(updates), pedidoId]

    await q(`UPDATE pedido SET ${setClauses} WHERE id=?`, values)
  } catch (e) {
    return { error: e.message }
  }

  revalidatePath('/pedidos')
  redirect(`/pedidos/${pedidoId}`)
}
