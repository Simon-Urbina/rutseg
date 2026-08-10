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
      accent: '#2596be',
      kicker: '// PROGRESO',
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
      ),
    },
    {
      label: 'Puntos totales',
      value: profile?.points?.toLocaleString('es-CO') ?? '—',
      unit: 'pts',
      accent: '#F5C500',
      kicker: '// PUNTAJE',
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
        </svg>
      ),
    },
    {
      label: 'Posición ranking',
      value: profile?.rank ? `#${profile.rank}` : '—',
      accent: '#1A3F96',
      kicker: '// CLASIFICACIÓN',
      icon: (
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      ),
    },
  ]

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: isDark ? '#EEF3FC' : '#0A1545' }}>
      <div className="min-h-[calc(100vh-72px)]">

        {/* Hero */}
        <div
          className="relative border-b py-10 sm:py-12"
          style={{
            borderColor: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)',
            background: isDark
              ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 100%)'
              : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 100%)',
          }}
        >
          <div className="max-w-7xl mx-auto px-6 lg:px-10">
            <div className="flex items-center justify-between flex-wrap gap-6">

              {/* Avatar + greeting */}
              <div className="flex items-center gap-5 sm:gap-6">
                <UserAvatar
                  src={profile?.profileImage ? `data:image/jpeg;base64,${profile.profileImage}` : null}
                  username={profile?.username ?? user?.username ?? '?'}
                  size={72}
                  isDark={isDark}
                />
                <div>
                  <p
                    className="font-mono text-xs tracking-[0.18em] uppercase mb-2 font-medium"
                    style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                  >
                    // DASHBOARD — {new Date().toLocaleDateString('es-CO', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                  </p>
                  <h1
                    className="font-display text-3xl sm:text-4xl font-bold tracking-tight mb-1"
                    style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
                  >
                    Hola, <span style={{ color: '#1A3F96' }}>{user?.username}</span>
                  </h1>
                  <p
                    className="text-sm sm:text-base font-light"
                    style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
                  >
                    Continúa donde lo dejaste o explora nuevos laboratorios.
                  </p>
                </div>
              </div>

              <button
                onClick={() => setEditOpen(true)}
                disabled={!profile}
                className="btn-ghost-light text-sm px-4 py-2.5 flex items-center gap-2"
              >
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                  <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
                Editar perfil
              </button>
            </div>
          </div>
        </div>

        {/* Body */}
        <div className="max-w-7xl mx-auto px-6 lg:px-10 py-12 space-y-12">

          {/* Stats Grid */}
          <section className="grid grid-cols-1 sm:grid-cols-3 gap-6 animate-fade-up-2">
            {stats.map(({ label, value, unit, icon, accent, kicker }) => (
              <div key={label} className="hud-panel p-7 flex flex-col justify-between">
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <span
                      className="font-mono text-[10px] tracking-[0.2em] uppercase font-semibold"
                      style={{ color: accent }}
                    >
                      {kicker}
                    </span>
                    <div
                      className="w-9 h-9 rounded-lg flex items-center justify-center"
                      style={{
                        background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
                        border: `1px solid ${accent}30`,
                        color: accent,
                      }}
                    >
                      {icon}
                    </div>
                  </div>

                  <p
                    className="font-mono text-xs tracking-widest uppercase mb-1"
                    style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                  >
                    {label}
                  </p>

                  <p className="num-display text-4xl sm:text-5xl font-bold leading-none" style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}>
                    {loadingProfile ? '—' : value}
                    {unit && (
                      <span className="font-mono ml-2 text-sm font-semibold" style={{ color: accent }}>
                        {unit}
                      </span>
                    )}
                  </p>
                </div>
              </div>
            ))}
          </section>

          {/* Search bar */}
          {!coursesLoading && courses.length > 0 && (
            <section className="animate-fade-up-2">
              <CourseSearchBar value={searchQuery} onChange={setSearchQuery} isDark={isDark} />
            </section>
          )}

          {/* Mis cursos */}
          {(coursesLoading || enrolledCourses.length > 0) && (
            <section className="animate-fade-up-3">
              <SectionHeader
                kicker="// TU PROGRESO"
                title="Mis cursos"
                subtitle={
                  enrolledCourses.length === 0
                    ? 'Cargando…'
                    : `Estás inscrito en ${enrolledCourses.length} curso${enrolledCourses.length === 1 ? '' : 's'}.`
                }
                isDark={isDark}
              />

              {coursesLoading && enrolledCourses.length === 0 ? (
                <SkeletonGrid count={2} isDark={isDark} />
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
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
              kicker="// CATÁLOGO"
              title={enrolledCourses.length > 0 ? 'Otros cursos disponibles' : 'Cursos disponibles'}
              subtitle="Inscríbete y empieza a sumar puntos en el ranking."
              isDark={isDark}
              badge={availableCourses.length > 0 ? `${availableCourses.length}` : undefined}
            />

            {coursesError && (
              <div
                className="p-4 rounded-xl border font-mono text-sm"
                style={{
                  background: isDark ? 'rgba(6,13,31,0.6)' : '#EEF0F8',
                  borderColor: 'rgba(26,63,150,0.25)',
                  color: '#1A3F96',
                }}
              >
                ERR: {coursesError}
              </div>
            )}

            {!coursesError && coursesLoading && <SkeletonGrid count={3} isDark={isDark} />}

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
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {availableCourses.map(course => (
                  <CourseCard key={course.id} course={course} onEnroll={c => setPendingEnroll(c)} />
                ))}
              </div>
            )}
          </section>

          {/* Profile card & ranking */}
          <section className="grid grid-cols-1 lg:grid-cols-5 gap-6 animate-fade-up-3">
            <div className="hud-panel lg:col-span-2 p-8 flex flex-col justify-between">
              <div>
                <p
                  className="font-mono text-[10px] tracking-[0.22em] uppercase mb-6 font-semibold"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  // IDENTIDAD DE ESTUDIANTE
                </p>

                {profileError && (
                  <p className="text-sm" style={{ color: '#1A3F96' }}>{profileError}</p>
                )}

                {!profileError && (
                  <div className="space-y-5">
                    <Row label="Usuario" value={profile?.username ?? '—'} isDark={isDark} mono />
                    <Row label="Correo Electrónico" value={profile?.email ?? '—'} isDark={isDark} mono />
                    <Row
                      label="Biografía"
                      value={profile?.bio || 'Sin biografía aún. Edita tu perfil para agregar una.'}
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
                  </div>
                )}
              </div>
            </div>

            <div className="lg:col-span-3">
              <div className="mb-6">
                <p
                  className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2 font-semibold"
                  style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
                >
                  // CLASIFICACIÓN
                </p>
                <h3
                  className="font-display text-2xl font-bold"
                  style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
                >
                  Top 5 del ranking
                </h3>
              </div>
              <div className="hud-panel p-6 sm:p-8">
                <Ranking
                  limit={5}
                  selfProfile={profile ? { username: profile.username, rank: profile.rank, points: profile.points, bio: profile.bio } : null}
                />
              </div>
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
        justify-content: 'center',
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
          width={Math.round(size * 0.5)}
          height={Math.round(size * 0.5)}
          viewBox="0 0 24 24"
          fill="none"
          stroke={isDark ? '#7B9FE8' : '#1A3F96'}
          strokeWidth="1.8"
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
    <div className="mb-8 flex items-end justify-between gap-4 flex-wrap">
      <div>
        <p
          className="font-mono text-[10px] tracking-[0.22em] uppercase mb-2 font-semibold"
          style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
        >
          {kicker}
        </p>
        <h2
          className="font-display text-2xl sm:text-3xl font-bold tracking-tight"
          style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
        >
          {title}
        </h2>
        <p className="text-sm mt-1" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
          {subtitle}
        </p>
      </div>
      {badge && (
        <span
          className="font-mono text-[11px] tracking-[0.18em] px-3 py-1 rounded border font-semibold uppercase"
          style={{
            color: '#1A3F96',
            background: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.06)',
            borderColor: 'rgba(26,63,150,0.20)',
          }}
        >
          {badge} DISPONIBLES
        </span>
      )}
    </div>
  )
}

