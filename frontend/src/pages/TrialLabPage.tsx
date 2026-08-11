import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useTheme } from '../context/ThemeContext'
import Header from '../components/Header'
import Footer from '../components/Footer'

// Laboratorio de prueba 100% estático — sin backend, sin base de datos, sin login.
// Pensado como gancho de marketing: cualquier visitante lo completa sin fricción
// y termina viendo el botón de registro.

interface DemoQuestion {
  question: string
  options: string[]
  correctIndex: number
  explanation: string
}

const QUESTIONS: DemoQuestion[] = [
  {
    question: '¿Qué es el "phishing"?',
    options: [
      'Un correo o mensaje falso que se hace pasar por alguien de confianza para robar tus datos',
      'Un tipo de virus que borra archivos del computador',
      'Una técnica para tener internet más rápido',
      'Un programa antivirus gratuito',
    ],
    correctIndex: 0,
    explanation: 'El phishing engaña a la víctima haciéndose pasar por un banco, una empresa o un contacto conocido, para que entregue contraseñas o datos personales.',
  },
  {
    question: '¿Cuál de estas es la contraseña más segura?',
    options: ['123456', 'contraseña', 'R3d#Luna_2026!', 'tu propio nombre'],
    correctIndex: 2,
    explanation: 'Una buena contraseña combina mayúsculas, minúsculas, números y símbolos, y no es un dato obvio ni fácil de adivinar.',
  },
  {
    question: 'Te llega un correo de tu "banco" pidiendo que hagas clic en un enlace para "verificar tu cuenta" o la bloquearán. ¿Qué haces?',
    options: [
      'Haces clic de inmediato porque suena urgente',
      'No haces clic; entras a la página oficial del banco escribiendo tú mismo la dirección',
      'Respondes el correo con tu usuario y contraseña',
      'Reenvías el correo a tus contactos para avisarles',
    ],
    correctIndex: 1,
    explanation: 'Los bancos reales no piden contraseñas por correo. Ante la duda, entra siempre escribiendo tú mismo la dirección oficial, nunca desde un enlace recibido.',
  },
  {
    question: '¿Qué indica el ícono de candado que aparece junto a la dirección de una página web?',
    options: [
      'Que la conexión con esa página está cifrada (HTTPS)',
      'Que la página es 100% segura y confiable',
      'Que nadie puede hackear esa página',
      'Que la página es gratuita',
    ],
    correctIndex: 0,
    explanation: 'El candado solo indica que la conexión va cifrada — protege los datos en tránsito, pero no garantiza que el sitio en sí sea confiable.',
  },
  {
    question: '¿Para qué sirve la verificación en dos pasos (2FA)?',
    options: [
      'Para tener dos contraseñas exactamente iguales',
      'Agrega una segunda prueba de identidad, además de la contraseña, para dificultar el acceso a un atacante',
      'Para que la página cargue más rápido',
      'Solo la usan los bancos, ningún otro sitio',
    ],
    correctIndex: 1,
    explanation: 'Aunque un atacante consiga tu contraseña, sin el segundo factor (como un código en tu teléfono) no podrá entrar a tu cuenta.',
  },
]

