import { useNavigate } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { PageShell } from './AdminCourseDetailPage'

function IconBook() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
      <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
    </svg>
  )
}

function IconUsers() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  )
}

const CARDS = [
  {
    to: '/admin/courses',
    title: 'Cursos y contenido',
    description: 'Cursos, módulos, laboratorios y preguntas de los quizzes.',
    icon: <IconBook />,
  },
  {
    to: '/admin/users',
    title: 'Usuarios',
    description: 'Datos de cuenta, rol y contraseña de los usuarios registrados.',
    icon: <IconUsers />,
  },
]

export default function AdminDashboardPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()

  return (
    <PageShell isDark={isDark}>
      <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
        // panel de administración
      </p>
      <h1 className="font-display mb-8" style={{ fontSize: 'clamp(1.8rem, 3vw, 2.4rem)', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        ¿Qué quieres administrar?
      </h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {CARDS.map(card => (
          <button
            key={card.to}
            onClick={() => navigate(card.to)}
            className="hud-panel flex flex-col items-start gap-4 p-8 text-left"
            style={{
              background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
              '--hud-border-hover': '#1A3F96',
              '--hud-focus': '#2596be',
            } as React.CSSProperties}
          >
            <div
              className="flex items-center justify-center w-12 h-12 rounded-xl"
              style={{ background: isDark ? 'rgba(37,150,190,0.12)' : 'rgba(26,63,150,0.08)', color: isDark ? '#7B9FE8' : '#1A3F96' }}
            >
              {card.icon}
            </div>
            <div>
              <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                {card.title}
              </h2>
              <p className="text-[14px] mt-1" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
                {card.description}
              </p>
            </div>
          </button>
        ))}
      </div>
    </PageShell>
  )
}
