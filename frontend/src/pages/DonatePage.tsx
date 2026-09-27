import { useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import { useToast } from '../context/ToastContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Footer from '../components/Footer'
import PixelHeart from '../components/PixelHeart'

const BREB_KEY = '@3002167247'
const BREB_OWNER = 'Simón Urbina'
const PRESET_AMOUNTS = [5_000, 10_000, 20_000, 50_000]
const MIN_AMOUNT = 2_000
const MAX_AMOUNT = 5_000_000

const formatCop = (n: number) => `$${n.toLocaleString('es-CO')}`

const STEPS = [
  {
    title: 'Eliges cómo donar',
    body: 'La forma recomendada es la llave Bre-B: llega directo y sin comisiones. Si prefieres tarjeta, PSE o Nequi, puedes usar Wompi.',
  },
  {
    title: 'Envías tu aporte',
    body: `Con Bre-B, desde la app de tu banco o billetera envías a la llave ${BREB_KEY} y verificas que el destinatario sea ${BREB_OWNER}. Con Wompi, eliges el monto y te llevamos a su checkout seguro.`,
  },
  {
    title: 'Confirmación',
    body: 'Bre-B te muestra el comprobante al instante en tu app. Con Wompi vuelves a RutSeg a una página que te dice si el pago fue aprobado.',
  },
  {
    title: 'Tu aporte se convierte en RutSeg',
    body: 'Se usa para pagar los servidores (Railway, Vercel, Supabase), la IA de Uchi y el tiempo para crear laboratorios nuevos. RutSeg sigue siendo gratis para todos.',
  },
]

export default function DonatePage() {
  const { theme } = useTheme()
  const { addToast } = useToast()
  const isDark = theme === 'dark'

  const [selected, setSelected] = useState<number | null>(10_000)
  const [custom, setCustom] = useState('')
  const [loading, setLoading] = useState(false)

  const textPrimary = isDark ? '#C8D5EE' : '#0A1545'
  const textSecondary = isDark ? '#7B9FE8' : '#2451C8'
  const muted = isDark ? '#3A5AB8' : '#4A70CC'
  const cardBg = isDark ? 'rgba(13,27,70,0.85)' : '#f8faff'
  const cardBorder = isDark ? 'rgba(26,63,150,0.16)' : 'rgba(26,63,150,0.12)'

  const customAmount = custom ? Number(custom) : null
  const amount = customAmount ?? selected
  const amountValid = amount !== null && amount >= MIN_AMOUNT && amount <= MAX_AMOUNT

  const copyKey = async () => {
    try {
      await navigator.clipboard.writeText(BREB_KEY)
      addToast('Llave Bre-B copiada')
    } catch {
      addToast('No se pudo copiar. Selecciona la llave y cópiala manualmente.', 'error')
    }
  }

  const donateWithWompi = async () => {
    if (!amountValid || amount === null) return
    setLoading(true)
    try {
      const { checkoutUrl } = await api.post<{ checkoutUrl: string }>('/api/donations/checkout', { amount })
      window.location.href = checkoutUrl
    } catch (e) {
      addToast((e as Error).message, 'error')
      setLoading(false)
    }
  }

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: textPrimary }}>
      <Header />

      {/* ─── HERO ─── */}
      <section
        className="relative overflow-hidden border-b"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)',
          background: isDark
            ? 'linear-gradient(180deg, #0D1630 0%, #060D1F 100%)'
            : 'linear-gradient(180deg, #E8EEFA 0%, #EEF3FC 100%)',
        }}
      >
        <div className="relative max-w-4xl mx-auto px-6 lg:px-10 pt-16 pb-20 flex flex-col items-center text-center">
          <div className="mb-8 animate-fade-up-1">
            <PixelHeart size={112} beat />
          </div>
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-5 animate-fade-up-1" style={{ color: muted }}>
            // donar.md
          </p>
          <h1
            className="font-display mb-4 animate-fade-up-2"
            style={{ fontSize: 'clamp(2.2rem, 4.5vw, 3.4rem)', lineHeight: 1.1, letterSpacing: '-0.01em' }}
          >
            ¡Gracias por <span style={{ color: '#FF3D6E' }}>pasar por aquí</span>!
          </h1>
          <p className="text-[16px] font-light max-w-xl animate-fade-up-3" style={{ color: textSecondary, lineHeight: 1.65 }}>
            RutSeg es gratis, en español y sin publicidad, y lo sostengo yo solo. Solo entrar a esta
            página ya significa mucho. Si además quieres aportar, aquí te explico paso a paso qué va a pasar.
          </p>
        </div>
      </section>

      <div className="max-w-4xl mx-auto px-6 lg:px-10 py-16 lg:py-24">

        {/* ─── PASO A PASO ─── */}
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-6" style={{ color: muted }}>
          // paso a paso
        </p>
        <ol className="grid gap-4 sm:grid-cols-2 mb-16">
          {STEPS.map(({ title, body }, i) => (
            <li
              key={title}
              className="rounded-2xl p-6 border"
              style={{ background: cardBg, borderColor: cardBorder }}
            >
              <p className="font-mono text-[12px] mb-2" style={{ color: '#FF3D6E' }}>
                {String(i + 1).padStart(2, '0')}
              </p>
              <p className="font-semibold text-[16px] mb-2">{title}</p>
              <p className="text-[14px] font-light leading-relaxed" style={{ color: textSecondary }}>{body}</p>
            </li>
          ))}
        </ol>

        {/* ─── OPCIÓN 1: BRE-B ─── */}
        <div className="flex flex-wrap items-center gap-x-3 gap-y-2 mb-4">
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase" style={{ color: muted }}>
            // opción 1 — llave bre-b
          </p>
          <span
            className="font-mono text-[10px] tracking-[0.12em] uppercase px-2 py-0.5 rounded"
            style={{ color: '#22c55e', background: 'rgba(34,197,94,0.10)', border: '1px solid rgba(34,197,94,0.25)' }}
          >
            Recomendada · sin comisión
          </span>
        </div>
        <div
          className="hud-panel hud-static p-6 sm:p-8 mb-12"
          style={{
            background: isDark ? 'rgba(255,61,110,0.06)' : 'rgba(255,61,110,0.04)',
            '--hud-border': 'rgba(255,61,110,0.35)',
            '--hud-border-hover': 'rgba(255,61,110,0.35)',
          } as React.CSSProperties}
        >
          <p className="text-[14px] font-light mb-5" style={{ color: textSecondary }}>
            Abre la app de tu banco o billetera, busca <strong>Enviar con llave Bre-B</strong> e ingresa esta llave.
            Antes de confirmar, verifica que aparezca <strong>{BREB_OWNER}</strong> como destinatario.
          </p>
          <div className="flex flex-col sm:flex-row sm:items-center gap-4">
            <div
              className="flex-1 rounded-xl px-5 py-4 border font-mono text-[22px] font-semibold select-all break-all"
              style={{ background: cardBg, borderColor: cardBorder, color: textPrimary }}
            >
              {BREB_KEY}
            </div>
            <button onClick={copyKey} className="btn-neon px-6 py-3.5 text-[14px] font-semibold" style={{ borderRadius: '9999px' }}>
              Copiar llave
            </button>
          </div>
          <p className="font-mono text-[12px] mt-4" style={{ color: muted }}>
            Titular: {BREB_OWNER} · Monto: el que tú quieras
          </p>
        </div>

        {/* ─── OPCIÓN 2: WOMPI ─── */}
        <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4" style={{ color: muted }}>
          // opción 2 — tarjeta, pse o nequi con wompi
        </p>
        <div className="rounded-2xl p-6 sm:p-8 border mb-12" style={{ background: cardBg, borderColor: cardBorder }}>
          <p className="text-[14px] font-light mb-5" style={{ color: textSecondary }}>
            Elige un monto y te llevamos al checkout de Wompi. Tus datos de pago los maneja Wompi
            directamente; RutSeg nunca ve ni guarda tu tarjeta.
          </p>

          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mb-4">
            {PRESET_AMOUNTS.map(value => {
              const active = !custom && selected === value
              return (
                <button
                  key={value}
                  onClick={() => { setSelected(value); setCustom('') }}
                  aria-pressed={active}
                  className="rounded-xl py-3 font-mono text-[15px] font-semibold border transition-colors"
                  style={{
                    background: active ? 'rgba(255,61,110,0.12)' : 'transparent',
                    borderColor: active ? '#FF3D6E' : cardBorder,
                    color: active ? '#FF3D6E' : textPrimary,
                  }}
                >
                  {formatCop(value)}
                </button>
              )
            })}
          </div>

          <label className="block font-mono text-[11px] tracking-[0.12em] uppercase mb-2" style={{ color: muted }} htmlFor="custom-amount">
            Otro monto (COP)
          </label>
          <input
            id="custom-amount"
            type="text"
            inputMode="numeric"
            placeholder="Ej: 15000"
            value={custom}
            onChange={e => setCustom(e.target.value.replace(/\D/g, '').slice(0, 7))}
            className="w-full rounded-xl px-4 py-3 border font-mono text-[15px] mb-2 outline-none"
            style={{ background: 'transparent', borderColor: cardBorder, color: textPrimary }}
          />
          <p className="text-[12px] mb-6" style={{ color: amount !== null && !amountValid ? '#ef4444' : muted }}>
            Mínimo {formatCop(MIN_AMOUNT)} · máximo {formatCop(MAX_AMOUNT)}
          </p>

          <button
            onClick={donateWithWompi}
            disabled={!amountValid || loading}
            className="btn-neon w-full sm:w-auto px-8 py-3.5 text-[15px] font-semibold"
            style={{ borderRadius: '9999px' }}
          >
            {loading ? 'Abriendo Wompi…' : amountValid && amount !== null ? `Donar ${formatCop(amount)} con Wompi` : 'Donar con Wompi'}
          </button>
        </div>

        {/* ─── TRANSPARENCIA ─── */}
        <div
          className="hud-panel hud-static px-7 py-6"
          style={{
            background: isDark ? 'rgba(37,150,190,0.07)' : 'rgba(37,150,190,0.05)',
            '--hud-border': 'rgba(37,150,190,0.35)',
            '--hud-border-hover': 'rgba(37,150,190,0.35)',
          } as React.CSSProperties}
        >
          <p className="font-mono text-[10px] tracking-[0.2em] uppercase mb-2" style={{ color: '#2596be' }}>// transparencia</p>
          <p className="text-[14px] leading-relaxed" style={{ color: isDark ? '#93B0F0' : '#1A3F96' }}>
            Las donaciones las recibe {BREB_OWNER} como persona natural para cubrir los costos de RutSeg.
            Son voluntarias, no dan beneficios dentro de la plataforma (puntos, certificados ni ranking) y no
            son deducibles de impuestos.
          </p>
        </div>
      </div>

      <Footer />
    </div>
  )
}
