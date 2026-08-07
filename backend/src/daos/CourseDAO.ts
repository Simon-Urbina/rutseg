import sql from '../db/index.js'
import type { Course, Difficulty } from '../types.js'

export interface CourseWithStats extends Course {
  moduleCount: number
  labCount: number
  totalPoints: number
  isEnrolled: boolean
  completedLabsCount: number
}

export class CourseDAO {
  static async findAll(publishedOnly = true): Promise<Course[]> {
    if (publishedOnly) {
      return sql<Course[]>`
        SELECT * FROM courses WHERE is_published = TRUE ORDER BY created_at DESC
      `
    }
    return sql<Course[]>`SELECT * FROM courses ORDER BY created_at DESC`
  }

  static async findAllWithStats(
    opts: { userId?: string; publishedOnly?: boolean } = {},
  ): Promise<CourseWithStats[]> {
    const { userId, publishedOnly = true } = opts
    const rows = await sql<CourseWithStats[]>`
      SELECT
        c.*,
        COALESCE(s.module_count, 0)::int AS module_count,
        COALESCE(s.lab_count, 0)::int    AS lab_count,
        COALESCE(s.total_points, 0)::int AS total_points,
        ${
          userId
            ? sql`EXISTS(SELECT 1 FROM course_enrollments e WHERE e.user_id = ${userId} AND e.course_id = c.id)`
            : sql`FALSE`
        } AS is_enrolled,
        ${
          userId
            ? sql`(
                SELECT COALESCE(COUNT(DISTINCT ulp.laboratory_id), 0)::int
                FROM user_laboratory_progress ulp
                JOIN laboratories l  ON l.id  = ulp.laboratory_id
                JOIN course_modules cm ON cm.id = l.module_id
                WHERE ulp.user_id = ${userId}
                  AND ulp.status  = 'completed'
                  AND cm.course_id = c.id
              )`
            : sql`0`
        } AS completed_labs_count
      FROM courses c
      LEFT JOIN (
        SELECT
          cm.course_id,
          COUNT(DISTINCT cm.id)                                  AS module_count,
          COUNT(DISTINCT l.id) FILTER (WHERE l.is_published)     AS lab_count,
          COALESCE(SUM(l.points) FILTER (WHERE l.is_published), 0) AS total_points
        FROM course_modules cm
        LEFT JOIN laboratories l ON l.module_id = cm.id
        GROUP BY cm.course_id
      ) s ON s.course_id = c.id
      ${publishedOnly ? sql`WHERE c.is_published = TRUE` : sql``}
      ORDER BY c.created_at DESC
    `
    return rows
  }

  static async findBySlug(slug: string): Promise<Course | null> {
    const [row] = await sql<Course[]>`SELECT * FROM courses WHERE slug = ${slug}`
    return row ?? null
  }

  static async findBySlugWithStats(slug: string, userId?: string): Promise<CourseWithStats | null> {
    const [row] = await sql<CourseWithStats[]>`
      SELECT
        c.*,
        COALESCE(s.module_count, 0)::int  AS module_count,
        COALESCE(s.lab_count, 0)::int     AS lab_count,
        COALESCE(s.total_points, 0)::int  AS total_points,
        ${
          userId
            ? sql`EXISTS(SELECT 1 FROM course_enrollments e WHERE e.user_id = ${userId} AND e.course_id = c.id)`
            : sql`FALSE`
        } AS is_enrolled,
        ${
          userId
            ? sql`(
                SELECT COALESCE(COUNT(DISTINCT ulp.laboratory_id), 0)::int
                FROM user_laboratory_progress ulp
                JOIN laboratories l   ON l.id   = ulp.laboratory_id
                JOIN course_modules cm ON cm.id = l.module_id
                WHERE ulp.user_id   = ${userId}
                  AND ulp.status    = 'completed'
                  AND cm.course_id  = c.id
              )`
            : sql`0`
        } AS completed_labs_count
      FROM courses c
      LEFT JOIN (
        SELECT
          cm.course_id,
          COUNT(DISTINCT cm.id)                                      AS module_count,
          COUNT(DISTINCT l.id) FILTER (WHERE l.is_published)         AS lab_count,
          COALESCE(SUM(l.points) FILTER (WHERE l.is_published), 0)   AS total_points
        FROM course_modules cm
        LEFT JOIN laboratories l ON l.module_id = cm.id
        GROUP BY cm.course_id
      ) s ON s.course_id = c.id
      WHERE c.slug = ${slug}
    `
    return row ?? null
  }

  static async findById(id: string): Promise<Course | null> {
    const [row] = await sql<Course[]>`SELECT * FROM courses WHERE id = ${id}`
    return row ?? null
  }

  static async create(data: {
    slug: string
    title: string
    description?: string | null
    difficulty: Difficulty
    createdBy: string
  }): Promise<Course> {
    const [row] = await sql<Course[]>`
      INSERT INTO courses (slug, title, description, difficulty, created_by)
      VALUES (${data.slug}, ${data.title}, ${data.description ?? null}, ${data.difficulty}, ${data.createdBy})
      RETURNING *
    `
    return row
  }

  static async getPlatformStats(): Promise<{ courseCount: number; labCount: number; totalPoints: number; userCount: number }> {
    const [row] = await sql<[{ courseCount: number; labCount: number; totalPoints: number; userCount: number }]>`
      SELECT
        (SELECT COUNT(*)                      FROM courses     WHERE is_published = TRUE)::int                   AS course_count,
        (SELECT COUNT(*)                      FROM laboratories WHERE is_published = TRUE)::int                  AS lab_count,
        (SELECT COALESCE(SUM(points), 0)      FROM laboratories WHERE is_published = TRUE)::int                 AS total_points,
        (SELECT COUNT(*)                      FROM users        WHERE deleted_at IS NULL)::int                  AS user_count
    `
    return row
  }

  static async update(
    id: string,
    data: Partial<Pick<Course, 'slug' | 'title' | 'description' | 'difficulty' | 'isPublished'>>,
  ): Promise<Course | null> {
    const [row] = await sql<Course[]>`
      UPDATE courses SET
        slug        = COALESCE(${data.slug ?? null}, slug),
        title       = COALESCE(${data.title ?? null}, title),
        description = COALESCE(${data.description ?? null}, description),
        difficulty  = COALESCE(${data.difficulty ?? null}::course_diff, difficulty),
        is_published = COALESCE(${data.isPublished ?? null}, is_published)
      WHERE id = ${id}
      RETURNING *
    `
    return row ?? null
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await sql`DELETE FROM courses WHERE id = ${id} RETURNING id`
    return rows.length > 0
  }
}
