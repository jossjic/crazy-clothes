'use client'
import { useActionState } from 'react'
import { useState } from 'react'
import { cerrarMes } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormCierre() {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(cerrarMes, {})

  // Auto-detectar mes/año actual
  const now = new Date()
  const mesActual = now.getMonth() + 1
  const anioActual = now.getFullYear()

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
        Cerrar Mes
      </button>

      {open && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-xl font-semibold text-stone-900">Cerrar Mes</h2>
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

              <div className="p-4 bg-blue-50 rounded-lg">
                <p className="text-sm text-blue-900 mb-2">
                  <strong>📸 Snapshot mensual</strong>
                </p>
                <p className="text-xs text-blue-800">
                  Esto guardará un snapshot permanente de todas las métricas del mes seleccionado:
                  ingresos, costos, utilidad, inventario, comisiones y capital.
                </p>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-stone-700 mb-1">
                    Mes
                  </label>
                  <select
                    name="mes"
                    defaultValue={mesActual}
                    required
                    className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                  >
                    <option value="1">Enero</option>
                    <option value="2">Febrero</option>
                    <option value="3">Marzo</option>
                    <option value="4">Abril</option>
                    <option value="5">Mayo</option>
                    <option value="6">Junio</option>
                    <option value="7">Julio</option>
                    <option value="8">Agosto</option>
                    <option value="9">Septiembre</option>
                    <option value="10">Octubre</option>
                    <option value="11">Noviembre</option>
                    <option value="12">Diciembre</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-stone-700 mb-1">
                    Año
                  </label>
                  <input
                    type="number"
                    name="anio"
                    defaultValue={anioActual}
                    min="2020"
                    max="2030"
                    required
                    className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Fecha de cierre
                </label>
                <input
                  type="date"
                  name="fecha_cierre"
                  defaultValue={new Date().toISOString().split('T')[0]}
                  required
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
                  placeholder="Notas sobre este cierre..."
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
                  Crear Cierre
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
