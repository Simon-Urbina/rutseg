import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import { api } from '../lib/api'
import Header from '../components/Header'
import Footer from '../components/Footer'
import PixelHeart from '../components/PixelHeart'

type WompiStatus = 'APPROVED' | 'PENDING' | 'DECLINED' | 'VOIDED' | 'ERROR'

const MESSAGES: Record<WompiStatus | 'UNKNOWN', { title: string; body: string; ok: boolean }> = {
  APPROVED: { title: '¡Donación recibida!', body: 'Muchas gracias por apoyar RutSeg. Tu aporte ayuda a mantener la plataforma gratis para todos.', ok: true },
  PENDING:  { title: 'Tu pago está en proceso', body: 'Wompi todavía está confirmando la transacción (pasa a veces con PSE). Te llegará el resultado por correo.', ok: true },
  DECLINED: { title: 'El pago no se completó', body: 'Tu banco o Wompi rechazó la transacción y no se hizo ningún cobro. Puedes intentarlo de nuevo o usar la llave Bre-B.', ok: false },
  VOIDED:   { title: 'El pago fue anulado', body: 'La transacción se anuló y no se hizo ningún cobro.', ok: false },
  ERROR:    { title: 'Hubo un error con el pago', body: 'No se hizo ningún cobro. Puedes intentarlo de nuevo o usar la llave Bre-B.', ok: false },
  UNKNOWN:  { title: 'No pudimos confirmar tu donación', body: 'Si Wompi te mostró el pago como aprobado, revisa el correo que te enviaron: ese es tu comprobante.', ok: false },
}

export default function DonationResultPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const [params] = useSearchParams()
  const transactionId = params.get('id')

  const [status, setStatus] = useState<WompiStatus | 'UNKNOWN' | null>(transactionId ? null : 'UNKNOWN')
  const [amountCop, setAmountCop] = useState<number | null>(null)

  useEffect(() => {
    if (!transactionId) return
    api.get<{ status: WompiStatus; amountCop: number }>(`/api/donations/status/${encodeURIComponent(transactionId)}`)
      .then(res => {
        setStatus(res.status in MESSAGES ? res.status : 'UNKNOWN')
        setAmountCop(res.amountCop)
      })
      .catch(() => setStatus('UNKNOWN'))
  }, [transactionId])

  const textPrimary = isDark ? '#C8D5EE' : '#0A1545'
  const textSecondary = isDark ? '#7B9FE8' : '#2451C8'
  const msg = status ? MESSAGES[status] : null

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC', color: textPrimary }}>
      <Header />
      <section className="max-w-2xl mx-auto px-6 py-24 flex flex-col items-center text-center min-h-[70vh]">
        {!msg ? (
          <p className="font-mono text-[13px]" style={{ color: textSecondary }}>Consultando tu donación…</p>
        ) : (
          <>
            <div className="mb-8" style={{ opacity: msg.ok ? 1 : 0.45, filter: msg.ok ? undefined : 'grayscale(0.6)' }}>
              <PixelHeart size={112} beat={status === 'APPROVED'} />
            </div>
            <h1 className="font-display mb-4" style={{ fontSize: 'clamp(2rem, 4vw, 3rem)', lineHeight: 1.1 }}>
              {msg.title}
            </h1>
            {status === 'APPROVED' && amountCop !== null && (
              <p className="font-mono text-[15px] mb-4" style={{ color: '#FF3D6E' }}>
                ${amountCop.toLocaleString('es-CO')} COP
              </p>
            )}
            <p className="text-[16px] font-light mb-10" style={{ color: textSecondary, lineHeight: 1.65 }}>
              {msg.body}
            </p>
            <div className="flex flex-wrap justify-center gap-3">
              {!msg.ok && (
                <Link to="/donar" className="btn-neon px-6 py-3 text-[14px] font-semibold" style={{ borderRadius: '9999px' }}>
                  Volver a donaciones
                </Link>
              )}
              <Link
                to="/"
                className="px-6 py-3 text-[14px] font-semibold rounded-full border"
                style={{ borderColor: isDark ? 'rgba(26,63,150,0.35)' : 'rgba(26,63,150,0.25)', color: textSecondary }}
              >
                Ir al inicio
              </Link>
            </div>
          </>
        )}
      </section>
      <Footer />
    </div>
  )
}
