import sql from '../db/index.js'
import type { LaboratoryQuestionOption } from '../types.js'

export class LaboratoryQuestionOptionDAO {
  static async findByQuestionId(questionId: string): Promise<LaboratoryQuestionOption[]> {
    return sql<LaboratoryQuestionOption[]>`
      SELECT * FROM laboratory_question_options
      WHERE question_id = ${questionId}
      ORDER BY option_order ASC
    `
  }

  static async findCorrectByQuestionId(questionId: string): Promise<LaboratoryQuestionOption | null> {
    const [row] = await sql<LaboratoryQuestionOption[]>`
      SELECT * FROM laboratory_question_options
      WHERE question_id = ${questionId} AND is_correct = TRUE
    `
    return row ?? null
  }

  static async findById(id: string): Promise<LaboratoryQuestionOption | null> {
    const [row] = await sql<LaboratoryQuestionOption[]>`
      SELECT * FROM laboratory_question_options WHERE id = ${id}
    `
    return row ?? null
  }

  static async create(data: {
    questionId: string
    optionOrder: number
    optionText: string
    isCorrect: boolean
  }): Promise<LaboratoryQuestionOption> {
    return sql.begin(async (tx) => {
      const [row] = await tx<LaboratoryQuestionOption[]>`
        INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
        VALUES (${data.questionId}, ${data.optionOrder}, ${data.optionText}, ${data.isCorrect})
        RETURNING *
      `
      if (data.isCorrect) {
        await tx`
          UPDATE laboratory_question_options
          SET is_correct = FALSE
          WHERE question_id = ${data.questionId} AND id != ${row.id}
        `
      }
      return row
    })
  }

  static async update(
    id: string,
    data: Partial<Pick<LaboratoryQuestionOption, 'optionOrder' | 'optionText' | 'isCorrect'>>,
  ): Promise<LaboratoryQuestionOption | null> {
    return sql.begin(async (tx) => {
      const [row] = await tx<LaboratoryQuestionOption[]>`
        UPDATE laboratory_question_options SET
          option_order = COALESCE(${data.optionOrder ?? null}, option_order),
          option_text  = COALESCE(${data.optionText ?? null}, option_text),
          is_correct   = COALESCE(${data.isCorrect ?? null}, is_correct)
        WHERE id = ${id}
        RETURNING *
      `
      if (!row) return null
      if (data.isCorrect) {
        await tx`
          UPDATE laboratory_question_options
          SET is_correct = FALSE
          WHERE question_id = ${row.questionId} AND id != ${row.id}
        `
      }
      return row
    })
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await sql`DELETE FROM laboratory_question_options WHERE id = ${id} RETURNING id`
    return rows.length > 0
  }
}
