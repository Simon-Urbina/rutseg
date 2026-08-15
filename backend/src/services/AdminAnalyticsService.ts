import { AdminAnalyticsDAO, type AnalyticsRange, type BucketUnit } from '../daos/AdminAnalyticsDAO.js'
import { BadRequestError } from '../utils/errors.js'

const VALID_RANGES: AnalyticsRange[] = ['7d', '1m', '1y', '5y']
const QUIZ_SCORE_VALUES = [0, 20, 40, 60, 80, 100] as const

// El pool de conexiones (backend/src/db/index.ts) es compartido por toda la
// app — este endpoint no debe asumir que tiene 12 conexiones libres para sí
// solo. Corre las 12 queries en tandas de a 4 en vez de las 12 a la vez, para
// que varios admins puedan cargar la página al mismo tiempo sin saturar el
// pool, y aplica un timeout duro para que, si algo sí se cuelga, la petición
// falle rápido con un 500 (Hono conserva el header CORS incluso en la
// respuesta de error) en vez de quedarse colgada hasta que el navegador la
// reporte como error de CORS.
const CHUNK_SIZE = 4
const TIMEOUT_MS = 15_000

async function runChunked<T extends readonly unknown[]>(
  thunks: readonly [...{ [K in keyof T]: () => Promise<T[K]> }],
  chunkSize: number,
): Promise<T> {
  const results: unknown[] = []
  for (let i = 0; i < thunks.length; i += chunkSize) {
    const chunk = thunks.slice(i, i + chunkSize)
    results.push(...await Promise.all(chunk.map(fn => fn())))
  }
  return results as unknown as T
}

function withTimeout<T>(promise: Promise<T>, ms: number, message: string): Promise<T> {
  let timer: ReturnType<typeof setTimeout>
  const timeout = new Promise<never>((_, reject) => {
    timer = setTimeout(() => reject(new Error(message)), ms)
  })
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer))
}

function truncateToBucket(date: Date, bucketUnit: BucketUnit): Date {
  const d = new Date(date)
  if (bucketUnit === 'month') d.setUTCDate(1)
  d.setUTCHours(0, 0, 0, 0)
  return d
}

function resolveRange(range: string | undefined): { since: Date; bucketUnit: BucketUnit } {
  if (!range || !VALID_RANGES.includes(range as AnalyticsRange)) {
    throw new BadRequestError(`Rango inválido. Usa uno de: ${VALID_RANGES.join(', ')}.`)
  }
  const now = new Date()
  const { since, bucketUnit } = ((): { since: Date; bucketUnit: BucketUnit } => {
    switch (range as AnalyticsRange) {
      case '7d':
        return { since: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000), bucketUnit: 'day' }
      case '1m': {
        const s = new Date(now)
        s.setMonth(s.getMonth() - 1)
        return { since: s, bucketUnit: 'day' }
      }
      case '1y': {
        const s = new Date(now)
        s.setFullYear(s.getFullYear() - 1)
        return { since: s, bucketUnit: 'month' }
      }
      case '5y': {
        const s = new Date(now)
        s.setFullYear(s.getFullYear() - 5)
        return { since: s, bucketUnit: 'month' }
      }
    }
  })()
  // Trunca `since` al inicio de su bucket — si no, el primer bucket de cada
  // gráfica de serie de tiempo queda parcial (ej. medio día, o medio mes),
  // mostrando una caída falsa al inicio de la gráfica que no refleja actividad
  // real. También hace que el KPI "nuevos en el rango" cuente exactamente el
  // mismo período que el primer bucket de su gráfica.
  return { since: truncateToBucket(since, bucketUnit), bucketUnit }
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
    ] = await withTimeout(
      runChunked(
        [
          () => AdminAnalyticsDAO.getKpis(since),
          () => AdminAnalyticsDAO.getNewUsersByBucket(since, bucketUnit),
          () => AdminAnalyticsDAO.getLabsCompletedByBucket(since, bucketUnit),
          () => AdminAnalyticsDAO.getPointsAwardedByBucket(since, bucketUnit),
          () => AdminAnalyticsDAO.getForumCommentsByBucket(since, bucketUnit),
          () => AdminAnalyticsDAO.getPointsDistribution(),
          () => AdminAnalyticsDAO.getCoursesByDifficulty(),
          () => AdminAnalyticsDAO.getEnrollmentsByDifficulty(),
          () => AdminAnalyticsDAO.getUsersByAuthMethod(),
          () => AdminAnalyticsDAO.getEnrollmentsByCourse(),
          () => AdminAnalyticsDAO.getQuizScoreDistribution(),
          () => AdminAnalyticsDAO.getCourseCompletionRaw(),
        ] as const,
        CHUNK_SIZE,
      ),
      TIMEOUT_MS,
      'La consulta de analíticas tardó demasiado. Intenta de nuevo.',
    )

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
