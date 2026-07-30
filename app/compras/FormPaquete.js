'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { guardarPaquete } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormPaquete({ paquete, cruceId, paqueterias, ubicaciones, className }) {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarPaquete, {})

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  return (
    <>
      <button type="button" onClick={() => setOpen(true)} className={className || 'btn-primary'}>
        <Plus className="w-4 h-4" />
        Nuevo paquete
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="card w-full max-w-lg shadow-panel">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">{paquete ? 'Editar paquete' : 'Nuevo paquete'}</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <input type="hidden" name="id" value={paquete?.id || ''} />
              <input type="hidden" name="cruce_id" value={cruceId || paquete?.cruce_id || ''} />

              <div>
                <label className="label">Guía (CASI / tracking)</label>
                <input
                  type="text"
                  name="guia"
                  defaultValue={paquete?.guia}
                  placeholder="420785219434640109629005071033"
                  className="input"
                  required
                />
              </div>

              <div>
                <label className="label">Paquetería</label>
                <select name="paqueteria_id" defaultValue={paquete?.paqueteria_id || ''} className="input">
                  <option value="">—</option>
                  {paqueterias.map(p => (
                    <option key={p.id} value={p.id}>{p.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="label">Fecha llegada</label>
                <input
                  type="date"
                  name="fecha_llegada"
                  defaultValue={paquete?.fecha_llegada || new Date().toISOString().slice(0, 10)}
                  className="input"
                />
              </div>

              <div>
                <label className="label">Ubicación</label>
                <select name="ubicacion_id" defaultValue={paquete?.ubicacion_id || ''} className="input">
                  <option value="">—</option>
                  {ubicaciones.map(u => (
                    <option key={u.id} value={u.id}>{u.nombre}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="label">Estado</label>
                <select name="estado" defaultValue={paquete?.estado || 'RECIBIDO'} className="input">
                  <option value="PENDIENTE">Pendiente</option>
                  <option value="EN_TRANSITO">En tránsito</option>
                  <option value="RECIBIDO">Recibido</option>
                  <option value="CANCELADO">Cancelado</option>
                </select>
              </div>

              <div>
                <label className="label">Notas (opcional)</label>
                <textarea name="notas" defaultValue={paquete?.notas} rows="2" className="input" />
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
