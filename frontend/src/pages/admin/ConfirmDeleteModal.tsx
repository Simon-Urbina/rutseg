import { useState } from 'react'
import { useTheme } from '../../context/ThemeContext'

interface Props {
  open: boolean
  title: string
  warningDetail?: string
  requireTypedSlug?: string
  onCancel: () => void
  onConfirm: () => Promise<void>
}

export default function ConfirmDeleteModal({ open, title, warningDetail, requireTypedSlug, onCancel, onConfirm }: Props) {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const [typed, setTyped] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  if (!open) return null

  const canConfirm = !requireTypedSlug || typed.trim() === requireTypedSlug

  const handleConfirm = async () => {
    setLoading(true)
    setError('')
    try {
      await onConfirm()
      setTyped('')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-6"
      style={{ background: 'rgba(6,13,31,0.7)' }}
      onClick={onCancel}
    >
      <div
        className="hud-panel hud-static w-full max-w-md p-7"
        style={{
          background: isDark ? '#0D1630' : '#ffffff',
          '--hud-border': 'rgba(198,91,91,0.35)',
          '--hud-border-hover': 'rgba(198,91,91,0.35)',
        } as React.CSSProperties}
        onClick={e => e.stopPropagation()}
      >
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-3" style={{ color: '#1A3F96' }}>
          // acción irreversible
        </p>
        <h3 className="font-display mb-3" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Borrar {title}
        </h3>
        {warningDetail && (
          <p className="text-[14px] mb-4" style={{ color: isDark ? '#7B9FE8' : '#2451C8', lineHeight: 1.6 }}>
            {warningDetail}
          </p>
        )}
        {requireTypedSlug && (
          <div className="mb-4">
            <label className="block font-mono text-[10px] tracking-[0.18em] uppercase mb-2" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
              Escribe «{requireTypedSlug}» para confirmar
            </label>
            <input
              type="text"
              value={typed}
              onChange={e => setTyped(e.target.value)}
              className="tech-input w-full px-4 py-2.5 text-[14px]"
              style={{
                background: 'transparent',
                color: isDark ? '#C8D5EE' : '#0A1545',
                '--tech-input-border': 'rgba(198,91,91,0.35)',
                '--tech-input-focus': '#c65b5b',
                '--tech-input-accent': '#c65b5b',
                '--tech-input-glow': 'rgba(198,91,91,0.15)',
              } as React.CSSProperties}
            />
          </div>
        )}
        {error && <p className="text-[13px] mb-4" style={{ color: '#c65b5b' }}>{error}</p>}
        <div className="flex gap-3 justify-end">
          <button onClick={onCancel} className="btn-ghost-light px-5 py-2.5 rounded-xl text-[14px]">
            Cancelar
          </button>
          <button
            onClick={handleConfirm}
            disabled={!canConfirm || loading}
            className="px-5 py-2.5 rounded-xl text-[14px] font-semibold text-white disabled:opacity-40 disabled:cursor-not-allowed"
            style={{ background: '#8a2020' }}
          >
            {loading ? 'Borrando…' : 'Borrar definitivamente'}
          </button>
        </div>
      </div>
    </div>
  )
}
