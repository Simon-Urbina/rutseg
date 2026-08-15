import sql from '../db/index.js'

export type AnalyticsRange = '7d' | '1m' | '1y' | '5y'
export type BucketUnit = 'day' | 'month'

export interface KpiRow {
  totalUsers: number
  newUsersInRange: number
  totalPointsAwarded: number
  labsCompletedInRange: number
}

export interface TimeBucketRow {
  bucket: Date
  count: number
}

export interface PointsTimeBucketRow {
  bucket: Date
  points: number
}

export interface PointsDistributionRawRow {
  rangeLow: number
  rangeMid: number
  rangeHigh: number
  rangeMax: number
}

export interface DifficultyCountRow {
  difficulty: 'principiante' | 'intermedio' | 'avanzado'
  count: number
}

export interface AuthMethodCountRow {
  method: string
  count: number
}

export interface CourseEnrollmentRow {
  courseId: string
  title: string
  enrollments: number
}

export interface QuizScoreRow {
  scorePercent: number
  count: number
}

export interface CourseCompletionRawRow {
  courseId: string
  title: string
  enrolledCount: number
  labCount: number
  fullyCompletedCount: number
}

export class AdminAnalyticsDAO {
  static async getKpis(since: Date): Promise<KpiRow> {
    const [row] = await sql<[KpiRow]>`
      SELECT
        (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL)::int AS total_users,
        (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL AND created_at >= ${since})::int AS new_users_in_range,
        (SELECT COALESCE(SUM(points), 0) FROM users WHERE deleted_at IS NULL)::int AS total_points_awarded,
        (SELECT COUNT(*) FROM user_laboratory_progress WHERE status = 'completed' AND completed_at >= ${since})::int AS labs_completed_in_range
    `
    return row
  }

  static async getNewUsersByBucket(since: Date, bucketUnit: BucketUnit): Promise<TimeBucketRow[]> {
    return sql<TimeBucketRow[]>`
      WITH spine AS (
        SELECT generate_series(
          date_trunc(${bucketUnit}, ${since}::timestamptz),
          date_trunc(${bucketUnit}, now()),
          ('1 ' || ${bucketUnit})::interval
        ) AS bucket
      )
      SELECT spine.bucket, COALESCE(t.count, 0)::int AS count
      FROM spine
      LEFT JOIN (
        SELECT date_trunc(${bucketUnit}, created_at) AS bucket, COUNT(*)::int AS count
        FROM users
        WHERE created_at >= ${since} AND deleted_at IS NULL
        GROUP BY bucket
      ) t ON t.bucket = spine.bucket
      ORDER BY spine.bucket
    `
  }

  static async getLabsCompletedByBucket(since: Date, bucketUnit: BucketUnit): Promise<TimeBucketRow[]> {
    return sql<TimeBucketRow[]>`
      WITH spine AS (
        SELECT generate_series(
          date_trunc(${bucketUnit}, ${since}::timestamptz),
          date_trunc(${bucketUnit}, now()),
          ('1 ' || ${bucketUnit})::interval
        ) AS bucket
      )
      SELECT spine.bucket, COALESCE(t.count, 0)::int AS count
      FROM spine
      LEFT JOIN (
        SELECT date_trunc(${bucketUnit}, completed_at) AS bucket, COUNT(*)::int AS count
        FROM user_laboratory_progress
        WHERE status = 'completed' AND completed_at >= ${since}
        GROUP BY bucket
      ) t ON t.bucket = spine.bucket
      ORDER BY spine.bucket
    `
  }

  static async getPointsAwardedByBucket(since: Date, bucketUnit: BucketUnit): Promise<PointsTimeBucketRow[]> {
    return sql<PointsTimeBucketRow[]>`
      WITH spine AS (
        SELECT generate_series(
          date_trunc(${bucketUnit}, ${since}::timestamptz),
          date_trunc(${bucketUnit}, now()),
          ('1 ' || ${bucketUnit})::interval
        ) AS bucket
      )
      SELECT spine.bucket, COALESCE(t.points, 0)::int AS points
      FROM spine
      LEFT JOIN (
        SELECT date_trunc(${bucketUnit}, ulp.completed_at) AS bucket, COALESCE(SUM(l.points), 0)::int AS points
        FROM user_laboratory_progress ulp
        JOIN laboratories l ON l.id = ulp.laboratory_id
        WHERE ulp.status = 'completed' AND ulp.completed_at >= ${since}
        GROUP BY bucket
      ) t ON t.bucket = spine.bucket
      ORDER BY spine.bucket
    `
  }

