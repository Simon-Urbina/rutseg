import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { adminApi, slugify, type AdminCourse, type AdminModule, type AdminLabSummary, type AdminLabDetail, type AdminQuestion } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, ErrorBanner } from './AdminFormControls'
import { IconTrash } from './AdminIcons'
import { StatusBadge } from './AdminCoursesPage'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import ConfirmDeleteModal from './ConfirmDeleteModal'
import QuestionEditor from './QuestionEditor'

export default function AdminLabEditorPage() {
  const { courseSlug, moduleSlug, labSlug } = useParams<{ courseSlug: string; moduleSlug: string; labSlug: string }>()
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()
  const isNew = labSlug === 'new'

  const [course, setCourse] = useState<AdminCourse | null>(null)
  const [module, setModule] = useState<AdminModule | null>(null)
  const [labs, setLabs] = useState<AdminLabSummary[]>([])
  const [lab, setLab] = useState<AdminLabDetail | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    if (!courseSlug || !moduleSlug || !labSlug) return
    setLoading(true)
    setError('')
    Promise.all([adminApi.getCourse(courseSlug), adminApi.listModules(courseSlug), adminApi.listLabs(courseSlug, moduleSlug)])
      .then(async ([c, modules, labList]) => {
        setCourse(c)
        setLabs(labList)
        const foundModule = modules.find(m => m.slug === moduleSlug)
        if (!foundModule) throw new Error('Módulo no encontrado.')
        setModule(foundModule)

        if (!isNew) {
          const summary = labList.find(l => l.slug === labSlug)
          if (!summary) throw new Error('Laboratorio no encontrado.')
          const detail = await adminApi.getLabDetail(summary.id)
          setLab(detail)
        }
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [courseSlug, moduleSlug, labSlug, isNew])

  if (loading) return <PageShell isDark={isDark}><p style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>Cargando…</p></PageShell>
  if (error || !course || !module) return <PageShell isDark={isDark}><ErrorBanner message={error || 'No encontrado.'} isDark={isDark} /></PageShell>

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[
        { label: 'Panel', to: '/admin' },
        { label: 'Cursos', to: '/admin/courses' },
        { label: course.title, to: `/admin/courses/${courseSlug}` },
        { label: module.title, to: `/admin/courses/${courseSlug}/${moduleSlug}` },
        { label: isNew ? 'Nuevo laboratorio' : lab?.title ?? '' },
      ]} />

      {isNew ? (
        <div className="max-w-xl mt-6">
          <NewLabForm
            isDark={isDark}
            moduleId={module.id}
            nextPosition={labs.length + 1}
            onCreated={created => navigate(`/admin/courses/${courseSlug}/${moduleSlug}/${created.slug}`, { replace: true })}
          />
        </div>
      ) : lab ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-6 items-start">
          <EditLabForm isDark={isDark} lab={lab} onUpdated={patch => setLab(prev => prev ? { ...prev, ...patch } : prev)} onDeleted={() => navigate(`/admin/courses/${courseSlug}/${moduleSlug}`)} />

          <div className="space-y-4">
            <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
              Preguntas ({lab.questions.length}/5)
            </h2>
            {[1, 2, 3, 4, 5].map(order => {
              const question = lab.questions.find(q => q.questionOrder === order) ?? null
              return (
                <QuestionEditor
                  key={order}
                  order={order}
                  labId={lab.id}
                  question={question}
                  isDark={isDark}
                  onSaved={(q: AdminQuestion) =>
                    setLab(prev => prev ? { ...prev, questions: [...prev.questions.filter(x => x.questionOrder !== order), q] } : prev)
                  }
                  onDeleted={() =>
                    setLab(prev => prev ? { ...prev, questions: prev.questions.filter(x => x.questionOrder !== order) } : prev)
                  }
                />
              )
            })}
          </div>
        </div>
      ) : null}
    </PageShell>
  )
}

