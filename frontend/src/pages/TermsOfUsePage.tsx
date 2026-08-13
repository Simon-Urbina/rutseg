import { useTheme } from '../context/ThemeContext'
import Header from '../components/Header'
import Footer from '../components/Footer'

const SECTIONS = [
  {
    id: 'objeto',
    label: '01',
    title: 'Objeto y Aceptación',
    content: (
      <>
        <p>
          Los presentes Términos de Uso regulan el acceso y la utilización de la plataforma{' '}
          <strong>RutSeg</strong>, desarrollada como proyecto académico en el marco del
          Semillero de Investigación en Ciberseguridad y Desarrollo de Software de la{' '}
          <strong>Universidad Santo Tomás — Tunja, Colombia</strong>.
        </p>
        <p className="mt-4">
          Al registrarte o usar RutSeg, aceptas estos términos en su totalidad. Esto aplica
          sin importar el método que uses para crear tu cuenta o iniciar sesión: el formulario
          propio (usuario, correo y contraseña) o un proveedor externo como Google — hacer clic
          en "Continuar con Google" equivale a aceptar estos Términos de Uso y la Política de
          Privacidad. Si no estás de acuerdo con alguno de ellos, debes abstenerte de usar la
          plataforma.
        </p>
      </>
    ),
  },
  {
    id: 'uso-permitido',
    label: '02',
    title: 'Uso Permitido',
    content: (
      <>
        <p>RutSeg es una plataforma educativa. Puedes:</p>
        <ul className="mt-4 space-y-2 list-none">
          {[
            'Completar laboratorios, quizzes y actividades con fines de aprendizaje.',
            'Consultar el contenido educativo disponible en los cursos publicados.',
            'Participar en el ranking y visualizar perfiles públicos de otros usuarios.',
            'Usar las técnicas y herramientas aprendidas exclusivamente en entornos controlados y con autorización explícita.',
          ].map((item, i) => (
            <li key={i} className="flex items-start gap-3">
              <span className="font-mono text-[11px] mt-0.5 shrink-0" style={{ color: '#2596be' }}>▸</span>
              <span>{item}</span>
            </li>
          ))}
        </ul>
      </>
    ),
  },
  {
    id: 'uso-prohibido',
    label: '03',
    title: 'Conductas Prohibidas',
    content: (
      <>
        <p>Está estrictamente prohibido:</p>
        <ul className="mt-4 space-y-2 list-none">
          {[
            'Aplicar las técnicas aprendidas en sistemas reales sin autorización del propietario.',
            'Usar la plataforma para actividades ilegales, fraudulentas o que causen daño a terceros.',
            'Intentar acceder sin autorización a las cuentas de otros usuarios o a la infraestructura de la plataforma.',
            'Compartir credenciales de acceso o crear cuentas en nombre de otra persona.',
            'Publicar o distribuir contenido ofensivo, discriminatorio o que infrinja derechos de terceros.',
            'Automatizar el envío de respuestas o manipular el sistema de puntuación con herramientas externas.',
          ].map((item, i) => (
            <li key={i} className="flex items-start gap-3">
              <span className="font-mono text-[11px] mt-0.5 shrink-0" style={{ color: '#e05c5c' }}>✕</span>
              <span>{item}</span>
            </li>
          ))}
        </ul>
        <p className="mt-5">
          El incumplimiento de estas normas puede resultar en la suspensión o eliminación de la
          cuenta, sin perjuicio de las acciones legales que correspondan.
        </p>
      </>
    ),
  },
  {
    id: 'propiedad-intelectual',
    label: '04',
    title: 'Propiedad Intelectual',
    content: (
      <>
        <p>
          Todo el contenido de RutSeg — incluyendo textos, laboratorios, código fuente,
          diseño visual y materiales didácticos — es propiedad de sus autores y está protegido por
          las leyes de derechos de autor aplicables en Colombia.
        </p>
        <p className="mt-4">
          Se permite el uso personal y educativo del contenido. Queda prohibida su reproducción,
          distribución o modificación con fines comerciales sin autorización previa y por escrito.
        </p>
        <p className="mt-4">
          Las herramientas y frameworks de terceros mencionados en los laboratorios (Nmap, Gobuster,
          Nikto, sqlmap, Mimikatz, etc.) son propiedad de sus respectivos autores y se rigen por
          sus propias licencias.
        </p>
      </>
    ),
  },
  {
    id: 'responsabilidad',
    label: '05',
    title: 'Limitación de Responsabilidad',
    content: (
      <>
        <p>
          RutSeg es un proyecto académico proporcionado <strong>"tal como está"</strong>,
          sin garantías de disponibilidad continua, exactitud o idoneidad para un propósito
          particular.
        </p>
        <p className="mt-4">
          El autor no se hace responsable de ningún daño directo, indirecto o consecuente derivado
          del uso —o la imposibilidad de uso— de la plataforma, ni del uso indebido de las
          técnicas y herramientas presentadas en los laboratorios.
        </p>
        <p className="mt-4">
          El usuario es el único responsable de las acciones que realice con los conocimientos
          adquiridos. La ciberseguridad ofensiva solo es legal cuando existe autorización explícita
          del propietario del sistema objetivo.
        </p>
      </>
    ),
  },
  {
    id: 'cuentas',
    label: '06',
    title: 'Cuentas de Usuario',
    content: (
      <>
        <p>Al crear una cuenta en RutSeg, te comprometes a:</p>
        <ul className="mt-4 space-y-2 list-none">
          {[
            'Proporcionar información veraz y mantenerla actualizada.',
            'Mantener la confidencialidad de tu contraseña.',
            'Notificar de inmediato cualquier uso no autorizado de tu cuenta.',
            'No ceder ni compartir tu acceso con terceros.',
          ].map((item, i) => (
            <li key={i} className="flex items-start gap-3">
              <span className="font-mono text-[11px] mt-0.5 shrink-0" style={{ color: '#2596be' }}>▸</span>
              <span>{item}</span>
            </li>
          ))}
        </ul>
        <p className="mt-5">
          Nos reservamos el derecho de suspender o eliminar cuentas que incumplan estos términos,
          previa notificación cuando sea posible.
        </p>
      </>
    ),
  },
  {
    id: 'modificaciones',
    label: '07',
    title: 'Modificaciones',
    content: (
      <p>
        Estos Términos de Uso pueden actualizarse en cualquier momento. Los cambios significativos
        serán notificados mediante un aviso en la plataforma. El uso continuado de RutSeg
        tras la publicación de cambios constituye la aceptación de los nuevos términos.
      </p>
    ),
  },
  {
    id: 'contacto',
    label: '08',
    title: 'Contacto',
    content: (
      <>
        <p>Para consultas sobre estos Términos de Uso, puedes contactarnos en:</p>
        <div className="mt-4 space-y-1">
          {[
            { k: 'Correo', v: 'jacobitourbinalol@gmail.com' },
            { k: 'Proyecto', v: 'Semillero de Investigación — USTA Tunja' },
          ].map(({ k, v }) => (
            <p key={k} className="font-mono text-[13px]">
              <span style={{ color: '#2596be' }}>{k}</span>
              <span style={{ color: '#3A5AB8' }}>: </span>
              <span>{v}</span>
            </p>
          ))}
        </div>
      </>
    ),
  },
]

