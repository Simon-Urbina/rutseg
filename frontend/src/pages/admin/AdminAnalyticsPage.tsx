import { useEffect, useState } from 'react'
import { useTheme } from '../../context/ThemeContext'
import { adminApi, type AdminAnalytics, type AnalyticsRange } from '../../lib/adminApi'
import { ErrorBanner } from './AdminFormControls'
import { PageShell, Breadcrumb } from './AdminCourseDetailPage'
import { TimeSeriesAreaChart, CategoryBarChart, RankedHorizontalBarChart, VALIDATED_CHART_PALETTE } from './AdminAnalyticsCharts'

// Los tipos `Analytics*` de adminApi.ts son `interface`s sin índice de firma, mientras
// que los props `data` de los componentes de gráfica exigen un índice de firma
// (`[key: string]: number | string`) para poder indexar por `dataKey`/`xKey`/`yKey`
// dinámicos. Estructuralmente los datos ya cumplen la forma requerida en runtime —
// estos helpers solo relajan el tipo estático en el límite página↔gráfica, sin tocar
// ninguno de los dos archivos de origen.
type BucketDatum = { bucket: string; [key: string]: number | string }
type CategoryDatum = Record<string, string | number>

function asBucketData<T extends { bucket: string }>(arr: T[]): BucketDatum[] {
  return arr as unknown as BucketDatum[]
}

function asCategoryData<T extends object>(arr: T[]): CategoryDatum[] {
  return arr as unknown as CategoryDatum[]
}

const RANGE_OPTIONS: { value: AnalyticsRange; label: string }[] = [
  { value: '7d', label: '7 días' },
  { value: '1m', label: '1 mes' },
  { value: '1y', label: '1 año' },
  { value: '5y', label: '5 años' },
]

const DIFFICULTY_COLORS: Record<string, string> = {
  principiante: VALIDATED_CHART_PALETTE.cian,
  intermedio: VALIDATED_CHART_PALETTE.oro,
  avanzado: VALIDATED_CHART_PALETTE.azul,
}

const AUTH_METHOD_COLORS: Record<string, string> = {
  password: VALIDATED_CHART_PALETTE.grisAzulado,
  google: VALIDATED_CHART_PALETTE.cian,
  microsoft: VALIDATED_CHART_PALETTE.morado,
}

