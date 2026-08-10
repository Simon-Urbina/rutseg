import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import ProfileEditModal from '../components/ProfileEditModal'
import Ranking from '../components/Ranking'
import CourseCard, { type Course } from '../components/CourseCard'
import EnrollConfirmModal from '../components/EnrollConfirmModal'
import Footer from '../components/Footer'

interface FullProfile {
  id: string
  username: string
  email: string
  bio: string | null
  profileImage?: string | null
  points: number
  rank: number | null
  completedLabs: number
  role: 'user' | 'admin'
  createdAt: string
}

export default function DashboardPage() {
  const { user } = useAuth()
  const { theme } = useTheme()
  const navigate  = useNavigate()
  const isDark = theme === 'dark'

  const [profile, setProfile] = useState<FullProfile | null>(null)
  const [loadingProfile, setLoadingProfile] = useState(true)
  const [profileError, setProfileError] = useState<string | null>(null)
  const [editOpen, setEditOpen] = useState(false)

  const [courses, setCourses] = useState<Course[]>([])
  const [coursesLoading, setCoursesLoading] = useState(true)
  const [coursesError, setCoursesError] = useState<string | null>(null)
  const [pendingEnroll, setPendingEnroll] = useState<Course | null>(null)
  const [searchQuery, setSearchQuery] = useState('')

  useEffect(() => {
    setLoadingProfile(true)
    api.get<FullProfile>('/api/users/me')
      .then(setProfile)
      .catch(err => setProfileError(err.message))
      .finally(() => setLoadingProfile(false))
  }, [])

  useEffect(() => {
    setCoursesLoading(true)
    api.get<Course[]>('/api/courses')
      .then(setCourses)
      .catch(err => setCoursesError(err.message))
      .finally(() => setCoursesLoading(false))
  }, [])

  const query = searchQuery.toLowerCase().trim()
  const filteredCourses = query ? courses.filter(c => c.title.toLowerCase().includes(query)) : courses
  const enrolledCourses = filteredCourses.filter(c => c.isEnrolled)
  const availableCourses = filteredCourses.filter(c => !c.isEnrolled)

  const stats = [
    {
      label: 'Labs completados',
      value: profile?.completedLabs?.toString() ?? '—',
      unit: '',
      accent: '#2596be',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
      ),
    },
    {
      label: 'Puntos totales',
      value: profile?.points?.toLocaleString('es-CO') ?? '—',
      unit: 'pts',
      accent: '#F5C500',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
        </svg>
      ),
    },
    {
      label: 'Posición ranking',
      value: profile?.rank ? `#${profile.rank}` : '—',
      unit: '',
      accent: '#1A3F96',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      ),
    },
  ]

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <div className="min-h-[calc(100vh-72px)]">

        {/* ─── Hero ─── */}
        <div
          className={`relative overflow-hidden border-b ${isDark ? 'scanline-overlay' : ''}`}
          style={{
            borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)',
            backgroundImage: isDark
              ? 'linear-gradient(160deg, #0D1630 0%, #060D1F 100%), linear-gradient(rgba(26,63,150,0.07) 1px, transparent 1px), linear-gradient(90deg, rgba(26,63,150,0.07) 1px, transparent 1px)'
              : 'linear-gradient(160deg, #E8EEFA 0%, #EEF3FC 100%), linear-gradient(rgba(26,63,150,0.06) 1px, transparent 1px), linear-gradient(90deg, rgba(26,63,150,0.06) 1px, transparent 1px)',
            backgroundSize: 'cover, 32px 32px, 32px 32px',
          }}
        >
          <div className="relative max-w-7xl mx-auto px-6 lg:px-10 py-14 animate-fade-up-1">
            <div className="flex items-center justify-between flex-wrap gap-6">

              {/* Avatar + greeting */}
              <div className="flex items-center gap-6">
                <UserAvatar
                  src={profile?.profileImage ? `data:image/jpeg;base64,${profile.profileImage}` : null}
                  username={profile?.username ?? user?.username ?? '?'}
                  size={80}
                  isDark={isDark}
                />
                <div>
                  <p
                    className="font-mono text-xs tracking-[0.18em] mb-3"
                    style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                  >
                    // dashboard — {new Date().toLocaleDateString('es-CO', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                  </p>
                  <h1
                    className="font-display mb-2"
                    style={{
                      fontSize: 'clamp(2rem, 4vw, 3rem)',
                      lineHeight: 1.1,
                      color: isDark ? '#C8D5EE' : '#0A1545',
                    }}
                  >
                    Hola,{' '}
                    <span style={{
                      color: '#1A3F96',
                      textShadow: isDark ? '0 0 32px rgba(26,63,150,0.4)' : 'none',
                    }}>
                      {user?.username}
                    </span>
                  </h1>
                  <p
                    className="text-base font-light max-w-lg"
                    style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.65 }}
                  >
                    Continúa donde lo dejaste o explora nuevos laboratorios.
                  </p>
                </div>
              </div>

              <button
                onClick={() => setEditOpen(true)}
                disabled={!profile}
                className="flex items-center gap-2 px-5 py-3 rounded-xl text-[14px] font-medium transition-all disabled:opacity-40"
                style={{
                  color: isDark ? '#7B9FE8' : '#1A3F96',
                  background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)',
                  border: '1px solid rgba(26,63,150,0.20)',
                }}
                onMouseEnter={e => {
                  if (!profile) return
                  ;(e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.15)'
                  ;(e.currentTarget as HTMLElement).style.color = '#2451C8'
                }}
                onMouseLeave={e => {
                  ;(e.currentTarget as HTMLElement).style.background = isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)'
                  ;(e.currentTarget as HTMLElement).style.color = isDark ? '#7B9FE8' : '#1A3F96'
                }}
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
                Editar perfil
              </button>
            </div>
          </div>
        </div>

        {/* ─── Body ─── */}
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-14 space-y-16">

          {/* Stats */}
          <section className="grid grid-cols-1 sm:grid-cols-3 gap-5 animate-fade-up-2">
            {stats.map(({ label, value, unit, icon, accent }, i) => (
              <div
                key={label}
                className="hud-panel cursor-default"
                style={{
                  background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                  '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                  '--hud-border-hover': `${accent}99`,
                  '--hud-focus': accent,
                } as React.CSSProperties}
              >
                {/* Top accent strip */}
                <div style={{ height: '2px', background: `linear-gradient(90deg, transparent, ${accent}, transparent)` }} />

                <span className="hud-corner-tag" style={{ color: accent }}>{String(i + 1).padStart(2, '0')}</span>

                <div className="relative p-7">
                  {/* Top row: label kicker + icon */}
                  <div className="flex items-start justify-between mb-6">
                    <p
                      className="font-mono text-[10px] tracking-[0.22em] uppercase"
                      style={{ color: accent }}
                    >
                      {label}
                    </p>
                    <div
                      className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                      style={{
                        background: `${accent}18`,
                        border: `1px solid ${accent}35`,
                        color: accent,
                      }}
                    >
                      {icon}
                    </div>
                  </div>

                  {/* Value */}
                  <p
                    className="num-display"
                    style={{ fontSize: '3rem', lineHeight: 1.1, color: isDark ? '#C8D5EE' : '#0A1545' }}
                  >
                    {loadingProfile ? '—' : value}
                    {unit && (
                      <span className="font-mono ml-2" style={{ fontSize: '1rem', color: accent, letterSpacing: '0.05em' }}>
                        {unit}
                      </span>
                    )}
                  </p>

                  {/* Bottom accent line */}
                  <div
                    style={{
                      marginTop: '1.5rem',
                      height: '1px',
                      background: `linear-gradient(90deg, ${accent}55, ${accent}18, transparent)`,
                    }}
                  />
                </div>
              </div>
            ))}
          </section>

          {/* Búsqueda de cursos */}
          {!coursesLoading && courses.length > 0 && (
            <section className="animate-fade-up-2 -mt-6">
              <CourseSearchBar value={searchQuery} onChange={setSearchQuery} isDark={isDark} />
            </section>
          )}

          {/* Mis cursos */}
          {(coursesLoading || enrolledCourses.length > 0) && (
            <section className="animate-fade-up-3">
              <SectionHeader
                kicker="// tu progreso"
                title="Mis cursos"
                subtitle={
                  enrolledCourses.length === 0
                    ? 'Cargando…'
                    : `Estás inscrito en ${enrolledCourses.length} curso${enrolledCourses.length === 1 ? '' : 's'}.`
                }
                isDark={isDark}
              />

              {coursesLoading && enrolledCourses.length === 0 ? (
                <SkeletonGrid isDark={isDark} count={2} />
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                  {enrolledCourses.map(course => (
                    <CourseCard
                      key={course.id}
                      course={course}
                      onEnroll={() => {}}
                      onContinue={c => navigate(`/courses/${c.slug}`)}
                    />
                  ))}
                </div>
              )}
            </section>
          )}

          {/* Cursos disponibles */}
          <section className="animate-fade-up-3">
            <SectionHeader
              kicker="// catálogo"
              title={enrolledCourses.length > 0 ? 'Otros cursos disponibles' : 'Cursos disponibles'}
              subtitle="Inscríbete y empieza a sumar puntos en el ranking."
              isDark={isDark}
              badge={availableCourses.length > 0 ? `${availableCourses.length}` : undefined}
            />

            {coursesError && (
              <div
                className="flex items-start gap-3 px-4 py-3 rounded-xl"
                style={{
                  background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
                  border: '1px solid rgba(26,63,150,0.25)',
                  borderLeft: '3px solid #1A3F96',
                }}
              >
                <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
                <p className="text-sm" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{coursesError}</p>
              </div>
            )}

            {!coursesError && coursesLoading && <SkeletonGrid isDark={isDark} count={3} />}

            {!coursesError && !coursesLoading && availableCourses.length === 0 && (
              <EmptyState
                isDark={isDark}
                title={query ? 'Sin resultados' : 'Estás al día'}
                body={
                  query
                    ? `No hay cursos que coincidan con «${searchQuery.trim()}».`
                    : enrolledCourses.length > 0
                      ? 'Ya estás inscrito en todos los cursos disponibles.'
                      : 'Aún no hay cursos publicados. Vuelve pronto.'
                }
              />
            )}

            {!coursesError && availableCourses.length > 0 && (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {availableCourses.map(course => (
                  <CourseCard key={course.id} course={course} onEnroll={c => setPendingEnroll(c)} />
                ))}
              </div>
            )}
          </section>

          {/* Profile card + ranking */}
          <section className="grid grid-cols-1 lg:grid-cols-5 gap-5 animate-fade-up-3">
            <div
              className="hud-panel lg:col-span-2 p-8"
              style={{
                background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                '--hud-border-hover': 'rgba(26,63,150,0.65)',
                '--hud-focus': '#1A3F96',
              } as React.CSSProperties}
            >
              <p
                className="font-mono text-[10px] tracking-[0.22em] uppercase mb-6"
                style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
              >
                // identidad
              </p>

              {profileError && (
                <p className="text-sm" style={{ color: '#1A3F96' }}>{profileError}</p>
              )}

              {!profileError && (
                <div className="space-y-5">
                  <Row label="Username" value={profile?.username ?? '—'} isDark={isDark} mono />
                  <Row label="Email" value={profile?.email ?? '—'} isDark={isDark} mono />
                  <Row
                    label="Bio"
                    value={profile?.bio || 'Sin bio aún. Edita tu perfil para agregar una.'}
                    isDark={isDark}
                    muted={!profile?.bio}
                  />
                  <Row
                    label="Miembro desde"
                    value={profile?.createdAt
                      ? new Date(profile.createdAt).toLocaleDateString('es-CO', { year: 'numeric', month: 'long' })
                      : '—'}
                    isDark={isDark}
                    mono
                  />

                  {/* Cursos inscritos */}
                  <div>
                    <p
                      className="font-mono text-[10px] tracking-[0.18em] uppercase mb-2"
                      style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                    >
                      Cursos inscritos
                    </p>
                    {coursesLoading ? (
                      <p className="font-mono text-[13px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>—</p>
                    ) : enrolledCourses.length === 0 ? (
                      <p className="text-[14px] italic" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                        Sin cursos inscritos aún.
                      </p>
                    ) : (
                      <div className="flex flex-col gap-2">
                        {enrolledCourses.map(c => (
                          <button
                            key={c.id}
                            onClick={() => navigate(`/courses/${c.slug}`)}
                            className="flex items-center gap-2 w-fit px-3 py-1.5 rounded-lg text-[13px] font-mono transition-all duration-150 text-left"
                            style={{
                              color: isDark ? '#7B9FE8' : '#1A3F96',
                              background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)',
                              border: '1px solid rgba(26,63,150,0.18)',
                            }}
                            onMouseEnter={e => {
                              const el = e.currentTarget as HTMLElement
                              el.style.background = 'rgba(26,63,150,0.16)'
                              el.style.color = '#2596be'
                            }}
                            onMouseLeave={e => {
                              const el = e.currentTarget as HTMLElement
                              el.style.background = isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.06)'
                              el.style.color = isDark ? '#7B9FE8' : '#1A3F96'
                            }}
                          >
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: 0.6 }}>
                              <polyline points="9 18 15 12 9 6"/>
                            </svg>
                            {c.title}
                          </button>
                        ))}
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>

            <div className="lg:col-span-3">
              <div className="mb-6">
                <p
                  className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  // top operadores
                </p>
                <h3
                  className="font-display"
                  style={{ fontSize: '1.5rem', color: isDark ? '#C8D5EE' : '#0A1545' }}
                >
                  Top 5 del ranking
                </h3>
              </div>
              <Ranking
                limit={5}
                selfProfile={profile ? { username: profile.username, rank: profile.rank, points: profile.points, bio: profile.bio } : null}
              />
            </div>
          </section>
        </div>
      </div>

      <Footer />

      {profile && (
        <ProfileEditModal
          open={editOpen}
          onClose={() => setEditOpen(false)}
          initialProfile={profile}
          onUpdated={next => setProfile(next)}
        />
      )}

      <EnrollConfirmModal
        course={pendingEnroll}
        onClose={() => setPendingEnroll(null)}
        onEnrolled={enrolled => {
          setCourses(prev => prev.map(c => c.id === enrolled.id ? { ...c, isEnrolled: true } : c))
          setPendingEnroll(null)
        }}
      />
    </div>
  )
}

