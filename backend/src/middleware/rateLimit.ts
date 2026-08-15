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

// Muchas personas en la misma red (ej. el wifi de un salón/congreso) comparten
// una sola IP pública tras el NAT del router — un límite por IP demasiado
// estricto las bloquearía entre sí, no a cada una individualmente. Si el
// request trae `email` en el body (login/registro/verificación/reenvío/olvidé-
// mi-contraseña), se usa como parte de la clave junto con la IP, así cada
// cuenta tiene su propio contador sin importar cuánta gente más comparta la
// misma IP. `undefined` si el body no es JSON o no trae `email` (logout,
// google login, reset-password con token) — en ese caso el limiter de cuenta
// se salta (ver `skip` en `authAccountLimiter`) y solo aplica el límite por IP.
async function getRequestEmail(c: Context): Promise<string | undefined> {
  try {
    const body = await c.req.json()
    if (body && typeof body.email === 'string' && body.email.trim()) {
      return body.email.trim().toLowerCase()
    }
  } catch {
    // body vacío o no-JSON (ej. no aplica a este método) — no hay email que extraer
  }
  return undefined
}

// Límite general para toda la API. Deliberadamente generoso: pensado para que
// una demo en vivo frente a un grupo grande (ej. una charla/congreso) donde
// decenas o cientos de personas comparten la misma IP pública no se vea
// bloqueada — sigue acotando un scraping/abuso automatizado real.
export const apiRateLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 2000,
  standardHeaders: 'draft-7',
  keyGenerator: getClientIp,
  message: { error: 'Demasiadas peticiones. Intenta de nuevo en unos minutos.' },
})

// Techo por IP para /api/auth/* — cubre las rutas sin `email` en el body
// (google login, logout, reset-password) y actúa como límite general de la
// zona de auth. También generoso por la misma razón que apiRateLimiter.
export const authIpLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 600,
  standardHeaders: 'draft-7',
  keyGenerator: getClientIp,
  message: { error: 'Demasiadas peticiones. Intenta de nuevo en unos minutos.' },
})

// Límite por cuenta (IP + email) para login/registro/verificación/reenvío/
// olvidé-mi-contraseña — el blanco real de fuerza bruta de contraseña o del
// código de verificación de 6 dígitos es SIEMPRE una cuenta específica, nunca
// "una IP" en general. Esto protege cada cuenta sin penalizar a otras 399
// personas que comparten la misma IP en un salón/congreso. Se salta por
// completo si el request no trae `email` (ver `getRequestEmail`) — esas rutas
// ya quedan cubiertas por `authIpLimiter`.
export const authAccountLimiter = rateLimiter({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: 'draft-7',
  keyGenerator: async (c) => `${getClientIp(c)}:${(await getRequestEmail(c)) ?? ''}`,
  skip: async (c) => (await getRequestEmail(c)) === undefined,
  message: { error: 'Demasiados intentos para esta cuenta. Intenta de nuevo en unos minutos.' },
})
