import sql from '../db/index.js'
import type { CourseModule } from '../types.js'

export class CourseModuleDAO {
  static async findByCourseId(courseId: string): Promise<CourseModule[]> {
    return sql<CourseModule[]>`
      SELECT * FROM course_modules WHERE course_id = ${courseId} ORDER BY position ASC
    `
  }

  static async findBySlug(courseId: string, slug: string): Promise<CourseModule | null> {
    const [row] = await sql<CourseModule[]>`
      SELECT * FROM course_modules WHERE course_id = ${courseId} AND slug = ${slug}
    `
    return row ?? null
  }

  static async findById(id: string): Promise<CourseModule | null> {
    const [row] = await sql<CourseModule[]>`SELECT * FROM course_modules WHERE id = ${id}`
    return row ?? null
  }

  static async create(data: {
    courseId: string
    slug: string
    title: string
    description?: string | null
    position: number
  }): Promise<CourseModule> {
    const [row] = await sql<CourseModule[]>`
      INSERT INTO course_modules (course_id, slug, title, description, position)
      VALUES (${data.courseId}, ${data.slug}, ${data.title}, ${data.description ?? null}, ${data.position})
      RETURNING *
    `
    return row
  }

  static async update(
    id: string,
    data: Partial<Pick<CourseModule, 'slug' | 'title' | 'description' | 'position'>>,
  ): Promise<CourseModule | null> {
    const [row] = await sql<CourseModule[]>`
      UPDATE course_modules SET
        slug        = COALESCE(${data.slug ?? null}, slug),
        title       = COALESCE(${data.title ?? null}, title),
        description = COALESCE(${data.description ?? null}, description),
        position    = COALESCE(${data.position ?? null}, position)
      WHERE id = ${id}
      RETURNING *
    `
    return row ?? null
  }

  static async delete(id: string): Promise<boolean> {
    const rows = await sql`DELETE FROM course_modules WHERE id = ${id} RETURNING id`
    return rows.length > 0
  }
}
