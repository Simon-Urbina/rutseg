import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { useTheme } from '../../context/ThemeContext'
import { useAuth } from '../../context/AuthContext'
import { adminApi, type AdminUser } from '../../lib/adminApi'
import { AdminInput, AdminTextarea, AdminSelect, ErrorBanner } from './AdminFormControls'
import { IconTrash } from './AdminIcons'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import { RoleBadge } from './AdminUsersPage'
import ConfirmDeleteModal from './ConfirmDeleteModal'

const ROLES = [
  { value: 'user', label: 'Usuario' },
  { value: 'admin', label: 'Administrador' },
]

export default function AdminUserDetailPage() {
  const { id } = useParams<{ id: string }>()
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const navigate = useNavigate()
  const { user: currentUser } = useAuth()

  const [targetUser, setTargetUser] = useState<AdminUser | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [deleteOpen, setDeleteOpen] = useState(false)

  useEffect(() => {
    if (!id) return
    setLoading(true)
    adminApi.getUser(id)
      .then(setTargetUser)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [id])

  if (loading) return <PageShell isDark={isDark}><p style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>Cargando…</p></PageShell>
  if (error || !targetUser) return <PageShell isDark={isDark}><ErrorBanner message={error || 'Usuario no encontrado.'} isDark={isDark} /></PageShell>

  const isSelf = targetUser.id === currentUser?.id

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[
        { label: 'Panel', to: '/admin' },
        { label: 'Usuarios', to: '/admin/users' },
        { label: targetUser.username },
      ]} />

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-6 items-start">
        <EditUserForm
          isDark={isDark}
          user={targetUser}
          isSelf={isSelf}
          onUpdated={setTargetUser}
          onDeleteClick={() => setDeleteOpen(true)}
        />
        <PasswordForm isDark={isDark} userId={targetUser.id} />
      </div>

      <ConfirmDeleteModal
        open={deleteOpen}
        title={`el usuario "${targetUser.username}"`}
        warningDetail="Esto elimina la cuenta (soft-delete). El usuario ya no podrá iniciar sesión ni aparecer en el ranking."
        requireTypedSlug={targetUser.username}
        onCancel={() => setDeleteOpen(false)}
        onConfirm={async () => { await adminApi.deleteUser(targetUser.id); navigate('/admin/users') }}
      />
    </PageShell>
  )
}

function EditUserForm({
  isDark, user, isSelf, onUpdated, onDeleteClick,
}: { isDark: boolean; user: AdminUser; isSelf: boolean; onUpdated: (u: AdminUser) => void; onDeleteClick: () => void }) {
  const [username, setUsername] = useState(user.username)
  const [email, setEmail] = useState(user.email)
  const [bio, setBio] = useState(user.bio ?? '')
  const [role, setRole] = useState(user.role)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault()
    setSaving(true)
    setError('')
    try {
      const updated = await adminApi.updateUser(user.id, { username, email, bio, role })
      onUpdated(updated)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={handleSave} className="hud-panel hud-static p-7 space-y-5 h-fit" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
      '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
    } as React.CSSProperties}>
      <div className="flex items-center justify-between">
        <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
          Editar usuario
        </h2>
        <RoleBadge role={user.role} />
      </div>

      <AdminInput label="Username" value={username} onChange={setUsername} isDark={isDark} />
      <AdminInput label="Email" type="email" value={email} onChange={setEmail} isDark={isDark} />
      <AdminTextarea label="Bio" value={bio} onChange={setBio} isDark={isDark} rows={3} />
      <AdminSelect
        label="Rol"
        value={role}
        onChange={v => setRole(v as AdminUser['role'])}
        isDark={isDark}
        options={ROLES}
      />
      {isSelf && (
        <p className="text-[12px]" style={{ color: '#4A70CC' }}>
          No puedes quitarte el rol de administrador a ti mismo desde aquí.
        </p>
      )}

      <p className="font-mono text-[12px]" style={{ color: '#4A70CC' }}>
        {user.points} pts (automático) · registrado el {new Date(user.createdAt).toLocaleDateString('es-CO')}
      </p>

      {error && <ErrorBanner message={error} isDark={isDark} />}

      <div className="flex items-center gap-3 flex-wrap">
        <button type="submit" disabled={saving} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
          {saving ? 'Guardando…' : 'Guardar cambios'}
        </button>
        {!isSelf && (
          <button
            type="button"
            onClick={onDeleteClick}
            className="ml-auto flex items-center gap-2 px-4 py-2.5 rounded-xl text-[13px] font-medium"
            style={{ color: '#c65b5b', background: 'rgba(198,91,91,0.08)', border: '1px solid rgba(198,91,91,0.25)' }}
          >
            <IconTrash size={13} />
            Borrar usuario
          </button>
        )}
      </div>
    </form>
  )
}

function PasswordForm({ isDark, userId }: { isDark: boolean; userId: string }) {
  const [newPassword, setNewPassword] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess(false)
    if (newPassword.length < 8) {
      setError('La contraseña debe tener al menos 8 caracteres.')
      return
    }
    setSaving(true)
    try {
      await adminApi.setUserPassword(userId, newPassword)
      setNewPassword('')
      setSuccess(true)
    } catch (err: any) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="hud-panel hud-static p-7 space-y-5 h-fit" style={{
      background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
      '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
    } as React.CSSProperties}>
      <h2 className="font-display" style={{ fontSize: '1.3rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        Cambiar contraseña
      </h2>
      <p className="text-[13px]" style={{ color: '#4A70CC' }}>
        Establece una nueva contraseña sin necesidad de conocer la actual.
      </p>
      <AdminInput label="Nueva contraseña" type="password" value={newPassword} onChange={setNewPassword} isDark={isDark} placeholder="Mínimo 8 caracteres" />
      {error && <ErrorBanner message={error} isDark={isDark} />}
      {success && (
        <p className="text-[13px]" style={{ color: '#52ad70' }}>
          Contraseña actualizada correctamente.
        </p>
      )}
      <button type="submit" disabled={saving} className="btn-neon px-6 py-2.5 rounded-xl text-[14px] disabled:opacity-50">
        {saving ? 'Actualizando…' : 'Actualizar contraseña'}
      </button>
    </form>
  )
}
