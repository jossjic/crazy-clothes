'use client'
import { useActionState } from 'react'
import { useState } from 'react'
import { guardarPedidoOrden } from '@/lib/actions'
import { Plus, X } from 'lucide-react'

export default function FormPedido() {
  const [open, setOpen] = useState(false)
  const [state, action] = useActionState(guardarPedidoOrden, {})

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
        Nuevo Pedido
      </button>

      {open && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-6 border-b border-stone-200">
              <h2 className="text-xl font-semibold text-stone-900">Nuevo Pedido a Proveedor</h2>
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
                  Folio (opcional)
                </label>
                <input
                  type="text"
                  name="folio"
                  placeholder="Ej: PED-2026-001"
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Fecha del pedido
                </label>
                <input
                  type="date"
                  name="fecha_pedido"
                  defaultValue={new Date().toISOString().split('T')[0]}
                  required
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Proveedor
                </label>
                <input
                  type="text"
                  name="proveedor"
                  placeholder="Nombre del proveedor"
                  required
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Monto total USD (opcional)
                </label>
                <input
                  type="number"
                  name="monto_total_usd"
                  step="0.01"
                  min="0"
                  placeholder="1000.00"
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-stone-700 mb-1">
                  Notas (opcional)
                </label>
                <textarea
                  name="notas"
                  rows="3"
                  placeholder="Detalles del pedido..."
                  className="w-full px-3 py-2 border border-stone-300 rounded-lg"
                />
              </div>

              <div className="p-3 bg-blue-50 rounded-lg">
                <p className="text-xs text-blue-800">
                  <strong>💡 Nota:</strong> Después de crear el pedido, podrás agregar líneas/productos
                  en la página de detalle y marcar cambios de estado (Enviado → Recibido).
                </p>
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
                  Crear Pedido
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  )
}
