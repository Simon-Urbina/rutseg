import { useEffect, useMemo, useRef, useState } from 'react'
import useSound from 'use-sound'
import risingPercent from '../sounds/rising-percent.wav'
import labFail from '../sounds/lab-fail.wav'
import { useNavigate, useParams } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Footer from '../components/Footer'
import { LogoIcon } from '../components/Logo'
import { Sparkles } from '../components/Sparkles'

// ─── Types ────────────────────────────────────────────────────────────────────

interface LabData {
  lab: {
    id: string; slug: string; title: string; contentMarkdown: string
    estimatedMinutes: number; points: number; quizQuestionsRequired: number
  }
  questions: Question[]
  progress: LabProgress | null
}

interface Question {
  id: string; questionOrder: number
  questionType: 'multiple_choice' | 'activity_response'
  questionText: string; explanation: string
  options: { id: string; optionOrder: number; optionText: string }[]
  activity: Activity | null
}

interface Activity {
  id: string; title: string; instructionsMarkdown: string
  isCompleted: boolean; generatedResponse: string | null
}

interface LabProgress {
  status: string; attemptsCount: number
  bestScorePercent: number; completedAt: string | null
}

interface SubmissionResult {
  attemptNumber: number; correctAnswersCount: number
  totalQuestions: number; scorePercent: number; pointsEarned: number
}

interface QuestionState {
  selectedOptionId?: string
  generatedResponse?: string  // correct answer from terminal
  responseText?: string       // what the user typed/pasted
  checked?: boolean
  isCorrect?: boolean
  correctOptionId?: string | null
  explanation?: string
}

interface CourseNav {
  modules: { slug: string; labs: { slug: string; title: string }[] }[]
}

interface SubmissionHistory {
  attemptNumber: number
  scorePercent: number
  correctAnswersCount: number
  submittedAt: string
}

// ─── Markdown ─────────────────────────────────────────────────────────────────

function esc(s: string) {
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
}

function inline(s: string) {
  return s
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/`([^`]+)`/g, '<code class="md-inline">$1</code>')
}

function tableToHtml(block: string): string {
  const rows = block.split('\n').filter(l => l.trim().startsWith('|'))
  if (rows.length < 2) return ''
  const cells = (row: string) => row.split('|').slice(1, -1).map(c => c.trim())
  const head = cells(rows[0])
  const body = rows.slice(2)
  const th = head.map(h => `<th>${inline(h)}</th>`).join('')
  const trs = body.map(r => `<tr>${cells(r).map(c => `<td>${inline(c)}</td>`).join('')}</tr>`).join('')
  return `<div class="md-table-wrap"><table class="md-table"><thead><tr>${th}</tr></thead><tbody>${trs}</tbody></table></div>`
}

function markdownToHtml(md: string): string {
  const blocks = md.split(/\n\n+/)
  return blocks.map(block => {
    const b = block.trim()
    if (!b) return ''
    if (b.startsWith('```')) {
      const code = b.replace(/^```\w*\n?/, '').replace(/\n?```$/, '').trim()
      return `<pre class="md-pre"><code>${esc(code)}</code></pre>`
    }
    if (b.includes('|') && b.includes('\n')) return tableToHtml(b)
    if (b.startsWith('## ')) return `<h2 class="md-h2">${inline(b.slice(3))}</h2>`
    if (b.startsWith('### ')) return `<h3 class="md-h3">${inline(b.slice(4))}</h3>`
    if (b.startsWith('- ') || b.startsWith('* ')) {
      const items = b.split('\n').map(l => `<li>${inline(l.replace(/^[-*]\s+/, ''))}</li>`).join('')
      return `<ul class="md-list">${items}</ul>`
    }
    return `<p class="md-p">${inline(b.replace(/\n/g, ' '))}</p>`
  }).join('')
}

