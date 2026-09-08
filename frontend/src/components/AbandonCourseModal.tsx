import { useEffect, useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import { useToast } from '../context/ToastContext'
import { api } from '../lib/api'
import type { Course } from './CourseCard'

interface Props {
  course: Course | null
  onClose: () => void
  onAbandoned: (course: Course) => void
}

export default function AbandonCourseModal({ course, onClose, onAbandoned }: Props) {
  const { theme } = useTheme()
  const { addToast } = useToast()
  const isDark = theme === 'dark'

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    if (course) {
      setLoading(false)
      setError('')
    }
  }, [course])

  useEffect(() => {
    if (!course) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape' && !loading) onClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [course, loading, onClose])

  if (!course) return null

  const handleConfirm = async () => {
    setError('')
    setLoading(true)
    try {
      await api.delete(`/api/courses/${course.slug}/enroll`)
      addToast(`Abandonaste ${course.title}.`)
      onAbandoned(course)
    } catch (err: any) {
      setError(err.message)
      setLoading(false)
    }
  }

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4 animate-fade-up-1"
      style={{
        background: 'rgba(6,13,31,0.75)',
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)',
      }}
      onClick={() => { if (!loading) onClose() }}
    >
      <div
        onClick={e => e.stopPropagation()}
        className="hud-panel hud-static relative w-full max-w-[460px]"
        style={{
          background: isDark ? 'rgba(9,21,32,0.84)' : 'rgba(248,250,255,0.92)',
          backdropFilter: 'blur(24px)',
          WebkitBackdropFilter: 'blur(24px)',
          boxShadow: '0 32px 80px rgba(0,0,0,0.5), 0 0 60px rgba(220,38,38,0.10)',
          '--hud-border': 'rgba(220,38,38,0.35)',
          '--hud-border-hover': 'rgba(220,38,38,0.35)',
        } as React.CSSProperties}
      >
        {/* Top accent line */}
        <div
          className="absolute top-0 left-0 right-0 h-px"
          style={{
            background: 'linear-gradient(90deg, transparent 0%, #dc2626 35%, #F5C500 65%, transparent 100%)',
            opacity: 0.6,
          }}
        />

        <div className="relative p-8">
          {/* Icon */}
          <div
            className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6"
            style={{
              background: 'rgba(220,38,38,0.10)',
              border: '1px solid rgba(220,38,38,0.30)',
            }}
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#dc2626" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
              <path d="M6 12v5c3 3 9 3 12 0v-5"/>
              <line x1="4" y1="4" x2="20" y2="20"/>
            </svg>
          </div>

          <p
            className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2"
            style={{ color: '#dc2626' }}
          >
            // abandonar curso
          </p>
          <h3
            className="font-display mb-3"
            style={{ fontSize: '1.5rem', lineHeight: 1.2, color: isDark ? '#C8D5EE' : '#0A1545' }}
          >
            ¿Abandonar{' '}
            <span style={{ color: '#dc2626' }}>{course.title}</span>?
          </h3>
          <p
            className="text-[14px] font-light mb-7"
            style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
          >
            Perderás acceso a los laboratorios de este curso hasta que te vuelvas a inscribir.
            Tu progreso y puntos ya ganados{' '}
            <span style={{ color: isDark ? '#C8D5EE' : '#0A1545', fontWeight: 600 }}>
              se conservan
            </span>
            {' '}y los recuperarás apenas te vuelvas a inscribir.
          </p>

          {error && (
            <div
              className="flex items-start gap-3 px-4 py-3 rounded-xl mb-5"
              style={{
                background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
                border: '1px solid rgba(220,38,38,0.30)',
                borderLeft: '3px solid #dc2626',
              }}
            >
              <span className="font-mono text-xs mt-0.5" style={{ color: '#dc2626' }}>ERR</span>
              <p className="text-sm" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
            </div>
          )}

          <div className="flex items-center gap-3">
            <button
              onClick={onClose}
              disabled={loading}
              className="flex-1 py-3 rounded-xl text-[14px] font-medium transition-all disabled:opacity-50"
              style={{
                background: 'transparent',
                color: isDark ? '#7B9FE8' : '#1A3F96',
                border: `1px solid ${isDark ? 'rgba(26,63,150,0.22)' : 'rgba(26,63,150,0.25)'}`,
              }}
              onMouseEnter={e => {
                if (loading) return
                ;(e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.08)'
              }}
              onMouseLeave={e => {
                ;(e.currentTarget as HTMLElement).style.background = 'transparent'
              }}
            >
              Cancelar
            </button>
            <button
              onClick={handleConfirm}
              disabled={loading}
              className="flex-1 py-3 rounded-xl text-[14px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              style={{ background: '#dc2626', color: '#fff' }}
              onMouseEnter={e => { if (!loading) e.currentTarget.style.background = '#b91c1c' }}
              onMouseLeave={e => { e.currentTarget.style.background = '#dc2626' }}
            >
              {loading ? (
                <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Abandonando</span>
              ) : (
                'Sí, abandonar'
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
