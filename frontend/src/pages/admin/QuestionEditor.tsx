import { useState } from 'react'
import { adminApi, type AdminQuestion, type AdminOption } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, ErrorBanner } from './AdminFormControls'
import { IconPlus, IconTrash, IconCheck } from './AdminIcons'
import ConfirmDeleteModal from './ConfirmDeleteModal'

interface Props {
  order: number
  labId: string
  question: AdminQuestion | null
  isDark: boolean
  onSaved: (q: AdminQuestion) => void
  onDeleted: () => void
}

type QuestionType = 'multiple_choice' | 'activity_response'

export default function QuestionEditor({ order, labId, question, isDark, onSaved, onDeleted }: Props) {
  const [collapsed, setCollapsed] = useState(!!question)
  const [pickingType, setPickingType] = useState(false)
  const [draftType, setDraftType] = useState<QuestionType | null>(null)
  const [deleteOpen, setDeleteOpen] = useState(false)

  const boxStyle = {
    background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
    border: '1px solid rgba(26,63,150,0.14)',
  }

  if (!question && !pickingType) {
    return (
      <button
        onClick={() => setPickingType(true)}
        className="w-full flex items-center justify-center gap-2 px-5 py-6 rounded-xl text-[14px] font-medium transition-all"
        style={{ ...boxStyle, color: isDark ? '#7B9FE8' : '#1A3F96', borderStyle: 'dashed' }}
      >
        <IconPlus size={13} />
        Agregar pregunta {order}
      </button>
    )
  }

  if (!question && pickingType && !draftType) {
    return (
      <div className="p-6 rounded-xl space-y-4" style={boxStyle}>
        <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
          Pregunta {order} — elige el tipo
        </p>
        <div className="flex gap-3 flex-wrap">
          <button onClick={() => setDraftType('multiple_choice')} className="btn-ghost-light px-5 py-3 rounded-xl text-[14px]">
            Opción múltiple
          </button>
          <button onClick={() => setDraftType('activity_response')} className="btn-ghost-light px-5 py-3 rounded-xl text-[14px]">
            Actividad práctica
          </button>
        </div>
        <button onClick={() => setPickingType(false)} className="text-[13px] underline" style={{ color: '#4A70CC' }}>
          Cancelar
        </button>
      </div>
    )
  }

  if (!question && draftType) {
    return (
      <NewQuestionForm
        labId={labId}
        order={order}
        questionType={draftType}
        isDark={isDark}
        onCreated={q => { onSaved(q); setPickingType(false); setDraftType(null) }}
        onCancel={() => { setDraftType(null); setPickingType(false) }}
      />
    )
  }

  if (question && collapsed) {
    return (
      <div className="flex items-center justify-between gap-4 p-5 rounded-xl" style={boxStyle}>
        <div>
          <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
            Pregunta {order} · {question.questionType === 'multiple_choice' ? 'Opción múltiple' : 'Actividad práctica'}
          </p>
          <p className="text-[14px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>{question.questionText}</p>
        </div>
        <div className="flex items-center gap-2 shrink-0">
          <button onClick={() => setCollapsed(false)} className="btn-ghost-light px-4 py-2 rounded-lg text-[13px]">
            Editar
          </button>
          <button
            onClick={() => setDeleteOpen(true)}
            className="flex items-center justify-center w-9 h-9 rounded-lg"
            style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
          >
            <IconTrash size={13} />
          </button>
        </div>
        <ConfirmDeleteModal
          open={deleteOpen}
          title={`la pregunta ${order}`}
          onCancel={() => setDeleteOpen(false)}
          onConfirm={async () => { await adminApi.deleteQuestion(question.id); onDeleted() }}
        />
      </div>
    )
  }

  return (
    <ExistingQuestionEditor question={question!} order={order} isDark={isDark} onSaved={onSaved} onCollapse={() => setCollapsed(true)} />
  )
}

