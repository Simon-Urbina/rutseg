import type { MiddlewareHandler } from 'hono'
import { verify } from 'jsonwebtoken'
import type { TokenPayload } from '../types.js'
import { UnauthorizedError, ForbiddenError } from '../utils/errors.js'

function getSecret(): string {
  const s = process.env.JWT_SECRET
  if (!s) throw new Error('JWT_SECRET is required')
  return s
}

function extractToken(c: Parameters<MiddlewareHandler>[0]): string {
  const auth = c.req.header('Authorization')
  if (!auth?.startsWith('Bearer ')) throw new UnauthorizedError('No autorizado.')
  return auth.slice(7)
}

export const optionalAuth: MiddlewareHandler = async (c, next) => {
  const auth = c.req.header('Authorization')
  if (auth?.startsWith('Bearer ')) {
    try {
      const payload = verify(auth.slice(7), getSecret()) as TokenPayload
      c.set('user', payload)
    } catch {
      // ignorar tokens inválidos — el endpoint es accesible sin autenticación
    }
  }
  await next()
}

export const requireAuth: MiddlewareHandler = async (c, next) => {
  try {
    const payload = verify(extractToken(c), getSecret()) as TokenPayload
    c.set('user', payload)
  } catch (e) {
    if (e instanceof UnauthorizedError) throw e
    throw new UnauthorizedError('Token inválido o expirado.')
  }
  await next()
}

export const requireAdmin: MiddlewareHandler = async (c, next) => {
  try {
    const payload = verify(extractToken(c), getSecret()) as TokenPayload
    if (payload.role !== 'admin') throw new ForbiddenError('Acceso denegado.')
    c.set('user', payload)
  } catch (e) {
    if (e instanceof UnauthorizedError || e instanceof ForbiddenError) throw e
    throw new UnauthorizedError('Token inválido o expirado.')
  }
  await next()
}
