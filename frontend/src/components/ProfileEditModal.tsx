import { useEffect, useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import { useAuth } from '../context/AuthContext'
import { api } from '../lib/api'
import GoogleLinkButton from './GoogleLinkButton'

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
  hasPassword: boolean
  linkedProviders: string[]
}

function Field({
  label, type, value, onChange, placeholder, isDark, autoFocus = false, hint,
}: {
  label: string
  type: string
  value: string
  onChange: (v: string) => void
  placeholder?: string
  isDark: boolean
  autoFocus?: boolean
  hint?: string
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
      {hint && (
        <p className="text-[12px] font-light leading-relaxed" style={{ color: isDark ? '#7B9FE8' : '#4A70CC' }}>
          {hint}
        </p>
      )}
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

function SectionHeading({ isDark, kicker, title }: { isDark: boolean; kicker: string; title: string }) {
  return (
    <div>
      <p
        className="font-mono text-[10px] tracking-[0.22em] uppercase mb-1.5 font-semibold"
        style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
      >
        {kicker}
      </p>
      <h4 className="font-display" style={{ fontSize: '1.15rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        {title}
      </h4>
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

  const [username, setUsername] = useState(initialProfile.username)
  const [email, setEmail] = useState(initialProfile.email)
  const [bio, setBio] = useState(initialProfile.bio ?? '')
  const [profileError, setProfileError] = useState('')
  const [profileSuccess, setProfileSuccess] = useState('')
  const [profileLoading, setProfileLoading] = useState(false)

  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [passwordError, setPasswordError] = useState('')
  const [passwordSuccess, setPasswordSuccess] = useState('')
  const [passwordLoading, setPasswordLoading] = useState(false)

  const [avatarLoading, setAvatarLoading] = useState(false)
  const [avatarPreview, setAvatarPreview] = useState<string | null>(
    initialProfile.profileImage ? `data:image/jpeg;base64,${initialProfile.profileImage}` : null
  )
  const [avatarImgError, setAvatarImgError] = useState(false)
  const [avatarError, setAvatarError] = useState('')

  useEffect(() => {
    if (open) {
      setUsername(initialProfile.username)
      setEmail(initialProfile.email)
      setBio(initialProfile.bio ?? '')
      setCurrentPassword('')
      setNewPassword('')
      setConfirmPassword('')
      setProfileError(''); setProfileSuccess('')
      setPasswordError(''); setPasswordSuccess('')
      setAvatarError('')
      setAvatarPreview(initialProfile.profileImage ? `data:image/jpeg;base64,${initialProfile.profileImage}` : null)
      setAvatarImgError(false)
    }
  }, [open, initialProfile])

  const handleAvatarChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (!['image/jpeg', 'image/jpg'].includes(file.type)) {
      setAvatarError('Solo se aceptan imágenes JPG/JPEG.')
      return
    }
    if (file.size > 5 * 1024 * 1024) {
      setAvatarError('La imagen no puede superar los 5 MB.')
      return
    }

    const preview = URL.createObjectURL(file)
    setAvatarPreview(preview)
    setAvatarImgError(false)
    setAvatarError('')
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
    } catch (err: any) {
      setAvatarError(err.message)
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
    setProfileError(''); setProfileSuccess('')
    if (!profileChanged) {
      setProfileError('No hay cambios para guardar.')
      return
    }
    setProfileLoading(true)
    try {
      const patch: Record<string, string | null> = {}
      if (username.trim() !== initialProfile.username) patch.username = username.trim()
      if (email.trim() !== initialProfile.email) patch.email = email.trim()
      if ((bio.trim() || null) !== (initialProfile.bio ?? null)) patch.bio = bio.trim() || null

      const next = await api.put<FullProfile>('/api/users/me', patch)
      updateUser({ username: next.username, email: next.email })
      onUpdated(next)
      setProfileSuccess('Perfil actualizado.')
    } catch (err: any) {
      setProfileError(err.message)
    } finally {
      setProfileLoading(false)
    }
  }

  const submitPassword = async (e: React.FormEvent) => {
    e.preventDefault()
    setPasswordError(''); setPasswordSuccess('')
    if (newPassword !== confirmPassword) {
      setPasswordError('Las contraseñas nuevas no coinciden.')
      return
    }
    if (newPassword.length < 8) {
      setPasswordError('La nueva contraseña debe tener al menos 8 caracteres.')
      return
    }
    setPasswordLoading(true)
    try {
      await api.post('/api/users/me/password', initialProfile.hasPassword ? { currentPassword, newPassword } : { newPassword })
      setCurrentPassword(''); setNewPassword(''); setConfirmPassword('')
      setPasswordSuccess(initialProfile.hasPassword ? 'Contraseña actualizada.' : 'Contraseña creada — ya puedes iniciar sesión con ella además de con Google.')
      if (!initialProfile.hasPassword) onUpdated({ ...initialProfile, hasPassword: true })
    } catch (err: any) {
      setPasswordError(err.message)
    } finally {
      setPasswordLoading(false)
    }
  }

  const googleLinked = initialProfile.linkedProviders.includes('google')

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
        className="hud-panel hud-static relative w-full max-w-[560px]"
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

        {/* Body — todo en una sola vista, sin pestañas */}
        <div className="px-7 py-7 overflow-y-auto space-y-9" style={{ flex: 1 }}>

          {/* ── Perfil ── */}
          <form onSubmit={submitProfile} className="space-y-6">
            <SectionHeading isDark={isDark} kicker="// identidad" title="Perfil" />

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
            {avatarError && <ErrorBox isDark={isDark} message={avatarError} />}

            <Field
              label="Username"
              type="text"
              value={username}
              onChange={setUsername}
              isDark={isDark}
              hint="Pon tu nombre completo real aquí para que tu certificado de finalización se vea más profesional."
            />
            <Field label="Email" type="email" value={email} onChange={setEmail} isDark={isDark} />
            <TextareaField
              label="Bio"
              value={bio}
              onChange={setBio}
              placeholder="¿Qué te define como hacker?"
              isDark={isDark}
              hint={`${bio.length}/500 caracteres`}
            />

            {profileError && <ErrorBox isDark={isDark} message={profileError} />}
            {profileSuccess && <SuccessBox isDark={isDark} message={profileSuccess} />}

            <button
              type="submit"
              disabled={profileLoading || !profileChanged}
              className="btn-neon w-full py-3.5 rounded-xl text-[15px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {profileLoading ? (
                <span className="font-mono text-xs tracking-[0.15em] cursor-blink">Guardando</span>
              ) : (
                'Guardar cambios'
              )}
            </button>
          </form>

          <Divider isDark={isDark} />

          {/* ── Contraseña ── */}
          <form onSubmit={submitPassword} className="space-y-6">
            <SectionHeading isDark={isDark} kicker="// seguridad" title="Contraseña" />

            {!initialProfile.hasPassword && (
              <p className="text-[13px] font-light leading-relaxed" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
                Tu cuenta inicia sesión con Google. Puedes agregar una contraseña como método de respaldo — no hace falta la actual porque todavía no tienes una.
              </p>
            )}

            {initialProfile.hasPassword && (
              <Field label="Contraseña actual" type="password" value={currentPassword} onChange={setCurrentPassword} isDark={isDark} />
            )}
            <Field label="Nueva contraseña" type="password" value={newPassword} onChange={setNewPassword} placeholder="mín. 8 caracteres" isDark={isDark} />
            <Field label="Confirmar nueva contraseña" type="password" value={confirmPassword} onChange={setConfirmPassword} isDark={isDark} />

            {passwordError && <ErrorBox isDark={isDark} message={passwordError} />}
            {passwordSuccess && <SuccessBox isDark={isDark} message={passwordSuccess} />}

            <button
              type="submit"
              disabled={
                passwordLoading || !newPassword || !confirmPassword ||
                (initialProfile.hasPassword && !currentPassword)
              }
              className="btn-gold w-full py-3.5 rounded-xl text-[15px] font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {passwordLoading ? (
                <span className="font-mono text-xs tracking-[0.15em] cursor-blink">
                  {initialProfile.hasPassword ? 'Actualizando' : 'Creando'}
                </span>
              ) : (
                initialProfile.hasPassword ? 'Cambiar contraseña' : 'Establecer contraseña'
              )}
            </button>
          </form>

          <Divider isDark={isDark} />

          {/* ── Cuentas vinculadas ── */}
          <div className="space-y-4">
            <SectionHeading isDark={isDark} kicker="// acceso" title="Cuentas vinculadas" />

            <div
              className="flex items-center justify-between gap-4 p-4 rounded-xl"
              style={{
                background: isDark ? 'rgba(6,13,31,0.4)' : 'rgba(26,63,150,0.04)',
                border: `1px solid ${isDark ? 'rgba(26,63,150,0.20)' : 'rgba(26,63,150,0.15)'}`,
              }}
            >
              <div className="flex items-center gap-3">
                <GoogleGlyph />
                <div>
                  <p className="text-[14px] font-medium" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
                    Google
                  </p>
                  <p className="font-mono text-[11px]" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>
                    {googleLinked ? 'Conectada' : 'No conectada'}
                  </p>
                </div>
              </div>
              {googleLinked ? (
                <span
                  className="font-mono text-[10px] tracking-[0.14em] uppercase px-2.5 py-1 rounded shrink-0"
                  style={{ color: '#52ad70', background: 'rgba(82,173,112,0.10)', border: '1px solid rgba(82,173,112,0.30)' }}
                >
                  ✓ Vinculada
                </span>
              ) : (
                <div className="shrink-0">
                  <GoogleLinkButton<FullProfile> isDark={isDark} onLinked={onUpdated} />
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function GoogleGlyph() {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24">
      <path fill="#4285F4" d="M23.52 12.27c0-.85-.08-1.67-.22-2.45H12v4.64h6.47a5.53 5.53 0 0 1-2.4 3.63v3h3.88c2.27-2.09 3.57-5.17 3.57-8.82z"/>
      <path fill="#34A853" d="M12 24c3.24 0 5.96-1.07 7.95-2.91l-3.88-3c-1.08.72-2.45 1.15-4.07 1.15-3.13 0-5.78-2.11-6.73-4.96H1.27v3.1A12 12 0 0 0 12 24z"/>
      <path fill="#FBBC05" d="M5.27 14.28A7.2 7.2 0 0 1 4.89 12c0-.79.14-1.56.38-2.28v-3.1H1.27A12 12 0 0 0 0 12c0 1.94.46 3.77 1.27 5.38l4-3.1z"/>
      <path fill="#EA4335" d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.44-3.44C17.95 1.19 15.24 0 12 0A12 12 0 0 0 1.27 6.62l4 3.1C6.22 6.86 8.87 4.75 12 4.75z"/>
    </svg>
  )
}

function Divider({ isDark }: { isDark: boolean }) {
  return <div style={{ height: 1, background: isDark ? 'rgba(26,63,150,0.14)' : 'rgba(26,63,150,0.10)' }} />
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