function NewQuestionForm({
  labId, order, questionType, isDark, onCreated, onCancel,
}: {
  labId: string; order: number; questionType: QuestionType; isDark: boolean
  onCreated: (q: AdminQuestion) => void; onCancel: () => void
}) {
  const [questionText, setQuestionText] = useState('')
  const [explanation, setExplanation] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const question = await adminApi.createQuestion(labId, {
        questionOrder: order, questionType, questionText, explanation: explanation || undefined,
      })
      onCreated({ ...question, options: [], activity: null })
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="p-6 rounded-xl space-y-4" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
      <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        Pregunta {order} — {questionType === 'multiple_choice' ? 'Opción múltiple' : 'Actividad práctica'}
      </p>
      <AdminInput label="Texto de la pregunta" value={questionText} onChange={setQuestionText} isDark={isDark} />
      <AdminTextarea label="Explicación (se muestra tras responder)" value={explanation} onChange={setExplanation} isDark={isDark} rows={2} />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <div className="flex items-center gap-3">
        <button type="submit" disabled={loading} className="btn-neon px-5 py-2.5 rounded-xl text-[13px] disabled:opacity-50">
          {loading ? 'Creando…' : 'Crear pregunta'}
        </button>
        <button type="button" onClick={onCancel} className="text-[13px] underline" style={{ color: '#4A70CC' }}>
          Cancelar
        </button>
      </div>
    </form>
  )
}

function ExistingQuestionEditor({
  question, order, isDark, onSaved, onCollapse,
}: { question: AdminQuestion; order: number; isDark: boolean; onSaved: (q: AdminQuestion) => void; onCollapse: () => void }) {
  const [questionText, setQuestionText] = useState(question.questionText)
  const [explanation, setExplanation] = useState(question.explanation ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleSaveText = async () => {
    setSaving(true)
    setError('')
    try {
      const updated = await adminApi.updateQuestion(question.id, { questionText, explanation })
      onSaved({ ...question, ...updated, options: question.options, activity: question.activity })
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="p-6 rounded-xl space-y-5" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff', border: '1px solid rgba(26,63,150,0.14)',
    }}>
      <div className="flex items-center justify-between">
        <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
          Pregunta {order} · {question.questionType === 'multiple_choice' ? 'Opción múltiple' : 'Actividad práctica'}
        </p>
        <button onClick={onCollapse} className="text-[13px] underline" style={{ color: '#4A70CC' }}>
          Cerrar
        </button>
      </div>

      <AdminInput label="Texto de la pregunta" value={questionText} onChange={setQuestionText} isDark={isDark} />
      <AdminTextarea label="Explicación" value={explanation} onChange={setExplanation} isDark={isDark} rows={2} />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <button onClick={handleSaveText} disabled={saving} className="btn-ghost-light px-5 py-2 rounded-xl text-[13px] disabled:opacity-50">
        {saving ? 'Guardando…' : 'Guardar texto'}
      </button>

      {question.questionType === 'multiple_choice' ? (
        <OptionsEditor question={question} isDark={isDark} onChanged={opts => onSaved({ ...question, options: opts })} />
      ) : (
        <ActivityEditor question={question} isDark={isDark} onChanged={activity => onSaved({ ...question, activity })} />
      )}
    </div>
  )
}

