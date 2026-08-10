import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import Header from '../components/Header'
import Footer from '../components/Footer'

export default function NotFoundPage() {
  const { theme } = useTheme()
  const { token } = useAuth()
  const isDark = theme === 'dark'

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <Header />

      <div
        className="relative overflow-hidden min-h-[calc(100vh-72px)] flex items-center"
        style={{
          background: isDark
            ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 80%)'
            : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 80%)',
        }}
      >
        {/* Neon grid (dark only) */}
        {isDark && (
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              backgroundImage: `
                linear-gradient(rgba(26, 63, 150, 0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(26, 63, 150, 0.07) 1px, transparent 1px)
              `,
              backgroundSize: '50px 50px',
              maskImage: 'radial-gradient(ellipse at center, black 40%, transparent 80%)',
              WebkitMaskImage: 'radial-gradient(ellipse at center, black 40%, transparent 80%)',
            }}
          />
        )}

        <div className="relative max-w-7xl mx-auto px-6 lg:px-10 py-20 w-full">
          <div className="max-w-xl">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-8 animate-fade-up-1"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // error · ruta no encontrada
            </p>

            <p
              className="num-display animate-fade-up-2"
              style={{
                fontSize: 'clamp(6.5rem, 18vw, 11rem)',
                lineHeight: 0.9,
                color: '#1A3F96',
                letterSpacing: '-0.02em',
                textShadow: isDark ? '0 0 80px rgba(26,63,150,0.50)' : 'none',
              }}
            >
              404
            </p>

            <h1
              className="font-display mt-7 mb-4 animate-fade-up-3"
              style={{
                fontSize: 'clamp(1.6rem, 3.5vw, 2.4rem)',
                lineHeight: 1.1,
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              Página no encontrada.
            </h1>

            <p
              className="text-base font-light mb-10 animate-fade-up-4"
              style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65, maxWidth: '38ch' }}
            >
              La ruta que intentas acceder no existe o fue movida. Revisa la URL o regresa al inicio.
            </p>

            <div className="flex flex-wrap gap-4 animate-fade-up-5">
              <Link to="/" className="btn-neon px-6 py-3 rounded-xl text-[14px] font-semibold">
                ← Volver al inicio
              </Link>
              {token && (
                <Link
                  to="/dashboard"
                  className="flex items-center gap-2 px-6 py-3 rounded-xl text-[14px] font-medium transition-all"
                  style={{
                    color: isDark ? '#7B9FE8' : '#1A3F96',
                    background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)',
                    border: '1px solid rgba(26,63,150,0.20)',
                  }}
                  onMouseEnter={e => {
                    ;(e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.15)'
                  }}
                  onMouseLeave={e => {
                    ;(e.currentTarget as HTMLElement).style.background = isDark
                      ? 'rgba(26,63,150,0.08)'
                      : 'rgba(26,63,150,0.06)'
                  }}
                >
                  Ir al dashboard →
                </Link>
              )}
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  )
}
