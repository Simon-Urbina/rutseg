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
      SELECT date_trunc(${bucketUnit}, created_at) AS bucket, COUNT(*)::int AS count
      FROM users
      WHERE created_at >= ${since} AND deleted_at IS NULL
      GROUP BY bucket
      ORDER BY bucket
    `
  }

  static async getLabsCompletedByBucket(since: Date, bucketUnit: BucketUnit): Promise<TimeBucketRow[]> {
    return sql<TimeBucketRow[]>`
      SELECT date_trunc(${bucketUnit}, completed_at) AS bucket, COUNT(*)::int AS count
      FROM user_laboratory_progress
      WHERE status = 'completed' AND completed_at >= ${since}
      GROUP BY bucket
      ORDER BY bucket
    `
  }

  static async getPointsAwardedByBucket(since: Date, bucketUnit: BucketUnit): Promise<PointsTimeBucketRow[]> {
    return sql<PointsTimeBucketRow[]>`
      SELECT date_trunc(${bucketUnit}, ulp.completed_at) AS bucket, COALESCE(SUM(l.points), 0)::int AS points
      FROM user_laboratory_progress ulp
      JOIN laboratories l ON l.id = ulp.laboratory_id
      WHERE ulp.status = 'completed' AND ulp.completed_at >= ${since}
      GROUP BY bucket
      ORDER BY bucket
    `
  }

  static async getForumCommentsByBucket(since: Date, bucketUnit: BucketUnit): Promise<TimeBucketRow[]> {
    return sql<TimeBucketRow[]>`
      SELECT date_trunc(${bucketUnit}, created_at) AS bucket, COUNT(*)::int AS count
      FROM forum_comments
      WHERE created_at >= ${since} AND deleted_at IS NULL
      GROUP BY bucket
      ORDER BY bucket
    `
  }
}
