import type { CSSProperties, ReactNode } from 'react'
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell,
} from 'recharts'

/**
 * Paleta categórica para las gráficas del panel de analíticas, validada con la
 * skill `dataviz` (node scripts/validate_palette.js) contra los dos tokens de
 * fondo de card usados en RutSeg — rgba(13,27,70,0.85) oscuro (compuesto sobre
 * el fondo de página #060D1F ≈ #0C1940 opaco) y #f8faff claro — en modo claro
 * y oscuro, con el modo de validación "adjacent" (el correcto para
 * bar/area/stacked charts, según la skill).
 *
 * Dos colores no pasaron la validación tal cual estaban y dos SÍ:
 *   - cian            #2596be  (teal-500)    → sin cambios, PASS
 *   - azul            #2451C8  (rosewood-400) → cambiado desde #1A3F96: el
 *     original tenía L=0.398 (OKLCH), fuera de la banda de luminosidad
 *     [0.48–0.67] compartida por ambos modos, y contraste 1.79:1 contra el
 *     fondo oscuro (< 3:1). rosewood-400 ya se usa en RutSeg (p. ej. como
 *     AXIS_COLOR_LIGHT más abajo) y sí pasa.
 *   - oro             #998000  (gold-700)    → cambiado desde #F5C500: el
 *     original tenía L=0.842, también fuera de banda, y contraste 1.56:1
 *     contra el fondo claro. gold-700 ya se usa en RutSeg como el tono de oro
 *     legible sobre fondos claros (p. ej. CourseCard, LabPage) y sí pasa.
 *   - morado          #8a5cf6              → sin cambios, PASS
 *   - gris-azulado    #3A5AB8  (violet-600) → cambiado desde #4A70CC: el par
 *     gris-azulado↔morado tenía ΔE 11.8 en OKLab bajo visión normal, por
 *     debajo del piso de 15 (imposible de distinguir incluso con visión de
 *     color normal). violet-600 ya se usa en RutSeg como la variante oscura
 *     de #4A70CC (patrón `isDark ? '#3A5AB8' : '#4A70CC'` repetido en toda la
 *     app) y separa el par a ΔE 15.1.
 *
 * Con esos tres cambios, `validate_palette.js` reporta:
 *   node scripts/validate_palette.js "#2596be,#2451C8,#998000,#8a5cf6,#3A5AB8" --mode light --surface "#f8faff"
 *   node scripts/validate_palette.js "#2596be,#2451C8,#998000,#8a5cf6,#3A5AB8" --mode dark  --surface "#0C1940"
 * → ALL CHECKS PASS en ambos modos (exit 0). En modo oscuro persiste un WARN
 * de contraste (no bloqueante) en azul y gris-azulado, ~2.5–2.7:1 contra el
 * fondo oscuro; la skill documenta ese WARN como legal si hay codificación
 * secundaria (tooltip + etiquetas de eje), que estos componentes ya proveen.
 *
 * Los componentes de este archivo son puramente de presentación y no
 * hardcodean estos valores — quien los use (Task 8) debe pasar esta paleta
 * corregida vía las props `color` / `colorMap` / `defaultColor`.
 */
export const VALIDATED_CHART_PALETTE = {
  cian: '#2596be',
  azul: '#2451C8',
  oro: '#998000',
  morado: '#8a5cf6',
  grisAzulado: '#3A5AB8',
} as const

const AXIS_COLOR_DARK = '#4A70CC'
const AXIS_COLOR_LIGHT = '#2451C8'
const GRID_COLOR_DARK = 'rgba(74,112,204,0.15)'
const GRID_COLOR_LIGHT = 'rgba(26,63,150,0.12)'

function tooltipStyle(isDark: boolean) {
  return {
    contentStyle: {
      background: isDark ? '#0D1B46' : '#ffffff',
      border: `1px solid ${isDark ? 'rgba(26,63,150,0.3)' : 'rgba(26,63,150,0.2)'}`,
      borderRadius: 8,
      fontSize: 12,
    },
    labelStyle: { color: isDark ? '#C8D5EE' : '#0A1545' },
  }
}

