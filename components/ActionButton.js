'use client'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'

export default function ActionButton({ action, variant = 'secondary', confirm, children, size = 'md' }) {
  const [state, formAction] = useActionState(action, {})

  const handleSubmit = (e) => {
    if (confirm && !window.confirm(confirm)) {
      e.preventDefault()
    }
  }

  const btnClass = variant === 'danger' ? 'btn-danger' : 'btn-secondary'
  const sizeClass = size === 'sm' ? 'text-xs px-3 py-1.5' : ''

  return (
    <form action={formAction} onSubmit={handleSubmit}>
      <SubmitButton className={`${btnClass} ${sizeClass}`}>
        {children}
      </SubmitButton>
      {state?.error && (
        <p className="text-xs text-red-600 mt-1">{state.error}</p>
      )}
    </form>
  )
}

function SubmitButton({ children, className }) {
  const { pending } = useFormStatus()
  return (
    <button type="submit" disabled={pending} className={className}>
      {pending ? '...' : children}
    </button>
  )
}
