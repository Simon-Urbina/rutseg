import { useEffect, useRef, useState, type PointerEvent } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Ranking from '../components/Ranking'
import Footer from '../components/Footer'
import HeroSpotlight from '../components/HeroSpotlight'
import { FeatureCarousel, type FeatureCarouselCard } from '../components/FeatureCarousel'

const FEATURES: FeatureCarouselCard[] = [
  {
    id: 'practica-real',
    title: 'Aprende practicando',
    kicker: '// PRÁCTICA REAL',
    body: 'Laboratorios interactivos basados en escenarios reales de ciberseguridad. Sin teoría plana ni presentaciones: acceso directo a terminales y sistemas vulnerables.',
    accent: '#1A3F96',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5"/>
        <line x1="12" y1="19" x2="20" y2="19"/>
      </svg>
    ),
  },
  {
    id: 'clasificacion',
    title: 'Compite en el ranking',
    kicker: '// CLASIFICACIÓN',
    body: 'Cada laboratorio completado otorga puntos de experiencia. Escala posiciones en la tabla general de la universidad y mide tu nivel técnico.',
    accent: '#F5C500',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/>
        <path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/>
        <path d="M4 22h16"/>
        <path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/>
        <path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/>
        <path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/>
      </svg>
    ),
  },
  {
    id: 'sin-relleno',
    title: 'Cero relleno teórico',
    kicker: '// HABILIDADES CLAVE',
    body: 'Formación hands-on orientada al ejercicio profesional de la ciberseguridad. Cada actividad enseña conceptos prácticos directamente aplicables.',
    accent: '#2596be',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
      </svg>
    ),
  },
  {
    id: 'infraestructura',
    title: 'Entornos de ejecución aislados',
    kicker: '// INFRAESTRUCTURA',
    body: 'Contenedores dedicados y seguros en la nube para ejecutar pruebas de seguridad de la información sin necesidad de configuraciones locales complejas.',
    accent: '#1A3F96',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="2" width="20" height="8" rx="2" ry="2"/>
        <rect x="2" y="14" width="20" height="8" rx="2" ry="2"/>
        <line x1="6" y1="6" x2="6.01" y2="6"/>
        <line x1="6" y1="18" x2="6.01" y2="18"/>
      </svg>
    ),
  },
]

