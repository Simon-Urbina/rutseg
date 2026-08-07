import { Hono } from 'hono'
import { requireAdmin } from '../middleware/auth.js'
import { CourseDAO } from '../daos/CourseDAO.js'
import { CourseModuleDAO } from '../daos/CourseModuleDAO.js'
import { LaboratoryDAO } from '../daos/LaboratoryDAO.js'
import { LaboratoryQuestionDAO } from '../daos/LaboratoryQuestionDAO.js'
import { LaboratoryQuestionOptionDAO } from '../daos/LaboratoryQuestionOptionDAO.js'
import { QuestionActivityDAO } from '../daos/QuestionActivityDAO.js'
import {
  Course,
  CourseModule,
  Laboratory,
  LaboratoryQuestion,
  LaboratoryQuestionOption,
  QuestionActivity,
} from '../models/index.js'
import { NotFoundError, BadRequestError, ValidationError } from '../utils/errors.js'
import type { TokenPayload } from '../types.js'

const router = new Hono<{ Variables: { user: TokenPayload } }>()
router.use('*', requireAdmin)

/** Verifica que un laboratorio tenga sus 5 preguntas completas antes de permitir publicarlo. */
async function assertLabReadyToPublish(laboratoryId: string): Promise<void> {
  const questions = await LaboratoryQuestionDAO.findByLaboratoryId(laboratoryId)
  if (questions.length !== 5) {
    throw new BadRequestError(
      `El laboratorio debe tener exactamente 5 preguntas para publicarse (tiene ${questions.length}).`,
    )
  }
  for (const q of questions) {
    if (q.questionType === 'multiple_choice') {
      const options = await LaboratoryQuestionOptionDAO.findByQuestionId(q.id)
      if (options.length < 2)
        throw new BadRequestError(`La pregunta ${q.questionOrder} necesita al menos 2 opciones.`)
      const correctCount = options.filter(o => o.isCorrect).length
      if (correctCount !== 1)
        throw new BadRequestError(`La pregunta ${q.questionOrder} debe tener exactamente una opción correcta.`)
    } else {
      const activity = await QuestionActivityDAO.findByQuestionId(q.id)
      if (!activity)
        throw new BadRequestError(`La pregunta ${q.questionOrder} no tiene una actividad configurada.`)
    }
  }
}

// ── Courses ──────────────────────────────────────────────────────────────────
router.post('/courses', async (c) => {
  const user = c.get('user') as TokenPayload
  const data = await c.req.json()
  const errors = Course.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(await CourseDAO.create({ ...data, createdBy: user.id }), 201)
})

router.put('/courses/:id', async (c) => {
  const existing = await CourseDAO.findById(c.req.param('id'))
  if (!existing) throw new NotFoundError('Curso no encontrado.')
  const data = await c.req.json()
  const errors = Course.validate({
    slug: data.slug ?? existing.slug,
    title: data.title ?? existing.title,
    difficulty: data.difficulty ?? existing.difficulty,
  })
  if (errors.length) throw new ValidationError(errors)
  const course = await CourseDAO.update(c.req.param('id'), data)
  if (!course) throw new NotFoundError('Curso no encontrado.')
  return c.json(course)
})

router.delete('/courses/:id', async (c) => {
  const deleted = await CourseDAO.delete(c.req.param('id'))
  if (!deleted) throw new NotFoundError('Curso no encontrado.')
  return c.json({ success: true })
})

// ── Modules ───────────────────────────────────────────────────────────────────
router.post('/courses/:courseId/modules', async (c) => {
  const data = await c.req.json()
  const errors = CourseModule.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(
    await CourseModuleDAO.create({ ...data, courseId: c.req.param('courseId') }),
    201,
  )
})

router.put('/modules/:id', async (c) => {
  const existing = await CourseModuleDAO.findById(c.req.param('id'))
  if (!existing) throw new NotFoundError('Módulo no encontrado.')
  const data = await c.req.json()
  const errors = CourseModule.validate({
    slug: data.slug ?? existing.slug,
    title: data.title ?? existing.title,
    position: data.position ?? existing.position,
  })
  if (errors.length) throw new ValidationError(errors)
  const module = await CourseModuleDAO.update(c.req.param('id'), data)
  if (!module) throw new NotFoundError('Módulo no encontrado.')
  return c.json(module)
})

router.delete('/modules/:id', async (c) => {
  const deleted = await CourseModuleDAO.delete(c.req.param('id'))
  if (!deleted) throw new NotFoundError('Módulo no encontrado.')
  return c.json({ success: true })
})

// ── Laboratories ──────────────────────────────────────────────────────────────
router.get('/labs/:id', async (c) => {
  const lab = await LaboratoryDAO.findById(c.req.param('id'))
  if (!lab) throw new NotFoundError('Laboratorio no encontrado.')

  const questions = await LaboratoryQuestionDAO.findByLaboratoryId(lab.id)
  const questionsWithDetails = await Promise.all(
    questions.map(async (q) => {
      if (q.questionType === 'multiple_choice') {
        const options = await LaboratoryQuestionOptionDAO.findByQuestionId(q.id)
        return { ...q, options, activity: null }
      }
      const activity = await QuestionActivityDAO.findByQuestionId(q.id)
      return { ...q, options: [], activity }
    }),
  )

  return c.json({ ...lab, questions: questionsWithDetails })
})

