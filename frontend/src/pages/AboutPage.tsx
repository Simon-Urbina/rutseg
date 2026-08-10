import { useTheme } from '../context/ThemeContext'
import Header from '../components/Header'
import Footer from '../components/Footer'

const INTERESTS = [
  {
    title: 'Inteligencia Artificial',
    body: 'Aprendizaje automático, modelos de lenguaje y agentes autónomos. Explorando cómo la IA puede potenciar herramientas de seguridad y educación.',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 2a4 4 0 0 1 4 4v1h1a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3v-6a3 3 0 0 1 3-3h1V6a4 4 0 0 1 4-4Z"/>
        <circle cx="9" cy="13" r="1"/><circle cx="15" cy="13" r="1"/>
        <path d="M9 17c.83.63 1.96 1 3 1s2.17-.37 3-1"/>
      </svg>
    ),
    accent: '#2596be',
  },
  {
    title: 'Ciberseguridad',
    body: 'Hacking ético, análisis de vulnerabilidades y defensa de sistemas. La seguridad como mentalidad, no solo como herramienta.',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
      </svg>
    ),
    accent: '#1A3F96',
  },
  {
    title: 'Desarrollo de Software',
    body: 'Interfaces que importan, backends que escalan. Construir productos reales es la mejor forma de aprender.',
    icon: (
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/>
      </svg>
    ),
    accent: '#F5C500',
  },
]

const STACK = [
  { name: 'React 19', category: 'Frontend' },
  { name: 'TypeScript', category: 'Frontend' },
  { name: 'Tailwind CSS v4', category: 'Frontend' },
  { name: 'Vite', category: 'Frontend' },
  { name: 'Hono', category: 'Backend' },
  { name: 'Bun', category: 'Backend' },
  { name: 'PostgreSQL', category: 'Backend' },
  { name: 'Supabase', category: 'Backend' },
  { name: 'Gmail API', category: 'Backend' },
  { name: 'Railway', category: 'Infra' },
  { name: 'Vercel', category: 'Infra' },
  { name: 'FastAPI', category: 'IA' },
  { name: 'Python', category: 'IA' },
  { name: 'Groq', category: 'IA' },
]

const SOCIAL = [
  {
    label: 'YouTube',
    handle: '@simon__urbina',
    href: 'https://www.youtube.com/@simon__urbina',
    color: '#f87171',
    svg: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M23.5 6.19a3.02 3.02 0 0 0-2.12-2.14C19.54 3.5 12 3.5 12 3.5s-7.54 0-9.38.55A3.02 3.02 0 0 0 .5 6.19C0 8.04 0 12 0 12s0 3.96.5 5.81a3.02 3.02 0 0 0 2.12 2.14C4.46 20.5 12 20.5 12 20.5s7.54 0 9.38-.55a3.02 3.02 0 0 0 2.12-2.14C24 15.96 24 12 24 12s0-3.96-.5-5.81ZM9.75 15.5V8.5l6.25 3.5-6.25 3.5Z"/>
      </svg>
    ),
  },
  {
    label: 'GitHub',
    handle: 'Simon-Urbina',
    href: 'https://github.com/Simon-Urbina',
    color: '#C8D5EE',
    svg: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 .5a12 12 0 0 0-3.79 23.39c.6.11.82-.26.82-.58v-2.04c-3.34.72-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.21.09 1.85 1.24 1.85 1.24 1.07 1.84 2.81 1.31 3.5 1 .11-.78.42-1.31.76-1.61-2.66-.3-5.46-1.33-5.46-5.93 0-1.31.47-2.38 1.24-3.22-.13-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 0 1 6.01 0c2.29-1.55 3.3-1.23 3.3-1.23.66 1.66.25 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.62-5.48 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0 0 12 .5"/>
      </svg>
    ),
  },
  {
    label: 'Instagram',
    handle: '@simon__urbina',
    href: 'https://www.instagram.com/simon__urbina/',
    color: '#c084fc',
    svg: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
      </svg>
    ),
  },
  {
    label: 'LinkedIn',
    handle: 'simon-urbina-martinez',
    href: 'https://www.linkedin.com/in/simon-urbina-martinez/',
    color: '#60a5fa',
    svg: (
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.95v5.66H9.36V9h3.41v1.56h.05c.47-.9 1.63-1.85 3.36-1.85 3.59 0 4.26 2.36 4.26 5.43v6.31ZM5.34 7.43a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12ZM7.12 20.45H3.56V9h3.56v11.45ZM22.23 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.46c.98 0 1.77-.77 1.77-1.72V1.72C24 .77 23.21 0 22.23 0Z"/>
      </svg>
    ),
  },
]

