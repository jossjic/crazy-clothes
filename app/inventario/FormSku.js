'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { guardarSku } from '@/lib/actions'
import { Plus, Edit2, X } from 'lucide-react'

export default function FormSku({ sku, productos }) {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarSku, {})

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className={sku ? 'btn-ghost text-xs' : 'btn-primary'}
      >
        {sku ? <><Edit2 className="w-4 h-4" />Editar</> : <><Plus className="w-4 h-4" />Nuevo SKU</>}
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-lg shadow-panel">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">{sku ? 'Editar SKU' : 'Nuevo SKU'}</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <input type="hidden" name="id" value={sku?.id || ''} />

              <div>
                <label className="label">Código SKU</label>
                <input
                  type="text"
                  name="codigo"
                  defaultValue={sku?.codigo}
                  placeholder="JNG-0001"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Producto</label>
                <select name="producto_id" defaultValue={sku?.producto_id || ''} className="input" required>
                  <option value="">Elige un producto</option>
                  {productos.map(p => (
                    <option key={p.id} value={p.id}>
                      {p.marca} — {p.nombre}
                    </option>
                  ))}
                </select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Talla</label>
                  <input
                    type="text"
                    name="talla"
                    defaultValue={sku?.talla}
                    placeholder="M"
                    className="input"
                    required
                  />
                </div>
                <div>
                  <label className="label">Color</label>
                  <input
                    type="text"
                    name="color"
                    defaultValue={sku?.color}
                    placeholder="Black"
                    className="input"
                    required
                  />
                </div>
              </div>

              <div>
                <label className="label">Precio lista (MXN)</label>
                <input
                  type="number"
                  name="precio_lista_mxn"
                  defaultValue={sku?.precio_lista_mxn || ''}
                  step="0.01"
                  className="input"
                  placeholder="0.00"
                />
              </div>

              {state?.error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-800">
                  {state.error}
                </div>
              )}

              <div className="flex gap-3 justify-end pt-2">
                <button type="button" onClick={() => setOpen(false)} className="btn-secondary">
                  Cancelar
                </button>
                <SubmitButton />
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}

function SubmitButton() {
  const { pending } = useFormStatus()
  return (
    <button type="submit" disabled={pending} className="btn-primary">
      {pending ? 'Guardando...' : 'Guardar'}
    </button>
  )
}
