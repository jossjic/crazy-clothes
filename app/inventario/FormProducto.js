'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { guardarProducto } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormProducto({ marcas, tipos }) {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarProducto, {})

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} className="btn-secondary">
        <Plus className="w-4 h-4" />
        Nuevo producto
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-lg shadow-panel">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">Nuevo producto</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <div>
                <label className="label">Nombre</label>
                <input
                  type="text"
                  name="nombre"
                  placeholder="Batman Compression Tees"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Marca</label>
                <select name="marca_id" className="input" required>
                  <option value="">Elige una marca</option>
                  {marcas.map(m => (
                    <option key={m.id} value={m.id}>{m.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="label">Tipo de prenda</label>
                <select name="tipo_prenda_id" className="input" required>
                  <option value="">Elige un tipo</option>
                  {tipos.map(t => (
                    <option key={t.id} value={t.id}>{t.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="label">Código proveedor (opcional)</label>
                <input
                  type="text"
                  name="codigo_proveedor"
                  placeholder="4286"
                  className="input"
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