const CATEGORY_COLOR: Record<string, string> = {
  Frontend: '#2596be',
  Backend: '#1A3F96',
  Infra: '#F5C500',
  IA: '#a855f7',
}

export default function AboutPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

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
        {/* Grid */}
        {isDark && (
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              backgroundImage: `
                linear-gradient(rgba(26,63,150,0.06) 1px, transparent 1px),
                linear-gradient(90deg, rgba(26,63,150,0.06) 1px, transparent 1px)
              `,
              backgroundSize: '50px 50px',
              maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 80%)',
              WebkitMaskImage: 'radial-gradient(ellipse at center, black 30%, transparent 80%)',
            }}
          />
        )}

        <div className="relative max-w-7xl mx-auto px-6 lg:px-10 pt-20 pb-24 lg:pt-28 lg:pb-32">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

            {/* Text */}
            <div>
              <p className="font-mono text-xs tracking-[0.22em] uppercase mb-6 animate-fade-up-1"
                style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                // el creador de la plataforma
              </p>
              <div className="flex items-center gap-5 mb-6 animate-fade-up-2">
                <img
                  src="/media/simon_pic.jpg"
                  alt="Simón Urbina"
                  className="w-20 h-20 rounded-full object-cover shrink-0"
                  style={{
                    border: `2px solid ${isDark ? 'rgba(37,150,190,0.35)' : 'rgba(26,63,150,0.22)'}`,
                    boxShadow: isDark ? '0 0 24px rgba(37,150,190,0.22)' : '0 4px 16px rgba(10,21,69,0.10)',
                  }}
                />
                <h1
                  className="font-display"
                  style={{
                    fontSize: 'clamp(2.6rem, 5.5vw, 4.2rem)',
                    lineHeight: 1.05,
                    letterSpacing: '-0.015em',
                    color: isDark ? '#C8D5EE' : '#0A1545',
                  }}
                >
                  Simón<br />
                  <span style={{ color: '#1A3F96', textShadow: isDark ? '0 0 40px rgba(26,63,150,0.5)' : 'none' }}>
                    Urbina.
                  </span>
                </h1>
              </div>
              <p
                className="text-lg font-light max-w-lg mb-8 animate-fade-up-3"
                style={{ color: isDark ? '#7B9FE8' : '#2451C8', lineHeight: 1.7 }}
              >
                Estudiante de <strong style={{ color: isDark ? '#C8D5EE' : '#0A1545', fontWeight: 600 }}>Ingeniería de Sistemas</strong> en la Universidad Santo Tomás de Aquino, Tunja. Construyo software enfocado en seguridad, aprendizaje y sistemas inteligentes.
              </p>

              {/* Tags */}
              <div className="flex flex-wrap gap-2.5 mb-10 animate-fade-up-4">
                {['IA & Machine Learning', 'Ciberseguridad', 'Desarrollo Web'].map(tag => (
                  <span
                    key={tag}
                    className="font-mono text-[11px] tracking-[0.14em] px-3 py-1.5 rounded-lg"
                    style={{
                      color: isDark ? '#7B9FE8' : '#1A3F96',
                      background: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.07)',
                      border: `1px solid ${isDark ? 'rgba(26,63,150,0.25)' : 'rgba(26,63,150,0.18)'}`,
                    }}
                  >
                    {tag}
                  </span>
                ))}
              </div>

              {/* Social links */}
              <div className="flex flex-wrap gap-3 animate-fade-up-5">
                {SOCIAL.map(({ label, handle, href, color, svg }) => (
                  <a
                    key={label}
                    href={href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-2.5 px-4 py-2.5 rounded-xl transition-all duration-200"
                    style={{
                      background: isDark ? 'rgba(13,27,70,0.7)' : '#f8faff',
                      border: `1px solid ${isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.14)'}`,
                      textDecoration: 'none',
                      color: isDark ? '#7B9FE8' : '#1A3F96',
                    }}
                    onMouseEnter={e => {
                      const el = e.currentTarget as HTMLElement
                      el.style.borderColor = color
                      el.style.background = `${color}12`
                      el.style.color = color
                    }}
                    onMouseLeave={e => {
                      const el = e.currentTarget as HTMLElement
                      el.style.borderColor = isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.14)'
                      el.style.background = isDark ? 'rgba(13,27,70,0.7)' : '#f8faff'
                      el.style.color = isDark ? '#7B9FE8' : '#1A3F96'
                    }}
                  >
                    <span style={{ color: 'inherit' }}>{svg}</span>
                    <div>
                      <p className="font-mono text-[10px] tracking-[0.14em] uppercase leading-none mb-0.5" style={{ color: 'inherit', opacity: 0.7 }}>{label}</p>
                      <p className="font-mono text-[12px] leading-none" style={{ color: 'inherit' }}>{handle}</p>
                    </div>
                  </a>
                ))}
              </div>
            </div>

            {/* Terminal card */}
            <div className="animate-fade-up-3">
              <div
                className="hud-panel hud-static"
                style={{
                  background: 'rgba(6,13,31,0.95)',
                  boxShadow: '0 20px 60px rgba(0,0,0,0.4), 0 0 0 1px rgba(26,63,150,0.08)',
                  '--hud-border': 'rgba(26,63,150,0.35)',
                  '--hud-border-hover': 'rgba(26,63,150,0.35)',
                } as React.CSSProperties}
              >
                {/* Title bar */}
                <div className="flex items-center gap-2 px-5 py-3" style={{ borderBottom: '1px solid rgba(26,63,150,0.14)' }}>
                  <span className="w-3 h-3 rounded-full" style={{ background: '#ff5f57' }} />
                  <span className="w-3 h-3 rounded-full" style={{ background: '#2b2b2b' }} />
                  <span className="w-3 h-3 rounded-full" style={{ background: '#2b2b2b' }} />
                  <span className="flex-1 text-center font-mono text-[10px] tracking-[0.15em]" style={{ color: '#3A5AB8' }}>
                    simon@rutseg — whoami
                  </span>
                </div>
                {/* Content */}
                <div className="px-6 py-5 font-mono text-[13px] space-y-2 leading-6">
                  <p style={{ color: '#4ade80' }}>$ whoami</p>
                  <p style={{ color: '#C8D5EE' }}>simón_urbina</p>
                  <p style={{ color: '#4ade80' }}>$ cat perfil.txt</p>
                  {[
                    { key: 'nombre', value: 'Simón Jacobo Urbina Martínez' },
                    { key: 'rol', value: 'Estudiante / Desarrollador' },
                    { key: 'universidad', value: 'USTA — Tunja, Colombia' },
                    { key: 'carrera', value: 'Ing. de Sistemas' },
                    { key: 'intereses', value: 'IA · Ciberseguridad · Desarrollo' },
                    { key: 'proyecto', value: 'RutSeg (UCHIE)' },
                  ].map(({ key, value }) => (
                    <p key={key}>
                      <span style={{ color: '#2596be' }}>{key}</span>
                      <span style={{ color: '#3A5AB8' }}>: </span>
                      <span style={{ color: '#C8D5EE' }}>{value}</span>
                    </p>
                  ))}
                  <p style={{ color: '#4ade80' }}>$ <span className="cursor-blink" style={{ color: '#4ade80' }}>_</span></p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ─── INTERESES ─── */}
      <section className="border-t" style={{ borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)' }}>
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-20 lg:py-28">
          <div className="max-w-2xl mb-14">
            <p className="font-mono text-xs tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              // áreas de enfoque
            </p>
            <h2 className="font-display" style={{ fontSize: 'clamp(1.9rem, 3.5vw, 2.6rem)', lineHeight: 1.15, color: isDark ? '#C8D5EE' : '#0A1545' }}>
              Lo que me{' '}
              <span style={{ color: '#1A3F96' }}>apasiona</span>{' '}
              construir y aprender.
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {INTERESTS.map(({ title, body, icon, accent }) => (
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
                  className="w-12 h-12 rounded-xl flex items-center justify-center mb-6"
                  style={{ background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.03)', border: `1px solid ${accent}30`, color: accent }}
                >
                  {icon}
                </div>
                <h3 className="font-display mb-3" style={{ fontSize: '1.4rem', color: isDark ? '#EEF3FC' : '#0A1545' }}>
                  {title}
                </h3>
                <p className="text-[14px] font-light" style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.7 }}>
                  {body}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── POR QUÉ RUTSEG ─── */}
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
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
            <div>
              <p className="font-mono text-xs tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                // la historia detrás del proyecto
              </p>
              <h2 className="font-display mb-6" style={{ fontSize: 'clamp(1.9rem, 3.5vw, 2.6rem)', lineHeight: 1.15, color: isDark ? '#C8D5EE' : '#0A1545' }}>
                Por qué existe <br></br>
                <span style={{ color: '#2596be' }}>RutSeg</span>.
              </h2>
              <div className="space-y-4 text-[15px] font-light" style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.8 }}>
                <p>
                  Aprender ciberseguridad en Colombia es difícil. La mayoría de recursos son en inglés, costosos o puramente teóricos. Los estudiantes terminan viendo diapositivas sobre conceptos que nunca ponen en práctica.
                </p>
                <p>
                  RutSeg nació como proyecto del semillero de investigación en USTA Tunja para cambiar eso: una plataforma en español, gratuita, basada en <strong style={{ color: isDark ? '#C8D5EE' : '#0A1545', fontWeight: 600 }}>laboratorios prácticos reales</strong> donde aprendes haciendo, no leyendo.
                </p>
                <p>
                  Cada lab está diseñado para enseñar algo concreto que puedas aplicar. Sin relleno, sin teoría plana. Solo terminales, problemas, y el progreso que acumulas al resolverlos.
                </p>
              </div>

              {/* Docente */}
              <div
                className="hud-panel hud-static mt-8 p-6 flex items-start gap-4"
                style={{
                  background: isDark ? 'rgba(37,150,190,0.07)' : 'rgba(37,150,190,0.06)',
                  '--hud-border': isDark ? 'rgba(37,150,190,0.35)' : 'rgba(37,150,190,0.30)',
                  '--hud-border-hover': isDark ? 'rgba(37,150,190,0.35)' : 'rgba(37,150,190,0.30)',
                } as React.CSSProperties}
              >
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                  style={{ background: isDark ? 'rgba(37,150,190,0.15)' : 'rgba(37,150,190,0.10)', color: '#2596be' }}
                >
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
                    <path d="M6 12v5c3 3 9 3 12 0v-5"/>
                  </svg>
                </div>
                <div>
                  <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1.5" style={{ color: '#2596be' }}>
                    // iniciativa y dirección académica
                  </p>
                  <p className="font-semibold text-[15px] mb-0.5" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    Harrizon Alexander Soler Galindo
                  </p>
                  <p className="text-[13px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
                    Docente — Universidad Santo Tomás, Tunja<br />
                    Semillero de Investigación en Ciberseguridad y Desarrollo de Software
                  </p>
                </div>
              </div>
            </div>

            {/* Stack */}
            <div>
              <p className="font-mono text-xs tracking-[0.22em] uppercase mb-6" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                // construido con
              </p>
              <div className="flex flex-wrap gap-2.5">
                {STACK.map(({ name, category }) => {
                  const color = CATEGORY_COLOR[category]
                  return (
                    <div
                      key={name}
                      className="flex items-center gap-2 px-3.5 py-2 rounded-xl"
                      style={{
                        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                        border: `1px solid ${isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.14)'}`,
                      }}
                    >
                      <span className="w-1.5 h-1.5 rounded-full shrink-0" style={{ background: color }} />
                      <span className="font-mono text-[12px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>{name}</span>
                      <span className="font-mono text-[10px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>{category}</span>
                    </div>
                  )
                })}
              </div>

              {/* University card */}
              <div
                className="hud-panel hud-static mt-8 p-6"
                style={{
                  background: isDark ? 'rgba(13,27,70,0.55)' : '#f0f4ff',
                  '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
                  '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
                } as React.CSSProperties}
              >
                <p className="font-mono text-[10px] tracking-[0.2em] uppercase mb-3" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                  // institución
                </p>
                <p className="font-display text-xl mb-1" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  Universidad Santo Tomás
                </p>
                <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
                  Ingeniería de Sistemas — Tunja, Boyacá, Colombia
                </p>
                <p className="font-mono text-[11px] mt-3" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                  Semillero de Investigación · Ciberseguridad y Desarrollo de Software
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ─── CONTACTO ─── */}
      <section
        className="border-t"
        style={{ borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)' }}
      >
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-20 lg:py-28">
          <div className="max-w-2xl mb-14">
            <p className="font-mono text-xs tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              // contacto
            </p>
            <h2 className="font-display mb-4" style={{ fontSize: 'clamp(1.9rem, 3.5vw, 2.6rem)', lineHeight: 1.15, color: isDark ? '#C8D5EE' : '#0A1545' }}>
              ¿Tienes alguna{' '}
              <span style={{ color: '#2596be' }}>pregunta</span>?
            </h2>
            <p className="text-[15px] font-light" style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.7 }}>
              Si quieres colaborar, reportar un problema, proponer contenido o simplemente saludar, aquí están los canales directos.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {/* Email */}
            <a
              href="mailto:jacobitourbinalol@gmail.com"
              className="hud-panel p-7 flex flex-col gap-4"
              style={{
                background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                textDecoration: 'none',
                '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                '--hud-border-hover': 'rgba(37,150,190,0.75)',
                '--hud-focus': '#2596be',
              } as React.CSSProperties}
            >
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center"
                style={{ background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.03)', border: '1px solid rgba(37,150,190,0.30)', color: '#2596be' }}
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                  <polyline points="22,6 12,13 2,6"/>
                </svg>
              </div>
              <div>
                <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1.5" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                  // correo directo
                </p>
                <p className="font-mono text-[13px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  jacobitourbinalol@gmail.com
                </p>
              </div>
            </a>

            {/* GitHub Issues */}
            <a
              href="https://github.com/Simon-Urbina"
              target="_blank"
              rel="noopener noreferrer"
              className="hud-panel p-7 flex flex-col gap-4"
              style={{
                background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                textDecoration: 'none',
                '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                '--hud-border-hover': isDark ? 'rgba(200,213,238,0.55)' : 'rgba(10,21,69,0.55)',
                '--hud-focus': isDark ? '#C8D5EE' : '#0A1545',
              } as React.CSSProperties}
            >
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center"
                style={{ background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.03)', border: '1px solid rgba(200,213,238,0.20)', color: isDark ? '#C8D5EE' : '#0A1545' }}
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M12 .5a12 12 0 0 0-3.79 23.39c.6.11.82-.26.82-.58v-2.04c-3.34.72-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.21.09 1.85 1.24 1.85 1.24 1.07 1.84 2.81 1.31 3.5 1 .11-.78.42-1.31.76-1.61-2.66-.3-5.46-1.33-5.46-5.93 0-1.31.47-2.38 1.24-3.22-.13-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 0 1 6.01 0c2.29-1.55 3.3-1.23 3.3-1.23.66 1.66.25 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.62-5.48 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0 0 12 .5"/>
                </svg>
              </div>
              <div>
                <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1.5" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                  // reportar un bug
                </p>
                <p className="font-mono text-[13px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  github.com/Simon-Urbina/rutseg
                </p>
              </div>
            </a>

            {/* LinkedIn */}
            <a
              href="https://www.linkedin.com/in/simon-urbina-martinez/"
              target="_blank"
              rel="noopener noreferrer"
              className="hud-panel p-7 flex flex-col gap-4"
              style={{
                background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                textDecoration: 'none',
                '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                '--hud-border-hover': 'rgba(96,165,250,0.65)',
                '--hud-focus': '#60a5fa',
              } as React.CSSProperties}
            >
              <div
                className="w-12 h-12 rounded-xl flex items-center justify-center"
                style={{ background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.03)', border: '1px solid rgba(96,165,250,0.25)', color: '#60a5fa' }}
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.95v5.66H9.36V9h3.41v1.56h.05c.47-.9 1.63-1.85 3.36-1.85 3.59 0 4.26 2.36 4.26 5.43v6.31ZM5.34 7.43a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12ZM7.12 20.45H3.56V9h3.56v11.45ZM22.23 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.46c.98 0 1.77-.77 1.77-1.72V1.72C24 .77 23.21 0 22.23 0Z"/>
                </svg>
              </div>
              <div>
                <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1.5" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                  // linkedin
                </p>
                <p className="font-mono text-[13px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  simon-urbina-martinez
                </p>
              </div>
            </a>
          </div>
        </div>
      </section>

      <Footer />
    </div>
  )
}
