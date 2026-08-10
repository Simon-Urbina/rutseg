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

// `color` tints backgrounds/borders at low alpha, where any hue reads fine.
// `textColor` is what actually gets used as solid text/icon color: gold is
// too light to read as text on a white card (~1.6:1), so light mode swaps in
// the darker gold-700 token there instead.
const DIFFICULTY_META: Record<Course['difficulty'], { color: string; textColor: string; label: string; bg: string }> = {
  principiante: { color: '#2596be', textColor: '#2596be', label: 'PRINCIPIANTE', bg: 'rgba(37, 150, 190, 0.10)' },
  intermedio:   { color: '#F5C500', textColor: '#998000', label: 'INTERMEDIO',   bg: 'rgba(245, 197, 0, 0.10)' },
  avanzado:     { color: '#1A3F96', textColor: '#1A3F96', label: 'AVANZADO',     bg: 'rgba(26, 63, 150, 0.10)' },
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
    <div className="hud-panel flex flex-col justify-between p-7 relative overflow-hidden group">
      {/* Accent top border */}
      <div
        className="absolute top-0 left-0 right-0 h-1 transition-colors"
        style={{
          background: `linear-gradient(90deg, transparent 0%, ${diff.color} 50%, transparent 100%)`,
        }}
      />

      <div>
        {/* Top Header Row: Difficulty Badge + Enrolled Status */}
        <div className="flex items-center justify-between gap-2 mb-5">
          <div
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full font-mono text-[10px] font-semibold tracking-widest uppercase border"
            style={{
              color: isDark ? diff.color : diff.textColor,
              backgroundColor: diff.bg,
              borderColor: `${diff.color}35`,
            }}
          >
            <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: diff.color }} />
            {diff.label}
          </div>

          {course.isEnrolled && (
            <span className="inline-flex items-center gap-1.5 font-mono text-[10px] font-semibold tracking-wider text-emerald-500 bg-emerald-500/10 border border-emerald-500/30 px-2.5 py-1 rounded-full uppercase">
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              Inscrito
            </span>
          )}
        </div>

        {/* Title */}
        <h3
          className="font-display text-xl font-bold tracking-tight mb-3"
          style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
        >
          {course.title}
        </h3>

        {/* Description */}
        <p
          className="text-sm font-light leading-relaxed mb-6 line-clamp-3"
          style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
        >
          {course.description || 'Sin descripción disponible.'}
        </p>
      </div>

      <div>
        {/* Stats Row */}
        <div
          className="grid grid-cols-3 gap-2 py-4 mb-6 text-center border-y"
          style={{ borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)' }}
        >
          <div>
            <p className="num-display text-lg font-bold leading-none" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
              {course.moduleCount}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase mt-1" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              Módulos
            </p>
          </div>

          <div>
            <p className="num-display text-lg font-bold leading-none" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
              {course.labCount}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase mt-1" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              Labs
            </p>
          </div>

          <div>
            <p className="num-display text-lg font-bold leading-none" style={{ color: isDark ? '#F5C500' : '#998000' }}>
              {course.totalPoints.toLocaleString('es-CO')}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase mt-1" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              Puntos
            </p>
          </div>
        </div>

        {/* Progress Bar (Enrolled Courses) */}
        {course.isEnrolled && (
          <div className="mb-6">
            <div className="flex items-center justify-between text-xs font-mono mb-2">
              <span className="uppercase tracking-widest text-[9px]" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>PROGRESO</span>
              <span className="text-xs font-bold" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                {course.completedLabsCount ?? 0} / {course.labCount} labs
              </span>
            </div>
            <div className="h-1.5 rounded-full overflow-hidden" style={{ background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.10)' }}>
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{
                  width: `${course.labCount > 0 ? ((course.completedLabsCount ?? 0) / course.labCount) * 100 : 0}%`,
                  background: diff.color,
                }}
              />
            </div>
          </div>
        )}

        {/* Action Button */}
        {course.isEnrolled ? (
          <button
            onClick={() => onContinue?.(course)}
            className="w-full btn-ghost-light text-sm font-semibold py-2.5"
          >
            Continuar curso →
          </button>
        ) : (
          <button
            onClick={() => onEnroll(course)}
            className="w-full btn-neon text-sm font-semibold py-2.5"
          >
            Inscribirme
          </button>
        )}
      </div>
    </div>
  )
}
