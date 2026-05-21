import { createHmac } from 'crypto'

/**
 * Genera un código de respuesta único y determinista por par usuario+actividad.
 * El mismo usuario siempre obtiene el mismo código para la misma actividad.
 * Usuarios distintos obtienen códigos distintos.
 */
export function generateActivityResponse(userId: string, activityId: string): string {
  const secret = process.env.JWT_SECRET ?? 'fallback-secret'
  return createHmac('sha256', secret)
    .update(`activity:${userId}:${activityId}`)
    .digest('hex')
    .slice(0, 16)
    .toUpperCase()
}
