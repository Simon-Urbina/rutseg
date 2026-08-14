import PDFDocument from 'pdfkit'
import SVGtoPDF from 'svg-to-pdfkit'
import { readFileSync } from 'fs'
import { CourseDAO } from '../daos/CourseDAO.js'
import { UserDAO } from '../daos/UserDAO.js'
import { NotFoundError, ForbiddenError } from '../utils/errors.js'
import { generateCertificateCode } from '../utils/certificate.js'
import type { CourseWithStats } from '../daos/CourseDAO.js'
import type { TokenPayload } from '../types.js'

// Copia local del logo — el backend y el frontend se despliegan como paquetes
// independientes (Railway / Vercel), así que no puede leer frontend/public/logo.svg
// en producción. Si el logo cambia, actualizar también src/assets/logo.svg.
const LOGO_SVG = readFileSync(`${import.meta.dir}/../assets/logo.svg`, 'utf-8')

const COLORS = {
  darkBlue: '#1A3F96',
  cyan: '#2596be',
  gold: '#F5C500',
  ink: '#0A1545',
  muted: '#4A70CC',
  faint: '#7A8CB0',
} as const

export class CertificateService {
  /** Verifica matrícula y completitud del curso. Lanza ForbiddenError si el usuario
   * no puede descargar el certificado todavía (no matriculado o curso incompleto). */
  static async getCompletionStatus(
    userId: string,
    courseSlug: string,
  ): Promise<{ course: CourseWithStats; isCompleted: boolean; completedLabsCount: number; labCount: number }> {
    const course = await CourseDAO.findBySlugWithStats(courseSlug, userId)
    if (!course) throw new NotFoundError('Curso no encontrado.')
    if (!course.isEnrolled) throw new ForbiddenError('Debes estar matriculado en este curso.')

    const isCompleted = course.labCount > 0 && course.completedLabsCount === course.labCount
    if (!isCompleted)
      throw new ForbiddenError('Debes completar todos los laboratorios del curso para obtener el certificado.')

    return { course, isCompleted, completedLabsCount: course.completedLabsCount, labCount: course.labCount }
  }

  /** Verificación pública de un certificado. Nunca lanza — un código o curso inválido
   * simplemente resulta en { valid: false }, sin filtrar si el username o el curso existen. */
  static async verify(
    username: string,
    courseSlug: string,
    code: string,
  ): Promise<{ valid: boolean; courseTitle?: string; username?: string }> {
    const user = await UserDAO.findByUsername(username)
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!user || !course) return { valid: false }

    const expectedCode = generateCertificateCode(user.id, course.id)
    if (code.toUpperCase() !== expectedCode) return { valid: false }

    const stats = await CourseDAO.findBySlugWithStats(courseSlug, user.id)
    const isCompleted =
      !!stats && stats.isEnrolled && stats.labCount > 0 && stats.completedLabsCount === stats.labCount
    if (!isCompleted) return { valid: false }

    return { valid: true, courseTitle: course.title, username: user.username }
  }

  /** Genera el PDF del certificado. No valida completitud — el llamador debe haber
   * pasado por getCompletionStatus() antes. */
  static async generatePdf(user: TokenPayload, course: CourseWithStats): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ layout: 'landscape', size: 'LETTER', margin: 0 })
      const chunks: Buffer[] = []
      doc.on('data', (chunk: Buffer) => chunks.push(chunk))
      doc.on('end', () => resolve(Buffer.concat(chunks)))
      doc.on('error', reject)

      const pageWidth = doc.page.width
      const pageHeight = doc.page.height
      const code = generateCertificateCode(user.id, course.id)

      // Barras de degradado (marca) arriba y abajo
      const gradient = doc.linearGradient(0, 0, pageWidth, 0)
      gradient.stop(0, COLORS.gold).stop(0.5, COLORS.cyan).stop(1, COLORS.darkBlue)
      doc.rect(0, 0, pageWidth, 10).fill(gradient)
      doc.rect(0, pageHeight - 10, pageWidth, 10).fill(gradient)

      // Marco decorativo
      doc.rect(24, 24, pageWidth - 48, pageHeight - 48).lineWidth(1.5).stroke(COLORS.darkBlue)

      // Logo + nombre de marca
      const logoSize = 44
      const logoY = 54
      SVGtoPDF(doc, LOGO_SVG, pageWidth / 2 - logoSize / 2, logoY, { width: logoSize, height: logoSize })
      doc.font('Helvetica-Bold').fontSize(18).fillColor(COLORS.ink)
        .text('RutSeg', 0, logoY + logoSize + 8, { align: 'center' })

      // Título
      doc.font('Helvetica-Bold').fontSize(32).fillColor(COLORS.darkBlue)
        .text('Certificado de Finalización', 0, 168, { align: 'center' })

      // Cuerpo
      const bodyY = 226
      doc.font('Helvetica').fontSize(14).fillColor(COLORS.ink)
        .text('Se certifica que', 0, bodyY, { align: 'center' })

      doc.font('Helvetica-Bold').fontSize(22).fillColor(COLORS.darkBlue)
        .text(user.username, 0, bodyY + 24, { align: 'center' })

      doc.font('Helvetica').fontSize(10).fillColor(COLORS.faint)
        .text(user.email, 0, bodyY + 50, { align: 'center' })

      doc.font('Helvetica').fontSize(14).fillColor(COLORS.ink)
        .text('completó el curso', 0, bodyY + 70, { align: 'center' })

      doc.font('Helvetica-Bold').fontSize(20).fillColor(COLORS.cyan)
        .text(`"${course.title}"`, 100, bodyY + 94, { align: 'center', width: pageWidth - 200 })

      doc.font('Helvetica').fontSize(12).fillColor(COLORS.muted)
        .text(
          'en RutSeg, plataforma de laboratorios prácticos en ciberseguridad del Semillero de\n' +
          'Investigación en Ciberseguridad y Desarrollo de Software — Universidad Santo Tomás, Tunja.',
          80, bodyY + 130, { align: 'center', width: pageWidth - 160, lineGap: 4 },
        )

      const dateStr = new Date().toLocaleDateString('es-CO', { year: 'numeric', month: 'long', day: 'numeric' })
      doc.font('Helvetica').fontSize(11).fillColor(COLORS.ink)
        .text(`Fecha de finalización: ${dateStr}`, 0, bodyY + 188, { align: 'center' })

      // Disclaimer — obligatorio, ver §5 del plan (no es una credencial de competencia)
      doc.font('Helvetica-Oblique').fontSize(9).fillColor(COLORS.faint)
        .text(
          'Este certificado acredita la finalización del contenido del curso. No constituye una evaluación ' +
          'ni una certificación de competencia profesional.',
          80, pageHeight - 82, { align: 'center', width: pageWidth - 160 },
        )

      // Código y URL de verificación
      doc.font('Courier').fontSize(9).fillColor(COLORS.muted)
        .text(
          `Código: ${code}   ·   Verificar en: rutseg.vercel.app/verify/${user.username}/${course.slug}/${code}`,
          0, pageHeight - 48, { align: 'center' },
        )

      doc.end()
    })
  }
}