export default function TermsOfUsePage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <Header />

      {/* Hero */}
      <div
        className="relative border-b overflow-hidden"
        style={{
          borderColor: isDark ? 'rgba(26,63,150,0.12)' : 'rgba(26,63,150,0.10)',
          background: isDark
            ? 'linear-gradient(160deg, #0D1630 0%, #060D1F 100%)'
            : 'linear-gradient(160deg, #E8EEFA 0%, #EEF3FC 100%)',
        }}
      >
        <div
          className="absolute pointer-events-none"
          style={{
            top: '-40%', right: '-5%',
            width: '420px', height: '420px',
            borderRadius: '50%',
            background: isDark
              ? 'radial-gradient(circle, rgba(26,63,150,0.18) 0%, transparent 60%)'
              : 'radial-gradient(circle, rgba(26,63,150,0.07) 0%, transparent 60%)',
          }}
        />
        <div className="relative max-w-4xl mx-auto px-6 lg:px-10 py-16">
          <p
            className="font-mono text-[10px] tracking-[0.22em] uppercase mb-4"
            style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}
          >
            // legal
          </p>
          <h1
            className="font-display mb-4"
            style={{
              fontSize: 'clamp(2rem, 4vw, 3rem)',
              lineHeight: 1.1,
              color: isDark ? '#C8D5EE' : '#0A1545',
            }}
          >
            Términos de <span style={{ color: '#1A3F96' }}>Uso</span>
          </h1>
          <p style={{ color: isDark ? '#4A70CC' : '#2451C8', maxWidth: '520px', lineHeight: 1.65 }}>
            Al usar RutSeg aceptas estos términos. Léelos con atención antes de registrarte.
          </p>
          <p
            className="font-mono text-[11px] mt-6"
            style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}
          >
            Última actualización: agosto 2026
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-4xl mx-auto px-6 lg:px-10 py-16 space-y-10">
        {SECTIONS.map(({ id, label, title, content }) => (
          <section
            key={id}
            id={id}
            className="hud-panel hud-static p-8"
            style={{
              background: isDark ? 'rgba(13,27,70,0.60)' : '#f8faff',
              '--hud-border': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
              '--hud-border-hover': isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
            } as React.CSSProperties}
          >
            <div className="flex items-start gap-5 mb-5">
              <span
                className="font-mono text-[11px] tracking-[0.18em] shrink-0 mt-1"
                style={{ color: '#2596be' }}
              >
                {label}
              </span>
              <h2
                className="font-display"
                style={{
                  fontSize: '1.25rem',
                  color: isDark ? '#C8D5EE' : '#0A1545',
                }}
              >
                {title}
              </h2>
            </div>
            <div
              className="text-[15px] leading-relaxed space-y-3"
              style={{ color: isDark ? '#8BAAD8' : '#1E2A4A' }}
            >
              {content}
            </div>
          </section>
        ))}
      </div>

      <Footer />
    </div>
  )
}
