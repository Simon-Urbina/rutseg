import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { adminApi, slugify, type AdminCourse } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, AdminSelect, ErrorBanner } from './AdminFormControls'
import { IconPlus, IconChevronRight } from './AdminIcons'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import { CourseFilterPanel } from '../../components/CourseFilters'
import { emptyCourseFilters, courseMatchesFilters, hasActiveCourseFilters, type CourseFilterState } from '../../lib/courseFilters'
import { ContinuousPagination } from '../../components/ContinuousPagination'

const PAGE_SIZE = 10

const DIFFICULTIES = [
  { value: 'principiante', label: 'Principiante' },
  { value: 'intermedio', label: 'Intermedio' },
  { value: 'avanzado', label: 'Avanzado' },
]

export default function AdminCoursesPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()

  const [courses, setCourses] = useState<AdminCourse[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [filters, setFilters] = useState<CourseFilterState>(emptyCourseFilters())
  const [filtersOpen, setFiltersOpen] = useState(false)
  const [page, setPage] = useState(1)

  useEffect(() => {
    setLoading(true)
    adminApi.listCourses()
      .then(setCourses)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  const query = searchQuery.toLowerCase().trim()
  const filteredCourses = courses
    .filter(c => !query || c.title.toLowerCase().includes(query) || (c.description ?? '').toLowerCase().includes(query))
    .filter(c => courseMatchesFilters(c, filters))

  // Este endpoint no pagina en el backend (la lista completa de cursos es
  // chica) — se pagina del lado del cliente sobre el resultado ya filtrado.
  const totalPages = Math.max(1, Math.ceil(filteredCourses.length / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const pageCourses = filteredCourses.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  useEffect(() => {
    setPage(1)
  }, [searchQuery, filters])

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[{ label: 'Panel', to: '/admin' }, { label: 'Cursos' }]} />

      <div className="flex items-center justify-between mb-8 mt-6 flex-wrap gap-4">
        <h1 className="font-display" style={{ fontSize: 'clamp(1.8rem, 3vw, 2.4rem)', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Cursos
        </h1>
        <button onClick={() => setShowForm(s => !s)} className="btn-neon flex items-center gap-2 px-5 py-2.5 rounded-xl text-[14px]">
          <IconPlus />
          Nuevo curso
        </button>
      </div>

      {showForm && (
        <NewCourseForm
          isDark={isDark}
          onCreated={course => { setCourses(prev => [course, ...prev]); setShowForm(false) }}
        />
      )}

      {error && <div className="mt-6"><ErrorBanner message={error} isDark={isDark} /></div>}

      {!loading && !error && courses.length === 0 && (
        <p className="text-[14px] mt-8" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
          Aún no hay cursos. Crea el primero arriba.
        </p>
      )}

      {!loading && !error && courses.length > 0 && (
        <div className="mt-6 space-y-3">
          <CourseSearchBar
            value={searchQuery}
            onChange={setSearchQuery}
            isDark={isDark}
            filtersOpen={filtersOpen}
            onToggleFilters={() => setFiltersOpen(o => !o)}
            filtersActive={hasActiveCourseFilters(filters)}
          />
          <div
            className="overflow-hidden transition-all duration-300 ease-in-out"
            style={{ maxHeight: filtersOpen ? '320px' : '0px', opacity: filtersOpen ? 1 : 0 }}
          >
            <CourseFilterPanel filters={filters} onChange={setFilters} isDark={isDark} />
          </div>
        </div>
      )}

      {!loading && !error && courses.length > 0 && filteredCourses.length === 0 && (
        <p className="text-[14px] mt-6" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
          Ningún curso coincide con la búsqueda o los filtros.
        </p>
      )}

      <div className="mt-8 flex flex-col gap-3">
        {pageCourses.map(course => (
          <button
            key={course.id}
            onClick={() => navigate(`/admin/courses/${course.slug}`)}
            className="hud-panel flex items-center justify-between gap-4 px-6 py-5 text-left w-full"
            style={{
              background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
              '--hud-border-hover': '#1A3F96',
              '--hud-focus': '#2596be',
            } as React.CSSProperties}
          >
            <div>
              <div className="flex items-center gap-3 mb-1">
                <h3 className="font-display" style={{ fontSize: '1.1rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  {course.title}
                </h3>
                <StatusBadge published={course.isPublished} />
              </div>
              <p className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
                /{course.slug} · {course.moduleCount} módulos · {course.labCount} labs
              </p>
            </div>
            <IconChevronRight />
          </button>
        ))}
      </div>

      {totalPages > 1 && (
        <div className="flex flex-col items-center gap-3 mt-8">
          <span className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
            Página {safePage} de {totalPages} · {filteredCourses.length} cursos
          </span>
          <ContinuousPagination currentPage={safePage} totalPages={totalPages} onPageChange={setPage} />
        </div>
      )}
    </PageShell>
  )
}

function CourseSearchBar({
  value, onChange, isDark, filtersOpen, onToggleFilters, filtersActive,
}: {
  value: string; onChange: (v: string) => void; isDark: boolean
  filtersOpen: boolean; onToggleFilters: () => void; filtersActive: boolean
}) {
  return (
    <div
      className="hud-panel p-3 flex items-center gap-3"
      style={{ background: isDark ? 'rgba(13,27,70,0.85)' : '#FFFFFF' }}
    >
      <svg
        width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
        className="shrink-0 ml-2"
      >
        <circle cx="11" cy="11" r="8"/>
        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
      <input
        type="text"
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder="Buscar por nombre o temática…"
        className="flex-1 min-w-0 bg-transparent outline-none text-sm px-2"
        style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
      />
      {value && (
        <button
          onClick={() => onChange('')}
          className="shrink-0 text-xs font-mono px-2.5 py-1 rounded transition-colors"
          style={{
            background: isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.08)',
            color: isDark ? '#7B9FE8' : '#1A3F96',
          }}
          onMouseEnter={e => { e.currentTarget.style.background = isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.14)' }}
          onMouseLeave={e => { e.currentTarget.style.background = isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.08)' }}
        >
          Limpiar
        </button>
      )}
      <button
        onClick={onToggleFilters}
        aria-label="Mostrar filtros"
        aria-expanded={filtersOpen}
        className="relative shrink-0 w-9 h-9 rounded-lg flex items-center justify-center transition-colors"
        style={{
          background: filtersOpen
            ? '#1A3F96'
            : isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.08)',
          color: filtersOpen ? '#fff' : isDark ? '#7B9FE8' : '#1A3F96',
        }}
        onMouseEnter={e => { if (!filtersOpen) e.currentTarget.style.background = isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.14)' }}
        onMouseLeave={e => { if (!filtersOpen) e.currentTarget.style.background = isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.08)' }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>
        </svg>
        {filtersActive && !filtersOpen && (
          <span
            className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full"
            style={{ background: '#F5C500', border: `2px solid ${isDark ? '#0D1B46' : '#FFFFFF'}` }}
          />
        )}
      </button>
    </div>
  )
}

export function StatusBadge({ published }: { published: boolean }) {
  return (
    <span
      className="font-mono text-[10px] tracking-[0.14em] uppercase px-2 py-1 rounded"
      style={{
        color: published ? '#52ad70' : '#F5C500',
        background: published ? 'rgba(82,173,112,0.10)' : 'rgba(245,197,0,0.10)',
        border: `1px solid ${published ? 'rgba(82,173,112,0.30)' : 'rgba(245,197,0,0.30)'}`,
      }}
    >
      {published ? 'Publicado' : 'Borrador'}
    </span>
  )
}

function NewCourseForm({ isDark, onCreated }: { isDark: boolean; onCreated: (c: AdminCourse) => void }) {
  const [title, setTitle] = useState('')
  const [slug, setSlug] = useState('')
  const [slugTouched, setSlugTouched] = useState(false)
  const [description, setDescription] = useState('')
  const [difficulty, setDifficulty] = useState('principiante')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleTitleChange = (v: string) => {
    setTitle(v)
    if (!slugTouched) setSlug(slugify(v))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const course = await adminApi.createCourse({ slug, title, description: description || undefined, difficulty: difficulty as AdminCourse['difficulty'] })
      onCreated({ ...course, moduleCount: 0, labCount: 0, totalPoints: 0 })
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="hud-panel hud-static p-7 space-y-5 mb-8" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
      '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
    } as React.CSSProperties}>
      <AdminInput label="Título" value={title} onChange={handleTitleChange} isDark={isDark} placeholder="Fundamentos de Ciberseguridad" />
      <AdminInput label="Slug" value={slug} onChange={v => { setSlug(v); setSlugTouched(true) }} isDark={isDark} placeholder="fundamentos-ciberseguridad" />
      <AdminTextarea label="Descripción" value={description} onChange={setDescription} isDark={isDark} rows={3} placeholder="Aprende los conceptos base de..." />
      <AdminSelect label="Dificultad" value={difficulty} onChange={setDifficulty} isDark={isDark} options={DIFFICULTIES} />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <button type="submit" disabled={loading} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
        {loading ? 'Creando…' : 'Crear curso'}
      </button>
    </form>
  )
}
