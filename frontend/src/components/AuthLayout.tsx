import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { LogoIcon } from './Logo'
import { Boop } from './Boop'
import ThemeToggle from './ThemeToggle'
import { api } from '../lib/api'

const TERMINAL_LINES = [
  { text: '$ nmap -sV --script vuln 10.10.14.1', color: '#2596be', delay: '0.9s' },
  { text: 'Starting Nmap 7.94SVN...', color: '#3A5AB8', delay: '1.4s' },
  { text: 'PORT   STATE  SERVICE    VERSION', color: '#3A5AB8', delay: '1.9s' },
  { text: '22/tcp  open  ssh        OpenSSH 8.9p1', color: '#3DAED0', delay: '2.4s' },
  { text: '80/tcp  open  http       Apache 2.4.54', color: '#1A3F96', delay: '2.9s' },
  { text: '443/tcp open  ssl/https  nginx 1.23.4', color: '#1A3F96', delay: '3.3s' },
  { text: 'VULNERABLE: CVE-2023-4911 (glibc)', color: '#F5C500', delay: '3.8s' },
]

interface AuthLayoutProps {
  children: React.ReactNode
  headline: React.ReactNode
  subheadline: string
  terminalComment: string
}

export default function AuthLayout({
  children,
  headline,
  subheadline,
  terminalComment,
}: AuthLayoutProps) {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const [stats, setStats] = useState<{ courseCount: number; labCount: number; totalPoints: number } | null>(null)
  useEffect(() => {
    api.get<{ courseCount: number; labCount: number; totalPoints: number }>('/api/stats')
      .then(setStats).catch(() => {})
  }, [])

  return (
    <div className="min-h-screen flex" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>

      {/* ── Left decorative panel ── */}
      <div
        className="hidden lg:flex lg:w-[54%] relative overflow-hidden flex-col"
        style={{ background: 'linear-gradient(155deg, #0D1630 0%, #060D1F 55%, #091520 100%)' }}
      >
        {/* Neon grid */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            backgroundImage: `
              linear-gradient(rgba(26, 63, 150, 0.07) 1px, transparent 1px),
              linear-gradient(90deg, rgba(26, 63, 150, 0.07) 1px, transparent 1px)
            `,
            backgroundSize: '44px 44px',
          }}
        />

        {/* Scanline */}
        <div className="scanline-sweep" />

        {/* Watermark logo */}
        <div className="absolute bottom-8 right-6 pointer-events-none" style={{ opacity: 0.04 }}>
          <LogoIcon className="w-80 h-80" />
        </div>

        {/* Panel content */}
        <div className="relative z-10 flex flex-col h-full p-14 xl:p-20">

          {/* Logo */}
          <Link to="/" className="flex items-center gap-3 w-fit animate-fade-up-1">
            <Boop rotation={12} scale={1.12}>
              <LogoIcon className="w-8 h-8" />
            </Boop>
            <span
              className="font-mono text-[11px] tracking-[0.24em] uppercase"
              style={{ color: '#3A5AB8' }}
            >
              RutSeg
            </span>
          </Link>

          {/* Hero */}
          <div className="flex-1 flex flex-col justify-center mt-12 space-y-8">
            <p
              className="font-mono text-[11px] tracking-[0.22em] uppercase animate-fade-up-2"
              style={{ color: '#3A5AB8' }}
            >
              {terminalComment}
            </p>

            <div className="animate-fade-up-3">
              {headline}
            </div>

            <p
              className="text-base leading-relaxed max-w-xs font-light animate-fade-up-4"
              style={{ color: '#4A70CC', lineHeight: 1.7 }}
            >
              {subheadline}
            </p>

            {/* Stats */}
            <div className="flex gap-12 pt-2 animate-fade-up-5">
              {[
                { value: stats ? String(stats.courseCount) : '—', label: 'Cursos' },
                { value: stats ? String(stats.labCount) : '—', label: 'Labs' },
                { value: stats ? `${stats.totalPoints.toLocaleString('es-CO')}` : '—', label: 'Puntos' },
              ].map(({ value, label }) => (
                <div key={label}>
                  <p
                    className="num-display leading-none"
                    style={{ fontSize: '2.25rem', color: '#F5C500' }}
                  >
                    {value}
                  </p>
                  <p
                    className="font-mono text-[9px] tracking-[0.2em] uppercase mt-1.5"
                    style={{ color: '#3A5AB8' }}
                  >
                    {label}
                  </p>
                </div>
              ))}
            </div>
          </div>

          {/* Terminal widget */}
          <div
            className="hud-panel hud-static animate-fade-up-5 mt-14"
            style={{
              background: 'rgba(6, 13, 31, 0.85)',
              backdropFilter: 'blur(12px)',
              boxShadow: '0 0 50px rgba(26,63,150,0.06), inset 0 0 30px rgba(26,63,150,0.03)',
              '--hud-border': 'rgba(26,63,150,0.35)',
              '--hud-border-hover': 'rgba(26,63,150,0.35)',
            } as React.CSSProperties}
          >
            <div
              className="flex items-center gap-2 px-5 py-3"
              style={{ borderBottom: '1px solid rgba(26, 63, 150, 0.15)' }}
            >
              <span className="w-2.5 h-2.5 rounded-full" style={{ background: '#1A3F96' }} />
              <span className="w-2.5 h-2.5 rounded-full" style={{ background: 'rgba(26,63,150,0.35)' }} />
              <span className="w-2.5 h-2.5 rounded-full" style={{ background: 'rgba(37,150,190,0.30)' }} />
              <span
                className="ml-3 font-mono text-[10px] tracking-[0.15em]"
                style={{ color: '#3A5AB8' }}
              >
                terminal — bash
              </span>
            </div>
            <div className="px-5 py-4 space-y-1.5">
              {TERMINAL_LINES.map((line, i) => (
                <p
                  key={i}
                  className="font-mono text-xs leading-5"
                  style={{ color: line.color, animation: `fadeIn 0.3s ${line.delay} ease both`, opacity: 0 }}
                >
                  {line.text}
                </p>
              ))}
              <p className="font-mono text-xs cursor-blink" style={{ color: '#2596be' }}>
                &nbsp;
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* ── Right form panel ── */}
      <div
        className="flex-1 flex flex-col min-h-screen"
        style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}
      >
        {/* Top bar */}
        <div className="flex items-center justify-between px-8 py-5 lg:px-10">
          <Link to="/" className="lg:hidden flex items-center gap-2.5">
            <Boop rotation={12} scale={1.12}>
              <LogoIcon className="w-7 h-7" />
            </Boop>
            <span
              className="font-display text-[17px]"
              style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
            >
              RutSeg
            </span>
          </Link>
          <div className="hidden lg:block" />
          <ThemeToggle />
        </div>

        {/* Form */}
        <div className="flex-1 flex items-center justify-center px-8 py-10">
          <div
            className="hud-panel hud-static w-full max-w-[440px] animate-slide-in"
            style={{
              background: isDark ? 'rgba(13,27,70,0.85)' : '#ffffff',
              padding: '44px',
              boxShadow: isDark ? 'none' : '0 4px 40px rgba(10,21,69,0.07)',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
              '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
            } as React.CSSProperties}
          >
            {children}
          </div>
        </div>

        {/* Footer */}
        <div className="px-8 py-5 text-center">
          <p
            className="font-mono text-[10px] tracking-[0.2em] uppercase"
            style={{ color: isDark ? 'rgba(26,63,150,0.4)' : 'rgba(26,63,150,0.3)' }}
          >
            RutSeg © 2026
          </p>
        </div>
      </div>
    </div>
  )
}
