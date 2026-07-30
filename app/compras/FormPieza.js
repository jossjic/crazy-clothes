'use client'
import { useState, useEffect } from 'react'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { guardarPieza } from '@/lib/actions'
import { Plus, Edit2, X, Search } from 'lucide-react'

export default function FormPieza({ pieza, paqueteId, marcas, tipos, socios, skus, className }) {
  const [open, setOpen] = useState(false)
  const [destino, setDestino] = useState(pieza?.destino || 'NEGOCIO')
  const [modoSku, setModoSku] = useState('existente') // 'existente' | 'nuevo'
  const [skuSeleccionado, setSkuSeleccionado] = useState(pieza?.sku_id || '')
  const [state, action] = useActionState(guardarPieza, {})

  // Autocomplete cuando seleccionas un SKU existente
  const [autoMarca, setAutoMarca] = useState('')
  const [autoTipo, setAutoTipo] = useState('')
  const [autoTalla, setAutoTalla] = useState('')
  const [autoColor, setAutoColor] = useState('')

  useEffect(() => {
    if (state?.ok) {
      setOpen(false)
    }
  }, [state])

  // Inicializar valores cuando se edita una pieza existente
  useEffect(() => {
    if (pieza && open) {
      setAutoMarca(pieza.marca_id || '')
      setAutoTipo(pieza.tipo_prenda_id || '')
      if (pieza.sku_id) {
        setModoSku('existente')
        setSkuSeleccionado(pieza.sku_id)
      }
    }
  }, [pieza, open])

  useEffect(() => {
    if (modoSku === 'existente' && skuSeleccionado) {
      const sku = skus.find(s => s.id === Number(skuSeleccionado))
      if (sku) {
        setAutoMarca(sku.marca_id || '')
        setAutoTipo(sku.tipo_prenda_id || '')
        setAutoTalla(sku.talla || '')
        setAutoColor(sku.color || '')
      }
    } else if (modoSku === 'nuevo') {
      // En modo nuevo, limpiar solo si no estamos editando
      if (!pieza) {
        setAutoMarca('')
        setAutoTipo('')
      }
      setAutoTalla('')
      setAutoColor('')
    }
  }, [modoSku, skuSeleccionado, skus, pieza])

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className={className || (pieza ? 'btn-ghost text-xs' : 'btn-primary')}
      >
        {pieza ? <><Edit2 className="w-4 h-4" />Editar</> : <><Plus className="w-4 h-4" />Nueva pieza</>}
      </button>

      {open && (
        <div className="fixed inset-0 bg-stone-900/20 backdrop-blur-sm flex items-center justify-center z-50 p-4 overflow-y-auto">
          <div className="card w-full max-w-2xl shadow-panel my-8">
            <div className="card-header flex items-center justify-between">
              <h2 className="text-lg font-semibold">{pieza ? 'Editar pieza' : 'Nueva pieza'}</h2>
              <button type="button" onClick={() => setOpen(false)} className="btn-ghost p-2">
                <X className="w-4 h-4" />
              </button>
            </div>
            <form action={action} className="card-body space-y-4">
              <input type="hidden" name="id" value={pieza?.id || ''} />
              <input type="hidden" name="paquete_id" value={paqueteId} />

              {/* DESTINO primero */}
              <div>
                <label className="label">Destino</label>
                <div className="flex gap-3">
                  <label className="flex-1 flex items-center gap-2 p-3 border border-stone-300 rounded-lg cursor-pointer hover:bg-stone-50">
                    <input
                      type="radio"
                      name="destino"
                      value="NEGOCIO"
                      checked={destino === 'NEGOCIO'}
                      onChange={(e) => setDestino(e.target.value)}
                      className="text-accent-600"
                    />
                    <div className="flex-1">
                      <p className="text-sm font-medium">Negocio</p>
                      <p className="text-xs text-stone-500">Va a inventario para vender</p>
                    </div>
                  </label>
                  <label className="flex-1 flex items-center gap-2 p-3 border border-stone-300 rounded-lg cursor-pointer hover:bg-stone-50">
                    <input
                      type="radio"
                      name="destino"
                      value="PERSONAL"
                      checked={destino === 'PERSONAL'}
                      onChange={(e) => setDestino(e.target.value)}
                      className="text-accent-600"
                    />
                    <div className="flex-1">
                      <p className="text-sm font-medium">Personal</p>
                      <p className="text-xs text-stone-500">De un socio, no se vende</p>
                    </div>
                  </label>
                </div>
              </div>

              {destino === 'PERSONAL' && (
                <div>
                  <label className="label">De quién es</label>
                  <select name="socio_id" defaultValue={pieza?.socio_id || ''} className="input" required>
                    <option value="">Elige un socio</option>
                    {socios.map(s => (
                      <option key={s.id} value={s.id}>{s.nombre}</option>
                    ))}
                  </select>
                </div>
              )}

              {/* SELECTOR DE SKU solo si es NEGOCIO */}
              {destino === 'NEGOCIO' && (
                <div className="p-4 bg-accent-50 border border-accent-200 rounded-lg space-y-3">
                  <div className="flex items-center gap-2">
                    <Search className="w-4 h-4 text-accent-600" />
                    <label className="label !mb-0">¿Ya existe el SKU en el catálogo?</label>
                  </div>

                  <div className="flex gap-3">
                    <label className="flex-1 flex items-center gap-2 p-2 border border-stone-300 bg-white rounded cursor-pointer hover:bg-stone-50">
                      <input
                        type="radio"
                        checked={modoSku === 'existente'}
                        onChange={() => setModoSku('existente')}
                        className="text-accent-600"
                      />
                      <span className="text-sm">Sí, seleccionar existente</span>
                    </label>
                    <label className="flex-1 flex items-center gap-2 p-2 border border-stone-300 bg-white rounded cursor-pointer hover:bg-stone-50">
                      <input
                        type="radio"
                        checked={modoSku === 'nuevo'}
                        onChange={() => setModoSku('nuevo')}
                        className="text-accent-600"
                      />
                      <span className="text-sm">No, crear uno nuevo</span>
                    </label>
                  </div>

                  {modoSku === 'existente' && (
                    <div>
                      <select
                        name="sku_id"
                        value={skuSeleccionado}
                        onChange={(e) => setSkuSeleccionado(e.target.value)}
                        className="input"
                      >
                        <option value="">Selecciona un SKU...</option>
                        {skus.map(s => (
                          <option key={s.id} value={s.id}>
                            {s.codigo} — {s.producto} {s.talla} {s.color}
                          </option>
                        ))}
                      </select>
                      {skuSeleccionado && (
                        <p className="text-xs text-accent-700 mt-2 font-medium">
                          ✓ Los campos de marca/tipo/talla/color se llenarán automáticamente
                        </p>
                      )}
                    </div>
                  )}

                  {modoSku === 'nuevo' && (
                    <p className="text-xs text-accent-700">
                      Llena marca, tipo, talla y color abajo. El SKU se asignará después en Inventario.
                    </p>
                  )}
                </div>
              )}

              <div>
                <label className="label">Descripción (como venga en el pedido)</label>
                <input
                  type="text"
                  name="descripcion"
                  defaultValue={pieza?.descripcion}
                  placeholder="Batman Compression Tees Black Medium"
                  className="input"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Cantidad</label>
                  <input
                    type="number"
                    name="cantidad"
                    defaultValue={pieza?.cantidad || 1}
                    min="1"
                    className="input"
                    required
                  />
                </div>
                <div>
                  <label className="label">Costo (USD)</label>
                  <input
                    type="number"
                    name="costo_usd"
                    defaultValue={pieza?.costo_usd}
                    step="0.01"
                    placeholder="0.00"
                    className="input"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">
                    Marca {autoMarca && <span className="text-accent-600 text-xs">(autocompletado)</span>}
                  </label>
                  <select
                    name="marca_id"
                    value={autoMarca || pieza?.marca_id || ''}
                    onChange={(e) => setAutoMarca(e.target.value)}
                    className="input"
                    required
                    disabled={modoSku === 'existente' && skuSeleccionado && autoMarca}
                  >
                    <option value="">Elige una marca</option>
                    {marcas.map(m => (
                      <option key={m.id} value={m.id}>{m.nombre}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="label">
                    Tipo de prenda {autoTipo && <span className="text-accent-600 text-xs">(autocompletado)</span>}
                  </label>
                  <select
                    name="tipo_prenda_id"
                    value={autoTipo || pieza?.tipo_prenda_id || ''}
                    onChange={(e) => setAutoTipo(e.target.value)}
                    className="input"
                    required
                    disabled={modoSku === 'existente' && skuSeleccionado && autoTipo}
                  >
                    <option value="">Elige un tipo</option>
                    {tipos.map(t => (
                      <option key={t.id} value={t.id}>{t.nombre}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Talla y Color - solo para NEGOCIO en modo nuevo */}
              {destino === 'NEGOCIO' && (
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="label">
                      Talla {autoTalla && <span className="text-accent-600 text-xs">(autocompletado)</span>}
                    </label>
                    <input
                      type="text"
                      name="talla"
                      value={autoTalla}
                      onChange={(e) => setAutoTalla(e.target.value)}
                      placeholder="S, M, L, XL..."
                      className="input"
                      disabled={modoSku === 'existente' && skuSeleccionado && autoTalla}
                    />
                  </div>
                  <div>
                    <label className="label">
                      Color {autoColor && <span className="text-accent-600 text-xs">(autocompletado)</span>}
                    </label>
                    <input
                      type="text"
                      name="color"
                      value={autoColor}
                      onChange={(e) => setAutoColor(e.target.value)}
                      placeholder="Black, White..."
                      className="input"
                      disabled={modoSku === 'existente' && skuSeleccionado && autoColor}
                    />
                  </div>
                </div>
              )}

              <div>
                <label className="label">Factor manual (opcional — solo si no aplica la tabla)</label>
                <input
                  type="number"
                  name="factor_manual"
                  defaultValue={pieza?.factor_manual}
                  step="0.1"
                  placeholder="Deja en blanco para usar la tabla"
                  className="input"
                />
                <p className="text-xs text-stone-500 mt-1">
                  Base: Camiseta compresión YoungLA = 1.0. Usa esto solo para piezas que no encajan en la tabla (Oculus, etc).
                </p>
              </div>

              <div>
                <label className="label">Notas (opcional)</label>
                <textarea name="notas" defaultValue={pieza?.notas} rows="2" className="input" />
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
