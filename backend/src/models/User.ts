import type { UserRole } from '../types.js'

export class User {
  constructor(
    public readonly id: string,
    public username: string,
    public email: string,
    public readonly passwordHash: string,
    public readonly createdAt: Date,
    public updatedAt: Date,
    public role: UserRole = 'user',
    public bio: string | null = null,
    public profileImage: Buffer | null = null,
    public points: number = 0,
    public deletedAt: Date | null = null,
    public privacyAcceptedAt: Date | null = null,
    public privacyPolicyVersion: string | null = null,
  ) {}

  static validate({ username, email, password }: {
    username: string
    email: string
    password: string
  }): string[] {
    const errors: string[] = []
    if (!username || username.trim().length < 3 || username.trim().length > 50)
      errors.push('El username debe tener entre 3 y 50 caracteres.')
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
      errors.push('El email no tiene un formato válido.')
    if (!password || password.length < 8)
      errors.push('La contraseña debe tener al menos 8 caracteres.')
    return errors
  }

  static validateProfileImage({ mimetype, size }: { mimetype: string; size: number }): string[] {
    const errors: string[] = []
    const ALLOWED = ['image/jpeg', 'image/jpg']
    const MAX_BYTES = 5 * 1024 * 1024
    if (!ALLOWED.includes(mimetype)) errors.push('La foto de perfil solo acepta formato JPG/JPEG.')
    if (size > MAX_BYTES) errors.push('La foto de perfil no puede superar los 5 MB.')
    return errors
  }

  isDeleted(): boolean {
    return this.deletedAt !== null
  }

  isAdmin(): boolean {
    return this.role === 'admin'
  }

  /** Datos seguros para incluir en un JWT o sesión (sin hash ni imagen binaria). */
  toSession() {
    return {
      id: this.id,
      username: this.username,
      email: this.email,
      role: this.role,
    }
  }

  /** Perfil público visible por cualquier visitante. */
  toPublic() {
    return {
      id: this.id,
      username: this.username,
      bio: this.bio,
      points: this.points,
    }
  }

  /** Perfil completo visible solo por el propio usuario. */
  toProfile() {
    return {
      id: this.id,
      username: this.username,
      email: this.email,
      bio: this.bio,
      points: this.points,
      role: this.role,
      createdAt: this.createdAt,
    }
  }

  /** Fila del ranking global. */
  toRankingRow() {
    return {
      id: this.id,
      username: this.username,
      bio: this.bio,
      points: this.points,
    }
  }

  /** Vista completa para el panel admin: todos los campos salvo el hash y la imagen. */
  toAdmin() {
    return {
      id: this.id,
      username: this.username,
      email: this.email,
      bio: this.bio,
      role: this.role,
      points: this.points,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    }
  }
}
