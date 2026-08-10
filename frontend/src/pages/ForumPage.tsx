import { useEffect, useState, useRef } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Footer from '../components/Footer'

interface Author {
  username: string
  profileImage: string | null
}

interface Comment {
  id: string
  content: string
  author: Author | null
  authorId: string | null
  parentId: string | null
  replyCount: number
  createdAt: string
  isDeleted: boolean
}

interface ForumResponse {
  comments: Comment[]
  total: number
  page: number
  totalPages: number
}

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime()
  const mins = Math.floor(diff / 60000)
  if (mins < 1) return 'ahora mismo'
  if (mins < 60) return `hace ${mins} min`
  const hrs = Math.floor(mins / 60)
  if (hrs < 24) return `hace ${hrs} h`
  const days = Math.floor(hrs / 24)
  return `hace ${days} d`
}

function Avatar({ author, size = 36, isDark }: { author: Author | null; size?: number; isDark: boolean }) {
  const [imgError, setImgError] = useState(false)
  const initial = author?.username?.[0]?.toUpperCase() ?? '?'
  const src = author?.profileImage ? `data:image/jpeg;base64,${author.profileImage}` : null

  return (
    <div
      style={{
        width: size, height: size, borderRadius: '50%', flexShrink: 0,
        background: isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.10)',
        border: `1px solid ${isDark ? 'rgba(26,63,150,0.35)' : 'rgba(26,63,150,0.20)'}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        overflow: 'hidden',
      }}
    >
      {src && !imgError ? (
        <img src={src} alt={author!.username} onError={() => setImgError(true)}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
      ) : (
        <span className="font-mono font-bold" style={{ fontSize: size * 0.38, color: isDark ? '#7B9FE8' : '#1A3F96' }}>
          {initial}
        </span>
      )}
    </div>
  )
}

function CommentCard({
  comment, isDark, currentUserId, currentUserRole, onDeleted,
}: {
  comment: Comment
  isDark: boolean
  currentUserId: string | null
  currentUserRole: string | null
  onDeleted: (id: string) => void
}) {
  const [expanded, setExpanded] = useState(false)
  const [replies, setReplies] = useState<Comment[]>([])
  const [loadingReplies, setLoadingReplies] = useState(false)
  const [replyText, setReplyText] = useState('')
  const [submittingReply, setSubmittingReply] = useState(false)
  const [replyError, setReplyError] = useState<string | null>(null)
  const [deleting, setDeleting] = useState(false)
  const [deleteError, setDeleteError] = useState<string | null>(null)

  const showDelete = !comment.isDeleted && (
    currentUserRole === 'admin' ||
    (currentUserId !== null && comment.authorId === currentUserId)
  )

  async function loadReplies() {
    setLoadingReplies(true)
    try {
      const data = await api.get<Comment[]>(`/api/forum/${comment.id}/replies`)
      setReplies(data)
    } catch {
      // silent
    } finally {
      setLoadingReplies(false)
    }
  }

  async function toggleReplies() {
    if (!expanded) await loadReplies()
    setExpanded(e => !e)
  }

  async function submitReply(e: React.FormEvent) {
    e.preventDefault()
    if (!replyText.trim()) return
    setSubmittingReply(true)
    setReplyError(null)
    try {
      const newReply = await api.post<Comment>(`/api/forum/${comment.id}/replies`, { content: replyText.trim() })
      setReplies(r => [...r, newReply])
      setReplyText('')
      if (!expanded) setExpanded(true)
    } catch (err: unknown) {
      setReplyError(err instanceof Error ? err.message : 'Error al enviar la respuesta.')
    } finally {
      setSubmittingReply(false)
    }
  }

  async function handleDelete(id: string) {
    if (!confirm('¿Eliminar este comentario?')) return
    setDeleting(true)
    setDeleteError(null)
    try {
      await api.delete(`/api/forum/${id}`)
      onDeleted(id)
    } catch (err: unknown) {
      setDeleteError(err instanceof Error ? err.message : 'Error al eliminar.')
      setDeleting(false)
    }
  }

  async function handleDeleteReply(id: string) {
    if (!confirm('¿Eliminar esta respuesta?')) return
    try {
      await api.delete(`/api/forum/${id}`)
      setReplies(rs => rs.map(r =>
        r.id === id ? { ...r, isDeleted: true, content: '[comentario eliminado]', author: null, authorId: null } : r,
      ))
    } catch {
      // silent — reply delete errors are non-critical
    }
  }

  const cardBg = isDark ? 'rgba(13,27,70,0.70)' : '#f8faff'
  const border = isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.10)'

  return (
    <div className="hud-panel hud-static" style={{
      background: cardBg,
      '--hud-border': border,
      '--hud-border-hover': border,
    } as React.CSSProperties}>
      <div className="p-5">
        <div className="flex items-start gap-3">
          <Avatar author={comment.author} isDark={isDark} />
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between gap-2 mb-2 flex-wrap">
              <span className="font-mono text-[13px] font-semibold" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                {comment.author?.username ?? 'Usuario eliminado'}
              </span>
              <div className="flex items-center gap-3">
                <span className="font-mono text-[11px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                  {timeAgo(comment.createdAt)}
                </span>
                {showDelete && (
                  <button
                    onClick={() => handleDelete(comment.id)}
                    disabled={deleting}
                    className="font-mono text-[11px] transition-colors"
                    style={{ color: '#e05c5c', opacity: deleting ? 0.5 : 1 }}
                  >
                    {deleting ? 'eliminando…' : 'eliminar'}
                  </button>
                )}
              </div>
            </div>
            <p
              className="text-[14px] leading-relaxed break-words"
              style={{
                color: comment.isDeleted ? (isDark ? '#3A5AB8' : '#4A70CC') : (isDark ? '#8BAAD8' : '#1E2A4A'),
                fontStyle: comment.isDeleted ? 'italic' : 'normal',
              }}
            >
              {comment.content}
            </p>
            {deleteError && (
              <p className="font-mono text-[11px] mt-1" style={{ color: '#e05c5c' }}>{deleteError}</p>
            )}
          </div>
        </div>

        {!comment.isDeleted && (
          <button
            onClick={toggleReplies}
            className="mt-3 ml-[48px] font-mono text-[12px] transition-colors"
            style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            onMouseEnter={e => { (e.currentTarget as HTMLElement).style.color = '#2596be' }}
            onMouseLeave={e => { (e.currentTarget as HTMLElement).style.color = isDark ? '#3A5AB8' : '#1A3F96' }}
          >
            {loadingReplies
              ? 'Cargando…'
              : expanded
              ? '▲ ocultar respuestas'
              : `▼ ${comment.replyCount} respuesta${comment.replyCount !== 1 ? 's' : ''}`}
          </button>
        )}
      </div>

      {expanded && (
        <div
          className="border-t px-5 pt-4 pb-5 space-y-4"
          style={{ borderColor: border, background: isDark ? 'rgba(6,13,31,0.4)' : 'rgba(26,63,150,0.03)' }}
        >
          {replies.map(reply => (
            <div key={reply.id} className="flex items-start gap-3">
              <Avatar author={reply.author} size={28} isDark={isDark} />
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2 mb-1 flex-wrap">
                  <span className="font-mono text-[12px] font-semibold" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    {reply.author?.username ?? 'Usuario eliminado'}
                  </span>
                  <div className="flex items-center gap-3">
                    <span className="font-mono text-[10px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                      {timeAgo(reply.createdAt)}
                    </span>
                    {!reply.isDeleted && (
                      currentUserRole === 'admin' ||
                      (currentUserId !== null && reply.authorId === currentUserId)
                    ) && (
                      <button
                        onClick={() => handleDeleteReply(reply.id)}
                        className="font-mono text-[10px]"
                        style={{ color: '#e05c5c' }}
                      >
                        eliminar
                      </button>
                    )}
                  </div>
                </div>
                <p
                  className="text-[13px] leading-relaxed break-words"
                  style={{
                    color: reply.isDeleted ? (isDark ? '#3A5AB8' : '#4A70CC') : (isDark ? '#8BAAD8' : '#1E2A4A'),
                    fontStyle: reply.isDeleted ? 'italic' : 'normal',
                  }}
                >
                  {reply.content}
                </p>
              </div>
            </div>
          ))}

          {currentUserId ? (
            <form onSubmit={submitReply} className="flex gap-2 mt-2">
              <input
                value={replyText}
                onChange={e => setReplyText(e.target.value)}
                placeholder="Escribe una respuesta…"
                maxLength={2000}
                className="tech-input flex-1 px-4 py-2 text-[13px]"
                style={{
                  background: isDark ? 'rgba(6,13,31,0.6)' : '#fff',
                  color: isDark ? '#C8D5EE' : '#0A1545',
                }}
              />
              <button
                type="submit"
                disabled={submittingReply || !replyText.trim()}
                className="px-4 py-2 rounded-xl font-mono text-[12px] font-medium transition-all disabled:opacity-40"
                style={{ background: '#1A3F96', color: '#fff' }}
              >
                {submittingReply ? '…' : 'Responder'}
              </button>
            </form>
          ) : (
            <p className="text-[13px] mt-2" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
              <Link to="/login" style={{ color: '#2596be' }}>Inicia sesión</Link> para responder.
            </p>
          )}
          {replyError && <p className="text-[12px] mt-1" style={{ color: '#e05c5c' }}>{replyError}</p>}
        </div>
      )}
    </div>
  )
}

export default function ForumPage() {
  const { user } = useAuth()
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const [data, setData] = useState<ForumResponse | null>(null)
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const [newComment, setNewComment] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [submitError, setSubmitError] = useState<string | null>(null)
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    api.get<ForumResponse>('/api/forum?page=1')
      .then(setData)
      .catch(err => setError(err instanceof Error ? err.message : 'Error al cargar el foro.'))
      .finally(() => setLoading(false))
  }, [])

  async function loadMore() {
    if (!data || data.page >= data.totalPages) return
    setLoadingMore(true)
    try {
      const next = await api.get<ForumResponse>(`/api/forum?page=${data.page + 1}`)
      setData(prev => prev ? { ...next, comments: [...prev.comments, ...next.comments] } : next)
    } catch {
      // silent
    } finally {
      setLoadingMore(false)
    }
  }

  async function submitComment(e: React.FormEvent) {
    e.preventDefault()
    if (!newComment.trim()) return
    setSubmitting(true)
    setSubmitError(null)
    try {
      const created = await api.post<Comment>('/api/forum', { content: newComment.trim() })
      setData(prev => prev ? { ...prev, comments: [created, ...prev.comments], total: prev.total + 1 } : null)
      setNewComment('')
    } catch (err: unknown) {
      setSubmitError(err instanceof Error ? err.message : 'Error al publicar.')
    } finally {
      setSubmitting(false)
    }
  }

  function handleDeleted(id: string) {
    setData(prev => {
      if (!prev) return prev
      return {
        ...prev,
        comments: prev.comments.map(c =>
          c.id === id ? { ...c, isDeleted: true, content: '[comentario eliminado]', author: null, authorId: null } : c,
        ),
      }
    })
  }

  const bg = isDark ? '#060D1F' : '#EEF3FC'
  const heroBg = isDark
    ? 'linear-gradient(160deg, #0D1630 0%, #060D1F 100%)'
    : 'linear-gradient(160deg, #E8EEFA 0%, #EEF3FC 100%)'
  const border = isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.10)'

  return (
    <div style={{ background: bg }}>
      <Header />

      {/* Hero */}
      <div className="relative border-b overflow-hidden" style={{ borderColor: border, background: heroBg }}>
        <div className="relative max-w-4xl mx-auto px-6 lg:px-10 py-14">
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // comunidad
          </p>
          <h1
            className="font-display mb-3"
            style={{ fontSize: 'clamp(2rem,4vw,3rem)', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}
          >
            Foro de la <span style={{ color: '#1A3F96' }}>Comunidad</span>
          </h1>
          <p style={{ color: isDark ? '#4A70CC' : '#2451C8', maxWidth: '480px', lineHeight: 1.65 }}>
            Comparte dudas, recursos y experiencias con otros estudiantes de ciberseguridad.
          </p>
          {data && (
            <p className="font-mono text-[11px] mt-4" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
              {data.total} comentario{data.total !== 1 ? 's' : ''}
            </p>
          )}
        </div>
      </div>

      {/* Body */}
      <div className="max-w-4xl mx-auto px-6 lg:px-10 py-12 space-y-8">

        {/* Composer */}
        <div
          className="hud-panel hud-static p-6"
          style={{
            background: isDark ? 'rgba(13,27,70,0.70)' : '#f8faff',
            '--hud-border': border,
            '--hud-border-hover': border,
          } as React.CSSProperties}
        >
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // nuevo comentario
          </p>
          {user ? (
            <form onSubmit={submitComment} className="space-y-3">
              <textarea
                ref={textareaRef}
                value={newComment}
                onChange={e => setNewComment(e.target.value)}
                placeholder="Escribe tu comentario aquí…"
                rows={4}
                maxLength={2000}
                className="tech-input w-full px-4 py-3 text-[14px] resize-none"
                style={{
                  background: isDark ? 'rgba(6,13,31,0.6)' : '#fff',
                  color: isDark ? '#C8D5EE' : '#0A1545',
                }}
              />
              <div className="flex items-center justify-between gap-4 flex-wrap">
                <span className="font-mono text-[11px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                  {newComment.length}/2000
                </span>
                <button
                  type="submit"
                  disabled={submitting || !newComment.trim()}
                  className="px-6 py-2.5 rounded-xl font-mono text-[13px] font-medium transition-all disabled:opacity-40"
                  style={{ background: '#1A3F96', color: '#fff' }}
                >
                  {submitting ? 'Publicando…' : 'Publicar'}
                </button>
              </div>
              {submitError && <p className="text-[13px]" style={{ color: '#e05c5c' }}>{submitError}</p>}
            </form>
          ) : (
            <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
              <Link to="/login" style={{ color: '#2596be', fontWeight: 500 }}>Inicia sesión</Link>
              {' '}para participar en el foro. ¿No tienes cuenta?{' '}
              <Link to="/register" style={{ color: '#2596be', fontWeight: 500 }}>Regístrate gratis.</Link>
            </p>
          )}
        </div>

        {/* List */}
        {loading && (
          <div className="space-y-4">
            {[1, 2, 3].map(i => (
              <div
                key={i}
                className="rounded-2xl animate-pulse"
                style={{ height: '120px', background: isDark ? 'rgba(13,27,70,0.4)' : '#f0f4ff', border: `1px solid ${border}` }}
              />
            ))}
          </div>
        )}

        {error && (
          <div
            className="hud-panel hud-static px-4 py-3"
            style={{
              background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
              borderLeft: '3px solid #1A3F96',
              '--hud-border': 'rgba(26,63,150,0.35)',
              '--hud-border-hover': 'rgba(26,63,150,0.35)',
            } as React.CSSProperties}
          >
            <p className="text-sm" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
          </div>
        )}

        {!loading && !error && data && (
          <div className="space-y-4">
            {data.comments.length === 0 ? (
              <div
                className="hud-panel hud-static px-6 py-12 text-center"
                style={{
                  background: isDark ? 'rgba(6,13,31,0.6)' : '#f8faff',
                  '--hud-border': border,
                  '--hud-border-hover': border,
                } as React.CSSProperties}
              >
                <p className="font-display mb-2" style={{ fontSize: '1.25rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  Sin comentarios aún
                </p>
                <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
                  Sé el primero en iniciar una conversación.
                </p>
              </div>
            ) : (
              data.comments.map(comment => (
                <CommentCard
                  key={comment.id}
                  comment={comment}
                  isDark={isDark}
                  currentUserId={user?.id ?? null}
                  currentUserRole={user?.role ?? null}
                  onDeleted={handleDeleted}
                />
              ))
            )}

            {data.page < data.totalPages && (
              <button
                onClick={loadMore}
                disabled={loadingMore}
                className="w-full py-3 rounded-2xl font-mono text-[13px] transition-all disabled:opacity-40"
                style={{
                  color: isDark ? '#7B9FE8' : '#1A3F96',
                  background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)',
                  border: `1px solid ${isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.18)'}`,
                }}
              >
                {loadingMore ? 'Cargando…' : 'Cargar más comentarios'}
              </button>
            )}
          </div>
        )}
      </div>

      <Footer />
    </div>
  )
}
