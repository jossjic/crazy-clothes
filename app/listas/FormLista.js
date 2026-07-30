'use client'
import { useActionState } from 'react'
import { useState } from 'react'
import { Plus, X } from 'lucide-react'

const LABELS = {
  marca: 'Marca',
  tipo_prenda: 'Tipo de Prenda',
  ubicacion: 'Ubicación',
  canal: 'Canal'
}

export default function FormLista({ tipo, action }) {
  const [open, setOpen] = useState(false)
  const [state, formAction] = useActionState(action, {})

  if (state?.ok) {
    setOpen(false)
    state.ok = false
  }

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-1 px-2 py-1 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
      >
        <Plus className="w-4 h-4" />
      </button>

      {open && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-xl font-semibold text-stone-900">
                Nueva {LABELS[tipo]}
              </h2>
              <button
                onClick={() => setOpen(false)}
                className="p-1 hover:bg-stone-100 rounded transition-colors"
              >
                <X className="w-5 h-5 text-stone-500" />
              </button>
            </div>

            <form action={formAction} className="p-6 space-y-4">
              {state?.error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded text-sm text-red-700">
                  {state.error}
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Nombre
                </label>
                <input
                  type="text"
                  name="nombre"
                  required
                  autoFocus
                  placeholder={`Ej: ${tipo === 'marca' ? 'Nike' : tipo === 'tipo_prenda' ? 'Playera' : tipo === 'ubicacion' ? 'Puebla' : 'Instagram'}`}
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div className="flex gap-3 pt-4">
                <button
                  type="button"
                  onClick={() => setOpen(false)}
                  className="flex-1 px-4 py-2 border border-stone-300 rounded-lg hover:bg-stone-50 transition-colors"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Crear
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
