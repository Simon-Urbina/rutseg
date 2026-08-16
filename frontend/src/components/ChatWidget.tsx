import { useEffect, useRef, useState, type ReactNode } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'

interface Message {
  role: 'user' | 'assistant'
  content: string
}

const CHATBOT_URL = import.meta.env.VITE_CHATBOT_URL ?? 'http://localhost:8001'
const MAX_HISTORY = 20

// Reconoce enlaces estilo Markdown que Uchi genera para redirigir dentro de la plataforma: [texto](/ruta)
// y negrillas **texto** — combinados en un solo patrón para que compartan el recorrido del string
// (si no, procesar cada uno por separado desordena los índices del otro).
const LINK_PATTERN = /\[([^\]]+)\]\((\/[^\s)]+|https?:\/\/[^\s)]+)\)/
const BOLD_PATTERN = /\*\*([^*]+)\*\*/
const TOKEN_PATTERN = new RegExp(`${LINK_PATTERN.source}|${BOLD_PATTERN.source}`, 'g')

function renderMessageContent(content: string, onNavigate: (path: string) => void, linkColor: string): ReactNode[] {
  const nodes: ReactNode[] = []
  let lastIndex = 0
  let key = 0
  let match: RegExpExecArray | null

  TOKEN_PATTERN.lastIndex = 0
  while ((match = TOKEN_PATTERN.exec(content)) !== null) {
    if (match.index > lastIndex) nodes.push(content.slice(lastIndex, match.index))

    const [full, label, href, bold] = match
    if (label !== undefined) {
      const isInternal = href.startsWith('/')
      nodes.push(
        <a
          key={key++}
          href={href}
          onClick={isInternal ? (e) => { e.preventDefault(); onNavigate(href) } : undefined}
          target={isInternal ? undefined : '_blank'}
          rel={isInternal ? undefined : 'noopener noreferrer'}
          style={{ color: linkColor, textDecoration: 'underline', textUnderlineOffset: '2px', fontWeight: 600, cursor: 'pointer' }}
        >
          {label}
        </a>,
      )
    } else {
      nodes.push(<strong key={key++}>{bold}</strong>)
    }
    lastIndex = match.index + full.length
  }
  if (lastIndex < content.length) nodes.push(content.slice(lastIndex))
  return nodes
}

