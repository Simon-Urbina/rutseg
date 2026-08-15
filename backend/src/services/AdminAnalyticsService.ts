import { AdminAnalyticsDAO, type AnalyticsRange, type BucketUnit } from '../daos/AdminAnalyticsDAO.js'
import { BadRequestError } from '../utils/errors.js'

const VALID_RANGES: AnalyticsRange[] = ['7d', '1m', '1y', '5y']
const QUIZ_SCORE_VALUES = [0, 20, 40, 60, 80, 100] as const

function resolveRange(range: string | undefined): { since: Date; bucketUnit: BucketUnit } {
  if (!range || !VALID_RANGES.includes(range as AnalyticsRange)) {
    throw new BadRequestError(`Rango inválido. Usa uno de: ${VALID_RANGES.join(', ')}.`)
  }
  const now = new Date()
  switch (range as AnalyticsRange) {
    case '7d':
      return { since: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000), bucketUnit: 'day' }
    case '1m': {
      const since = new Date(now)
      since.setMonth(since.getMonth() - 1)
      return { since, bucketUnit: 'day' }
    }
    case '1y': {
      const since = new Date(now)
      since.setFullYear(since.getFullYear() - 1)
      return { since, bucketUnit: 'month' }
    }
    case '5y': {
      const since = new Date(now)
      since.setFullYear(since.getFullYear() - 5)
      return { since, bucketUnit: 'month' }
    }
  }
}

export class AdminAnalyticsService {
  static async getAnalytics(range: string | undefined) {
    const { since, bucketUnit } = resolveRange(range)

    const [
      kpis,
      newUsers,
      labsCompleted,
      pointsAwarded,
      forumComments,
      pointsDistributionRaw,
      coursesByDifficulty,
      enrollmentsByDifficulty,
      usersByAuthMethod,
      enrollmentsByCourse,
      quizScoreDistributionRaw,
      courseCompletionRaw,
    ] = await Promise.all([
      AdminAnalyticsDAO.getKpis(since),
      AdminAnalyticsDAO.getNewUsersByBucket(since, bucketUnit),
      AdminAnalyticsDAO.getLabsCompletedByBucket(since, bucketUnit),
      AdminAnalyticsDAO.getPointsAwardedByBucket(since, bucketUnit),
      AdminAnalyticsDAO.getForumCommentsByBucket(since, bucketUnit),
      AdminAnalyticsDAO.getPointsDistribution(),
      AdminAnalyticsDAO.getCoursesByDifficulty(),
      AdminAnalyticsDAO.getEnrollmentsByDifficulty(),
      AdminAnalyticsDAO.getUsersByAuthMethod(),
      AdminAnalyticsDAO.getEnrollmentsByCourse(),
      AdminAnalyticsDAO.getQuizScoreDistribution(),
      AdminAnalyticsDAO.getCourseCompletionRaw(),
    ])

    const quizScoreMap = new Map(quizScoreDistributionRaw.map(r => [r.scorePercent, r.count]))
    const quizScoreDistribution = QUIZ_SCORE_VALUES.map(scorePercent => ({
      scorePercent,
      count: quizScoreMap.get(scorePercent) ?? 0,
    }))

    const completionRateByCourse = courseCompletionRaw.map(c => ({
      courseId: c.courseId,
      title: c.title,
      enrolledCount: c.enrolledCount,
      ratePercent: c.enrolledCount > 0 ? Math.round((c.fullyCompletedCount / c.enrolledCount) * 1000) / 10 : 0,
    }))

    return {
      kpis,
      timeSeries: {
        newUsers,
        labsCompleted,
        pointsAwarded,
        forumComments,
      },
      pointsDistribution: [
        { range: '0-100', count: pointsDistributionRaw.rangeLow },
        { range: '100-500', count: pointsDistributionRaw.rangeMid },
        { range: '500-1000', count: pointsDistributionRaw.rangeHigh },
        { range: '1000+', count: pointsDistributionRaw.rangeMax },
      ],
      coursesByDifficulty,
      enrollmentsByDifficulty,
      usersByAuthMethod,
      enrollmentsByCourse,
      quizScoreDistribution,
      completionRateByCourse,
    }
  }
}