function UserAvatar({
  src, username, size = 72, isDark,
}: {
  src?: string | null
  username: string
  size?: number
  isDark: boolean
}) {
  const [imgError, setImgError] = useState(false)
  const showImg = src && !imgError

  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: '50%',
        overflow: 'hidden',
        background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
        border: `2px solid ${isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.25)'}`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexShrink: 0,
      }}
    >
      {showImg ? (
        <img
          src={src}
          alt={username}
          onError={() => setImgError(true)}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      ) : (
        <svg
          width={Math.round(size * 0.52)}
          height={Math.round(size * 0.52)}
          viewBox="0 0 24 24"
          fill="none"
          stroke={isDark ? '#7B9FE8' : '#1A3F96'}
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <circle cx="12" cy="8" r="4" />
          <path d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8" />
        </svg>
      )}
    </div>
  )
}

function SectionHeader({
  kicker, title, subtitle, isDark, badge,
}: {
  kicker: string; title: string; subtitle: string; isDark: boolean; badge?: string
}) {
  return (
    <div className="mb-7 flex items-end justify-between gap-4 flex-wrap">
      <div>
        <p
          className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2"
          style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
        >
          {kicker}
        </p>
        <h2
          className="font-display"
          style={{
            fontSize: 'clamp(1.6rem, 2.5vw, 2rem)',
            lineHeight: 1.15,
            color: isDark ? '#C8D5EE' : '#0A1545',
          }}
        >
          {title}
        </h2>
        <p className="text-[14px] mt-2" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
          {subtitle}
        </p>
      </div>
      {badge && (
        <span
          className="font-mono text-[11px] tracking-[0.18em] px-3 py-1.5 rounded-md"
          style={{
            color: '#1A3F96',
            background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.07)',
            border: '1px solid rgba(26,63,150,0.18)',
          }}
        >
          {badge}
        </span>
      )}
    </div>
  )
}