function buildContext(pathname: string, username?: string) {
  if (pathname.match(/^\/courses\/[^/]+\/[^/]+\/[^/]+/)) {
    const parts = pathname.split('/')
    return { page: 'lab', labTitle: decodeURIComponent(parts[4] ?? ''), username }
  }
  if (pathname.match(/^\/courses\//)) {
    return { page: 'course', courseTitle: decodeURIComponent(pathname.split('/')[2] ?? ''), username }
  }
  if (pathname === '/dashboard') return { page: 'dashboard', username }
  return { page: 'other', username }
}

const AUTH_PATHS = ['/login', '/register', '/forgot-password', '/reset-password']

export default function ChatWidget() {
  const { theme } = useTheme()
  const { user } = useAuth()
  const { pathname } = useLocation()
  const navigate = useNavigate()
  const isDark = theme === 'dark'

  const [open, setOpen] = useState(false)
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [streaming, setStreaming] = useState(false)
  const [thinking, setThinking] = useState(false)
  const [isMobile, setIsMobile] = useState(() => window.innerWidth < 520)
  const bottomRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const abortRef = useRef<AbortController | null>(null)

  useEffect(() => {
    const onResize = () => setIsMobile(window.innerWidth < 520)
    window.addEventListener('resize', onResize)
    return () => window.removeEventListener('resize', onResize)
  }, [])

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 50)
    }
  }, [open])

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') setOpen(false) }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [open])

  if (AUTH_PATHS.includes(pathname)) return null

  const handleLinkNavigate = (path: string) => {
    setOpen(false)
    navigate(path)
  }

  const send = async () => {
    const text = input.trim()
    if (!text || streaming) return

    const userMsg: Message = { role: 'user', content: text }
    const history = [...messages, userMsg].slice(-MAX_HISTORY)
    setMessages(history)
    setInput('')
    setStreaming(true)
    setThinking(true)

    const assistantMsg: Message = { role: 'assistant', content: '' }
    setMessages(prev => [...prev, assistantMsg])

    abortRef.current = new AbortController()

    try {
      const res = await fetch(`${CHATBOT_URL}/chat/stream`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: history,
          context: buildContext(pathname, user?.username),
        }),
        signal: abortRef.current.signal,
      })

      if (!res.ok || !res.body) throw new Error('Error al conectar con Uchi')

      const reader = res.body.getReader()
      const decoder = new TextDecoder()
      let buffer = ''

      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        buffer += decoder.decode(value, { stream: true })
        const lines = buffer.split('\n')
        buffer = lines.pop() ?? ''

        for (const line of lines) {
          if (!line.startsWith('data: ')) continue
          const payload = line.slice(6).trim()
          if (payload === '[DONE]') continue
          try {
            const { chunk } = JSON.parse(payload)
            if (chunk) {
              setThinking(false)
              setMessages(prev => {
                const updated = [...prev]
                updated[updated.length - 1] = {
                  ...updated[updated.length - 1],
                  content: updated[updated.length - 1].content + chunk,
                }
                return updated
              })
            }
          } catch { /* skip malformed chunk */ }
        }
      }
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        setMessages(prev => {
          const updated = [...prev]
          updated[updated.length - 1] = {
            role: 'assistant',
            content: 'No pude conectarme. ¿Está corriendo el servidor de Uchi?',
          }
          return updated
        })
      }
    } finally {
      setStreaming(false)
      setThinking(false)
    }
  }

  const onKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      send()
    }
  }

  const bg     = isDark ? 'rgba(9,21,32,0.96)'  : 'rgba(248,250,255,0.97)'
  const border = isDark ? 'rgba(26,63,150,0.28)' : 'rgba(26,63,150,0.22)'
  const textPrimary   = isDark ? '#C8D5EE' : '#0A1545'
  const textSecondary = isDark ? '#4A70CC' : '#2451C8'
  const inputBg       = isDark ? 'rgba(6,13,31,0.6)' : 'rgba(232,238,250,0.7)'

  const panelWidth  = isMobile ? `calc(100vw - 3rem)` : '380px'
  const panelHeight = isMobile ? '70svh' : '520px'

  return (
    <>
      {/* Overlay táctil en móvil — toca fuera para cerrar */}
      {open && isMobile && (
        <div
          onClick={() => setOpen(false)}
          style={{
            position: 'fixed', inset: 0, zIndex: 49,
            background: 'rgba(6,13,31,0.4)',
            backdropFilter: 'blur(2px)',
            WebkitBackdropFilter: 'blur(2px)',
          }}
        />
      )}
    <div style={{ position: 'fixed', bottom: '1.5rem', left: '1.5rem', zIndex: 50 }}>
      {/* Chat panel */}
      {open && (
        <div
          className="animate-fade-up-1"
          style={{
            marginBottom: '0.75rem',
            width: panelWidth,
            height: panelHeight,
            display: 'flex',
            flexDirection: 'column',
            borderRadius: isMobile ? '1rem' : '1.25rem',
            overflow: 'hidden',
            background: bg,
            backdropFilter: 'blur(24px)',
            WebkitBackdropFilter: 'blur(24px)',
            border: `1px solid ${border}`,
            boxShadow: '0 24px 64px rgba(0,0,0,0.45), 0 0 0 1px rgba(26,63,150,0.08)',
          }}
        >
          {/* Top accent line */}
          <div
            style={{
              height: '1px', flexShrink: 0,
              background: 'linear-gradient(90deg, transparent 0%, #1A3F96 35%, #2596be 65%, transparent 100%)',
              opacity: 0.7,
            }}
          />

          {/* Header */}
          <div
            style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '0.875rem 1.125rem',
              borderBottom: `1px solid ${border}`,
              flexShrink: 0,
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.625rem' }}>
              <div
                style={{
                  width: '32px', height: '32px', borderRadius: '0.625rem',
                  background: 'rgba(26,63,150,0.12)',
                  border: '1px solid rgba(26,63,150,0.25)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}
              >
                {/* Uchi robo-cat icon — header (small) */}
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                  {/* Ears */}
                  <path d="M5 10 L7.5 3.5 L11.5 8.5 Z" fill="#1A3F96"/>
                  <path d="M12.5 8.5 L16.5 3.5 L19 10 Z" fill="#1A3F96"/>
                  {/* Head */}
                  <circle cx="12" cy="13.5" r="7.5" fill="#1A3F96"/>
                  {/* Ear holes */}
                  <circle cx="7.5" cy="5.5" r="0.6" fill="#060D1F"/>
                  <circle cx="16.5" cy="5.5" r="0.6" fill="#060D1F"/>
                  {/* Left eye LCD */}
                  <rect x="7.6" y="11.1" width="3.0" height="2.7" rx="0.5" fill="#F5C500"/>
                  <rect x="8.15" y="11.55" width="1.9" height="1.9" rx="0.3" fill="#060D1F"/>
                  <rect x="8.35" y="11.72" width="0.55" height="0.55" rx="0.12" fill="#2596be"/>
                  {/* Right eye LCD */}
                  <rect x="13.4" y="11.1" width="3.0" height="2.7" rx="0.5" fill="#F5C500"/>
                  <rect x="13.95" y="11.55" width="1.9" height="1.9" rx="0.3" fill="#060D1F"/>
                  <rect x="14.15" y="11.72" width="0.55" height="0.55" rx="0.12" fill="#2596be"/>
                  {/* Nose diamond */}
                  <path d="M12 15.1 L12.5 15.6 L12 16.1 L11.5 15.6 Z" fill="#2596be"/>
                  {/* Mouth grill */}
                  <rect x="10.4" y="16.8" width="0.85" height="0.4" rx="0.12" fill="#2596be"/>
                  <rect x="11.6" y="16.8" width="0.85" height="0.4" rx="0.12" fill="#2596be"/>
                  <rect x="12.8" y="16.8" width="0.85" height="0.4" rx="0.12" fill="#2596be"/>
                </svg>
              </div>
              <div>
                <p style={{ fontFamily: 'var(--font-display)', fontSize: '0.9rem', color: textPrimary, lineHeight: 1 }}>
                  Uchi
                </p>
                <p style={{ fontFamily: 'var(--font-mono)', fontSize: '9px', color: textSecondary, letterSpacing: '0.18em', textTransform: 'uppercase', marginTop: '2px' }}>
                  {thinking ? 'pensando...' : streaming ? 'escribiendo...' : 'asistente'}
                </p>
              </div>
            </div>
            <button
              onClick={() => setOpen(false)}
              style={{
                background: 'transparent', border: 'none', cursor: 'pointer',
                color: textSecondary, padding: '4px', borderRadius: '6px',
              }}
              onMouseEnter={e => { (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.10)' }}
              onMouseLeave={e => { (e.currentTarget as HTMLElement).style.background = 'transparent' }}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>

          {/* Messages */}
          <div
            className="chat-scroll"
            style={{
              flex: 1, overflowY: 'auto', padding: '1rem',
              display: 'flex', flexDirection: 'column', gap: '0.75rem',
            }}
          >
            {messages.length === 0 && (
              <div style={{ margin: 'auto', textAlign: 'center', padding: '1rem' }}>
                <p style={{ fontFamily: 'var(--font-mono)', fontSize: '11px', color: textSecondary, letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: '0.5rem' }}>
                  // Uchi listo
                </p>
                <p style={{ fontSize: '13px', color: textSecondary, lineHeight: 1.5 }}>
                  Pregúntame sobre tus labs, conceptos de ciberseguridad o cómo usar la plataforma.
                </p>
              </div>
            )}

            {messages.map((msg, i) => (
              <div
                key={i}
                style={{
                  display: 'flex',
                  justifyContent: msg.role === 'user' ? 'flex-end' : 'flex-start',
                }}
              >
                <div
                  style={{
                    maxWidth: '85%',
                    padding: '0.6rem 0.875rem',
                    borderRadius: msg.role === 'user' ? '1rem 1rem 0.25rem 1rem' : '1rem 1rem 1rem 0.25rem',
                    background: msg.role === 'user'
                      ? 'rgba(26,63,150,0.18)'
                      : isDark ? 'rgba(6,13,31,0.5)' : 'rgba(210,220,245,0.5)',
                    border: `1px solid ${msg.role === 'user' ? 'rgba(26,63,150,0.3)' : border}`,
                    fontSize: '13px',
                    lineHeight: 1.55,
                    color: textPrimary,
                    fontFamily: 'var(--font-sans)',
                    whiteSpace: 'pre-wrap',
                    wordBreak: 'break-word',
                  }}
                >
                  {msg.role === 'assistant' && thinking && i === messages.length - 1 && msg.content === '' ? (
                    <span style={{ fontFamily: 'var(--font-mono)', fontSize: '11px', color: '#2596be', letterSpacing: '0.15em' }}>
                      pensando
                      <span className="cursor-blink">...</span>
                    </span>
                  ) : (
                    <>
                      {msg.role === 'assistant'
                        ? renderMessageContent(msg.content, handleLinkNavigate, '#2596be')
                        : msg.content}
                      {msg.role === 'assistant' && streaming && !thinking && i === messages.length - 1 && (
                        <span className="cursor-blink" style={{ fontFamily: 'var(--font-mono)', fontSize: '11px', color: '#2596be' }}>▋</span>
                      )}
                    </>
                  )}
                </div>
              </div>
            ))}
            <div ref={bottomRef} />
          </div>

          {/* Input */}
          <div
            style={{
              padding: '0.75rem',
              borderTop: `1px solid ${border}`,
              flexShrink: 0,
            }}
          >
            <div
              style={{
                display: 'flex', alignItems: 'center', gap: '0.5rem',
                background: inputBg,
                border: `1px solid ${border}`,
                borderRadius: '0.875rem',
                padding: '0.375rem 0.375rem 0.375rem 0.75rem',
              }}
            >
              <textarea
                ref={inputRef}
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={onKeyDown}
                placeholder="Pregunta algo..."
                rows={1}
                disabled={streaming}
                style={{
                  flex: 1, background: 'transparent', border: 'none', outline: 'none',
                  resize: 'none', fontFamily: 'var(--font-sans)', fontSize: '13px',
                  color: textPrimary, lineHeight: '20px', maxHeight: '100px',
                  overflowY: 'hidden', padding: 0, margin: 0,
                  height: '20px', display: 'block',
                }}
                onInput={e => {
                  const el = e.currentTarget
                  el.style.height = '20px'
                  el.style.height = `${Math.min(el.scrollHeight, 100)}px`
                  el.style.overflowY = el.scrollHeight > 100 ? 'auto' : 'hidden'
                }}
              />
              <button
                onClick={send}
                disabled={!input.trim() || streaming}
                style={{
                  flexShrink: 0, width: '32px', height: '32px', borderRadius: '0.625rem',
                  background: input.trim() && !streaming ? '#1A3F96' : 'rgba(26,63,150,0.15)',
                  border: 'none', cursor: input.trim() && !streaming ? 'pointer' : 'not-allowed',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  transition: 'background 0.15s',
                }}
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="22" y1="2" x2="11" y2="13"/>
                  <polygon points="22 2 15 22 11 13 2 9 22 2"/>
                </svg>
              </button>
            </div>
            {!isMobile && (
              <p style={{ fontFamily: 'var(--font-mono)', fontSize: '9px', color: textSecondary, textAlign: 'center', marginTop: '0.375rem', letterSpacing: '0.1em' }}>
                Enter para enviar · Shift+Enter nueva línea
              </p>
            )}
          </div>
        </div>
      )}

      {/* Toggle button */}
      <button
        onClick={() => setOpen(prev => !prev)}
        title="Uchi – Asistente"
        style={{
          width: '52px', height: '52px', borderRadius: '50%',
          background: open ? '#1A3F96' : isDark ? 'rgba(13,22,70,0.95)' : 'rgba(248,250,255,0.97)',
          border: `1px solid ${open ? '#1A3F96' : border}`,
          boxShadow: open
            ? '0 0 0 4px rgba(26,63,150,0.18), 0 8px 32px rgba(0,0,0,0.35)'
            : '0 4px 24px rgba(0,0,0,0.3)',
          cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transition: 'all 0.2s cubic-bezier(0.22,1,0.36,1)',
          backdropFilter: 'blur(16px)',
          WebkitBackdropFilter: 'blur(16px)',
        }}
        onMouseEnter={e => {
          if (!open) (e.currentTarget as HTMLElement).style.transform = 'scale(1.08)'
        }}
        onMouseLeave={e => {
          (e.currentTarget as HTMLElement).style.transform = 'scale(1)'
        }}
      >
        {open ? (
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        ) : (
          /* Uchi robo-cat icon — toggle button (large, with whiskers) */
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
            {/* Ears */}
            <path d="M4.5 10 L7 3.5 L11 8.5 Z" fill={isDark ? '#4A9FCC' : '#1A3F96'}/>
            <path d="M13 8.5 L17 3.5 L19.5 10 Z" fill={isDark ? '#4A9FCC' : '#1A3F96'}/>
            {/* Head */}
            <circle cx="12" cy="13.5" r="7.5" fill={isDark ? '#1A3F96' : '#1A3F96'}/>
            {/* Ear holes (drawn on top of everything — visible in ear tip region) */}
            <circle cx="7" cy="5.5" r="0.58" fill="#030810"/>
            <circle cx="17" cy="5.5" r="0.58" fill="#030810"/>
            {/* Left eye: golden LCD frame */}
            <rect x="7.4" y="11.0" width="3.2" height="2.9" rx="0.55" fill="#F5C500"/>
            {/* Left eye: dark screen */}
            <rect x="7.95" y="11.5" width="2.1" height="2.0" rx="0.35" fill="#060D1F"/>
            {/* Left eye: cyan glint */}
            <rect x="8.15" y="11.68" width="0.6" height="0.6" rx="0.14" fill="#2596be"/>
            {/* Right eye: golden LCD frame */}
            <rect x="13.4" y="11.0" width="3.2" height="2.9" rx="0.55" fill="#F5C500"/>
            {/* Right eye: dark screen */}
            <rect x="13.95" y="11.5" width="2.1" height="2.0" rx="0.35" fill="#060D1F"/>
            {/* Right eye: cyan glint */}
            <rect x="14.15" y="11.68" width="0.6" height="0.6" rx="0.14" fill="#2596be"/>
            {/* Nose: diamond sensor */}
            <path d="M12 15.1 L12.55 15.65 L12 16.2 L11.45 15.65 Z" fill="#2596be"/>
            {/* Mouth: speaker grill (3 slots) */}
            <rect x="10.0" y="16.85" width="0.95" height="0.45" rx="0.15" fill="#2596be"/>
            <rect x="11.52" y="16.85" width="0.95" height="0.45" rx="0.15" fill="#2596be"/>
            <rect x="13.05" y="16.85" width="0.95" height="0.45" rx="0.15" fill="#2596be"/>
            {/* Left cheek vent holes (2×2 grid) */}
            <rect x="6.5" y="14.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="7.52" y="14.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="6.5" y="15.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="7.52" y="15.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            {/* Right cheek vent holes */}
            <rect x="15.8" y="14.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="16.82" y="14.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="15.8" y="15.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            <rect x="16.82" y="15.1" width="0.7" height="0.7" rx="0.15" fill="#030810"/>
            {/* Whiskers: circuit lines with node dots */}
            <line x1="7.1" y1="14.2" x2="2.5" y2="13.3" stroke={isDark ? '#7B9FE8' : '#4A70CC'} strokeWidth="0.65" strokeLinecap="round"/>
            <line x1="7.1" y1="15.3" x2="2.5" y2="16.1" stroke={isDark ? '#7B9FE8' : '#4A70CC'} strokeWidth="0.65" strokeLinecap="round"/>
            <circle cx="4.7" cy="13.75" r="0.38" fill="#2596be"/>
            <circle cx="4.65" cy="15.78" r="0.38" fill="#2596be"/>
            <line x1="16.9" y1="14.2" x2="21.5" y2="13.3" stroke={isDark ? '#7B9FE8' : '#4A70CC'} strokeWidth="0.65" strokeLinecap="round"/>
            <line x1="16.9" y1="15.3" x2="21.5" y2="16.1" stroke={isDark ? '#7B9FE8' : '#4A70CC'} strokeWidth="0.65" strokeLinecap="round"/>
            <circle cx="19.3" cy="13.75" r="0.38" fill="#2596be"/>
            <circle cx="19.35" cy="15.78" r="0.38" fill="#2596be"/>
          </svg>
        )}
      </button>
    </div>
    </>
  )
}
