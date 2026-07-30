'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { useRouter } from 'next/navigation'
import { guardarVenta } from '@/lib/actions'
import { Plus, Trash2, ArrowLeft } from 'lucide-react'
import Link from 'next/link'

export default function FormVenta({ venta, stock, canales, socios, rolesVenta }) {
  const router = useRouter()
  const [lineas, setLineas] = useState(venta?.lineas || [])
  const [roles, setRoles] = useState(venta?.roles || {})
  const [state, action] = useActionState(guardarVenta, {})

  useEffect(() => {
    if (state?.ok) {
      router.push('/ventas')
      router.refresh()
    }
  }, [state, router])

  const agregarLinea = () => {
    setLineas([...lineas, { sku_id: '', cantidad: 1, precio_unitario_mxn: 0, descuento_mxn: 0 }])
  }

  const quitarLinea = (idx) => {
    setLineas(lineas.filter((_, i) => i !== idx))
  }

  const total = lineas.reduce((sum, l) => sum + (Number(l.cantidad) * Number(l.precio_unitario_mxn) - Number(l.descuento_mxn)), 0)

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Link href="/ventas" className="btn-ghost p-2">
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-semibold text-stone-900">
            {venta ? 'Editar venta' : 'Nueva venta'}
          </h1>
        </div>
      </div>

      <form action={action} className="space-y-6">
        <input type="hidden" name="id" value={venta?.id || ''} />
        <input type="hidden" name="lineas" value={JSON.stringify(lineas)} />
        <input type="hidden" name="roles" value={JSON.stringify(roles)} />

        <div className="card card-body space-y-4">
          <h2 className="text-lg font-semibold text-stone-900">Datos generales</h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label">Folio (opcional)</label>
              <input type="text" name="folio" defaultValue={venta?.folio} className="input" placeholder="V-001" />
            </div>
            <div>
              <label className="label">Fecha</label>
              <input
                type="date"
                name="fecha"
                defaultValue={venta?.fecha || new Date().toISOString().slice(0, 10)}
                className="input"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="label">Cliente</label>
              <input type="text" name="cliente" defaultValue={venta?.cliente} className="input" />
            </div>
            <div>
              <label className="label">Canal</label>
              <select name="canal_id" defaultValue={venta?.canal_id || ''} className="input">
                <option value="">—</option>
                {canales.map(c => (
                  <option key={c.id} value={c.id}>{c.nombre}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="label">Estado</label>
            <select name="estado" defaultValue={venta?.estado || 'CERRADA'} className="input">
              <option value="CERRADA">Cerrada</option>
              <option value="APARTADO">Apartado</option>
              <option value="CANCELADO">Cancelado</option>
            </select>
          </div>

          <div>
            <label className="label">Notas</label>
            <textarea name="notas" defaultValue={venta?.notas} rows="2" className="input" />
          </div>
        </div>

        <div className="card">
          <div className="card-header flex items-center justify-between">
            <h2 className="text-lg font-semibold">Prendas</h2>
            <button type="button" onClick={agregarLinea} className="btn-secondary text-xs">
              <Plus className="w-4 h-4" />
              Agregar prenda
            </button>
          </div>
          <div className="card-body space-y-3">
            {lineas.length === 0 && (
              <p className="text-center text-stone-500 py-8">
                Agrega al menos una prenda a la venta.
              </p>
            )}
            {lineas.map((l, idx) => (
              <div key={idx} className="flex gap-3 items-start p-3 bg-stone-50 rounded-lg">
                <div className="flex-1 grid grid-cols-1 md:grid-cols-5 gap-3">
                  <div className="md:col-span-2">
                    <select
                      value={l.sku_id}
                      onChange={(e) => {
                        const sku = stock.find(s => s.sku_id === Number(e.target.value))
                        const nuevoLineas = [...lineas]
                        nuevoLineas[idx] = {
                          ...l,
                          sku_id: e.target.value,
                          precio_unitario_mxn: sku?.precio_lista_mxn || 0,
                        }
                        setLineas(nuevoLineas)
                      }}
                      className="input text-xs"
                      required
                    >
                      <option value="">Elige un SKU</option>
                      {stock.map(s => (
                        <option key={s.sku_id} value={s.sku_id}>
                          {s.codigo} — {s.producto} {s.talla} {s.color} (stock: {s.disponible})
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <input
                      type="number"
                      value={l.cantidad}
                      onChange={(e) => {
                        const nuevoLineas = [...lineas]
                        nuevoLineas[idx].cantidad = e.target.value
                        setLineas(nuevoLineas)
                      }}
                      min="1"
                      placeholder="Cant"
                      className="input text-xs"
                      required
                    />
                  </div>
                  <div>
                    <input
                      type="number"
                      value={l.precio_unitario_mxn}
                      onChange={(e) => {
                        const nuevoLineas = [...lineas]
                        nuevoLineas[idx].precio_unitario_mxn = e.target.value
                        setLineas(nuevoLineas)
                      }}
                      step="0.01"
                      placeholder="Precio"
                      className="input text-xs"
                      required
                    />
                  </div>
                  <div>
                    <input
                      type="number"
                      value={l.descuento_mxn}
                      onChange={(e) => {
                        const nuevoLineas = [...lineas]
                        nuevoLineas[idx].descuento_mxn = e.target.value
                        setLineas(nuevoLineas)
                      }}
                      step="0.01"
                      placeholder="Descuento"
                      className="input text-xs"
                    />
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => quitarLinea(idx)}
                  className="btn-ghost p-2 text-red-600 hover:bg-red-50"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))}
            {lineas.length > 0 && (
              <div className="flex justify-end pt-3 border-t border-stone-200">
                <div className="text-right">
                  <p className="text-sm text-stone-600">Total</p>
                  <p className="text-2xl font-semibold font-mono">
                    ${total.toLocaleString('es-MX', { minimumFractionDigits: 2 })}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>

        <div className="card card-body space-y-4">
          <h2 className="text-lg font-semibold">Roles</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {rolesVenta.map(r => (
              <div key={r.id}>
                <label className="label">{r.nombre}</label>
                <select
                  value={roles[r.id] || ''}
                  onChange={(e) => setRoles({ ...roles, [r.id]: e.target.value })}
                  className="input"
                >
                  <option value="">—</option>
                  {socios.map(s => (
                    <option key={s.id} value={s.id}>{s.nombre}</option>
                  ))}
                </select>
              </div>
            ))}
          </div>
        </div>

        {state?.error && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-sm text-red-800">
            {state.error}
          </div>
        )}

        {state?.avisos && state.avisos.length > 0 && (
          <div className="p-4 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800">
            <p className="font-medium mb-2">Advertencias de stock:</p>
            <ul className="list-disc list-inside space-y-1">
              {state.avisos.map((a, i) => (
                <li key={i}>{a}</li>
              ))}
            </ul>
          </div>
        )}

        <div className="flex gap-3 justify-end">
          <Link href="/ventas" className="btn-secondary">
            Cancelar
          </Link>
          <SubmitButton />
        </div>
      </form>
    </div>
  )
}

function SubmitButton() {
  const { pending } = useFormStatus()
  return (
    <button type="submit" disabled={pending} className="btn-primary">
      {pending ? 'Guardando...' : 'Guardar venta'}
    </button>
  )
}
