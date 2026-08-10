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

const DIFFICULTY_META: Record<Course['difficulty'], { color: string; label: string; bg: string }> = {
  principiante: { color: '#10B981', label: 'PRINCIPIANTE', bg: 'rgba(16, 185, 129, 0.12)' },
  intermedio:   { color: '#F59E0B', label: 'INTERMEDIO',   bg: 'rgba(245, 158, 11, 0.12)' },
  avanzado:     { color: '#F43F5E', label: 'AVANZADO',     bg: 'rgba(244, 63, 94, 0.12)' },
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
    <div className="glass-card-wm flex flex-col justify-between p-7 relative overflow-hidden group">
      {/* Top Ambient Glow accent line */}
      <div
        className="absolute top-0 left-0 right-0 h-1 transition-all duration-300 opacity-80"
        style={{
          background: `linear-gradient(90deg, transparent 0%, ${diff.color} 50%, transparent 100%)`,
        }}
      />

      <div>
        {/* Top Header Row: Difficulty Badge + Enrolled Status */}
        <div className="flex items-center justify-between gap-2 mb-6">
          <div
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full font-mono text-[10px] font-bold tracking-wider"
            style={{
              color: diff.color,
              backgroundColor: diff.bg,
              border: `1px solid ${diff.color}35`,
            }}
          >
            <span className="w-1.5 h-1.5 rounded-full animate-pulse" style={{ backgroundColor: diff.color }} />
            {diff.label}
          </div>

          {course.isEnrolled && (
            <span className="inline-flex items-center gap-1.5 font-mono text-[10px] font-bold tracking-wider text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-3 py-1 rounded-full">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"/>
              </svg>
              INSCRITO
            </span>
          )}
        </div>

        {/* Title */}
        <h3 className={`font-display text-xl font-bold tracking-tight mb-3 transition-colors ${isDark ? 'text-white group-hover:text-teal-300' : 'text-slate-900 group-hover:text-rosewood-600'}`}>
          {course.title}
        </h3>

        {/* Description */}
        <p className="text-slate-600 dark:text-slate-300 text-sm font-normal leading-relaxed mb-6 line-clamp-3">
          {course.description || 'Sin descripción disponible.'}
        </p>
      </div>

      <div>
        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-2 py-4 mb-6 border-y border-slate-200 dark:border-white/10 text-center">
          <div>
            <p className="num-display text-lg font-bold text-slate-800 dark:text-slate-100 leading-none">
              {course.moduleCount}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase text-slate-500 dark:text-slate-400 mt-1.5">
              Módulos
            </p>
          </div>

          <div>
            <p className="num-display text-lg font-bold text-slate-800 dark:text-slate-100 leading-none">
              {course.labCount}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase text-slate-500 dark:text-slate-400 mt-1.5">
              Labs
            </p>
          </div>

          <div>
            <p className="num-display text-lg font-bold text-amber-400 leading-none">
              {course.totalPoints.toLocaleString('es-CO')}
            </p>
            <p className="font-mono text-[9px] tracking-widest uppercase text-slate-500 dark:text-slate-400 mt-1.5">
              Puntos
            </p>
          </div>
        </div>

        {/* Progress Bar (Enrolled Courses) */}
        {course.isEnrolled && (
          <div className="mb-6">
            <div className="flex items-center justify-between text-xs font-mono mb-2">
              <span className="text-slate-400 uppercase tracking-widest text-[10px]">PROGRESO</span>
              <span className="text-teal-400 font-bold">
                {course.completedLabsCount ?? 0} / {course.labCount} labs
              </span>
            </div>
            <div className="h-2 rounded-full bg-slate-200 dark:bg-white/10 overflow-hidden">
              <div
                className="h-full rounded-full transition-all duration-700 bg-gradient-to-r from-teal-400 to-sky-400"
                style={{
                  width: `${course.labCount > 0 ? ((course.completedLabsCount ?? 0) / course.labCount) * 100 : 0}%`,
                }}
              />
            </div>
          </div>
        )}

        {/* Action Button */}
        {course.isEnrolled ? (
          <button
            onClick={() => onContinue?.(course)}
            className="w-full btn-wm-secondary text-sm font-semibold py-3 flex items-center justify-center gap-2"
          >
            Continuar Curso →
          </button>
        ) : (
          <button
            onClick={() => onEnroll(course)}
            className="w-full btn-wm-primary text-sm font-semibold py-3 flex items-center justify-center gap-2"
          >
            Inscribirme Gratis
          </button>
        )}
      </div>
    </div>
  )
}
