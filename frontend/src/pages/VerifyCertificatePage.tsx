import { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Footer from '../components/Footer'

interface VerifyResult {
  valid: boolean
  courseTitle?: string
  username?: string
}

export default function VerifyCertificatePage() {
  const { username, courseSlug, code } = useParams<{ username: string; courseSlug: string; code: string }>()
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const [result, setResult]   = useState<VerifyResult | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!username || !courseSlug || !code) return
    let cancelled = false
    setLoading(true)
    const params = new URLSearchParams({ username, courseSlug, code })
    api.get<VerifyResult>(`/api/certificates/verify?${params.toString()}`)
      .then(data => { if (!cancelled) setResult(data) })
      .catch(() => { if (!cancelled) setResult({ valid: false }) })
      .finally(() => { if (!cancelled) setLoading(false) })
    return () => { cancelled = true }
  }, [username, courseSlug, code])

  const bg        = isDark ? '#060D1F' : '#EEF3FC'
  const cardBg     = isDark ? 'rgba(13,27,70,0.7)' : '#f8faff'
  const cardBorder = isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.12)'
  const textMain   = isDark ? '#C8D5EE' : '#0A1545'
  const textMuted  = isDark ? '#3A5AB8' : '#4A70CC'

  return (
    <div className="min-h-screen flex flex-col" style={{ background: bg }}>
      <Header />

      <main className="flex-1 w-full max-w-xl mx-auto px-4 py-16">
        <div
          className="hud-panel hud-static p-10 text-center"
          style={{
            background: cardBg,
            '--hud-border': result?.valid ? 'rgba(82,173,112,0.45)' : cardBorder,
            '--hud-border-hover': result?.valid ? 'rgba(82,173,112,0.45)' : cardBorder,
          } as React.CSSProperties}
        >
          {loading ? (
            <div className="flex flex-col items-center gap-4 py-8">
              <div className="w-9 h-9 rounded-full border-2 animate-spin"
                style={{ borderColor: '#1A3F96', borderTopColor: 'transparent' }} />
              <p className="font-mono text-[11px] tracking-[0.2em] uppercase" style={{ color: textMuted }}>
                Verificando certificado…
              </p>
            </div>
          ) : result?.valid ? (
            <>
              <div
                className="w-16 h-16 rounded-full mx-auto mb-6 flex items-center justify-center"
                style={{ background: 'rgba(82,173,112,0.12)', border: '1px solid rgba(82,173,112,0.35)' }}
              >
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#52ad70" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
              </div>
              <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-3" style={{ color: '#52ad70' }}>
                Certificado válido
              </p>
              <p className="font-display mb-2" style={{ fontSize: 'clamp(1.3rem,3vw,1.7rem)', color: textMain }}>
                {result.username} completó
              </p>
              <p className="font-display mb-6" style={{ fontSize: 'clamp(1.3rem,3vw,1.7rem)', color: '#2596be' }}>
                "{result.courseTitle}"
              </p>
              <p className="text-[13px] font-light" style={{ color: textMuted }}>
                en RutSeg, plataforma de laboratorios prácticos en ciberseguridad.
              </p>
            </>
          ) : (
            <>
              <div
                className="w-16 h-16 rounded-full mx-auto mb-6 flex items-center justify-center"
                style={{ background: 'rgba(248,113,113,0.10)', border: '1px solid rgba(248,113,113,0.30)' }}
              >
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#f87171" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
                </svg>
              </div>
              <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-3" style={{ color: '#f87171' }}>
                Certificado no válido
              </p>
              <p className="text-[15px] font-light" style={{ color: textMain }}>
                No se pudo verificar este certificado.
              </p>
            </>
          )}
        </div>

        <p className="text-center mt-6">
          <Link
            to="/"
            className="font-mono text-[11px] tracking-[0.18em] uppercase transition-colors"
            style={{ color: textMuted }}
          >
            ← Volver a RutSeg
          </Link>
        </p>
      </main>

      <Footer />
    </div>
  )
}
