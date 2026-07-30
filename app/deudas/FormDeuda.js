'use client'
import { useActionState } from 'react'
import { useState } from 'react'
import { guardarDeuda } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormDeuda() {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarDeuda, {})

  if (state?.ok) {
    setOpen(false)
    state.ok = false
  }

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
      >
        <Plus className="w-4 h-4" />
        Registrar Préstamo
      </button>

      {open && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-xl font-semibold text-stone-900">Registrar Préstamo</h2>
              <button
                onClick={() => setOpen(false)}
                className="p-1 hover:bg-stone-100 rounded transition-colors"
              >
                <X className="w-5 h-5 text-stone-500" />
              </button>
            </div>

            <form action={action} className="p-6 space-y-4">
              {state?.error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded text-sm text-red-700">
                  {state.error}
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Fecha del préstamo
                </label>
                <input
                  type="date"
                  name="fecha"
                  defaultValue={new Date().toISOString().split('T')[0]}
                  required
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Quién presta (Acreedor)
                </label>
                <select
                  name="socio_acreedor_id"
                  required
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                >
                  <option value="">Seleccionar...</option>
                  <option value="4">JJ</option>
                  <option value="5">Agusto</option>
                  <option value="6">Luise</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Quién debe (Deudor)
                </label>
                <select
                  name="socio_deudor_id"
                  required
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                >
                  <option value="">Seleccionar...</option>
                  <option value="4">JJ</option>
                  <option value="5">Agusto</option>
                  <option value="6">Luise</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Monto (MXN)
                </label>
                <input
                  type="number"
                  name="monto_mxn"
                  step="0.01"
                  min="0.01"
                  required
                  placeholder="1000.00"
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Motivo
                </label>
                <input
                  type="text"
                  name="motivo"
                  placeholder="Ej: Préstamo para compra de inventario"
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Fecha de vencimiento (opcional)
                </label>
                <input
                  type="date"
                  name="fecha_vencimiento"
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Notas (opcional)
                </label>
                <textarea
                  name="notas"
                  rows="2"
                  placeholder="Notas adicionales..."
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
                  Guardar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
