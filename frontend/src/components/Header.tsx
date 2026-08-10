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
          ? 'bg-[#060D1F]/90 border-rosewood-500/15 shadow-[0_4px_30px_rgba(0,0,0,0.5)]' 
          : 'bg-[#EEF3FC]/95 border-rosewood-500/12 shadow-xs'
      }`}
    >
      <div className="max-w-7xl mx-auto px-6 lg:px-10">
        <div className="flex items-center justify-between h-[72px]">
          
          {/* Logo */}
          <Link
            to="/"
            className="shrink-0 transition-transform duration-300 hover:scale-[1.02] active:scale-95 flex items-center gap-2"
          >
            <LogoWordmark isDark={isDark} />
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-8">
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
              <div className="flex items-center gap-5">
                {/* User Status Pill */}
                <div
                  className={`flex items-center gap-2 font-mono text-[13px] px-3.5 py-1.5 rounded-full border ${
                    isDark 
                      ? 'text-rosewood-400 bg-rosewood-500/10 border-rosewood-500/20' 
                      : 'text-rosewood-700 bg-rosewood-500/5 border-rosewood-500/20'
                  }`}
                >
                  <span className="opacity-70 cursor-blink">~/</span>
                  <span className="font-semibold">{user.username}</span>
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
              <div className="flex items-center gap-5">
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
                  className="btn-neon text-[14px] px-5 py-2.5 rounded-xl font-semibold"
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
              className={`relative w-10 h-10 flex flex-col items-center justify-center gap-[5px] rounded-xl transition-all active:scale-95 border ${
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
      </div>

      {/* Mobile Dropdown Drawer */}
      <div
        className={`md:hidden overflow-hidden transition-all duration-300 ease-in-out ${
          menuOpen ? 'max-h-[280px] opacity-100' : 'max-h-0 opacity-0'
        }`}
      >
        <div
          className={`px-6 pb-6 pt-4 space-y-3 shadow-inner border-t ${
            isDark 
              ? 'bg-[#0D1630] border-rosewood-500/20' 
              : 'bg-[#EEF3FC] border-rosewood-500/20'
          }`}
        >
          {user ? (
            <div className="flex flex-col gap-3">
              <div
                className={`w-full text-center font-mono text-[13px] px-4 py-2 rounded-lg border ${
                  isDark ? 'text-rosewood-400 bg-rosewood-500/10 border-rosewood-500/20' : 'text-rosewood-600 bg-rosewood-500/5 border-rosewood-500/20'
                }`}
              >
                <span className="opacity-70 cursor-blink">~/</span>{user.username}
              </div>
              <Link
                to="/forum"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              {user.role === 'admin' && (
                <Link
                  to="/admin"
                  onClick={() => setMenuOpen(false)}
                  className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                    isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                  }`}
                >
                  Admin
                </Link>
              )}
              <button
                onClick={handleLogout}
                className={`w-full px-4 py-2.5 text-[14px] font-medium rounded-xl ${
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
                className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Foro
              </Link>
              <Link
                to="/login"
                onClick={() => setMenuOpen(false)}
                className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium ${
                  isDark ? 'text-violet-300 hover:bg-white/5' : 'text-rosewood-700 hover:bg-black/5'
                }`}
              >
                Iniciar sesión
              </Link>
              <Link
                to="/register"
                onClick={() => setMenuOpen(false)}
                className="btn-neon block w-full text-center text-[14px] py-2.5 rounded-xl"
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