function ChartCard({ isDark, title, children }: { isDark: boolean; title: string; children: ReactNode }) {
  return (
    <div
      className="hud-panel p-6"
      style={{
        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
        '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
      } as CSSProperties}
    >
      <h3 className="font-mono text-[11px] tracking-[0.16em] uppercase mb-4" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
        {title}
      </h3>
      {children}
    </div>
  )
}

export function TimeSeriesAreaChart({
  isDark, title, data, dataKey, color,
}: {
  isDark: boolean
  title: string
  data: { bucket: string; [key: string]: number | string }[]
  dataKey: string
  color: string
}) {
  const formatted = data.map(d => ({
    ...d,
    bucket: new Date(d.bucket as string).toLocaleDateString('es-CO', { day: '2-digit', month: 'short' }),
  }))
  return (
    <ChartCard isDark={isDark} title={title}>
      <ResponsiveContainer width="100%" height={220}>
        <AreaChart data={formatted} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
          <defs>
            <linearGradient id={`gradient-${dataKey}`} x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor={color} stopOpacity={0.4} />
              <stop offset="95%" stopColor={color} stopOpacity={0} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke={isDark ? GRID_COLOR_DARK : GRID_COLOR_LIGHT} vertical={false} />
          <XAxis dataKey="bucket" tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }} axisLine={false} tickLine={false} allowDecimals={false} />
          <Tooltip {...tooltipStyle(isDark)} />
          <Area
            type="monotone"
            dataKey={dataKey}
            stroke={color}
            fill={`url(#gradient-${dataKey})`}
            strokeWidth={2}
            animationDuration={700}
            animationEasing="ease-out"
          />
        </AreaChart>
      </ResponsiveContainer>
    </ChartCard>
  )
}

export function CategoryBarChart({
  isDark, title, data, xKey, yKey, colorMap, defaultColor,
}: {
  isDark: boolean
  title: string
  data: Record<string, string | number>[]
  xKey: string
  yKey: string
  colorMap?: Record<string, string>
  defaultColor: string
}) {
  return (
    <ChartCard isDark={isDark} title={title}>
      <ResponsiveContainer width="100%" height={220}>
        <BarChart data={data} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke={isDark ? GRID_COLOR_DARK : GRID_COLOR_LIGHT} vertical={false} />
          <XAxis dataKey={xKey} tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }} axisLine={false} tickLine={false} />
          <YAxis tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }} axisLine={false} tickLine={false} allowDecimals={false} />
          <Tooltip {...tooltipStyle(isDark)} />
          <Bar dataKey={yKey} radius={[6, 6, 0, 0]} animationDuration={700} animationEasing="ease-out">
            {data.map((entry, i) => (
              <Cell key={i} fill={(colorMap && colorMap[String(entry[xKey])]) || defaultColor} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </ChartCard>
  )
}

export function RankedHorizontalBarChart({
  isDark, title, data, xKey, yKey, color, valueFormatter,
}: {
  isDark: boolean
  title: string
  data: Record<string, string | number>[]
  xKey: string
  yKey: string
  color: string
  valueFormatter?: (value: number) => string
}) {
  const height = Math.max(120, data.length * 36)
  return (
    <ChartCard isDark={isDark} title={title}>
      <ResponsiveContainer width="100%" height={height}>
        <BarChart data={data} layout="vertical" margin={{ top: 4, right: 24, left: 8, bottom: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke={isDark ? GRID_COLOR_DARK : GRID_COLOR_LIGHT} horizontal={false} />
          <XAxis type="number" tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }} axisLine={false} tickLine={false} allowDecimals={false} />
          <YAxis
            type="category"
            dataKey={xKey}
            tick={{ fill: isDark ? AXIS_COLOR_DARK : AXIS_COLOR_LIGHT, fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            width={140}
          />
          <Tooltip
            {...tooltipStyle(isDark)}
            formatter={(value) => (valueFormatter && typeof value === 'number' ? valueFormatter(value) : value)}
          />
          <Bar dataKey={yKey} fill={color} radius={[0, 6, 6, 0]} animationDuration={700} animationEasing="ease-out" />
        </BarChart>
      </ResponsiveContainer>
    </ChartCard>
  )
}
