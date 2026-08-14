import type { Context } from 'hono'
import { CourseService } from '../services/CourseService.js'
import { CertificateService } from '../services/CertificateService.js'
import type { TokenPayload } from '../types.js'

export class CourseController {
  static async listCourses(c: Context) {
    const user = c.get('user') as TokenPayload | undefined
    return c.json(await CourseService.listCourses({ userId: user?.id, role: user?.role }))
  }

  static async getCourse(c: Context) {
    const user = c.get('user') as TokenPayload | undefined
    return c.json(await CourseService.getCourse(c.req.param('slug')!, user?.id, user?.role))
  }

  static async getCourseNav(c: Context) {
    return c.json(await CourseService.getCourseNav(c.req.param('slug')!))
  }

  static async enroll(c: Context) {
    const user = c.get('user') as TokenPayload
    const enrollment = await CourseService.enrollUser(user.id, c.req.param('slug')!)
    return c.json(enrollment, 201)
  }

  static async getModules(c: Context) {
    const user = c.get('user') as TokenPayload | undefined
    return c.json(await CourseService.getModules(c.req.param('slug')!, user?.role))
  }

  static async getLaboratories(c: Context) {
    const user = c.get('user') as TokenPayload | undefined
    const { slug, moduleSlug } = c.req.param()
    return c.json(await CourseService.getLaboratories(slug, moduleSlug, user?.id, user?.role))
  }

  static async getLaboratory(c: Context) {
    const user = c.get('user') as TokenPayload
    const { slug, moduleSlug, labSlug } = c.req.param()
    return c.json(
      await CourseService.getLaboratory(slug, moduleSlug, labSlug, user.id, user.role),
    )
  }

  static async getCertificate(c: Context) {
    const user = c.get('user') as TokenPayload
    const { course } = await CertificateService.getCompletionStatus(user.id, c.req.param('slug')!)
    const pdfBuffer = await CertificateService.generatePdf(user, course)
    c.header('Content-Type', 'application/pdf')
    c.header('Content-Disposition', `attachment; filename="rutseg-${course.slug}.pdf"`)
    // c.body() espera Uint8Array<ArrayBuffer>; Buffer es Uint8Array<ArrayBufferLike>, no asignable directamente.
    return c.body(new Uint8Array(pdfBuffer))
  }
}
