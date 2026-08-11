import { useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import AuthLayout from '../components/AuthLayout'

export default function ResetPasswordPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const token = params.get('token') ?? ''

  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [showPw, setShowPw] = useState(false)
  const [showCf, setShowCf] = useState(false)
  const [loading, setLoading] = useState(false)
  const [done, setDone] = useState(false)
  const [error, setError] = useState('')
  const [focusPw, setFocusPw] = useState(false)
  const [focusCf, setFocusCf] = useState(false)

  const textMain = isDark ? '#C8D5EE' : '#0A1545'
  const textMuted = isDark ? '#3A5AB8' : '#4A70CC'
  const textSub = isDark ? '#7B9FE8' : '#2451C8'
  const focusColor = '#2596be'
  const borderIdle = isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.35)'

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (password !== confirm) { setError('Las contraseñas no coinciden.'); return }
    if (password.length < 8) { setError('La contraseña debe tener al menos 8 caracteres.'); return }
    setError('')
    setLoading(true)
    try {
      await api.post('/api/auth/reset-password', { token, newPassword: password })
      setDone(true)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const EyeIcon = ({ show }: { show: boolean }) => show ? (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
      <line x1="1" y1="1" x2="23" y2="23"/>
    </svg>
  ) : (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
      <circle cx="12" cy="12" r="3"/>
    </svg>
  )

  return (
    <AuthLayout
      terminalComment="// nueva contraseña"
      headline={
        <h1 className="font-display leading-[1.05]" style={{ fontSize: 'clamp(2.4rem, 5vw, 3.4rem)', color: '#C8D5EE' }}>
          Nueva<br />
          <span style={{ color: '#2596be', textShadow: '0 0 32px rgba(37,150,190,0.5)' }}>contraseña.</span>
        </h1>
      }
      subheadline="Elige una contraseña segura de al menos 8 caracteres."
    >
      <div className="mb-10">
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: textSub }}>
          // restablecer acceso
        </p>
        <h2 className="font-display" style={{ fontSize: 'clamp(1.6rem, 7vw, 2.25rem)', lineHeight: 1.15, color: textMain }}>
          Restablecer contraseña
        </h2>
      </div>

      {!token ? (
        <div className="hud-panel hud-static px-6 py-8 text-center space-y-3"
          style={{
            background: 'rgba(248,113,113,0.06)',
            '--hud-border': 'rgba(248,113,113,0.35)',
            '--hud-border-hover': 'rgba(248,113,113,0.35)',
          } as React.CSSProperties}>
          <p className="font-display text-xl" style={{ color: '#f87171' }}>Enlace inválido</p>
          <p className="text-[14px]" style={{ color: textMuted }}>Este enlace no es válido. Solicita uno nuevo.</p>
          <Link to="/forgot-password" className="inline-block mt-2 font-mono text-[12px] tracking-wide hover:underline" style={{ color: textMuted }}>
            → Solicitar nuevo enlace
          </Link>
        </div>
      ) : done ? (
        <div className="hud-panel hud-static px-6 py-8 text-center space-y-4"
          style={{
            background: 'rgba(74,222,128,0.06)',
            '--hud-border': 'rgba(74,222,128,0.35)',
            '--hud-border-hover': 'rgba(74,222,128,0.35)',
          } as React.CSSProperties}>
          <div className="w-12 h-12 rounded-full flex items-center justify-center mx-auto" style={{ background: 'rgba(74,222,128,0.12)', border: '1px solid rgba(74,222,128,0.3)' }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4ade80" strokeWidth="2" strokeLinecap="round">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>
          <p className="font-display text-xl" style={{ color: textMain }}>Contraseña actualizada</p>
          <p className="text-[14px]" style={{ color: textMuted }}>Ya puedes iniciar sesión con tu nueva contraseña.</p>
          <button onClick={() => navigate('/login')} className="btn-neon px-8 py-3 rounded-xl text-[14px] font-semibold mt-2">
            Ir al login
          </button>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="space-y-7">
          {/* New password */}
          <div className="space-y-2">
            <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: textSub }}>
              Nueva contraseña
            </label>
            <div className="relative">
              <input
                type={showPw ? 'text' : 'password'}
                required
                value={password}
                onChange={e => setPassword(e.target.value)}
                onFocus={() => setFocusPw(true)}
                onBlur={() => setFocusPw(false)}
                placeholder="mín. 8 caracteres"
                className="input-terminal w-full text-[15px] px-5 py-3.5 pr-11"
                style={{ color: textMain, border: `1px solid ${focusPw ? focusColor : borderIdle}`, borderRadius: '2px', transition: 'border-color 0.2s ease' }}
              />
              <button type="button" onClick={() => setShowPw(s => !s)} tabIndex={-1}
                className="absolute right-3 top-1/2 -translate-y-1/2"
                style={{ color: textMuted, opacity: 0.7 }}>
                <EyeIcon show={showPw} />
              </button>
            </div>
          </div>

          {/* Confirm password */}
          <div className="space-y-2">
            <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: textSub }}>
              Confirmar contraseña
            </label>
            <div className="relative">
              <input
                type={showCf ? 'text' : 'password'}
                required
                value={confirm}
                onChange={e => setConfirm(e.target.value)}
                onFocus={() => setFocusCf(true)}
                onBlur={() => setFocusCf(false)}
                placeholder="repite la contraseña"
                className="input-terminal w-full text-[15px] px-5 py-3.5 pr-11"
                style={{ color: textMain, border: `1px solid ${focusCf ? focusColor : borderIdle}`, borderRadius: '2px', transition: 'border-color 0.2s ease' }}
              />
              <button type="button" onClick={() => setShowCf(s => !s)} tabIndex={-1}
                className="absolute right-3 top-1/2 -translate-y-1/2"
                style={{ color: textMuted, opacity: 0.7 }}>
                <EyeIcon show={showCf} />
              </button>
            </div>
          </div>

          {error && (
            <div className="flex items-start gap-3 px-4 py-3 rounded-xl"
              style={{ background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8', border: '1px solid rgba(26,63,150,0.25)', borderLeft: '3px solid #f87171' }}>
              <span className="font-mono text-xs mt-0.5" style={{ color: '#f87171' }}>ERR</span>
              <p className="text-[14px]" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
            </div>
          )}

          <button type="submit" disabled={loading}
            className="btn-neon w-full py-4 rounded-xl text-[15px] disabled:opacity-50 disabled:cursor-not-allowed">
            {loading ? <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Actualizando</span> : 'Restablecer contraseña'}
          </button>
        </form>
      )}
    </AuthLayout>
  )
}
