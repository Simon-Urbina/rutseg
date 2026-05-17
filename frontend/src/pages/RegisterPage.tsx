import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import useSound from 'use-sound'
import popDown from '../sounds/pop-down.wav'
import popUpOn from '../sounds/pop-up-on.wav'
import popUpOff from '../sounds/pop-up-off.wav'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import AuthLayout from '../components/AuthLayout'

function InputField({
  label, type, value, onChange, placeholder, isDark,
}: {
  label: string; type: string; value: string;
  onChange: (v: string) => void; placeholder: string; isDark: boolean
}) {
  const [focused, setFocused] = useState(false)
  const [show, setShow] = useState(false)
  const isPassword = type === 'password'
  return (
    <div className="space-y-2">
      <label
        className="block font-mono text-[10px] tracking-[0.18em] uppercase"
        style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
      >
        {label}
      </label>
      <div className="relative">
        <input
          type={isPassword ? (show ? 'text' : 'password') : type}
          required
          value={value}
          onChange={e => onChange(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder={placeholder}
          className="input-terminal w-full text-[15px] px-5 py-3.5"
          style={{
            color: isDark ? '#C8D5EE' : '#0A1545',
            border: `1px solid ${focused ? '#F5C500' : isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.35)'}`,
            borderRadius: '10px',
            transition: 'border-color 0.2s ease',
            paddingRight: isPassword ? '2.75rem' : undefined,
          }}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShow(s => !s)}
            className="absolute right-3 top-1/2 -translate-y-1/2 transition-opacity"
            style={{ color: isDark ? '#3A5AB8' : '#4A70CC', opacity: 0.7 }}
            onMouseEnter={e => (e.currentTarget.style.opacity = '1')}
            onMouseLeave={e => (e.currentTarget.style.opacity = '0.7')}
            tabIndex={-1}
          >
            {show ? (
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
            )}
          </button>
        )}
      </div>
    </div>
  )
}

