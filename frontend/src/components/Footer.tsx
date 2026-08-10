import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { LogoIcon } from './Logo'
import { Boop } from './Boop'

const FOOTER_COLUMNS = [
  {
    label: 'Plataforma',
    links: [
      { label: 'Cursos', to: '/dashboard' },
      { label: 'Dashboard', to: '/dashboard' },
      { label: 'Foro', to: '/forum' },
    ],
  },
  {
    label: 'Comunidad',
    links: [
      { label: 'Política de privacidad', to: '/privacy-policy' },
      { label: 'Términos de uso', to: '/terms-of-use' },
      { label: 'Acerca de', to: '/about' },
    ],
  },
  {
    label: 'Universidad',
    links: [
      { label: 'Santoto Tunja', to: 'https://santototunja.edu.co/', external: true },
      { label: 'Ing. de Sistemas', to: 'https://santototunja.edu.co/pregrados/ingenieria-de-sistemas', external: true },
    ],
  },
]

const SOCIAL = [
  {
    label: 'GitHub',
    href: 'https://github.com/Simon-Urbina',
    svg: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M12 .5a12 12 0 0 0-3.79 23.39c.6.11.82-.26.82-.58v-2.04c-3.34.72-4.04-1.61-4.04-1.61-.55-1.39-1.34-1.76-1.34-1.76-1.09-.74.08-.73.08-.73 1.21.09 1.85 1.24 1.85 1.24 1.07 1.84 2.81 1.31 3.5 1 .11-.78.42-1.31.76-1.61-2.66-.3-5.46-1.33-5.46-5.93 0-1.31.47-2.38 1.24-3.22-.13-.3-.54-1.52.12-3.18 0 0 1.01-.32 3.3 1.23a11.5 11.5 0 0 1 6.01 0c2.29-1.55 3.3-1.23 3.3-1.23.66 1.66.25 2.88.12 3.18.77.84 1.24 1.91 1.24 3.22 0 4.61-2.81 5.62-5.48 5.92.43.37.81 1.1.81 2.22v3.29c0 .32.22.7.83.58A12 12 0 0 0 12 .5"/>
      </svg>
    ),
  },
  {
    label: 'Instagram',
    href: 'https://www.instagram.com/simon__urbina/',
    svg: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
      </svg>
    ),
  },
  {
    label: 'LinkedIn',
    href: 'https://www.linkedin.com/in/simon-urbina-martinez/',
    svg: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.85-3.04-1.86 0-2.14 1.45-2.14 2.95v5.66H9.36V9h3.41v1.56h.05c.47-.9 1.63-1.85 3.36-1.85 3.59 0 4.26 2.36 4.26 5.43v6.31ZM5.34 7.43a2.06 2.06 0 1 1 0-4.12 2.06 2.06 0 0 1 0 4.12ZM7.12 20.45H3.56V9h3.56v11.45ZM22.23 0H1.77C.79 0 0 .77 0 1.72v20.56C0 23.23.79 24 1.77 24h20.46c.98 0 1.77-.77 1.77-1.72V1.72C24 .77 23.21 0 22.23 0Z"/>
      </svg>
    ),
  },
  {
    label: 'YouTube',
    href: 'https://www.youtube.com/@simon__urbina',
    svg: (
      <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
        <path d="M23.5 6.19a3.02 3.02 0 0 0-2.12-2.14C19.54 3.5 12 3.5 12 3.5s-7.54 0-9.38.55A3.02 3.02 0 0 0 .5 6.19C0 8.04 0 12 0 12s0 3.96.5 5.81a3.02 3.02 0 0 0 2.12 2.14C4.46 20.5 12 20.5 12 20.5s7.54 0 9.38-.55a3.02 3.02 0 0 0 2.12-2.14C24 15.96 24 12 24 12s0-3.96-.5-5.81ZM9.75 15.5V8.5l6.25 3.5-6.25 3.5Z"/>
      </svg>
    ),
  },
]

export default function Footer() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  return (
    <footer
      className="relative border-t"
      style={{
        background: isDark ? '#060D1F' : '#E8EEFA',
        borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)',
      }}
    >
      <div className="max-w-7xl mx-auto px-6 lg:px-10 pt-14 pb-10">
        <div className="grid grid-cols-1 md:grid-cols-12 gap-10 mb-12">

          {/* Brand block */}
          <div className="md:col-span-5">
            <Link to="/" className="flex items-center gap-3 mb-4 w-fit">
              <Boop rotation={12} scale={1.12}>
                <LogoIcon className="w-9 h-9" />
              </Boop>
              <div>
                <p
                  className="font-display text-[18px] leading-none font-bold"
                  style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
                >
                  RutSeg
                </p>
                <p
                  className="font-mono text-[9px] tracking-[0.22em] uppercase mt-1 font-semibold"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  RUTA · SEGURA
                </p>
              </div>
            </Link>

            <p
              className="text-[14px] font-light max-w-sm leading-relaxed mb-6"
              style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
            >
              La plataforma institucional de laboratorios prácticos en ciberseguridad.
            </p>

            {/* Social */}
            <div className="flex items-center gap-2.5">
              {SOCIAL.map(({ label, href, svg }) => (
                <a
                  key={label}
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label={label}
                  className="w-9 h-9 rounded-lg flex items-center justify-center transition-all duration-200"
                  style={{
                    color: isDark ? '#7B9FE8' : '#1A3F96',
                    border: `1px solid ${isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.22)'}`,
                  }}
                  onMouseEnter={e => {
                    const el = e.currentTarget as HTMLElement
                    el.style.background = 'rgba(26,63,150,0.10)'
                    el.style.color = '#2596be'
                  }}
                  onMouseLeave={e => {
                    const el = e.currentTarget as HTMLElement
                    el.style.background = 'transparent'
                    el.style.color = isDark ? '#7B9FE8' : '#1A3F96'
                  }}
                >
                  {svg}
                </a>
              ))}
            </div>
          </div>

          {/* Link columns */}
          <div className="md:col-span-7 grid grid-cols-2 sm:grid-cols-3 gap-8">
            {FOOTER_COLUMNS.map(({ label, links }) => (
              <div key={label}>
                <p
                  className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4 font-semibold"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  // {label.toLowerCase()}
                </p>
                <ul className="space-y-2.5">
                  {links.map(link => (
                    <li key={link.label}>
                      {'external' in link && link.external ? (
                        <a
                          href={link.to}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="nav-link text-[14px] inline-block transition-colors"
                          style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
                        >
                          {link.label}
                        </a>
                      ) : (
                        <Link
                          to={link.to}
                          className="nav-link text-[14px] inline-block transition-colors"
                          style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
                        >
                          {link.label}
                        </Link>
                      )}
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom row */}
        <div
          className="pt-6 border-t flex flex-wrap items-center justify-between gap-4 font-mono text-[10px] tracking-[0.2em] uppercase"
          style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)', color: isDark ? '#3A5AB8' : '#1A3F96' }}
        >
          <p>RutSeg © 2026 — Simón Jacobo Urbina Martínez</p>
          <span
            className="px-2.5 py-1 rounded"
            style={{
              color: '#2596be',
              background: 'rgba(37,150,190,0.08)',
              border: '1px solid rgba(37,150,190,0.20)',
            }}
          >
            V.UCHIE-1.0 ACADEMIC
          </span>
        </div>
      </div>
    </footer>
  )
}