const METHODOLOGY: FeatureCarouselCard[] = [
  {
    id: 'crea-cuenta',
    title: 'Crea tu cuenta',
    kicker: '// PASO 01',
    body: 'Regístrate gratis en menos de 2 minutos con tu correo universitario o personal.',
    accent: '#1A3F96',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="9" cy="7" r="4"/>
        <path d="M2 21v-2a4 4 0 0 1 4-4h6a4 4 0 0 1 4 4v2"/>
        <line x1="19" y1="8" x2="19" y2="14"/>
        <line x1="16" y1="11" x2="22" y2="11"/>
      </svg>
    ),
  },
  {
    id: 'elige-curso',
    title: 'Elige un curso',
    kicker: '// PASO 02',
    body: 'Inscríbete en los cursos según tu nivel de conocimiento, desde principiante hasta avanzado.',
    accent: '#2596be',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/>
        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/>
      </svg>
    ),
  },
  {
    id: 'trabaja-labs',
    title: 'Trabaja los labs',
    kicker: '// PASO 03',
    body: 'Ejecuta actividades en entornos seguros, resuelve los retos y responde las evaluaciones.',
    accent: '#1A3F96',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <path d="M9 2v6.5L4 18a2 2 0 0 0 1.8 3h12.4a2 2 0 0 0 1.8-3l-5-9.5V2"/>
        <line x1="8" y1="2" x2="16" y2="2"/>
      </svg>
    ),
  },
  {
    id: 'sube-ranking',
    title: 'Sube en el ranking',
    kicker: '// PASO 04',
    body: 'Obtén puntos por cada laboratorio completado y destaca en la clasificación general.',
    accent: '#F5C500',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
        <polyline points="17 6 23 6 23 12"/>
      </svg>
    ),
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

  const spotRef = useRef<HTMLDivElement>(null)
  const handleHeroPointerMove = (e: PointerEvent<HTMLElement>) => {
    const rect = e.currentTarget.getBoundingClientRect()
    const x = ((e.clientX - rect.left) / rect.width) * 100
    const y = ((e.clientY - rect.top) / rect.height) * 100
    spotRef.current?.style.setProperty('--x', `${x}%`)
    spotRef.current?.style.setProperty('--y', `${y}%`)
  }

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: isDark ? '#EEF3FC' : '#0A1545' }}>
      <Header />

      {/* ─── HERO SECTION INSTITUCIONAL ─── */}
      <section
        onPointerMove={handleHeroPointerMove}
        className="relative border-b overflow-hidden"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)',
          background: isDark
            ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 100%)'
            : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 100%)',
        }}
      >
        <HeroSpotlight ref={spotRef} isDark={isDark} />

        <div className="relative max-w-3xl mx-auto px-6 lg:px-10 pt-24 pb-24 lg:pt-32 lg:pb-32 flex flex-col items-center text-center">

          <h1
            className="font-display font-bold tracking-tight text-4xl sm:text-5xl lg:text-6xl leading-[1.08]"
            style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
          >
            Tu ruta segura hacia el{' '}
            <span
              style={{
                color: '#1A3F96',
                backgroundImage: isDark
                  ? 'linear-gradient(135deg, #7B9FE8 0%, #2451C8 60%, #2596be 100%)'
                  : 'linear-gradient(135deg, #1A3F96 0%, #2451C8 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
              }}
            >
              hacking real
            </span>
            .
          </h1>

          <p
            className="text-base sm:text-lg font-light max-w-2xl leading-relaxed mt-6"
            style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
          >
            RutSeg es la plataforma de entrenamiento práctico en ciberseguridad.
            Aprende con escenarios reales, a tu propio ritmo, sin presentaciones teóricas y con validación automática.
          </p>

          <div className="flex flex-wrap items-center justify-center gap-4 pt-8">
            {token ? (
              <Link to="/dashboard" className="btn-neon text-[15px]">
                Ir al dashboard →
              </Link>
            ) : (
              <>
                <Link to="/register" className="btn-neon text-[15px]">
                  Empezar gratis →
                </Link>
                <Link to="/login" className="btn-ghost-light text-[15px]">
                  Ya tengo cuenta
                </Link>
              </>
            )}
          </div>

          {/* Métricas Numéricas */}
          <div
            className="grid grid-cols-2 sm:grid-cols-4 gap-8 pt-10 mt-10 border-t w-full max-w-2xl"
            style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)' }}
          >
            {[
              { label: 'CURSOS', val: stats ? String(stats.courseCount) : '—', color: isDark ? '#EEF3FC' : '#0A1545' },
              { label: 'LABORATORIOS', val: stats ? String(stats.labCount) : '—', color: isDark ? '#7B9FE8' : '#1A3F96' },
              { label: 'PUNTOS DISPONIBLES', val: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', color: isDark ? '#F5C500' : '#998000' },
              { label: 'USUARIOS', val: stats ? String(stats.userCount) : '—', color: '#2596be' },
            ].map(({ label, val, color }) => (
              <div key={label} className="text-center">
                <p className="num-display text-2xl sm:text-3xl leading-none font-bold" style={{ color }}>
                  {val}
                </p>
                <p
                  className="font-mono text-[10px] tracking-[0.2em] uppercase mt-2 font-medium"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  {label}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── CARACTERÍSTICAS BENTO GRID INSTITUCIONAL ─── */}
      <section
        className="py-20 border-b"
        style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)' }}
      >
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-3xl mb-14">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-3 font-semibold"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // ¿POR QUÉ RUTSEG?
            </p>
            <h2
              className="font-display text-3xl sm:text-4xl font-bold tracking-tight"
              style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
            >
              Una plataforma pensada para aprender{' '}
              <span style={{ color: '#1A3F96' }}>haciendo</span>
              , no solo leyendo.
            </h2>
          </div>

          <FeatureCarousel cards={FEATURES} />
        </div>
      </section>

      {/* ─── CÓMO FUNCIONA — PASO A PASO ─── */}
      <section
        className="py-20 border-b relative"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)',
          background: isDark
            ? 'linear-gradient(180deg, #060D1F 0%, #091520 100%)'
            : 'linear-gradient(180deg, #EEF3FC 0%, #E8EEFA 100%)',
        }}
      >
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-2xl mb-14">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-3 font-semibold"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // METODOLOGÍA
            </p>
            <h2
              className="font-display text-3xl sm:text-4xl font-bold tracking-tight"
              style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
            >
              De cero a operador en <span style={{ color: '#2596be' }}>cuatro pasos</span>.
            </h2>
          </div>

          <FeatureCarousel cards={METHODOLOGY} />
        </div>
      </section>

      {/* ─── RANKING ─── */}
      <section
        className="py-20 border-b"
        style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)' }}
      >
        <div className="max-w-4xl mx-auto px-6 lg:px-10">
          <div className="mb-12">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-3 font-semibold"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // TOP OPERADORES
            </p>
            <h2
              className="font-display text-3xl sm:text-4xl font-bold tracking-tight mb-2"
              style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
            >
              Los <span style={{ color: isDark ? '#F5C500' : '#998000' }}>5 mejores</span> estudiantes de la plataforma.
            </h2>
            <p
              className="text-sm font-light"
              style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
            >
              Tabla de clasificación en tiempo real. Haz clic en cualquier perfil para explorar sus estadísticas.
            </p>
          </div>

          <div className="hud-panel p-6 sm:p-8">
            <Ranking limit={5} />
          </div>
        </div>
      </section>

      {/* ─── CTA BANNER INSTITUCIONAL ─── */}
      {!token && (
        <section className="py-20 text-center">
          <div className="max-w-3xl mx-auto px-6">
            <p
              className="font-mono text-xs tracking-[0.22em] uppercase mb-4 font-semibold"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // REGISTRO DE ESTUDIANTES
            </p>
            <h2
              className="font-display text-3xl sm:text-5xl font-bold tracking-tight mb-6"
              style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
            >
              ¿Listo para <span style={{ color: '#1A3F96' }}>empezar</span>?
            </h2>
            <p
              className="text-base sm:text-lg font-light mb-8 max-w-xl mx-auto"
              style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
            >
              Crea tu cuenta institucional gratis, accede a tu primer laboratorio y comienza a sumar puntos.
            </p>
            <div className="flex flex-col items-center justify-center gap-4">
              <Link to="/demo" className="btn-ghost-light text-[16px] py-3.5 px-8">
                Probar un laboratorio gratis, sin registro →
              </Link>
              <Link to="/register" className="btn-neon text-[16px] py-3.5 px-8">
                Crear cuenta gratis →
              </Link>
            </div>
          </div>
        </section>
      )}

      <Footer />
    </div>
  )
}
