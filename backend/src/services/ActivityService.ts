import { QuestionActivityDAO } from '../daos/QuestionActivityDAO.js'
import { ActivityActionLogDAO } from '../daos/ActivityActionLogDAO.js'
import { UserActivityProgressDAO } from '../daos/UserActivityProgressDAO.js'
import { NotFoundError } from '../utils/errors.js'
import { generateActivityResponse } from '../utils/response.js'

export class ActivityService {
  static async attempt(
    userId: string,
    activityId: string,
    actionPayload: Record<string, unknown>,
  ) {
    const activity = await QuestionActivityDAO.findById(activityId)
    if (!activity || !activity.isPublished)
      throw new NotFoundError('Actividad no encontrada.')

    // Si ya fue completada, retornar la respuesta almacenada sin registrar otro intento
    const existing = await UserActivityProgressDAO.find(userId, activityId)
    if (existing?.status === 'completed') {
      return {
        isCorrect: true,
        feedback: activity.successFeedback,
        generatedResponse: existing.generatedResponse,
        alreadyCompleted: true,
      }
    }

    // Aceptar la acción bajo la clave 'action' o 'command' (primer valor como fallback)
    const submitted = String(
      actionPayload.action ?? actionPayload.command ?? Object.values(actionPayload)[0] ?? '',
    ).trim()
    const isCorrect = submitted === activity.expectedActionKey.trim()

    const generatedResponse = isCorrect ? generateActivityResponse(userId, activityId) : null
    const feedback = isCorrect
      ? activity.successFeedback
      : 'Acción incorrecta. Revisa el comando e inténtalo de nuevo.'

    // Insertar log → el trigger de la BD hace upsert en user_activity_progress automáticamente
    await ActivityActionLogDAO.create({
      userId,
      activityId,
      actionPayload,
      isCorrect,
      feedback,
      generatedResponse,
    })

    return { isCorrect, feedback, generatedResponse, alreadyCompleted: false }
  }
}
