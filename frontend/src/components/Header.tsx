import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { LogoWordmark } from './Logo'
import ThemeToggle from './ThemeToggle'

function AvatarCircle({ avatarImage, isDark, size = 28 }: { avatarImage: string | null; isDark: boolean; size?: number }) {
  return (
    <div
      className="shrink-0 overflow-hidden flex items-center justify-center rounded-full"
      style={{
        width: size,
        height: size,
        background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
        border: `1px solid ${isDark ? 'rgba(26,63,150,0.35)' : 'rgba(26,63,150,0.25)'}`,
      }}
    >
      {avatarImage ? (
        <img src={avatarImage} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      ) : (
        <svg width={size * 0.55} height={size * 0.55} viewBox="0 0 24 24" fill="none"
          stroke={isDark ? '#7B9FE8' : '#1A3F96'} strokeWidth="1.75" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="8" r="4" />
          <path d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8" />
        </svg>
      )}
    </div>
  )
}

export default function Header() {
  const { theme } = useTheme()
  const { user, avatarImage, logout } = useAuth()
  const navigate = useNavigate()
  const [menuOpen, setMenuOpen] = useState(false)
  const isDark = theme === 'dark'

  const handleLogout = () => {
    logout()
    navigate('/login')
    setMenuOpen(false)
  }

  const pillBg = isDark ? 'rgba(6,13,31,0.75)' : 'rgba(238,243,252,0.85)'
  const pillBorder = isDark ? 'rgba(26,63,150,0.25)' : 'rgba(26,63,150,0.18)'

  return (
    <header className="sticky top-4 z-50 w-full px-4">
      {/* Píldora flotante */}
      <div
        className="max-w-6xl mx-auto flex items-center justify-between h-16 rounded-full border backdrop-blur-xl px-4 sm:px-6 transition-colors duration-300"
        style={{
          background: pillBg,
          borderColor: pillBorder,
          boxShadow: isDark ? '0 8px 32px rgba(0,0,0,0.45)' : '0 8px 24px rgba(26,63,150,0.10)',
        }}
      >
        {/* Logo */}
        <Link
          to="/"
          className="shrink-0 transition-transform duration-300 hover:scale-[1.02] active:scale-95 flex items-center gap-2"
        >
          <LogoWordmark isDark={isDark} />
        </Link>

        {/* Desktop Navigation */}
        <div className="hidden md:flex items-center gap-7">
          <Link
            to="/forum"
            className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
              isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
            }`}
          >
            Foro
          </Link>

          {user?.role === 'admin' && (
            <Link
              to="/admin"
              className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
                isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
              }`}
            >
              Admin
            </Link>
          )}

          <ThemeToggle />

          {user ? (
            <div className="flex items-center gap-4">
              <div
                className="flex items-center gap-2 rounded-full border pl-1.5 pr-3.5 py-1"
                style={{
                  background: isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.05)',
                  borderColor: isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.20)',
                }}
              >
                <AvatarCircle avatarImage={avatarImage} isDark={isDark} />
                <span
                  className="font-mono text-[13px] font-semibold"
                  style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
                >
                  {user.username}
                </span>
              </div>

              <button
                onClick={handleLogout}
                className={`text-[14px] font-medium transition-colors ${
                  isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
                }`}
              >
                Salir
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-4">
              <Link
                to="/login"
                className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
                  isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
                }`}
              >
                Iniciar sesión
              </Link>

              <Link
                to="/register"
                className="btn-neon text-[14px] px-5 py-2.5 font-semibold"
                style={{ borderRadius: '9999px' }}
              >
                Registrarse
              </Link>
            </div>
          )}
        </div>

        {/* Mobile Controls */}
        <div className="flex md:hidden items-center gap-3">
          <ThemeToggle />
          <button
            onClick={() => setMenuOpen(o => !o)}
            aria-label="Menú"
            className={`relative w-10 h-10 flex flex-col items-center justify-center gap-[5px] rounded-full transition-all active:scale-95 border ${
              isDark
                ? 'text-violet-300 bg-white/5 border-white/10'
                : 'text-rosewood-700 bg-black/5 border-rosewood-500/20'
            }`}
          >
            <span
              className={`block w-5 h-[2px] bg-current transition-all duration-300 origin-center rounded-full ${menuOpen ? 'rotate-45 translate-y-[7px]' : ''}`}
            />
            <span
              className={`block w-5 h-[2px] bg-current transition-all duration-300 rounded-full ${menuOpen ? 'opacity-0 scale-x-0' : 'opacity-100 scale-x-100'}`}
            />
            <span
              className={`block w-5 h-[2px] bg-current transition-all duration-300 origin-center rounded-full ${menuOpen ? '-rotate-45 -translate-y-[7px]' : ''}`}
            />
          </button>
        </div>
      </div>

      {/* Mobile Dropdown Drawer — píldora propia, flotando debajo de la barra */}
      <div
        className={`md:hidden max-w-6xl mx-auto overflow-hidden transition-all duration-300 ease-in-out ${
          menuOpen ? 'max-h-[320px] opacity-100 mt-2' : 'max-h-0 opacity-0 mt-0'
        }`}
      >
        <div
          className="px-6 py-5 space-y-3 rounded-3xl border backdrop-blur-xl"
          style={{ background: pillBg, borderColor: pillBorder }}
        >
          {user ? (
            <div className="flex flex-col gap-3">
              <div
                className="w-full flex items-center justify-center gap-2 font-mono text-[13px] px-4 py-2 rounded-full border"
                style={{
                  background: isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.05)',
                  borderColor: isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.20)',
                  color: isDark ? '#7B9FE8' : '#1A3F96',
                }}
              >
                <AvatarCircle avatarImage={avatarImage} isDark={isDark} />
                {user.username}
              </div>
              <Link
                to="/forum"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-2.5 rounded-full text-[14px] font-medium transition-all ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              {user.role === 'admin' && (
                <Link
                  to="/admin"
                  onClick={() => setMenuOpen(false)}
                  className={`block w-full text-center px-4 py-2.5 rounded-full text-[14px] font-medium transition-all ${
                    isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                  }`}
                >
                  Admin
                </Link>
              )}
              <button
                onClick={handleLogout}
                className={`w-full px-4 py-2.5 text-[14px] font-medium rounded-full ${
                  isDark ? 'text-violet-300 bg-white/5' : 'text-rosewood-700 bg-black/5'
                }`}
              >
                Cerrar sesión
              </button>
            </div>
          ) : (
            <div className="flex flex-col gap-2.5">
              <Link
                to="/forum"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-2.5 rounded-full text-[14px] font-medium ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              <Link
                to="/login"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-2.5 rounded-full text-[14px] font-medium ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Iniciar sesión
              </Link>
              <Link
                to="/register"
                onClick={() => setMenuOpen(false)}
                className="btn-neon block w-full text-center text-[14px] py-2.5"
                style={{ borderRadius: '9999px' }}
              >
                Registrarse
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}
