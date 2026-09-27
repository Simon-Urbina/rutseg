import { createHash, randomUUID } from 'crypto'
import { AppError, BadRequestError, NotFoundError } from '../utils/errors.js'

// Donaciones con Wompi Web Checkout (https://docs.wompi.co/docs/colombia/widget-checkout-web/).
// El monto viaja firmado con el secreto de integridad (SHA256 de
// referencia + monto + moneda + secreto), así que el pagador no puede alterarlo
// en el checkout. Ese secreto nunca debe salir del backend.
//
// No se guarda nada en la base de datos: el registro oficial de cada donación
// vive en el panel de comercio de Wompi.

const CURRENCY = 'COP'
const MIN_AMOUNT_COP = 2_000
const MAX_AMOUNT_COP = 5_000_000
const REFERENCE_PREFIX = 'DON-'

function getConfig() {
  const publicKey = process.env.WOMPI_PUBLIC_KEY
  const integritySecret = process.env.WOMPI_INTEGRITY_SECRET
  if (!publicKey || !integritySecret)
    throw new AppError('Las donaciones con Wompi no están disponibles por ahora. Puedes usar la llave Bre-B.')

  // Las llaves de sandbox empiezan por pub_test_; las de producción por pub_prod_.
  const apiBase = publicKey.startsWith('pub_test_')
    ? 'https://sandbox.wompi.co/v1'
    : 'https://production.wompi.co/v1'

  const frontendUrl = (process.env.FRONTEND_URL ?? 'http://localhost:5173').split(',')[0].trim()
  return { publicKey, integritySecret, apiBase, frontendUrl }
}

export class DonationService {
  static createCheckout(amountCop: unknown) {
    if (typeof amountCop !== 'number' || !Number.isInteger(amountCop))
      throw new BadRequestError('El monto debe ser un número entero de pesos.')
    if (amountCop < MIN_AMOUNT_COP || amountCop > MAX_AMOUNT_COP)
      throw new BadRequestError(
        `El monto debe estar entre $${MIN_AMOUNT_COP.toLocaleString('es-CO')} y $${MAX_AMOUNT_COP.toLocaleString('es-CO')} COP.`,
      )

    const { publicKey, integritySecret, frontendUrl } = getConfig()
    const amountInCents = amountCop * 100
    const reference = `${REFERENCE_PREFIX}${randomUUID()}`
    const signature = createHash('sha256')
      .update(`${reference}${amountInCents}${CURRENCY}${integritySecret}`)
      .digest('hex')

    const params = new URLSearchParams({
      'public-key': publicKey,
      currency: CURRENCY,
      'amount-in-cents': String(amountInCents),
      reference,
      'signature:integrity': signature,
      'redirect-url': `${frontendUrl}/donar/gracias`,
    })

    return { checkoutUrl: `https://checkout.wompi.co/p/?${params}` }
  }

  // Wompi agrega ?id=<transactionId> al redirect-url. El endpoint de consulta de
  // transacciones de Wompi es público; se hace desde el backend solo para que el
  // frontend no tenga que saber si estamos en sandbox o producción.
  static async getStatus(transactionId: string) {
    if (!/^[\w-]{1,64}$/.test(transactionId))
      throw new BadRequestError('Identificador de transacción inválido.')

    const { apiBase } = getConfig()
    const res = await fetch(`${apiBase}/transactions/${encodeURIComponent(transactionId)}`)
    if (res.status === 404) throw new NotFoundError('Transacción no encontrada.')
    if (!res.ok) throw new AppError('No se pudo consultar la transacción en Wompi.')

    const { data } = (await res.json()) as {
      data: { status: string; amount_in_cents: number; reference: string }
    }
    // Solo se exponen transacciones creadas por esta página de donaciones.
    if (!data.reference?.startsWith(REFERENCE_PREFIX))
      throw new NotFoundError('Transacción no encontrada.')

    return { status: data.status, amountCop: data.amount_in_cents / 100 }
  }
}
