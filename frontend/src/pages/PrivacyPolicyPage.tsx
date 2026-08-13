import { useState } from 'react'
import { useTheme } from '../context/ThemeContext'
import Header from '../components/Header'
import Footer from '../components/Footer'

const SECTIONS = [
  {
    id: 'responsable',
    label: '01',
    title: 'Responsable del Tratamiento',
    content: (
      <>
        <p>
          El responsable del tratamiento de los datos personales recopilados a través de la plataforma
          <strong> RutSeg</strong> es:
        </p>
        <div className="mt-4 space-y-1">
          {[
            { k: 'Nombre', v: 'Simón Jacobo Urbina Martínez' },
            { k: 'Institución', v: 'Universidad Santo Tomás — Tunja, Colombia' },
            { k: 'Proyecto', v: 'Semillero de Investigación en Ciberseguridad y Desarrollo de Software' },
            { k: 'Correo de contacto', v: 'jacobitourbinalol@gmail.com' },
            { k: 'Sitio web', v: 'https://rutseg.vercel.app' },
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
  {
    id: 'datos',
    label: '02',
    title: 'Datos Personales que Recopilamos',
    content: (
      <>
        <p>Al registrarte y usar RutSeg, recopilamos la siguiente información:</p>
        <div className="mt-5 space-y-3">
          {[
            {
              cat: 'Datos de cuenta',
              items: ['Nombre de usuario (username)', 'Dirección de correo electrónico', 'Contraseña (almacenada exclusivamente como hash; nunca en texto plano) — solo si te registras con el formulario propio'],
            },
            {
              cat: 'Datos de cuenta vía Google',
              items: ['Si inicias sesión o te registras con "Continuar con Google", recibimos tu nombre y tu correo verificado directamente de Google (Google Identity Services) para crear o vincular tu cuenta', 'Nunca recibimos ni almacenamos tu contraseña de Google — la autenticación la resuelve Google, RutSeg solo verifica un token firmado'],
            },
            {
              cat: 'Datos de perfil',
              items: ['Biografía (bio) — opcional', 'Foto de perfil (JPG/JPEG, máx. 5 MB) — opcional'],
            },
            {
              cat: 'Datos de actividad',
              items: ['Puntos acumulados por completar laboratorios', 'Progreso en cursos, módulos y laboratorios', 'Respuestas enviadas en quizzes (historial de submissions)', 'Intentos en actividades prácticas'],
            },
            {
              cat: 'Datos técnicos',
              items: ['Token de sesión JWT almacenado en localStorage del navegador', 'Preferencia de tema visual (oscuro/claro) almacenada en localStorage'],
            },
          ].map(({ cat, items }) => (
            <div key={cat}>
              <p className="font-mono text-[11px] tracking-[0.14em] uppercase mb-2" style={{ color: '#F5C500' }}>
                // {cat.toLowerCase()}
              </p>
              <ul className="space-y-1 pl-4">
                {items.map(item => (
                  <li key={item} className="flex items-start gap-2 text-[14px]">
                    <span className="mt-2 w-1 h-1 rounded-full shrink-0" style={{ background: '#2596be' }} />
                    {item}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <p className="mt-4 text-[13px]" style={{ color: '#6b7280' }}>
          No recopilamos datos de pago, documentos de identidad ni información financiera.
        </p>
      </>
    ),
  },
  {
    id: 'finalidad',
    label: '03',
    title: 'Finalidad del Tratamiento',
    content: (
      <>
        <p>Los datos personales son usados exclusivamente para las siguientes finalidades:</p>
        <div className="mt-4 space-y-2">
          {[
            ['Autenticación y seguridad', 'Verificar tu identidad al iniciar sesión, proteger tu cuenta mediante verificación de correo electrónico y restablecer contraseñas de forma segura.'],
            ['Funcionamiento de la plataforma', 'Registrar tu progreso en labs y cursos, calcular puntos, mostrar tu posición en el ranking y personalizar tu experiencia.'],
            ['Comunicaciones transaccionales', 'Enviar correos de verificación de cuenta y restablecimiento de contraseña. No enviamos publicidad ni newsletters sin tu consentimiento explícito.'],
            ['Perfil público', 'Mostrar tu username, bio y puntos en el ranking global y en tu perfil público (/u/:username), accesible sin necesidad de iniciar sesión.'],
            ['Mejora del servicio', 'Analizar el uso agregado de la plataforma para mejorar el contenido y la experiencia educativa.'],
          ].map(([title, body]) => (
            <div key={title as string} className="rounded-xl p-4" style={{ background: 'rgba(26,63,150,0.06)', border: '1px solid rgba(26,63,150,0.12)' }}>
              <p className="font-semibold text-[14px] mb-1">{title as string}</p>
              <p className="text-[13px] leading-relaxed" style={{ color: '#6b7280' }}>{body as string}</p>
            </div>
          ))}
        </div>
      </>
    ),
  },
  {
    id: 'almacenamiento',
    label: '04',
    title: 'Almacenamiento y Proveedores',
    content: (
      <>
        <p>
          Tus datos se almacenan y procesan en los siguientes servicios de terceros, todos con estándares de
          seguridad reconocidos internacionalmente:
        </p>
        <div className="mt-4 space-y-3">
          {[
            {
              name: 'Supabase (PostgreSQL)',
              role: 'Base de datos principal',
              desc: 'Almacena todos los datos de cuenta, perfil, progreso y submissions. Los servidores se ubican en AWS (us-east-1). Supabase cumple con SOC 2 Type II.',
              url: 'https://supabase.com/privacy',
            },
            {
              name: 'Railway',
              role: 'Servidor backend',
              desc: 'Ejecuta la API REST (Hono + Bun). Procesa las peticiones y aplica la lógica de negocio. Los datos en tránsito se protegen con TLS/HTTPS.',
              url: 'https://railway.app/legal/privacy',
            },
            {
              name: 'Vercel',
              role: 'Alojamiento del frontend',
              desc: 'Sirve la aplicación React compilada. No almacena datos de usuario directamente. Usa CDN global para distribución.',
              url: 'https://vercel.com/legal/privacy-policy',
            },
            {
              name: 'Google (Gmail API)',
              role: 'Envío de correos transaccionales',
              desc: 'Usado exclusivamente para enviar correos de verificación de cuenta y restablecimiento de contraseña. No se almacena ningún dato de usuario en los servidores de Google.',
              url: 'https://policies.google.com/privacy',
            },
            {
              name: 'Google Identity Services',
              role: 'Inicio de sesión con Google',
              desc: 'Si eliges "Continuar con Google", RutSeg verifica el token que emite Google y obtiene tu nombre y correo verificado para crear o vincular tu cuenta. Al hacer clic en este botón aceptas esta Política de Privacidad y los Términos de Uso de RutSeg.',
              url: 'https://policies.google.com/privacy',
            },
          ].map(({ name, role, desc, url: providerUrl }) => (
            <div key={name} className="rounded-xl p-5" style={{ background: 'rgba(26,63,150,0.05)', border: '1px solid rgba(26,63,150,0.12)' }}>
              <div className="flex items-start justify-between gap-4 flex-wrap mb-2">
                <div>
                  <span className="font-mono text-[13px] font-semibold">{name}</span>
                  <span className="font-mono text-[10px] tracking-[0.12em] uppercase ml-3 px-2 py-0.5 rounded" style={{ color: '#2596be', background: 'rgba(37,150,190,0.10)', border: '1px solid rgba(37,150,190,0.20)' }}>
                    {role}
                  </span>
                </div>
                <a href={providerUrl} target="_blank" rel="noopener noreferrer" className="font-mono text-[11px] transition-colors" style={{ color: '#2596be' }}
                  onMouseEnter={e => (e.currentTarget.style.color = '#F5C500')}
                  onMouseLeave={e => (e.currentTarget.style.color = '#2596be')}>
                  Ver política →
                </a>
              </div>
              <p className="text-[13px] leading-relaxed" style={{ color: '#6b7280' }}>{desc}</p>
            </div>
          ))}
        </div>

        <div className="mt-5 space-y-3">
          <div className="rounded-xl px-5 py-4" style={{ background: 'rgba(26,63,150,0.06)', border: '1px solid rgba(26,63,150,0.14)' }}>
            <p className="font-mono text-[11px] tracking-[0.14em] uppercase mb-2" style={{ color: '#F5C500' }}>// transferencia internacional de datos</p>
            <p className="text-[14px] leading-relaxed" style={{ color: '#6b7280' }}>
              Los servidores de Supabase (AWS us-east-1), Railway y Vercel se encuentran en Estados Unidos,
              país que no cuenta con declaración de adecuación por parte de Colombia. La transferencia
              internacional de tus datos se realiza sobre la base de la <strong>autorización expresa</strong> que
              otorgas al aceptar esta política durante el registro —ya sea completando el formulario propio
              o haciendo clic en "Continuar con Google"—, conforme al artículo 26 de la Ley 1581 de 2012.
            </p>
          </div>
          <div className="rounded-xl px-5 py-4" style={{ background: 'rgba(26,63,150,0.06)', border: '1px solid rgba(26,63,150,0.14)' }}>
            <p className="font-mono text-[11px] tracking-[0.14em] uppercase mb-2" style={{ color: '#F5C500' }}>// retención de datos</p>
            <p className="text-[14px] leading-relaxed" style={{ color: '#6b7280' }}>
              Tus datos se conservan mientras tu cuenta esté activa. Si solicitas la eliminación, tu cuenta
              se marcará como inactiva (<em>soft delete</em>) durante <strong>90 días</strong> —período
              en el que puedes solicitar su restauración— tras los cuales los datos personales identificables
              serán eliminados permanentemente de nuestros sistemas.
            </p>
          </div>
        </div>
      </>
    ),
  },
  {
    id: 'publicidad',
    label: '05',
    title: 'Publicidad (Google AdSense)',
    content: (
      <>
        <div className="rounded-xl px-5 py-4 mb-4" style={{ background: 'rgba(245,197,0,0.06)', border: '1px solid rgba(245,197,0,0.20)' }}>
          <p className="font-mono text-[11px] tracking-[0.14em] uppercase mb-1" style={{ color: '#F5C500' }}>// estado actual</p>
          <p className="text-[14px]">
            En este momento, RutSeg <strong>no muestra publicidad</strong>. Este apartado describe el comportamiento previsto si la plataforma integra Google AdSense en el futuro.
          </p>
        </div>
        <p>
          Si se habilita Google AdSense, Google podrá utilizar cookies para mostrar anuncios personalizados basados en tus visitas a este y otros sitios. Puedes consultar y gestionar tus preferencias en{' '}
          <a href="https://adssettings.google.com" target="_blank" rel="noopener noreferrer" className="transition-colors" style={{ color: '#2596be' }}>
            adssettings.google.com
          </a>.
        </p>
        <p className="mt-3">
          Los anuncios solo se mostrarán en páginas públicas (landing page, perfiles públicos). Las páginas de contenido educativo dentro del dashboard no incluirán publicidad intrusiva.
        </p>
        <p className="mt-3">
          Google AdSense puede recopilar datos técnicos como dirección IP, tipo de navegador y páginas visitadas para medir el rendimiento de los anuncios, de acuerdo con la{' '}
          <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer" className="transition-colors" style={{ color: '#2596be' }}>
            Política de Privacidad de Google
          </a>.
        </p>
      </>
    ),
  },
  {
    id: 'derechos',
    label: '06',
    title: 'Tus Derechos (Ley 1581 de 2012)',
    content: (
      <>
        <p>
          De conformidad con la <strong>Ley Estatutaria 1581 de 2012</strong> de la República de Colombia y el
          Decreto Reglamentario 1377 de 2013, tienes los siguientes derechos sobre tus datos personales:
        </p>
        <div className="mt-4 space-y-3">
          {[
            ['Acceso', 'Conocer, actualizar y rectificar tus datos personales en cualquier momento desde la sección de perfil de tu cuenta.'],
            ['Rectificación', 'Corregir datos inexactos, incompletos o desactualizados accediendo a "Editar perfil" o contactándonos directamente.'],
            ['Supresión', 'Solicitar la eliminación de tus datos cuando consideres que no son tratados conforme a la ley o que ya no son necesarios. Esto implica la desactivación (soft delete) de tu cuenta.'],
            ['Revocación del consentimiento', 'Retirar en cualquier momento el consentimiento que hayas otorgado para el tratamiento de tus datos, sin que ello afecte la licitud del tratamiento previo.'],
            ['Prueba de autorización', 'Solicitar prueba de la autorización que otorgaste para el tratamiento de tus datos personales, conforme al artículo 8(c) de la Ley 1581 de 2012.'],
            ['Queja ante la autoridad', 'Presentar una queja ante la Superintendencia de Industria y Comercio (SIC) si consideras que se han vulnerado tus derechos.'],
          ].map(([right, desc]) => (
            <div key={right as string} className="flex gap-4">
              <span className="font-mono text-[11px] tracking-[0.1em] uppercase shrink-0 mt-0.5 px-2 py-1 rounded h-fit" style={{ color: '#1A3F96', background: 'rgba(26,63,150,0.08)', border: '1px solid rgba(26,63,150,0.18)' }}>
                {right as string}
              </span>
              <p className="text-[14px] leading-relaxed" style={{ color: '#6b7280' }}>{desc as string}</p>
            </div>
          ))}
        </div>
        <p className="mt-5 text-[13px]" style={{ color: '#6b7280' }}>
          Para ejercer cualquiera de estos derechos, envía una solicitud a nuestro correo de contacto indicando tu nombre de usuario, el derecho que deseas ejercer y la información relacionada.
        </p>
      </>
    ),
  },
  {
    id: 'seguridad',
    label: '07',
    title: 'Seguridad de los Datos',
    content: (
      <>
        <p>Implementamos las siguientes medidas técnicas para proteger tu información:</p>
        <div className="mt-4 space-y-2">
          {[
            'Las contraseñas se almacenan usando <strong>Argon2/bcrypt</strong> mediante la API nativa de Bun — nunca en texto plano.',
            'Todas las comunicaciones entre el cliente y el servidor ocurren sobre <strong>HTTPS/TLS</strong>.',
            'La autenticación se gestiona mediante <strong>JSON Web Tokens (JWT)</strong> con expiración de 7 días firmados con una clave secreta.',
            'El acceso a datos sensibles requiere autenticación válida. Las rutas de administración exigen rol <code>admin</code>.',
            'Los correos de verificación y restablecimiento de contraseña incluyen <strong>tokens de un solo uso con expiración</strong> (15 min y 1 hora respectivamente).',
            'La base de datos implementa <strong>soft delete</strong>: los registros eliminados se marcan con una fecha de borrado y no se eliminan físicamente de inmediato.',
          ].map((item, i) => (
            <div key={i} className="flex items-start gap-3 rounded-lg px-4 py-3" style={{ background: 'rgba(26,63,150,0.04)', border: '1px solid rgba(26,63,150,0.10)' }}>
              <span className="font-mono text-[11px] shrink-0 mt-0.5" style={{ color: '#2596be' }}>✓</span>
              <p className="text-[14px] leading-relaxed" style={{ color: '#6b7280' }} dangerouslySetInnerHTML={{ __html: item }} />
            </div>
          ))}
        </div>
        <p className="mt-4 text-[13px]" style={{ color: '#9ca3af' }}>
          Ningún sistema es 100% infalible. Si descubres una vulnerabilidad de seguridad, repórtala responsablemente a{' '}
          <a href="mailto:jacobitourbinalol@gmail.com" style={{ color: '#2596be' }}>
            jacobitourbinalol@gmail.com
          </a>.
        </p>
      </>
    ),
  },
  {
    id: 'menores',
    label: '08',
    title: 'Menores de Edad',
    content: (
      <>
        <p>
          RutSeg está diseñada principalmente para estudiantes universitarios y personas mayores de
          <strong> 18 años</strong>. Conforme al artículo 7 de la Ley 1581 de 2012, no recopilamos
          intencionalmente datos de menores de 18 años sin el consentimiento verificado de su representante legal.
        </p>
        <p className="mt-3">
          Si eres padre, madre o tutor y crees que tu hijo menor de 18 años ha creado una cuenta sin tu
          consentimiento, contáctanos para proceder con la eliminación de la cuenta y sus datos asociados.
        </p>
      </>
    ),
  },
  {
    id: 'cambios',
    label: '09',
    title: 'Cambios a esta Política',
    content: (
      <>
        <p>
          Podemos actualizar esta Política de Privacidad para reflejar cambios en la plataforma, en la
          legislación aplicable o en nuestras prácticas de tratamiento de datos.
        </p>
        <p className="mt-3">
          Cuando realicemos cambios materiales, notificaremos a los usuarios registrados por correo electrónico
          y actualizaremos la fecha de "Última actualización" al inicio de esta página.
        </p>
        <p className="mt-3">
          El uso continuado de la plataforma tras la publicación de cambios constituye la aceptación de la
          política actualizada.
        </p>
      </>
    ),
  },
  {
    id: 'contacto',
    label: '10',
    title: 'Contacto',
    content: (
      <>
        <p>
          Para cualquier consulta, solicitud de ejercicio de derechos o reporte relacionado con el tratamiento
          de tus datos personales, puedes contactarnos por los siguientes medios:
        </p>
        <div className="mt-4 space-y-3">
          {[
            { label: 'Correo electrónico', value: 'jacobitourbinalol@gmail.com', href: 'mailto:jacobitourbinalol@gmail.com' },
          ].map(({ label, value, href }) => (
            <div key={label} className="flex items-center gap-4 rounded-xl px-5 py-4" style={{ background: 'rgba(26,63,150,0.05)', border: '1px solid rgba(26,63,150,0.12)' }}>
              <span className="font-mono text-[11px] tracking-[0.1em] uppercase w-36 shrink-0" style={{ color: '#3A5AB8' }}>{label}</span>
              <a href={href} target={href.startsWith('mailto') ? undefined : '_blank'} rel="noopener noreferrer"
                className="font-mono text-[13px] transition-colors" style={{ color: '#2596be' }}
                onMouseEnter={e => (e.currentTarget.style.color = '#F5C500')}
                onMouseLeave={e => (e.currentTarget.style.color = '#2596be')}>
                {value}
              </a>
            </div>
          ))}
        </div>
        <p className="mt-5 text-[13px]" style={{ color: '#9ca3af' }}>
          Respondemos solicitudes en un plazo máximo de <strong>10 días hábiles</strong>, conforme a lo
          establecido en el artículo 14 de la Ley 1581 de 2012.
        </p>
      </>
    ),
  },
]

export default function PrivacyPolicyPage() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const [active, setActive] = useState<string | null>(null)

  const textPrimary = isDark ? '#C8D5EE' : '#0A1545'
  const textSecondary = isDark ? '#7B9FE8' : '#2451C8'
  const cardBg = isDark ? 'rgba(13,27,70,0.85)' : '#f8faff'
  const cardBorder = isDark ? 'rgba(26,63,150,0.16)' : 'rgba(26,63,150,0.12)'

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
        {isDark && (
          <div
            className="absolute inset-0 pointer-events-none"
            style={{
              backgroundImage: `linear-gradient(rgba(26,63,150,0.05) 1px, transparent 1px), linear-gradient(90deg, rgba(26,63,150,0.05) 1px, transparent 1px)`,
              backgroundSize: '48px 48px',
              maskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
              WebkitMaskImage: 'radial-gradient(ellipse at center, black 30%, transparent 75%)',
            }}
          />
        )}

        <div className="relative max-w-4xl mx-auto px-6 lg:px-10 pt-16 pb-20">
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-5 animate-fade-up-1" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // politica_de_privacidad.md
          </p>
          <h1
            className="font-display mb-4 animate-fade-up-2"
            style={{ fontSize: 'clamp(2.2rem, 4.5vw, 3.4rem)', lineHeight: 1.1, letterSpacing: '-0.01em' }}
          >
            Política de <span style={{ color: '#1A3F96' }}>Privacidad</span>
          </h1>
          <p className="text-[16px] font-light max-w-xl mb-8 animate-fade-up-3" style={{ color: textSecondary, lineHeight: 1.65 }}>
            RutSeg se compromete a proteger tus datos personales de acuerdo con la legislación colombiana
            e internacional vigente.
          </p>
          <div className="flex flex-wrap gap-6 animate-fade-up-4">
            {[
              { label: 'Última actualización', value: '12 de agosto de 2026' },
              { label: 'Versión', value: '1.1' },
              { label: 'Jurisdicción', value: 'Colombia — Ley 1581 de 2012' },
            ].map(({ label, value }) => (
              <div key={label}>
                <p className="font-mono text-[9px] tracking-[0.2em] uppercase mb-1" style={{ color: isDark ? '#3A5AB8' : '#4A70CC' }}>{label}</p>
                <p className="font-mono text-[13px]" style={{ color: textPrimary }}>{value}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── CONTENT ─── */}
      <div className="max-w-4xl mx-auto px-6 lg:px-10 py-16 lg:py-24">

        {/* Intro note */}
        <div
          className="hud-panel hud-static px-7 py-6 mb-12"
          style={{
            background: isDark ? 'rgba(37,150,190,0.07)' : 'rgba(37,150,190,0.05)',
            '--hud-border': 'rgba(37,150,190,0.35)',
            '--hud-border-hover': 'rgba(37,150,190,0.35)',
          } as React.CSSProperties}
        >
          <p className="font-mono text-[10px] tracking-[0.2em] uppercase mb-2" style={{ color: '#2596be' }}>// resumen ejecutivo</p>
          <p className="text-[14px] leading-relaxed" style={{ color: isDark ? '#93B0F0' : '#1A3F96' }}>
            Recopilamos únicamente los datos necesarios para que la plataforma funcione. No vendemos tu
            información, no enviamos spam y nunca almacenamos contraseñas en texto plano. Tienes control total
            sobre tus datos y puedes solicitar su eliminación en cualquier momento.
          </p>
        </div>

        {/* Sections */}
        <div className="space-y-4">
          {SECTIONS.map(({ id, label, title, content }) => {
            const isOpen = active === id
            return (
              <div
                key={id}
                className="hud-panel hud-static"
                style={{
                  background: cardBg,
                  boxShadow: isOpen
                    ? isDark ? '0 8px 40px rgba(0,0,0,0.25)' : '0 8px 32px rgba(10,21,69,0.07)'
                    : 'none',
                  '--hud-border': isOpen ? 'rgba(26,63,150,0.55)' : cardBorder,
                  '--hud-border-hover': isOpen ? 'rgba(26,63,150,0.55)' : cardBorder,
                } as React.CSSProperties}
              >
                {/* Header */}
                <button
                  className="w-full flex items-center gap-5 px-7 py-6 text-left transition-all"
                  onClick={() => setActive(isOpen ? null : id)}
                  style={{ background: 'transparent' }}
                >
                  <span
                    className="font-mono text-[11px] tracking-[0.14em] shrink-0 w-8"
                    style={{ color: isOpen ? '#F5C500' : (isDark ? '#3A5AB8' : '#4A70CC') }}
                  >
                    {label}
                  </span>
                  <span
                    className="font-display flex-1 text-left transition-colors"
                    style={{
                      fontSize: '1.15rem',
                      color: isOpen ? (isDark ? '#EEF3FC' : '#0A1545') : textSecondary,
                    }}
                  >
                    {title}
                  </span>
                  <span
                    className="shrink-0 font-mono text-[18px] transition-transform duration-300"
                    style={{
                      color: isDark ? '#3A5AB8' : '#4A70CC',
                      transform: isOpen ? 'rotate(45deg)' : 'rotate(0deg)',
                    }}
                  >
                    +
                  </span>
                </button>

                {/* Body */}
                {isOpen && (
                  <div
                    className="px-7 pb-8 text-[14px] leading-relaxed space-y-3"
                    style={{ color: isDark ? '#7B9FE8' : '#2451C8', borderTop: `1px solid ${cardBorder}` }}
                  >
                    <div className="pt-6">{content}</div>
                  </div>
                )}
              </div>
            )
          })}
        </div>

        {/* Bottom note */}
        <div
          className="hud-panel hud-static mt-16 px-7 py-6 text-center"
          style={{
            background: isDark ? 'rgba(13,27,70,0.6)' : '#f0f4ff',
            '--hud-border': cardBorder,
            '--hud-border-hover': cardBorder,
          } as React.CSSProperties}
        >
          <p className="font-mono text-[10px] tracking-[0.22em] uppercase mb-3" style={{ color: isDark ? '#3A5AB8' : '#1A3F96' }}>
            // marco legal
          </p>
          <p className="text-[13px] leading-relaxed max-w-xl mx-auto" style={{ color: isDark ? '#4A70CC' : '#2451C8' }}>
            Esta política está elaborada en cumplimiento de la{' '}
            <strong style={{ color: textPrimary }}>Ley Estatutaria 1581 de 2012</strong> (Protección de Datos Personales de Colombia),
            el <strong style={{ color: textPrimary }}>Decreto 1377 de 2013</strong> y los principios del
            Reglamento General de Protección de Datos de la Unión Europea (<strong style={{ color: textPrimary }}>RGPD/GDPR</strong>).
          </p>
        </div>
      </div>

      <Footer />
    </div>
  )
}
