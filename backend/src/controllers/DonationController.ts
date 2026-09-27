import type { Context } from 'hono'
import { DonationService } from '../services/DonationService.js'
import { BadRequestError } from '../utils/errors.js'

export class DonationController {
  static async checkout(c: Context) {
    const body = await c.req.json().catch(() => null)
    if (!body) throw new BadRequestError('Cuerpo de la petición inválido.')
    return c.json(DonationService.createCheckout(body.amount))
  }

  static async status(c: Context) {
    return c.json(await DonationService.getStatus(c.req.param('id') ?? ''))
  }
}
