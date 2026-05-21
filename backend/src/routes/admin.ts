import { Hono } from 'hono'
import { requireAdmin } from '../middleware/auth.js'
import { CourseDAO } from '../daos/CourseDAO.js'
import { CourseModuleDAO } from '../daos/CourseModuleDAO.js'
import { LaboratoryDAO } from '../daos/LaboratoryDAO.js'
import { LaboratoryQuestionDAO } from '../daos/LaboratoryQuestionDAO.js'
import { LaboratoryQuestionOptionDAO } from '../daos/LaboratoryQuestionOptionDAO.js'
import { QuestionActivityDAO } from '../daos/QuestionActivityDAO.js'
import { NotFoundError, BadRequestError } from '../utils/errors.js'
import type { TokenPayload } from '../types.js'

const router = new Hono<{ Variables: { user: TokenPayload } }>()
router.use('*', requireAdmin)

// ── Courses ──────────────────────────────────────────────────────────────────
router.post('/courses', async (c) => {
  const user = c.get('user') as TokenPayload
  const data = await c.req.json()
  return c.json(await CourseDAO.create({ ...data, createdBy: user.id }), 201)
})

router.put('/courses/:id', async (c) => {
  const course = await CourseDAO.update(c.req.param('id'), await c.req.json())
  if (!course) throw new NotFoundError('Curso no encontrado.')
  return c.json(course)
})

// ── Modules ───────────────────────────────────────────────────────────────────
router.post('/courses/:courseId/modules', async (c) => {
  const data = await c.req.json()
  return c.json(
    await CourseModuleDAO.create({ ...data, courseId: c.req.param('courseId') }),
    201,
  )
})

router.put('/modules/:id', async (c) => {
  const module = await CourseModuleDAO.update(c.req.param('id'), await c.req.json())
  if (!module) throw new NotFoundError('Módulo no encontrado.')
  return c.json(module)
})

// ── Laboratories ──────────────────────────────────────────────────────────────
router.post('/modules/:moduleId/labs', async (c) => {
  const data = await c.req.json()
  return c.json(
    await LaboratoryDAO.create({ ...data, moduleId: c.req.param('moduleId') }),
    201,
  )
})

router.put('/labs/:id', async (c) => {
  const lab = await LaboratoryDAO.update(c.req.param('id'), await c.req.json())
  if (!lab) throw new NotFoundError('Laboratorio no encontrado.')
  return c.json(lab)
})

// ── Questions ─────────────────────────────────────────────────────────────────
router.post('/labs/:labId/questions', async (c) => {
  const labId = c.req.param('labId')
  const count = await LaboratoryQuestionDAO.countByLaboratoryId(labId)
  if (count >= 5) throw new BadRequestError('El laboratorio ya tiene 5 preguntas.')
  const data = await c.req.json()
  return c.json(await LaboratoryQuestionDAO.create({ ...data, laboratoryId: labId }), 201)
})

router.put('/questions/:id', async (c) => {
  const question = await LaboratoryQuestionDAO.update(c.req.param('id'), await c.req.json())
  if (!question) throw new NotFoundError('Pregunta no encontrada.')
  return c.json(question)
})

// ── Options ───────────────────────────────────────────────────────────────────
router.post('/questions/:questionId/options', async (c) => {
  const data = await c.req.json()
  return c.json(
    await LaboratoryQuestionOptionDAO.create({ ...data, questionId: c.req.param('questionId') }),
    201,
  )
})

// ── Activities ────────────────────────────────────────────────────────────────
router.post('/questions/:questionId/activity', async (c) => {
  const data = await c.req.json()
  return c.json(
    await QuestionActivityDAO.create({ ...data, questionId: c.req.param('questionId') }),
    201,
  )
})

router.put('/activities/:id', async (c) => {
  const activity = await QuestionActivityDAO.update(c.req.param('id'), await c.req.json())
  if (!activity) throw new NotFoundError('Actividad no encontrada.')
  return c.json(activity)
})

export default router