function SkeletonGrid({ isDark, count }: { isDark: boolean; count: number }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
      {Array.from({ length: count }).map((_, i) => (
        <div
          key={i}
          className="rounded-2xl animate-pulse"
          style={{
            height: '320px',
            background: isDark ? 'rgba(6,13,31,0.5)' : '#f8faff',
            border: `1px solid ${isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.07)'}`,
            opacity: 0.5,
          }}
        />
      ))}
    </div>
  )
}

function EmptyState({ isDark, title, body }: { isDark: boolean; title: string; body: string }) {
  return (
    <div
      className="rounded-2xl px-6 py-12 text-center"
      style={{
        background: isDark ? 'rgba(6,13,31,0.6)' : '#f8faff',
        border: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.08)'}`,
      }}
    >
      <p
        className="font-display mb-2"
        style={{ fontSize: '1.25rem', color: isDark ? '#C8D5EE' : '#0A1545' }}
      >
        {title}
      </p>
      <p
        className="text-[14px] font-light max-w-sm mx-auto"
        style={{ color: isDark ? '#4A70CC' : '#2451C8', lineHeight: 1.6 }}
      >
        {body}
      </p>
    </div>
  )
}

function CourseSearchBar({ value, onChange, isDark }: { value: string; onChange: (v: string) => void; isDark: boolean }) {
  return (
    <div>
      <p
        className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        // buscar
      </p>
      <div
        className="flex items-center gap-3 px-4 rounded-xl transition-all duration-150"
        style={{
          background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
          border: `1px solid ${isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.15)'}`,
          height: '48px',
        }}
        onFocusCapture={e => {
          (e.currentTarget as HTMLElement).style.borderColor = '#1A3F96'
          ;(e.currentTarget as HTMLElement).style.boxShadow = '0 0 0 2px rgba(26,63,150,0.15)'
        }}
        onBlurCapture={e => {
          (e.currentTarget as HTMLElement).style.borderColor = isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.15)'
          ;(e.currentTarget as HTMLElement).style.boxShadow = 'none'
        }}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: isDark ? '#3A5AB8' : '#1A3F96', flexShrink: 0 }}>
          <circle cx="11" cy="11" r="8"/>
          <line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          type="text"
          value={value}
          onChange={e => onChange(e.target.value)}
          placeholder="Buscar cursos…"
          autoComplete="off"
          className="flex-1 bg-transparent outline-none text-[14px]"
          style={{
            color: isDark ? '#C8D5EE' : '#0A1545',
            caretColor: '#1A3F96',
          }}
        />
        {value && (
          <button
            onClick={() => onChange('')}
            className="flex items-center justify-center w-5 h-5 rounded-full transition-colors shrink-0"
            style={{
              color: isDark ? '#3A5AB8' : '#4A70CC',
              background: isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.07)',
            }}
            onMouseEnter={e => { (e.currentTarget as HTMLElement).style.color = '#1A3F96' }}
            onMouseLeave={e => { (e.currentTarget as HTMLElement).style.color = isDark ? '#3A5AB8' : '#4A70CC' }}
            aria-label="Limpiar búsqueda"
          >
            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        )}
      </div>
    </div>
  )
}

function Row({
  label, value, isDark, mono = false, muted = false,
}: {
  label: string; value: string; isDark: boolean; mono?: boolean; muted?: boolean
}) {
  return (
    <div>
      <p
        className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1.5"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        {label}
      </p>
      <p
        className={mono ? 'font-mono text-[14px]' : 'text-[15px]'}
        style={{
          color: muted ? (isDark ? '#3A5AB8' : '#4A70CC') : (isDark ? '#C8D5EE' : '#0A1545'),
          fontStyle: muted ? 'italic' : 'normal',
          lineHeight: 1.5,
        }}
      >
        {value}
      </p>
    </div>
  )
}
