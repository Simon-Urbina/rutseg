# RutSeg — Laboratorios de Ciberseguridad

Plataforma de aprendizaje en ciberseguridad donde los usuarios se inscriben en cursos, trabajan laboratorios prácticos, completan actividades interactivas y responden quizzes. Los usuarios acumulan puntos al completar laboratorios y pueden descargar un certificado en PDF al completar un curso al 100%. Incluye un panel de administración para gestionar cursos/módulos/labs/preguntas y usuarios.

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Runtime | [Bun](https://bun.sh/) |
| Frontend | React 19 + TypeScript + Vite + Tailwind CSS v4 |
| Backend | Hono 4 |
| Email | Gmail API (OAuth2 via HTTP) |
| Chatbot | FastAPI + Python + Groq (llama-3.3-70b-versatile) |
| Base de datos | PostgreSQL en [Supabase](https://supabase.com/) |
| Despliegue backend | [Railway](https://railway.app/) |
| Despliegue frontend | [Vercel](https://vercel.com/) |
| Despliegue chatbot | [Railway](https://railway.app/) |

---

## Estructura del repositorio

```
cybersec-labs/
├── backend/
│   ├── database/
│   │   └── schema.sql          # Esquema idempotente (seguro re-ejecutar)
│   └── src/
│       ├── index.ts             # Entrada Hono + CORS
│       ├── db/index.ts          # Conexión postgres
│       ├── middleware/auth.ts   # requireAuth / optionalAuth / requireAdmin
│       ├── types.ts             # TokenPayload y tipos compartidos
│       ├── models/              # Clases de dominio (sin ORM)
│       ├── daos/                # Acceso a datos (SQL crudo con postgres)
│       ├── services/            # Lógica de negocio
│       ├── controllers/         # Manejo request/response
│       ├── routes/              # Definición de rutas Hono
│       ├── assets/logo.svg      # Copia local del logo, usada por CertificateService (PDF)
│       └── utils/               # errors.ts, response.ts, email.ts, certificate.ts
├── chatbot/
│   ├── main.py                  # FastAPI — endpoint /chat/stream (SSE)
│   ├── config.py                # Cliente Groq (openai-compatible)
│   ├── prompts.py               # System prompt con contexto de página
│   ├── retriever.py             # RAG con TF-IDF sobre knowledge.json
│   ├── knowledge.json           # Base de conocimiento de la plataforma
│   ├── requirements.txt         # Dependencias Python
│   └── railway.json             # Configuración de despliegue en Railway
└── frontend/
    └── src/
        ├── context/             # AuthContext, ThemeContext
        ├── lib/                 # api.ts — cliente HTTP centralizado; adminApi.ts — cliente de /api/admin/*
        ├── components/          # Header, Footer, CourseCard, Ranking, ChatWidget, modals…
        └── pages/               # Landing, Login, Register, ForgotPassword, ResetPassword,
                                 # Dashboard, CoursePage, LabPage, PublicProfilePage,
                                 # AboutPage, ForumPage, VerifyCertificatePage,
                                 # PrivacyPolicyPage, TermsOfUsePage, NotFoundPage
            └── admin/           # Panel de administración (solo rol admin): cursos/módulos/labs/
                                 # preguntas, gestión de usuarios y estadísticas — ver
                                 # docs/Documentacion/Documentacion-Frontend.md §5
```

---

## Primeros pasos

### Prerrequisitos

- [Bun](https://bun.sh/) instalado (incluye runtime, bundler y gestor de paquetes)
- Una base de datos PostgreSQL (recomendado: Supabase)

### 1. Clonar e instalar dependencias

```bash
# Backend
cd backend
bun install

# Frontend
cd ../frontend
bun install
```

### 2. Variables de entorno

**`backend/.env`**
```env
DATABASE_URL=postgresql://user:password@host:5432/dbname
JWT_SECRET=tu_secreto_muy_seguro
PORT=3000
FRONTEND_URL=http://localhost:5173
GMAIL_SENDER_EMAIL=tucorreo@gmail.com
GMAIL_CLIENT_ID=xxxxx.apps.googleusercontent.com
GMAIL_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
GMAIL_REFRESH_TOKEN=1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GOOGLE_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

> `GOOGLE_CLIENT_ID` es para **login social** (Sign in with Google) — solo se usa para verificar la firma del `id_token` que manda el frontend, no requiere client secret en el backend. Puede ser el mismo OAuth Client que `GMAIL_CLIENT_ID` o uno nuevo — son usos independientes (enviar correo vs. login), pero comparten el mismo proyecto de Google Cloud si quieres.
>
> El login con Microsoft está soportado en el backend (tabla `user_oauth_accounts`, provider `'microsoft'`) pero temporalmente sin implementar en `oauthProviders.ts`/rutas/frontend — el registro de la app en Azure quedó pendiente.

**`frontend/.env`** (además de las ya existentes)
```env
VITE_GOOGLE_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

**`chatbot/.env`**
```env
GROQ_API_KEY=gsk_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
RUTSEG_API_URL=http://localhost:3000
CATALOG_REFRESH_SECONDS=3600
```

> `RUTSEG_API_URL` y `CATALOG_REFRESH_SECONDS` son opcionales (con esos valores por defecto) —
> se usan para refrescar en background el catálogo de cursos que el chatbot conoce, llamando a
> `GET /api/courses` (público) cada `CATALOG_REFRESH_SECONDS` segundos. Ver
> `docs/Documentacion/Documentacion-Frontend.md` §13.

**`frontend/.env`**
```env
VITE_API_URL=http://localhost:3000
VITE_CHATBOT_URL=http://localhost:8002
```

### 3. Inicializar la base de datos

Ejecuta `backend/database/schema.sql` en el editor SQL de Supabase (o en cualquier cliente PostgreSQL). El script es idempotente: puede ejecutarse varias veces sin errores.

### 4. Correr en desarrollo

```bash
# Backend (hot reload con --watch)
cd backend
bun dev          # → http://localhost:3000

# Frontend (en otra terminal)
cd frontend
bun dev          # → http://localhost:5173
```

**Chatbot (opcional, solo si vas a trabajar en Uchi):** usa un entorno virtual propio de Python,
separado de cualquier otro proyecto en la máquina — evita choques de versiones entre paquetes de
distintos proyectos (`fastapi`/`starlette` son especialmente sensibles a esto).

```bash
cd chatbot
python -m venv .venv

# Activar el entorno
.venv\Scripts\activate      # Windows
source .venv/bin/activate   # macOS/Linux

pip install -r requirements.txt
uvicorn main:app --reload --port 8002   # → http://localhost:8002
```

---

## Paquetes instalados

### Backend (`backend/package.json`)

| Paquete | Versión | Uso |
|---------|---------|-----|
| `hono` | ^4.12.5 | Framework web |
| `hono-rate-limiter` | ^0.5.3 | Límite de peticiones por IP (general y estricto en `/api/auth/*`) |
| `postgres` | ^3.4.8 | Driver PostgreSQL (SQL crudo) |
| `jsonwebtoken` | ^9.0.3 | Generación y verificación de JWT (sesión propia de RutSeg) |
| `jose` | ^6.2.8 | Verifica la firma de los `id_token` de Google en el login social |
| `drizzle-orm` | ^0.45.1 | ORM (instalado, las queries usan `postgres` directamente) |
| `pdfkit` | ^0.19.1 | Genera el PDF del certificado de finalización |
| `svg-to-pdfkit` | ^0.1.8 | Dibuja el logo (SVG) vectorialmente dentro del PDF del certificado |
| `@types/bun` | ^1.3.10 | Tipos de Bun |
| `@types/jsonwebtoken` | ^9.0.9 | Tipos de jsonwebtoken |
| `@types/node` | ^24.10.1 | Tipos de Node |
| `@types/pdfkit` | ^0.17.6 | Tipos de pdfkit |
| `typescript` | ~5.9.3 | Compilador TypeScript |

> El hashing de contraseñas usa `Bun.password.hash` / `Bun.password.verify` (API nativa de Bun, sin paquete adicional).

### Frontend (`frontend/package.json`)

| Paquete | Versión | Uso |
|---------|---------|-----|
| `react` | ^19.2.0 | UI |
| `react-dom` | ^19.2.0 | Renderizado DOM |
| `react-router-dom` | ^7.14.2 | Enrutamiento SPA |
| `tailwindcss` | ^4.2.4 | Estilos utilitarios |
| `@tailwindcss/vite` | ^4.2.4 | Plugin Tailwind para Vite |
| `vite` | ^7.3.1 | Dev server y bundler |
| `@vitejs/plugin-react` | ^5.1.1 | Plugin React para Vite |
| `@vercel/analytics` | ^2.0.1 | Analytics de Vercel |
| `@vercel/speed-insights` | ^2.0.0 | Speed Insights de Vercel |
| `use-sound` | ^5.0.0 | Reproducción de efectos de sonido con React hooks |
| `@types/howler` | ^2.2.12 | Tipos TypeScript para Howler.js (peer dep de use-sound) |
| `recharts` | ^3.10.1 | Gráficas del panel de estadísticas admin (`/admin/analytics`) |
| `typescript` | ~5.9.3 | Compilador TypeScript |
| `eslint` | ^9.39.1 | Linter |
| `typescript-eslint` | ^8.48.0 | Reglas ESLint para TS |

---

## Comandos de referencia

### Backend

```bash
bun dev          # Desarrollo con hot reload
bun start        # Producción
```

### Frontend

```bash
bun dev          # Dev server en localhost:5173
bun run build    # tsc -b + vite build (producción)
bun run lint     # ESLint
bun preview      # Vista previa del build de producción
```

---

## API — Endpoints disponibles

Base URL: `http://localhost:3000`

### Estadísticas (`/api/stats`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/stats` | — | Métricas globales (cursos, labs, usuarios, puntos) |

### Autenticación (`/api/auth`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/api/auth/register` | — | Paso 1 del registro: valida datos y envía código de 6 dígitos al email |
| POST | `/api/auth/verify-email` | — | Paso 2 del registro: verifica el código y crea el usuario → devuelve JWT |
| POST | `/api/auth/resend-verification` | — | Reenviar código de verificación |
| POST | `/api/auth/login` | — | Iniciar sesión → devuelve JWT |
| POST | `/api/auth/logout` | Bearer | Cerrar sesión |
| POST | `/api/auth/forgot-password` | — | Enviar email de restablecimiento |
| POST | `/api/auth/reset-password` | — | Restablecer contraseña con token |
| POST | `/api/auth/google` | — | Login/registro con Google (recibe `idToken` de Google Identity Services) |

### Usuarios (`/api/users`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/users/me` | Bearer | Perfil propio |
| PUT | `/api/users/me` | Bearer | Actualizar perfil (username, bio…) |
| POST | `/api/users/me/password` | Bearer | Cambiar contraseña |
| POST | `/api/users/me/avatar` | Bearer | Subir foto de perfil |
| GET | `/api/users/:username` | — | Perfil público |

### Cursos (`/api/courses`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/courses` | Opcional | Listar cursos publicados |
| GET | `/api/courses/:slug` | Opcional | Detalle de un curso |
| POST | `/api/courses/:slug/enroll` | Bearer | Inscribirse en un curso |
| GET | `/api/courses/:slug/modules` | — | Módulos del curso |
| GET | `/api/courses/:slug/modules/:moduleSlug/labs` | — | Laboratorios del módulo |
| GET | `/api/courses/:slug/modules/:moduleSlug/labs/:labSlug` | Bearer | Detalle de un laboratorio |
| GET | `/api/courses/:slug/certificate` | Bearer | Descargar certificado de finalización en PDF (requiere 100% del curso completado) |

### Actividades y envíos

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/api/activities/:activityId/attempt` | Bearer | Intentar una actividad práctica |
| POST | `/api/labs/:labId/submit` | Bearer | Enviar quiz del laboratorio (5 respuestas) |

### Ranking

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/ranking` | — | Tabla de clasificación global |

### Foro (`/api/forum`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/forum` | Opcional | Comentarios raíz paginados (20/página) con conteo de respuestas |
| GET | `/api/forum/:id/replies` | Opcional | Respuestas de un comentario |
| POST | `/api/forum` | Bearer | Crear comentario raíz |
| POST | `/api/forum/:id/replies` | Bearer | Responder a un comentario |
| DELETE | `/api/forum/:id` | Bearer | Eliminar comentario propio (o cualquiera si `admin`) |

### Certificados (`/api/certificates`)

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | `/api/certificates/verify?username=&courseSlug=&code=` | — | Verificación pública de un certificado (sin sesión) |

### Administración (`/api/admin`) — solo rol `admin`

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/admin/courses` | Crear curso |
| PUT | `/api/admin/courses/:id` | Actualizar curso |
| DELETE | `/api/admin/courses/:id` | Borrar curso (cascada: módulos, labs, matrículas, progreso) |
| POST | `/api/admin/courses/:courseId/modules` | Crear módulo |
| PUT | `/api/admin/modules/:id` | Actualizar módulo |
| DELETE | `/api/admin/modules/:id` | Borrar módulo (cascada: labs, preguntas, progreso) |
| GET | `/api/admin/labs/:id` | Detalle de un laboratorio con preguntas, opciones y actividades |
| POST | `/api/admin/modules/:moduleId/labs` | Crear laboratorio |
| PUT | `/api/admin/labs/:id` | Actualizar laboratorio (despublica solo si queda incompleto) |
| DELETE | `/api/admin/labs/:id` | Borrar laboratorio (cascada: preguntas, progreso) |
| POST | `/api/admin/labs/:labId/questions` | Agregar pregunta (máx. 5) |
| PUT | `/api/admin/questions/:id` | Actualizar pregunta |
| DELETE | `/api/admin/questions/:id` | Borrar pregunta |
| POST | `/api/admin/questions/:questionId/options` | Agregar opción de respuesta |
| PUT | `/api/admin/questions/:questionId/options/:id` | Actualizar opción |
| DELETE | `/api/admin/questions/:questionId/options/:id` | Borrar opción |
| POST | `/api/admin/questions/:questionId/activity` | Crear actividad práctica |
| PUT | `/api/admin/activities/:id` | Actualizar actividad |
| GET | `/api/admin/users?page=&limit=&search=` | Listado paginado de usuarios (búsqueda por username/email) |
| GET | `/api/admin/users/:id` | Detalle de un usuario |
| PUT | `/api/admin/users/:id` | Editar username/email/bio/rol (un admin no puede quitarse el rol a sí mismo) |
| POST | `/api/admin/users/:id/password` | Establece una nueva contraseña sin pedir la actual |
| DELETE | `/api/admin/users/:id` | Borra un usuario (soft-delete; un admin no puede auto-eliminarse) |
| GET | `/api/admin/analytics?range=7d\|1m\|1y\|5y` | KPIs y 11 gráficas del panel de estadísticas (usuarios, puntos, cursos, actividad) |

### Health check

```
GET /health  →  { "status": "ok" }
```

---

## Arquitectura del backend

```
Routes → Controllers → Services → DAOs → PostgreSQL
```

- **Routes**: definen los endpoints y aplican middlewares (`requireAuth`, `optionalAuth`, `requireAdmin`)
- **Controllers**: reciben `Context` de Hono y delegan a Services
- **Services**: lógica de negocio (cálculo de `score_percent`, validaciones, etc.)
- **DAOs**: queries SQL crudas usando el driver `postgres`
- **Models**: clases de dominio con métodos de proyección (`toPublic()`, `toSummary()`, `toAdmin()`, `toProfile()`, `toSession()`, `toRankingRow()`)

### Autenticación

JWT via header `Authorization: Bearer <token>`. Tres middlewares:
- `optionalAuth`: adjunta el usuario si el token es válido; no falla si no hay token
- `requireAuth`: exige token válido (401 si no)
- `requireAdmin`: exige token válido con `role === 'admin'` (403 si no)

---

## Esquema de base de datos

Jerarquía principal: `courses → course_modules → laboratories → laboratory_questions → laboratory_question_options / question_activities`

### Tablas

| Tabla | Descripción |
|-------|-------------|
| `users` | Usuarios con soft-delete (`deleted_at`) |
| `courses` | Cursos con slug único y dificultad (`principiante`, `intermedio`, `avanzado`) |
| `course_modules` | Módulos ordenados por posición dentro de un curso |
| `laboratories` | Laboratorios con contenido Markdown, puntos y quiz de exactamente 5 preguntas |
| `laboratory_questions` | Preguntas tipo `multiple_choice` o `activity_response` |
| `laboratory_question_options` | Opciones para preguntas de opción múltiple |
| `question_activities` | Actividad práctica vinculada 1:1 a una pregunta |
| `user_activity_progress` | Progreso del usuario por actividad |
| `activity_action_logs` | Registro de cada intento en una actividad |
| `submissions` | Envíos de quiz (exactamente 5 respuestas por envío) |
| `user_laboratory_progress` | Mejor puntaje y estado por usuario/laboratorio |
| `course_enrollments` | Inscripciones usuario-curso |
| `forum_comments` | Comentarios del foro comunitario con soft-delete; `parent_id IS NULL` = raíz, `parent_id = <id>` = respuesta (máx. un nivel) |

### Triggers automáticos

1. `activity_action_logs` INSERT → upserta `user_activity_progress`
2. `submissions` INSERT → upserta `user_laboratory_progress`
3. `user_laboratory_progress` cambia a `completed` (primera vez) → suma `laboratories.points` a `users.points`

---

## Despliegue

### Base de datos — Supabase

Ejecutar `backend/database/schema.sql` en el Editor SQL de Supabase.

### Backend — Railway

Variables de entorno requeridas:
```
DATABASE_URL
JWT_SECRET
PORT
FRONTEND_URL=https://rutseg.vercel.app
GMAIL_SENDER_EMAIL
GMAIL_CLIENT_ID
GMAIL_CLIENT_SECRET
GMAIL_REFRESH_TOKEN
GOOGLE_CLIENT_ID
```

> El email se envía directo por la **API HTTP de Gmail con OAuth2** (no SMTP — Railway bloquea los puertos SMTP salientes). El correo sale firmado por Google mismo desde `GMAIL_SENDER_EMAIL`, por lo que no necesita dominio propio ni verificación de remitente en un tercero. `GMAIL_CLIENT_ID`/`GMAIL_CLIENT_SECRET` salen de un OAuth Client en Google Cloud Console, y `GMAIL_REFRESH_TOKEN` se obtiene una sola vez autorizando el scope `gmail.send` para `GMAIL_SENDER_EMAIL`.

Configuración en `backend/railway.json`.

### Chatbot — Railway (servicio separado)

Variables de entorno requeridas:
```
GROQ_API_KEY
RUTSEG_API_URL=https://tu-backend.up.railway.app
```

> **Importante:** en Railway, `RUTSEG_API_URL` **debe** apuntar al dominio público real del
> servicio backend — el valor por defecto (`http://localhost:3000`) solo funciona en desarrollo
> local, donde ambos procesos corren en la misma máquina. Si se deja el default en producción, el
> chatbot nunca logra refrescar el catálogo de cursos (falla en silencio cada hora y sigue usando
> el catálogo de respaldo desactualizado) — no rompe el chat, pero Uchi no se entera de cursos
> nuevos. `CATALOG_REFRESH_SECONDS` es opcional (default 3600 = 1 hora).

Configuración en `chatbot/railway.json`. Railway detecta Python por `requirements.txt` e inicia con `uvicorn main:app --host 0.0.0.0 --port $PORT`.

### Frontend — Vercel

Conectar el repositorio en Vercel con:
- **Root Directory**: `frontend`
- **Framework**: Vite

Variables de entorno requeridas:
```
VITE_API_URL=https://tu-backend.up.railway.app
VITE_CHATBOT_URL=https://tu-chatbot.up.railway.app
VITE_GOOGLE_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

> **Login social:** en Google Cloud Console (Credentials → tu OAuth Client) agrega `https://rutseg.vercel.app` y `http://localhost:5173` en "Authorized JavaScript origins". Login con Microsoft pendiente de agregar (ver nota en la sección de variables de entorno del backend).

El archivo `frontend/vercel.json` configura el enrutamiento SPA — todas las rutas se redirigen a `index.html` para que React Router funcione correctamente al acceder directamente a una URL (ej: `/reset-password`, `/dashboard`).

---

## Documentación adicional

Todo vive en `docs/Documentacion/`:

| Documento | Contenido |
|---|---|
| [`Documentacion-Backend.md`](docs/Documentacion/Documentacion-Backend.md) | Arquitectura en capas, modelos, base de datos, auth, endpoints, roadmap |
| [`Documentacion-Frontend.md`](docs/Documentacion/Documentacion-Frontend.md) | Estructura de páginas, componentes, panel admin, catálogo del chatbot |
| [`Documentacion-Seguridad.md`](docs/Documentacion/Documentacion-Seguridad.md) | Auditoría de seguridad — ver pendientes abajo |
| [`Documentacion-Errores-Historicos.md`](docs/Documentacion/Documentacion-Errores-Historicos.md) | Historial de bugs reales encontrados y corregidos desde el primer commit, con causa raíz y evidencia de cada uno |

### Seguridad — pendientes conocidos

Según la última auditoría (`Documentacion-Seguridad.md`, actualizada 2026-08-15):

- ✅ **Rate limiting** — implementado en backend (`hono-rate-limiter`) y chatbot (`slowapi`). En `/api/auth/*` el límite es **por cuenta** (IP + email), no solo por IP, para que un grupo grande de personas en la misma red (ej. una demo en vivo) no se bloquee entre sí, mientras cada cuenta sigue protegida contra fuerza bruta. Pendiente: límite de tamaño de body.
- 🔴 **Row Level Security (RLS) de Supabase no verificable desde el código** — requiere confirmarse manualmente en el panel de Supabase, no solo en `schema.sql`.
- 🟡 **Sin registro de intentos de ataque** (auth fallida repetida, 403 en rutas admin, etc.) — no hay logging dedicado a detectar abuso.

El resto de la auditoría (RBAC, protección de rutas, SQL parametrizado, manejo de errores, aislamiento del chatbot) está correcto. Ver el documento completo para detalle y el checklist priorizado.

---

## Créditos y referencias

- **[Josh W. Comeau](https://www.joshwcomeau.com/)** — Implementación de animaciones interactivas (`Boop`, `Sparkles`) y efectos de sonido (`use-sound`). Artículos de referencia:
  - [Announcing use-sound](https://www.joshwcomeau.com/react/announcing-use-sound-react-hook/)
  - [Boop!](https://www.joshwcomeau.com/react/boop/)
  - [Animated Sparkles in React](https://www.joshwcomeau.com/react/animated-sparkles-in-react/)
