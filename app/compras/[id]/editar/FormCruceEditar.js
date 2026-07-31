'use client'

import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { useRouter } from 'next/navigation'
import { Save, Trash2, AlertTriangle } from 'lucide-react'
import { guardarCruce, eliminarCruce } from '@/lib/actions'

export default function FormCruceEditar({ cruce }) {
  const router = useRouter()
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
  const [updateState, updateAction] = useActionState(guardarCruce, {})
  const [deleteState, deleteAction] = useActionState(eliminarCruce, {})

  useEffect(() => {
    if (updateState?.ok) {
      router.push(`/compras/${cruce.id}`)
    }
  }, [updateState, cruce.id, router])

  useEffect(() => {
    if (deleteState?.ok) {
      router.push('/compras')
    }
  }, [deleteState, router])

  return (
    <div className="space-y-6">
      {/* Formulario de edición */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Información del Cruce</h2>
        </div>
        <form action={updateAction} className="p-6 space-y-4">
          <input type="hidden" name="id" value={cruce.id} />

          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">Folio</label>
            <input
              type="text"
              name="folio"
              defaultValue={cruce.folio}
              placeholder="CONS9962926323"
              className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Fecha</label>
              <input
                type="date"
                name="fecha"
                defaultValue={cruce.fecha}
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Costo (MXN)</label>
              <input
                type="number"
                name="costo_mxn"
                defaultValue={cruce.costo_mxn}
                step="0.01"
                placeholder="0.00"
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                required
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">Notas (opcional)</label>
            <textarea
              name="notas"
              defaultValue={cruce.notas || ''}
              rows="3"
              className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>

          {updateState?.error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-800">
              {updateState.error}
            </div>
          )}

          <div className="flex gap-3 justify-end pt-2">
            <button
              type="button"
              onClick={() => router.back()}
              className="px-4 py-2 text-stone-700 bg-stone-100 hover:bg-stone-200 rounded-lg transition-colors"
            >
              Cancelar
            </button>
            <UpdateButton />
          </div>
        </form>
      </div>

      {/* Zona de peligro - Eliminar */}
      <div className="bg-white rounded-lg border border-red-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-red-200 bg-red-50">
          <h2 className="text-lg font-semibold text-red-900">Zona de Peligro</h2>
        </div>
        <div className="p-6">
          {!showDeleteConfirm ? (
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <p className="text-sm font-medium text-stone-900">Eliminar este cruce</p>
                <p className="text-sm text-stone-600 mt-1">
                  Esta acción eliminará el cruce y todos sus paquetes y piezas asociadas. No se puede deshacer.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setShowDeleteConfirm(true)}
                className="ml-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors flex items-center gap-2"
              >
                <Trash2 className="w-4 h-4" />
                Eliminar
              </button>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-4 bg-amber-50 border border-amber-200 rounded-lg">
                <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-semibold text-amber-900">¿Estás seguro?</p>
                  <p className="text-sm text-amber-800 mt-1">
                    Se eliminará el cruce <strong>{cruce.folio}</strong> y todos sus datos relacionados.
                    Esta acción es permanente y no se puede deshacer.
                  </p>
                </div>
              </div>

              {deleteState?.error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-800">
                  {deleteState.error}
                </div>
              )}

              <form action={deleteAction} className="flex gap-3 justify-end">
                <input type="hidden" name="id" value={cruce.id} />
                <button
                  type="button"
                  onClick={() => setShowDeleteConfirm(false)}
                  className="px-4 py-2 text-stone-700 bg-stone-100 hover:bg-stone-200 rounded-lg transition-colors"
                >
                  Cancelar
                </button>
                <DeleteButton />
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

function UpdateButton() {
  const { pending } = useFormStatus()
  return (
    <button
      type="submit"
      disabled={pending}
      className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 flex items-center gap-2"
    >
      <Save className="w-4 h-4" />
      {pending ? 'Guardando...' : 'Guardar cambios'}
    </button>
  )
}

function DeleteButton() {
  const { pending } = useFormStatus()
  return (
    <button
      type="submit"
      disabled={pending}
      className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors disabled:opacity-50 flex items-center gap-2"
    >
      <Trash2 className="w-4 h-4" />
      {pending ? 'Eliminando...' : 'Sí, eliminar definitivamente'}
    </button>
  )
}
