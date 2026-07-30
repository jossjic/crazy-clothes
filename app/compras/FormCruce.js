'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { guardarCruce } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormCruce({ cruce, className }) {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarCruce, {})

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} className={className || 'btn-primary'}>
        <Plus className="w-4 h-4" />
        Nuevo cruce
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-lg shadow-panel">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">{cruce ? 'Editar cruce' : 'Nuevo cruce'}</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <input type="hidden" name="id" value={cruce?.id || ''} />

              <div>
                <label className="label">Folio CONS</label>
                <input
                  type="text"
                  name="folio"
                  defaultValue={cruce?.folio}
                  placeholder="CONS9962926323"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Fecha</label>
                <input
                  type="date"
                  name="fecha"
                  defaultValue={cruce?.fecha || new Date().toISOString().slice(0, 10)}
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Costo del cruce (MXN)</label>
                <input
                  type="number"
                  name="costo_mxn"
                  defaultValue={cruce?.costo_mxn}
                  step="0.01"
                  placeholder="0.00"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Notas (opcional)</label>
                <textarea name="notas" defaultValue={cruce?.notas} rows="2" className="input" />
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
