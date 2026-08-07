import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import Header from '../../components/Header'
import { adminApi, slugify, type AdminCourse, type AdminModule } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, AdminSelect, ErrorBanner } from './AdminFormControls'
import { IconPlus, IconChevronRight, IconTrash } from './AdminIcons'
import { StatusBadge } from './AdminCoursesPage'
import ConfirmDeleteModal from './ConfirmDeleteModal'

const DIFFICULTIES = [
  { value: 'principiante', label: 'Principiante' },
  { value: 'intermedio', label: 'Intermedio' },
  { value: 'avanzado', label: 'Avanzado' },
]

export function PageShell({ isDark, children }: { isDark: boolean; children: React.ReactNode }) {
  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', minHeight: '100vh' }}>
      <Header />
      <div className="max-w-5xl mx-auto px-6 lg:px-10 py-14">{children}</div>
    </div>
  )
}

export function Breadcrumb({ isDark, items }: { isDark: boolean; items: { label: string; to?: string }[] }) {
  const navigate = useNavigate()
  return (
    <div className="flex items-center gap-2 font-mono text-[12px]" style={{ color: '#4A70CC' }}>
      {items.map((item, i) => (
        <span key={i} className="flex items-center gap-2">
          {i > 0 && <span>/</span>}
          {item.to ? (
            <button onClick={() => navigate(item.to!)} className="hover:underline" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
              {item.label}
            </button>
          ) : (
            <span>{item.label}</span>
          )}
        </span>
      ))}
    </div>
  )
}

