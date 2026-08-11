import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID as string | undefined

interface AuthResponse {
  token: string
  user: { id: string; username: string; email: string; role: 'user' | 'admin' }
}

function loadGoogleScript(): Promise<void> {
  return new Promise((resolve, reject) => {
    if ((window as any).google?.accounts?.id) return resolve()
    const existing = document.getElementById('google-identity-script')
    if (existing) {
      existing.addEventListener('load', () => resolve())
      return
    }
    const script = document.createElement('script')
    script.id = 'google-identity-script'
    script.src = 'https://accounts.google.com/gsi/client'
    script.async = true
    script.defer = true
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('No se pudo cargar Google Identity Services.'))
    document.head.appendChild(script)
  })
}

/** Botón de "Continuar con Google" — sirve tanto para iniciar sesión como para crear cuenta
 * la primera vez (find-or-create en el backend). `disabled` se usa en Register para exigir
 * el checkbox de privacidad antes de habilitarlo.
 *
 * Nota: Microsoft se quitó temporalmente (registro de la app en Azure sin terminar) — el
 * backend ya soporta el provider 'microsoft' (ver oauthProviders.ts / user_oauth_accounts),
 * solo falta reintroducir el botón aquí cuando esté lista la app de Azure. */
export default function SocialAuthButtons({ disabled }: { disabled?: boolean }) {
  const { login } = useAuth()
  const { theme } = useTheme()
  const navigate = useNavigate()
  const isDark = theme === 'dark'
  const googleButtonRef = useRef<HTMLDivElement>(null)
  const [error, setError] = useState('')

  const finishAuth = (res: AuthResponse) => {
    login(res.token, res.user)
    navigate(res.user.role === 'admin' ? '/admin' : '/dashboard')
  }

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID || disabled) return
    let cancelled = false

    loadGoogleScript()
      .then(() => {
        if (cancelled) return
        const google = (window as any).google
        google.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
          callback: async (response: { credential: string }) => {
            setError('')
            try {
              const res = await api.post<AuthResponse>('/api/auth/google', {
                idToken: response.credential,
                privacyPolicyVersion: '1.0',
              })
              finishAuth(res)
            } catch (err: any) {
              setError(err.message ?? 'No se pudo iniciar sesión con Google.')
            }
          },
        })
        if (googleButtonRef.current) {
          googleButtonRef.current.innerHTML = ''
          // Google no soporta ancho porcentual — se mide el contenedor real para que
          // el botón nunca se desborde en tarjetas angostas (teléfonos pequeños).
          const measured = Math.floor(googleButtonRef.current.getBoundingClientRect().width)
          const width = measured > 0 ? Math.min(320, measured) : 280
          google.accounts.id.renderButton(googleButtonRef.current, {
            theme: isDark ? 'filled_black' : 'outline',
            size: 'large',
            width,
            text: 'continue_with',
            locale: 'es',
          })
        }
      })
      .catch(() => setError('No se pudo cargar el botón de Google.'))

    return () => { cancelled = true }
  }, [isDark, disabled])

  if (!GOOGLE_CLIENT_ID) return null

  const lineColor = isDark ? 'rgba(26,63,150,0.3)' : 'rgba(26,63,150,0.2)'
  const labelColor = isDark ? '#3A5AB8' : '#4A70CC'

  return (
    <div>
      <div className="flex items-center gap-3 my-6">
        <div className="flex-1 h-px" style={{ background: lineColor }} />
        <span className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: labelColor }}>
          o continúa con
        </span>
        <div className="flex-1 h-px" style={{ background: lineColor }} />
      </div>

      <div className="flex flex-col gap-3" style={{ opacity: disabled ? 0.5 : 1, pointerEvents: disabled ? 'none' : 'auto' }}>
        <div ref={googleButtonRef} className="flex justify-center" />
      </div>

      <p className="text-[12px] mt-3 text-center leading-relaxed" style={{ color: labelColor }}>
        Al continuar, aceptas la Política de Privacidad de RutSeg.
      </p>

      {error && (
        <p className="text-[13px] mt-2 text-center" style={{ color: '#ef4444' }}>{error}</p>
      )}
    </div>
  )
}
