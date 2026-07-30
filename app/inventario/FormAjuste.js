'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { ajustarStock } from '@/lib/actions'
import { Plus, Minus, X } from 'lucide-react'

export default function FormAjuste({ skuId, codigo, ubicaciones }) {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(ajustarStock, {})

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} className="btn-ghost text-xs">
        Ajustar
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-md shadow-panel">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">Ajustar stock</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <input type="hidden" name="sku_id" value={skuId} />

              <div className="p-3 bg-stone-50 rounded-lg">
                <p className="text-sm text-stone-600">SKU</p>
                <p className="font-mono text-sm font-medium">{codigo}</p>
              </div>

              <div>
                <label className="label">Cantidad</label>
                <input
                  type="number"
                  name="cantidad"
                  min="1"
                  defaultValue="1"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Tipo de ajuste</label>
                <div className="flex gap-3">
                  <label className="flex-1 flex items-center gap-2 p-3 border border-stone-300 rounded-lg cursor-pointer hover:bg-stone-50">
                    <input type="radio" name="sentido" value="MAS" defaultChecked className="text-accent-600" />
                    <Plus className="w-4 h-4 text-green-600" />
                    <span className="text-sm">Sumar</span>
                  </label>
                  <label className="flex-1 flex items-center gap-2 p-3 border border-stone-300 rounded-lg cursor-pointer hover:bg-stone-50">
                    <input type="radio" name="sentido" value="MENOS" className="text-accent-600" />
                    <Minus className="w-4 h-4 text-red-600" />
                    <span className="text-sm">Restar</span>
                  </label>
                </div>
              </div>

              <div>
                <label className="label">Ubicación</label>
                <select name="ubicacion_id" className="input" required>
                  <option value="">Elige una ubicación</option>
                  {ubicaciones.map(u => (
                    <option key={u.id} value={u.id}>{u.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="label">Notas (opcional)</label>
                <textarea name="notas" rows="2" className="input" placeholder="Ej: corrección de inventario físico" />
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
      {pending ? 'Ajustando...' : 'Ajustar'}
    </button>
  )
}
