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
      label: 'Labs Completados',
      value: profile?.completedLabs?.toString() ?? '—',
      accent: '#2596be',
      badge: 'PROGRESO',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
        </svg>
      ),
    },
    {
      label: 'Puntos Totales',
      value: profile?.points?.toLocaleString('es-CO') ?? '—',
      unit: 'pts',
      accent: '#F5C500',
      badge: 'SCORE',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
        </svg>
      ),
    },
    {
      label: 'Posición Global',
      value: profile?.rank ? `#${profile.rank}` : '—',
      accent: '#10B981',
      badge: 'RANKING',
      icon: (
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
      ),
    },
  ]

  return (
    <div className={`min-h-screen ${isDark ? 'bg-[#060D1F] text-slate-100' : 'bg-slate-50 text-slate-900'}`}>
      {/* Ambient background mesh orbs */}
      <div className="wm-orb w-96 h-96 top-0 left-[-50px] bg-teal-500/10 blur-3xl pointer-events-none" />
      <div className="wm-orb w-[500px] h-[500px] top-[300px] right-[-100px] bg-indigo-500/10 blur-3xl pointer-events-none" />

      {/* ─── Hero Section ─── */}
      <div className="relative border-b border-slate-200 dark:border-white/10 pt-8 pb-12">
        <div className="max-w-7xl mx-auto px-6 lg:px-10">
          <div className="flex items-center justify-between flex-wrap gap-6">

            {/* Avatar + greeting */}
            <div className="flex items-center gap-5 sm:gap-6">
              <UserAvatar
                src={profile?.profileImage ? `data:image/jpeg;base64,${profile.profileImage}` : null}
                username={profile?.username ?? user?.username ?? '?'}
                size={76}
                isDark={isDark}
              />
              <div>
                <p className="font-mono text-xs text-teal-400 font-bold tracking-widest uppercase mb-2">
                  // OPERADOR ACTIVO — {new Date().toLocaleDateString('es-CO', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                </p>
                <h1 className="font-display text-3xl sm:text-4xl font-extrabold tracking-tight">
                  Hola, <span className="bg-gradient-to-r from-teal-400 to-sky-400 bg-clip-text text-transparent">{user?.username}</span>
                </h1>
                <p className="text-slate-600 dark:text-slate-300 text-sm sm:text-base font-normal mt-1">
                  Continúa donde lo dejaste o explora nuevos laboratorios.
                </p>
              </div>
            </div>

            <button
              onClick={() => setEditOpen(true)}
              disabled={!profile}
              className="btn-wm-secondary text-sm font-semibold py-2.5 px-5 flex items-center gap-2"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
              </svg>
              Editar Perfil
            </button>
          </div>
        </div>
      </div>

      {/* ─── Main Body Bento Dashboard ─── */}
      <div className="max-w-7xl mx-auto px-6 lg:px-10 py-12 space-y-12">

        {/* BENTO STATS GRID */}
        <section className="grid grid-cols-1 sm:grid-cols-3 gap-6 animate-fade-up-2">
          {stats.map(({ label, value, unit, icon, accent, badge }) => (
            <div
              key={label}
              className="glass-card-wm p-7 flex flex-col justify-between group hover:border-teal-500/40 relative overflow-hidden"
            >
              <div className="flex items-center justify-between mb-6">
                <span className="font-mono text-[10px] tracking-widest uppercase px-3 py-1 rounded-full border border-white/10 bg-white/5 text-slate-400">
                  {badge}
                </span>
                <div
                  className="w-10 h-10 rounded-xl flex items-center justify-center transition-transform group-hover:scale-110"
                  style={{
                    background: `${accent}15`,
                    color: accent,
                    border: `1px solid ${accent}30`,
                  }}
                >
                  {icon}
                </div>
              </div>

              <div>
                <p className="font-mono text-xs tracking-widest uppercase text-slate-500 dark:text-slate-400 mb-2">
                  {label}
                </p>
                <p className="num-display text-4xl sm:text-5xl font-extrabold text-slate-900 dark:text-white leading-none">
                  {loadingProfile ? '—' : value}
                  {unit && (
                    <span className="font-mono ml-2 text-base text-amber-400 font-bold">
                      {unit}
                    </span>
                  )}
                </p>
              </div>
            </div>
          ))}
        </section>

        {/* SEARCH BAR */}
        {!coursesLoading && courses.length > 0 && (
          <section className="animate-fade-up-2">
            <CourseSearchBar value={searchQuery} onChange={setSearchQuery} isDark={isDark} />
          </section>
        )}

        {/* MIS CURSOS INSCRITOS */}
        {(coursesLoading || enrolledCourses.length > 0) && (
          <section className="animate-fade-up-3">
            <SectionHeader
              kicker="// TU PROGRESO"
              title="Mis Cursos"
              subtitle={
                enrolledCourses.length === 0
                  ? 'Cargando…'
                  : `Estás inscrito en ${enrolledCourses.length} curso${enrolledCourses.length === 1 ? '' : 's'}.`
              }
              isDark={isDark}
            />

            {coursesLoading && enrolledCourses.length === 0 ? (
              <SkeletonGrid count={2} />
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

        {/* CURSOS DISPONIBLES */}
        <section className="animate-fade-up-3">
          <SectionHeader
            kicker="// CATÁLOGO COMPLETO"
            title={enrolledCourses.length > 0 ? 'Otros Cursos Disponibles' : 'Cursos Disponibles'}
            subtitle="Inscríbete y empieza a sumar puntos en el ranking global."
            isDark={isDark}
            badge={availableCourses.length > 0 ? `${availableCourses.length}` : undefined}
          />

          {coursesError && (
            <div className="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-400 font-mono text-sm">
              ERROR: {coursesError}
            </div>
          )}

          {!coursesError && coursesLoading && <SkeletonGrid count={3} />}

          {!coursesError && !coursesLoading && availableCourses.length === 0 && (
            <EmptyState
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

        {/* PROFILE CARD & RANKING SECTION */}
        <section className="grid grid-cols-1 lg:grid-cols-5 gap-6 animate-fade-up-3">
          {/* Identity Card */}
          <div className="glass-card-wm lg:col-span-2 p-8 flex flex-col justify-between">
            <div>
              <span className="font-mono text-xs text-teal-400 font-bold tracking-widest uppercase block mb-6">
                // IDENTIDAD DE OPERADOR
              </span>

              {profileError && (
                <p className="text-sm text-rose-400">{profileError}</p>
              )}

              {!profileError && (
                <div className="space-y-6">
                  <Row label="Usuario" value={profile?.username ?? '—'} mono />
                  <Row label="Correo Electrónico" value={profile?.email ?? '—'} mono />
                  <Row
                    label="Biografía"
                    value={profile?.bio || 'Sin biografía aún. Edita tu perfil para agregar una.'}
                    muted={!profile?.bio}
                  />
                  <Row
                    label="Miembro Desde"
                    value={profile?.createdAt
                      ? new Date(profile.createdAt).toLocaleDateString('es-CO', { year: 'numeric', month: 'long' })
                      : '—'}
                    mono
                  />
                </div>
              )}
            </div>
          </div>

          {/* Ranking Widget */}
          <div className="lg:col-span-3">
            <div className="mb-6">
              <span className="font-mono text-xs text-amber-400 font-bold tracking-widest uppercase block mb-2">
                // CLASIFICACIÓN
              </span>
              <h3 className="font-display text-2xl font-bold">Top 5 del Ranking Global</h3>
            </div>
            <div className="glass-card-wm p-6 sm:p-8">
              <Ranking
                limit={5}
                selfProfile={profile ? { username: profile.username, rank: profile.rank, points: profile.points, bio: profile.bio } : null}
              />
            </div>
          </div>
        </section>
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
  src, username, size = 76, isDark,
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
      style={{ width: size, height: size }}
      className="rounded-full overflow-hidden border-2 border-teal-500/30 flex items-center justify-center shrink-0 bg-teal-500/10 shadow-lg"
    >
      {showImg ? (
        <img
          src={src}
          alt={username}
          onError={() => setImgError(true)}
          className="w-full h-full object-cover"
        />
      ) : (
        <svg
          width={Math.round(size * 0.5)}
          height={Math.round(size * 0.5)}
          viewBox="0 0 24 24"
          fill="none"
          stroke={isDark ? '#2596be' : '#1A3F96'}
          strokeWidth="2"
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
  kicker, title, subtitle, badge,
}: {
  kicker: string; title: string; subtitle: string; isDark: boolean; badge?: string
}) {
  return (
    <div className="mb-8 flex items-end justify-between gap-4 flex-wrap">
      <div>
        <span className="font-mono text-xs text-teal-400 font-bold tracking-widest uppercase block mb-2">
          {kicker}
        </span>
        <h2 className="font-display text-2xl sm:text-3xl font-bold tracking-tight">
          {title}
        </h2>
        <p className="text-slate-600 dark:text-slate-300 text-sm mt-1">
          {subtitle}
        </p>
      </div>
      {badge && (
        <span className="font-mono text-xs px-3 py-1.5 rounded-full border border-teal-500/20 bg-teal-500/10 text-teal-400 font-bold">
          {badge} DISPONIBLES
        </span>
      )}
    </div>
  )
}

function SkeletonGrid({ count }: { count: number }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className="glass-card-wm h-80 animate-pulse bg-white/5" />
      ))}
    </div>
  )
}

function EmptyState({ title, body }: { title: string; body: string }) {
  return (
    <div className="glass-card-wm p-12 text-center">
      <h3 className="font-display text-xl font-bold mb-2">{title}</h3>
      <p className="text-slate-600 dark:text-slate-400 text-sm max-w-md mx-auto">{body}</p>
    </div>
  )
}

function CourseSearchBar({ value, onChange }: { value: string; onChange: (v: string) => void; isDark: boolean }) {
  return (
    <div className="glass-card-wm p-3 flex items-center gap-3">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-teal-400 shrink-0 ml-2">
        <circle cx="11" cy="11" r="8"/>
        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
      <input
        type="text"
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder="Buscar cursos por título o tecnología…"
        className="flex-1 bg-transparent outline-none text-sm px-2 text-slate-900 dark:text-white placeholder-slate-400"
      />
      {value && (
        <button
          onClick={() => onChange('')}
          className="text-slate-400 hover:text-white px-3 py-1 font-mono text-xs rounded-lg bg-white/5"
        >
          Limpiar
        </button>
      )}
    </div>
  )
}

function Row({
  label, value, mono = false, muted = false,
}: {
  label: string; value: string; mono?: boolean; muted?: boolean
}) {
  return (
    <div>
      <p className="font-mono text-[10px] tracking-widest text-slate-400 uppercase mb-1">
        {label}
      </p>
      <p className={`${mono ? 'font-mono text-sm' : 'text-sm'} ${muted ? 'text-slate-500 italic' : 'text-slate-900 dark:text-slate-100'}`}>
        {value}
      </p>
    </div>
  )
}