export default function RegisterPage() {
  const { login } = useAuth()
  const { theme } = useTheme()
  const navigate = useNavigate()
  const [form, setForm] = useState({ username: '', email: '', password: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const isDark = theme === 'dark'

  // Step 2: email verification
  const [step, setStep] = useState<'register' | 'verify'>('register')
  const [pendingEmail, setPendingEmail] = useState('')
  const [code, setCode] = useState('')
  const [resendCooldown, setResendCooldown] = useState(0)
  const [privacyAccepted, setPrivacyAccepted] = useState(false)
  // Ref: https://www.joshwcomeau.com/react/announcing-use-sound-react-hook/
  const [playActive] = useSound(popDown, { volume: 0.25 })
  const [playOn] = useSound(popUpOn, { volume: 0.25 })
  const [playOff] = useSound(popUpOff, { volume: 0.25 })

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post<{ message: string; email: string }>('/api/auth/register', {
        ...form,
        privacyPolicyVersion: '1.0',
      })
      setPendingEmail(res.email)
      setStep('verify')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post<{ token: string; user: any }>('/api/auth/verify-email', {
        email: pendingEmail,
        code: code.trim(),
      })
      login(res.token, res.user)
      navigate('/dashboard')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleResend = async () => {
    if (resendCooldown > 0) return
    try {
      await api.post('/api/auth/resend-verification', { email: pendingEmail })
      setResendCooldown(60)
      const interval = setInterval(() => {
        setResendCooldown(prev => {
          if (prev <= 1) { clearInterval(interval); return 0 }
          return prev - 1
        })
      }, 1000)
    } catch {
      // silently fail — backend always returns success
    }
  }

  const [codeFocused, setCodeFocused] = useState(false)

  if (step === 'verify') {
    return (
      <AuthLayout
        terminalComment="// verificación de identidad"
        headline={
          <h1
            className="font-display leading-[1.05]"
            style={{ fontSize: 'clamp(2.8rem, 5vw, 3.8rem)', color: '#C8D5EE' }}
          >
            Confirma<br />
            tu<br />
            <span style={{ color: '#F5C500', textShadow: '0 0 32px rgba(245,197,0,0.45)' }}>identidad.</span>
          </h1>
        }
        subheadline="Revisa tu correo y pega el código de verificación."
      >
        <div className="mb-10">
          <p
            className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4"
            style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
          >
            // verificar correo
          </p>
          <h2
            className="font-display"
            style={{ fontSize: '2.25rem', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}
          >
            Código enviado
          </h2>
          <p className="text-[15px] mt-3" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
            Enviamos un código de 6 dígitos a{' '}
            <span className="font-semibold" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
              {pendingEmail}
            </span>
          </p>
        </div>

        <form onSubmit={handleVerify} className="space-y-7">
          <div className="space-y-2">
            <label
              className="block font-mono text-[10px] tracking-[0.18em] uppercase"
              style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
            >
              Código de verificación
            </label>
            <input
              type="text"
              inputMode="numeric"
              maxLength={6}
              required
              value={code}
              onChange={e => setCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
              onFocus={() => setCodeFocused(true)}
              onBlur={() => setCodeFocused(false)}
              placeholder="000000"
              className="input-terminal w-full text-center text-[28px] tracking-[0.5em] px-5 py-4"
              style={{
                color: isDark ? '#C8D5EE' : '#0A1545',
                border: `1px solid ${codeFocused ? '#F5C500' : isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.35)'}`,
                borderRadius: '10px',
                transition: 'border-color 0.2s ease',
                fontFamily: 'monospace',
              }}
            />
          </div>

          {error && (
            <div
              className="flex items-start gap-3 px-4 py-3 rounded-xl"
              style={{
                background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
                border: '1px solid rgba(26,63,150,0.25)',
                borderLeft: '3px solid #1A3F96',
              }}
            >
              <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
              <p className="text-[14px]" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
            </div>
          )}

          <button
            type="submit"
            disabled={loading || code.length < 6}
            className="btn-gold w-full py-4 rounded-xl text-[15px] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? (
              <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Verificando</span>
            ) : (
              'Verificar y crear cuenta'
            )}
          </button>

          <div className="text-center space-y-2">
            <p className="text-[14px]" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
              ¿No recibiste el correo?{' '}
              <button
                type="button"
                onClick={handleResend}
                disabled={resendCooldown > 0}
                className="font-semibold transition-colors hover:underline disabled:cursor-not-allowed disabled:no-underline"
                style={{ color: resendCooldown > 0 ? (isDark ? '#3A5AB8' : '#9CA3AF') : (isDark ? '#F5C500' : '#1A3F96') }}
              >
                {resendCooldown > 0 ? `Reenviar en ${resendCooldown}s` : 'Reenviar código'}
              </button>
            </p>
            <p className="text-[13px]" style={{ color: isDark ? '#3A5AB8' : '#9CA3AF' }}>
              El código expira en 15 minutos.
            </p>
          </div>
        </form>
      </AuthLayout>
    )
  }

  return (
    <AuthLayout
      terminalComment="// nuevo operador detectado"
      headline={
        <h1
          className="font-display leading-[1.05]"
          style={{ fontSize: 'clamp(2.8rem, 5vw, 3.8rem)', color: '#C8D5EE' }}
        >
          Crea tu<br />
          <span style={{ color: '#F5C500', textShadow: '0 0 32px rgba(245,197,0,0.45)' }}>identidad</span><br />
          digital.
        </h1>
      }
      subheadline="Únete a la plataforma. Completa labs, demuestra skills y compite en el ranking."
    >
      <div className="mb-10">
        <p
          className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4"
          style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
        >
          // crear cuenta
        </p>
        <h2
          className="font-display"
          style={{ fontSize: '2.25rem', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}
        >
          Únete al equipo
        </h2>
        <p className="text-[15px] mt-3" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
          ¿Ya tienes cuenta?{' '}
          <Link
            to="/login"
            className="font-semibold transition-colors hover:underline"
            style={{ color: isDark ? '#F5C500' : '#1A3F96' }}
          >
            Inicia sesión →
          </Link>
        </p>
      </div>

      <form onSubmit={handleRegister} className="space-y-7">
        <InputField
          label="Username" type="text"
          value={form.username}
          onChange={v => setForm(f => ({ ...f, username: v }))}
          placeholder="h4ck3r_alias"
          isDark={isDark}
        />
        <InputField
          label="Email" type="email"
          value={form.email}
          onChange={v => setForm(f => ({ ...f, email: v }))}
          placeholder="operador@example.com"
          isDark={isDark}
        />
        <InputField
          label="Contraseña" type="password"
          value={form.password}
          onChange={v => setForm(f => ({ ...f, password: v }))}
          placeholder="mín. 8 caracteres"
          isDark={isDark}
        />

        {/* Consentimiento — Ley 1581 de 2012 */}
        <div className="flex items-start gap-3">
          <button
            type="button"
            role="checkbox"
            aria-checked={privacyAccepted}
            onClick={() => {
              playActive()
              if (!privacyAccepted) playOn()
              else playOff()
              setPrivacyAccepted(v => !v)
            }}
            className="mt-0.5 w-5 h-5 shrink-0 rounded flex items-center justify-center transition-all"
            style={{
              background: privacyAccepted ? '#1A3F96' : 'transparent',
              border: `2px solid ${privacyAccepted ? '#1A3F96' : isDark ? 'rgba(26,63,150,0.45)' : 'rgba(26,63,150,0.40)'}`,
            }}
          >
            {privacyAccepted && (
              <svg width="10" height="10" viewBox="0 0 12 12" fill="none">
                <path d="M2 6L5 9L10 3" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            )}
          </button>
          <p className="text-[13px] leading-relaxed" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
            He leído y acepto la{' '}
            <Link
              to="/privacy-policy"
              target="_blank"
              className="font-semibold transition-colors hover:underline"
              style={{ color: isDark ? '#F5C500' : '#1A3F96' }}
            >
              Política de Privacidad
            </Link>{' '}
            y autorizo el tratamiento de mis datos personales conforme a la Ley 1581 de 2012 de Colombia.
          </p>
        </div>

        {error && (
          <div
            className="flex items-start gap-3 px-4 py-3 rounded-xl"
            style={{
              background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
              border: '1px solid rgba(26,63,150,0.25)',
              borderLeft: '3px solid #1A3F96',
            }}
          >
            <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
            <p className="text-[14px]" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
          </div>
        )}

        <button
          type="submit"
          disabled={loading || !privacyAccepted}
          className="btn-gold w-full py-4 rounded-xl text-[15px] disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Enviando código</span>
          ) : (
            'Crear cuenta gratis'
          )}
        </button>
      </form>
    </AuthLayout>
  )
}