export default function TrialLabPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const [started, setStarted] = useState(false)
  const [step, setStep] = useState(0)
  const [selected, setSelected] = useState<number | null>(null)
  const [checked, setChecked] = useState(false)
  const [score, setScore] = useState(0)
  const [finished, setFinished] = useState(false)

  const textMain = isDark ? '#C8D5EE' : '#0A1545'
  const textSub = isDark ? '#7B9FE8' : '#2451C8'
  const textMuted = isDark ? '#3A5AB8' : '#4A70CC'
  const correctColor = isDark ? '#4ade80' : '#2E7D46'
  const wrongColor = isDark ? '#f87171' : '#B23B3B'

  const question = QUESTIONS[step]
  const isLast = step === QUESTIONS.length - 1

  const handleCheck = () => {
    if (selected === null || checked) return
    setChecked(true)
    if (selected === question.correctIndex) setScore(s => s + 1)
  }

  const handleNext = () => {
    if (isLast) { setFinished(true); return }
    setStep(s => s + 1)
    setSelected(null)
    setChecked(false)
  }

  const handleRestart = () => {
    setStarted(false)
    setStep(0)
    setSelected(null)
    setChecked(false)
    setScore(0)
    setFinished(false)
  }

  return (
    <div className="min-h-screen flex flex-col" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <Header />

      <main className="flex-1 max-w-2xl mx-auto w-full px-6 py-12 sm:py-16">
        <p
          className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4 text-center"
          style={{ color: textMuted }}
        >
          // laboratorio de prueba · sin registro
        </p>

        {/* ── Intro ── */}
        {!started && (
          <div className="hud-panel hud-static p-7 sm:p-10 animate-fade-up-1"
            style={{
              background: isDark ? 'rgba(13,27,70,0.55)' : '#f8faff',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
              '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
            } as React.CSSProperties}
          >
            <h1
              className="font-display mb-5"
              style={{ fontSize: 'clamp(1.8rem, 6vw, 2.5rem)', lineHeight: 1.15, color: textMain }}
            >
              Fundamentos de <span style={{ color: '#2596be' }}>Ciberseguridad</span>
            </h1>

            <div className="space-y-4 text-[15px] leading-relaxed" style={{ color: textSub }}>
              <p>
                Así como cierras la puerta de tu casa con llave, la <strong style={{ color: textMain }}>ciberseguridad</strong> es
                el conjunto de prácticas para proteger tu información y tus cuentas de quienes no deberían tener acceso a ellas.
              </p>
              <p>
                En RutSeg aprendes esto de forma práctica, con laboratorios reales — no solo teoría. Este es un mini adelanto:
                <strong style={{ color: textMain }}> 5 preguntas cortas</strong> sobre conceptos básicos que cualquiera debería conocer.
              </p>
              <p style={{ color: textMuted }}>
                No necesitas cuenta ni conocimientos previos. Solo dale "Comenzar".
              </p>
            </div>

            <button
              onClick={() => setStarted(true)}
              className="btn-neon w-full sm:w-auto mt-8 py-3.5 px-8 text-[15px] font-semibold"
            >
              Comenzar →
            </button>
          </div>
        )}

        {/* ── Question flow ── */}
        {started && !finished && (
          <div className="animate-fade-up-1">
            {/* Progress */}
            <div className="mb-6">
              <div className="flex justify-between font-mono text-[10px] tracking-[0.15em] uppercase mb-2" style={{ color: textMuted }}>
                <span>Pregunta {step + 1} de {QUESTIONS.length}</span>
                <span>{score} correcta{score !== 1 ? 's' : ''}</span>
              </div>
              <div className="h-1.5 rounded-full overflow-hidden" style={{ background: isDark ? 'rgba(26,63,150,0.15)' : 'rgba(26,63,150,0.10)' }}>
                <div
                  className="h-full rounded-full transition-all duration-500"
                  style={{ width: `${((step + (checked ? 1 : 0)) / QUESTIONS.length) * 100}%`, background: 'linear-gradient(90deg, #1A3F96, #2596be)' }}
                />
              </div>
            </div>

            <div
              className="hud-panel hud-static p-6 sm:p-8"
              style={{
                background: isDark ? 'rgba(13,27,70,0.55)' : '#f8faff',
                '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
                '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.24)',
              } as React.CSSProperties}
            >
              <p className="text-[16px] sm:text-[17px] font-medium leading-snug mb-6" style={{ color: textMain }}>
                {question.question}
              </p>

              <div className="space-y-2.5">
                {question.options.map((opt, i) => {
                  const isSelected = selected === i
                  const isCorrectOpt = checked && i === question.correctIndex
                  const isWrongSelection = checked && isSelected && i !== question.correctIndex

                  let bg = isDark ? 'rgba(26,63,150,0.06)' : 'rgba(255,255,255,0.7)'
                  let border = isDark ? 'rgba(26,63,150,0.16)' : 'rgba(26,63,150,0.14)'
                  let color = textMain

                  if (isCorrectOpt) {
                    bg = 'rgba(74,222,128,0.10)'; border = 'rgba(74,222,128,0.35)'; color = correctColor
                  } else if (isWrongSelection) {
                    bg = 'rgba(248,113,113,0.10)'; border = 'rgba(248,113,113,0.35)'; color = wrongColor
                  } else if (isSelected && !checked) {
                    bg = isDark ? 'rgba(26,63,150,0.22)' : 'rgba(26,63,150,0.10)'
                    border = '#1A3F96'
                  }

                  return (
                    <button
                      key={i}
                      disabled={checked}
                      onClick={() => !checked && setSelected(i)}
                      className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-left text-[14px] transition-all duration-200"
                      style={{ background: bg, border: `1px solid ${border}`, color, cursor: checked ? 'default' : 'pointer' }}
                    >
                      <span
                        className="w-4 h-4 rounded-full shrink-0 flex items-center justify-center"
                        style={{ border: `2px solid ${isCorrectOpt ? correctColor : isWrongSelection ? wrongColor : isSelected ? '#1A3F96' : textMuted}` }}
                      >
                        {(isSelected || isCorrectOpt) && (
                          <span className="w-2 h-2 rounded-full" style={{ background: isCorrectOpt ? correctColor : isWrongSelection ? wrongColor : '#1A3F96' }} />
                        )}
                      </span>
                      <span className="flex-1">{opt}</span>
                    </button>
                  )
                })}
              </div>

              {checked && (
                <div
                  className="mt-4 px-4 py-3 rounded-xl"
                  style={{
                    background: isDark ? 'rgba(26,63,150,0.08)' : 'rgba(26,63,150,0.05)',
                    borderLeft: `3px solid ${selected === question.correctIndex ? correctColor : wrongColor}`,
                  }}
                >
                  <p className="font-mono text-[10px] tracking-[0.18em] uppercase mb-1" style={{ color: textMuted }}>
                    {selected === question.correctIndex ? '✓ correcto' : '✗ no del todo'}
                  </p>
                  <p className="text-[13px] leading-relaxed" style={{ color: textMain }}>{question.explanation}</p>
                </div>
              )}

              <div className="mt-6 flex justify-end">
                {!checked ? (
                  <button
                    onClick={handleCheck}
                    disabled={selected === null}
                    className="btn-neon py-3 px-7 text-[14px] font-semibold disabled:opacity-40 disabled:cursor-not-allowed"
                  >
                    Verificar
                  </button>
                ) : (
                  <button onClick={handleNext} className="btn-neon py-3 px-7 text-[14px] font-semibold">
                    {isLast ? 'Ver resultado →' : 'Siguiente →'}
                  </button>
                )}
              </div>
            </div>
          </div>
        )}

        {/* ── Finish ── */}
        {finished && (
          <div
            className="hud-panel hud-static p-8 sm:p-10 text-center space-y-6 animate-fade-up-1"
            style={{
              background: isDark ? 'rgba(13,27,70,0.55)' : '#f8faff',
              '--hud-border': isDark ? 'rgba(74,222,128,0.35)' : 'rgba(74,222,128,0.35)',
              '--hud-border-hover': isDark ? 'rgba(74,222,128,0.35)' : 'rgba(74,222,128,0.35)',
            } as React.CSSProperties}
          >
            <p className="num-display" style={{ fontSize: '3.5rem', lineHeight: 1, color: correctColor }}>
              {score}/{QUESTIONS.length}
            </p>
            <div className="space-y-2">
              <p className="font-display text-xl" style={{ color: textMain }}>
                {score === QUESTIONS.length ? '¡Perfecto!' : score >= QUESTIONS.length / 2 ? '¡Bien hecho!' : '¡Buen intento!'}
              </p>
              <p className="text-[14px]" style={{ color: textSub }}>
                Esto fue solo una muestra. En RutSeg tienes laboratorios completos con terminal real, más de 50 ejercicios
                prácticos y un ranking para medirte con otros estudiantes.
              </p>
            </div>

            <div className="flex flex-col gap-3 pt-2 max-w-xs mx-auto">
              <Link to="/register" className="btn-neon w-full py-3.5 rounded-xl text-[15px] font-semibold">
                Crear cuenta gratis →
              </Link>
              <button
                onClick={handleRestart}
                className="w-full py-3 rounded-xl text-[13px] font-mono transition-colors"
                style={{ color: textMuted }}
                onMouseEnter={e => (e.currentTarget.style.color = '#2596be')}
                onMouseLeave={e => (e.currentTarget.style.color = textMuted)}
              >
                Repetir la prueba
              </button>
            </div>
          </div>
        )}
      </main>

      <Footer />
    </div>
  )
}
