import sql from '../db/index.js'
import type { LaboratoryQuestion } from '../types.js'

export class LaboratoryQuestionDAO {
  static async findByLaboratoryId(laboratoryId: string): Promise<LaboratoryQuestion[]> {
    return sql<LaboratoryQuestion[]>`
      SELECT * FROM laboratory_questions
      WHERE laboratory_id = ${laboratoryId}
      ORDER BY question_order ASC
    `
  }

  static async findById(id: string): Promise<LaboratoryQuestion | null> {
    const [row] = await sql<LaboratoryQuestion[]>`
      SELECT * FROM laboratory_questions WHERE id = ${id}
    `
    return row ?? null
  }

  static async countByLaboratoryId(laboratoryId: string): Promise<number> {
    const [{ count }] = await sql<[{ count: string }]>`
      SELECT COUNT(*) AS count FROM laboratory_questions WHERE laboratory_id = ${laboratoryId}
    `
    return Number(count)
  }

  static async create(data: {
    laboratoryId: string
    questionOrder: number
    questionType: 'multiple_choice' | 'activity_response'
    questionText: string
    explanation?: string | null
  }): Promise<LaboratoryQuestion> {
    const [row] = await sql<LaboratoryQuestion[]>`
      INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
      VALUES (
        ${data.laboratoryId}, ${data.questionOrder}, ${data.questionType},
        ${data.questionText}, ${data.explanation ?? null}
      )
      RETURNING *
    `
    return row
  }

  static async update(
    id: string,
    data: Partial<Pick<LaboratoryQuestion, 'questionText' | 'explanation'>>,
  ): Promise<LaboratoryQuestion | null> {
    const [row] = await sql<LaboratoryQuestion[]>`
      UPDATE laboratory_questions SET
        question_text = COALESCE(${data.questionText ?? null}, question_text),
        explanation   = COALESCE(${data.explanation ?? null}, explanation)
      WHERE id = ${id}
      RETURNING *
    `
    return row ?? null
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await sql`DELETE FROM laboratory_questions WHERE id = ${id} RETURNING id`
    return rows.length > 0
  }
}
