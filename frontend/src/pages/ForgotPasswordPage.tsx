import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import AuthLayout from '../components/AuthLayout'

export default function ForgotPasswordPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [sent, setSent] = useState(false)
  const [error, setError] = useState('')
  const [focused, setFocused] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      await api.post('/api/auth/forgot-password', { email })
      setSent(true)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const textMain = isDark ? '#C8D5EE' : '#0A1545'
  const textMuted = isDark ? '#3A5AB8' : '#4A70CC'
  const textSub = isDark ? '#7B9FE8' : '#2451C8'

  return (
    <AuthLayout
      terminalComment="// recuperación de acceso"
      headline={
        <h1 className="font-display leading-[1.05]" style={{ fontSize: 'clamp(2.4rem, 5vw, 3.4rem)', color: '#C8D5EE' }}>
          Recupera<br />
          tu <span style={{ color: '#2596be', textShadow: '0 0 32px rgba(37,150,190,0.5)' }}>acceso.</span>
        </h1>
      }
      subheadline="Ingresa tu correo y te enviaremos las instrucciones para restablecer tu contraseña."
    >
      <div className="mb-10">
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: textSub }}>
          // restablecer contraseña
        </p>
        <h2 className="font-display" style={{ fontSize: '2.25rem', lineHeight: 1.1, color: textMain }}>
          ¿Olvidaste tu contraseña?
        </h2>
        <p className="text-[15px] mt-3" style={{ color: textSub }}>
          ¿Ya la recordaste?{' '}
          <Link to="/login" className="font-semibold hover:underline transition-colors" style={{ color: isDark ? '#F5C500' : '#1A3F96' }}>
            Volver al login →
          </Link>
        </p>
      </div>

      {sent ? (
        <div
          className="hud-panel hud-static px-6 py-8 text-center space-y-4"
          style={{
            background: isDark ? 'rgba(37,150,190,0.08)' : 'rgba(37,150,190,0.05)',
            '--hud-border': 'rgba(37,150,190,0.35)',
            '--hud-border-hover': 'rgba(37,150,190,0.35)',
          } as React.CSSProperties}
        >
          <div className="w-12 h-12 rounded-full flex items-center justify-center mx-auto" style={{ background: 'rgba(37,150,190,0.12)', border: '1px solid rgba(37,150,190,0.3)' }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#2596be" strokeWidth="2" strokeLinecap="round">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>
          <p className="font-display text-xl" style={{ color: textMain }}>Instrucciones enviadas</p>
          <p className="text-[14px]" style={{ color: textMuted }}>
            Si <span style={{ color: '#2596be' }}>{email}</span> está registrado, recibirás un enlace para restablecer tu contraseña.
          </p>
          <Link
            to="/login"
            className="inline-block mt-2 font-mono text-[12px] tracking-wide hover:underline"
            style={{ color: textMuted }}
          >
            ← Volver al login
          </Link>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-8">
          <div className="space-y-2">
            <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: textSub }}>
              Correo electrónico
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={e => setEmail(e.target.value)}
              onFocus={() => setFocused(true)}
              onBlur={() => setFocused(false)}
              placeholder="operador@example.com"
              className="input-terminal w-full text-[15px] px-5 py-3.5"
              style={{
                color: textMain,
                border: `1px solid ${focused ? '#2596be' : isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.35)'}`,
                borderRadius: '2px',
                transition: 'border-color 0.2s ease',
              }}
            />
          </div>

          {error && (
            <div className="flex items-start gap-3 px-4 py-3 rounded-xl"
              style={{ background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8', border: '1px solid rgba(26,63,150,0.25)', borderLeft: '3px solid #1A3F96' }}>
              <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
              <p className="text-[14px]" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="btn-neon w-full py-4 rounded-xl text-[15px] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Enviando</span> : 'Enviar instrucciones'}
          </button>
        </form>
      )}
    </AuthLayout>
  )
}