  static async getForumCommentsByBucket(since: Date, bucketUnit: BucketUnit): Promise<TimeBucketRow[]> {
    return sql<TimeBucketRow[]>`
      WITH spine AS (
        SELECT generate_series(
          date_trunc(${bucketUnit}, ${since}::timestamptz),
          date_trunc(${bucketUnit}, now()),
          ('1 ' || ${bucketUnit})::interval
        ) AS bucket
      )
      SELECT spine.bucket, COALESCE(t.count, 0)::int AS count
      FROM spine
      LEFT JOIN (
        SELECT date_trunc(${bucketUnit}, created_at) AS bucket, COUNT(*)::int AS count
        FROM forum_comments
        WHERE created_at >= ${since} AND deleted_at IS NULL
        GROUP BY bucket
      ) t ON t.bucket = spine.bucket
      ORDER BY spine.bucket
    `
  }

  static async getPointsDistribution(): Promise<PointsDistributionRawRow> {
    const [row] = await sql<[PointsDistributionRawRow]>`
      SELECT
        COUNT(*) FILTER (WHERE points >= 0 AND points < 100)::int AS range_low,
        COUNT(*) FILTER (WHERE points >= 100 AND points < 500)::int AS range_mid,
        COUNT(*) FILTER (WHERE points >= 500 AND points < 1000)::int AS range_high,
        COUNT(*) FILTER (WHERE points >= 1000)::int AS range_max
      FROM users
      WHERE deleted_at IS NULL
    `
    return row
  }

  static async getCoursesByDifficulty(): Promise<DifficultyCountRow[]> {
    return sql<DifficultyCountRow[]>`
      SELECT difficulty, COUNT(*)::int AS count
      FROM courses
      WHERE is_published
      GROUP BY difficulty
    `
  }

  static async getEnrollmentsByDifficulty(): Promise<DifficultyCountRow[]> {
    return sql<DifficultyCountRow[]>`
      SELECT c.difficulty, COUNT(*)::int AS count
      FROM course_enrollments ce
      JOIN courses c ON c.id = ce.course_id
      WHERE c.is_published
      GROUP BY c.difficulty
    `
  }

  static async getUsersByAuthMethod(): Promise<AuthMethodCountRow[]> {
    return sql<AuthMethodCountRow[]>`
      WITH primary_oauth AS (
        SELECT DISTINCT ON (user_id) user_id, provider
        FROM user_oauth_accounts
        ORDER BY user_id, created_at ASC
      )
      SELECT COALESCE(po.provider, 'password') AS method, COUNT(*)::int AS count
      FROM users u
      LEFT JOIN primary_oauth po ON po.user_id = u.id
      WHERE u.deleted_at IS NULL
      GROUP BY method
    `
  }

  static async getEnrollmentsByCourse(): Promise<CourseEnrollmentRow[]> {
    return sql<CourseEnrollmentRow[]>`
      SELECT c.id AS course_id, c.title, COUNT(ce.id)::int AS enrollments
      FROM courses c
      LEFT JOIN course_enrollments ce ON ce.course_id = c.id
      WHERE c.is_published
      GROUP BY c.id, c.title
      ORDER BY enrollments DESC
    `
  }

  static async getQuizScoreDistribution(): Promise<QuizScoreRow[]> {
    return sql<QuizScoreRow[]>`
      SELECT score_percent::int AS score_percent, COUNT(*)::int AS count
      FROM submissions
      GROUP BY score_percent
      ORDER BY score_percent
    `
  }

  static async getCourseCompletionRaw(): Promise<CourseCompletionRawRow[]> {
    return sql<CourseCompletionRawRow[]>`
      WITH course_lab_counts AS (
        SELECT cm.course_id, COUNT(DISTINCT l.id) AS lab_count
        FROM course_modules cm
        JOIN laboratories l ON l.module_id = cm.id AND l.is_published
        GROUP BY cm.course_id
      ),
      user_completed_counts AS (
        SELECT cm.course_id, ulp.user_id, COUNT(DISTINCT ulp.laboratory_id) AS completed_count
        FROM user_laboratory_progress ulp
        JOIN laboratories l ON l.id = ulp.laboratory_id AND l.is_published
        JOIN course_modules cm ON cm.id = l.module_id
        JOIN course_enrollments ce ON ce.course_id = cm.course_id AND ce.user_id = ulp.user_id
        WHERE ulp.status = 'completed'
        GROUP BY cm.course_id, ulp.user_id
      ),
      enrollment_counts AS (
        SELECT course_id, COUNT(*) AS enrolled_count
        FROM course_enrollments
        GROUP BY course_id
      )
      SELECT
        c.id AS course_id,
        c.title,
        COALESCE(ec.enrolled_count, 0)::int AS enrolled_count,
        COALESCE(clc.lab_count, 0)::int AS lab_count,
        COALESCE((
          SELECT COUNT(*) FROM user_completed_counts ucc
          WHERE ucc.course_id = c.id AND clc.lab_count > 0 AND ucc.completed_count = clc.lab_count
        ), 0)::int AS fully_completed_count
      FROM courses c
      LEFT JOIN course_lab_counts clc ON clc.course_id = c.id
      LEFT JOIN enrollment_counts ec ON ec.course_id = c.id
      WHERE c.is_published
      ORDER BY c.title
    `
  }
}
