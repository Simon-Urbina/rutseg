function shuffle<T>(arr: T[]): T[] {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

import { CourseDAO } from '../daos/CourseDAO.js'
import { CourseModuleDAO } from '../daos/CourseModuleDAO.js'
import { CourseEnrollmentDAO } from '../daos/CourseEnrollmentDAO.js'
import { LaboratoryDAO } from '../daos/LaboratoryDAO.js'
import { LaboratoryQuestionDAO } from '../daos/LaboratoryQuestionDAO.js'
import { LaboratoryQuestionOptionDAO } from '../daos/LaboratoryQuestionOptionDAO.js'
import { QuestionActivityDAO } from '../daos/QuestionActivityDAO.js'
import { UserActivityProgressDAO } from '../daos/UserActivityProgressDAO.js'
import { UserLaboratoryProgressDAO } from '../daos/UserLaboratoryProgressDAO.js'
import { NotFoundError, ForbiddenError, ConflictError } from '../utils/errors.js'
import type { UserRole, CourseEnrollment } from '../types.js'

export class CourseService {
  static async listCourses(opts: { userId?: string; role?: UserRole } = {}) {
    return CourseDAO.findAllWithStats({
      userId: opts.userId,
      publishedOnly: opts.role !== 'admin',
    })
  }

  static async getCourse(slug: string, userId?: string, role?: UserRole) {
    const course = await CourseDAO.findBySlugWithStats(slug, userId)
    if (!course || (!course.isPublished && role !== 'admin'))
      throw new NotFoundError('Curso no encontrado.')
    return course
  }

  static async getCourseNav(courseSlug: string) {
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!course || !course.isPublished) throw new NotFoundError('Curso no encontrado.')
    const modules = await CourseModuleDAO.findByCourseId(course.id)
    const modulesWithLabs = await Promise.all(
      modules.map(async m => {
        const labs = await LaboratoryDAO.findByModuleId(m.id, true)
        return { slug: m.slug, labs: labs.map(l => ({ slug: l.slug, title: l.title })) }
      })
    )
    return { modules: modulesWithLabs }
  }

  static async enrollUser(userId: string, courseSlug: string): Promise<CourseEnrollment> {
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!course || !course.isPublished) throw new NotFoundError('Curso no encontrado.')
    if (await CourseEnrollmentDAO.find(userId, course.id))
      throw new ConflictError('Ya estás inscrito en este curso.')
    return CourseEnrollmentDAO.create(userId, course.id)
  }

  static async getModules(courseSlug: string, role?: UserRole) {
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!course || (!course.isPublished && role !== 'admin'))
      throw new NotFoundError('Curso no encontrado.')
    return CourseModuleDAO.findByCourseId(course.id)
  }

  static async getLaboratories(courseSlug: string, moduleSlug: string, userId?: string, role?: UserRole) {
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!course || (!course.isPublished && role !== 'admin'))
      throw new NotFoundError('Curso no encontrado.')
    const module = await CourseModuleDAO.findBySlug(course.id, moduleSlug)
    if (!module) throw new NotFoundError('Módulo no encontrado.')
    return LaboratoryDAO.findByModuleId(module.id, role !== 'admin', userId)
  }

  static async getLaboratory(
    courseSlug: string,
    moduleSlug: string,
    labSlug: string,
    userId: string,
    role: UserRole,
  ) {
    const course = await CourseDAO.findBySlug(courseSlug)
    if (!course || (!course.isPublished && role !== 'admin'))
      throw new NotFoundError('Curso no encontrado.')

    // Verificación de inscripción (admin omite esta validación)
    if (role !== 'admin') {
      if (!(await CourseEnrollmentDAO.find(userId, course.id)))
        throw new ForbiddenError('Debes inscribirte al curso para acceder a este laboratorio.')
    }

    const module = await CourseModuleDAO.findBySlug(course.id, moduleSlug)
    if (!module) throw new NotFoundError('Módulo no encontrado.')

    const lab = await LaboratoryDAO.findBySlug(module.id, labSlug)
    if (!lab || (!lab.isPublished && role !== 'admin'))
      throw new NotFoundError('Laboratorio no encontrado.')

    const questions = await LaboratoryQuestionDAO.findByLaboratoryId(lab.id)

    const questionsWithDetails = await Promise.all(
      questions.map(async (q) => {
        if (q.questionType === 'multiple_choice') {
          const options = await LaboratoryQuestionOptionDAO.findByQuestionId(q.id)
          return {
            id: q.id,
            questionOrder: q.questionOrder,
            questionType: q.questionType,
            questionText: q.questionText,
            explanation: q.explanation,
            options: shuffle(options).map((o) => ({
              id: o.id,
              optionOrder: o.optionOrder,
              optionText: o.optionText,
            })),
            activity: null,
          }
        }

        // activity_response
        const activity = await QuestionActivityDAO.findByQuestionId(q.id)
        const progress = activity
          ? await UserActivityProgressDAO.find(userId, activity.id)
          : null
        return {
          id: q.id,
          questionOrder: q.questionOrder,
          questionType: q.questionType,
          questionText: q.questionText,
          explanation: q.explanation,
          options: [],
          activity: activity
            ? {
                id: activity.id,
                title: activity.title,
                instructionsMarkdown: activity.instructionsMarkdown,
                isCompleted: progress?.status === 'completed',
                // Solo revelar la respuesta después de que el usuario completó la actividad
                generatedResponse:
                  progress?.status === 'completed' ? progress.generatedResponse : null,
              }
            : null,
        }
      }),
    )

    const progress = await UserLaboratoryProgressDAO.find(userId, lab.id)

    return {
      lab: {
        id: lab.id,
        slug: lab.slug,
        title: lab.title,
        contentMarkdown: lab.contentMarkdown,
        estimatedMinutes: lab.estimatedMinutes,
        points: lab.points,
        quizQuestionsRequired: lab.quizQuestionsRequired,
        ...(role === 'admin' ? { isPublished: lab.isPublished } : {}),
      },
      questions: questionsWithDetails,
      progress: progress
        ? {
            status: progress.status,
            attemptsCount: progress.attemptsCount,
            bestScorePercent: progress.bestScorePercent,
            lastScorePercent: progress.lastScorePercent,
            completedAt: progress.completedAt,
          }
        : null,
    }
  }
}
