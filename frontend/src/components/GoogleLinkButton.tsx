import { useEffect, useRef, useState } from 'react'
import { GOOGLE_CLIENT_ID, loadGoogleScript } from '../lib/googleIdentity'
import { api } from '../lib/api'

/** Botón "Conectar con Google" para vincular una identidad de Google a una
 * cuenta ya autenticada (a diferencia de SocialAuthButtons, que inicia
 * sesión/registra) — postea a /api/users/me/link-google en vez de
 * /api/auth/google. */
export default function GoogleLinkButton<T>({ isDark, onLinked }: { isDark: boolean; onLinked: (profile: T) => void }) {
  const buttonRef = useRef<HTMLDivElement>(null)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) return
    let cancelled = false

    loadGoogleScript()
      .then(() => {
        if (cancelled) return
        const google = (window as any).google
        google.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
          callback: async (response: { credential: string }) => {
            setError('')
            setLoading(true)
            try {
              const profile = await api.post<T>('/api/users/me/link-google', { idToken: response.credential })
              onLinked(profile)
            } catch (err: any) {
              setError(err.message ?? 'No se pudo vincular la cuenta de Google.')
            } finally {
              setLoading(false)
            }
          },
        })
        if (buttonRef.current) {
          buttonRef.current.innerHTML = ''
          const measured = Math.floor(buttonRef.current.getBoundingClientRect().width)
          const width = measured > 0 ? Math.min(320, measured) : 260
          google.accounts.id.renderButton(buttonRef.current, {
            theme: isDark ? 'filled_black' : 'outline',
            size: 'large',
            width,
            text: 'signin_with',
            locale: 'es',
          })
        }
      })
      .catch(() => setError('No se pudo cargar el botón de Google.'))

    return () => { cancelled = true }
  }, [isDark])

  if (!GOOGLE_CLIENT_ID) return null

  return (
    <div>
      <div ref={buttonRef} className="flex justify-center" style={{ opacity: loading ? 0.6 : 1, pointerEvents: loading ? 'none' : 'auto' }} />
      {error && (
        <p className="text-[12px] mt-2 text-center" style={{ color: '#ef4444' }}>{error}</p>
      )}
    </div>
  )
}
