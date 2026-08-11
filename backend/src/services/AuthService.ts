import jwt from 'jsonwebtoken'
import { UserDAO } from '../daos/UserDAO.js'
import { UserOAuthDAO } from '../daos/UserOAuthDAO.js'
import { ConflictError, UnauthorizedError, ValidationError } from '../utils/errors.js'
import type { OAuthProviderName, TokenPayload, User } from '../types.js'

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

    if (!user.passwordHash)
      throw new UnauthorizedError('Esta cuenta inicia sesión con Google o Microsoft. Usa esa opción para ingresar.')

    const match = await Bun.password.verify(password, user.passwordHash)
    if (!match) throw new UnauthorizedError('Credenciales inválidas.')

    return { user, token: AuthService.generateToken(user) }
  }

  /**
   * Login/registro vía Google o Microsoft. Reglas de vinculación:
   * 1. Si esta identidad externa ya está vinculada a un usuario, se usa ese usuario.
   * 2. Si no, pero ya existe una cuenta con el mismo email (verificado por el proveedor),
   *    se vincula el proveedor a esa cuenta existente (mismo criterio de confianza que
   *    el código de verificación por correo: el proveedor ya confirmó que el email es tuyo).
   * 3. Si no existe ninguna cuenta, se crea una nueva sin contraseña.
   */
  static async findOrCreateOAuthUser(params: {
    provider: OAuthProviderName
    providerUserId: string
    email: string
    name: string | null
    privacyPolicyVersion: string
  }): Promise<{ user: User; token: string; isNewUser: boolean }> {
    const { provider, providerUserId, email, name, privacyPolicyVersion } = params

    const linkedUser = await UserOAuthDAO.findUserByProvider(provider, providerUserId)
    if (linkedUser) return { user: linkedUser, token: AuthService.generateToken(linkedUser), isNewUser: false }

    const existingUser = await UserDAO.findByEmail(email)
    if (existingUser) {
      await UserOAuthDAO.link(existingUser.id, provider, providerUserId)
      return { user: existingUser, token: AuthService.generateToken(existingUser), isNewUser: false }
    }

    const username = await AuthService.generateUniqueUsername(name ?? email.split('@')[0] ?? 'usuario')
    const newUser = await UserDAO.create({
      username,
      email,
      passwordHash: null,
      privacyAcceptedAt: new Date(),
      privacyPolicyVersion,
    })
    await UserOAuthDAO.link(newUser.id, provider, providerUserId)
    return { user: newUser, token: AuthService.generateToken(newUser), isNewUser: true }
  }

  static async generateUniqueUsername(base: string): Promise<string> {
    const cleaned = base
      .toLowerCase()
      .normalize('NFD').replace(/[̀-ͯ]/g, '') // quita tildes
      .replace(/[^a-z0-9_.-]/g, '')
      .slice(0, 40) || 'usuario'

    let candidate = cleaned
    let suffix = 0
    while (await UserDAO.findByUsername(candidate)) {
      suffix += 1
      candidate = `${cleaned}${suffix}`.slice(0, 50)
    }
    return candidate
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
