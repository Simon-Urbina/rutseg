import type { Context } from 'hono'
import { AdminAnalyticsService } from '../services/AdminAnalyticsService.js'

export class AdminAnalyticsController {
  static async get(c: Context) {
    const range = c.req.query('range')
    return c.json(await AdminAnalyticsService.getAnalytics(range))
  }
}