export default function AdminCourseDetailPage() {
  const { courseSlug } = useParams<{ courseSlug: string }>()
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()

  const [course, setCourse] = useState<AdminCourse | null>(null)
  const [modules, setModules] = useState<AdminModule[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [showModuleForm, setShowModuleForm] = useState(false)
  const [deleteOpen, setDeleteOpen] = useState(false)

  useEffect(() => {
    if (!courseSlug) return
    setLoading(true)
    Promise.all([adminApi.getCourse(courseSlug), adminApi.listModules(courseSlug)])
      .then(([c, m]) => { setCourse(c); setModules(m) })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [courseSlug])

  if (loading) return <PageShell isDark={isDark}><p style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>Cargando…</p></PageShell>
  if (error || !course) return <PageShell isDark={isDark}><ErrorBanner message={error || 'Curso no encontrado.'} isDark={isDark} /></PageShell>

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[{ label: 'Cursos', to: '/admin' }, { label: course.title }]} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-6">
        <EditCourseForm isDark={isDark} course={course} onUpdated={setCourse} onDeleteClick={() => setDeleteOpen(true)} />

        <div>
          <div className="flex items-center justify-between mb-5">
            <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
              Módulos
            </h2>
            <button onClick={() => setShowModuleForm(s => !s)} className="btn-neon flex items-center gap-2 px-4 py-2 rounded-xl text-[13px]">
              <IconPlus size={12} />
              Nuevo módulo
            </button>
          </div>

          {showModuleForm && (
            <NewModuleForm
              isDark={isDark}
              courseId={course.id}
              nextPosition={modules.length + 1}
              onCreated={m => { setModules(prev => [...prev, m]); setShowModuleForm(false) }}
            />
          )}

          {modules.length === 0 && !showModuleForm && (
            <p className="text-[14px] mt-4" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
              Este curso todavía no tiene módulos.
            </p>
          )}

          <div className="flex flex-col gap-3 mt-4">
            {modules.map(m => (
              <button
                key={m.id}
                onClick={() => navigate(`/admin/courses/${courseSlug}/${m.slug}`)}
                className="flex items-center justify-between gap-4 px-5 py-4 rounded-xl text-left transition-all"
                style={{ background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)' }}
              >
                <div>
                  <p className="font-display" style={{ fontSize: '1rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    {m.position}. {m.title}
                  </p>
                  <p className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>/{m.slug}</p>
                </div>
                <IconChevronRight />
              </button>
            ))}
          </div>
        </div>
      </div>

      <ConfirmDeleteModal
        open={deleteOpen}
        title={`el curso "${course.title}"`}
        warningDetail={`Esto borrará ${course.moduleCount} módulo(s) y ${course.labCount} laboratorio(s), junto con las inscripciones y el progreso de los estudiantes en este curso.`}
        requireTypedSlug={course.slug}
        onCancel={() => setDeleteOpen(false)}
        onConfirm={async () => { await adminApi.deleteCourse(course.id); navigate('/admin') }}
      />
    </PageShell>
  )
}

function EditCourseForm({
  isDark, course, onUpdated, onDeleteClick,
}: { isDark: boolean; course: AdminCourse; onUpdated: (c: AdminCourse) => void; onDeleteClick: () => void }) {
  const [title, setTitle] = useState(course.title)
  const [slug, setSlug] = useState(course.slug)
  const [description, setDescription] = useState(course.description ?? '')
  const [difficulty, setDifficulty] = useState(course.difficulty)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setError('')
    try {
      const updated = await adminApi.updateCourse(course.id, { title, slug, description, difficulty })
      onUpdated({ ...course, ...updated })
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const togglePublish = async () => {
    setError('')
    try {
      const updated = await adminApi.updateCourse(course.id, { isPublished: !course.isPublished })
      onUpdated({ ...course, ...updated })
    } catch (err: any) {
      setError(err.message)
    }
  }

  return (
    <form onSubmit={handleSave} className="p-7 rounded-2xl space-y-5 h-fit" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
      <div className="flex items-center justify-between">
        <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Editar curso
        </h2>
        <StatusBadge published={course.isPublished} />
      </div>

      <AdminInput label="Título" value={title} onChange={setTitle} isDark={isDark} />
      <AdminInput label="Slug" value={slug} onChange={setSlug} isDark={isDark} />
      <AdminTextarea label="Descripción" value={description} onChange={setDescription} isDark={isDark} rows={3} />
      <AdminSelect label="Dificultad" value={difficulty} onChange={v => setDifficulty(v as AdminCourse['difficulty'])} isDark={isDark} options={DIFFICULTIES} />

      {error && <ErrorBanner message={error} isDark={isDark} />}

      <div className="flex items-center gap-3 flex-wrap">
        <button type="submit" disabled={saving} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
          {saving ? 'Guardando…' : 'Guardar cambios'}
        </button>
        <button type="button" onClick={togglePublish} className="btn-ghost-light px-5 py-2.5 rounded-xl text-[14px]">
          {course.isPublished ? 'Despublicar' : 'Publicar'}
        </button>
        <button
          type="button"
          onClick={onDeleteClick}
          className="ml-auto flex items-center gap-2 px-4 py-2.5 rounded-xl text-[13px] font-medium"
          style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
        >
          <IconTrash size={13} />
          Borrar curso
        </button>
      </div>
    </form>
  )
}

function NewModuleForm({
  isDark, courseId, nextPosition, onCreated,
}: { isDark: boolean; courseId: string; nextPosition: number; onCreated: (m: AdminModule) => void }) {
  const [title, setTitle] = useState('')
  const [slug, setSlug] = useState('')
  const [slugTouched, setSlugTouched] = useState(false)
  const [description, setDescription] = useState('')
  const [position, setPosition] = useState(String(nextPosition))
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
      const module = await adminApi.createModule(courseId, { slug, title, description: description || undefined, position: Number(position) })
      onCreated(module)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="p-6 rounded-2xl space-y-4 mb-4" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
      <AdminInput label="Título" value={title} onChange={handleTitleChange} isDark={isDark} placeholder="Reconocimiento y Escaneo" />
      <AdminInput label="Slug" value={slug} onChange={v => { setSlug(v); setSlugTouched(true) }} isDark={isDark} />
      <AdminTextarea label="Descripción" value={description} onChange={setDescription} isDark={isDark} rows={2} />
      <AdminInput label="Posición" type="number" value={position} onChange={setPosition} isDark={isDark} />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <button type="submit" disabled={loading} className="btn-neon px-5 py-2.5 rounded-xl text-[13px] disabled:opacity-50">
        {loading ? 'Creando…' : 'Crear módulo'}
      </button>
    </form>
  )
}