function OptionsEditor({
  question, isDark, onChanged,
}: { question: AdminQuestion; isDark: boolean; onChanged: (options: AdminOption[]) => void }) {
  const [error, setError] = useState('')

  const handleAdd = async () => {
    setError('')
    try {
      const option = await adminApi.createOption(question.id, {
        optionOrder: question.options.length + 1, optionText: 'Nueva opción', isCorrect: question.options.length === 0,
      })
      onChanged([...question.options, option])
    } catch (err: any) {
      setError(err.message)
    }
  }

  const handleTextChange = (id: string, text: string) => {
    onChanged(question.options.map(o => o.id === id ? { ...o, optionText: text } : o))
  }

  const handleTextBlur = async (option: AdminOption) => {
    try {
      await adminApi.updateOption(question.id, option.id, { optionText: option.optionText })
    } catch (err: any) {
      setError(err.message)
    }
  }

  const handleMarkCorrect = async (id: string) => {
    setError('')
    try {
      await adminApi.updateOption(question.id, id, { isCorrect: true })
      onChanged(question.options.map(o => ({ ...o, isCorrect: o.id === id })))
    } catch (err: any) {
      setError(err.message)
    }
  }

  const handleDelete = async (id: string) => {
    setError('')
    try {
      await adminApi.deleteOption(question.id, id)
      onChanged(question.options.filter(o => o.id !== id))
    } catch (err: any) {
      setError(err.message)
    }
  }

  return (
    <div className="space-y-3 pt-2" style={{ borderTop: `1px solid ${isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.10)'}` }}>
      <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        Opciones — marca la correcta
      </p>
      {error && <ErrorBanner message={error} isDark={isDark} />}
      {question.options.map(option => (
        <div key={option.id} className="flex items-center gap-3">
          <button
            onClick={() => handleMarkCorrect(option.id)}
            aria-label="Marcar como correcta"
            className="flex items-center justify-center w-6 h-6 rounded-full shrink-0 transition-colors"
            style={{
              border: `2px solid ${option.isCorrect ? '#52ad70' : 'rgba(26,63,150,0.35)'}`,
              color: '#52ad70',
              background: option.isCorrect ? 'rgba(82,173,112,0.12)' : 'transparent',
            }}
          >
            {option.isCorrect && <IconCheck size={12} />}
          </button>
          <input
            value={option.optionText}
            onChange={e => handleTextChange(option.id, e.target.value)}
            onBlur={() => handleTextBlur(option)}
            className="flex-1 px-4 py-2 rounded-lg text-[14px] outline-none"
            style={{ background: isDark ? 'rgba(6,13,31,0.5)' : '#ffffff', border: '1px solid rgba(26,63,150,0.25)', color: isDark ? '#C8D5EE' : '#0A1545' }}
          />
          <button
            onClick={() => handleDelete(option.id)}
            disabled={question.options.length <= 2}
            className="flex items-center justify-center w-9 h-9 rounded-lg shrink-0 disabled:opacity-30 disabled:cursor-not-allowed"
            style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
          >
            <IconTrash size={13} />
          </button>
        </div>
      ))}
      <button onClick={handleAdd} className="flex items-center gap-2 text-[13px] font-medium" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        <IconPlus size={12} />
        Agregar opción
      </button>
    </div>
  )
}

function ActivityEditor({
  question, isDark, onChanged,
}: { question: AdminQuestion; isDark: boolean; onChanged: (activity: AdminQuestion['activity']) => void }) {
  const activity = question.activity
  const [title, setTitle] = useState(activity?.title ?? '')
  const [instructionsMarkdown, setInstructionsMarkdown] = useState(activity?.instructionsMarkdown ?? '')
  const [expectedActionKey, setExpectedActionKey] = useState(activity?.expectedActionKey ?? '')
  const [successFeedback, setSuccessFeedback] = useState(activity?.successFeedback ?? '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleSave = async () => {
    setSaving(true)
    setError('')
    try {
      if (activity) {
        const updated = await adminApi.updateActivity(activity.id, { title, instructionsMarkdown, expectedActionKey, successFeedback })
        onChanged({ ...activity, ...updated })
      } else {
        const created = await adminApi.createActivity(question.id, { title, instructionsMarkdown, expectedActionKey, successFeedback: successFeedback || undefined })
        onChanged(created)
      }
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="space-y-4 pt-2" style={{ borderTop: `1px solid ${isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.10)'}` }}>
      <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        Actividad práctica
      </p>
      <AdminInput label="Título de la actividad" value={title} onChange={setTitle} isDark={isDark} />
      <AdminTextarea
        label="Instrucciones"
        hint='Admite Markdown: encabezados, bloques de código con ```bash, listas y negrita — igual que el contenido del laboratorio.'
        value={instructionsMarkdown}
        onChange={setInstructionsMarkdown}
        isDark={isDark}
        rows={5}
        mono
      />
      <AdminInput label="Clave de acción esperada" value={expectedActionKey} onChange={setExpectedActionKey} isDark={isDark} placeholder="nmap -sV 10.10.10.1" />
      <AdminInput label="Mensaje de éxito" value={successFeedback} onChange={setSuccessFeedback} isDark={isDark} placeholder="¡Correcto! ..." />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      <button onClick={handleSave} disabled={saving} className="btn-ghost-light px-5 py-2 rounded-xl text-[13px] disabled:opacity-50">
        {saving ? 'Guardando…' : activity ? 'Guardar actividad' : 'Crear actividad'}
      </button>
    </div>
  )
}
