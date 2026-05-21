import jwt from 'jsonwebtoken'
import { UserDAO } from '../daos/UserDAO.js'
import { ConflictError, UnauthorizedError, ValidationError } from '../utils/errors.js'
import type { TokenPayload, User } from '../types.js'

const TOKEN_TTL = '7d'

function getSecret(): string {
  const s = process.env.JWT_SECRET
  if (!s) throw new Error('JWT_SECRET is required')
  return s
}

export class AuthService {
  static async prepareRegistration(
    username: string,
    email: string,
    password: string,
  ): Promise<{ username: string; email: string; passwordHash: string }> {
    const errors: string[] = []
    if (!username || username.trim().length < 3 || username.trim().length > 50)
      errors.push('El username debe tener entre 3 y 50 caracteres.')
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
      errors.push('El email no tiene un formato válido.')
    if (!password || password.length < 8)
      errors.push('La contraseña debe tener al menos 8 caracteres.')
    if (errors.length) throw new ValidationError(errors)

    if (await UserDAO.findByEmail(email.toLowerCase()))
      throw new ConflictError('El email ya está registrado.')
    if (await UserDAO.findByUsername(username.trim()))
      throw new ConflictError('El username ya está en uso.')

    const passwordHash = await Bun.password.hash(password)
    return { username: username.trim(), email: email.toLowerCase(), passwordHash }
  }

  static async createUser(
    username: string,
    email: string,
    passwordHash: string,
    privacyPolicyVersion: string,
  ): Promise<{ user: User; token: string }> {
    const user = await UserDAO.create({
      username,
      email,
      passwordHash,
      privacyAcceptedAt: new Date(),
      privacyPolicyVersion,
    })
    return { user, token: AuthService.generateToken(user) }
  }

  static async login(email: string, password: string): Promise<{ user: User; token: string }> {
    const user = await UserDAO.findByEmail(email.toLowerCase())
    if (!user) throw new UnauthorizedError('Credenciales inválidas.')

    const match = await Bun.password.verify(password, user.passwordHash)
    if (!match) throw new UnauthorizedError('Credenciales inválidas.')

    return { user, token: AuthService.generateToken(user) }
  }

  static generateToken(user: User): string {
    const payload: TokenPayload = {
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
    }
    return jwt.sign(payload, getSecret(), { expiresIn: TOKEN_TTL })
  }
}
