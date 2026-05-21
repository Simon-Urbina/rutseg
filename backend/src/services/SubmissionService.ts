import { LaboratoryDAO } from '../daos/LaboratoryDAO.js'
import { LaboratoryQuestionDAO } from '../daos/LaboratoryQuestionDAO.js'
import { LaboratoryQuestionOptionDAO } from '../daos/LaboratoryQuestionOptionDAO.js'
import { QuestionActivityDAO } from '../daos/QuestionActivityDAO.js'
import { UserActivityProgressDAO } from '../daos/UserActivityProgressDAO.js'
import { UserLaboratoryProgressDAO } from '../daos/UserLaboratoryProgressDAO.js'
import { SubmissionDAO } from '../daos/SubmissionDAO.js'
import { CourseEnrollmentDAO } from '../daos/CourseEnrollmentDAO.js'
import { CourseModuleDAO } from '../daos/CourseModuleDAO.js'
import { NotFoundError, ForbiddenError, BadRequestError } from '../utils/errors.js'
import type { SubmissionAnswer } from '../types.js'

export class SubmissionService {
  static async submit(
    userId: string,
    laboratoryId: string,
    answers: SubmissionAnswer[],
  ) {
    const lab = await LaboratoryDAO.findById(laboratoryId)
    if (!lab || !lab.isPublished) throw new NotFoundError('Laboratorio no encontrado.')

    if (answers.length !== lab.quizQuestionsRequired)
      throw new BadRequestError(`Debes responder exactamente ${lab.quizQuestionsRequired} preguntas.`)

    // Verificación de inscripción
    const module = await CourseModuleDAO.findById(lab.moduleId)
    if (module) {
      const enrollment = await CourseEnrollmentDAO.find(userId, module.courseId)
      if (!enrollment)
        throw new ForbiddenError('Debes estar inscrito en el curso para enviar este laboratorio.')
    }

    const questions = await LaboratoryQuestionDAO.findByLaboratoryId(laboratoryId)
    const questionIds = new Set(questions.map((q) => q.id))

    for (const a of answers) {
      if (!questionIds.has(a.questionId))
        throw new BadRequestError(`La pregunta ${a.questionId} no pertenece a este laboratorio.`)
    }

    // Calificar cada respuesta
    let correctCount = 0
    for (const answer of answers) {
      const question = questions.find((q) => q.id === answer.questionId)!

      if (question.questionType === 'multiple_choice') {
        if (!answer.selectedOptionId) continue
        const option = await LaboratoryQuestionOptionDAO.findById(answer.selectedOptionId)
        if (option?.questionId === question.id && option.isCorrect) correctCount++
      } else {
        // activity_response: correcta solo si coincide con la respuesta generada del usuario
        if (!answer.responseText) continue
        const activity = await QuestionActivityDAO.findByQuestionId(question.id)
        if (!activity) continue
        const progress = await UserActivityProgressDAO.find(userId, activity.id)
        if (
          progress?.generatedResponse &&
          answer.responseText.trim() === progress.generatedResponse.trim()
        ) {
          correctCount++
        }
      }
    }

    const scorePercent = Number(
      ((correctCount / lab.quizQuestionsRequired) * 100).toFixed(2),
    )
    const attemptNumber = await SubmissionDAO.getNextAttemptNumber(userId, laboratoryId)

    // Verificar estado de completitud previo antes de insertar (para detectar la primera completitud)
    const prevProgress = await UserLaboratoryProgressDAO.find(userId, laboratoryId)
    const wasAlreadyCompleted = prevProgress?.status === 'completed'

    // Insertar → el trigger de la BD actualiza user_laboratory_progress y otorga puntos en la primera completitud
    const submission = await SubmissionDAO.create({
      userId,
      laboratoryId,
      attemptNumber,
      answers,
      answeredQuestionsCount: answers.length,
      correctAnswersCount: correctCount,
      scorePercent,
    })

    const passed = scorePercent >= 60
    const pointsEarned = passed && !wasAlreadyCompleted ? lab.points : 0

    return {
      submissionId: submission.id,
      attemptNumber,
      correctAnswersCount: correctCount,
      totalQuestions: lab.quizQuestionsRequired,
      scorePercent,
      pointsEarned,
    }
  }

  static async getHistory(userId: string, laboratoryId: string) {
    const submissions = await SubmissionDAO.findByUserAndLab(userId, laboratoryId)
    return submissions.map(s => ({
      attemptNumber: s.attemptNumber,
      scorePercent: s.scorePercent,
      correctAnswersCount: s.correctAnswersCount,
      submittedAt: s.submittedAt,
    }))
  }

  static async checkAnswer(
    labId: string,
    questionId: string,
    selectedOptionId: string,
  ) {
    const question = await LaboratoryQuestionDAO.findById(questionId)
    if (!question || question.laboratoryId !== labId || question.questionType !== 'multiple_choice')
      throw new BadRequestError('Pregunta no válida.')

    const options = await LaboratoryQuestionOptionDAO.findByQuestionId(questionId)
    const selected = options.find(o => o.id === selectedOptionId)
    const correct = options.find(o => o.isCorrect)

    return {
      isCorrect: selected?.isCorrect ?? false,
      correctOptionId: correct?.id ?? null,
      explanation: question.explanation,
    }
  }
}
