import sql from '../db/index.js'
import type { CourseEnrollment } from '../types.js'

export class CourseEnrollmentDAO {
  static async find(userId: string, courseId: string): Promise<CourseEnrollment | null> {
    const [row] = await sql<CourseEnrollment[]>`
      SELECT * FROM course_enrollments WHERE user_id = ${userId} AND course_id = ${courseId}
    `
    return row ?? null
  }

  static async create(userId: string, courseId: string): Promise<CourseEnrollment> {
    const [row] = await sql<CourseEnrollment[]>`
      INSERT INTO course_enrollments (user_id, course_id) VALUES (${userId}, ${courseId}) RETURNING *
    `
    return row
  }

  static async delete(userId: string, courseId: string): Promise<void> {
    await sql`
      DELETE FROM course_enrollments WHERE user_id = ${userId} AND course_id = ${courseId}
    `
  }

  static async findByUserId(userId: string): Promise<CourseEnrollment[]> {
    return sql<CourseEnrollment[]>`
      SELECT * FROM course_enrollments WHERE user_id = ${userId}
    `
  }

  static async findCourseSummariesByUserId(userId: string): Promise<{ id: string; title: string; slug: string }[]> {
    return sql`
      SELECT c.id, c.title, c.slug
      FROM course_enrollments ce
      JOIN courses c ON c.id = ce.course_id
      WHERE ce.user_id = ${userId}
      ORDER BY ce.enrolled_at ASC
    `
  }
}
