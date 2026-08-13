# Documentación Técnica del Frontend — RutSeg

> **Audience:** Desarrolladores o estudiantes que quieran entender cómo está construido el frontend de esta plataforma.  
> **Fecha:** 2026-08-09

---

## Tabla de Contenidos

1. [Visión General](#1-visión-general)
2. [Stack Tecnológico](#2-stack-tecnológico)
3. [Estructura de Carpetas](#3-estructura-de-carpetas)
4. [Rutas y Páginas](#4-rutas-y-páginas)
5. [Componentes Compartidos](#5-componentes-compartidos)
6. [Gestión de Estado](#6-gestión-de-estado)
7. [Comunicación con el Backend](#7-comunicación-con-el-backend)
8. [Sistema de Temas (Dark / Light)](#8-sistema-de-temas-dark--light)
9. [Convenciones de Estilos](#9-convenciones-de-estilos)
10. [Variables de Entorno](#10-variables-de-entorno)
11. [Comandos de Desarrollo](#11-comandos-de-desarrollo)
12. [Despliegue](#12-despliegue)
13. [Microservicio Chatbot (Uchi)](#13-microservicio-chatbot-uchi)
14. [Glosario de Términos](#14-glosario-de-términos)

---

## 1. Visión General

El frontend de Cybersec Labs es una **SPA** (*Single Page Application*) construida con React. Su responsabilidad es:

- Presentar el catálogo de cursos, módulos y laboratorios al usuario.
- Guiar al usuario a través de las actividades prácticas y los quizzes de cada laboratorio.
- Mostrar el ranking de usuarios y los perfiles públicos.
- Gestionar el inicio y cierre de sesión sin recargar la página.
- Adaptarse al tema claro u oscuro según la preferencia guardada en `localStorage`.
- Mostrar un asistente de IA ("Uchi") disponible en todas las páginas autenticadas.
- Proveer un foro comunitario donde los usuarios autenticados pueden publicar comentarios y respuestas.

> **Iniciativa académica:** RutSeg nació como proyecto del **Semillero de Investigación en Ciberseguridad y Desarrollo de Software** de la Universidad Santo Tomás — Tunja, bajo la iniciativa y dirección del docente **Harrizon Alexander Soler Galindo**.

El frontend es completamente estático una vez compilado: solo contiene HTML, CSS y JavaScript. Toda la lógica de negocio y el acceso a la base de datos ocurre en el backend (Railway). El chatbot Uchi se comunica con un microservicio Python separado.

---

## 2. Stack Tecnológico

| Componente | Tecnología | Para qué sirve |
|---|---|---|
| **Runtime / Bundler** | [Bun](https://bun.sh) | Instala dependencias, ejecuta el dev server y compila el proyecto. Más rápido que npm/yarn. |
| **Framework UI** | [React 19](https://react.dev) | Librería para construir interfaces de usuario mediante componentes reutilizables. |
| **Lenguaje** | TypeScript | JavaScript con tipado estático. Detecta errores antes de ejecutar el código. |
| **Enrutamiento** | [React Router DOM v7](https://reactrouter.com) | Maneja la navegación entre páginas dentro de la SPA sin recargar el navegador. |
| **Estilos** | [Tailwind CSS v4](https://tailwindcss.com) | Framework de estilos utilitarios. Se aplica con clases directamente en JSX. |
| **Dev server / Build** | [Vite](https://vite.dev) | Inicia el servidor de desarrollo en milisegundos. Compila el proyecto para producción con Rolldown. |
| **Linter** | ESLint + typescript-eslint | Detecta errores de código y malas prácticas. |
| **Analytics** | `@vercel/analytics` + `@vercel/speed-insights` | Métricas de uso y rendimiento real de la aplicación, integradas con Vercel. |
| **Sonido** | [use-sound](https://github.com/joshwcomeau/use-sound) | Hook React para efectos de sonido. Los hooks deben instanciarse en el componente que tiene el evento de usuario (no en componentes hijos montados tras un `await`), para respetar la browser autoplay policy. Ref: [Josh W. Comeau](https://www.joshwcomeau.com/react/announcing-use-sound-react-hook/) |
| **Animaciones** | Componentes propios (`Boop`, `Sparkles`) | Micro-interacciones sin dependencias. Ref: [Boop](https://www.joshwcomeau.com/react/boop/) · [Sparkles](https://www.joshwcomeau.com/react/animated-sparkles-in-react/) |

---

## 3. Estructura de Carpetas

```
frontend/
├── public/
│   ├── logo.svg                 ← Logo SVG de la plataforma
│   └── media/
│       └── simon_pic.jpg        ← Foto de perfil del autor (usada en AboutPage)
├── src/
│   ├── main.tsx                 ← Punto de entrada: monta <App /> en el DOM
│   ├── index.css                ← Estilos globales, animaciones y scrollbar del chat
│   ├── App.tsx                  ← Router principal, rutas protegidas, ScrollToTop y ChatWidget
│   ├── context/
│   │   ├── AuthContext.tsx      ← Estado global de autenticación (user, token, login, logout)
│   │   ├── ThemeContext.tsx     ← Estado global del tema (dark/light, toggle)
│   │   └── ToastContext.tsx     ← Sistema de notificaciones flotantes (addToast)
│   ├── lib/
│   │   └── api.ts               ← Cliente HTTP centralizado (get, post, put, patch, delete)
│   ├── components/
│   │   ├── Boop.tsx               ← Hook useBoop + componente de wiggle en hover para el logo
│   │   ├── Sparkles.tsx           ← Hook useRandomInterval + destellos animados para ResultModal
│   │   ├── Header.tsx           ← Barra de navegación superior (incluye enlace "Foro")
│   │   ├── Footer.tsx           ← Pie de página con columnas Plataforma y Legal
│   │   ├── Logo.tsx             ← Logo SVG con enlace a la raíz
│   │   ├── ThemeToggle.tsx      ← Botón para alternar tema
│   │   ├── CourseCard.tsx       ← Tarjeta de curso en la lista del dashboard
│   │   ├── Ranking.tsx          ← Tabla de posiciones paginada
│   │   ├── AuthLayout.tsx       ← Layout centrado para páginas de autenticación
│   │   ├── SocialAuthButtons.tsx ← Botón "Continuar con Google" (Login y Register)
│   │   ├── EnrollConfirmModal.tsx ← Modal de confirmación de matrícula
│   │   ├── ProfileEditModal.tsx   ← Modal para editar perfil
│   │   ├── CookieBanner.tsx       ← Banner de consentimiento de cookies (GDPR)
│   │   └── ChatWidget.tsx         ← Asistente IA "Uchi" (chat flotante, esquina inferior izquierda)
│   └── pages/
│       ├── LandingPage.tsx      ← Página de inicio pública con hero, features y ranking
│       ├── LoginPage.tsx        ← Formulario de inicio de sesión
│       ├── RegisterPage.tsx     ← Registro en 2 pasos: formulario + verificación de código por email
│       ├── ForgotPasswordPage.tsx ← Solicitar restablecimiento de contraseña
│       ├── ResetPasswordPage.tsx  ← Formulario de nueva contraseña con token
│       ├── DashboardPage.tsx    ← Panel principal del usuario autenticado
│       ├── CoursePage.tsx       ← Detalle de un curso con sus módulos y labs
│       ├── LabPage.tsx          ← Laboratorio con contenido Markdown, actividades, quiz y sonidos de resultado
│       ├── PublicProfilePage.tsx ← Perfil público de cualquier usuario (/u/:username)
│       ├── AboutPage.tsx        ← Sobre el proyecto, su autor y la iniciativa académica
│       ├── ForumPage.tsx        ← Foro comunitario con comentarios y respuestas paginados
│       ├── PrivacyPolicyPage.tsx ← Política de privacidad de la plataforma
│       ├── TermsOfUsePage.tsx   ← Términos de uso de la plataforma
│       ├── NotFoundPage.tsx     ← Página 404
│       └── admin/                ← Panel de administración (solo rol admin)
│           ├── AdminDashboardPage.tsx    ← Entrada del panel: cartas Cursos / Usuarios
│           ├── AdminCoursesPage.tsx      ← Lista de cursos + creación
│           ├── AdminCourseDetailPage.tsx ← Edición de curso, lista de módulos (exporta PageShell/Breadcrumb compartidos)
│           ├── AdminModuleDetailPage.tsx ← Edición de módulo, lista de labs
│           ├── AdminLabEditorPage.tsx    ← Edición de lab + sus 5 preguntas
│           ├── AdminUsersPage.tsx        ← Lista de usuarios con búsqueda y paginación (exporta RoleBadge)
│           ├── AdminUserDetailPage.tsx   ← Edición de datos, cambio de contraseña y borrado de un usuario
│           ├── QuestionEditor.tsx        ← Sub-formulario de una pregunta (mult. choice o actividad)
│           ├── AdminFormControls.tsx     ← AdminInput/AdminTextarea/AdminSelect/ErrorBanner compartidos
│           ├── AdminIcons.tsx            ← Set de íconos SVG del panel admin
│           └── ConfirmDeleteModal.tsx    ← Modal de borrado reutilizable (confirmación por slug/username)
├── index.html                   ← HTML raíz con el div#root donde React se monta
├── vite.config.ts               ← Configuración de Vite (plugin React, plugin Tailwind)
├── tsconfig.json                ← Configuración del compilador TypeScript
└── package.json                 ← Dependencias y scripts del proyecto
```

---

## 4. Rutas y Páginas

Las rutas se definen en `src/App.tsx` usando React Router DOM. Hay tres tipos:

### Rutas públicas (sin autenticación)

| Ruta | Componente | Descripción |
|---|---|---|
| `/` | `LandingPage` | Página de inicio: hero, features, stats, ranking |
| `/about` | `AboutPage` | Sobre el proyecto, autor y la iniciativa académica |
| `/forum` | `ForumPage` | Foro comunitario — lectura libre, escritura requiere sesión |
| `/privacy-policy` | `PrivacyPolicyPage` | Política de privacidad de la plataforma |
| `/terms-of-use` | `TermsOfUsePage` | Términos de uso de la plataforma |
| `/u/:username` | `PublicProfilePage` | Perfil público de un usuario |
| `/forgot-password` | `ForgotPasswordPage` | Formulario para pedir reset de contraseña |
| `/reset-password` | `ResetPasswordPage` | Formulario para establecer nueva contraseña |

### Rutas de autenticación (`PublicRoute`)

Solo accesibles si el usuario **no** está autenticado. Si ya tiene sesión, redirige a `/dashboard`.

| Ruta | Componente |
|---|---|
| `/login` | `LoginPage` |
| `/register` | `RegisterPage` — paso 1 (formulario) y paso 2 (código de verificación) en el mismo componente |

### Rutas protegidas (`PrivateRoute`)

Solo accesibles si el usuario **sí** está autenticado. Si no tiene sesión, redirige a `/login`.

| Ruta | Componente | Descripción |
|---|---|---|
| `/dashboard` | `DashboardPage` | Panel principal: cursos inscritos y disponibles |
| `/courses/:slug` | `CoursePage` | Módulos y laboratorios de un curso |
| `/courses/:slug/:moduleSlug/:labSlug` | `LabPage` | Laboratorio completo con quiz |

### Rutas de administrador (`AdminRoute`)

Solo accesibles si el usuario está autenticado **y** su `role` es `'admin'`. Si no, redirige a `/login` (sin sesión) o `/dashboard` (sesión sin rol admin) — es un guard de UI únicamente: la seguridad real la impone `requireAdmin` en el backend en cada request a `/api/admin/*`.

| Ruta | Componente | Descripción |
|---|---|---|
| `/admin` | `AdminDashboardPage` | Entrada del panel: dos cartas, Cursos y Usuarios |
| `/admin/courses` | `AdminCoursesPage` | Lista de cursos, crear curso |
| `/admin/courses/:courseSlug` | `AdminCourseDetailPage` | Editar curso, lista de módulos, crear módulo |
| `/admin/courses/:courseSlug/:moduleSlug` | `AdminModuleDetailPage` | Editar módulo, lista de labs |
| `/admin/courses/:courseSlug/:moduleSlug/:labSlug` | `AdminLabEditorPage` | Crear (`labSlug = 'new'`) o editar un laboratorio y sus 5 preguntas |
| `/admin/users` | `AdminUsersPage` | Lista de usuarios, búsqueda por username/email, paginación |
| `/admin/users/:id` | `AdminUserDetailPage` | Editar datos del usuario, cambiar contraseña, borrar |

```tsx
function AdminRoute({ children }: { children: React.ReactNode }) {
  const { token, user } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  return user?.role === 'admin' ? <>{children}</> : <Navigate to="/dashboard" replace />
}
```

### `PrivateRoute` y `PublicRoute`

```tsx
// PrivateRoute: redirige a /login si no hay token
function PrivateRoute({ children }) {
  const { token } = useAuth()
  return token ? <>{children}</> : <Navigate to="/login" replace />
}

// PublicRoute: redirige a /dashboard si ya hay token
function PublicRoute({ children }) {
  const { token } = useAuth()
  return !token ? <>{children}</> : <Navigate to="/dashboard" replace />
}
```

### `AppShell` y componentes globales

`AppShell` es el componente que envuelve todas las rutas. Incluye dos elementos que viven fuera del árbol de rutas:

- **`ScrollToTop`**: escucha cambios de `pathname` y llama a `window.scrollTo(0, 0)` para que cada navegación comience desde el tope.
- **`ChatWidget`**: el chat de Uchi se monta **una sola vez** en `AppShell`, no dentro de las rutas, para preservar el historial de conversación al navegar entre páginas. Se oculta automáticamente en las rutas de autenticación.

```tsx
function AppShell() {
  return (
    <div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <ScrollToTop />
      <Routes>{/* ... */}</Routes>
      <ChatWidget />   {/* siempre montado, se oculta en /login y /register */}
    </div>
  )
}
```

---

## 5. Componentes Compartidos

### `Header`

Barra de navegación superior que aparece en la mayoría de páginas. Contiene:
- Logo con enlace a `/`
- Links de navegación: Dashboard, Foro, Ranking, About (en escritorio y menú móvil)
- Avatar del usuario con dropdown (perfil, cerrar sesión)
- `ThemeToggle` para cambiar el tema

El menú móvil se despliega con un ícono de hamburguesa. En ambos modos (desktop y móvil) el enlace "Foro" aparece para usuarios autenticados y para invitados.

### `Footer`

Pie de página con tres columnas de enlaces:
- **Plataforma**: Dashboard, Foro, Ranking, About
- **Legal**: Política de Privacidad, Términos de Uso
- Créditos y links al repositorio y redes del autor

Se incluye en LandingPage, AboutPage, y páginas legales.

### `CourseCard`

Tarjeta que muestra el resumen de un curso: título, dificultad, número de módulos/labs, puntos totales y estado de matrícula. Aparece en `DashboardPage`.

### `Ranking`

Tabla de clasificación paginada. Muestra posición, avatar, username, puntos y bio. Se usa tanto en `LandingPage` (previsualización) como en páginas dedicadas.

### `RegisterPage` — Flujo de 2 pasos

El registro tiene dos fases dentro del mismo componente, controladas por el estado `step`:

| Paso | `step` | Acción |
|---|---|---|
| 1 | `'register'` | El usuario llena username, email y contraseña → `POST /api/auth/register` → el backend envía el código al email |
| 2 | `'verify'` | El usuario ingresa el código de 6 dígitos → `POST /api/auth/verify-email` → el backend crea el usuario y devuelve el JWT |

El paso 2 incluye un botón "Reenviar código" con un **cooldown de 60 segundos** (llama a `POST /api/auth/resend-verification`). El código expira en 15 minutos.

Al verificar correctamente, se llama a `login(token, user)` del contexto y se navega a `/dashboard`, igual que un login normal.

### `AuthLayout`

Layout centrado utilizado por las páginas de autenticación (Login, Register, ForgotPassword, ResetPassword). Mantiene la consistencia visual sin el Header/Footer principal.

El panel izquierdo (visible solo en pantallas `lg+`) muestra estadísticas reales de la plataforma (cursos, labs, puntos totales) obtenidas desde `/api/stats` al montar el componente. Mientras carga, muestra `—` como placeholder.

### `SocialAuthButtons`

Botón "Continuar con Google", compartido por `LoginPage` y `RegisterPage`. Carga el script de
**Google Identity Services** (`accounts.google.com/gsi/client`), inicializa el cliente con
`VITE_GOOGLE_CLIENT_ID` y renderiza el botón oficial de Google (`google.accounts.id.renderButton`).
Al recibir el `credential` del callback, hace `POST /api/auth/google` con `{ idToken, privacyPolicyVersion }`
y llama a `login()` del `AuthContext`, igual que un login por formulario.

El botón está **siempre activo** (no depende de ningún checkbox previo): debajo se muestra un texto
fijo indicando que continuar implica aceptar la Política de Privacidad y los Términos de Uso, con
enlaces a ambas páginas. Esto es intencional — ver la nota sobre Ley 1581 de 2012 en
[`Documentacion-Backend.md` §8.1](./Documentacion-Backend.md#81-autenticación-apiauth).

Si `VITE_GOOGLE_CLIENT_ID` no está definida, el componente no renderiza nada (`return null`).

### `EnrollConfirmModal`

Modal de confirmación antes de matricularse en un curso. Muestra el nombre del curso y los puntos que se pueden ganar.

### `ProfileEditModal`

Modal para editar el perfil del usuario autenticado: username, email, bio y foto de perfil. Llama a `PUT /api/users/me` y `POST /api/users/me/avatar`.

### `ChatWidget`

Asistente de IA "Uchi" disponible en toda la plataforma como un widget flotante en la esquina inferior izquierda. Características:

| Característica | Detalle |
|---|---|
| **Posición** | `position: fixed`, `bottom: 1.5rem`, `left: 1.5rem` |
| **Ícono** | Gato SVG con colores institucionales (azul `#1A3F96`, cian `#2596be`, amarillo `#F5C500`) |
| **Visibilidad** | Se oculta en `/login`, `/register`, `/forgot-password`, `/reset-password` |
| **Historial** | Guarda hasta 20 mensajes en memoria durante la sesión |
| **Streaming** | Muestra texto token a token con indicador "escribiendo..." |
| **Thinking** | Indica "pensando..." mientras espera el primer token |
| **Contexto** | Envía la página actual al backend para respuestas contextuales |
| **Mobile** | Panel adaptativo: `calc(100vw - 3rem)` de ancho, `70svh` de alto; overlay de cierre táctil |
| **Teclado** | `Enter` envía el mensaje; `Shift+Enter` agrega una nueva línea; `Escape` cierra el panel |
| **SSE** | Lee el stream del microservicio Python línea a línea con buffer acumulativo |

### `Boop`

Componente de micro-interacción para el logo. Al pasar el cursor sobre `LogoIcon`, aplica una rotación de 12° + escala 1.12x con una animación de 150ms de ida y un spring-back (`cubic-bezier(0.34, 1.56, 0.64, 1)`) al soltar.

Se aplica en 4 puntos:
- `LogoWordmark` en `Logo.tsx` (cubre el Header)
- Logo de marca del panel izquierdo en `AuthLayout.tsx`
- Logo de marca del top bar móvil en `AuthLayout.tsx`
- Logo en `Footer.tsx`

Implementación basada en [Boop! — Josh W. Comeau](https://www.joshwcomeau.com/react/boop/).

### `Sparkles`

Componente que genera destellos animados (SVG de 4 puntas) alrededor de su contenido. Acepta prop `active: boolean` — cuando `false`, detiene la generación sin desmontar.

Usado en `ResultModal` de `LabPage`: se activa (`active={true}`) al terminar la animación de count-up del porcentaje, si el laboratorio fue aprobado. Wrappea el texto `¡Lab completado!`/`¡Bien hecho!` y el badge `+X pts`.

Colores usados: `#F5C500` (gold), `#2596be` (cyan), `#C8D5EE` (blue-gray), `#ffffff`.

Implementación basada en [Animated Sparkles — Josh W. Comeau](https://www.joshwcomeau.com/react/animated-sparkles-in-react/).

### `CookieBanner`

Banner de consentimiento de cookies que aparece en la primera visita del usuario (invitado o autenticado) cuando aún no ha aceptado la política de privacidad. Se muestra en la parte inferior de la pantalla y persiste hasta que el usuario hace clic en "Aceptar".

- Guarda el consentimiento en `localStorage` para no volver a mostrarse.
- Incluye enlace a `/privacy-policy` para que el usuario pueda leer la política antes de aceptar.
- Se monta desde `App.tsx` fuera del árbol de rutas, igual que `ChatWidget`.

### `ForumPage`

Foro comunitario de la plataforma. Accesible públicamente; la escritura requiere sesión activa.

Compuesto por tres sub-componentes internos definidos en el mismo archivo:

| Sub-componente | Responsabilidad |
|---|---|
| `Avatar` | Muestra la foto de perfil del autor (o inicial si no tiene avatar) |
| `CommentCard` | Renderiza un comentario raíz con sus controles: expandir/colapsar respuestas, responder, eliminar |
| `ForumPage` | Componente raíz: carga paginada de comentarios, compositor de comentario nuevo, botón "Cargar más" |

Comportamiento clave:

- **Paginación**: Los comentarios raíz se cargan en páginas de 20 (`GET /api/forum?page=N`). El botón "Cargar más" agrega la siguiente página al final de la lista sin reemplazarla.
- **Respuestas**: Al expandir un `CommentCard`, se cargan sus respuestas (`GET /api/forum/:id/replies`). El formulario de respuesta aparece inline bajo la lista de respuestas.
- **Soft-delete**: Los comentarios eliminados muestran `[comentario eliminado]` en lugar del contenido y no muestran autor.
- **Autorización de borrado**: El botón de eliminar aparece solo si `!comment.isDeleted && (usuario es admin || el comentario tiene autor y el usuario actual es el autor)`.
- **Invitados**: En lugar del compositor, se muestra un enlace "Inicia sesión para comentar".

El widget detecta en qué página está el usuario (`pathname`) y construye un objeto `context` que se envía junto con cada mensaje:

```ts
// Ejemplos de context según pathname
{ page: 'lab',       labTitle: 'Introducción a XSS', username: 'simon' }
{ page: 'course',    courseTitle: 'intro-linux',      username: 'simon' }
{ page: 'dashboard', username: 'simon' }
{ page: 'other',     username: 'simon' }
```

### Panel de administración (`pages/admin/`)

Ocho páginas + componentes compartidos, accesibles solo a usuarios con `role: 'admin'` vía el guard `AdminRoute`. Todo el acceso al backend pasa por `src/lib/adminApi.ts`, un wrapper tipado sobre `api.ts` específico para `/api/admin/*` (y para los `GET` públicos de cursos/módulos/labs, que ya devuelven contenido no publicado cuando el JWT es de un admin).

| Página | Responsabilidad |
|---|---|
| `AdminDashboardPage` | Punto de entrada (`/admin`): dos cartas de navegación, Cursos y Usuarios |
| `AdminCoursesPage` → `AdminCourseDetailPage` → `AdminModuleDetailPage` → `AdminLabEditorPage` | Jerarquía de gestión de contenido: curso → módulo → laboratorio → sus 5 preguntas (`QuestionEditor`) |
| `AdminUsersPage` → `AdminUserDetailPage` | Gestión de usuarios: lista con búsqueda/paginación → editar username/email/bio/rol, restablecer contraseña sin la actual, y borrar (soft-delete) |

`AdminCourseDetailPage.tsx` exporta dos componentes compartidos por las demás páginas del panel: `PageShell` (fondo + `Header` + contenedor centrado) y `Breadcrumb` (navegación "Panel / Cursos / ..." con links). `AdminCoursesPage.tsx` exporta `StatusBadge` (borrador/publicado) y `AdminUsersPage.tsx` exporta `RoleBadge` (usuario/admin) — ambas páginas de detalle los reutilizan.

**Salvaguardas de auto-gestión:** un admin no puede borrar su propia cuenta ni quitarse el rol de administrador desde `AdminUserDetailPage` — el botón de borrar no se renderiza y el backend rechaza el cambio de rol con `BadRequestError` si el `id` de la ruta coincide con el del token.

**Borrado:** `ConfirmDeleteModal` es el mismo componente en las seis entidades borrables del panel (curso, módulo, lab, pregunta, opción, usuario) — para curso/módulo/lab/usuario exige escribir el slug o username exacto antes de habilitar el botón, fricción intencional dado que son operaciones irreversibles con cascada real sobre progreso de estudiantes o acceso de la cuenta.

---

## 6. Gestión de Estado

El estado global se maneja con **React Context** — no se usa Redux ni Zustand. Hay tres contextos:

### `AuthContext` (`src/context/AuthContext.tsx`)

Gestiona la sesión del usuario. Expone:

| Valor / Función | Tipo | Descripción |
|---|---|---|
| `user` | `AuthUser \| null` | Datos del usuario autenticado (id, username, email, role) |
| `token` | `string \| null` | JWT guardado en `localStorage` |
| `login(token, user)` | función | Guarda el token y usuario en estado + `localStorage` |
| `logout()` | función | Limpia el estado y `localStorage` |
| `updateUser(patch)` | función | Actualiza parcialmente el usuario en estado + `localStorage` |

El estado se inicializa leyendo `localStorage` para que la sesión persista entre recargas de página.

**Uso:**
```tsx
const { user, token, logout } = useAuth()
```

### `ThemeContext` (`src/context/ThemeContext.tsx`)

Gestiona el tema visual. Expone:

| Valor / Función | Tipo | Descripción |
|---|---|---|
| `theme` | `'dark' \| 'light'` | Tema activo |
| `toggle()` | función | Alterna entre dark y light |

Al cambiar el tema, agrega/quita la clase `dark` en `<html>` y guarda la preferencia en `localStorage`.

**Uso:**
```tsx
const { theme, toggle } = useTheme()
const isDark = theme === 'dark'
```

### `ToastContext` (`src/context/ToastContext.tsx`)

Sistema de notificaciones flotantes no bloqueantes (toasts). Aparecen en la esquina inferior derecha y se auto-descartan a los 4 segundos. Se pueden cerrar manualmente haciendo clic.

Expone:

| Función | Tipo | Descripción |
|---|---|---|
| `addToast(message, type?)` | función | Muestra una notificación. `type` por defecto: `'success'` |

Tipos disponibles:

| Tipo | Color de acento | Ícono | Uso típico |
|---|---|---|---|
| `'success'` | verde `#4ade80` | `✓` | Operación completada (matrícula, guardado de perfil) |
| `'error'` | rojo `#f87171` | `✗` | Error de validación o fallo de red |
| `'info'` | cian `#2596be` | `·` | Información general |

**Uso:**
```tsx
const { addToast } = useToast()

addToast('Perfil actualizado')               // success por defecto
addToast('Contraseña incorrecta', 'error')
addToast('Recuerda guardar los cambios', 'info')
```

> **Nota de diseño:** `ToastProvider` está anidado dentro de `AuthProvider` y `ThemeProvider` en `App.tsx`, por lo que los toasts pueden mostrarse desde cualquier página o componente con acceso a los contextos de sesión y tema.

---

## 7. Comunicación con el Backend

Todo el acceso al backend REST pasa por `src/lib/api.ts`. Es un cliente HTTP minimalista construido sobre `fetch`.

### Estructura

```typescript
const BASE_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3000'

export const api = {
  get:    <T>(path: string) => request<T>(path),
  post:   <T>(path: string, body: unknown) => request<T>(path, { method: 'POST', ... }),
  put:    <T>(path: string, body: unknown) => request<T>(path, { method: 'PUT', ... }),
  patch:  <T>(path: string, body: unknown) => request<T>(path, { method: 'PATCH', ... }),
  delete: <T>(path: string) => request<T>(path, { method: 'DELETE' }),
}
```

### Comportamiento automático

- **Token JWT**: Si hay un token en `localStorage`, lo incluye en el header `Authorization: Bearer <token>` automáticamente en cada petición.
- **Errores**: Si la respuesta HTTP no es OK (`!res.ok`), lanza un `Error` con el mensaje del campo `error` del JSON de respuesta.
- **Content-Type**: Siempre envía `Content-Type: application/json`.

### Ejemplo de uso en un componente

```tsx
import { api } from '../lib/api'

// GET con tipo de respuesta
const cursos = await api.get<Course[]>('/api/courses')

// POST con body
await api.post('/api/courses/intro-linux/enroll', {})

// Manejo de errores
try {
  await api.put('/api/users/me', { username: 'nuevo' })
} catch (err) {
  console.error(err.message) // Mensaje en español del backend
}
```

> **Nota sobre imágenes (avatar):** La subida de foto de perfil usa `fetch` directamente (no `api.ts`) porque se envía como `FormData` con `Content-Type: multipart/form-data`, no como JSON.

> **Nota sobre el chatbot:** La comunicación con el microservicio Python de Uchi **no** pasa por `api.ts`. `ChatWidget` llama directamente a `VITE_CHATBOT_URL/chat/stream` usando `fetch` con streaming SSE. Ver [Sección 13](#13-microservicio-chatbot-uchi).

---

## 8. Sistema de Temas (Dark / Light)

El frontend soporta dos temas. El sistema funciona así:

1. `ThemeContext` lee el tema guardado en `localStorage` al cargar la app.
2. Al cambiar el tema, agrega/quita la clase `dark` en `document.documentElement` (`<html>`).
3. Los colores se aplican **inline** con condicionales `isDark ? '#color-dark' : '#color-light'`, en vez de usar variables CSS de Tailwind.

### Paleta de colores

| Uso | Dark | Light |
|---|---|---|
| Fondo principal | `#060D1F` | `#EEF3FC` |
| Fondo hero / secciones | `#0D1630` | `#E8EEFA` |
| Fondo tarjetas | `rgba(13,27,70,0.85)` | `#f8faff` |
| Texto principal | `#C8D5EE` | `#0A1545` |
| Texto secundario | `#7B9FE8` | `#2451C8` |
| Texto apagado | `#4A70CC` | `#4A70CC` |
| Acento azul oscuro | `#1A3F96` | `#1A3F96` |
| Acento azul claro | `#2596be` | `#2596be` |
| Acento amarillo | `#F5C500` | `#F5C500` |
| Borde tarjetas | `rgba(26,63,150,0.14)` | `rgba(26,63,150,0.10)` |

> **Nota:** desde el rediseño "consola técnica" (ver §9.1), la mayoría de tarjetas/paneles ya no usan un borde fijo vía Tailwind — usan la primitiva `.hud-panel`, cuyo color de borde se pasa por instancia con la custom property `--hud-border` (típicamente `rgba(26,63,150,0.22–0.40)` según el contexto). La tabla de arriba sigue vigente para fondos y texto.

### Patrón de código

```tsx
const { theme } = useTheme()
const isDark = theme === 'dark'

// Uso en JSX
<div style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
```

### Gradiente de texto

Para texto con gradiente (como "rompiendo cosas" en LandingPage), se usan tres propiedades en combinación y se agrega un `key` que fuerza el re-montaje del `<span>` cuando cambia el tema, evitando que el gradiente quede en blanco:

```tsx
<span
  key={isDark ? 'dark' : 'light'}
  style={{
    display: 'inline-block',
    backgroundImage: isDark
      ? 'linear-gradient(135deg, #4A9FCC 0%, #1A3F96 55%, #7B9FE8 100%)'
      : 'linear-gradient(135deg, #1A3F96 0%, #2596be 100%)',
    WebkitBackgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
    backgroundClip: 'text',
  }}
>
  rompiendo cosas
</span>
```

> Se usa `backgroundImage` (no `background`) porque la propiedad shorthand `background` puede entrar en conflicto con `WebkitTextFillColor: 'transparent'` durante los repintados del navegador.

---

## 9. Convenciones de Estilos

### 9.1 Sistema de paneles HUD (esquina cortada)

Desde agosto de 2026 el lenguaje visual del sitio se rediseñó para alejarse del look genérico "tarjeta SaaS" (`rounded-xl`/`rounded-2xl` uniforme, blobs difusos con `radial-gradient`) hacia una estética de consola técnica. Las primitivas viven en `src/index.css` y se aplican en casi todas las páginas y componentes (excepto donde se documenta lo contrario más abajo).

| Clase | Qué hace | Cuándo usarla |
|---|---|---|
| `.hud-panel` | Corta la esquina superior derecha (`clip-path`, 16px) y dibuja un borde de 1px que sigue el corte, vía la técnica `mask-composite: exclude` sobre un `::before` — no un doble `<div>`. El color de borde se controla con las custom properties `--hud-border` / `--hud-border-hover` (por instancia, inline). Reemplaza `rounded-xl`/`rounded-2xl` en tarjetas, filas de lista, paneles de formulario y modales. | Cualquier tarjeta/panel/fila que antes tuviera `rounded-xl`/`2xl` + `border`. |
| `.hud-panel.hud-static` | Igual que arriba pero sin el `translateY(-3px)` al hover — evita que un contenedor grande (formulario, modal) "brinque" mientras el usuario mueve el mouse para hacer click en un campo interno. | Formularios, modales, banners de estado (error/éxito), paneles no-clicables. |
| `.hud-corner-tag` | Posiciona un `<span>` mono pequeño dentro de la esquina cortada — se usa como slot de etiqueta (dificultad, índice `01`/`02`, tipo de pregunta) en vez de dejar el corte vacío. | Opcional, dentro de un `.hud-panel`. |
| `.tech-input` | Reemplaza `rounded-lg` + `outline-none` en inputs/textareas/selects. Radio casi recto (2px), barra de acento izquierda de 2px, y un estado `:focus`/`:focus-visible` real (antes varios inputs del panel admin tenían `outline-none` sin ningún reemplazo). Colores vía `--tech-input-border` / `--tech-input-focus` / `--tech-input-accent` / `--tech-input-glow`. | Cualquier `<input>`/`<textarea>`/`<select>` fuera del `.input-terminal` de las páginas de auth (que ya tenía su propio tratamiento). |
| `.tech-grid` | Fondo de grilla técnica de 32px (líneas de 1px) — reemplaza los blobs `radial-gradient` decorativos en hero sections. Si el elemento ya tiene un `background` inline (gradiente), la grilla se compone manualmente como capas extra en `backgroundImage` en vez de usar esta clase (ver `DashboardPage.tsx`, hero). | Fondos de hero/secciones grandes, en vez de `.orb`. |
| `.scanline-overlay` | Textura de scanlines estática (`repeating-linear-gradient` muy sutil) vía `::after`. Solo se aplica condicionalmente en dark mode. | Complementa `.tech-grid` en hero sections dark. |

**Fuera de este sistema, a propósito:**
- `TerminalPanel` en `LabPage.tsx` — es un terminal simulado real (traffic-light dots, taskbar); cortarle una esquina rompería la metáfora.
- El skill-tree de laboratorios en `CoursePage.tsx` (nodos circulares, spine punteado) y sus `LabCard` — ya son el elemento más distintivo del sitio, no se tocaron.
- Botones (`.btn-neon`, `.btn-gold`, `.btn-ghost-light`, etc.) — ya tenían buen micro-interaction desde antes del rediseño.
- Chips/pills pequeños (badges de dificultad, tags de stack tecnológico, el pill `~/username` del Header) — no son el patrón "tarjeta genérica" que motivó el cambio.

Los decoradores `.orb` / `@keyframes glowPulse` siguen definidos en `index.css` pero **ya no se usan en ningún componente** — se removieron de todas las páginas como parte de este rediseño.

### Clases de Tailwind vs. estilos inline

- **Tailwind** se usa para: layout (`flex`, `grid`, `items-center`), espaciado (`px-6`, `py-4`, `gap-3`), tipografía (`text-sm`, `font-mono`), tamaños (`w-12`, `h-12`), transiciones (`transition-all`, `duration-200`). Los bordes/esquinas de paneles usan `.hud-panel` (ver §9.1) en vez de `rounded-xl`/`2xl`.
- **Estilos inline** se usan para: colores que dependen del tema (`isDark ? ... : ...`), colores de acento personalizados (incluyendo las custom properties `--hud-*`/`--tech-input-*`), sombras complejas, gradientes.

### Fuentes tipográficas

| Clase | Uso |
|---|---|
| `font-display` | Títulos principales (h1, h2) |
| `font-mono` | Labels, código, badges, etiquetas técnicas |
| `font-light` | Texto de cuerpo y descripciones |

### Animaciones

Las páginas usan animaciones de entrada escalonadas definidas con clases personalizadas en `src/index.css`:
- `animate-fade-up-1`, `animate-fade-up-2`, etc. — elementos que entran deslizándose hacia arriba con retraso creciente.
- `cursor-blink` — efecto de cursor parpadeante. Usado en la AboutPage y en el indicador de streaming del chatbot (`▋`).
- `slideInRight` — entrada desde la derecha, usada por los toasts de `ToastContext`.
- `sparkle-spin` — animación de 700ms para cada destello: aparece escalado desde 0, rota 90°, llega a opacidad máxima en el 50%, luego desaparece. Usada por `Sparkles`.

### Scrollbar del chat

El área de mensajes de `ChatWidget` usa la clase `.chat-scroll` definida en `src/index.css` para mostrar una barra de desplazamiento delgada con los colores institucionales:

```css
.chat-scroll {
  scrollbar-width: thin;
  scrollbar-color: rgba(26,63,150,0.35) transparent;
}
.chat-scroll::-webkit-scrollbar       { width: 4px; }
.chat-scroll::-webkit-scrollbar-track { background: transparent; }
.chat-scroll::-webkit-scrollbar-thumb {
  background: rgba(26,63,150,0.35);
  border-radius: 99px;
}
.chat-scroll::-webkit-scrollbar-thumb:hover { background: rgba(37,150,190,0.6); }
```

`scrollbar-width: thin` aplica en Firefox; `::-webkit-scrollbar-*` aplica en Chrome, Edge y Safari.

### Hover interactivo

La mayoría de tarjetas/paneles ya resuelven hover/focus/active en CSS puro vía `.hud-panel` (§9.1): elevación (`translateY`), brillo de borde y outline de foco por teclado (`:focus-visible`) sin JavaScript. El patrón `onMouseEnter`/`onMouseLeave` mutando `style` inline sigue existiendo para casos que quedaron fuera del sistema `.hud-panel` (pills pequeños, links de texto, botones con lógica de color dependiente de props) donde el valor a aplicar depende de una variable del componente que no puede expresarse como custom property CSS fija.

---

## 10. Variables de Entorno

El frontend necesita las siguientes variables de entorno:

| Variable | Obligatoria | Descripción |
|---|---|---|
| `VITE_API_URL` | ❌ | URL base del backend REST. Si no se define, usa `http://localhost:3000` |
| `VITE_CHATBOT_URL` | ❌ | URL base del microservicio Python de Uchi. Si no se define, usa `http://localhost:8001` |

**En desarrollo** (`frontend/.env`):
```env
VITE_API_URL=http://localhost:3000
VITE_CHATBOT_URL=http://localhost:8002
```

**En producción**, se configuran como variables de entorno en el proveedor de hosting (Netlify, Vercel, Cloudflare Pages, etc.) antes del build.

> **Importante:** Solo las variables que empiezan con `VITE_` son expuestas al código del navegador por Vite. Variables sin ese prefijo permanecen privadas en el servidor de build.

---

## 11. Comandos de Desarrollo

```bash
# Instalar dependencias
bun install

# Iniciar dev server (hot reload en localhost:5173)
bun dev

# Compilar para producción (genera frontend/dist/)
bun run build

# Previsualizar el build de producción localmente
bun preview

# Ejecutar el linter
bun run lint
```

El proceso de build (`bun run build`) ejecuta dos pasos:
1. `tsc -b` — verifica los tipos TypeScript sin emitir archivos.
2. `vite build` — compila y empaqueta el código en `dist/`.

El contenido de `dist/` es lo que se sube al servidor de hosting.

---

## 12. Despliegue

### Paso 1 — Construir el proyecto

```bash
# Con la URL del backend de Railway
VITE_API_URL=https://tu-backend.railway.app bun run build
```

O configurar `VITE_API_URL` y `VITE_CHATBOT_URL` como variables de entorno en el panel del proveedor y hacer el build ahí.

### Paso 2 — Desplegar en Vercel

El proyecto está desplegado en **Vercel** conectado al repositorio de GitHub. Vercel construye automáticamente con cada push.

Configuración del proyecto en Vercel:
- **Root Directory**: `frontend`
- **Framework Preset**: Vite
- **Build Command**: `bun run build`
- **Output Directory**: `dist`

### Enrutamiento SPA en Vercel

El archivo `frontend/vercel.json` es obligatorio para que React Router funcione correctamente en producción:

```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

Sin este archivo, Vercel devuelve 404 al acceder directamente a rutas como `/dashboard`, `/reset-password` o `/login`, porque intenta buscar archivos estáticos en esas rutas y no los encuentra. El rewrite redirige todo al `index.html` y React Router se encarga del resto.

Variables de entorno configuradas en Vercel:
```
VITE_API_URL=https://backend-production-64fa7.up.railway.app
VITE_CHATBOT_URL=https://chatbot-production-2003.up.railway.app
```

Vercel genera una URL de producción estable (`rutseg.vercel.app`) y URLs de preview únicas por cada deploy (`cyberseclabs-xxxx.vercel.app`).

### Configuración SPA requerida

Dado que la app usa React Router con rutas como `/dashboard` o `/courses/:slug`, el servidor de hosting debe redirigir **todas las rutas** a `index.html`. Sin esto, una recarga directa en `/dashboard` dará 404.

**En Netlify** — archivo `public/_redirects`:
```
/*  /index.html  200
```

**En Cloudflare Pages** — se configura desde el panel de control (o `public/_redirects` también funciona).

**En Vercel** — archivo `vercel.json`:
```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

---

## 13. Microservicio Chatbot (Uchi)

Uchi es un asistente de IA que vive en un **microservicio Python independiente** (`chatbot/`), separado del backend principal de Hono. El frontend se comunica con él directamente mediante **SSE** (*Server-Sent Events*) para mostrar las respuestas en tiempo real (token a token).

### Arquitectura

```
ChatWidget (React)
    │  POST /chat/stream  (fetch + ReadableStream)
    ▼
chatbot/main.py  (FastAPI)
    │
    ├── retriever.py  ← TF-IDF sobre knowledge.json (RAG)
    ├── prompts.py    ← Sistema de prompts con contexto de página + FAQs
    └── config.py     ← Cliente Groq (openai.AsyncOpenAI apuntando a api.groq.com)
```

### Flujo de una petición

1. El usuario escribe un mensaje en `ChatWidget`.
2. React hace `POST /chat/stream` con `{ messages, context }` al microservicio.
3. FastAPI recupera los 3 FAQs más relevantes de `knowledge.json` usando TF-IDF + similitud coseno.
4. Construye el system prompt inyectando el contexto de página y los FAQs relevantes.
5. Llama a **Groq** con `stream=True`.
6. Transmite cada fragmento de respuesta como `data: {"chunk": "..."}` en formato SSE.
7. `ChatWidget` acumula los fragmentos y actualiza el mensaje del asistente en tiempo real.

### RAG (Retrieval-Augmented Generation)

En lugar de incluir toda la base de conocimiento en el system prompt (que aumentaría el tamaño de cada petición), solo se inyectan los 3 FAQs más relevantes para la pregunta actual.

- **Base de conocimiento**: `chatbot/knowledge.json` — 20 pares pregunta/respuesta sobre la plataforma (qué es CyberSec Labs, sistema de puntos, ranking, laboratorios, etc.).
- **Vectorización**: `TfidfVectorizer(ngram_range=(1,2), sublinear_tf=True)` de scikit-learn.
- **Similitud**: coseno entre el vector de la consulta y la matriz del corpus.
- **Umbral**: solo se incluyen FAQs con `score >= 0.10`. Si la pregunta es de ciberseguridad general (XSS, SQL injection, etc.), normalmente no supera el umbral y el modelo responde desde su conocimiento base.
- **Normalización Unicode**: tanto el corpus como la consulta se normalizan antes de indexar/buscar (`"qué" == "que"`, `"cómo" == "como"`), usando `unicodedata.normalize("NFD")` más eliminación de diacríticos.

### Proveedor LLM

El chatbot usa **Groq** con el modelo `llama-3.3-70b-versatile`. Requiere la variable `GROQ_API_KEY` en `chatbot/.env`.

Groq expone una API compatible con OpenAI, por lo que se usa el cliente `openai.AsyncOpenAI` apuntando a `https://api.groq.com/openai/v1`.

### Lectura SSE en el frontend

`ChatWidget` usa un patrón de buffer acumulativo para manejar correctamente fragmentos de línea SSE que llegan divididos entre múltiples llamadas a `reader.read()`:

```ts
const reader = res.body.getReader()
const decoder = new TextDecoder()
let buffer = ''

while (true) {
  const { done, value } = await reader.read()
  if (done) break

  buffer += decoder.decode(value, { stream: true })
  const lines = buffer.split('\n')
  buffer = lines.pop() ?? ''   // la última línea puede estar incompleta

  for (const line of lines) {
    if (!line.startsWith('data: ')) continue
    const payload = line.slice(6).trim()
    if (payload === '[DONE]') continue
    const { chunk } = JSON.parse(payload)
    // acumula chunk en el mensaje del asistente
  }
}
```

### Variables de entorno del chatbot

```env
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Comandos del microservicio

```bash
# Desde la carpeta chatbot/
pip install -r requirements.txt

# Iniciar en desarrollo (puerto 8002)
uvicorn main:app --reload --port 8002
```

En producción, Railway usa `uvicorn main:app --host 0.0.0.0 --port $PORT` según `chatbot/railway.json`.

---

## 14. Glosario de Términos

**Bundle / Build** — El proceso de compilar y empaquetar el código fuente (TypeScript, JSX, CSS) en archivos optimizados que el navegador puede ejecutar directamente.

**CDN** — *Content Delivery Network*. Red de servidores distribuidos globalmente que sirven los archivos estáticos desde el servidor más cercano al usuario, reduciendo la latencia.

**Context API** — Mecanismo nativo de React para compartir estado entre componentes sin necesidad de pasar props manualmente por cada nivel del árbol de componentes.

**CSR** — *Client-Side Rendering*. El navegador descarga un HTML mínimo y JavaScript, y React renderiza la interfaz en el cliente. Contrasta con SSR (Server-Side Rendering).

**ESLint** — Herramienta de análisis estático para JavaScript/TypeScript que detecta errores, malas prácticas y problemas de estilo en el código.

**Hook** — Función de React que permite usar características como estado (`useState`) o efectos secundarios (`useEffect`) dentro de componentes funcionales. Los hooks personalizados (como `useAuth`, `useTheme`, `useToast`) encapsulan lógica reutilizable.

**Hot Reload** — Característica del dev server de Vite que actualiza automáticamente el navegador cuando se guarda un archivo, sin perder el estado de la aplicación.

**JSX** — *JavaScript XML*. Extensión de sintaxis de JavaScript que permite escribir estructuras similares a HTML dentro de código JS. React las convierte en llamadas a funciones.

**LocalStorage** — API del navegador para guardar datos como strings en el disco local. El frontend la usa para persistir el token JWT y la preferencia de tema entre sesiones.

**Microservicio** — Servicio independiente con responsabilidad única que se despliega y escala por separado. El chatbot Uchi es un microservicio Python que el frontend llama directamente, sin pasar por el backend principal.

**PrivateRoute** — Componente que verifica si el usuario tiene sesión activa antes de renderizar su contenido. Si no la tiene, redirige al login.

**RAG** — *Retrieval-Augmented Generation*. Técnica que recupera documentos relevantes (FAQs en `knowledge.json`) y los inyecta en el contexto del LLM antes de generar la respuesta, mejorando la precisión sin reentrenar el modelo.

**SPA** — *Single Page Application*. Aplicación web que carga una sola página HTML y actualiza el contenido dinámicamente con JavaScript, sin recargas completas del navegador.

**SSE** — *Server-Sent Events*. Protocolo HTTP unidireccional (servidor → cliente) para transmitir datos en tiempo real. El chatbot lo usa para enviar tokens del LLM a medida que se generan, produciendo el efecto de escritura en tiempo real.

**Toast** — Notificación flotante no bloqueante que aparece brevemente en pantalla para informar al usuario sobre el resultado de una acción (éxito, error o información).

**TypeScript** — Superset de JavaScript con tipos estáticos. Detecta errores de tipado en tiempo de desarrollo. Se "compila" a JavaScript normal para el navegador.

**Vite** — Herramienta moderna de build para proyectos frontend. Usa ES Modules nativos en desarrollo (arranque instantáneo) y Rolldown en producción (bundle optimizado).

**VITE_API_URL** — Variable de entorno que le dice al frontend dónde está el backend principal (Hono). Vite la inyecta en el código durante el build, por lo que el valor queda fijo en el bundle resultante.

**VITE_CHATBOT_URL** — Variable de entorno que le dice al frontend dónde está el microservicio Python de Uchi. Usada únicamente por `ChatWidget.tsx`.
