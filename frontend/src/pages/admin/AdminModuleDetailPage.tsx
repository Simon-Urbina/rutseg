import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { adminApi, type AdminCourse, type AdminModule, type AdminLabSummary } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, ErrorBanner } from './AdminFormControls'
import { IconPlus, IconChevronRight, IconTrash } from './AdminIcons'
import { StatusBadge } from './AdminCoursesPage'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import ConfirmDeleteModal from './ConfirmDeleteModal'

export default function AdminModuleDetailPage() {
  const { courseSlug, moduleSlug } = useParams<{ courseSlug: string; moduleSlug: string }>()
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()

  const [course, setCourse] = useState<AdminCourse | null>(null)
  const [module, setModule] = useState<AdminModule | null>(null)
  const [labs, setLabs] = useState<AdminLabSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [deleteOpen, setDeleteOpen] = useState(false)

  useEffect(() => {
    if (!courseSlug || !moduleSlug) return
    setLoading(true)
    Promise.all([adminApi.getCourse(courseSlug), adminApi.listModules(courseSlug), adminApi.listLabs(courseSlug, moduleSlug)])
      .then(([c, modules, labList]) => {
        setCourse(c)
        setLabs(labList)
        const found = modules.find(m => m.slug === moduleSlug)
        if (!found) throw new Error('Módulo no encontrado.')
        setModule(found)
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [courseSlug, moduleSlug])

  if (loading) return <PageShell isDark={isDark}><p style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>Cargando…</p></PageShell>
  if (error || !course || !module) return <PageShell isDark={isDark}><ErrorBanner message={error || 'Módulo no encontrado.'} isDark={isDark} /></PageShell>

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[
        { label: 'Panel', to: '/admin' },
        { label: 'Cursos', to: '/admin/courses' },
        { label: course.title, to: `/admin/courses/${courseSlug}` },
        { label: module.title },
      ]} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-6">
        <EditModuleForm isDark={isDark} module={module} onUpdated={setModule} onDeleteClick={() => setDeleteOpen(true)} />

        <div>
          <div className="flex items-center justify-between mb-5">
            <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
              Laboratorios
            </h2>
            <button
              onClick={() => navigate(`/admin/courses/${courseSlug}/${moduleSlug}/new`)}
              className="btn-neon flex items-center gap-2 px-4 py-2 rounded-xl text-[13px]"
            >
              <IconPlus size={12} />
              Nuevo lab
            </button>
          </div>

          {labs.length === 0 && (
            <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
              Este módulo todavía no tiene laboratorios.
            </p>
          )}

          <div className="flex flex-col gap-3">
            {labs.map(lab => (
              <button
                key={lab.id}
                onClick={() => navigate(`/admin/courses/${courseSlug}/${moduleSlug}/${lab.slug}`)}
                className="flex items-center justify-between gap-4 px-5 py-4 rounded-xl text-left transition-all"
                style={{ background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)' }}
              >
                <div>
                  <div className="flex items-center gap-3 mb-1">
                    <p className="font-display" style={{ fontSize: '1rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                      {lab.position}. {lab.title}
                    </p>
                    <StatusBadge published={lab.isPublished} />
                  </div>
                  <p className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
                    /{lab.slug} · {lab.estimatedMinutes} min · {lab.points} pts
                  </p>
                </div>
                <IconChevronRight />
              </button>
            ))}
          </div>
        </div>
      </div>

      <ConfirmDeleteModal
        open={deleteOpen}
        title={`el módulo "${module.title}"`}
        warningDetail={`Esto borrará ${labs.length} laboratorio(s) de este módulo, junto con sus preguntas y el progreso de los estudiantes.`}
        requireTypedSlug={module.slug}
        onCancel={() => setDeleteOpen(false)}
        onConfirm={async () => { await adminApi.deleteModule(module.id); navigate(`/admin/courses/${courseSlug}`) }}
      />
    </PageShell>
  )
}

function EditModuleForm({
  isDark, module, onUpdated, onDeleteClick,
}: { isDark: boolean; module: AdminModule; onUpdated: (m: AdminModule) => void; onDeleteClick: () => void }) {
  const [title, setTitle] = useState(module.title)
  const [slug, setSlug] = useState(module.slug)
  const [description, setDescription] = useState(module.description ?? '')
  const [position, setPosition] = useState(String(module.position))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setError('')
    try {
      const updated = await adminApi.updateModule(module.id, { title, slug, description, position: Number(position) })
      onUpdated({ ...module, ...updated })
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={handleSave} className="p-7 rounded-2xl space-y-5 h-fit" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
      <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        Editar módulo
      </h2>
      <AdminInput label="Título" value={title} onChange={setTitle} isDark={isDark} />
      <AdminInput label="Slug" value={slug} onChange={setSlug} isDark={isDark} />
      <AdminTextarea label="Descripción" value={description} onChange={setDescription} isDark={isDark} rows={3} />
      <AdminInput label="Posición" type="number" value={position} onChange={setPosition} isDark={isDark} />

      {error && <ErrorBanner message={error} isDark={isDark} />}

      <div className="flex items-center gap-3">
        <button type="submit" disabled={saving} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
          {saving ? 'Guardando…' : 'Guardar cambios'}
        </button>
        <button
          type="button"
          onClick={onDeleteClick}
          className="ml-auto flex items-center gap-2 px-4 py-2.5 rounded-xl text-[13px] font-medium"
          style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
        >
          <IconTrash size={13} />
          Borrar módulo
        </button>
      </div>
    </form>
  )
}