function SkeletonGrid({ isDark, count }: { isDark: boolean; count: number }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {Array.from({ length: count }).map((_, i) => (
        <div
          key={i}
          className="rounded-2xl animate-pulse h-80"
          style={{
            background: isDark ? 'rgba(6,13,31,0.5)' : '#f8faff',
            border: `1px solid ${isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.12)'}`,
          }}
        />
      ))}
    </div>
  )
}

function EmptyState({ isDark, title, body }: { isDark: boolean; title: string; body: string }) {
  return (
    <div className="hud-panel p-12 text-center">
      <h3
        className="font-display text-xl font-bold mb-2"
        style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}
      >
        {title}
      </h3>
      <p
        className="text-sm font-light max-w-sm mx-auto"
        style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}
      >
        {body}
      </p>
    </div>
  )
}

function CourseSearchBar({ value, onChange, isDark }: { value: string; onChange: (v: string) => void; isDark: boolean }) {
  return (
    <div
      className="hud-panel p-3 flex items-center gap-3"
      style={{
        background: isDark ? 'rgba(13,27,70,0.85)' : '#FFFFFF',
      }}
    >
      <svg
        width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
        className="shrink-0 ml-2"
      >
        <circle cx="11" cy="11" r="8"/>
        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
      <input
        type="text"
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder="Buscar cursos…"
        className="flex-1 bg-transparent outline-none text-sm px-2"
        style={{
          color: isDark ? '#C8D5EE' : '#0A1545',
        }}
      />
      {value && (
        <button
          onClick={() => onChange('')}
          className="text-xs font-mono px-2.5 py-1 rounded bg-black/10 text-slate-400 hover:text-white transition-colors"
        >
          Limpiar
        </button>
      )}
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
        className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1 font-semibold"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        {label}
      </p>
      <p
        className={mono ? 'font-mono text-sm' : 'text-sm'}
        style={{
          color: muted ? (isDark ? '#3A5AB8' : '#4A70CC') : (isDark ? '#C8D5EE' : '#0A1545'),
          fontStyle: muted ? 'italic' : 'normal',
        }}
      >
        {value}
      </p>
    </div>
  )
}