function NewLabForm({
  isDark, moduleId, nextPosition, onCreated,
}: { isDark: boolean; moduleId: string; nextPosition: number; onCreated: (lab: { slug: string }) => void }) {
  const [title, setTitle] = useState('')
  const [slug, setSlug] = useState('')
  const [slugTouched, setSlugTouched] = useState(false)
  const [contentMarkdown, setContentMarkdown] = useState('')
  const [position, setPosition] = useState(String(nextPosition))
  const [estimatedMinutes, setEstimatedMinutes] = useState('10')
  const [points, setPoints] = useState('0')
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
      const created = await adminApi.createLab(moduleId, {
        slug, title, contentMarkdown, position: Number(position), estimatedMinutes: Number(estimatedMinutes), points: Number(points),
      })
      onCreated(created)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="hud-panel hud-static p-7 space-y-5" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
      '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
    } as React.CSSProperties}>
      <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        Nuevo laboratorio
      </h2>
      <AdminInput label="Título" value={title} onChange={handleTitleChange} isDark={isDark} placeholder="Escaneo de puertos con Nmap" />
      <AdminInput label="Slug" value={slug} onChange={v => { setSlug(v); setSlugTouched(true) }} isDark={isDark} />
      <AdminTextarea
        label="Contenido"
        hint='Admite Markdown: encabezados, bloques de código con ```bash, listas y negrita.'
        value={contentMarkdown}
        onChange={setContentMarkdown}
        isDark={isDark}
        rows={8}
        mono
      />
      <div className="grid grid-cols-3 gap-3">
        <AdminInput label="Posición" type="number" value={position} onChange={setPosition} isDark={isDark} />
        <AdminInput label="Minutos" type="number" value={estimatedMinutes} onChange={setEstimatedMinutes} isDark={isDark} />
        <AdminInput label="Puntos" type="number" value={points} onChange={setPoints} isDark={isDark} />
      </div>
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <button type="submit" disabled={loading} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
        {loading ? 'Creando…' : 'Crear laboratorio'}
      </button>
      <p className="text-[13px]" style={{ color: '#4A70CC' }}>
        Después de crearlo podrás agregar las 5 preguntas y publicarlo.
      </p>
    </form>
  )
}

function EditLabForm({
  isDark, lab, onUpdated, onDeleted,
}: { isDark: boolean; lab: AdminLabDetail; onUpdated: (patch: Partial<AdminLabDetail>) => void; onDeleted: () => void }) {
  const [title, setTitle] = useState(lab.title)
  const [slug, setSlug] = useState(lab.slug)
  const [contentMarkdown, setContentMarkdown] = useState(lab.contentMarkdown)
  const [position, setPosition] = useState(String(lab.position))
  const [estimatedMinutes, setEstimatedMinutes] = useState(String(lab.estimatedMinutes))
  const [points, setPoints] = useState(String(lab.points))
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [deleteOpen, setDeleteOpen] = useState(false)

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setError('')
    try {
      const updated = await adminApi.updateLab(lab.id, {
        title, slug, contentMarkdown, position: Number(position), estimatedMinutes: Number(estimatedMinutes), points: Number(points),
      })
      onUpdated(updated)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  const togglePublish = async () => {
    setError('')
    try {
      const updated = await adminApi.updateLab(lab.id, { isPublished: !lab.isPublished })
      onUpdated(updated)
    } catch (err: any) {
      setError(err.message)
    }
  }

  return (
    <form onSubmit={handleSave} className="hud-panel hud-static p-7 space-y-5 h-fit" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
      '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
    } as React.CSSProperties}>
      <div className="flex items-center justify-between">
        <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Editar laboratorio
        </h2>
        <StatusBadge published={lab.isPublished} />
      </div>

      <AdminInput label="Título" value={title} onChange={setTitle} isDark={isDark} />
      <AdminInput label="Slug" value={slug} onChange={setSlug} isDark={isDark} />
      <AdminTextarea
        label="Contenido"
        hint='Admite Markdown: encabezados, bloques de código con ```bash, listas y negrita.'
        value={contentMarkdown}
        onChange={setContentMarkdown}
        isDark={isDark}
        rows={8}
        mono
      />
      <div className="grid grid-cols-3 gap-3">
        <AdminInput label="Posición" type="number" value={position} onChange={setPosition} isDark={isDark} />
        <AdminInput label="Minutos" type="number" value={estimatedMinutes} onChange={setEstimatedMinutes} isDark={isDark} />
        <AdminInput label="Puntos" type="number" value={points} onChange={setPoints} isDark={isDark} />
      </div>

      {error && <ErrorBanner message={error} isDark={isDark} />}

      <div className="flex items-center gap-3 flex-wrap">
        <button type="submit" disabled={saving} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
          {saving ? 'Guardando…' : 'Guardar cambios'}
        </button>
        <button type="button" onClick={togglePublish} className="btn-ghost-light px-5 py-2.5 rounded-xl text-[14px]">
          {lab.isPublished ? 'Despublicar' : 'Publicar'}
        </button>
        <button
          type="button"
          onClick={() => setDeleteOpen(true)}
          className="ml-auto flex items-center gap-2 px-4 py-2.5 rounded-xl text-[13px] font-medium"
          style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
        >
          <IconTrash size={13} />
          Borrar laboratorio
        </button>
      </div>

      <ConfirmDeleteModal
        open={deleteOpen}
        title={`el laboratorio "${lab.title}"`}
        warningDetail="Esto borrará sus preguntas y el progreso de los estudiantes en este laboratorio."
        requireTypedSlug={lab.slug}
        onCancel={() => setDeleteOpen(false)}
        onConfirm={async () => { await adminApi.deleteLab(lab.id); onDeleted() }}
      />
    </form>
  )
}
