import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import Header from '../../components/Header'
import { adminApi, slugify, type AdminCourse } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, AdminSelect, ErrorBanner } from './AdminFormControls'
import { IconPlus, IconChevronRight } from './AdminIcons'

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

  useEffect(() => {
    setLoading(true)
    adminApi.listCourses()
      .then(setCourses)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [])

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', minHeight: '100vh' }}>
      <Header />
      <div className="max-w-5xl mx-auto px-6 lg:px-10 py-14">
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
          // panel de administración
        </p>
        <div className="flex items-center justify-between mb-8 flex-wrap gap-4">
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

        <div className="mt-8 flex flex-col gap-3">
          {courses.map(course => (
            <button
              key={course.id}
              onClick={() => navigate(`/admin/courses/${course.slug}`)}
              className="flex items-center justify-between gap-4 px-6 py-5 rounded-xl text-left transition-all"
              style={{ background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)' }}
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
      </div>
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
      onCreated(course)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="p-7 rounded-2xl space-y-5 mb-8" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
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
