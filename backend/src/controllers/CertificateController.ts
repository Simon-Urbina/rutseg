import type { Context } from 'hono'
import { CertificateService } from '../services/CertificateService.js'
import { BadRequestError } from '../utils/errors.js'

export class CertificateController {
  static async verify(c: Context) {
    const { username, courseSlug, code } = c.req.query()
    if (!username || !courseSlug || !code)
      throw new BadRequestError('Faltan parámetros: username, courseSlug y code son requeridos.')
    return c.json(await CertificateService.verify(username, courseSlug, code))
  }
}