function KpiTile({ isDark, label, value }: { isDark: boolean; label: string; value: number }) {
  return (
    <div
      className="hud-panel px-5 py-4"
      style={{
        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
        '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      } as React.CSSProperties}
    >
      <p className="font-mono text-[10px] tracking-[0.14em] uppercase mb-1" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
        {label}
      </p>
      <p className="font-display" style={{ fontSize: '1.6rem', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        {value.toLocaleString('es-CO')}
      </p>
    </div>
  )
}

export default function AdminAnalyticsPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const [range, setRange] = useState<AnalyticsRange>('1m')
  const [data, setData] = useState<AdminAnalytics | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    setLoading(true)
    setError('')
    adminApi.getAnalytics(range)
      .then(setData)
      .catch(err => setError(err.message))
      .finally(() => setLoading(false))
  }, [range])

  return (
    <PageShell isDark={isDark}>
      <Breadcrumb isDark={isDark} items={[{ label: 'Panel', to: '/admin' }, { label: 'Estadísticas' }]} />

      <h1 className="font-display mt-6 mb-8" style={{ fontSize: 'clamp(1.8rem, 3vw, 2.4rem)', color: isDark ? '#C8D5EE' : '#0A1545' }}>
        Estadísticas de la plataforma
      </h1>

      {error && <div className="mb-6"><ErrorBanner message={error} isDark={isDark} /></div>}

      {loading && !data && (
        <p className="text-[14px]" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>Cargando…</p>
      )}

      {data && (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
            <KpiTile isDark={isDark} label="Usuarios totales" value={data.kpis.totalUsers} />
            <KpiTile isDark={isDark} label="Nuevos en el rango" value={data.kpis.newUsersInRange} />
            <KpiTile isDark={isDark} label="Puntos otorgados" value={data.kpis.totalPointsAwarded} />
            <KpiTile isDark={isDark} label="Labs completados" value={data.kpis.labsCompletedInRange} />
          </div>

          <div className="flex items-center justify-between flex-wrap gap-4 mb-6">
            <h2 className="font-mono text-[11px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
              // actividad en el tiempo
            </h2>
            <div className="flex gap-2">
              {RANGE_OPTIONS.map(opt => (
                <button
                  key={opt.value}
                  onClick={() => setRange(opt.value)}
                  className={opt.value === range ? 'btn-neon px-4 py-2 rounded-lg text-[13px]' : 'btn-ghost-light px-4 py-2 rounded-lg text-[13px]'}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
            <TimeSeriesAreaChart isDark={isDark} title="Registros de usuarios nuevos" data={asBucketData(data.timeSeries.newUsers)} dataKey="count" color={VALIDATED_CHART_PALETTE.cian} />
            <TimeSeriesAreaChart isDark={isDark} title="Laboratorios completados" data={asBucketData(data.timeSeries.labsCompleted)} dataKey="count" color={VALIDATED_CHART_PALETTE.azul} />
            <TimeSeriesAreaChart isDark={isDark} title="Puntos otorgados" data={asBucketData(data.timeSeries.pointsAwarded)} dataKey="points" color={VALIDATED_CHART_PALETTE.oro} />
            <TimeSeriesAreaChart isDark={isDark} title="Comentarios del foro" data={asBucketData(data.timeSeries.forumComments)} dataKey="count" color={VALIDATED_CHART_PALETTE.morado} />
          </div>

          <h2 className="font-mono text-[11px] tracking-[0.18em] uppercase mb-6" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // estado actual
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <CategoryBarChart isDark={isDark} title="Distribución de puntos entre usuarios" data={asCategoryData(data.pointsDistribution)} xKey="range" yKey="count" defaultColor={VALIDATED_CHART_PALETTE.cian} />
            <CategoryBarChart isDark={isDark} title="Cursos por dificultad" data={asCategoryData(data.coursesByDifficulty)} xKey="difficulty" yKey="count" colorMap={DIFFICULTY_COLORS} defaultColor={VALIDATED_CHART_PALETTE.cian} />
            <CategoryBarChart isDark={isDark} title="Usuarios inscritos por dificultad" data={asCategoryData(data.enrollmentsByDifficulty)} xKey="difficulty" yKey="count" colorMap={DIFFICULTY_COLORS} defaultColor={VALIDATED_CHART_PALETTE.cian} />
            <CategoryBarChart isDark={isDark} title="Usuarios registrados por método" data={asCategoryData(data.usersByAuthMethod)} xKey="method" yKey="count" colorMap={AUTH_METHOD_COLORS} defaultColor={VALIDATED_CHART_PALETTE.grisAzulado} />
            <CategoryBarChart
              isDark={isDark}
              title="Distribución de puntajes de quiz"
              data={asCategoryData(data.quizScoreDistribution.map(q => ({ scorePercent: `${q.scorePercent}%`, count: q.count })))}
              xKey="scorePercent"
              yKey="count"
              defaultColor={VALIDATED_CHART_PALETTE.cian}
            />
            <RankedHorizontalBarChart isDark={isDark} title="Cursos por matrícula" data={asCategoryData(data.enrollmentsByCourse)} xKey="title" yKey="enrollments" color={VALIDATED_CHART_PALETTE.azul} />
            <RankedHorizontalBarChart
              isDark={isDark}
              title="Tasa de finalización por curso"
              data={asCategoryData(data.completionRateByCourse)}
              xKey="title"
              yKey="ratePercent"
              color={VALIDATED_CHART_PALETTE.oro}
              valueFormatter={v => `${v}%`}
            />
          </div>
        </>
      )}
    </PageShell>
  )
}
