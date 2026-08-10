import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Ranking from '../components/Ranking'
import Footer from '../components/Footer'
import CourseCard, { type Course } from '../components/CourseCard'

export default function LandingPage() {
  const { theme } = useTheme()
  const { token } = useAuth()
  const isDark = theme === 'dark'

  const [stats, setStats] = useState<{ courseCount: number; labCount: number; totalPoints: number; userCount: number } | null>(null)
  const [courses, setCourses] = useState<Course[]>([])
  const [coursesLoading, setCoursesLoading] = useState(true)

  const [activeTab, setActiveTab] = useState<'terminal' | 'exploit' | 'flag'>('terminal')

  useEffect(() => {
    api.get<{ courseCount: number; labCount: number; totalPoints: number; userCount: number }>('/api/stats')
      .then(setStats).catch(() => {})

    api.get<Course[]>('/api/courses')
      .then(setCourses)
      .catch(() => {})
      .finally(() => setCoursesLoading(false))
  }, [])

  return (
    <div className={`min-h-screen selection:bg-cyan-500/30 selection:text-white transition-colors duration-300 ${isDark ? 'bg-[#070913] text-slate-100' : 'bg-slate-50 text-slate-900'}`}>
      <Header />

      {/* ─── HERO SECTION WITH INTERACTIVE TERMINAL PREVIEW ─── */}
      <section className="relative pt-8 pb-20 lg:pt-16 lg:pb-32 overflow-hidden">
        {/* Bioluminescent Watermelon Glow Orbs */}
        <div className="wm-orb w-[550px] h-[550px] top-[-100px] left-[-150px] bg-cyan-500/20 blur-[120px]" />
        <div className="wm-orb w-[600px] h-[600px] top-[150px] right-[-200px] bg-purple-600/20 blur-[130px]" />
        <div className="wm-orb w-[400px] h-[400px] bottom-[-50px] left-[35%] bg-emerald-400/15 blur-[100px]" />

        <div className="relative max-w-7xl mx-auto px-6 lg:px-10">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">

            {/* Left Hero Content */}
            <div className="lg:col-span-7 space-y-8 text-left">
              {/* Badge */}
              <div className="inline-flex items-center gap-2.5 px-4 py-2 rounded-full border border-cyan-500/30 bg-cyan-500/10 backdrop-blur-xl text-cyan-300 font-mono text-xs font-bold uppercase tracking-wider shadow-[0_0_20px_rgba(5,217,232,0.2)]">
                <span className="relative flex h-2.5 w-2.5">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-cyan-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-cyan-400"></span>
                </span>
                PLATAFORMA DE HACKING & CIBERSEGURIDAD 2.0
              </div>

              {/* Title */}
              <h1 className="font-display font-black text-4xl sm:text-6xl lg:text-7xl leading-[1.05] tracking-tight">
                Tu ruta segura hacia el{' '}
                <span className="bg-gradient-to-r from-cyan-400 via-emerald-300 to-pink-500 bg-clip-text text-transparent drop-shadow-sm">
                  hacking real
                </span>
                .
              </h1>

              {/* Paragraph */}
              <p className="text-base sm:text-lg font-normal text-slate-300 dark:text-slate-300 max-w-2xl leading-relaxed">
                Entrena con laboratorios interactivos en vivo, escenarios de pentesting y exploits reales. Sin diapositivas y sin teoría aburrida: conecta tu terminal y resuelve problemas.
              </p>

              {/* Action Buttons */}
              <div className="flex flex-wrap items-center gap-4 pt-2">
                {token ? (
                  <Link to="/dashboard" className="btn-wm-primary text-base py-4 px-8">
                    Ir al Dashboard →
                  </Link>
                ) : (
                  <>
                    <Link to="/register" className="btn-wm-primary text-base py-4 px-8">
                      Empezar Gratis Ahora →
                    </Link>
                    <Link to="/login" className="btn-wm-secondary text-base py-4 px-8">
                      Ya tengo cuenta
                    </Link>
                  </>
                )}
              </div>

              {/* Live Metric Pills */}
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 pt-6 border-t border-white/10">
                {[
                  { label: 'CURSOS', val: stats ? String(stats.courseCount) : '—', color: 'text-cyan-400' },
                  { label: 'LABORATORIOS', val: stats ? String(stats.labCount) : '—', color: 'text-emerald-400' },
                  { label: 'PUNTOS DISP.', val: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', color: 'text-amber-400' },
                  { label: 'OPERADORES', val: stats ? String(stats.userCount) : '—', color: 'text-pink-400' },
                ].map(({ label, val, color }) => (
                  <div key={label} className="p-3 rounded-2xl bg-white/5 border border-white/10">
                    <p className={`num-display text-2xl sm:text-3xl font-extrabold ${color} leading-none mb-1`}>
                      {val}
                    </p>
                    <p className="font-mono text-[9px] tracking-widest text-slate-400 uppercase">
                      {label}
                    </p>
                  </div>
                ))}
              </div>
            </div>

            {/* Right Hero: Interactive Terminal Mockup */}
            <div className="lg:col-span-5">
              <div className="terminal-card relative shadow-[0_25px_60px_-15px_rgba(5,217,232,0.3)]">
                {/* Header */}
                <div className="terminal-header">
                  <div className="terminal-dots">
                    <span className="terminal-dot terminal-dot-red" />
                    <span className="terminal-dot terminal-dot-yellow" />
                    <span className="terminal-dot terminal-dot-green" />
                  </div>
                  <span className="font-mono text-xs text-slate-400 font-semibold tracking-wider">
                    root@rutseg-lab:~#
                  </span>
                  <div className="flex gap-2 font-mono text-[10px]">
                    <button
                      onClick={() => setActiveTab('terminal')}
                      className={`px-2 py-1 rounded transition-colors ${activeTab === 'terminal' ? 'bg-cyan-500/20 text-cyan-300' : 'text-slate-500 hover:text-slate-300'}`}
                    >
                      terminal.sh
                    </button>
                    <button
                      onClick={() => setActiveTab('exploit')}
                      className={`px-2 py-1 rounded transition-colors ${activeTab === 'exploit' ? 'bg-purple-500/20 text-purple-300' : 'text-slate-500 hover:text-slate-300'}`}
                    >
                      exploit.py
                    </button>
                  </div>
                </div>

                {/* Body Content */}
                <div className="p-5 font-mono text-xs sm:text-sm text-slate-200 space-y-3 min-h-[320px]">
                  {activeTab === 'terminal' ? (
                    <>
                      <div className="text-slate-400"># RutSeg Cybersec Sandbox v2.4.0</div>
                      <div className="flex items-center gap-2 text-cyan-400">
                        <span>$</span>
                        <span>rutseg connect --target lab-sqli-v1</span>
                      </div>
                      <div className="text-emerald-400 text-[12px] pl-3 border-l border-emerald-500/40 space-y-1">
                        <div>[+] Connecting to isolated docker container... OK</div>
                        <div>[+] Target IP: 10.10.14.88 (Port 80)</div>
                        <div>[+] Vulnerability detected: Blind SQL Injection</div>
                      </div>
                      <div className="flex items-center gap-2 text-pink-400">
                        <span>$</span>
                        <span>python3 exploit.py --url http://10.10.14.88/api</span>
                      </div>
                      <div className="text-amber-300 bg-amber-500/10 p-2.5 rounded-lg border border-amber-500/20 space-y-1">
                        <div>[!] Extracting database admin hash...</div>
                        <div>[!] Cracking hash via hashcat dictionary attack...</div>
                        <div className="text-emerald-400 font-bold">🎉 FLAG CAPTURED: RUTSEG{`{sql_injection_master_2026}`}</div>
                      </div>
                      <div className="flex items-center gap-2 text-cyan-300 pt-2 cursor-blink">
                        <span>$</span>
                        <span className="text-slate-400">submit-flag --points 500</span>
                      </div>
                    </>
                  ) : (
                    <>
                      <div className="text-purple-400"># Python Exploit Script - Proof of Concept</div>
                      <pre className="text-slate-300 text-xs leading-relaxed overflow-x-auto p-2 bg-black/40 rounded border border-white/5">
{`import requests

url = "http://10.10.14.88/api/v1/auth"
payload = {"username": "admin' OR 1=1 --", "pass": "x"}

res = requests.post(url, json=payload)
if "flag" in res.text:
    print("[+] SUCCESS! Access granted.")`}
                      </pre>
                      <div className="p-2.5 rounded bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs">
                        Status: EXPLOIT READY TO EXECUTE
                      </div>
                    </>
                  )}
                </div>

                {/* Footer bar */}
                <div className="bg-black/60 px-4 py-2 border-t border-white/10 flex items-center justify-between font-mono text-[11px] text-slate-400">
                  <span className="flex items-center gap-1.5 text-emerald-400">
                    <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                    CONTAINER ONLINE
                  </span>
                  <span>100% HANDS-ON</span>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ─── BENTO BOX FEATURES GRID ─── */}
      <section className="relative py-24 border-t border-white/10 bg-slate-950/60">
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-3xl mb-16 text-left">
            <span className="font-mono text-xs tracking-widest text-cyan-400 uppercase font-bold block mb-3">
              // VENTAJAS EXCLUSIVAS DE RUTSEG
            </span>
            <h2 className="font-display text-3xl sm:text-5xl font-black tracking-tight">
              Una plataforma diseñada para aprender <span className="text-cyan-400">haciendo</span>.
            </h2>
          </div>

          {/* ASYMMETRIC BENTO GRID */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6">

            {/* Bento Card 1 (Span 8): Interactive Labs */}
            <div className="md:col-span-8 glass-card-wm p-8 flex flex-col justify-between group">
              <div>
                <div className="flex items-center justify-between mb-6">
                  <div className="w-12 h-12 rounded-2xl bg-cyan-500/20 border border-cyan-500/40 text-cyan-400 flex items-center justify-center font-mono font-bold text-lg">
                    &gt;_
                  </div>
                  <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-cyan-500/30 bg-cyan-500/10 text-cyan-300 font-bold">
                    LABORATORIOS EN VIVO
                  </span>
                </div>
                <h3 className="font-display text-2xl sm:text-3xl font-extrabold mb-3">
                  Laboratorios Interactivos con Escenarios Reales
                </h3>
                <p className="text-slate-300 text-base leading-relaxed max-w-xl">
                  Sin teoría plana, sin PDF de 100 páginas: accede directamente a entornos vulnerables preparados para practicar inyección SQL, XSS, escalación de privilegios y pentesting web.
                </p>
              </div>

              <div className="mt-8 p-4 rounded-2xl bg-black/40 border border-white/10 font-mono text-xs text-emerald-400 flex items-center justify-between">
                <span>[+] Target machine: Linux Ubuntu 22.04 LTS</span>
                <span className="text-cyan-400">LIVE CONTAINER</span>
              </div>
            </div>

            {/* Bento Card 2 (Span 4): Gamification & Leaderboard */}
            <div className="md:col-span-4 glass-card-wm p-8 flex flex-col justify-between group">
              <div>
                <div className="flex items-center justify-between mb-6">
                  <div className="w-12 h-12 rounded-2xl bg-amber-500/20 border border-amber-500/40 text-amber-400 flex items-center justify-center text-xl">
                    🏆
                  </div>
                  <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-amber-500/30 bg-amber-500/10 text-amber-300 font-bold">
                    LEADERBOARD
                  </span>
                </div>
                <h3 className="font-display text-2xl font-extrabold mb-3">
                  Compite en el Ranking Global
                </h3>
                <p className="text-slate-300 text-sm leading-relaxed">
                  Cada laboratorio superado otorga puntos de experiencia. Sube puestos en la tabla general y demuestra tu nivel técnico ante la comunidad.
                </p>
              </div>

              <div className="mt-6 space-y-2">
                <div className="flex items-center justify-between p-2.5 rounded-xl bg-white/5 border border-white/10 text-xs font-mono">
                  <span className="text-amber-400 font-bold">#1 @cyber_ninja</span>
                  <span className="text-slate-300">12,450 PTS</span>
                </div>
                <div className="flex items-center justify-between p-2.5 rounded-xl bg-white/5 border border-white/10 text-xs font-mono">
                  <span className="text-slate-300 font-bold">#2 @root_seeker</span>
                  <span className="text-slate-300">10,800 PTS</span>
                </div>
              </div>
            </div>

            {/* Bento Card 3 (Span 4): Zero Filler */}
            <div className="md:col-span-4 glass-card-wm p-8 flex flex-col justify-between group">
              <div>
                <div className="flex items-center justify-between mb-6">
                  <div className="w-12 h-12 rounded-2xl bg-pink-500/20 border border-pink-500/40 text-pink-400 flex items-center justify-center text-xl">
                    ⚡
                  </div>
                  <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-pink-500/30 bg-pink-500/10 text-pink-300 font-bold">
                    CERO RELLENO
                  </span>
                </div>
                <h3 className="font-display text-2xl font-extrabold mb-3">
                  100% Efectividad Táctica
                </h3>
                <p className="text-slate-300 text-sm leading-relaxed">
                  Aprende lo que realmente se exige en auditorías de seguridad y puestos de Ciberseguridad. Directo al grano desde el minuto 1.
                </p>
              </div>

              <div className="mt-6 flex items-center gap-2 font-mono text-xs text-pink-400">
                <span>✓ SIN DIAPOSITIVAS</span>
                <span>✓ SOLO PRÁCTICA</span>
              </div>
            </div>

            {/* Bento Card 4 (Span 8): Progress Tracking */}
            <div className="md:col-span-8 glass-card-wm p-8 flex flex-col justify-between group">
              <div>
                <div className="flex items-center justify-between mb-6">
                  <div className="w-12 h-12 rounded-2xl bg-emerald-500/20 border border-emerald-500/40 text-emerald-400 flex items-center justify-center text-xl">
                    📊
                  </div>
                  <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-emerald-500/30 bg-emerald-500/10 text-emerald-300 font-bold">
                    MÉTRICAS REALES
                  </span>
                </div>
                <h3 className="font-display text-2xl sm:text-3xl font-extrabold mb-3">
                  Seguimiento de Progreso y Flags Capturadas
                </h3>
                <p className="text-slate-300 text-base leading-relaxed max-w-xl">
                  Visualiza estadísticas detalladas de laboratorios completados, módulos aprobados y habilidades adquiridas en tu perfil público de operador.
                </p>
              </div>

              <div className="mt-6 grid grid-cols-3 gap-4">
                <div className="p-3 rounded-xl bg-white/5 text-center">
                  <p className="num-display text-xl font-bold text-emerald-400">100%</p>
                  <p className="font-mono text-[10px] text-slate-400 uppercase">Validación Automática</p>
                </div>
                <div className="p-3 rounded-xl bg-white/5 text-center">
                  <p className="num-display text-xl font-bold text-cyan-400">24/7</p>
                  <p className="font-mono text-[10px] text-slate-400 uppercase">Acceso a Labs</p>
                </div>
                <div className="p-3 rounded-xl bg-white/5 text-center">
                  <p className="num-display text-xl font-bold text-amber-400">LIVE</p>
                  <p className="font-mono text-[10px] text-slate-400 uppercase">Ranking Instantáneo</p>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* ─── LIVE COURSES SHOWCASE ─── */}
      {!coursesLoading && courses.length > 0 && (
        <section className="relative py-24 border-t border-white/10">
          <div className="max-w-7xl mx-auto px-6 lg:px-10">
            <div className="flex items-end justify-between flex-wrap gap-4 mb-14">
              <div>
                <span className="font-mono text-xs tracking-widest text-cyan-400 uppercase font-bold block mb-3">
                  // CATÁLOGO DESTACADO DE CURSOS
                </span>
                <h2 className="font-display text-3xl sm:text-4xl font-extrabold tracking-tight">
                  Explora las Rutas de Aprendizaje
                </h2>
              </div>
              <Link to="/register" className="btn-wm-secondary text-sm py-2.5 px-5">
                Ver Todos los Cursos →
              </Link>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {courses.slice(0, 3).map(course => (
                <CourseCard
                  key={course.id}
                  course={course}
                  onEnroll={() => {}}
                  onContinue={() => {}}
                />
              ))}
            </div>
          </div>
        </section>
      )}

      {/* ─── CÓMO FUNCIONA STEPS ─── */}
      <section className="relative py-24 border-t border-white/10 bg-slate-950/40">
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="max-w-2xl mb-16">
            <span className="font-mono text-xs tracking-widest text-emerald-400 uppercase font-bold block mb-3">
              // PASO A PASO
            </span>
            <h2 className="font-display text-3xl sm:text-4xl font-extrabold tracking-tight">
              De cero a operador en 4 sencillos pasos.
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              { step: '01', title: 'Crea tu Cuenta', desc: 'Registro instantáneo en menos de 2 minutos sin tarjeta de crédito.' },
              { step: '02', title: 'Elige un Path', desc: 'Selecciona cursos desde nivel principiante hasta escenarios avanzados.' },
              { step: '03', title: 'Resuelve Labs', desc: 'Ejecuta exploits, descubre vulnerabilidades y responde los retos.' },
              { step: '04', title: 'Escala el Ranking', desc: 'Acumula puntos por cada laboratorio y posiciónate en el TOP 10.' },
            ].map(({ step, title, desc }) => (
              <div key={step} className="glass-card-wm p-8 relative overflow-hidden group">
                <span className="num-display text-7xl font-black text-white/5 absolute top-2 right-4 pointer-events-none select-none group-hover:scale-110 transition-transform">
                  {step}
                </span>
                <div>
                  <span className="font-mono text-xs text-cyan-400 font-bold tracking-widest block mb-4">
                    // PASO {step}
                  </span>
                  <h3 className="font-display text-xl font-bold mb-2">{title}</h3>
                  <p className="text-slate-300 text-sm leading-relaxed">{desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── RANKING PODIUM ─── */}
      <section className="relative py-24 border-t border-white/10">
        <div className="max-w-4xl mx-auto px-6 lg:px-10">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="font-mono text-xs tracking-widest text-amber-400 uppercase font-bold block mb-3">
              // CLASIFICACIÓN EN TIEMPO REAL
            </span>
            <h2 className="font-display text-3xl sm:text-4xl font-extrabold tracking-tight">
              Top Operadores de RutSeg
            </h2>
          </div>

          <div className="glass-card-wm p-6 sm:p-10">
            <Ranking limit={5} />
          </div>
        </div>
      </section>

      {/* ─── HIGH CONVERSION CTA ─── */}
      {!token && (
        <section className="relative py-28 border-t border-white/10 overflow-hidden">
          <div className="wm-orb w-[600px] h-[600px] top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-cyan-500/20 blur-[130px]" />
          
          <div className="relative max-w-4xl mx-auto px-6 text-center">
            <h2 className="font-display text-4xl sm:text-6xl font-black tracking-tight mb-6">
              ¿Listo para empezar a <span className="text-cyan-400">hackear</span>?
            </h2>
            <p className="text-slate-300 text-lg sm:text-xl mb-10 max-w-2xl mx-auto leading-relaxed">
              Crea tu cuenta totalmente gratis hoy mismo y accede a la librería completa de laboratorios.
            </p>
            <Link to="/register" className="btn-wm-primary text-lg py-5 px-12 shadow-[0_0_40px_rgba(5,217,232,0.4)]">
              Crear Cuenta Gratis Ahora →
            </Link>
          </div>
        </section>
      )}

      <Footer />
    </div>
  )
}
