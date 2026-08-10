import { useTheme } from '../context/ThemeContext'

export interface Course {
  id: string
  slug: string
  title: string
  description: string | null
  difficulty: 'principiante' | 'intermedio' | 'avanzado'
  moduleCount: number
  labCount: number
  totalPoints: number
  isEnrolled: boolean
  completedLabsCount?: number
}

const DIFFICULTY_META: Record<Course['difficulty'], { color: string; label: string; bars: number }> = {
  principiante: { color: '#2596be', label: 'PRINCIPIANTE', bars: 1 },
  intermedio:   { color: '#F5C500', label: 'INTERMEDIO',   bars: 2 },
  avanzado:     { color: '#1A3F96', label: 'AVANZADO',     bars: 3 },
}

interface Props {
  course: Course
  onEnroll: (course: Course) => void
  onContinue?: (course: Course) => void
}

export default function CourseCard({ course, onEnroll, onContinue }: Props) {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const diff = DIFFICULTY_META[course.difficulty]

  return (
    <div
      className="hud-panel group flex flex-col"
      style={{
        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
        '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
        '--hud-border-hover': `${diff.color}99`,
        '--hud-focus': diff.color,
      } as React.CSSProperties}
    >
      {/* Top accent bar (color-coded by difficulty) */}
      <div
        className="absolute top-0 left-0 right-0 h-px"
        style={{
          background: `linear-gradient(90deg, transparent 0%, ${diff.color} 50%, transparent 100%)`,
          opacity: 0.5,
        }}
      />

      <span className="hud-corner-tag" style={{ color: diff.color }}>{diff.label}</span>

      <div className="relative p-7 flex flex-col flex-1">
        {/* Top row: difficulty + enrolled badge */}
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-end gap-0.5">
            {[0, 1, 2].map(i => (
              <span
                key={i}
                className="w-1 rounded-sm transition-colors"
                style={{
                  height: `${6 + i * 3}px`,
                  background: i < diff.bars ? diff.color : (isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)'),
                }}
              />
            ))}
          </div>

          {course.isEnrolled && (
            <span
              className="font-mono text-[10px] tracking-[0.18em] uppercase px-2 py-1 rounded flex items-center gap-1.5"
              style={{
                color: '#52ad70',
                background: 'rgba(82,173,112,0.08)',
                border: '1px solid rgba(82,173,112,0.25)',
              }}
            >
              <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              Inscrito
            </span>
          )}
        </div>

        {/* Title */}
        <h3
          className="font-display mb-3"
          style={{
            fontSize: '1.4rem',
            lineHeight: 1.2,
            color: isDark ? '#C8D5EE' : '#0A1545',
          }}
        >
          {course.title}
        </h3>

        {/* Description */}
        <p
          className="text-[14px] font-light flex-1 mb-6"
          style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.6 }}
        >
          {course.description || 'Sin descripción disponible.'}
        </p>

        {/* Stats row */}
        <div
          className="grid grid-cols-3 gap-2 mb-6 py-4 px-1"
          style={{
            borderTop: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.10)'}`,
            borderBottom: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.10)'}`,
          }}
        >
          <Stat label="Módulos" value={course.moduleCount.toString()} isDark={isDark} accent={diff.color} />
          <Stat label="Labs" value={course.labCount.toString()} isDark={isDark} accent={diff.color} />
          <Stat label="Puntos" value={course.totalPoints.toLocaleString('es-CO')} isDark={isDark} accent="#F5C500" />
        </div>

        {/* Progress bar — enrolled courses only */}
        {course.isEnrolled && (
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <span
                className="font-mono text-[9px] tracking-[0.18em] uppercase"
                style={{ color: diff.color }}
              >
                Progreso
              </span>
              <span
                className="font-mono text-[11px]"
                style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
              >
                <span className="num-display" style={{ fontSize: '0.8rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  {course.completedLabsCount ?? 0}
                </span>
                {' / '}{course.labCount} labs
              </span>
            </div>
            <div
              className="h-1.5 rounded-full overflow-hidden"
              style={{ background: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.08)' }}
            >
              <div
                className="h-full rounded-full transition-all duration-700"
                style={{
                  width: `${course.labCount > 0 ? ((course.completedLabsCount ?? 0) / course.labCount) * 100 : 0}%`,
                  background: `linear-gradient(90deg, ${diff.color}, ${diff.color}bb)`,
                  minWidth: (course.completedLabsCount ?? 0) > 0 ? '6px' : '0px',
                }}
              />
            </div>
          </div>
        )}

        {/* CTA */}
        {course.isEnrolled ? (
          <button
            onClick={() => onContinue?.(course)}
            className="w-full py-3 rounded-xl text-[14px] font-semibold transition-all"
            style={{
              background: 'transparent',
              color: '#2596be',
              border: '1px solid rgba(37,150,190,0.4)',
            }}
            onMouseEnter={e => {
              ;(e.currentTarget as HTMLElement).style.background = 'rgba(37,150,190,0.10)'
              ;(e.currentTarget as HTMLElement).style.borderColor = '#2596be'
            }}
            onMouseLeave={e => {
              ;(e.currentTarget as HTMLElement).style.background = 'transparent'
              ;(e.currentTarget as HTMLElement).style.borderColor = 'rgba(37,150,190,0.4)'
            }}
          >
            Continuar →
          </button>
        ) : (
          <button
            onClick={() => onEnroll(course)}
            className="btn-neon w-full py-3 rounded-xl text-[14px] font-semibold"
          >
            Inscribirme
          </button>
        )}
      </div>
    </div>
  )
}

function Stat({ label, value, isDark, accent }: { label: string; value: string; isDark: boolean; accent: string }) {
  return (
    <div className="text-center">
      <p
        className="num-display leading-none"
        style={{ fontSize: '1.25rem', color: isDark ? '#C8D5EE' : '#0A1545' }}
      >
        {value}
      </p>
      <p
        className="font-mono text-[9px] tracking-[0.18em] uppercase mt-1.5"
        style={{ color: accent, opacity: 0.85 }}
      >
        {label}
      </p>
    </div>
  )
}
