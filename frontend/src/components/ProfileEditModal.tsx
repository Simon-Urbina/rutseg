import { useEffect, useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'

type Tab = 'profile' | 'password'

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

function Field({
  label, type, value, onChange, placeholder, isDark, autoFocus = false,
}: {
  label: string
  type: string
  value: string
  onChange: (v: string) => void
  placeholder?: string
  isDark: boolean
  autoFocus?: boolean
}) {
  const [focused, setFocused] = useState(false)
  return (
    <div className="space-y-2">
      <label
        className="block font-mono text-[10px] tracking-[0.18em] uppercase"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        {label}
      </label>
      <div className="relative">
        <input
          type={type}
          value={value}
          onChange={e => onChange(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          placeholder={placeholder}
          autoFocus={autoFocus}
          className="input-terminal w-full text-[15px]"
          style={{
            color: isDark ? '#C8D5EE' : '#0A1545',
            borderBottomColor: focused
              ? 'transparent'
              : isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.22)',
          }}
        />
        <div
          className="absolute bottom-0 left-0 transition-all duration-300"
          style={{
            height: '1.5px',
            width: focused ? '100%' : '0%',
            background: 'linear-gradient(90deg, #1A3F96, #2596be)',
            marginBottom: '-1px',
          }}
        />
      </div>
    </div>
  )
}

function TextareaField({
  label, value, onChange, placeholder, isDark, hint,
}: {
  label: string
  value: string
  onChange: (v: string) => void
  placeholder?: string
  isDark: boolean
  hint?: string
}) {
  return (
    <div className="space-y-2">
      <label
        className="block font-mono text-[10px] tracking-[0.18em] uppercase"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        {label}
      </label>
      <textarea
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        rows={3}
        maxLength={500}
        className="tech-input w-full text-[15px] p-3"
        style={{
          background: isDark ? 'rgba(0,0,0,0.25)' : 'rgba(0,0,0,0.02)',
          color: isDark ? '#C8D5EE' : '#0A1545',
          fontFamily: "'DM Sans', sans-serif",
          resize: 'vertical',
          '--tech-input-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.30)',
        } as React.CSSProperties}
      />
      {hint && (
        <p className="font-mono text-[10px]" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
          {hint}
        </p>
      )}
    </div>
  )
}

interface Props {
  open: boolean
  onClose: () => void
  initialProfile: FullProfile
  onUpdated: (next: FullProfile) => void
}

export default function ProfileEditModal({ open, onClose, initialProfile, onUpdated }: Props) {
  const { theme } = useTheme()
  const { updateUser } = useAuth()
  const isDark = theme === 'dark'

  const [tab, setTab] = useState<Tab>('profile')

  const [username, setUsername] = useState(initialProfile.username)
  const [email, setEmail] = useState(initialProfile.email)
  const [bio, setBio] = useState(initialProfile.bio ?? '')

  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')

  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [loading, setLoading] = useState(false)
  const [avatarLoading, setAvatarLoading] = useState(false)
  const [avatarPreview, setAvatarPreview] = useState<string | null>(
    initialProfile.profileImage ? `data:image/jpeg;base64,${initialProfile.profileImage}` : null
  )
  const [avatarImgError, setAvatarImgError] = useState(false)

  useEffect(() => {
    if (open) {
      setUsername(initialProfile.username)
      setEmail(initialProfile.email)
      setBio(initialProfile.bio ?? '')
      setCurrentPassword('')
      setNewPassword('')
      setConfirmPassword('')
      setError('')
      setSuccess('')
      setTab('profile')
      setAvatarPreview(initialProfile.profileImage ? `data:image/jpeg;base64,${initialProfile.profileImage}` : null)
      setAvatarImgError(false)
    }
  }, [open, initialProfile])

  const handleAvatarChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (!['image/jpeg', 'image/jpg'].includes(file.type)) {
      setError('Solo se aceptan imágenes JPG/JPEG.')
      return
    }
    if (file.size > 5 * 1024 * 1024) {
      setError('La imagen no puede superar los 5 MB.')
      return
    }

    const preview = URL.createObjectURL(file)
    setAvatarPreview(preview)
    setAvatarImgError(false)
    setError('')
    setAvatarLoading(true)

    try {
      const token = localStorage.getItem('token')
      const base = import.meta.env.VITE_API_URL ?? 'http://localhost:3000'
      const formData = new FormData()
      formData.append('avatar', file)
      const res = await fetch(`${base}/api/users/me/avatar`, {
        method: 'POST',
        headers: token ? { Authorization: `Bearer ${token}` } : {},
        body: formData,
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error ?? 'Error al subir la foto.')

      const updated = await (await fetch(`${base}/api/users/me`, {
        headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      })).json()
      onUpdated(updated)
      setSuccess('Foto de perfil actualizada.')
    } catch (err: any) {
      setError(err.message)
      setAvatarPreview(initialProfile.profileImage ? `data:image/jpeg;base64,${initialProfile.profileImage}` : null)
    } finally {
      setAvatarLoading(false)
      e.target.value = ''
    }
  }

  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [open, onClose])

  if (!open) return null

  const profileChanged =
    username.trim() !== initialProfile.username ||
    email.trim() !== initialProfile.email ||
    (bio.trim() || null) !== (initialProfile.bio ?? null)

  const submitProfile = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(''); setSuccess('')
    if (!profileChanged) {
      setError('No hay cambios para guardar.')
      return
    }
    setLoading(true)
    try {
      const patch: Record<string, string | null> = {}
      if (username.trim() !== initialProfile.username) patch.username = username.trim()
      if (email.trim() !== initialProfile.email) patch.email = email.trim()
      if ((bio.trim() || null) !== (initialProfile.bio ?? null)) patch.bio = bio.trim() || null

      const next = await api.put<FullProfile>('/api/users/me', patch)
      updateUser({ username: next.username, email: next.email })
      onUpdated(next)
      setSuccess('Perfil actualizado.')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const submitPassword = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(''); setSuccess('')
    if (newPassword !== confirmPassword) {
      setError('Las contraseñas nuevas no coinciden.')
      return
    }
    if (newPassword.length < 8) {
      setError('La nueva contraseña debe tener al menos 8 caracteres.')
      return
    }
    setLoading(true)
    try {
      await api.post('/api/users/me/password', { currentPassword, newPassword })
      setCurrentPassword(''); setNewPassword(''); setConfirmPassword('')
      setSuccess('Contraseña actualizada.')
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center p-4 animate-fade-up-1"
      style={{
        background: 'rgba(6,13,31,0.75)',
        backdropFilter: 'blur(8px)',
        WebkitBackdropFilter: 'blur(8px)',
      }}
      onClick={onClose}
    >
      <div
        onClick={e => e.stopPropagation()}
        className="hud-panel hud-static relative w-full max-w-[520px]"
        style={{
          background: isDark ? 'rgba(9,21,32,0.84)' : 'rgba(248,250,255,0.92)',
          backdropFilter: 'blur(24px)',
          WebkitBackdropFilter: 'blur(24px)',
          boxShadow: '0 32px 80px rgba(0,0,0,0.5), 0 0 60px rgba(26,63,150,0.10)',
          maxHeight: '90vh',
          display: 'flex',
          flexDirection: 'column',
          '--hud-border': isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.30)',
          '--hud-border-hover': isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.30)',
        } as React.CSSProperties}
      >
        {/* Header */}
        <div
          className="flex items-center justify-between px-7 py-5 shrink-0"
          style={{ borderBottom: `1px solid ${isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)'}` }}
        >
          <div>
            <p
              className="font-mono text-[10px] tracking-[0.22em] uppercase mb-1"
              style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
            >
              // configuración
            </p>
            <h3
              className="font-display"
              style={{ fontSize: '1.5rem', color: isDark ? '#C8D5EE' : '#0A1545' }}
            >
              Editar perfil
            </h3>
          </div>
          <button
            onClick={onClose}
            aria-label="Cerrar"
            className="w-9 h-9 rounded-lg flex items-center justify-center transition-colors"
            style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
            onMouseEnter={e => { (e.currentTarget as HTMLElement).style.background = 'rgba(26,63,150,0.10)' }}
            onMouseLeave={e => { (e.currentTarget as HTMLElement).style.background = 'transparent' }}
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"/>
              <line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        {/* Tabs */}
        <div
          className="flex shrink-0 px-7"
          style={{ borderBottom: `1px solid ${isDark ? 'rgba(26,63,150,0.10)' : 'rgba(26,63,150,0.08)'}` }}
        >
          {[
            { id: 'profile', label: 'Perfil' },
            { id: 'password', label: 'Contraseña' },
          ].map(t => {
            const active = tab === t.id
            return (
              <button
                key={t.id}
                onClick={() => { setTab(t.id as Tab); setError(''); setSuccess('') }}
                className="relative px-1 py-3.5 mr-7 text-[13px] font-medium transition-colors"
                style={{
                  color: active ? '#1A3F96' : (isDark ? '#3A5AB8' : '#4A70CC'),
                }}
              >
                {t.label}
                {active && (
                  <span
                    className="absolute bottom-0 left-0 right-0"
                    style={{ height: '1.5px', background: '#1A3F96' }}
                  />
                )}
              </button>
            )
          })}
        </div>

        {/* Body */}
        <div className="px-7 py-7 overflow-y-auto" style={{ flex: 1 }}>
          {tab === 'profile' && (
            <form onSubmit={submitProfile} className="space-y-7">
              {/* Avatar upload */}
              <div className="flex items-center gap-5">
                <label className="relative cursor-pointer group shrink-0" title="Cambiar foto de perfil">
                  <input
                    type="file"
                    accept="image/jpeg,image/jpg"
                    className="sr-only"
                    onChange={handleAvatarChange}
                    disabled={avatarLoading}
                  />
                  <div
                    style={{
                      width: 72, height: 72,
                      borderRadius: '50%',
                      overflow: 'hidden',
                      background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.08)',
                      border: `2px solid ${isDark ? 'rgba(26,63,150,0.40)' : 'rgba(26,63,150,0.25)'}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      position: 'relative',
                    }}
                  >
                    {(avatarPreview && !avatarImgError) ? (
                      <img
                        src={avatarPreview}
                        alt="Avatar"
                        onError={() => setAvatarImgError(true)}
                        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                      />
                    ) : (
                      <svg width="38" height="38" viewBox="0 0 24 24" fill="none"
                        stroke={isDark ? '#7B9FE8' : '#1A3F96'} strokeWidth="1.5"
                        strokeLinecap="round" strokeLinejoin="round">
                        <circle cx="12" cy="8" r="4" />
                        <path d="M4 20c0-4.418 3.582-8 8-8s8 3.582 8 8" />
                      </svg>
                    )}
                    {/* Overlay on hover */}
                    <div
                      className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                      style={{ background: 'rgba(6,13,31,0.55)', borderRadius: '50%' }}
                    >
                      {avatarLoading ? (
                        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      ) : (
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#EEF3FC" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                          <polyline points="17 8 12 3 7 8"/>
                          <line x1="12" y1="3" x2="12" y2="15"/>
                        </svg>
                      )}
                    </div>
                  </div>
                </label>
                <div>
                  <p className="text-[13px] font-medium" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    Foto de perfil
                  </p>
                  <p className="font-mono text-[10px] mt-1" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                    JPG · máx 5 MB
                  </p>
                </div>
              </div>

              <Field label="Username" type="text" value={username} onChange={setUsername} isDark={isDark} autoFocus />
              <Field label="Email" type="email" value={email} onChange={setEmail} isDark={isDark} />
              <TextareaField
                label="Bio"
                value={bio}
                onChange={setBio}
                placeholder="¿Qué te define como hacker?"
                isDark={isDark}
                hint={`${bio.length}/500 caracteres`}
              />

              {error && <ErrorBox isDark={isDark} message={error} />}
              {success && <SuccessBox isDark={isDark} message={success} />}

              <button
                type="submit"
                disabled={loading || !profileChanged}
                className="btn-neon w-full py-3.5 rounded-xl text-[15px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Guardando</span>
                ) : (
                  'Guardar cambios'
                )}
              </button>
            </form>
          )}

          {tab === 'password' && (
            <form onSubmit={submitPassword} className="space-y-7">
              <Field label="Contraseña actual" type="password" value={currentPassword} onChange={setCurrentPassword} isDark={isDark} autoFocus />
              <Field label="Nueva contraseña" type="password" value={newPassword} onChange={setNewPassword} placeholder="mín. 8 caracteres" isDark={isDark} />
              <Field label="Confirmar nueva contraseña" type="password" value={confirmPassword} onChange={setConfirmPassword} isDark={isDark} />

              {error && <ErrorBox isDark={isDark} message={error} />}
              {success && <SuccessBox isDark={isDark} message={success} />}

              <button
                type="submit"
                disabled={loading || !currentPassword || !newPassword || !confirmPassword}
                className="btn-gold w-full py-3.5 rounded-xl text-[15px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? (
                  <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Actualizando</span>
                ) : (
                  'Cambiar contraseña'
                )}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}

function ErrorBox({ isDark, message }: { isDark: boolean; message: string }) {
  return (
    <div
      className="flex items-start gap-3 px-4 py-3 rounded-xl"
      style={{
        background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
        border: '1px solid rgba(26,63,150,0.25)',
        borderLeft: '3px solid #1A3F96',
      }}
    >
      <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
      <p className="text-sm" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{message}</p>
    </div>
  )
}

function SuccessBox({ isDark, message }: { isDark: boolean; message: string }) {
  return (
    <div
      className="flex items-start gap-3 px-4 py-3 rounded-xl"
      style={{
        background: isDark ? 'rgba(0,40,20,0.4)' : '#eaf7ee',
        border: '1px solid rgba(82,173,112,0.3)',
        borderLeft: '3px solid #52ad70',
      }}
    >
      <span className="font-mono text-xs mt-0.5" style={{ color: '#52ad70' }}>OK</span>
      <p className="text-sm" style={{ color: isDark ? '#97cea9' : '#316843' }}>{message}</p>
    </div>
  )
}
