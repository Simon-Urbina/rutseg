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
    <header className="sticky top-0 z-50 w-full px-4 sm:px-6 pt-3 pb-2 transition-all duration-300 pointer-events-none">
      <div className="max-w-7xl mx-auto pointer-events-auto">
        <div className="glass-dock rounded-2xl sm:rounded-3xl px-5 sm:px-8 py-3 flex items-center justify-between transition-all duration-300">
          
          {/* Logo */}
          <Link
            to="/"
            className="shrink-0 transition-transform duration-300 hover:scale-105 active:scale-95 flex items-center gap-2"
          >
            <LogoWordmark isDark={isDark} />
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-6 lg:gap-8">
            <Link
              to="/forum"
              className={`nav-link text-[14px] tracking-tight font-medium transition-all ${
                isDark ? 'text-violet-200 hover:text-white' : 'text-slate-700 hover:text-rosewood-600'
              }`}
            >
              Foro
            </Link>

            {user?.role === 'admin' && (
              <Link
                to="/admin"
                className={`nav-link text-[14px] tracking-tight font-medium transition-all ${
                  isDark ? 'text-violet-200 hover:text-white' : 'text-slate-700 hover:text-rosewood-600'
                }`}
              >
                Admin
              </Link>
            )}

            <div className="h-4 w-px bg-white/10 dark:bg-white/10 bg-slate-300" />

            <ThemeToggle />

            {user ? (
              <div className="flex items-center gap-4 animate-fade-up-1">
                {/* User Status Pill with Watermelon Pulse */}
                <div
                  className={`flex items-center gap-2.5 font-mono text-[13px] px-3.5 py-1.5 rounded-full border transition-all ${
                    isDark
                      ? 'text-teal-300 bg-teal-500/10 border-teal-500/20 shadow-[0_0_15px_rgba(37,150,190,0.15)]'
                      : 'text-rosewood-700 bg-rosewood-50 border-rosewood-200 shadow-sm'
                  }`}
                >
                  <span className="relative flex h-2 w-2">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                  </span>
                  <span className="opacity-60 cursor-blink">~/</span>
                  <span className="font-semibold tracking-tight">{user.username}</span>
                </div>

                <button
                  onClick={handleLogout}
                  className={`text-[13px] tracking-tight font-medium px-3.5 py-1.5 rounded-xl border transition-all ${
                    isDark
                      ? 'text-violet-300 border-white/10 hover:bg-white/10 hover:text-white'
                      : 'text-slate-600 border-slate-200 hover:bg-slate-100 hover:text-slate-900'
                  }`}
                >
                  Salir
                </button>
              </div>
            ) : (
              <div className="flex items-center gap-4 animate-fade-up-1">
                <Link
                  to="/login"
                  className={`text-[14px] font-medium px-4 py-2 rounded-xl transition-all ${
                    isDark ? 'text-violet-200 hover:text-white hover:bg-white/5' : 'text-slate-700 hover:text-slate-900 hover:bg-slate-100'
                  }`}
                >
                  Iniciar sesión
                </Link>

                <Link
                  to="/register"
                  className="btn-wm-primary text-[14px] !py-2.5 !px-5"
                >
                  Empezar gratis
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
                  ? 'text-violet-200 bg-white/5 border-white/10'
                  : 'text-slate-700 bg-slate-100 border-slate-200'
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

        {/* Mobile Dropdown Drawer */}
        <div
          className={`md:hidden overflow-hidden transition-all duration-300 ease-in-out ${
            menuOpen ? 'max-h-[300px] opacity-100 mt-2' : 'max-h-0 opacity-0 mt-0'
          }`}
        >
          <div
            className={`p-5 rounded-2xl space-y-3 glass-dock border ${
              isDark ? 'border-white/10' : 'border-slate-200'
            }`}
          >
            {user ? (
              <div className="flex flex-col gap-3">
                <div
                  className={`w-full flex items-center justify-center gap-2 font-mono text-[13px] px-4 py-2.5 rounded-xl border ${
                    isDark ? 'text-teal-300 bg-teal-500/10 border-teal-500/20' : 'text-rosewood-700 bg-rosewood-50 border-rosewood-200'
                  }`}
                >
                  <span className="relative flex h-2 w-2">
                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                    <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                  </span>
                  <span className="opacity-70 cursor-blink">~/</span>{user.username}
                </div>
                <Link
                  to="/forum"
                  onClick={() => setMenuOpen(false)}
                  className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                    isDark ? 'text-violet-200 hover:bg-white/5' : 'text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  Foro
                </Link>
                {user.role === 'admin' && (
                  <Link
                    to="/admin"
                    onClick={() => setMenuOpen(false)}
                    className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                      isDark ? 'text-violet-200 hover:bg-white/5' : 'text-slate-700 hover:bg-slate-100'
                    }`}
                  >
                    Admin
                  </Link>
                )}
                <button
                  onClick={handleLogout}
                  className={`w-full px-4 py-2.5 text-[14px] font-medium transition-all rounded-xl border ${
                    isDark ? 'text-rose-400 border-rose-500/20 bg-rose-500/10' : 'text-rose-600 border-rose-200 bg-rose-50'
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
                  className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                    isDark ? 'text-violet-200 hover:bg-white/5' : 'text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  Foro
                </Link>
                <Link
                  to="/login"
                  onClick={() => setMenuOpen(false)}
                  className={`block w-full text-center px-4 py-2.5 rounded-xl text-[14px] font-medium transition-all ${
                    isDark ? 'text-violet-200 hover:bg-white/5' : 'text-slate-700 hover:bg-slate-100'
                  }`}
                >
                  Iniciar sesión
                </Link>
                <Link
                  to="/register"
                  onClick={() => setMenuOpen(false)}
                  className="btn-wm-primary block w-full text-center text-[14px] !py-3"
                >
                  Registrarse gratis
                </Link>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}