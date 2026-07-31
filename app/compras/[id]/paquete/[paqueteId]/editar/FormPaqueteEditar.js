'use client'

import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { useRouter } from 'next/navigation'
import { Save, Trash2, AlertTriangle } from 'lucide-react'
import { guardarPaquete, borrarPaquete } from '@/lib/actions'

export default function FormPaqueteEditar({ paquete, cruceId, paqueterias, ubicaciones, cruces }) {
  const router = useRouter()
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false)
  const [updateState, updateAction] = useActionState(guardarPaquete, {})
  const [deleteState, deleteAction] = useActionState(borrarPaquete, {})

  useEffect(() => {
    if (updateState?.ok) {
      router.push(`/compras/${cruceId}/paquete/${paquete.id}`)
    }
  }, [updateState, cruceId, paquete.id, router])

  useEffect(() => {
    if (deleteState?.ok) {
      router.push(`/compras/${cruceId}`)
    }
  }, [deleteState, cruceId, router])

  return (
    <div className="space-y-6">
      {/* Formulario de edición */}
      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Información del Paquete</h2>
        </div>
        <form action={updateAction} className="p-6 space-y-4">
          <input type="hidden" name="id" value={paquete.id} />

          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">
              Número de Guía <span className="text-red-600">*</span>
            </label>
            <input
              type="text"
              name="guia"
              defaultValue={paquete.guia}
              placeholder="1Z08X89AYW00349426"
              className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              required
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Paquetería</label>
              <select
                name="paqueteria_id"
                defaultValue={paquete.paqueteria_id || ''}
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Sin especificar</option>
                {paqueterias.map(p => (
                  <option key={p.id} value={p.id}>{p.nombre}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Cruce</label>
              <select
                name="cruce_id"
                defaultValue={paquete.cruce_id || ''}
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Sin asignar (guía perdida)</option>
                {cruces.map(c => (
                  <option key={c.id} value={c.id}>{c.folio}</option>
                ))}
              </select>
              <p className="text-xs text-stone-500 mt-1">
                Dejar en blanco si no sabes en qué cruce viajó
              </p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Fecha de llegada</label>
              <input
                type="date"
                name="fecha_llegada"
                defaultValue={paquete.fecha_llegada}
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-stone-700 mb-1">Ubicación</label>
              <select
                name="ubicacion_id"
                defaultValue={paquete.ubicacion_id || ''}
                className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="">Sin especificar</option>
                {ubicaciones.map(u => (
                  <option key={u.id} value={u.id}>{u.nombre}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">Estado</label>
            <select
              name="estado"
              defaultValue={paquete.estado || 'RECIBIDO'}
              className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="PENDIENTE">Pendiente</option>
              <option value="EN_TRANSITO">En tránsito</option>
              <option value="RECIBIDO">Recibido</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-stone-700 mb-1">
              Notas
            </label>
            <textarea
              name="notas"
              defaultValue={paquete.notas || ''}
              rows="4"
              placeholder="Ej: TrackPan - taxes ($15) + seguro ($8.50) = $23.50 USD&#10;Guía sin piezas físicas, solo gastos administrativos"
              className="w-full px-3 py-2 border border-stone-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            <p className="text-xs text-stone-500 mt-1">
              Usa este campo para explicar paquetes sin piezas (ej: TrackPan, taxes, seguros)
            </p>
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
                <p className="text-sm font-medium text-stone-900">Eliminar este paquete</p>
                <p className="text-sm text-stone-600 mt-1">
                  Esta acción eliminará el paquete y todas sus piezas asociadas. No se puede deshacer.
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
                    Se eliminará el paquete <strong>{paquete.guia}</strong> y todas sus piezas.
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
                <input type="hidden" name="id" value={paquete.id} />
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
