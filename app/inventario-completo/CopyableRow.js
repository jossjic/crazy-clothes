'use client'

import { useState } from 'react'
import { Check } from 'lucide-react'

export function CopyableRow({ children, rowData }) {
  const [copied, setCopied] = useState(false)

  const handleClick = async () => {
    // Formatear los datos en TSV (tab-separated values) para pegar en Excel/Sheets
    const text = Object.values(rowData)
      .map(v => v === null || v === undefined || v === '' ? '—' : String(v))
      .join('\t')

    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 1500)
    } catch (err) {
      console.error('Error al copiar:', err)
    }
  }

  return (
    <tr
      onClick={handleClick}
      className={`relative cursor-pointer transition-colors ${
        copied ? 'bg-green-50' : 'hover:bg-stone-50'
      }`}
      title="Click para copiar fila"
    >
      {children}
      {copied && (
        <td className="absolute right-2 top-1/2 -translate-y-1/2 pointer-events-none">
          <div className="flex items-center gap-1 px-2 py-1 bg-green-600 text-white text-xs rounded-lg shadow-lg">
            <Check className="w-3 h-3" />
            <span>Copiado</span>
          </div>
        </td>
      )}
    </tr>
  )
}
