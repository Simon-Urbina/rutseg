import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { adminApi, type AdminUser } from '../../lib/adminApi'
import { ErrorBanner } from './AdminFormControls'
import { IconChevronRight } from './AdminIcons'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import { ContinuousPagination } from '../../components/ContinuousPagination'

const PAGE_SIZE = 20

export default function AdminUsersPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()

  const [users, setUsers] = useState<AdminUser[]>([])
  const [total, setTotal] = useState(0)
  const [totalPages, setTotalPages] = useState(1)
  const [page, setPage] = useState(1)
  const [searchInput, setSearchInput] = useState('')
  const [search, setSearch] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    setLoading(true)
    setError('')
    adminApi.listUsers({ page, limit: PAGE_SIZE, search: search || undefined })
      .then(res => { setUsers(res.data); setTotal(res.total); setTotalPages(res.totalPages) })
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [page, search])

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setPage(1)
    setSearch(searchInput.trim())
  }

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[{ label: 'Panel', to: '/admin' }, { label: 'Usuarios' }]} />

      <div className="flex items-center justify-between mb-8 mt-6 flex-wrap gap-4">
        <h1 className="font-display" style={{ fontSize: 'clamp(1.8rem, 3vw, 2.4rem)', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Usuarios
        </h1>
        <form onSubmit={handleSearchSubmit} className="flex gap-2">
          <input
            type="text"
            value={searchInput}
            onChange={e => setSearchInput(e.target.value)}
            placeholder="Buscar por username o email…"
            className="tech-input px-4 py-2.5 text-[14px] w-64"
            style={{
              background: isDark ? 'rgba(6,13,31,0.5)' : '#ffffff',
              color: isDark ? '#C8D5EE' : '#0A1545',
            }}
          />
          <button type="submit" className="btn-neon px-5 py-2.5 rounded-xl text-[14px]">Buscar</button>
        </form>
      </div>

      {error && <div className="mb-6"><ErrorBanner message={error} isDark={isDark} /></div>}

      {!loading && !error && users.length === 0 && (
        <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
          No se encontraron usuarios{search ? ` para "${search}"` : ''}.
        </p>
      )}

      <div className="flex flex-col gap-3">
        {users.map(u => (
          <button
            key={u.id}
            onClick={() => navigate(`/admin/users/${u.id}`)}
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
                  {u.username}
                </h3>
                <RoleBadge role={u.role} />
              </div>
              <p className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
                {u.email} · {u.points} pts · desde {new Date(u.createdAt).toLocaleDateString('es-CO')}
              </p>
            </div>
            <IconChevronRight />
          </button>
        ))}
      </div>

      {totalPages > 1 && (
        <div className="flex flex-col items-center gap-3 mt-8">
          <span className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
            Página {page} de {totalPages} · {total} usuarios
          </span>
          <ContinuousPagination currentPage={page} totalPages={totalPages} onPageChange={setPage} />
        </div>
      )}
    </PageShell>
  )
}

export function RoleBadge({ role }: { role: 'user' | 'admin' }) {
  const isAdmin = role === 'admin'
  return (
    <span
      className="font-mono text-[10px] tracking-[0.14em] uppercase px-2 py-1 rounded"
      style={{
        color: isAdmin ? '#8a5cf6' : '#4A70CC',
        background: isAdmin ? 'rgba(138,92,246,0.10)' : 'rgba(74,112,204,0.10)',
        border: `1px solid ${isAdmin ? 'rgba(138,92,246,0.30)' : 'rgba(74,112,204,0.30)'}`,
      }}
    >
      {isAdmin ? 'Admin' : 'Usuario'}
    </span>
  )
}
