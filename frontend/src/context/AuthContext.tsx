import { createContext, useContext, useEffect, useState } from 'react'
import { api } from '../lib/api'

interface AuthUser {
  id: string
  username: string
  email: string
  role: 'user' | 'admin'
}

interface AuthContextType {
  user: AuthUser | null
  token: string | null
  avatarImage: string | null
  login: (token: string, user: AuthUser) => void
  logout: () => void
  updateUser: (patch: Partial<AuthUser>) => void
  setAvatarImage: (image: string | null) => void
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  token: null,
  avatarImage: null,
  login: () => {},
  logout: () => {},
  updateUser: () => {},
  setAvatarImage: () => {},
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('token'))
  const [user, setUser] = useState<AuthUser | null>(() => {
    const stored = localStorage.getItem('user')
    return stored ? JSON.parse(stored) : null
  })
  // No se persiste en localStorage a propósito: es una imagen base64 y podría
  // acercarse rápido a la cuota de almacenamiento del origen. Se resuelve una
  // vez por sesión (o al hacer login) contra /api/users/me.
  const [avatarImage, setAvatarImage] = useState<string | null>(null)

  useEffect(() => {
    if (!token) {
      setAvatarImage(null)
      return
    }
    let cancelled = false
    api.get<{ profileImage: string | null }>('/api/users/me')
      .then(({ profileImage }) => {
        if (!cancelled) setAvatarImage(profileImage ? `data:image/jpeg;base64,${profileImage}` : null)
      })
      .catch(() => {})
    return () => { cancelled = true }
  }, [token])

  const login = (newToken: string, newUser: AuthUser) => {
    localStorage.setItem('token', newToken)
    localStorage.setItem('user', JSON.stringify(newUser))
    setToken(newToken)
    setUser(newUser)
  }

  const logout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    setToken(null)
    setUser(null)
    setAvatarImage(null)
  }

  const updateUser = (patch: Partial<AuthUser>) => {
    setUser(prev => {
      if (!prev) return prev
      const next = { ...prev, ...patch }
      localStorage.setItem('user', JSON.stringify(next))
      return next
    })
  }

  return (
    <AuthContext.Provider value={{ user, token, avatarImage, login, logout, updateUser, setAvatarImage }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
