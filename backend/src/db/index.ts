import postgres from 'postgres'

const DATABASE_URL = process.env.DATABASE_URL
if (!DATABASE_URL) throw new Error('DATABASE_URL is required')

const isPooler = DATABASE_URL.includes('.pooler.supabase.com')

const sql = postgres(DATABASE_URL, {
  transform: {
    column: {
      from: (name: string) => name.replace(/_([a-z])/g, (_, c: string) => c.toUpperCase()),
    },
    undefined: null,
  },
  ssl: DATABASE_URL.includes('supabase.co') ? { rejectUnauthorized: false } : false,
  prepare: !isPooler,
  // AdminAnalyticsService dispara 12 queries concurrentes por carga de página
  // (Promise.all) — con max:10 el pool se queda sin conexiones libres para las
  // últimas 2 y la petición se cuelga indefinidamente en vez de fallar rápido.
  // Verificado: max:15 resuelve el cuelgue en tandas sucesivas contra la misma DB.
  max: 20,
  idle_timeout: 20,
})

export default sql
