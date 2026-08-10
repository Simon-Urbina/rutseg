import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Ranking from '../components/Ranking'
import Footer from '../components/Footer'

const FEATURES = [
  {
    title: 'Aprende practicando',
    body: 'Laboratorios interactivos con escenarios reales. Sin teoría plana, sin diapositivas: solo terminales y problemas para resolver.',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5"/>
        <line x1="12" y1="19" x2="20" y2="19"/>
      </svg>
    ),
    accent: '#1A3F96',
  },
  {
    title: 'Compite en el ranking',
    body: 'Cada lab completado suma puntos. Escala posiciones, demuestra tu nivel y mide tu progreso contra otros operadores.',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/>
        <path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/>
        <path d="M4 22h16"/>
        <path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/>
        <path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/>
        <path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/>
      </svg>
    ),
    accent: '#F5C500',
  },
  {
    title: 'Cero relleno',
    body: 'Aprendizaje hands-on desde el primer minuto. Cada actividad existe para enseñarte algo concreto que puedas usar el día siguiente.',
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
      </svg>
    ),
    accent: '#2596be',
  },
]

export default function LandingPage() {
  const { theme } = useTheme()
  const { token } = useAuth()
  const isDark = theme === 'dark'

  const [stats, setStats] = useState<{ courseCount: number; labCount: number; totalPoints: number; userCount: number } | null>(null)
  useEffect(() => {
    api.get<{ courseCount: number; labCount: number; totalPoints: number; userCount: number }>('/api/stats')
      .then(setStats).catch(() => {})
  }, [])

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <Header />

      {/* ─── HERO ─── */}
      <section
        className="relative overflow-hidden"
        style={{
          background: isDark
            ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 80%)'
            : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 80%)',
        }}
      >
        {/* Neon grid */}
        {isDark && (
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              backgroundImage: `
                linear-gradient(rgba(26, 63, 150, 0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(26, 63, 150, 0.07) 1px, transparent 1px)
              `,
              backgroundSize: '50px 50px',
              maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 80%)',
              WebkitMaskImage: 'radial-gradient(ellipse at center, black 30%, transparent 80%)',
            }}
          />
        )}

        <div className="relative max-w-7xl mx-auto px-6 lg:px-10 pt-20 pb-28 lg:pt-28 lg:pb-36">
          <div className="max-w-4xl">
            <h1
              className="font-display mb-8 animate-fade-up-2"
              style={{
                fontSize: 'clamp(2.6rem, 6.5vw, 5rem)',
                lineHeight: 1.05,
                letterSpacing: '-0.015em',
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              Tu ruta segura{' '}
              <span
                key={isDark ? 'dark' : 'light'}
                style={{
                  display: 'inline-block',
                  backgroundImage: isDark
                    ? 'linear-gradient(135deg, #4A9FCC 0%, #1A3F96 55%, #7B9FE8 100%)'
                    : 'linear-gradient(135deg, #1A3F96 0%, #2596be 100%)',
                  WebkitBackgroundClip: 'text',
                  WebkitTextFillColor: 'transparent',
                  backgroundClip: 'text',
                }}
              >
                hacia el hacking real
              </span>
              .
            </h1>
            <p
              className="text-lg lg:text-xl font-light max-w-2xl mb-12 animate-fade-up-3"
              style={{ color: isDark ? '#7B9FE8' : '#2451C8', lineHeight: 1.6 }}
            >
              RutSeg es tu plataforma de laboratorios prácticos en ciberseguridad.
              Aprende con ejercicios reales, a tu ritmo, sin diapositivas y sin atajos.
            </p>

            <div className="flex flex-wrap items-center gap-4 animate-fade-up-4">
              {token ? (
                <Link
                  to="/dashboard"
                  className="btn-neon px-7 py-4 rounded-xl text-[15px] font-semibold"
                >
                  Ir al dashboard →
                </Link>
              ) : (
                <>
                  <Link
                    to="/register"
                    className="btn-neon px-7 py-4 rounded-xl text-[15px] font-semibold"
                  >
                    Empezar gratis →
                  </Link>
                  <Link
                    to="/login"
                    className="nav-link text-[15px] font-medium px-2 py-1"
                    style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
                  >
                    Ya tengo cuenta
                  </Link>
                </>
              )}
            </div>

            {/* Stats */}
            <div className="flex flex-wrap gap-12 mt-20 animate-fade-up-5">
              {[
                { value: stats ? String(stats.courseCount) : '—', label: 'Cursos' },
                { value: stats ? String(stats.labCount) : '—', label: 'Laboratorios' },
                { value: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', label: 'Puntos disponibles' },
                { value: stats ? String(stats.userCount) : '—', label: 'Usuarios' },
              ].map(({ value, label }) => (
                <div key={label}>
                  <p className="num-display leading-none" style={{ fontSize: '2.75rem', color: '#F5C500' }}>
                    {value}
                  </p>
                  <p className="font-mono text-[10px] tracking-[0.22em] uppercase mt-2" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                    {label}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ─── FEATURES ─── */}
      <section
        className="border-t"
        style={{ borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)' }}
      >
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-20 lg:py-28">
          <div className="max-w-3xl mb-16">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-4"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // ¿qué hace RutSeg diferente?
            </p>
            <h2
              className="font-display"
              style={{
                fontSize: 'clamp(1.9rem, 3.5vw, 2.75rem)',
                lineHeight: 1.15,
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              Una plataforma pensada para aprender{' '}
              <span style={{ color: '#1A3F96' }}>haciendo</span>
              , no solo leyendo.
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {FEATURES.map(({ title, body, icon, accent }) => (
              <div
                key={title}
                className="hud-panel p-8 cursor-default"
                style={{
                  background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                  '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                  '--hud-border-hover': `${accent}99`,
                } as React.CSSProperties}
              >
                <div
                  className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6"
                  style={{
                    background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.03)',
                    border: `1px solid ${accent}30`,
                    color: accent,
                  }}
                >
                  {icon}
                </div>
                <h3
                  className="font-display mb-3"
                  style={{ fontSize: '1.5rem', color: isDark ? '#EEF3FC' : '#0A1545' }}
                >
                  {title}
                </h3>
                <p
                  className="text-[15px] font-light"
                  style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
                >
                  {body}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── CÓMO FUNCIONA ─── */}
      <section
        className="border-t relative overflow-hidden"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)',
          background: isDark
            ? 'linear-gradient(180deg, #060D1F 0%, #091520 100%)'
            : 'linear-gradient(180deg, #EEF3FC 0%, #E8EEFA 100%)',
        }}
      >
        <div className="relative max-w-7xl mx-auto px-6 lg:px-10 py-20 lg:py-28">
          <div className="max-w-2xl mb-16">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-4"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // cómo funciona
            </p>
            <h2
              className="font-display"
              style={{
                fontSize: 'clamp(1.9rem, 3.5vw, 2.75rem)',
                lineHeight: 1.15,
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              De cero a hacker en{' '}
              <span style={{ color: '#2596be' }}>cuatro pasos</span>.
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
            {[
              {
                step: '01',
                title: 'Crea tu cuenta',
                body: 'Regístrate gratis en menos de 2 minutos. Solo necesitas un correo y un nombre de usuario.',
                accent: '#1A3F96',
              },
              {
                step: '02',
                title: 'Elige un curso',
                body: 'Explora los cursos disponibles e inscríbete en el path que más te interese — desde principiante hasta avanzado.',
                accent: '#2596be',
              },
              {
                step: '03',
                title: 'Trabaja los labs',
                body: 'Lee el contenido del laboratorio, completa las actividades interactivas y responde el quiz al final.',
                accent: '#1A3F96',
              },
              {
                step: '04',
                title: 'Sube en el ranking',
                body: 'Cada lab completado suma puntos. Escala posiciones y demuestra tu nivel en el ranking global.',
                accent: '#F5C500',
              },
            ].map(({ step, title, body, accent }) => (
              <div
                key={step}
                className="hud-panel p-8 relative cursor-default"
                style={{
                  background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                  '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                  '--hud-border-hover': `${accent}99`,
                } as React.CSSProperties}
              >
                <p
                  className="num-display absolute top-4 right-6 pointer-events-none select-none"
                  style={{ fontSize: '5rem', lineHeight: 1, color: accent, opacity: 0.07 }}
                >
                  {step}
                </p>
                <p
                  className="font-mono text-[11px] tracking-[0.22em] uppercase mb-5"
                  style={{ color: accent }}
                >
                  // paso {step}
                </p>
                <h3
                  className="font-display mb-3"
                  style={{ fontSize: '1.35rem', color: isDark ? '#EEF3FC' : '#0A1545' }}
                >
                  {title}
                </h3>
                <p
                  className="text-[14px] font-light"
                  style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
                >
                  {body}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── RANKING ─── */}
      <section
        className="border-t relative overflow-hidden"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)',
          background: isDark
            ? 'linear-gradient(180deg, #060D1F 0%, #091520 100%)'
            : 'linear-gradient(180deg, #EEF3FC 0%, #E8EEFA 100%)',
        }}
      >
        <div className="relative max-w-3xl mx-auto px-6 lg:px-10 py-20 lg:py-28">
          <div className="mb-12">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-4"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // top operadores
            </p>
            <h2
              className="font-display mb-4"
              style={{
                fontSize: 'clamp(1.9rem, 3.5vw, 2.75rem)',
                lineHeight: 1.15,
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              Los <span style={{ color: '#F5C500' }}>5 mejores</span> hackers de la plataforma.
            </h2>
            <p
              className="text-[15px] max-w-xl"
              style={{ color: isDark ? '#4A70CC' : '#1A3F96', lineHeight: 1.65 }}
            >
              Ranking en tiempo real. Haz clic en cualquier operador para ver su perfil público.
            </p>
          </div>

          <Ranking limit={5} />
        </div>
      </section>

      {/* ─── CTA ─── */}
      {!token && (
        <section
          className="border-t"
          style={{ borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)' }}
        >
          <div className="max-w-4xl mx-auto px-6 lg:px-10 py-20 lg:py-28 text-center">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-5"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // ready_player_one
            </p>
            <h2
              className="font-display mb-6"
              style={{
                fontSize: 'clamp(2rem, 4.5vw, 3.25rem)',
                lineHeight: 1.1,
                color: isDark ? '#C8D5EE' : '#0A1545',
              }}
            >
              ¿Listo para <span style={{ color: '#1A3F96' }}>hackear</span>?
            </h2>
            <p
              className="text-base lg:text-lg font-light max-w-xl mx-auto mb-10"
              style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
            >
              Crea tu cuenta gratis, completa tu primer lab y empieza a sumar puntos.
            </p>
            <Link
              to="/register"
              className="btn-neon inline-block px-8 py-4 rounded-xl text-[15px] font-semibold"
            >
              Crear cuenta gratis →
            </Link>
          </div>
        </section>
      )}

      <Footer />
    </div>
  )
}
