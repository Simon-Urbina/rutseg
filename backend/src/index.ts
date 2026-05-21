import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { AppError, NotFoundError, UnauthorizedError, ForbiddenError, ConflictError, ValidationError } from './utils/errors.js'
import authRoutes from './routes/auth.js'
import userRoutes from './routes/users.js'
import courseRoutes from './routes/courses.js'
import activityRoutes from './routes/activities.js'
import submissionRoutes from './routes/submissions.js'
import rankingRoutes from './routes/ranking.js'
import adminRoutes from './routes/admin.js'
import statsRoutes from './routes/stats.js'
import forumRoutes from './routes/forum.js'

const app = new Hono()

const allowedOrigins = (process.env.FRONTEND_URL ?? 'http://localhost:5173')
  .split(',')
  .map((s) => s.trim())

app.use(
  '*',
  cors({
    origin: (origin) => {
      if (allowedOrigins.includes(origin)) return origin
      if (/^https:\/\/rutseg[^.]*\.vercel\.app$/.test(origin)) return origin
      return null
    },
    allowMethods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
  }),
)

app.route('/api/auth', authRoutes)
app.route('/api/users', userRoutes)
app.route('/api/courses', courseRoutes)
app.route('/api/activities', activityRoutes)
app.route('/api', submissionRoutes)          // → /api/labs/:labId/submit
app.route('/api/ranking', rankingRoutes)
app.route('/api/admin', adminRoutes)
app.route('/api/stats', statsRoutes)
app.route('/api/forum', forumRoutes)

app.get('/health', (c) => c.json({ status: 'ok' }))

app.onError((err, c) => {
  if (err instanceof NotFoundError)     return c.json({ error: err.message }, 404)
  if (err instanceof UnauthorizedError) return c.json({ error: err.message }, 401)
  if (err instanceof ForbiddenError)    return c.json({ error: err.message }, 403)
  if (err instanceof ConflictError)     return c.json({ error: err.message }, 409)
  if (err instanceof ValidationError)   return c.json({ error: err.message }, 400)
  if (err instanceof AppError)          return c.json({ error: err.message }, 400)
  console.error(err)
  return c.json({ error: 'Error interno del servidor.' }, 500)
})

app.notFound((c) => c.json({ error: 'Ruta no encontrada.' }, 404))

export default {
  port: Number(process.env.PORT ?? 3000),
  fetch: app.fetch,
}
