import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { LogoWordmark } from './Logo'
import ThemeToggle from './ThemeToggle'

export default function Header() {
  const { theme } = useTheme()
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [menuOpen, setMenuOpen] = useState(false)
  const isDark = theme === 'dark'

  const handleLogout = () => {
    logout()
    navigate('/login')
    setMenuOpen(false)
  }

  return (
    <header
      className={`sticky top-0 z-50 w-full transition-all duration-300 backdrop-blur-xl border-b ${
        isDark 
          ? 'bg-violet-950/85 border-rosewood-500/10 shadow-[0_4px_30px_rgba(0,0,0,0.5)]' 
          : 'bg-violet-50/90 border-rosewood-500/10 shadow-sm'
      }`}
    >
      {/* Neon accent line (usando tus colores del theme) */}
      <div className="absolute bottom-0 left-0 right-0 h-[1.5px] bg-gradient-to-r from-transparent via-rosewood-500 to-teal-500 opacity-50 pointer-events-none" />

      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div className="flex items-center justify-between h-[76px]">

          {/* Logo */}
          <Link
            to="/"
            className="shrink-0 transition-transform duration-300 hover:scale-105 active:scale-95"
          >
            <LogoWordmark isDark={isDark} />
          </Link>

          {/* Desktop nav */}
          <div className="hidden md:flex items-center gap-8">
            <Link
              to="/forum"
              className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
                isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
              }`}
            >
              Foro
            </Link>
            <ThemeToggle />

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

            {user ? (
              <div className="flex items-center gap-6 animate-fade-up-1">
                {/* User Pill */}
                <div
                  className={`flex items-center gap-2 font-mono text-[13px] px-4 py-1.5 rounded-full border shadow-sm ${
                    isDark 
                      ? 'text-rosewood-400 bg-rosewood-500/10 border-rosewood-500/20' 
                      : 'text-rosewood-600 bg-rosewood-500/5 border-rosewood-500/20'
                  }`}
                >
                  <span className="opacity-70 cursor-blink">~/</span>
                  <span className="font-semibold">{user.username}</span>
                </div>

                <button
                  onClick={handleLogout}
                  className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
                    isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
                  }`}
                >
                  Salir
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-7 animate-fade-up-1">
                {/* Usando TU clase .nav-link que ya tiene la animación de la línea */}
                <Link
                  to="/login"
                  className={`nav-link text-[14px] tracking-wide font-medium transition-colors ${
                    isDark ? 'text-violet-300 hover:text-rosewood-400' : 'text-rosewood-700 hover:text-rosewood-500'
                  }`}
                >
                  Iniciar sesión
                </Link>

                {/* Usando TU clase .btn-neon */}
                <Link
                  to="/register"
                  className="btn-neon text-[14px] tracking-wide px-6 py-2.5 rounded-xl"
                >
                  Registrarse
                </Link>
              </div>
            )}
          </div>

          {/* Mobile controls */}
          <div className="flex md:hidden items-center gap-4">
            <ThemeToggle />
            <button
              onClick={() => setMenuOpen(o => !o)}
              aria-label="Menú"
              className={`relative w-10 h-10 flex flex-col items-center justify-center gap-[5px] rounded-full transition-colors active:scale-95 ${
                isDark ? 'text-violet-300 bg-white/5' : 'text-rosewood-700 bg-black/5'
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
      </div>

      {/* Mobile menu dropdown */}
      <div
        className={`md:hidden overflow-hidden transition-all duration-300 ease-in-out ${
          menuOpen ? 'max-h-[260px] opacity-100' : 'max-h-0 opacity-0'
        }`}
      >
        <div
          className={`px-6 pb-6 pt-4 space-y-4 shadow-inner border-t ${
            isDark 
              ? 'glass-card-violet border-rosewood-500/10' 
              : 'bg-violet-50/98 border-rosewood-500/10 backdrop-blur-md'
          }`}
        >
          {user ? (
            <div className="flex flex-col items-center gap-4 pt-2">
              <div
                className={`w-full text-center font-mono text-[13px] px-4 py-2.5 rounded-lg border ${
                  isDark ? 'text-rosewood-400 bg-rosewood-500/10 border-rosewood-500/20' : 'text-rosewood-600 bg-rosewood-500/5 border-rosewood-500/20'
                }`}
              >
                <span className="opacity-70 cursor-blink">~/</span>{user.username}
              </div>
              <Link
                to="/forum"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-3 rounded-xl text-[15px] font-medium tracking-wide transition-all duration-300 border ${
                  isDark
                    ? 'text-violet-300 border-violet-300/20 hover:bg-white/5'
                    : 'text-rosewood-700 border-rosewood-700/20 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              {user.role === 'admin' && (
                <Link
                  to="/admin"
                  onClick={() => setMenuOpen(false)}
                  className={`block w-full text-center px-4 py-3 rounded-xl text-[15px] font-medium tracking-wide transition-all duration-300 border ${
                    isDark
                      ? 'text-violet-300 border-violet-300/20 hover:bg-white/5'
                      : 'text-rosewood-700 border-rosewood-700/20 hover:bg-black/5'
                  }`}
                >
                  Admin
                </Link>
              )}
              <button
                onClick={handleLogout}
                className={`w-full px-4 py-3 text-[15px] font-medium tracking-wide transition-colors rounded-xl ${
                  isDark ? 'text-violet-300 bg-white/5' : 'text-rosewood-700 bg-black/5'
                }`}
              >
                Cerrar sesión
              </button>
            </div>
          ) : (
            <div className="flex flex-col gap-3 pt-2">
              <Link
                to="/forum"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-3 rounded-xl text-[15px] font-medium tracking-wide transition-all duration-300 border ${
                  isDark
                    ? 'text-violet-300 border-violet-300/20 hover:bg-white/5'
                    : 'text-rosewood-700 border-rosewood-700/20 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              <Link
                to="/login"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-3 rounded-xl text-[15px] font-medium tracking-wide transition-all duration-300 border ${
                  isDark
                    ? 'text-violet-300 border-violet-300/20 hover:bg-white/5'
                    : 'text-rosewood-700 border-rosewood-700/20 hover:bg-black/5'
                }`}
              >
                Iniciar sesión
              </Link>
              <Link
                to="/register"
                onClick={() => setMenuOpen(false)}
                className="btn-neon block w-full text-center px-4 py-3 rounded-xl text-[15px] tracking-wide"
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