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
    kicker: '// PRÁCTICA REAL',
    body: 'Laboratorios interactivos basados en escenarios reales de ciberseguridad. Sin teoría plana ni presentaciones: acceso directo a terminales y sistemas vulnerables.',
    accent: '#1A3F96',
    gridSpan: 'col-span-12 lg:col-span-7',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5"/>
        <line x1="12" y1="19" x2="20" y2="19"/>
      </svg>
    ),
  },
  {
    title: 'Compite en el ranking',
    kicker: '// CLASIFICACIÓN',
    body: 'Cada laboratorio completado otorga puntos de experiencia. Escala posiciones en la tabla general de la universidad y mide tu nivel técnico.',
    accent: '#F5C500',
    gridSpan: 'col-span-12 lg:col-span-5',
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
    title: 'Cero relleno teórico',
    kicker: '// HABILIDADES CLAVE',
    body: 'Formación hands-on orientada al ejercicio profesional de la ciberseguridad. Cada actividad enseña conceptos prácticos directamente aplicables.',
    accent: '#2596be',
    gridSpan: 'col-span-12 lg:col-span-5',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
      </svg>
    ),
  },
  {
    title: 'Entornos de ejecución aislados',
    kicker: '// INFRAESTRUCTURA',
    body: 'Contenedores dedicados y seguros en la nube para ejecutar pruebas de seguridad de la información sin necesidad de configuraciones locales complejas.',
    accent: '#1A3F96',
    gridSpan: 'col-span-12 lg:col-span-7',
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
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: isDark ? '#EEF3FC' : '#0A1545' }}>
      <Header />

      {/* ─── HERO SECTION INSTITUCIONAL ─── */}
      <section
        className="relative border-b overflow-hidden"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)',
          background: isDark
            ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 100%)'
            : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 100%)',
        }}
      >
        <div className="relative max-w-7xl mx-auto px-6 lg:px-10 pt-12 pb-20 lg:pt-20 lg:pb-28">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">

            {/* Columna Izquierda: Mensaje Principal */}
            <div className="lg:col-span-7 space-y-6">
              <div
                className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full font-mono text-[11px] tracking-[0.18em] uppercase border"
                style={{
                  color: isDark ? '#7B9FE8' : '#1A3F96',
                  background: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.06)',
                  borderColor: isDark ? 'rgba(26,63,150,0.25)' : 'rgba(26,63,150,0.20)',
                }}
              >
                <span className="w-2 h-2 rounded-full" style={{ background: '#2596be' }} />
                Plataforma Institucional de Laboratorios Prácticos
              </div>

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
                className="text-base sm:text-lg font-light max-w-2xl leading-relaxed"
                style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
              >
                RutSeg es la plataforma de entrenamiento práctico en ciberseguridad.
                Aprende con escenarios reales, a tu propio ritmo, sin presentaciones teóricas y con validación automática.
              </p>

              <div className="flex flex-wrap items-center gap-4 pt-2">
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
                className="grid grid-cols-2 sm:grid-cols-4 gap-6 pt-8 border-t"
                style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)' }}
              >
                {[
                  { label: 'CURSOS', val: stats ? String(stats.courseCount) : '—', color: isDark ? '#EEF3FC' : '#0A1545' },
                  { label: 'LABORATORIOS', val: stats ? String(stats.labCount) : '—', color: isDark ? '#7B9FE8' : '#1A3F96' },
                  { label: 'PUNTOS DISPONIBLES', val: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', color: '#F5C500' },
                  { label: 'USUARIOS', val: stats ? String(stats.userCount) : '—', color: '#2596be' },
                ].map(({ label, val, color }) => (
                  <div key={label}>
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

            {/* Columna Derecha: Terminal Profesional de Laboratorio */}
            <div className="lg:col-span-5">
              <div className="tech-terminal">
                <div className="tech-terminal-header">
                  <div className="flex items-center gap-2">
                    <span className="w-3 h-3 rounded-full bg-rose-500/80" />
                    <span className="w-3 h-3 rounded-full bg-amber-500/80" />
                    <span className="w-3 h-3 rounded-full bg-emerald-500/80" />
                  </div>
                  <span className="font-mono text-xs text-slate-300 tracking-wider">
                    operador@rutseg-lab:~#
                  </span>
                  <span className="font-mono text-[10px] text-teal-400 bg-teal-500/10 px-2 py-0.5 rounded border border-teal-500/20">
                    CONEXIÓN SEGURA
                  </span>
                </div>

                <div className="p-5 font-mono text-xs text-slate-200 space-y-3 min-h-[300px] leading-relaxed">
                  <div className="text-slate-400">// Entorno virtual de pruebas RutSeg</div>
                  <div className="flex items-center gap-2 text-teal-400">
                    <span>$</span>
                    <span>rutseg lab start --id sql-injection-01</span>
                  </div>
                  <div className="text-slate-300 pl-3 border-l-2 border-teal-500/40 space-y-1">
                    <div>[+] Inicializando contenedor aislado... [OK]</div>
                    <div>[+] IP asignada: 10.10.14.88</div>
                    <div>[+] Objetivo: Vulnerabilidad SQL Injection</div>
                  </div>
                  <div className="flex items-center gap-2 text-indigo-300">
                    <span>$</span>
                    <span>curl -s "http://10.10.14.88/login?user=admin'--"</span>
                  </div>
                  <div className="p-3 rounded bg-white/5 border border-white/10 text-emerald-400 text-[11px]">
                    <div>[+] Respuesta 200 OK — Sesión de Administrador Obtenida</div>
                    <div className="font-bold text-amber-300 mt-1">FLAG CAPTURADA: RUTSEG{`{sql_injection_master_2026}`}</div>
                  </div>
                  <div className="flex items-center gap-2 text-teal-400 cursor-blink">
                    <span>$</span>
                    <span className="text-slate-400">rutseg submit --flag RUTSEG{`{...}`}</span>
                  </div>
                </div>

                <div className="bg-black/40 px-4 py-2.5 border-t border-white/10 flex items-center justify-between font-mono text-[11px] text-slate-400">
                  <span className="flex items-center gap-2 text-emerald-400">
                    <span className="w-2 h-2 rounded-full bg-emerald-400" />
                    ESTADO: ACTIVO
                  </span>
                  <span>HANDS-ON LAB</span>
                </div>
              </div>
            </div>

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

          {/* Grilla Bento Asimétrica Formal */}
          <div className="grid grid-cols-12 gap-6">
            {FEATURES.map(({ title, kicker, body, icon, accent, gridSpan }) => (
              <div
                key={title}
                className={`${gridSpan} hud-panel p-8 flex flex-col justify-between`}
              >
                <div>
                  <div className="flex items-center justify-between mb-6">
                    <div
                      className="w-12 h-12 rounded-xl flex items-center justify-center"
                      style={{
                        background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
                        border: `1px solid ${accent}40`,
                        color: accent,
                      }}
                    >
                      {icon}
                    </div>
                    <span
                      className="font-mono text-[10px] tracking-[0.18em] uppercase px-3 py-1 rounded border font-semibold"
                      style={{
                        color: accent,
                        background: `${accent}10`,
                        borderColor: `${accent}30`,
                      }}
                    >
                      {kicker}
                    </span>
                  </div>

                  <h3
                    className="font-display text-2xl font-bold mb-3"
                    style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
                  >
                    {title}
                  </h3>

                  <p
                    className="text-sm font-light leading-relaxed"
                    style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
                  >
                    {body}
                  </p>
                </div>
              </div>
            ))}
          </div>
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

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                step: '01',
                title: 'Crea tu cuenta',
                body: 'Regístrate gratis en menos de 2 minutos con tu correo universitario o personal.',
                accent: '#1A3F96',
              },
              {
                step: '02',
                title: 'Elige un curso',
                body: 'Inscríbete en los cursos según tu nivel de conocimiento, desde principiante hasta avanzado.',
                accent: '#2596be',
              },
              {
                step: '03',
                title: 'Trabaja los labs',
                body: 'Ejecuta actividades en entornos seguros, resuelve los retos y responde las evaluaciones.',
                accent: '#1A3F96',
              },
              {
                step: '04',
                title: 'Sube en el ranking',
                body: 'Obtén puntos por cada laboratorio completado y destaca en la clasificación general.',
                accent: '#F5C500',
              },
            ].map(({ step, title, body, accent }) => (
              <div
                key={step}
                className="hud-panel p-7 relative flex flex-col justify-between"
              >
                <div>
                  <span
                    className="font-mono text-xs font-semibold tracking-[0.2em] uppercase block mb-4"
                    style={{ color: accent }}
                  >
                    // PASO {step}
                  </span>
                  <h3
                    className="font-display text-xl font-bold mb-2"
                    style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
                  >
                    {title}
                  </h3>
                  <p
                    className="text-xs sm:text-sm font-light leading-relaxed"
                    style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
                  >
                    {body}
                  </p>
                </div>
              </div>
            ))}
          </div>
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
              Los <span style={{ color: '#F5C500' }}>5 mejores</span> estudiantes de la plataforma.
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
            <Link to="/register" className="btn-neon text-[16px] py-3.5 px-8">
              Crear cuenta gratis →
            </Link>
          </div>
        </section>
      )}

      <Footer />
    </div>
  )
}
