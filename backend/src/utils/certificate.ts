import { createHmac } from 'crypto'

/** Código de verificación determinista por par usuario+curso. Mismo patrón que
 * generateActivityResponse() en response.ts — no requiere guardar nada en base de datos,
 * el código se puede recalcular siempre que se necesite verificar. */
export function generateCertificateCode(userId: string, courseId: string): string {
  const secret = process.env.JWT_SECRET ?? 'fallback-secret'
  return createHmac('sha256', secret)
    .update(`certificate:${userId}:${courseId}`)
    .digest('hex')
    .slice(0, 12)
    .toUpperCase()
}
