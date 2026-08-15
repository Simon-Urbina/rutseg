# Documentación de Seguridad — RutSeg

> **Audience:** Equipo del proyecto (Semillero de Investigación en Ciberseguridad y Desarrollo de
> Software, USTA Tunja) y cualquier revisor técnico que evalúe la postura de seguridad de la
> plataforma.
> **Fecha:** 2026-08-14
> **Alcance:** Auditoría manual del código fuente actual (`backend/`, `frontend/`, `chatbot/`) más
> la configuración de despliegue documentada en `README.md`. No incluye pentesting activo contra el
> entorno desplegado, ni acceso al panel de Supabase/Railway/Vercel — donde algo depende de
> configuración de infraestructura y no de código, se marca explícitamente como **"no verificable
> desde el repositorio"**.

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Límite de Peticiones (Rate Limiting)](#2-límite-de-peticiones-rate-limiting)
3. [Gestión de Llaves y Secretos](#3-gestión-de-llaves-y-secretos)
4. [Control de Acceso por Roles (RBAC)](#4-control-de-acceso-por-roles-rbac)
5. [Protección del Sistema de Puntos](#5-protección-del-sistema-de-puntos)
6. [Validación y Filtrado de Datos de Entrada](#6-validación-y-filtrado-de-datos-de-entrada)
7. [Exposición de la Base de Datos](#7-exposición-de-la-base-de-datos)
8. [Protección de Rutas — Auditoría Completa](#8-protección-de-rutas--auditoría-completa)
9. [Manejo de Errores y Fuga de Información](#9-manejo-de-errores-y-fuga-de-información)
10. [Registro y Detección de Ataques](#10-registro-y-detección-de-ataques)
11. [Aislamiento del Chatbot Frente a la Base de Datos](#11-aislamiento-del-chatbot-frente-a-la-base-de-datos)
12. [Escaneo Adicional — `backend/database/`](#12-escaneo-adicional--backenddatabase)
13. [Checklist Priorizado de Acciones](#13-checklist-priorizado-de-acciones)

---

## 1. Resumen Ejecutivo

| # | Pregunta | Veredicto | Severidad |
|---|---|---|---|
| 1 | Rate limiting | Implementado en backend (por cuenta en auth) y chatbot; pendiente límite de tamaño de body | 🟢 OK (menor) |
| 2 | Llaves fuera del código | Correcto, con una excepción | 🟡 MEDIO |
| 3 | Reglas de acceso por rol | Correcto | 🟢 OK |
| 4 | Puntos protegidos | Correcto | 🟢 OK |
| 5 | Filtrado de datos de entrada | Correcto, con matices | 🟢 OK (menor) |
| 6 | Ninguna tabla abierta por defecto | **No verificable desde el código — acción manual requerida** | 🔴 ALTO |
| 7 | Rutas protegidas | Correcto | 🟢 OK |
| 8 | Errores no filtran información | Correcto, con una excepción menor | 🟡 BAJO |
| 9 | Registro para detectar ataques | **No implementado** | 🟡 MEDIO |
| 10 | Chatbot sin acceso a la BD | Correcto | 🟢 OK |

**Lectura rápida:** la arquitectura del backend (capas, validación, SQL parametrizado, RBAC) está
sólida. El rate limiting ya está resuelto en backend y chatbot (2026-08-15, §2), con un diseño
pensado explícitamente para no bloquear a un grupo grande de personas usando la misma red (ej. una
demo en vivo) mientras sigue protegiendo cada cuenta contra fuerza bruta. El hueco real que sigue
abierto es **la imposibilidad de confirmar desde el código que Row Level Security (RLS) está activo
en Supabase**, que requiere una acción manual en el panel de Supabase, no un cambio de código. El
resto de preguntas ya están cubiertas por decisiones de diseño
existentes.

---

## 2. Límite de Peticiones (Rate Limiting)

**Veredicto: implementado en backend y chatbot (2026-08-15) — pendiente solo el límite de tamaño
de body.**

### 2.1 Backend (`backend/src/middleware/rateLimit.ts`, `hono-rate-limiter`)

La primera versión (misma fecha, mismo día) usaba un único límite por IP en `/api/auth/*` — se
corrigió horas después al notar que **muchas personas en la misma red comparten una sola IP
pública tras el NAT del router** (el caso real que motivó el cambio: presentar la plataforma en
vivo frente a un grupo grande, donde todos los asistentes están en el mismo wifi). Un límite por
IP demasiado estricto ahí bloquearía a los asistentes entre sí, no a un atacante. Diseño final, tres
middlewares montados en `backend/src/index.ts` antes de las rutas:

| Middleware | Alcance | Clave | Límite | Ventana |
|---|---|---|---|---|
| `apiRateLimiter` | `/api/*` (toda la API) | IP | 2000 peticiones | 15 minutos |
| `authIpLimiter` | `/api/auth/*` | IP | 600 peticiones | 15 minutos |
| `authAccountLimiter` | `/api/auth/*` **con `email` en el body** (login, registro, verificación, reenvío, olvidé-mi-contraseña) | IP + email | 20 peticiones | 15 minutos |

`authAccountLimiter` es el que da la protección real contra fuerza bruta — al incluir el email en
la clave, el límite es **por cuenta**, no por IP: 400 personas registrándose desde la misma IP de
un congreso consumen 400 contadores independientes (uno por email), mientras que 20+ intentos
seguidos contra **la misma** cuenta sí se bloquean, sin importar cuántas otras personas compartan
esa IP. Las rutas sin `email` en el body (`/api/auth/google`, `/api/auth/logout`,
`/api/auth/reset-password`, que valida un token largo en vez de un email) se saltan
`authAccountLimiter` por completo (`skip`) y solo quedan cubiertas por el techo genérico de
`authIpLimiter`.

Todos identifican al cliente por IP vía `X-Forwarded-For` (Railway sí lo establece correctamente
como proxy delante del backend — verificado con los headers `x-railway-edge` en producción; cae a
la IP del socket crudo solo en desarrollo local, donde no hay proxy). Al superar el límite, la API
responde `429 Too Many Requests` con headers estándar `RateLimit-*`/`Retry-After`, y el header CORS
se preserva correctamente en esa respuesta (Hono conserva los headers seteados antes de `next()`
incluso en respuestas de error).

**Verificado en desarrollo** (dos escenarios, misma IP simulada vía `X-Forwarded-For`):
- 15 cuentas **distintas** haciendo login con la misma IP → las 15 pasan (401 por password
  incorrecta, no 429) — el escenario de "muchas personas, una sola IP" no se bloquea entre sí.
- 25 intentos contra **la misma** cuenta, misma IP → los primeros 20 pasan (401), el 21.º en
  adelante recibe `429` — la protección contra fuerza bruta real sigue intacta.
- 25 peticiones a `/api/auth/google` (sin `email` en el body) desde la misma IP → ninguna golpea
  el límite de cuenta (confirma que `skip` funciona), solo el techo de 600 de `authIpLimiter`
  aplicaría en un abuso real.

**Limitación conocida:** el store es en memoria (`MemoryStore`, el que trae `hono-rate-limiter` por
defecto) — los contadores se reinician si el proceso de Railway se reinicia (deploy, crash). Es el
mismo tipo de limitación que ya existe en `pendingRegistrations`/`resetTokens` (ver
`Documentacion-Errores-Historicos.md` §2.2). Aceptable a esta escala (una sola instancia); si el
backend llegara a correr en más de una instancia, los límites se dividirían entre instancias en vez
de compartirse — en ese caso hay que migrar a `RedisStore` (ya soportado por la misma librería, ver
`node_modules/hono-rate-limiter`).

### 2.2 Chatbot (`chatbot/main.py`, `slowapi`)

`POST /chat/stream` ahora usa `@limiter.limit("300/10minutes")` por IP (mismo criterio de
`X-Forwarded-For` que el backend, vía un `get_client_ip` propio — `slowapi.util.get_remote_address`
por defecto usa la IP del socket crudo, que en Railway sería la del proxy). Sin concepto de "cuenta"
en este endpoint (no requiere autenticación), así que el límite es solo por IP, pero deliberadamente
generoso por la misma razón que el backend: soportar una demo en vivo frente a un grupo grande sin
bloquearlos, mientras sigue acotando un script que le pegue al endpoint sin parar (agotaría 300
peticiones en minutos, protegiendo la cuota de la API key de Groq). Verificado con un servidor de
prueba aislado (mismo patrón, límite bajo para probar rápido): las peticiones dentro del límite
pasan, las que lo exceden reciben `429`, y el header CORS se preserva en esa respuesta.

**Pendiente (no cubierto por este cambio):** no hay límite de tamaño de body configurado en Hono ni
en FastAPI (ej. 1MB para JSON) — ya existe el límite de 5MB específico para avatares en
`User.validateProfileImage`, pero no un límite genérico de body a nivel de framework.

---

## 3. Gestión de Llaves y Secretos

**Veredicto: correcto en general — ninguna llave real está commiteada — con una excepción a corregir.**

### 3.1 Lo que está bien

- `.gitignore` excluye explícitamente `.env`, `.env.*`, `backend/.env`, `frontend/.env`,
  `chatbot/.env` en todos los niveles, permitiendo solo `*.env.example`.
- Se revisó el historial completo de git (`git log --all --diff-filter=A`) buscando archivos `.env`
  commiteados alguna vez: **solo existen `chatbot/.env.example` y `frontend/.env.example`** — nunca
  se commiteó un `.env` real con secretos.
- `chatbot/config.py` lee `GROQ_API_KEY` de variable de entorno sin ningún fallback hardcodeado
  (`os.getenv("GROQ_API_KEY", "")` — si falta, simplemente falla en la llamada a Groq, no hay una
  key "de repuesto" débil).
- `backend/src/middleware/auth.ts` — `getSecret()` **lanza un error si `JWT_SECRET` no está
  definido** en vez de usar un valor por defecto. Los tokens de sesión (login) nunca pueden firmarse
  con una llave débil conocida.

### 3.2 Hallazgo — fallback de secreto hardcodeado

`backend/src/utils/response.ts:9` y `backend/src/utils/certificate.ts:7` tienen:

```typescript
const secret = process.env.JWT_SECRET ?? 'fallback-secret'
```

A diferencia de `middleware/auth.ts`, estas dos funciones (`generateActivityResponse` y
`generateCertificateCode`) **no fallan si `JWT_SECRET` no está definido** — silenciosamente usan el
string literal `'fallback-secret'`, visible en el código fuente público del repositorio.

**Impacto si `JWT_SECRET` llegara a faltar en producción** (ej. error de configuración en Railway):
cualquiera que lea el código fuente (público en GitHub) podría calcular el hash HMAC esperado para
cualquier actividad o certificado, sin necesitar el secreto real — falsificando respuestas de
actividades prácticas o códigos de verificación de certificados.

**Severidad:** Media — requiere que la variable de entorno real falte para ser explotable (no es
explotable hoy si `JWT_SECRET` está bien configurado en Railway), pero es el tipo de fallo silencioso
que no se nota hasta que ya causó daño.

**Recomendación:** aplicar el mismo patrón que `middleware/auth.ts` — lanzar un error al arrancar si
`JWT_SECRET` no existe, en vez de degradar silenciosamente a un secreto público conocido.

---

## 4. Control de Acceso por Roles (RBAC)

**Veredicto: correcto.**

`backend/src/middleware/auth.ts` define tres niveles, cada uno verifica el JWT y aplica una regla
distinta:

| Middleware | Regla |
|---|---|
| `optionalAuth` | Adjunta el usuario si el token es válido; nunca bloquea la petición |
| `requireAuth` | Exige token válido — 401 si falta o expiró |
| `requireAdmin` | Exige token válido **y** `role === 'admin'` — 403 si no |

`backend/src/routes/admin.ts:22` aplica `router.use('*', requireAdmin)` **a nivel de router**, antes
de registrar cualquier ruta — es decir, es estructuralmente imposible agregar un endpoint nuevo bajo
`/api/admin` y olvidar protegerlo, porque el middleware se aplica a todo el router de una vez, no
ruta por ruta.

Reglas de negocio adicionales verificadas en `backend/src/routes/admin.ts`:
- Un admin no puede quitarse el rol de administrador a sí mismo (`PUT /users/:id:354`).
- Un admin no puede eliminar su propia cuenta (`DELETE /users/:id:388`).

No se encontró ningún endpoint mutante (POST/PUT/PATCH/DELETE) sin `requireAuth` o `requireAdmin`
explícito — ver la auditoría completa en §8.

---

## 5. Protección del Sistema de Puntos

**Veredicto: correcto — los puntos no son editables directamente por ningún endpoint.**

Los puntos (`users.points`) solo cambian por dos caminos, ninguno de los cuales acepta un valor
arbitrario del cliente:

1. **Trigger de base de datos** `trg_award_laboratory_points` (`Documentacion-Backend.md` §6.4):
   se dispara automáticamente cuando `user_laboratory_progress.status` cambia a `'completed'` por
   primera vez, y suma `laboratories.points` (un valor fijado por el admin al crear el lab, no por el
   usuario). El cliente nunca envía "cuántos puntos gané" — el servidor lo calcula a partir de
   respuestas correctas / 5.
2. **Panel admin** (`PUT /api/admin/users/:id`, `backend/src/routes/admin.ts:323`): el `patch` que se
   construye ahí solo acepta `username`, `email`, `bio` y `role` — **`points` no está en la lista de
   campos aceptados**, así que aunque un admin envíe `{ "points": 999999 }` en el body, se ignora
   silenciosamente (no llega a `UserDAO.update`).

No existe ningún endpoint `PATCH /api/users/me` ni similar que permita a un usuario normal modificar
su propio campo `points`.

---

## 6. Validación y Filtrado de Datos de Entrada

**Veredicto: correcto, con dos matices menores de defensa en profundidad.**

### 6.1 Lo que está bien

- **SQL Injection:** todas las queries usan el tagged template `sql\`...\`` de la librería
  `postgres`, que parametriza automáticamente cualquier `${valor}` interpolado. Se buscó
  específicamente el uso de `sql.unsafe(` (el único escape hatch que permitiría SQL crudo sin
  parametrizar) en todo `backend/src/` — **no se encontró ninguna ocurrencia**.
- **Validación de formato:** cada modelo (`backend/src/models/*.ts`) tiene un `validate()` estático
  que se ejecuta antes de tocar la base de datos (ver `Documentacion-Backend.md` §5). Se aplica en
  registro, cursos, módulos, labs, preguntas, opciones, actividades y comentarios del foro.
- **XSS en contenido de laboratorios:** `LabPage.tsx` renderiza el markdown de los labs con
  `dangerouslySetInnerHTML`, lo cual sería peligroso si el contenido no se escapara — pero el parser
  casero (`markdownToHtml` → `inline()` → `esc()`, `LabPage.tsx:71-80`) **escapa `&`, `<` y `>` antes**
  de aplicar cualquier transformación de negrita/cursiva/código. Un `<script>` dentro del markdown de
  un lab se renderiza como texto literal, no se ejecuta.
- **XSS en contenido de usuarios:** el foro (`ForumPage.tsx:192`) y la bio del perfil
  (`PublicProfilePage.tsx`) se renderizan como texto JSX normal (`{comment.content}`, `{profile.bio}`)
  — React escapa esto automáticamente. **No hay `dangerouslySetInnerHTML` en ningún componente que
  reciba contenido escrito por un usuario normal** (el único otro uso de `dangerouslySetInnerHTML`,
  en `PrivacyPolicyPage.tsx:277`, renderiza un array de strings estático hardcodeado en el propio
  componente, no contenido de base de datos).

### 6.2 Matiz — mimetype de avatar confiado del cliente

`backend/src/controllers/UserController.ts:31-34` valida el avatar contra `file.type` (el
`Content-Type` que el navegador reporta para el archivo), no contra los bytes reales del archivo
(no hay "magic byte sniffing"). Un archivo con extensión/contenido distinto podría subirse si el
cliente falsifica el `Content-Type` a `image/jpeg`. Impacto acotado: el archivo se guarda como
`bytea` y solo se vuelve a servir como `data:image/jpeg;base64,...` dentro de una etiqueta `<img>`
— el navegador no ejecuta contenido arbitrario ahí, en el peor caso la imagen simplemente no
renderiza. Severidad baja, pero es una validación que vale la pena reforzar si se agrega más tipos de
archivo en el futuro.

### 6.3 Matiz — sin límite de tamaño en `contentMarkdown`

`Laboratory.validate()` (`backend/src/models/Laboratory.ts:32`) solo exige que `contentMarkdown` no
esté vacío — no hay un máximo de caracteres. Como el endpoint que lo escribe requiere `requireAdmin`
(§8), el riesgo está acotado a una cuenta de administrador ya comprometida o a un error humano, no a
un usuario cualquiera.

---

## 7. Exposición de la Base de Datos

**Veredicto: no verificable completamente desde el código — este es el hallazgo que requiere acción
manual más urgente.**

### 7.1 Lo que el código sí garantiza

El backend se conecta a Postgres directamente con la librería `postgres` sobre `DATABASE_URL`
(`backend/src/db/index.ts`) — **no** usa el SDK de Supabase (`@supabase/supabase-js`) ni expone
ninguna `anon key` al frontend. Se confirmó revisando `frontend/.env.example` y el README: las
únicas variables del frontend son `VITE_API_URL`, `VITE_CHATBOT_URL` y `VITE_GOOGLE_CLIENT_ID` — el
frontend **nunca** habla directo con Supabase, todo pasa por el backend Hono.

### 7.2 El riesgo que el código no puede confirmar ni descartar

Supabase genera automáticamente una **API REST pública (PostgREST)** para cada tabla creada en el
proyecto — accesible en `https://<proyecto>.supabase.co/rest/v1/<tabla>` — **independiente** de que
el backend de RutSeg exista o no. Esa API se protege exclusivamente con **Row Level Security (RLS)**
por tabla, configurada desde el dashboard de Supabase, no desde SQL commiteado a este repositorio.

Se revisó `backend/database/schema.sql` completo buscando `ENABLE ROW LEVEL SECURITY` o `CREATE
POLICY` — **no existe ninguna instrucción de RLS en el script de esquema.** Esto significa una de dos
cosas, y **no se puede distinguir cuál desde el código**:

- (a) RLS está activado tabla por tabla directamente desde el dashboard de Supabase (fuera de este
  repo) — en cuyo caso todo está bien, o
- (b) RLS nunca se activó, y **cualquiera con la `anon key` del proyecto podría leer y escribir
  directamente `users`, `submissions`, `laboratory_questions` (incluida la columna `is_correct` de
  las opciones — la respuesta correcta del quiz), saltándose por completo el backend y su lógica de
  negocio.**

La `anon key` no se usa en el frontend de RutSeg (§7.1), lo que reduce el riesgo de exposición
accidental, pero no es un secreto fuerte por diseño — Supabase la trata como "publicable" *porque*
espera que RLS la limite. Si alguien la obtiene por otra vía (dashboard compartido, capturas de
pantalla, otro proyecto que sí la exponga), sin RLS tendría acceso total.

**Acción requerida (no se puede resolver con una edición de código):**
1. Entrar al dashboard de Supabase → Authentication → Policies (o Database → Tables) y confirmar que
   **RLS está `ENABLED`** en las 13 tablas listadas en `Documentacion-Backend.md` §6.3, especialmente
   `users`, `submissions`, `laboratory_question_options` y `user_activity_progress`.
2. Si el proyecto no necesita el Data API de Supabase en absoluto (todo el acceso pasa por el backend
   Hono), la opción más simple y segura es **desactivar el Data API por completo** desde
   Project Settings → Data API, en vez de mantenerlo activo con políticas RLS complejas de mantener.
3. Documentar la decisión tomada (RLS activado con políticas, o Data API desactivado) en este mismo
   archivo una vez verificado, para que quede registro de que se revisó explícitamente.

---

## 8. Protección de Rutas — Auditoría Completa

Se revisaron los **11 archivos de rutas** del backend uno por uno. Todos los endpoints mutantes
(POST/PUT/PATCH/DELETE) que tocan datos de un usuario específico o contenido administrable están
protegidos. Los únicos endpoints públicos son los que **deben** serlo por diseño (login/registro,
catálogo de cursos, perfil público, verificación de certificados).

| Archivo | Endpoint | Auth |
|---|---|---|
| `auth.ts` | `POST /register`, `/verify-email`, `/resend-verification`, `/login`, `/forgot-password`, `/reset-password`, `/google` | Público (por diseño — son el propio flujo de autenticación) |
| `auth.ts` | `POST /logout` | `requireAuth` |
| `users.ts` | `GET /me`, `PUT /me`, `POST /me/password`, `POST /me/avatar` | `requireAuth` |
| `users.ts` | `GET /:username` | Público (perfil público, por diseño) |
| `courses.ts` | `GET /`, `GET /:slug`, `GET /:slug/modules`, `GET /:slug/modules/:m/labs` | Público u opcional (catálogo) |
| `courses.ts` | `POST /:slug/enroll`, `GET /:slug/modules/:m/labs/:l`, `GET /:slug/certificate` | `requireAuth` |
| `activities.ts` | `POST /:activityId/attempt` | `requireAuth` |
| `submissions.ts` | `GET /labs/:id/submissions`, `POST /labs/:id/submit`, `POST /labs/:id/check` | `requireAuth` |
| `ranking.ts` | `GET /` | Público (tabla de posiciones, por diseño) |
| `stats.ts` | `GET /` | Público (métricas agregadas, sin PII) |
| `forum.ts` | `GET /`, `GET /:id/replies` | Opcional |
| `forum.ts` | `POST /`, `POST /:id/replies`, `DELETE /:id` | `requireAuth` |
| `certificates.ts` | `GET /verify` | Público (por diseño — cualquiera debe poder verificar sin sesión) |
| `admin.ts` | **Todo el router** (cursos, módulos, labs, preguntas, opciones, actividades, usuarios) | `requireAdmin` aplicado una sola vez con `router.use('*', requireAdmin)` |

**No se encontró ningún endpoint que debiera estar protegido y no lo esté.** El único patrón a
vigilar hacia adelante: si se agrega un archivo de rutas nuevo, replicar el patrón de `admin.ts`
(`router.use('*', ...)`) es más seguro que proteger ruta por ruta, porque no depende de que cada
desarrollador recuerde agregar el middleware en cada línea nueva.

---

## 9. Manejo de Errores y Fuga de Información

**Veredicto: correcto en general, con una fuga menor de enumeración de cuentas.**

### 9.1 Lo que está bien

`backend/src/index.ts` tiene un único manejador global de errores (`app.onError`) que:
- Traduce cada subclase de `AppError` a su código HTTP correspondiente con el mensaje de negocio
  (nunca un stack trace).
- Para cualquier error **no reconocido** (`console.error(err)` + `500`), responde siempre el mismo
  mensaje genérico `'Error interno del servidor.'` — el detalle real del error solo se imprime en los
  logs del servidor (Railway), nunca llega al cliente.
- Ya existían protecciones explícitas contra enumeración de emails en `resend-verification` y
  `forgot-password`/`reset-password` (misma respuesta exista o no la cuenta — documentado en
  `Documentacion-Backend.md` §7.2/§7.3).
- `AuthService.login` (`backend/src/services/AuthService.ts:55-63`) responde el mismo
  `'Credenciales inválidas.'` tanto si el email no existe como si la contraseña es incorrecta — no
  revela cuál de las dos falló.

### 9.2 Hallazgo menor — enumeración vía login social

`AuthService.login:59-60`:

```typescript
if (!user.passwordHash)
  throw new UnauthorizedError('Esta cuenta inicia sesión con Google o Microsoft. Usa esa opción para ingresar.')
```

Si alguien intenta iniciar sesión con contraseña usando el email de una cuenta que se registró
**solo** por Google/Microsoft (sin contraseña propia), recibe un mensaje distinto al genérico
`'Credenciales inválidas.'` — confirmando indirectamente que ese email **sí** está registrado en
RutSeg. Es una fuga de información menor (confirma existencia de cuenta, no la contraseña), y
consistente con un problema conocido y ya mitigado en otros flujos (verificación, reset de
contraseña) — solo falta aplicar el mismo criterio aquí.

**Severidad:** Baja. **Recomendación:** si se quiere cerrar por completo, devolver el mismo mensaje
genérico y, opcionalmente, indicar el método correcto solo en un canal que no sea la respuesta
inmediata (o aceptar el trade-off actual, que es común en productos con login social — muchas
plataformas grandes tienen el mismo comportamiento).

---

## 10. Registro y Detección de Ataques

**Veredicto: no implementado.**

Se revisó todo `backend/src/` buscando cualquier forma de logging de seguridad (intentos de login
fallidos, bloqueos por rol, picos de tráfico, IPs sospechosas) — el único logging que existe es:
- `console.error(err)` para errores 500 no reconocidos (para debugging, no para seguridad).
- La tabla `activity_action_logs` (registro inmutable de intentos en actividades prácticas) — es un
  log de **negocio** (progreso del estudiante), no de seguridad.

No hay ningún mecanismo que registre, por ejemplo: múltiples `401` seguidos desde la misma IP,
intentos de acceso a `/api/admin/*` sin rol admin, o un usuario descargando certificados de cursos
que no completó (aunque esto último ya está bloqueado por `CertificateService.getCompletionStatus`,
§5, no queda registro de que alguien lo intentó).

Railway captura los logs de stdout del proceso (incluye los `console.error`), pero eso es
observabilidad básica, no detección de ataques — nadie recibe una alerta si hay un patrón anómalo.

**Recomendación (proporcional al tamaño del proyecto — no se necesita un SIEM):**
1. Loggear (a stdout, ya capturado por Railway) los intentos de login fallidos con email + timestamp,
   sin loggear la contraseña.
2. Loggear cada `403 Forbidden` de `requireAdmin` con el `userId` y la ruta solicitada — es la señal
   más barata de detectar a alguien probando a escalar privilegios.
3. Si el proyecto crece, considerar un servicio externo gratuito/económico (ej. Better Stack,
   Axiom) para centralizar y alertar sobre estos logs en vez de depender de revisar Railway
   manualmente.

---

## 11. Aislamiento del Chatbot Frente a la Base de Datos

**Veredicto: correcto — el chatbot no tiene ningún camino hacia la base de datos.**

Se revisó `chatbot/main.py`, `chatbot/config.py` y `chatbot/retriever.py` completos:

- **No hay ningún driver de base de datos** importado en el microservicio Python (no hay
  `psycopg2`, `asyncpg`, `sqlalchemy`, ni el equivalente Node `postgres`).
- **No existe la variable `DATABASE_URL`** ni ninguna variable de conexión a Postgres/Supabase en
  `chatbot/.env.example` ni en el código — las únicas credenciales del chatbot son `GROQ_API_KEY`.
- La única fuente de "conocimiento" del chatbot es `chatbot/knowledge.json`, un archivo estático
  bundleado en su propio despliegue (Railway, servicio separado del backend) — no una consulta en
  vivo a la base de datos de usuarios/cursos.
- El único servicio externo al que el chatbot se conecta es la API de Groq
  (`https://api.groq.com/openai/v1`, `chatbot/config.py:8`).

**Conclusión:** si el microservicio del chatbot fuera comprometido por completo (inyección de
prompt, RCE en una dependencia de Python, lo que sea), el atacante **no obtiene ningún acceso a la
base de datos de RutSeg** — ni credenciales que robar, ni conexión de red que abrir, porque
simplemente no existen en ese proceso. El "radio de explosión" de un ataque exitoso al chatbot se
limita a: (a) hacer que Uchi responda cosas indebidas, y (b) consumir la cuota de la API key de Groq.

### 11.1 Hallazgo aparte — CORS abierto en el chatbot

`chatbot/main.py:18-23`:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["*"],
)
```

`allow_origins=["*"]` permite que **cualquier sitio web**, no solo `rutseg.vercel.app`, llame a
`POST /chat/stream` desde el navegador de un visitante. No es un riesgo para la base de datos (§11
arriba); el rate limiting de §2.2 ya acota cuánto puede consumirse desde una sola IP, pero no
impide que un tercero incruste una llamada a este endpoint en una página ajena a RutSeg y consuma
la cuota de Groq desde su propia IP (menos grave que sin límite, pero sigue siendo tráfico ajeno
gastando presupuesto del proyecto). Comparar con el backend Hono (`backend/src/index.ts:20-31`),
que sí restringe `origin` a una lista blanca (`FRONTEND_URL` + subdominios `*.vercel.app` de
RutSeg) — correcto ahí, pendiente en el chatbot.

**Recomendación:** restringir `allow_origins` en el chatbot a los mismos orígenes que ya usa el
backend (`FRONTEND_URL` y los previews de Vercel de RutSeg), en vez de `"*"`.

---

## 12. Escaneo Adicional — `backend/database/`

Revisión enfocada de los 6 archivos SQL (`schema.sql`, `seed.sql`, `seed2.sql`,
`owasp1_controlAccess.sql`, `owasp5_inyection.sql`, `owasp7_authFailures.sql` — ~370KB en total) a
pedido explícito, buscando específicamente: credenciales reales commiteadas, objetos SQL ejecutables
peligrosos ocultos en el contenido de los cursos OWASP, y configuración de conexión a la base de
datos.

### 12.1 Positivo — el contenido "vulnerable" de los cursos OWASP es solo texto, nunca código vivo

Se revisaron los tres archivos `owasp1_controlAccess.sql`, `owasp5_inyection.sql` y
`owasp7_authFailures.sql` completos. **Ninguno contiene `CREATE FUNCTION`, `CREATE TRIGGER`,
`GRANT`, `CREATE ROLE` ni `DROP`** — son exclusivamente sentencias `INSERT INTO
courses/course_modules/laboratories/laboratory_questions/laboratory_question_options/
question_activities`. El contenido que "enseña" SQL injection, IDOR o fallos de autenticación vive
como **texto** en columnas `content_markdown` / `instructions_markdown`, exactamente igual que
cualquier otro laboratorio — no crean tablas trampa, ni funciones vulnerables reales, ni usuarios de
base de datos con permisos débiles. El material didáctico está completamente aislado de la base de
datos real.

### 12.2 Positivo — el "terminal" de los labs no ejecuta nada de verdad

Dado que la documentación describe los labs como "terminal interactiva" y "ejecutas comandos
reales", se verificó específicamente si existe alguna forma de ejecución de comandos en el servidor
(`child_process`, `spawn`, pty, Docker, sandbox). **No existe ninguna** — se confirmó buscando en
todo `backend/src/`. `ActivityService.attempt()` (`backend/src/services/ActivityService.ts:29-32`)
hace una simple comparación de strings (`submitted === activity.expectedActionKey.trim()`) contra un
valor fijado por el admin al crear la actividad. Esto es una decisión de diseño correcta desde el
punto de vista de seguridad: elimina por completo la clase de vulnerabilidad más grave que podría
tener una plataforma de "laboratorios prácticos" (ejecución remota de comandos vía la terminal de un
lab).

### 12.3 Positivo — constraints a nivel de base de datos como defensa en profundidad

`schema.sql` usa `CHECK` constraints de forma consistente incluso donde el backend ya valida lo
mismo: `points >= 0`, `score_percent BETWEEN 0 AND 100`, `question_order BETWEEN 1 AND 5`,
`jsonb_array_length(answers) = 5`, y un índice único parcial que garantiza **a nivel de Postgres**
que una pregunta de selección múltiple no puede tener dos opciones marcadas como correctas
(`idx_laboratory_question_single_correct_option`, línea 360-362). Si algún día un bug en el backend
se saltara la validación de `Model.validate()`, la base de datos igual rechazaría el dato inválido.

### 12.4 Hallazgo — verificación TLS deshabilitada en la conexión a la base de datos

`backend/src/db/index.ts:15`:

```typescript
ssl: DATABASE_URL.includes('supabase.co') ? { rejectUnauthorized: false } : false,
```

Al conectar a Supabase, la conexión Postgres usa TLS (los datos van cifrados) pero
**`rejectUnauthorized: false` desactiva la verificación del certificado del servidor** — el cliente
nunca comprueba que el certificado presentado por el otro extremo esté firmado por una autoridad
confiable ni que coincida con el host esperado. En términos prácticos: la conexión está cifrada pero
no autenticada, lo que la deja teóricamente expuesta a un atacante en la ruta de red (on-path) que
pudiera interceptar el tráfico entre Railway y Supabase y presentar un certificado propio sin que el
driver lo note.

Es una configuración común en tutoriales de Supabase (por compatibilidad con su *pooler*, que a
veces usa certificados que Node no reconoce por defecto), pero no es la más segura disponible.

**Severidad:** Media — requiere control de la ruta de red entre Railway y Supabase, que no es
trivial de conseguir para un atacante externo, pero es una garantía de TLS debilitada
innecesariamente.

**Recomendación:** Supabase publica el certificado CA de su *pooler*
(`Project Settings → Database → SSL Configuration` en el dashboard). Se puede pasar ese certificado
como `ssl: { ca: <certificado>, rejectUnauthorized: true }` en vez de desactivar la verificación por
completo — mantiene la compatibilidad sin renunciar a la autenticación del servidor.

### 12.5 Hallazgo menor — datos que *parecen* credenciales reales en un repo público

Dos archivos contienen valores que imitan la forma de una credencial real, aunque **ninguno es
explotable**:

- `schema.sql:507-509` — `INSERT INTO users (...) VALUES ('admin', 'admin@example.com',
  '<hash-aqui>', 'admin')`. El valor `<hash-aqui>` es un placeholder literal, no un hash real — si
  se ejecutara tal cual, ese usuario nunca podría iniciar sesión con ninguna contraseña (el hash no
  tiene formato válido para `Bun.password.verify`). Mezclar una plantilla de seed dentro del script
  de esquema es confuso, pero no es explotable.
- `seed.sql:8-16` — `INSERT INTO users (...) VALUES ('admin', 'admin@cybersec.com',
  '$2b$10$abcdefghijklmnopqrstuvwx.yzABCDEFGHIJKLMNOPQRSTUVWXYZ12', 'admin', ...)`. **Se verificó
  que este NO es un hash bcrypt real** — es el alfabeto en orden secuencial disfrazado con el
  prefijo `$2b$10$` de bcrypt. No corresponde a ninguna contraseña real y no se puede crackear
  porque no es un hash genuino.

**Por qué igual vale la pena arreglarlo:** el repositorio es público (verificado con la API de
GitHub, ver documento previo de seguridad). Un string con la forma exacta de un hash bcrypt junto a
un email de admin es el tipo de patrón que los escáneres automáticos de secretos (GitHub Secret
Scanning, GitGuardian, TruffleHog) suelen marcar como posible credencial filtrada, generando ruido
y confusión — y alguien que reutilice `seed.sql` como plantilla podría no notar que el hash es falso
y asumir que es un ejemplo funcional.

**Recomendación:** reemplazar ambos placeholders por algo inequívocamente no-funcional, ej.
`'SEED_PLACEHOLDER_REEMPLAZAR_ANTES_DE_USAR'` en vez de un string con forma de hash bcrypt.

---

## 13. Checklist Priorizado de Acciones

Ordenado de mayor a menor impacto/urgencia:

- [ ] **[ALTO]** Verificar en el dashboard de Supabase que RLS está `ENABLED` en las 13 tablas de
      `schema.sql`, o desactivar el Data API si no se usa (§7).
- [x] **[ALTO]** ~~Agregar rate limiting al backend, con límite por cuenta (no solo por IP) en
      `/api/auth/*`~~ — hecho 2026-08-15, `backend/src/middleware/rateLimit.ts` (§2.1).
- [ ] **[MEDIO]** Restringir `allow_origins` del chatbot a los dominios reales de RutSeg, no `"*"`
      (§11.1).
- [x] **[MEDIO]** ~~Agregar rate limiting básico al chatbot (`/chat/stream`)~~ — hecho 2026-08-15,
      `chatbot/main.py` con `slowapi` (§2.2).
- [ ] **[MEDIO]** Hacer que `generateActivityResponse()` y `generateCertificateCode()` lancen error
      si `JWT_SECRET` falta, en vez de usar `'fallback-secret'` (§3.2).
- [ ] **[MEDIO]** Agregar logging de intentos de login fallidos y de `403` en rutas admin (§10).
- [ ] **[BAJO]** Validar el tipo real del archivo de avatar (magic bytes), no solo el `Content-Type`
      reportado por el cliente (§6.2).
- [ ] **[BAJO]** Agregar un máximo de caracteres a `contentMarkdown` en `Laboratory.validate()` (§6.3).
- [ ] **[BAJO]** Unificar el mensaje de error cuando se intenta login con contraseña en una cuenta
      OAuth-only, para no confirmar indirectamente que el email existe (§9.2).
- [ ] **[MEDIO]** Habilitar verificación TLS real en la conexión a Supabase usando su certificado CA,
      en vez de `rejectUnauthorized: false` (§12.4).
- [ ] **[BAJO]** Reemplazar los placeholders con forma de hash bcrypt en `schema.sql` y `seed.sql`
      por un string obviamente no-funcional (§12.5).

Ninguno de estos pendientes es una vulnerabilidad crítica explotable hoy contra el sistema tal como
está desplegado (los dos [ALTO] son ausencias de una capa de defensa, no un bug activo); se listan
en orden de qué tan barato es que alguien las explote si nada cambia.
