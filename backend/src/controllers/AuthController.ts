import type { Context } from 'hono'
import { AuthService } from '../services/AuthService.js'
import { UserDAO } from '../daos/UserDAO.js'
import { sendPasswordResetEmail, sendVerificationEmail } from '../utils/email.js'
import { verifyGoogleIdToken } from '../utils/oauthProviders.js'
import { BadRequestError } from '../utils/errors.js'

// Tokens de restablecimiento en memoria (clave → {userId, expiresAt}). Se reinician al reiniciar el servidor.
const resetTokens = new Map<string, { userId: string; expiresAt: number }>()

// Registros pendientes en espera de verificación de correo (clave = email). Se reinician al reiniciar el servidor.
const pendingRegistrations = new Map<string, {
  username: string
  email: string
  passwordHash: string
  privacyPolicyVersion: string
  code: string
  expiresAt: number
}>()

function generateCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString()
}

export class AuthController {
  static async register(c: Context) {
    const { username, email, password, privacyPolicyVersion } = await c.req.json()
    const prepared = await AuthService.prepareRegistration(username, email, password)
    const code = generateCode()
    pendingRegistrations.set(prepared.email, {
      ...prepared,
      privacyPolicyVersion: privacyPolicyVersion ?? '1.0',
      code,
      expiresAt: Date.now() + 900_000, // 15 minutos
    })
    try {
      await sendVerificationEmail(prepared.email, prepared.username, code)
    } catch (err) {
      console.error('[register] Error enviando email de verificación:', err)
    }
    return c.json({ message: 'Código de verificación enviado. Revisa tu correo.', email: prepared.email }, 200)
  }

  static async verifyEmail(c: Context) {
    const { email, code } = await c.req.json()
    if (!email || !code) return c.json({ error: 'Email y código son requeridos.' }, 400)
    const pending = pendingRegistrations.get(email.toLowerCase())
    if (!pending || pending.expiresAt < Date.now()) {
      pendingRegistrations.delete(email.toLowerCase())
      return c.json({ error: 'El código es inválido o ha expirado.' }, 400)
    }
    if (pending.code !== code.trim())
      return c.json({ error: 'Código incorrecto.' }, 400)
    pendingRegistrations.delete(email.toLowerCase())
    const { user, token } = await AuthService.createUser(pending.username, pending.email, pending.passwordHash, pending.privacyPolicyVersion)
    return c.json(
      { token, user: { id: user.id, username: user.username, email: user.email, role: user.role } },
      201,
    )
  }

  static async resendVerification(c: Context) {
    const { email } = await c.req.json()
    if (!email) return c.json({ error: 'Email requerido.' }, 400)
    const pending = pendingRegistrations.get(email.toLowerCase())
    if (pending) {
      const code = generateCode()
      pendingRegistrations.set(email.toLowerCase(), { ...pending, code, expiresAt: Date.now() + 900_000 })
      try {
        await sendVerificationEmail(pending.email, pending.username, code)
      } catch (err) {
        console.error('[resend-verification] Error enviando email:', err)
      }
    }
    // Siempre retornar el mismo mensaje para evitar enumeración
    return c.json({ message: 'Si hay un registro pendiente, se enviará un nuevo código.' })
  }

  static async login(c: Context) {
    const { email, password } = await c.req.json()
    const { user, token } = await AuthService.login(email, password)
    return c.json({ token, user: { id: user.id, username: user.username, email: user.email, role: user.role } })
  }

  static logout(c: Context) {
    return c.json({ message: 'Sesión cerrada.' })
  }

  static async google(c: Context) {
    const { idToken, privacyPolicyVersion } = await c.req.json()
    if (!idToken) throw new BadRequestError('idToken es requerido.')
    const identity = await verifyGoogleIdToken(idToken)
    const { user, token } = await AuthService.findOrCreateOAuthUser({
      provider: 'google',
      providerUserId: identity.providerUserId,
      email: identity.email,
      name: identity.name,
      privacyPolicyVersion: privacyPolicyVersion ?? '1.0',
    })
    return c.json({ token, user: { id: user.id, username: user.username, email: user.email, role: user.role } })
  }

  static async forgotPassword(c: Context) {
    const { email } = await c.req.json()
    const user = await UserDAO.findByEmail(email)
    if (user) {
      const token = crypto.randomUUID()
      resetTokens.set(token, { userId: user.id, expiresAt: Date.now() + 3_600_000 })
      const frontendUrl = process.env.FRONTEND_URL ?? 'http://localhost:5173'
      const resetLink = `${frontendUrl}/reset-password?token=${token}`
      try {
        await sendPasswordResetEmail(user.email, resetLink)
      } catch (err) {
        console.error('[forgot-password] Error enviando email:', err)
      }
    }
    // Siempre retornar el mismo mensaje para evitar enumeración de correos
    return c.json({ message: 'Si el correo está registrado, recibirás las instrucciones.' })
  }

  static async resetPassword(c: Context) {
    const { token, newPassword } = await c.req.json()
    if (!token) return c.json({ error: 'Token requerido.' }, 400)
    const entry = resetTokens.get(token)
    if (!entry || entry.expiresAt < Date.now()) {
      resetTokens.delete(token)
      return c.json({ error: 'El enlace es inválido o ha expirado.' }, 400)
    }
    if (!newPassword || newPassword.length < 8)
      return c.json({ error: 'La contraseña debe tener al menos 8 caracteres.' }, 400)
    const hash = await Bun.password.hash(newPassword)
    await UserDAO.updatePassword(entry.userId, hash)
    resetTokens.delete(token)
    return c.json({ message: 'Contraseña actualizada correctamente.' })
  }
}
