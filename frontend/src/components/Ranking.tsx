import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../lib/api'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'

interface RankRow {
  rank: number
  id: string
  username: string
  bio: string | null
  points: number
}

interface RankingResponse {
  data: RankRow[]
  total: number
}

interface SelfProfile {
  username: string
  rank: number | null
  points: number
  bio: string | null
}

// `color` is the vivid medal hue — used for backgrounds/borders/dots at low
// alpha, where it reads fine on any surface. `textColor` is a darker shade of
// the same hue reserved for text/icons in light mode: gold, silver and bronze
// are all light enough that used directly as text on a white card they fall
// well under readable contrast (e.g. gold text on white is ~1.6:1).
const RANK_ACCENTS: Record<number, { color: string; textColor: string; label: string }> = {
  1: { color: '#F5C500', textColor: '#8A7000', label: 'GOLD' },
  2: { color: '#7B9FE8', textColor: '#3A5AB8', label: 'SILVER' },
  3: { color: '#CD7F32', textColor: '#8A5423', label: 'BRONZE' },
}

export default function Ranking({ limit = 5, selfProfile }: { limit?: number; selfProfile?: SelfProfile | null }) {
  const { theme } = useTheme()
  const { user } = useAuth()
  const isDark = theme === 'dark'
  const [rows, setRows] = useState<RankRow[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    setLoading(true)
    api
      .get<RankingResponse>(`/api/ranking?limit=${limit}`)
      .then(res => setRows(res.data))
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [limit])

  const maxPoints = rows.length ? Math.max(...rows.map(r => r.points), 1) : 1
  const selfInList = user ? rows.some(r => r.username === user.username) : true
  const showSelf = !selfInList && !!selfProfile && selfProfile.rank !== null

  return (
    <div className="space-y-3">
      {loading && (
        <>
          {Array.from({ length: limit }).map((_, i) => (
            <div
              key={i}
              className="rounded-2xl px-6 py-5 animate-pulse"
              style={{
                background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                border: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.08)'}`,
                opacity: 0.5,
              }}
            >
              <div className="h-4" />
            </div>
          ))}
        </>
      )}

      {error && !loading && (
        <div
          className="hud-panel hud-static px-6 py-5"
          style={{
            background: isDark ? 'rgba(13,27,70,0.85)' : '#eef0f8',
            borderLeft: '3px solid #1A3F96',
            '--hud-border': 'rgba(26,63,150,0.35)',
            '--hud-border-hover': 'rgba(26,63,150,0.35)',
          } as React.CSSProperties}
        >
          <span className="font-mono text-xs" style={{ color: '#1A3F96' }}>ERR</span>
          <p className="text-sm mt-1" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{error}</p>
        </div>
      )}

      {!loading && !error && rows.length === 0 && (
        <div
          className="hud-panel hud-static px-6 py-10 text-center"
          style={{
            background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
            '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
            '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
          } as React.CSSProperties}
        >
          <p className="font-mono text-sm" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // sin operadores aún
          </p>
        </div>
      )}

      {!loading && !error && rows.length > 0 && (
        <p
          className="font-mono text-[10px] tracking-[0.18em] uppercase px-1 pb-1"
          style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
        >
          // clic en cualquier hacker para ver su perfil
        </p>
      )}

      {!loading && !error && rows.map(row => {
        const accent = RANK_ACCENTS[row.rank]?.color ?? (isDark ? '#3A5AB8' : '#4A70CC')
        // Text/icon color: in light mode the vivid medal hues (gold, silver,
        // bronze) are too close to white to read as text, so swap in the
        // darker textColor variant there. Dark mode keeps the vivid hue.
        const textAccent = isDark ? accent : (RANK_ACCENTS[row.rank]?.textColor ?? '#4A70CC')
        const label = RANK_ACCENTS[row.rank]?.label
        const isTop = row.rank === 1
        const ratio = row.points > 0 ? row.points / maxPoints : 0

        return (
          <Link
            key={row.id}
            to={`/u/${row.username}`}
            className="hud-panel block px-6 py-5 relative"
            style={{
              background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
              textDecoration: 'none',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
              '--hud-border-hover': `${accent}99`,
              '--hud-focus': accent,
              ...(isTop && {
                boxShadow: isDark
                  ? '0 0 0 1px rgba(245,197,0,0.18), 0 8px 32px rgba(245,197,0,0.05)'
                  : '0 0 0 1px rgba(245,197,0,0.25), 0 8px 32px rgba(245,197,0,0.08)',
              }),
            } as React.CSSProperties}
          >
            {label && <span className="hud-corner-tag" style={{ color: textAccent }}>{label}</span>}

            <div className="relative flex items-center gap-5">
              {/* Rank number */}
              <div
                className="shrink-0 w-12 h-12 rounded-xl flex items-center justify-center num-display"
                style={{
                  fontSize: '1.5rem',
                  background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.04)',
                  color: textAccent,
                  border: `1px solid ${accent}33`,
                }}
              >
                {row.rank}
              </div>

              {/* User info */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1 flex-wrap">
                  <p
                    className="font-display truncate"
                    style={{
                      fontSize: isTop ? '1.35rem' : '1.15rem',
                      color: isDark ? '#C8D5EE' : '#0A1545',
                    }}
                  >
                    {row.username}
                  </p>
                  {label && (
                    <span
                      className="font-mono text-[9px] tracking-[0.18em] px-1.5 py-0.5 rounded"
                      style={{ color: textAccent, background: `${accent}15`, border: `1px solid ${accent}30` }}
                    >
                      {label}
                    </span>
                  )}
                  {user?.username === row.username && (
                    <span
                      className="font-mono text-[9px] tracking-[0.18em] px-1.5 py-0.5 rounded"
                      style={{ color: '#2596be', background: 'rgba(37,150,190,0.12)', border: '1px solid rgba(37,150,190,0.30)' }}
                    >
                      TÚ
                    </span>
                  )}
                </div>
                {row.bio && (
                  <p
                    className="text-xs truncate"
                    style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                  >
                    {row.bio}
                  </p>
                )}
                {/* Progress bar */}
                <div
                  className="mt-2 h-1 rounded-full overflow-hidden"
                  style={{ background: isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.08)' }}
                >
                  <div
                    className="h-full rounded-full transition-all duration-700"
                    style={{
                      width: `${Math.max(ratio * 100, 4)}%`,
                      background: `linear-gradient(90deg, ${accent}, ${accent}dd)`,
                    }}
                  />
                </div>
              </div>

              {/* Points */}
              <div className="shrink-0 text-right">
                <p
                  className="num-display leading-none"
                  style={{ fontSize: '1.5rem', color: isDark ? '#C8D5EE' : '#0A1545' }}
                >
                  {row.points.toLocaleString('es-CO')}
                </p>
                <p
                  className="font-mono text-[10px] tracking-[0.18em] uppercase mt-1"
                  style={{ color: textAccent }}
                >
                  pts
                </p>
              </div>
            </div>
          </Link>
        )
      })}

      {/* Your position — shown when you're outside the top N */}
      {showSelf && selfProfile && (
        <>
          <div className="flex items-center gap-3 py-1">
            <div className="flex-1 h-px" style={{ background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.10)' }} />
            <span className="font-mono text-[9px] tracking-[0.18em]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>···</span>
            <div className="flex-1 h-px" style={{ background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.10)' }} />
          </div>
          <Link
            to={`/u/${selfProfile.username}`}
            className="hud-panel block px-6 py-5 relative"
            style={{
              background: isDark ? 'rgba(37,150,190,0.07)' : 'rgba(37,150,190,0.04)',
              textDecoration: 'none',
              '--hud-border': 'rgba(37,150,190,0.40)',
              '--hud-border-hover': '#2596be',
              '--hud-focus': '#2596be',
            } as React.CSSProperties}
          >
            <div className="flex items-center gap-5">
              <div className="shrink-0 w-12 h-12 rounded-xl flex items-center justify-center num-display"
                style={{ fontSize: '1.5rem', background: isDark ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.04)', color: '#2596be', border: '1px solid rgba(37,150,190,0.3)' }}>
                {selfProfile.rank}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <p className="font-display truncate" style={{ fontSize: '1.15rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    {selfProfile.username}
                  </p>
                  <span className="font-mono text-[9px] tracking-[0.18em] px-1.5 py-0.5 rounded"
                    style={{ color: '#2596be', background: 'rgba(37,150,190,0.12)', border: '1px solid rgba(37,150,190,0.30)' }}>
                    TÚ
                  </span>
                </div>
                {selfProfile.bio && (
                  <p className="text-xs truncate" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>{selfProfile.bio}</p>
                )}
                <div className="mt-2 h-1 rounded-full overflow-hidden" style={{ background: isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.08)' }}>
                  <div className="h-full rounded-full" style={{ width: `${Math.max((selfProfile.points / maxPoints) * 100, 2)}%`, background: 'linear-gradient(90deg, #2596be, #2596bedd)' }} />
                </div>
              </div>
              <div className="shrink-0 text-right">
                <p className="num-display leading-none" style={{ fontSize: '1.5rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
                  {selfProfile.points.toLocaleString('es-CO')}
                </p>
                <p className="font-mono text-[10px] tracking-[0.18em] uppercase mt-1" style={{ color: '#2596be' }}>pts</p>
              </div>
            </div>
          </Link>
        </>
      )}
    </div>
  )
}
