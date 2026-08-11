import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import AuthLayout from '../components/AuthLayout'
import SocialAuthButtons from '../components/SocialAuthButtons'

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
            border: `1px solid ${focused ? '#2596be' : isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.35)'}`,
            borderRadius: '2px',
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

export default function LoginPage() {
  const { login } = useAuth()
  const { theme } = useTheme()
  const navigate = useNavigate()
  const [form, setForm] = useState({ email: '', password: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const isDark = theme === 'dark'

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post<{ token: string; user: any }>('/api/auth/login', form)
      login(res.token, res.user)
      navigate(res.user.role === 'admin' ? '/admin' : '/dashboard')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthLayout
      terminalComment="// sesión iniciada"
      headline={
        <h1
          className="font-display leading-[1.05]"
          style={{ fontSize: 'clamp(2.8rem, 5vw, 3.8rem)', color: '#C8D5EE' }}
        >
          Bienvenido<br />
          de <span style={{ color: '#2596be', textShadow: '0 0 32px rgba(37,150,190,0.5)' }}>vuelta.</span>
        </h1>
      }
      subheadline="Retoma tus laboratorios, sube en el ranking y demuestra tus habilidades."
    >
      <div className="mb-10">
        <p
          className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4"
          style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
        >
          // acceso a la plataforma
        </p>
        <h2
          className="font-display"
          style={{ fontSize: 'clamp(1.7rem, 7vw, 2.25rem)', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}
        >
          Iniciar sesión
        </h2>
        <p className="text-[15px] mt-3" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
          ¿Primera vez?{' '}
          <Link
            to="/register"
            className="font-semibold transition-colors hover:underline"
            style={{ color: isDark ? '#F5C500' : '#1A3F96' }}
          >
            Crea tu cuenta →
          </Link>
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-8">
        <InputField
          label="Email" type="email"
          value={form.email}
          onChange={v => setForm(f => ({ ...f, email: v }))}
          placeholder="operador@example.com"
          isDark={isDark}
        />
        <div className="space-y-1">
          <InputField
            label="Contraseña" type="password"
            value={form.password}
            onChange={v => setForm(f => ({ ...f, password: v }))}
            placeholder="••••••••••"
            isDark={isDark}
          />
          <div className="flex justify-end">
            <Link
              to="/forgot-password"
              className="font-mono text-[10px] tracking-[0.12em] transition-colors hover:underline"
              style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
            >
              ¿Olvidaste tu contraseña?
            </Link>
          </div>
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
          disabled={loading}
          className="btn-neon w-full py-4 rounded-xl text-[15px] disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Autenticando</span>
          ) : (
            'Iniciar sesión'
          )}
        </button>
      </form>

      <SocialAuthButtons />
    </AuthLayout>
  )
}
