import { q } from '@/lib/db'
import { Settings, Save } from 'lucide-react'
import { actualizarConfig } from '@/lib/actions'

export const dynamic = 'force-dynamic'

export default async function ConfigPage() {
  const configs = await q('SELECT * FROM configuracion ORDER BY clave')

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-stone-900">Configuración del Sistema</h1>
        <p className="text-sm text-stone-500 mt-1">
          Parámetros editables sin tocar código
        </p>
      </div>

      <div className="bg-white rounded-lg border border-stone-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-stone-200">
          <h2 className="text-lg font-semibold text-stone-900">Parámetros</h2>
        </div>
        <div className="divide-y divide-stone-200">
          {configs.map(c => (
            <form key={c.clave} action={actualizarConfig} className="px-6 py-4">
              <input type="hidden" name="clave" value={c.clave} />
              <div className="flex items-center gap-4">
                <div className="flex-1">
                  <label className="block text-sm font-medium text-stone-900 mb-1">
                    {c.descripcion || c.clave}
                  </label>
                  <p className="text-xs text-stone-500 mb-2">
                    Clave: <code className="bg-stone-100 px-1 py-0.5 rounded">{c.clave}</code>
                    {' · '}Tipo: {c.tipo}
                  </p>
                  <div className="flex items-center gap-2">
                    {c.tipo === 'NUMBER' ? (
                      <input
                        type="number"
                        name="valor"
                        step="0.01"
                        defaultValue={c.valor}
                        className="px-3 py-2 border border-stone-300 rounded-lg w-48"
                      />
                    ) : c.tipo === 'BOOLEAN' ? (
                      <select
                        name="valor"
                        defaultValue={c.valor}
                        className="px-3 py-2 border border-stone-300 rounded-lg w-48"
                      >
                        <option value="true">Activado</option>
                        <option value="false">Desactivado</option>
                      </select>
                    ) : (
                      <input
                        type="text"
                        name="valor"
                        defaultValue={c.valor}
                        className="px-3 py-2 border border-stone-300 rounded-lg flex-1"
                      />
                    )}
                    <button
                      type="submit"
                      className="inline-flex items-center gap-1 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      <Save className="w-4 h-4" />
                      Guardar
                    </button>
                  </div>
                </div>
              </div>
            </form>
          ))}
        </div>
      </div>

      <div className="p-4 bg-amber-50 rounded-lg border border-amber-200">
        <p className="text-sm text-amber-900">
          <strong>⚠️ Nota:</strong> Estos parámetros están guardados en la base de datos.
          Los cambios afectan el comportamiento del sistema inmediatamente.
          Para agregar nuevos parámetros, edita la tabla <code>configuracion</code>.
        </p>
      </div>
    </div>
  )
}