router.post('/modules/:moduleId/labs', async (c) => {
  const data = await c.req.json()
  const errors = Laboratory.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(
    await LaboratoryDAO.create({ ...data, moduleId: c.req.param('moduleId') }),
    201,
  )
})

router.put('/labs/:id', async (c) => {
  const existing = await LaboratoryDAO.findById(c.req.param('id'))
  if (!existing) throw new NotFoundError('Laboratorio no encontrado.')
  const data = await c.req.json()
  const errors = Laboratory.validate({
    slug: data.slug ?? existing.slug,
    title: data.title ?? existing.title,
    contentMarkdown: data.contentMarkdown ?? existing.contentMarkdown,
    position: data.position ?? existing.position,
    estimatedMinutes: data.estimatedMinutes ?? existing.estimatedMinutes,
    points: data.points ?? existing.points,
  })
  if (errors.length) throw new ValidationError(errors)
  if (data.isPublished === true) await assertLabReadyToPublish(existing.id)
  const lab = await LaboratoryDAO.update(c.req.param('id'), data)
  if (!lab) throw new NotFoundError('Laboratorio no encontrado.')
  return c.json(lab)
})

router.delete('/labs/:id', async (c) => {
  const deleted = await LaboratoryDAO.delete(c.req.param('id'))
  if (!deleted) throw new NotFoundError('Laboratorio no encontrado.')
  return c.json({ success: true })
})

// ── Questions ─────────────────────────────────────────────────────────────────
router.post('/labs/:labId/questions', async (c) => {
  const labId = c.req.param('labId')
  const count = await LaboratoryQuestionDAO.countByLaboratoryId(labId)
  if (count >= 5) throw new BadRequestError('El laboratorio ya tiene 5 preguntas.')
  const data = await c.req.json()
  const errors = LaboratoryQuestion.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(await LaboratoryQuestionDAO.create({ ...data, laboratoryId: labId }), 201)
})

router.put('/questions/:id', async (c) => {
  const existing = await LaboratoryQuestionDAO.findById(c.req.param('id'))
  if (!existing) throw new NotFoundError('Pregunta no encontrada.')
  const data = await c.req.json()
  const errors = LaboratoryQuestion.validate({
    questionOrder: existing.questionOrder,
    questionType: existing.questionType,
    questionText: data.questionText ?? existing.questionText,
  })
  if (errors.length) throw new ValidationError(errors)
  const question = await LaboratoryQuestionDAO.update(c.req.param('id'), data)
  if (!question) throw new NotFoundError('Pregunta no encontrada.')
  return c.json(question)
})

router.delete('/questions/:id', async (c) => {
  const deleted = await LaboratoryQuestionDAO.delete(c.req.param('id'))
  if (!deleted) throw new NotFoundError('Pregunta no encontrada.')
  return c.json({ success: true })
})

// ── Options ───────────────────────────────────────────────────────────────────
router.post('/questions/:questionId/options', async (c) => {
  const data = await c.req.json()
  const errors = LaboratoryQuestionOption.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(
    await LaboratoryQuestionOptionDAO.create({ ...data, questionId: c.req.param('questionId') }),
    201,
  )
})

router.put('/questions/:questionId/options/:id', async (c) => {
  const existing = await LaboratoryQuestionOptionDAO.findById(c.req.param('id'))
  if (!existing || existing.questionId !== c.req.param('questionId'))
    throw new NotFoundError('Opción no encontrada.')
  const data = await c.req.json()
  const errors = LaboratoryQuestionOption.validate({
    optionOrder: data.optionOrder ?? existing.optionOrder,
    optionText: data.optionText ?? existing.optionText,
  })
  if (errors.length) throw new ValidationError(errors)
  const option = await LaboratoryQuestionOptionDAO.update(c.req.param('id'), data)
  if (!option) throw new NotFoundError('Opción no encontrada.')
  return c.json(option)
})

router.delete('/questions/:questionId/options/:id', async (c) => {
  const existing = await LaboratoryQuestionOptionDAO.findById(c.req.param('id'))
  if (!existing || existing.questionId !== c.req.param('questionId'))
    throw new NotFoundError('Opción no encontrada.')
  await LaboratoryQuestionOptionDAO.delete(c.req.param('id'))
  return c.json({ success: true })
})

// ── Activities ────────────────────────────────────────────────────────────────
router.post('/questions/:questionId/activity', async (c) => {
  const data = await c.req.json()
  const errors = QuestionActivity.validate(data)
  if (errors.length) throw new ValidationError(errors)
  return c.json(
    await QuestionActivityDAO.create({ ...data, questionId: c.req.param('questionId') }),
    201,
  )
})

router.put('/activities/:id', async (c) => {
  const existing = await QuestionActivityDAO.findById(c.req.param('id'))
  if (!existing) throw new NotFoundError('Actividad no encontrada.')
  const data = await c.req.json()
  const errors = QuestionActivity.validate({
    title: data.title ?? existing.title,
    instructionsMarkdown: data.instructionsMarkdown ?? existing.instructionsMarkdown,
    expectedActionKey: data.expectedActionKey ?? existing.expectedActionKey,
  })
  if (errors.length) throw new ValidationError(errors)
  const activity = await QuestionActivityDAO.update(c.req.param('id'), data)
  if (!activity) throw new NotFoundError('Actividad no encontrada.')
  return c.json(activity)
})

export default router
