import { useEffect, useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import { useToast } from '../context/ToastContext'
import { api } from '../lib/api'
import type { Course } from './CourseCard'

interface Props {
  course: Course | null
  onClose: () => void
  onEnrolled: (course: Course) => void
}

export default function EnrollConfirmModal({ course, onClose, onEnrolled }: Props) {
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
      await api.post(`/api/courses/${course.slug}/enroll`, {})
      addToast(`¡Inscrito en ${course.title}!`)
      onEnrolled(course)
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
          boxShadow: '0 32px 80px rgba(0,0,0,0.5), 0 0 60px rgba(26,63,150,0.10)',
          '--hud-border': isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.30)',
          '--hud-border-hover': isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.30)',
        } as React.CSSProperties}
      >
        {/* Top accent line */}
        <div
          className="absolute top-0 left-0 right-0 h-px"
          style={{
            background: 'linear-gradient(90deg, transparent 0%, #1A3F96 35%, #2596be 65%, transparent 100%)',
            opacity: 0.6,
          }}
        />

        <div className="relative p-8">
          {/* Icon */}
          <div
            className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6"
            style={{
              background: 'rgba(26,63,150,0.10)',
              border: '1px solid rgba(26,63,150,0.25)',
            }}
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A3F96" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
              <path d="M6 12v5c3 3 9 3 12 0v-5"/>
            </svg>
          </div>

          <p
            className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2"
            style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
          >
            // confirmar inscripción
          </p>
          <h3
            className="font-display mb-3"
            style={{ fontSize: '1.5rem', lineHeight: 1.2, color: isDark ? '#C8D5EE' : '#0A1545' }}
          >
            ¿Inscribirte en{' '}
            <span style={{ color: '#1A3F96' }}>{course.title}</span>?
          </h3>
          <p
            className="text-[14px] font-light mb-7"
            style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
          >
            Vas a unirte a este curso. Tendrás acceso a sus{' '}
            <span style={{ color: isDark ? '#C8D5EE' : '#0A1545', fontWeight: 600 }}>
              {course.labCount} laboratorio{course.labCount === 1 ? '' : 's'}
            </span>
            {' '}y podrás empezar a sumar hasta{' '}
            <span style={{ color: isDark ? '#F5C500' : '#998000', fontWeight: 600 }}>
              {course.totalPoints.toLocaleString('es-CO')} puntos
            </span>.
          </p>

          {error && (
            <div
              className="flex items-start gap-3 px-4 py-3 rounded-xl mb-5"
              style={{
                background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
                border: '1px solid rgba(26,63,150,0.25)',
                borderLeft: '3px solid #1A3F96',
              }}
            >
              <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
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
              className="btn-neon flex-1 py-3 rounded-xl text-[14px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Inscribiendo</span>
              ) : (
                'Sí, inscribirme'
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
