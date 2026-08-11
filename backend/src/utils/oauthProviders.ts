import { createRemoteJWKSet, jwtVerify } from 'jose'
import { UnauthorizedError } from './errors.js'

export interface VerifiedIdentity {
  providerUserId: string
  email: string
  name: string | null
}

// Los JWKS se cachean en memoria por `jose` — no se piden en cada request.
const googleJWKS = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'))

/** Verifica la firma, emisor y audiencia de un id_token de Google Identity Services. */
export async function verifyGoogleIdToken(idToken: string): Promise<VerifiedIdentity> {
  const clientId = process.env.GOOGLE_CLIENT_ID
  if (!clientId) throw new Error('GOOGLE_CLIENT_ID es requerido')

  let payload
  try {
    ;({ payload } = await jwtVerify(idToken, googleJWKS, {
      issuer: ['https://accounts.google.com', 'accounts.google.com'],
      audience: clientId,
    }))
  } catch {
    throw new UnauthorizedError('Token de Google inválido.')
  }

  const email = payload.email as string | undefined
  if (!email || payload.email_verified !== true)
    throw new UnauthorizedError('Tu cuenta de Google no tiene un correo verificado.')

  return {
    providerUserId: String(payload.sub),
    email: email.toLowerCase(),
    name: (payload.name as string | undefined) ?? null,
  }
}

// Microsoft se quitó temporalmente (registro de la app en Azure sin terminar).
// Para reintroducirlo: volver a agregar verifyMicrosoftIdToken aquí (JWKS en
// https://login.microsoftonline.com/common/discovery/v2.0/keys), el método
// AuthController.microsoft y la ruta POST /api/auth/microsoft — AuthService y
// la tabla user_oauth_accounts ya soportan el provider 'microsoft' sin cambios.
