import sql from '../db/index.js'
import type { Laboratory } from '../types.js'

export interface LaboratoryWithProgress extends Laboratory {
  progress: {
    status: 'not_started' | 'in_progress' | 'completed'
    bestScorePercent: number
    attemptsCount: number
  } | null
}

export class LaboratoryDAO {
  static async findByModuleId(
    moduleId: string,
    publishedOnly = true,
    userId?: string,
  ): Promise<LaboratoryWithProgress[]> {
    return sql<LaboratoryWithProgress[]>`
      SELECT
        l.*,
        ${userId
          ? sql`
            CASE WHEN ulp.id IS NOT NULL THEN
              jsonb_build_object(
                'status',           ulp.status,
                'bestScorePercent', ulp.best_score_percent,
                'attemptsCount',    ulp.attempts_count
              )
            ELSE NULL END
          `
          : sql`NULL`
        } AS progress
      FROM laboratories l
      ${userId
        ? sql`LEFT JOIN user_laboratory_progress ulp
                ON ulp.laboratory_id = l.id AND ulp.user_id = ${userId}`
        : sql``
      }
      WHERE l.module_id = ${moduleId}
        ${publishedOnly ? sql`AND l.is_published = TRUE` : sql``}
      ORDER BY l.position ASC
    `
  }

  static async findBySlug(moduleId: string, slug: string): Promise<Laboratory | null> {
    const [row] = await sql<Laboratory[]>`
      SELECT * FROM laboratories WHERE module_id = ${moduleId} AND slug = ${slug}
    `
    return row ?? null
  }

  static async findById(id: string): Promise<Laboratory | null> {
    const [row] = await sql<Laboratory[]>`SELECT * FROM laboratories WHERE id = ${id}`
    return row ?? null
  }

  static async create(data: {
    moduleId: string
    slug: string
    title: string
    contentMarkdown: string
    position: number
    estimatedMinutes?: number
    points?: number
  }): Promise<Laboratory> {
    const [row] = await sql<Laboratory[]>`
      INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points)
      VALUES (
        ${data.moduleId}, ${data.slug}, ${data.title}, ${data.contentMarkdown},
        ${data.position}, ${data.estimatedMinutes ?? 10}, ${data.points ?? 0}
      )
      RETURNING *
    `
    return row
  }

  static async update(
    id: string,
    data: Partial<Pick<Laboratory, 'slug' | 'title' | 'contentMarkdown' | 'position' | 'estimatedMinutes' | 'points' | 'isPublished'>>,
  ): Promise<Laboratory | null> {
    const [row] = await sql<Laboratory[]>`
      UPDATE laboratories SET
        slug             = COALESCE(${data.slug ?? null}, slug),
        title            = COALESCE(${data.title ?? null}, title),
        content_markdown = COALESCE(${data.contentMarkdown ?? null}, content_markdown),
        position         = COALESCE(${data.position ?? null}, position),
        estimated_minutes = COALESCE(${data.estimatedMinutes ?? null}, estimated_minutes),
        points           = COALESCE(${data.points ?? null}, points),
        is_published     = COALESCE(${data.isPublished ?? null}, is_published)
      WHERE id = ${id}
      RETURNING *
    `
    return row ?? null
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await sql`DELETE FROM laboratories WHERE id = ${id} RETURNING id`
    return rows.length > 0
  }
}
