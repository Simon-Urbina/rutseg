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
    title: 'Aprende Practicando',
    badge: 'HANDS-ON',
    body: 'Laboratorios interactivos con escenarios de ciberseguridad reales. Sin teoría plana ni diapositivas: solo terminales, código y problemas para resolver.',
    accent: '#2596be',
    gridSpan: 'col-span-12 md:col-span-7',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="4 17 10 11 4 5"/>
        <line x1="12" y1="19" x2="20" y2="19"/>
      </svg>
    ),
  },
  {
    title: 'Compite en el Ranking',
    badge: 'GAMIFICACIÓN',
    body: 'Cada laboratorio completado suma puntos instantáneos. Escala posiciones en el Leaderboard global y demuestra tu nivel técnico.',
    accent: '#F5C500',
    gridSpan: 'col-span-12 md:col-span-5',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
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
    title: 'Cero Relleno Teórico',
    badge: '100% EFECTIVO',
    body: 'Aprendizaje enfocado en habilidades reales del mercado laboral de ciberseguridad. Cada reto existe para enseñarte herramientas tácticas aplicables.',
    accent: '#10B981',
    gridSpan: 'col-span-12 md:col-span-12',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>
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
    <div className={`min-h-screen transition-colors duration-300 ${isDark ? 'bg-[#060D1F] text-slate-100' : 'bg-slate-50 text-slate-900'}`}>
      <Header />

      {/* ─── HERO SECTION WITH WATERMELON UI MESH GLOW ─── */}
      <section className="relative pt-12 pb-24 lg:pt-20 lg:pb-32 overflow-hidden">
        {/* Ambient Glowing Watermelon Mesh Orbs */}
        <div className="wm-orb w-96 h-96 top-[-50px] left-[-50px] bg-teal-500/20 dark:bg-teal-500/15 blur-3xl" />
        <div className="wm-orb w-[500px] h-[500px] top-[100px] right-[-100px] bg-indigo-500/20 dark:bg-indigo-600/15 blur-3xl" />
        <div className="wm-orb w-80 h-80 bottom-0 left-[30%] bg-emerald-500/15 dark:bg-emerald-500/10 blur-3xl" />

        <div className="relative max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-4xl mx-auto text-center">
            {/* Pill tag */}
            <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-teal-500/20 bg-teal-500/10 backdrop-blur-md text-teal-400 font-mono text-xs tracking-wider uppercase mb-8 animate-fade-up-1">
              <span className="w-2 h-2 rounded-full bg-teal-400 animate-pulse" />
              Plataforma de Laboratorios Prácticos en Ciberseguridad
            </div>

            {/* Main Headline */}
            <h1 className="font-display font-extrabold tracking-tight text-4xl sm:text-6xl lg:text-7xl leading-[1.08] mb-8 animate-fade-up-2">
              Tu ruta segura hacia el{' '}
              <span className="bg-gradient-to-r from-teal-400 via-sky-400 to-indigo-400 bg-clip-text text-transparent">
                hacking real
              </span>
              .
            </h1>

            <p className="text-lg sm:text-xl font-normal max-w-2xl mx-auto mb-10 text-slate-600 dark:text-slate-300 leading-relaxed animate-fade-up-3">
              RutSeg combina laboratorios interactivos en vivo, retos gamificados y métricas reales.
              Aprende a defender y atacar sistemas reales desde el navegador, a tu propio ritmo.
            </p>

            {/* Call to action buttons */}
            <div className="flex flex-wrap items-center justify-center gap-4 animate-fade-up-4 mb-20">
              {token ? (
                <Link to="/dashboard" className="btn-wm-primary text-base py-3.5 px-8">
                  Ir al Dashboard →
                </Link>
              ) : (
                <>
                  <Link to="/register" className="btn-wm-primary text-base py-3.5 px-8">
                    Empezar Gratis →
                  </Link>
                  <Link to="/login" className="btn-wm-secondary text-base py-3.5 px-8">
                    Ya tengo cuenta
                  </Link>
                </>
              )}
            </div>

            {/* BENTO STATS BAR */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 p-4 rounded-3xl glass-card-wm animate-fade-up-5">
              {[
                { value: stats ? String(stats.courseCount) : '—', label: 'Cursos', color: 'text-teal-400' },
                { value: stats ? String(stats.labCount) : '—', label: 'Laboratorios', color: 'text-sky-400' },
                { value: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', label: 'Puntos Disponibles', color: 'text-amber-400' },
                { value: stats ? String(stats.userCount) : '—', label: 'Operadores', color: 'text-emerald-400' },
              ].map(({ value, label, color }) => (
                <div key={label} className="p-4 rounded-2xl bg-white/5 dark:bg-white/5 border border-white/5 text-center">
                  <p className={`num-display text-3xl sm:text-4xl font-extrabold ${color} leading-none mb-2`}>
                    {value}
                  </p>
                  <p className="font-mono text-[11px] tracking-widest text-slate-500 dark:text-slate-400 uppercase">
                    {label}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ─── FEATURES BENTO GRID ─── */}
      <section className="relative py-20 border-t border-slate-200 dark:border-white/10">
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-2xl mb-14">
            <span className="font-mono text-xs tracking-widest text-teal-500 uppercase font-semibold block mb-3">
              // Ventajas Tácticas
            </span>
            <h2 className="font-display text-3xl sm:text-4xl font-bold tracking-tight">
              Diseñado para aprender <span className="text-teal-500">haciendo</span>.
            </h2>
          </div>

          <div className="grid grid-cols-12 gap-6">
            {FEATURES.map(({ title, badge, body, icon, accent, gridSpan }) => (
              <div
                key={title}
                className={`${gridSpan} glass-card-wm p-8 flex flex-col justify-between group hover:border-teal-500/40`}
              >
                <div>
                  <div className="flex items-center justify-between mb-6">
                    <div
                      className="w-12 h-12 rounded-2xl flex items-center justify-center transition-transform group-hover:scale-110"
                      style={{
                        background: `${accent}15`,
                        color: accent,
                        border: `1px solid ${accent}30`,
                      }}
                    >
                      {icon}
                    </div>
                    <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-white/10 bg-white/5 text-slate-400">
                      {badge}
                    </span>
                  </div>
                  <h3 className="font-display text-2xl font-bold mb-3">{title}</h3>
                  <p className="text-slate-600 dark:text-slate-300 text-sm leading-relaxed">{body}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── CÓMO FUNCIONA — BENTO STEPS ─── */}
      <section className="relative py-24 border-t border-slate-200 dark:border-white/10 bg-slate-100/50 dark:bg-white/[0.02]">
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-2xl mb-14">
            <span className="font-mono text-xs tracking-widest text-teal-500 uppercase font-semibold block mb-3">
              // Flujo de Aprendizaje
            </span>
            <h2 className="font-display text-3xl sm:text-4xl font-bold tracking-tight">
              De cero a operador en <span className="text-sky-400">4 pasos sencillos</span>.
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              {
                step: '01',
                title: 'Crea tu Cuenta',
                body: 'Registro instantáneo en menos de 2 minutos. Solo necesitas un correo y usuario.',
              },
              {
                step: '02',
                title: 'Elige un Path',
                body: 'Explora cursos desde nivel principiante hasta escenarios avanzados.',
              },
              {
                step: '03',
                title: 'Resuelve Labs',
                body: 'Ejecuta exploits, analiza vulnerabilidades y responde quizzes interactivos.',
              },
              {
                step: '04',
                title: 'Escala el Ranking',
                body: 'Obtén puntos por cada lab superado y sube en la clasificación global.',
              },
            ].map(({ step, title, body }) => (
              <div key={step} className="glass-card-wm p-7 flex flex-col justify-between relative overflow-hidden group">
                <span className="num-display text-6xl font-black text-slate-300/20 dark:text-white/5 absolute top-3 right-4 pointer-events-none select-none group-hover:scale-110 transition-transform">
                  {step}
                </span>
                <div>
                  <span className="font-mono text-xs text-teal-400 font-bold tracking-widest block mb-4">
                    // PASO {step}
                  </span>
                  <h3 className="font-display text-xl font-bold mb-2">{title}</h3>
                  <p className="text-slate-600 dark:text-slate-400 text-sm leading-relaxed">{body}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── LEADERBOARD SECTION ─── */}
      <section className="relative py-24 border-t border-slate-200 dark:border-white/10">
        <div className="max-w-4xl mx-auto px-6 lg:px-10">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="font-mono text-xs tracking-widest text-amber-400 uppercase font-semibold block mb-3">
              // Top Operadores
            </span>
            <h2 className="font-display text-3xl sm:text-4xl font-bold tracking-tight">
              Los 5 mejores hackers de la plataforma
            </h2>
          </div>

          <div className="glass-card-wm p-6 sm:p-8">
            <Ranking limit={5} />
          </div>
        </div>
      </section>

      {/* ─── CTA BANNER ─── */}
      {!token && (
        <section className="relative py-24 border-t border-slate-200 dark:border-white/10 overflow-hidden">
          <div className="wm-orb w-96 h-96 top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-teal-500/20 blur-3xl" />
          <div className="relative max-w-4xl mx-auto px-6 text-center">
            <h2 className="font-display text-4xl sm:text-5xl font-extrabold mb-6">
              ¿Listo para empezar a <span className="text-teal-400">hackear</span>?
            </h2>
            <p className="text-slate-600 dark:text-slate-300 text-lg mb-10 max-w-xl mx-auto">
              Crea tu cuenta totalmente gratis hoy mismo y accede a la librería completa de laboratorios.
            </p>
            <Link to="/register" className="btn-wm-primary text-lg py-4 px-10">
              Crear Cuenta Gratis →
            </Link>
          </div>
        </section>
      )}

      <Footer />
    </div>
  )
}
