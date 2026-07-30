import { q } from '@/lib/db'
import { List, Plus, Edit2, Trash2 } from 'lucide-react'
import { crearMarca, crearTipoPrenda, crearUbicacion, crearCanal } from '@/lib/actions'
import FormLista from './FormLista'

export const dynamic = 'force-dynamic'

export default async function ListasPage() {
  const [marcas, tipos, ubicaciones, canales] = await Promise.all([
    q('SELECT * FROM marca ORDER BY nombre'),
    q('SELECT * FROM tipo_prenda ORDER BY nombre'),
    q('SELECT * FROM ubicacion ORDER BY nombre'),
    q('SELECT * FROM canal ORDER BY nombre'),
  ])

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Listas del Sistema</h1>
        <p className="text-sm text-stone-500 mt-1">
          CRUD de catálogos: marcas, tipos de prenda, ubicaciones, canales
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Marcas */}
        <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-200 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-stone-900">Marcas</h2>
            <FormLista tipo="marca" action={crearMarca} />
          </div>
          <div className="divide-y divide-stone-200 max-h-96 overflow-y-auto">
            {marcas.length === 0 ? (
              <p className="px-6 py-8 text-center text-sm text-stone-500">No hay marcas</p>
            ) : (
              marcas.map(m => (
                <div key={m.id} className="px-6 py-3 flex items-center justify-between hover:bg-stone-50 transition-colors">
                  <span className="text-sm text-stone-900">{m.nombre}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Tipos de Prenda */}
        <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-200 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-stone-900">Tipos de Prenda</h2>
            <FormLista tipo="tipo_prenda" action={crearTipoPrenda} />
          </div>
          <div className="divide-y divide-stone-200 max-h-96 overflow-y-auto">
            {tipos.length === 0 ? (
              <p className="px-6 py-8 text-center text-sm text-stone-500">No hay tipos</p>
            ) : (
              tipos.map(t => (
                <div key={t.id} className="px-6 py-3 flex items-center justify-between hover:bg-stone-50 transition-colors">
                  <span className="text-sm text-stone-900">{t.nombre}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Ubicaciones */}
        <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-200 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-stone-900">Ubicaciones</h2>
            <FormLista tipo="ubicacion" action={crearUbicacion} />
          </div>
          <div className="divide-y divide-stone-200 max-h-96 overflow-y-auto">
            {ubicaciones.length === 0 ? (
              <p className="px-6 py-8 text-center text-sm text-stone-500">No hay ubicaciones</p>
            ) : (
              ubicaciones.map(u => (
                <div key={u.id} className="px-6 py-3 flex items-center justify-between hover:bg-stone-50 transition-colors">
                  <span className="text-sm text-stone-900">{u.nombre}</span>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Canales */}
        <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-stone-200 flex items-center justify-between">
            <h2 className="text-lg font-semibold text-stone-900">Canales</h2>
            <FormLista tipo="canal" action={crearCanal} />
          </div>
          <div className="divide-y divide-stone-200 max-h-96 overflow-y-auto">
            {canales.length === 0 ? (
              <p className="px-6 py-8 text-center text-sm text-stone-500">No hay canales</p>
            ) : (
              canales.map(c => (
                <div key={c.id} className="px-6 py-3 flex items-center justify-between hover:bg-stone-50 transition-colors">
                  <span className="text-sm text-stone-900">{c.nombre}</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
        <p className="text-sm text-blue-900">
          <strong>💡 Tip:</strong> Estas listas son los catálogos base del sistema.
          Al agregar/editar se valida que no haya duplicados. Para eliminar un elemento,
          primero asegúrate de que no tenga productos asociados.
        </p>
      </div>
    </div>
  )
}