function mdToTerminalLines(md: string) {
  type L = { type: 'heading' | 'text' | 'code' | 'blank'; text: string }
  const lines: L[] = []
  for (const block of md.split(/\n\n+/)) {
    const b = block.trim()
    if (!b) { lines.push({ type: 'blank', text: '' }); continue }
    if (b.startsWith('```')) {
      const code = b.replace(/^```\w*\n?/, '').replace(/\n?```$/, '').trim()
      lines.push({ type: 'blank', text: '' })
      for (const l of code.split('\n')) lines.push({ type: 'code', text: l })
      lines.push({ type: 'blank', text: '' })
    } else if (b.startsWith('#')) {
      lines.push({ type: 'heading', text: b.replace(/^#+\s+/, '') })
    } else {
      const plain = b.replace(/\*\*(.*?)\*\*/g, '$1').replace(/`([^`]+)`/g, '$1')
      for (const l of plain.split('\n')) if (l.trim()) lines.push({ type: 'text', text: l.trim() })
    }
  }
  return lines
}

function formatDate(iso: string): string {
  const d = new Date(iso)
  const month = d.toLocaleDateString('es-CO', { month: 'long' })
  return `${d.getFullYear()} - ${d.getDate()} de ${month}`
}

function extractCommand(md: string): string {
  const m = md.match(/```[^\n]*\n([\s\S]*?)```/)
  if (!m) return ''
  return m[1].trim().split('\n').filter(l => l.trim()).pop()?.trim() ?? ''
}

// ─── SimpleMarkdown ───────────────────────────────────────────────────────────

function SimpleMarkdown({ content, isDark }: { content: string; isDark: boolean }) {
  return (
    <div
      className="lab-prose"
      dangerouslySetInnerHTML={{ __html: markdownToHtml(content) }}
      data-dark={isDark}
    />
  )
}

// ─── Terminal side panel ──────────────────────────────────────────────────────

type HLine = { type: 'heading' | 'text' | 'code' | 'blank' | 'input' | 'output' | 'success' | 'error'; text: string }

function TerminalPanel({
  activity, questionId, isDark, onClose, onComplete,
}: {
  activity: Activity; questionId: string; isDark: boolean
  onClose: () => void
  onComplete: (questionId: string, generatedResponse: string) => void
}) {
  const [history, setHistory] = useState<HLine[]>(() => {
    const init: HLine[] = [
      { type: 'heading', text: 'RutSeg — Terminal Simulado' },
      { type: 'blank', text: '' },
      ...mdToTerminalLines(activity.instructionsMarkdown),
      { type: 'blank', text: '' },
    ]
    if (activity.isCompleted && activity.generatedResponse) {
      init.push({ type: 'success', text: '// Actividad ya completada — respuesta registrada:' })
      for (const l of activity.generatedResponse.split('\n')) init.push({ type: 'output', text: l })
    }
    return init
  })
  const [input, setInput] = useState('')
  const [busy, setBusy] = useState(false)
  const [done, setDone] = useState(activity.isCompleted)
  const [clock, setClock] = useState(new Date())
  const scrollRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)
  const suggest = extractCommand(activity.instructionsMarkdown)

  useEffect(() => {
    const id = setInterval(() => setClock(new Date()), 1000)
    return () => clearInterval(id)
  }, [])

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: 'smooth' })
  }, [history])

  const run = async () => {
    const cmd = input.trim()
    if (!cmd || busy) return
    setInput('')
    setHistory(h => [...h, { type: 'input', text: `root@rutseg:~# ${cmd}` }])
    setBusy(true)
    try {
      const res = await api.post<{ isCorrect: boolean; feedback: string; generatedResponse: string | null }>(
        `/api/activities/${activity.id}/attempt`, { action: cmd },
      )
      if (res.isCorrect && res.generatedResponse) {
        const outLines: HLine[] = res.generatedResponse.split('\n').map(t => ({ type: 'output' as const, text: t }))
        setHistory(h => [...h, { type: 'blank', text: '' }, ...outLines, { type: 'blank', text: '' }, { type: 'success', text: `✓  ${res.feedback}` }])
        setDone(true)
        onComplete(questionId, res.generatedResponse)
      } else {
        setHistory(h => [...h,
          { type: 'error', text: `bash: ${cmd}: command not found` },
          { type: 'text', text: res.feedback },
        ])
        inputRef.current?.focus()
      }
    } catch (err: any) {
      setHistory(h => [...h, { type: 'error', text: `Error: ${err.message}` }])
      inputRef.current?.focus()
    } finally {
      setBusy(false)
    }
  }

  const lineColor: Record<HLine['type'], string> = {
    heading: '#2596be', text: '#8899bb', code: '#F5C500',
    blank: 'transparent', input: '#C8D5EE',
    output: '#4ade80', success: '#4ade80', error: '#f87171',
  }

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-40"
        style={{ background: 'rgba(4,8,16,0.55)', backdropFilter: 'blur(2px)' }}
        onClick={onClose}
      />

      {/* Slide-in panel */}
      <div
        className="fixed top-0 right-0 z-50 flex flex-col"
        style={{
          width: 'min(580px, 100vw)',
          height: '100dvh',
          background: 'linear-gradient(150deg, #040912 0%, #060d1a 100%)',
          borderLeft: `1px solid ${isDark ? 'rgba(0,200,100,0.10)' : 'rgba(0,200,100,0.14)'}`,
          boxShadow: '-20px 0 80px rgba(0,0,0,0.6)',
          animation: 'slideInRight 0.28s cubic-bezier(0.22,1,0.36,1)',
        }}
      >
        {/* Grid wallpaper */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            backgroundImage: `
              linear-gradient(rgba(0,200,100,0.03) 1px, transparent 1px),
              linear-gradient(90deg, rgba(0,200,100,0.03) 1px, transparent 1px)
            `,
            backgroundSize: '28px 28px',
          }}
        />
        {/* Logo watermark */}
        <div className="absolute bottom-12 right-4 pointer-events-none" style={{ opacity: 0.04 }}>
          <LogoIcon className="w-56 h-56" />
        </div>

        {/* Panel header */}
        <div
          className="relative z-10 flex items-center gap-3 px-5 py-3.5 shrink-0"
          style={{ borderBottom: '1px solid rgba(0,200,100,0.08)' }}
        >
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#4ade80" strokeWidth="2.5" strokeLinecap="round">
            <polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/>
          </svg>
          <span className="font-mono text-[11px] tracking-[0.15em] uppercase flex-1 truncate" style={{ color: '#3A5AB8' }}>
            {activity.title}
          </span>
          <button
            onClick={onClose}
            className="font-mono text-[13px] w-6 h-6 flex items-center justify-center rounded transition-colors"
            style={{ color: '#3A5AB8' }}
            onMouseEnter={e => (e.currentTarget.style.color = '#f87171')}
            onMouseLeave={e => (e.currentTarget.style.color = '#3A5AB8')}
          >
            ✕
          </button>
        </div>

        {/* Terminal window */}
        <div
          className="relative z-10 flex-1 flex flex-col m-4 rounded-xl overflow-hidden"
          style={{
            background: 'rgba(6,10,18,0.97)',
            border: '1px solid rgba(0,200,100,0.10)',
            boxShadow: '0 8px 40px rgba(0,0,0,0.5)',
          }}
        >
          {/* Title bar */}
          <div
            className="flex items-center gap-2 px-4 py-2.5 shrink-0"
            style={{ borderBottom: '1px solid rgba(0,200,100,0.06)', background: 'rgba(10,16,28,0.8)' }}
          >
            <button onClick={onClose} className="w-3 h-3 rounded-full hover:opacity-80 transition-opacity" style={{ background: '#ff5f57' }} />
            <span className="w-3 h-3 rounded-full" style={{ background: '#2b2b2b' }} />
            <span className="w-3 h-3 rounded-full" style={{ background: '#2b2b2b' }} />
            <span className="flex-1 text-center font-mono text-[10px] tracking-[0.12em]" style={{ color: '#3A5AB8' }}>
              Terminal — root@rutseg:~
            </span>
          </div>

          {/* Output */}
          <div
            ref={scrollRef}
            className="flex-1 overflow-y-auto px-5 py-4 font-mono text-[13px] leading-6 space-y-0.5"
            style={{ WebkitOverflowScrolling: 'touch' } as React.CSSProperties}
          >
            {history.map((line, i) => (
              <p key={i} style={{ color: lineColor[line.type], fontWeight: line.type === 'heading' ? 600 : 400 }}>
                {line.text || ' '}
              </p>
            ))}
            {busy && <p style={{ color: '#4ade80' }}>▌</p>}
          </div>

          {/* Input */}
          {!done ? (
            <div
              className="flex items-center gap-2 px-5 py-3 shrink-0"
              style={{ borderTop: '1px solid rgba(0,200,100,0.06)' }}
            >
              <span className="font-mono text-[13px] shrink-0" style={{ color: '#4ade80' }}>
                root@rutseg:~#
              </span>
              <input
                ref={inputRef}
                autoFocus
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && run()}
                disabled={busy}
                placeholder={suggest ? `ej: ${suggest}` : 'escribe el comando...'}
                className="flex-1 bg-transparent outline-none font-mono text-[13px] min-w-0"
                style={{ color: '#C8D5EE', caretColor: '#4ade80' }}
              />
              {suggest && (
                <button
                  onClick={() => { setInput(suggest); inputRef.current?.focus() }}
                  className="font-mono text-[10px] px-2 py-1 rounded shrink-0 transition-colors"
                  style={{ color: '#3A5AB8', border: '1px solid rgba(26,63,150,0.2)' }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
                  onMouseLeave={e => (e.currentTarget.style.color = '#3A5AB8')}
                  title="Autocompletar comando"
                >
                  tab ↹
                </button>
              )}
            </div>
          ) : (
            <div
              className="flex items-center justify-between gap-3 px-5 py-3 shrink-0"
              style={{ borderTop: '1px solid rgba(0,200,100,0.06)' }}
            >
              <span className="font-mono text-[11px]" style={{ color: '#4ade80' }}>
                ↑ Copia la respuesta de arriba, cierra y pégala en el campo
              </span>
              <button
                onClick={onClose}
                className="font-mono text-[11px] px-3 py-1 rounded transition-colors shrink-0"
                style={{ color: '#3A5AB8', border: '1px solid rgba(26,63,150,0.2)' }}
                onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
                onMouseLeave={e => (e.currentTarget.style.color = '#3A5AB8')}
              >
                cerrar
              </button>
            </div>
          )}
        </div>

        {/* Taskbar */}
        <div
          className="relative z-10 shrink-0 flex items-center px-4 gap-3"
          style={{
            background: 'rgba(4,8,16,0.9)',
            borderTop: '1px solid rgba(0,200,100,0.05)',
            height: 'calc(2.5rem + env(safe-area-inset-bottom, 0px))',
            paddingBottom: 'env(safe-area-inset-bottom, 0px)',
          }}
        >
          <button className="w-7 h-7 rounded flex items-center justify-center transition-colors" style={{ color: '#1A3F96' }}
            onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
            onMouseLeave={e => (e.currentTarget.style.color = '#1A3F96')}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
              <rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/>
              <rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>
            </svg>
          </button>
          <div className="flex items-center gap-1.5 px-2.5 h-6 rounded font-mono text-[11px]"
            style={{ background: 'rgba(0,200,100,0.07)', border: '1px solid rgba(0,200,100,0.14)', color: '#4ade80' }}>
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/>
            </svg>
            Terminal
          </div>
          <div className="flex-1" />
          <span className="font-mono text-[11px] tabular-nums" style={{ color: '#3A5AB8' }}>
            {clock.toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit' })}
          </span>
        </div>
      </div>
    </>
  )
}

// ─── Result modal ─────────────────────────────────────────────────────────────

function ResultModal({
  result, isDark, onRetry, onDashboard, nextLab, onNext,
}: {
  result: SubmissionResult; isDark: boolean
  onRetry: () => void; onDashboard: () => void
  nextLab?: { title: string } | null
  onNext?: () => void
}) {
  const passed = result.scorePercent >= 60
  const accent = passed ? '#4ade80' : '#f87171'

  const [displayScore, setDisplayScore] = useState(0)
  const [showSparkles, setShowSparkles] = useState(false)
  // Ref: https://www.joshwcomeau.com/react/announcing-use-sound-react-hook/
  const [playRising] = useSound(risingPercent, { volume: 0.5 })
  const [playPass] = useSound('', { volume: 0.6 })
  const [playFail] = useSound(labFail, { volume: 0.6 })

  useEffect(() => {
    playRising()
    const target = Math.round(result.scorePercent)
    const duration = 1500
    const steps = 60
    let step = 0
    const timer = setInterval(() => {
      step++
      setDisplayScore(Math.round((target * step) / steps))
      if (step >= steps) {
        clearInterval(timer)
        setDisplayScore(target)
        if (passed) {
          playPass()
          setShowSparkles(true)
        } else {
          playFail()
        }
      }
    }, duration / steps)
    return () => clearInterval(timer)
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-6"
      style={{ background: 'rgba(4,8,16,0.75)', backdropFilter: 'blur(8px)' }}
    >
      <div
        className="w-full max-w-sm rounded-2xl p-10 text-center space-y-7 animate-fade-up-1"
        style={{
          background: isDark ? 'rgba(13,22,50,0.97)' : '#ffffff',
          border: `1px solid ${passed ? 'rgba(74,222,128,0.22)' : 'rgba(248,113,113,0.22)'}`,
          boxShadow: `0 0 60px ${passed ? 'rgba(74,222,128,0.08)' : 'rgba(248,113,113,0.08)'}, 0 24px 60px rgba(0,0,0,0.4)`,
        }}
      >
        {/* Score */}
        <div>
          <p className="num-display" style={{ fontSize: '4.5rem', lineHeight: 1, color: accent }}>
            {displayScore}%
          </p>
          <p className="font-mono text-[11px] tracking-[0.2em] uppercase mt-2" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            {result.correctAnswersCount}/{result.totalQuestions} respuestas correctas
          </p>
        </div>

        {/* Status + points */}
        <div className="space-y-2">
          <p className="font-display text-xl" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
            {passed
              ? <Sparkles active={showSparkles}>{result.pointsEarned > 0 ? '¡Lab completado!' : '¡Bien hecho!'}</Sparkles>
              : 'Inténtalo de nuevo'
            }
          </p>
          {result.pointsEarned > 0 && (
            <div className="flex items-center justify-center gap-2">
              <Sparkles active={showSparkles}>
                <span className="font-mono text-[13px] font-semibold" style={{ color: '#F5C500' }}>
                  +{result.pointsEarned} pts
                </span>
              </Sparkles>
              <span className="font-mono text-[11px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
                añadidos a tu perfil
              </span>
            </div>
          )}
          {!passed && (
            <p className="text-[13px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
              Necesitas al menos el 60% para completar el lab.
            </p>
          )}
          <p className="font-mono text-[10px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
            Intento #{result.attemptNumber}
          </p>
        </div>

        {/* Buttons */}
        <div className="flex flex-col gap-3">
          {passed && nextLab && onNext ? (
            <button
              onClick={onNext}
              className="btn-neon w-full py-3.5 rounded-xl text-[14px] font-semibold"
            >
              Siguiente lab →
            </button>
          ) : (
            <button
              onClick={onDashboard}
              className="btn-neon w-full py-3.5 rounded-xl text-[14px] font-semibold"
            >
              Volver al dashboard
            </button>
          )}
          {passed && nextLab && (
            <button
              onClick={onDashboard}
              className="w-full py-3.5 rounded-xl text-[14px] font-mono transition-all"
              style={{
                color: isDark ? '#7B9FE8' : '#1A3F96',
                border: '1px solid rgba(26,63,150,0.22)',
                background: 'rgba(26,63,150,0.05)',
              }}
              onMouseEnter={e => (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.12)'}
              onMouseLeave={e => (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.05)'}
            >
              Ir al dashboard
            </button>
          )}
          {!passed && (
            <button
              onClick={onRetry}
              className="w-full py-3.5 rounded-xl text-[14px] font-mono transition-all"
              style={{
                color: isDark ? '#7B9FE8' : '#1A3F96',
                border: '1px solid rgba(26,63,150,0.22)',
                background: 'rgba(26,63,150,0.05)',
              }}
              onMouseEnter={e => (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.12)'}
              onMouseLeave={e => (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.05)'}
            >
              Intentar de nuevo
            </button>
          )}
        </div>
      </div>
    </div>
  )
}

// ─── Question item ────────────────────────────────────────────────────────────

function QuestionItem({
  q, index, isOpen, isDark, state, onToggle, onSelectOption, onOpenTerminal, onConfirmActivity,
}: {
  q: Question; index: number; isOpen: boolean; isDark: boolean
  state: QuestionState | undefined
  onToggle: () => void
  onSelectOption: (questionId: string, optionId: string) => void
  onOpenTerminal: (activity: Activity) => void
  onConfirmActivity: (questionId: string, userInput: string) => void
}) {
  const [actInput, setActInput] = useState('')
  const isAnswered = q.questionType === 'multiple_choice'
    ? state?.checked
    : !!state?.responseText

  return (
    <div
      className="rounded-xl overflow-hidden transition-all duration-300"
      style={{
        border: `1px solid ${isOpen
          ? 'rgba(26,63,150,0.35)'
          : isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.12)'}`,
        background: isDark ? 'rgba(13,27,70,0.55)' : '#f8faff',
        boxShadow: isOpen ? '0 4px 24px rgba(26,63,150,0.09)' : 'none',
      }}
    >
      {/* Header */}
      <button
        onClick={onToggle}
        className="w-full flex items-center gap-4 px-5 py-4 text-left transition-colors"
        style={{ background: isOpen ? isDark ? 'rgba(26,63,150,0.09)' : 'rgba(26,63,150,0.04)' : 'transparent' }}
      >
        <span
          className="w-8 h-8 rounded-lg flex items-center justify-center font-mono text-[12px] shrink-0 transition-all"
          style={{
            background: isAnswered
              ? state?.isCorrect ? 'rgba(74,222,128,0.12)' : 'rgba(248,113,113,0.12)'
              : isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
            border: `1px solid ${isAnswered
              ? state?.isCorrect ? 'rgba(74,222,128,0.30)' : 'rgba(248,113,113,0.30)'
              : 'rgba(26,63,150,0.22)'}`,
            color: isAnswered
              ? state?.isCorrect ? '#4ade80' : '#f87171'
              : isDark ? '#7B9FE8' : '#1A3F96',
          }}
        >
          {isAnswered ? (state?.isCorrect ? '✓' : '✗') : index + 1}
        </span>
        <div className="flex-1 min-w-0">
          <p className="font-mono text-[10px] tracking-[0.2em] uppercase mb-0.5" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            Pregunta {index + 1} — {q.questionType === 'multiple_choice' ? 'opción múltiple' : 'actividad'}
          </p>
          <p className="text-[14px] truncate" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
            {q.questionText}
          </p>
        </div>
        <svg
          width="15" height="15" viewBox="0 0 24 24" fill="none"
          stroke={isDark ? '#3A5AB8' : '#4A70CC'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
          className="shrink-0 transition-transform duration-200"
          style={{ transform: isOpen ? 'rotate(180deg)' : 'rotate(0deg)' }}
        >
          <polyline points="6 9 12 15 18 9"/>
        </svg>
      </button>

      {/* Body */}
      {isOpen && (
        <div className="px-6 pb-6 pt-2 space-y-5">

          {/* Multiple choice */}
          {q.questionType === 'multiple_choice' && (
            <div className="space-y-2.5">
              {q.options.map(opt => {
                const selected = state?.selectedOptionId === opt.id
                const isCorrectOpt = state?.checked && state.correctOptionId === opt.id
                const isWrongSelection = state?.checked && selected && !state.isCorrect

                let bg = isDark ? 'rgba(26,63,150,0.06)' : 'rgba(255,255,255,0.7)'
                let border = isDark ? 'rgba(26,63,150,0.16)' : 'rgba(26,63,150,0.14)'
                let textColor = isDark ? '#C8D5EE' : '#0A1545'

                if (isCorrectOpt) {
                  bg = 'rgba(74,222,128,0.10)'; border = 'rgba(74,222,128,0.35)'; textColor = '#4ade80'
                } else if (isWrongSelection) {
                  bg = 'rgba(248,113,113,0.10)'; border = 'rgba(248,113,113,0.35)'; textColor = '#f87171'
                } else if (selected && !state?.checked) {
                  bg = isDark ? 'rgba(26,63,150,0.22)' : 'rgba(26,63,150,0.10)'
                  border = '#1A3F96'
                }

                return (
                  <button
                    key={opt.id}
                    disabled={!!state?.checked}
                    onClick={() => !state?.checked && onSelectOption(q.id, opt.id)}
                    className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left transition-all duration-200"
                    style={{ background: bg, border: `1px solid ${border}`, cursor: state?.checked ? 'default' : 'pointer' }}
                  >
                    <span
                      className="w-4 h-4 rounded-full shrink-0 flex items-center justify-center transition-all"
                      style={{ border: `2px solid ${isCorrectOpt ? '#4ade80' : isWrongSelection ? '#f87171' : selected ? '#1A3F96' : isDark ? '#3A5AB8' : '#4A70CC'}` }}
                    >
                      {(selected || isCorrectOpt) && (
                        <span className="w-2 h-2 rounded-full" style={{ background: isCorrectOpt ? '#4ade80' : isWrongSelection ? '#f87171' : '#1A3F96' }} />
                      )}
                    </span>
                    <span className="text-[14px]" style={{ color: textColor }}>{opt.optionText}</span>
                    {isCorrectOpt && <span className="ml-auto font-mono text-[11px]" style={{ color: '#4ade80' }}>✓ correcta</span>}
                    {isWrongSelection && <span className="ml-auto font-mono text-[11px]" style={{ color: '#f87171' }}>✗ incorrecta</span>}
                  </button>
                )
              })}

              {/* Explanation after checking */}
              {state?.checked && state.explanation && (
                <div
                  className="mt-3 px-4 py-3 rounded-xl"
                  style={{
                    background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.05)',
                    border: '1px solid rgba(26,63,150,0.18)',
                    borderLeft: `3px solid ${state.isCorrect ? '#4ade80' : '#f87171'}`,
                  }}
                >
                  <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                    // explicación
                  </p>
                  <p className="text-[13px] leading-relaxed" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    {state.explanation}
                  </p>
                </div>
              )}
            </div>
          )}

          {/* Activity response */}
          {q.questionType === 'activity_response' && q.activity && (
            <div className="space-y-4">
              {/* Activity card */}
              <div
                className="rounded-xl p-4"
                style={{ background: 'rgba(37,150,190,0.06)', border: '1px solid rgba(37,150,190,0.18)' }}
              >
                <p className="font-mono text-[10px] tracking-[0.2em] uppercase mb-1.5" style={{ color: '#2596be' }}>
                  // actividad práctica
                </p>
                <p className="text-[15px] font-medium" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  {q.activity.title}
                </p>
                <p className="text-[13px] mt-1" style={{ color: isDark ? '#4A70CC' : '#2596be' }}>
                  Ejecuta el comando en la terminal, copia la respuesta y pégala abajo.
                </p>
              </div>

              {/* Open terminal button (always visible until confirmed) */}
              {!state?.responseText && (
                <button
                  onClick={() => onOpenTerminal(q.activity!)}
                  className="flex items-center gap-2.5 px-5 py-3 rounded-xl font-mono text-[13px] tracking-wide transition-all duration-150"
                  style={{ background: 'rgba(0,200,100,0.06)', border: '1px solid rgba(0,200,100,0.18)', color: '#4ade80' }}
                  onMouseEnter={e => { const el = e.currentTarget as HTMLElement; el.style.background = 'rgba(0,200,100,0.12)'; el.style.borderColor = 'rgba(0,200,100,0.32)' }}
                  onMouseLeave={e => { const el = e.currentTarget as HTMLElement; el.style.background = 'rgba(0,200,100,0.06)'; el.style.borderColor = 'rgba(0,200,100,0.18)' }}
                >
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round">
                    <polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/>
                  </svg>
                  {state?.generatedResponse ? 'Re-abrir terminal' : 'Abrir terminal'}
                </button>
              )}

              {/* Paste input — shown once terminal has run and produced a response */}
              {state?.generatedResponse && !state?.responseText && (
                <div className="space-y-2">
                  <p className="font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
                    // pega la respuesta del terminal
                  </p>
                  <div className="flex gap-2">
                    <input
                      type="text"
                      value={actInput}
                      onChange={e => setActInput(e.target.value)}
                      onKeyDown={e => { if (e.key === 'Enter') { onConfirmActivity(q.id, actInput); setActInput('') } }}
                      placeholder="Pega aquí la respuesta obtenida…"
                      className="flex-1 px-4 py-2.5 rounded-xl font-mono text-[13px] outline-none transition-all"
                      style={{
                        background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.05)',
                        border: `1px solid ${isDark ? 'rgba(26,63,150,0.28)' : 'rgba(26,63,150,0.22)'}`,
                        color: isDark ? '#C8D5EE' : '#0A1545',
                      }}
                      autoFocus
                    />
                    <button
                      onClick={() => { onConfirmActivity(q.id, actInput); setActInput('') }}
                      disabled={!actInput.trim()}
                      className="px-4 py-2.5 rounded-xl font-mono text-[13px] transition-all disabled:opacity-40"
                      style={{ background: 'rgba(26,63,150,0.15)', border: '1px solid rgba(26,63,150,0.3)', color: isDark ? '#7B9FE8' : '#1A3F96' }}
                    >
                      Confirmar
                    </button>
                  </div>
                </div>
              )}

              {/* Confirmed response */}
              {state?.responseText && (
                <div className="space-y-2.5">
                  <span
                    className="font-mono text-[11px] tracking-[0.15em] uppercase"
                    style={{ color: state.isCorrect ? '#4ade80' : '#f87171' }}
                  >
                    {state.isCorrect ? '✓ Respuesta correcta' : '✗ Respuesta incorrecta'}
                  </span>
                  <div
                    className="font-mono text-[12px] px-4 py-3 rounded-lg overflow-x-auto"
                    style={{
                      background: state.isCorrect ? 'rgba(74,222,128,0.05)' : 'rgba(248,113,113,0.05)',
                      border: `1px solid ${state.isCorrect ? 'rgba(74,222,128,0.18)' : 'rgba(248,113,113,0.18)'}`,
                      color: state.isCorrect ? '#4ade80' : '#f87171',
                      whiteSpace: 'pre-wrap', wordBreak: 'break-all',
                    }}
                  >
                    {state.responseText}
                  </div>
                  {!state.isCorrect && (
                    <button
                      onClick={() => onOpenTerminal(q.activity!)}
                      className="font-mono text-[11px] transition-colors"
                      style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
                      onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
                      onMouseLeave={e => (e.currentTarget.style.color = isDark ? '#3A5AB8' : '#4A70CC')}
                    >
                      → Re-abrir terminal e intentar de nuevo
                    </button>
                  )}
                </div>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

// ─── Main ─────────────────────────────────────────────────────────────────────

export default function LabPage() {
  const { slug, moduleSlug, labSlug } = useParams<{ slug: string; moduleSlug: string; labSlug: string }>()
  const { theme } = useTheme()
  const navigate = useNavigate()
  const isDark = theme === 'dark'

  const [data, setData] = useState<LabData | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const [openQuestions, setOpenQuestions] = useState<Set<number>>(new Set([0]))
  const [questionStates, setQuestionStates] = useState<Record<string, QuestionState>>({})
  const [terminalActivity, setTerminalActivity] = useState<(Activity & { questionId: string }) | null>(null)

  const [submitting, setSubmitting] = useState(false)
  const [submitError, setSubmitError] = useState<string | null>(null)
  const [result, setResult] = useState<SubmissionResult | null>(null)

  const [courseNav, setCourseNav] = useState<CourseNav | null>(null)
  const [attemptHistory, setAttemptHistory] = useState<SubmissionHistory[]>([])
  const [historyOpen, setHistoryOpen] = useState(false)

  // Load lab
  useEffect(() => {
    if (!slug || !moduleSlug || !labSlug) return
    setLoading(true)
    api.get<LabData>(`/api/courses/${slug}/modules/${moduleSlug}/labs/${labSlug}`)
      .then(d => {
        setData(d)
        // Pre-fill already-completed activities
        const init: Record<string, QuestionState> = {}
        for (const q of d.questions) {
          if (q.questionType === 'activity_response' && q.activity?.isCompleted && q.activity.generatedResponse) {
            init[q.id] = { responseText: q.activity.generatedResponse, isCorrect: true }
          }
        }
        setQuestionStates(init)
      })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [slug, moduleSlug, labSlug])

  // Fetch course navigation for next-lab computation
  useEffect(() => {
    if (!slug) return
    api.get<CourseNav>(`/api/courses/${slug}/nav`).then(setCourseNav).catch(() => {})
  }, [slug])

  // Fetch attempt history once lab data is loaded
  useEffect(() => {
    if (!data) return
    api.get<SubmissionHistory[]>(`/api/labs/${data.lab.id}/submissions`).then(setAttemptHistory).catch(() => {})
  }, [data?.lab.id])

  const nextLab = useMemo(() => {
    if (!courseNav || !moduleSlug || !labSlug) return null
    const flat = courseNav.modules.flatMap(m => m.labs.map(l => ({ moduleSlug: m.slug, ...l })))
    const idx = flat.findIndex(l => l.moduleSlug === moduleSlug && l.slug === labSlug)
    return idx >= 0 && idx + 1 < flat.length ? flat[idx + 1] : null
  }, [courseNav, moduleSlug, labSlug])

  // Open next question (keeps current open)
  const advanceAfter = (currentIndex: number, delay: number) => {
    if (!data) return
    setTimeout(() => {
      const next = currentIndex + 1
      if (next < data.questions.length)
        setOpenQuestions(prev => new Set([...prev, next]))
    }, delay)
  }

  // Select a multiple-choice option → call check API → feedback + auto-advance
  const handleSelectOption = async (questionId: string, optionId: string) => {
    if (!data || questionStates[questionId]?.checked) return
    // Optimistic UI: mark as selected
    setQuestionStates(prev => ({ ...prev, [questionId]: { ...prev[questionId], selectedOptionId: optionId } }))
    try {
      const res = await api.post<{ isCorrect: boolean; correctOptionId: string | null; explanation: string }>(
        `/api/labs/${data.lab.id}/check`, { questionId, selectedOptionId: optionId },
      )
      setQuestionStates(prev => ({
        ...prev,
        [questionId]: {
          selectedOptionId: optionId,
          checked: true,
          isCorrect: res.isCorrect,
          correctOptionId: res.correctOptionId,
          explanation: res.explanation,
        },
      }))
      const idx = data.questions.findIndex(q => q.id === questionId)
      advanceAfter(idx, res.isCorrect ? 1200 : 2800)
    } catch {
      // If check fails, keep selection without feedback
    }
  }

  // Terminal ran the correct command — store expected answer, let user copy it manually
  const handleActivityComplete = (questionId: string, generatedResponse: string) => {
    setQuestionStates(prev => ({ ...prev, [questionId]: { ...prev[questionId], generatedResponse } }))
    // Terminal stays open so user can copy the output; they close it themselves
  }

  // User confirmed their pasted/typed response
  const handleConfirmActivity = (questionId: string, userInput: string) => {
    if (!data || !userInput.trim()) return
    const expected = questionStates[questionId]?.generatedResponse ?? ''
    const isCorrect = userInput.trim() === expected.trim()
    setQuestionStates(prev => ({
      ...prev,
      [questionId]: { ...prev[questionId], responseText: userInput, isCorrect },
    }))
    if (isCorrect) {
      const idx = data.questions.findIndex(q => q.id === questionId)
      advanceAfter(idx, 1200)
    }
  }

  // Submit all answers
  const handleSubmit = async () => {
    if (!data) return
    const answersArray = data.questions.map(q => {
      const s = questionStates[q.id]
      return q.questionType === 'multiple_choice'
        ? { questionId: q.id, selectedOptionId: s?.selectedOptionId }
        : { questionId: q.id, responseText: s?.responseText }
    })
    setSubmitting(true)
    setSubmitError(null)
    try {
      const res = await api.post<SubmissionResult>(`/api/labs/${data.lab.id}/submit`, { answers: answersArray })
      setResult(res)
    } catch (err: any) {
      setSubmitError(err.message)
    } finally {
      setSubmitting(false)
    }
  }

  const handleRetry = () => {
    setResult(null)
    setQuestionStates({})
    setOpenQuestions(new Set([0]))
    setSubmitError(null)
  }

  const handleNext = () => {
    if (!nextLab) return
    setResult(null)
    setQuestionStates({})
    setOpenQuestions(new Set([0]))
    setSubmitError(null)
    navigate(`/courses/${slug}/${nextLab.moduleSlug}/${nextLab.slug}`)
  }

  const answeredCount = data
    ? data.questions.filter(q => {
        const s = questionStates[q.id]
        return q.questionType === 'multiple_choice' ? s?.checked : !!s?.responseText
      }).length
    : 0
  const allAnswered = data ? answeredCount === data.questions.length : false

  // ── Loading / Error ─────────────────────────────────────────────────────────

  if (loading) {
    return (
      <div className="min-h-screen flex flex-col" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
        <Header />
        <div className="flex-1 flex items-center justify-center flex-col gap-4">
          <div className="w-10 h-10 rounded-full border-2 border-t-transparent animate-spin"
            style={{ borderColor: '#1A3F96', borderTopColor: 'transparent' }} />
          <p className="font-mono text-[11px] tracking-[0.2em] uppercase" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            Cargando laboratorio…
          </p>
        </div>
        <Footer />
      </div>
    )
  }

  if (error || !data) {
    return (
      <div className="min-h-screen flex flex-col" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
        <Header />
        <div className="flex-1 flex items-center justify-center flex-col gap-6">
          <p className="font-display text-xl" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
            {error ?? 'Laboratorio no encontrado.'}
          </p>
          <button onClick={() => navigate(`/courses/${slug}`)} className="btn-neon px-6 py-3 rounded-xl text-[14px]">
            ← Volver al curso
          </button>
        </div>
        <Footer />
      </div>
    )
  }

  // ── Render ──────────────────────────────────────────────────────────────────

  return (
    <div className="min-h-screen flex flex-col" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <Header />

      <main className="flex-1 max-w-4xl mx-auto w-full px-6 py-12 space-y-14">

        {/* Lab title */}
        <div className="animate-fade-up-1">
          <button
            onClick={() => navigate(`/courses/${slug}`)}
            className="flex items-center gap-1.5 font-mono text-[11px] tracking-[0.18em] uppercase mb-6 transition-colors"
            style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
            onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
            onMouseLeave={e => (e.currentTarget.style.color = isDark ? '#3A5AB8' : '#4A70CC')}
          >
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <polyline points="15 18 9 12 15 6"/>
            </svg>
            Volver al curso
          </button>

          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // laboratorio · {data.lab.estimatedMinutes} min · {data.lab.points} pts
          </p>
          <h1 className="font-display mb-5"
            style={{ fontSize: 'clamp(1.9rem, 4vw, 2.8rem)', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}>
            {data.lab.title}
          </h1>

          {data.progress && data.progress.status !== 'not_started' && (
            <div className="flex items-center gap-3">
              <span
                className="font-mono text-[11px] tracking-[0.15em] uppercase px-3 py-1.5 rounded-lg"
                style={{
                  background: data.progress.status === 'completed' ? 'rgba(74,222,128,0.08)' : 'rgba(245,197,0,0.08)',
                  border: `1px solid ${data.progress.status === 'completed' ? 'rgba(74,222,128,0.25)' : 'rgba(245,197,0,0.25)'}`,
                  color: data.progress.status === 'completed' ? '#4ade80' : '#F5C500',
                }}
              >
                {data.progress.status === 'completed' ? '✓ Completado' : 'En progreso'}
              </span>
              <span className="font-mono text-[11px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                {data.progress.attemptsCount} intento{data.progress.attemptsCount !== 1 ? 's' : ''} · mejor: {Math.round(data.progress.bestScorePercent)}%
              </span>
            </div>
          )}
        </div>

        {/* Lab content */}
        <section className="animate-fade-up-2">
          <SimpleMarkdown content={data.lab.contentMarkdown} isDark={isDark} />
        </section>

        {/* Divider */}
        <div className="relative animate-fade-up-3">
          <div className="h-px w-full" style={{ background: isDark ? 'rgba(26,63,150,0.2)' : 'rgba(26,63,150,0.15)' }} />
          <div className="absolute inset-0 flex items-center justify-center">
            <span
              className="px-5 font-mono text-[10px] tracking-[0.28em] uppercase"
              style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // quiz · {data.lab.quizQuestionsRequired} preguntas
            </span>
          </div>
        </div>

        {/* Attempt history */}
        {attemptHistory.length > 0 && (
          <div className="animate-fade-up-3">
            <button
              onClick={() => setHistoryOpen(h => !h)}
              className="w-full flex items-center justify-between px-5 py-3.5 rounded-xl transition-all"
              style={{
                background: isDark ? 'rgba(13,27,70,0.55)' : '#f8faff',
                border: `1px solid ${isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.12)'}`,
              }}
            >
              <div className="flex items-center gap-3">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={isDark ? '#3A5AB8' : '#1A3F96'} strokeWidth="2" strokeLinecap="round">
                  <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                </svg>
                <span className="font-mono text-[11px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
                  Intentos anteriores
                </span>
                <span
                  className="font-mono text-[10px] px-2 py-0.5 rounded"
                  style={{ background: isDark ? 'rgba(26,63,150,0.18)' : 'rgba(26,63,150,0.10)', color: isDark ? '#7B9FE8' : '#1A3F96' }}
                >
                  {attemptHistory.length}
                </span>
              </div>
              <svg
                width="14" height="14" viewBox="0 0 24 24" fill="none"
                stroke={isDark ? '#3A5AB8' : '#4A70CC'} strokeWidth="2" strokeLinecap="round"
                style={{ transform: historyOpen ? 'rotate(180deg)' : 'rotate(0deg)', transition: 'transform 0.2s' }}
              >
                <polyline points="6 9 12 15 18 9"/>
              </svg>
            </button>

            {historyOpen && (
              <div className="mt-2 space-y-2">
                {attemptHistory.map(h => {
                  const ok = h.scorePercent >= 60
                  return (
                    <div
                      key={h.attemptNumber}
                      className="flex items-center gap-4 px-5 py-3 rounded-xl"
                      style={{
                        background: isDark ? 'rgba(13,27,70,0.35)' : 'rgba(248,250,255,0.8)',
                        border: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.09)'}`,
                      }}
                    >
                      <span className="font-mono text-[11px] shrink-0" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                        #{h.attemptNumber}
                      </span>
                      <div
                        className="font-mono text-[13px] font-semibold"
                        style={{ color: ok ? '#4ade80' : '#f87171', minWidth: '3.5rem' }}
                      >
                        {Math.round(h.scorePercent)}%
                      </div>
                      <span className="text-[12px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
                        {h.correctAnswersCount} correctas
                      </span>
                      <span className="ml-auto font-mono text-[11px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                        {formatDate(h.submittedAt)}
                      </span>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        )}

        {/* Questions */}
        <section className="space-y-3 animate-fade-up-3">
          {data.questions.map((q, i) => (
            <QuestionItem
              key={q.id}
              q={q}
              index={i}
              isOpen={openQuestions.has(i)}
              isDark={isDark}
              state={questionStates[q.id]}
              onToggle={() => setOpenQuestions(prev => {
                const next = new Set(prev)
                if (next.has(i)) next.delete(i); else next.add(i)
                return next
              })}
              onSelectOption={handleSelectOption}
              onOpenTerminal={activity => setTerminalActivity({ ...activity, questionId: q.id })}
              onConfirmActivity={handleConfirmActivity}
            />
          ))}
        </section>

        {/* Submit */}
        <div className="flex flex-col items-center gap-5 pb-8 animate-fade-up-3">
          <div className="w-full max-w-sm">
            <div className="flex justify-between font-mono text-[10px] tracking-[0.15em] uppercase mb-2"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              <span>Progreso del quiz</span>
              <span>{answeredCount}/{data.questions.length}</span>
            </div>
            <div className="h-1.5 rounded-full overflow-hidden" style={{ background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.10)' }}>
              <div
                className="h-full rounded-full transition-all duration-500"
                style={{ width: `${(answeredCount / data.questions.length) * 100}%`, background: 'linear-gradient(90deg, #1A3F96, #2596be)' }}
              />
            </div>
          </div>

          <button
            onClick={handleSubmit}
            disabled={!allAnswered || submitting}
            className="btn-neon px-10 py-4 rounded-xl text-[15px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {submitting ? <span className="font-mono text-[13px] tracking-[0.15em]">Enviando…</span> : 'Enviar respuestas'}
          </button>

          {submitError && (
            <p className="text-[13px] text-center" style={{ color: '#f87171' }}>{submitError}</p>
          )}
        </div>
      </main>

      <Footer />

      {/* Terminal side panel */}
      {terminalActivity && (
        <TerminalPanel
          activity={terminalActivity}
          questionId={terminalActivity.questionId}
          isDark={isDark}
          onClose={() => setTerminalActivity(null)}
          onComplete={handleActivityComplete}
        />
      )}

      {/* Result modal */}
      {result && (
        <ResultModal
          result={result}
          isDark={isDark}
          onRetry={handleRetry}
          onDashboard={() => navigate('/dashboard')}
          nextLab={nextLab}
          onNext={handleNext}
        />
      )}
    </div>
  )
}
