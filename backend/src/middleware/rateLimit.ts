import { rateLimiter } from 'hono-rate-limiter'
import { getConnInfo } from 'hono/bun'
import type { Context } from 'hono'

// Railway pone un edge/proxy delante del backend (confirmado: los headers
// x-railway-edge/x-railway-request-id llegan en toda respuesta) — la IP de
// la conexión TCP cruda (getConnInfo) sería siempre la del proxy de Railway,
// no la del cliente real. x-forwarded-for trae la IP real del cliente en esa
// topología. En local (sin proxy) no hay ese header, así que cae al socket.
function getClientIp(c: Context): string {
  const forwarded = c.req.header('x-forwarded-for')
  if (forwarded) return forwarded.split(',')[0].trim()
  return getConnInfo(c).remote.address ?? 'unknown'
}

// Límite general para toda la API — evita scraping/abuso básico sin afectar
// el uso normal de la plataforma.
export const apiRateLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 300,
  standardHeaders: 'draft-7',
  keyGenerator: getClientIp,
  message: { error: 'Demasiadas peticiones. Intenta de nuevo en unos minutos.' },
})

// Límite estricto para /api/auth/* — login, registro, verificación de correo,
// reset de contraseña y login con Google son los blancos típicos de fuerza
// bruta, spam de registro y bombardeo de correos de verificación/reset.
export const authRateLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: 'draft-7',
  keyGenerator: getClientIp,
  message: { error: 'Demasiados intentos. Intenta de nuevo en unos minutos.' },
})
