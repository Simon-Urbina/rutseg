# Documentación Técnica del Backend — RutSeg

> **Audience:** Desarrolladores o estudiantes que quieran entender cómo está construido el backend de esta plataforma.  
> **Fecha:** 2026-08-09

---

## Tabla de Contenidos

1. [Visión General](#1-visión-general)
2. [Stack Tecnológico](#2-stack-tecnológico)
3. [Estructura de Carpetas](#3-estructura-de-carpetas)
4. [Arquitectura en Capas](#4-arquitectura-en-capas)
5. [Modelos de Dominio y Validación](#5-modelos-de-dominio-y-validación)
6. [Base de Datos](#6-base-de-datos)
7. [Autenticación y Autorización](#7-autenticación-y-autorización)
8. [Endpoints de la API](#8-endpoints-de-la-api)
9. [Lógica de Negocio Clave](#9-lógica-de-negocio-clave)
10. [Manejo de Errores](#10-manejo-de-errores)
11. [Variables de Entorno](#11-variables-de-entorno)
12. [Despliegue](#12-despliegue)
13. [Glosario de Términos](#13-glosario-de-términos)

> **Nota:** La sección 8 incluye los endpoints del foro (8.8) y los de administración se renumeraron a 8.9.

---

## 1. Visión General

El backend de RutSeg es una **API REST** (Interfaz de Programación basada en HTTP) que sirve como núcleo de la plataforma de aprendizaje. Su responsabilidad es:

- Gestionar usuarios (registro, login, perfiles, ranking).
- Proveer el catálogo de cursos, módulos y laboratorios.
- Registrar el progreso de cada usuario en actividades y quizzes.
- Otorgar puntos automáticamente al completar un laboratorio.
- Exponer rutas exclusivas para administradores que permiten crear y editar contenido.
- Gestionar el foro comunitario: comentarios raíz y respuestas de un solo nivel.

> **Iniciativa académica:** RutSeg nació como proyecto del **Semillero de Investigación en Ciberseguridad y Desarrollo de Software** de la Universidad Santo Tomás — Tunja, bajo la iniciativa y dirección del docente **Harrizon Alexander Soler Galindo**.

El servidor escucha peticiones HTTP del frontend (React) y responde siempre en formato **JSON**.

---

## 2. Stack Tecnológico

| Componente | Tecnología | Para qué sirve |
|---|---|---|
| **Runtime** | [Bun](https://bun.sh) | Ejecuta JavaScript/TypeScript directamente, sin necesidad de compilar a Node.js. Es más rápido que Node para arrancar y ejecutar. |
| **Framework HTTP** | [Hono](https://hono.dev) v4.12 | Define las rutas de la API y maneja peticiones/respuestas. Es ultra-ligero y optimizado para Bun. |
| **Base de datos** | PostgreSQL en [Supabase](https://supabase.com) | Motor de base de datos relacional. Supabase es un servicio en la nube que lo aloja. |
| **Driver de DB** | `postgres` v3.4 | Librería que permite ejecutar consultas SQL directamente desde TypeScript. |
| **Autenticación** | JSON Web Tokens (JWT) via `jsonwebtoken` v9 | Genera y verifica tokens de sesión. |
| **Hashing de contraseñas** | `Bun.password` (built-in) | Función nativa de Bun para almacenar contraseñas de forma segura. |
| **Lenguaje** | TypeScript | JavaScript con tipado estático, compila a JS pero con más seguridad en tiempo de desarrollo. |
| **Despliegue** | [Railway](https://railway.app) | Plataforma en la nube que aloja y ejecuta el servidor. |

---

## 3. Estructura de Carpetas

```
backend/
├── src/
│   ├── index.ts                 ← Punto de entrada: crea el servidor y registra las rutas
│   ├── types.ts                 ← Definiciones TypeScript de todos los tipos de datos
│   ├── db/
│   │   └── index.ts             ← Configuración y conexión a la base de datos
│   ├── middleware/
│   │   └── auth.ts              ← Funciones que se ejecutan ANTES de los controladores
│   ├── routes/
│   │   ├── auth.ts              ← Define qué URL lleva a qué controlador (autenticación)
│   │   ├── users.ts             ← Rutas de perfil de usuario
│   │   ├── courses.ts           ← Rutas de cursos, módulos y laboratorios
│   │   ├── activities.ts        ← Rutas de actividades prácticas
│   │   ├── submissions.ts       ← Rutas de envío de quizzes
│   │   ├── ranking.ts           ← Ruta de tabla de posiciones
│   │   ├── stats.ts             ← Ruta de estadísticas públicas
│   │   ├── admin.ts             ← Rutas exclusivas del administrador
│   │   └── forum.ts             ← Rutas del foro comunitario
│   ├── controllers/
│   │   ├── AuthController.ts    ← Extrae datos del request y llama al Service correcto
│   │   ├── UserController.ts
│   │   ├── CourseController.ts
│   │   ├── ActivityController.ts
│   │   ├── SubmissionController.ts
│   │   └── ForumController.ts   ← Controlador del foro
│   ├── services/
│   │   ├── AuthService.ts       ← Contiene la lógica de negocio de autenticación
│   │   ├── UserService.ts
│   │   ├── CourseService.ts
│   │   ├── ActivityService.ts
│   │   ├── SubmissionService.ts
│   │   └── ForumService.ts      ← Lógica del foro (paginación, validaciones, soft-delete)
│   ├── daos/
│   │   ├── UserDAO.ts           ← Consultas SQL relacionadas con usuarios
│   │   ├── CourseDAO.ts
│   │   ├── CourseModuleDAO.ts
│   │   ├── CourseEnrollmentDAO.ts
│   │   ├── LaboratoryDAO.ts
│   │   ├── LaboratoryQuestionDAO.ts
│   │   ├── LaboratoryQuestionOptionDAO.ts
│   │   ├── QuestionActivityDAO.ts
│   │   ├── SubmissionDAO.ts
│   │   ├── ActivityActionLogDAO.ts
│   │   ├── UserActivityProgressDAO.ts
│   │   ├── UserLaboratoryProgressDAO.ts
│   │   └── ForumCommentDAO.ts   ← Consultas SQL del foro (findRoots, findReplies, create, softDelete)
│   ├── models/
│   │   ├── User.ts              ← Clase de dominio con validate() y proyecciones
│   │   ├── Course.ts
│   │   ├── CourseModule.ts
│   │   ├── Laboratory.ts
│   │   ├── LaboratoryQuestion.ts
│   │   ├── LaboratoryQuestionOption.ts
│   │   ├── QuestionActivity.ts
│   │   ├── Submission.ts
│   │   ├── CourseEnrollment.ts
│   │   ├── ActivityActionLog.ts
│   │   ├── UserActivityProgress.ts
│   │   ├── UserLaboratoryProgress.ts
│   │   ├── ForumComment.ts      ← Modelo del foro: validate(), isDeleted, toPublic()
│   │   └── index.ts             ← Re-exporta todos los modelos
│   └── utils/
│       ├── errors.ts            ← Jerarquía de errores de dominio (AppError y subclases, sin acoplamiento HTTP)
│       ├── response.ts          ← Generador de respuestas para actividades
│       └── email.ts             ← Envío de correos vía Gmail REST API (verificación y reset)
├── database/
│   ├── schema.sql               ← Script SQL que crea todas las tablas
│   └── seed.sql                 ← Datos de ejemplo para pruebas
├── package.json
├── tsconfig.json
└── railway.json                 ← Configuración de despliegue en Railway
```

---

## 4. Arquitectura en Capas

El backend sigue un patrón de **arquitectura en capas** (*layered architecture*). Cada capa tiene una responsabilidad específica y solo puede hablar con la capa inmediatamente inferior. Esto hace el código más organizado, fácil de mantener y de probar.

```
HTTP Request
     ↓
┌─────────────┐
│   Routes    │  Define qué URL activa qué función. También aplica middleware.
└──────┬──────┘
       ↓
┌─────────────┐
│ Middleware  │  Se ejecuta antes del controller: verifica tokens JWT, valida roles.
└──────┬──────┘
       ↓
┌─────────────┐
│ Controllers │  "Recepcionistas": extraen datos del request (body, params, headers)
│             │  y delegan el trabajo al Service. Formatean la respuesta HTTP.
└──────┬──────┘
       ↓
┌─────────────┐
│  Services   │  "Cerebro": contienen la lógica de negocio. Llaman a Model.validate(),
│             │  verifican reglas que requieren DB, coordinan múltiples DAOs.
└──────┬──────┘
       ↓
┌─────────────┐
│   Models    │  Clases de dominio con validación de formato y proyecciones de datos.
│             │  No acceden a la DB. Solo conocen las reglas del negocio.
└──────┬──────┘
       ↓
┌─────────────┐
│    DAOs     │  "Archivistas": ejecutan consultas SQL. Solo saben hablar con la DB.
│  (Data Access│  Devuelven instancias de los modelos.
│   Objects)  │
└──────┬──────┘
       ↓
┌─────────────┐
│  PostgreSQL │  Base de datos. Almacena todos los datos de forma persistente.
│             │  Triggers automatizan la actualización de progreso y puntos.
└─────────────┘
```

### ¿Por qué esta separación?

- Si mañana se cambia PostgreSQL por otra base de datos, solo se modifican los DAOs.
- Si cambia una regla de negocio (ej: el quiz requiere 6 preguntas en vez de 5), solo se edita el Service y el Model.
- Si cambia el formato de la respuesta HTTP, solo se toca el Controller.
- Si cambia una regla de formato (ej: el username permite hasta 60 caracteres), solo se toca el Model.

### Ejemplo del flujo completo: usuario envía un quiz

```
POST /api/labs/:labId/submit

1. Route (submissions.ts)
   └─ Aplica requireAuth middleware → verifica JWT → agrega userId al contexto

2. Middleware (auth.ts)
   └─ Extrae el token del header Authorization, lo verifica, pone el user en c.set('user', payload)

3. SubmissionController.submit()
   └─ Extrae labId de los params y answers del body
   └─ Llama a SubmissionService.submit(userId, labId, answers)

4. SubmissionService.submit()
   └─ Verifica que el laboratorio exista y esté publicado
   └─ Verifica que lleguen exactamente 5 respuestas
   └─ Verifica que el usuario esté inscrito en el curso padre
   └─ Verifica que cada questionId pertenezca al lab
   └─ Para cada respuesta:
       - Si es multiple_choice: busca la opción y verifica is_correct
       - Si es activity_response: compara el texto contra el hash guardado en user_activity_progress
   └─ Calcula scorePercent = (correctas / 5) × 100

5. SubmissionDAO.create()
   └─ INSERT INTO submissions (...)
   └─ La base de datos ejecuta el trigger trg_sync_user_laboratory_progress_from_submission
      que actualiza user_laboratory_progress automáticamente
   └─ Si es la primera vez que completa con ≥ 60% → trigger agrega los puntos al usuario

6. SubmissionController devuelve:
   { submissionId, attemptNumber, correctAnswersCount, totalQuestions, scorePercent, pointsEarned }
   con HTTP 201 (Created)
```

---

## 5. Modelos de Dominio y Validación

Los **modelos** (`src/models/`) son clases TypeScript simples (sin ORM) que representan las entidades del sistema. Tienen dos responsabilidades:

1. **Validar** datos de entrada antes de persistirlos (método `static validate()`).
2. **Proyectar** datos hacia el exterior con el mínimo de información necesaria (métodos `toPublic()`, `toProfile()`, etc.).

### 5.1 Sistema de Validación

La validación ocurre en **dos lugares** del sistema:

```
Request body (datos crudos del HTTP)
        ↓
  Controller extrae los datos
        ↓
  Service llama a Model.validate(datos)
        ↓ ← si hay errores, lanza ValidationError (HTTP 400)
  Service verifica reglas de negocio con DB
        ↓ ← si hay conflictos, lanza ConflictError / NotFoundError / ForbiddenError, etc.
  DAO inserta datos válidos en PostgreSQL
```

**Lugar 1 — Modelos:** validan *formato y estructura* de los datos. No acceden a la base de datos.

**Lugar 2 — Services:** validan *reglas de negocio* que requieren consultar la base de datos (unicidad de email, existencia de recursos, matrícula del usuario, etc.).

### 5.2 Validaciones por Modelo

#### `User.validate()`

Valida los datos de registro de un nuevo usuario.

```typescript
User.validate({ username, email, password })
```

| Campo | Regla | Error |
|---|---|---|
| `username` | 3–50 caracteres | `'El username debe tener entre 3 y 50 caracteres.'` |
| `email` | Formato válido (`x@x.x`) | `'El email no tiene un formato válido.'` |
| `password` | Mínimo 8 caracteres | `'La contraseña debe tener al menos 8 caracteres.'` |

#### `User.validateProfileImage()`

Valida el archivo de foto de perfil.

```typescript
User.validateProfileImage({ mimetype, size })
```

| Campo | Regla | Error |
|---|---|---|
| `mimetype` | Solo `image/jpeg` o `image/jpg` | `'La foto de perfil solo acepta formato JPG/JPEG.'` |
| `size` | Máximo 5 MB (5 × 1024 × 1024 bytes) | `'La foto de perfil no puede superar los 5 MB.'` |

#### `Course.validate()`

Valida los datos de creación o edición de un curso.

```typescript
Course.validate({ slug, title, difficulty? })
```

| Campo | Regla | Error |
|---|---|---|
| `slug` | Solo letras minúsculas, números y guiones (`/^[a-z0-9-]+$/`) | `'El slug solo puede contener letras minúsculas, números y guiones.'` |
| `title` | 3–180 caracteres | `'El título debe tener entre 3 y 180 caracteres.'` |
| `difficulty` | Uno de: `principiante`, `intermedio`, `avanzado` | `'La dificultad debe ser una de: principiante, intermedio, avanzado.'` |

#### `ForumComment.validate()`

Valida el contenido de un comentario del foro antes de insertarlo.

```typescript
ForumComment.validate({ content })
```

| Campo | Regla | Error |
|---|---|---|
| `content` | No puede estar vacío (string con al menos 1 carácter) | `'El comentario no puede estar vacío.'` |
| `content` | Máximo 2000 caracteres | `'El comentario no puede superar los 2000 caracteres.'` |

El modelo también expone:
- `get isDeleted(): boolean` — `true` si `deletedAt !== null`.
- `toPublic(author, replyCount)` — devuelve `{ id, content, author, parentId, replyCount, createdAt, isDeleted }`. Si el comentario está eliminado, `content` = `'[comentario eliminado]'` y `author` = `null`.

#### `CourseModule.validate()`

Valida los datos de un módulo dentro de un curso.

```typescript
CourseModule.validate({ slug, title, position })
```

| Campo | Regla | Error |
|---|---|---|
| `slug` | Solo letras minúsculas, números y guiones | mismo que Course |
| `title` | 3–180 caracteres | mismo que Course |
| `position` | Entero mayor a 0 | `'La posición debe ser un entero mayor a 0.'` |

#### `Laboratory.validate()`

Valida los datos de un laboratorio dentro de un módulo.

```typescript
Laboratory.validate({ slug, title, contentMarkdown, position, estimatedMinutes, points })
```

| Campo | Regla | Error |
|---|---|---|
| `slug` | Solo letras minúsculas, números y guiones | mismo que Course |
| `title` | 3–180 caracteres | mismo que Course |
| `contentMarkdown` | No puede estar vacío | `'El contenido en markdown no puede estar vacío.'` |
| `position` | Entero mayor a 0 | `'La posición debe ser un entero mayor a 0.'` |
| `estimatedMinutes` | Entero mayor a 0 | `'El tiempo estimado debe ser un entero mayor a 0.'` |
| `points` | Entero ≥ 0 | `'Los puntos deben ser un entero igual o mayor a 0.'` |

#### `LaboratoryQuestion.validate()`

Valida los datos de una pregunta de quiz.

```typescript
LaboratoryQuestion.validate({ questionOrder, questionType, questionText })
```

| Campo | Regla | Error |
|---|---|---|
| `questionOrder` | Entero entre 1 y 5 | `'El orden de pregunta debe estar entre 1 y 5.'` |
| `questionType` | Uno de: `multiple_choice`, `activity_response` | `'El tipo de pregunta debe ser uno de: multiple_choice, activity_response.'` |
| `questionText` | No puede estar vacío | `'El texto de la pregunta no puede estar vacío.'` |

### 5.3 Validaciones de Negocio en Services

Además del formato, los Services verifican reglas que requieren consultar la base de datos:

| Service | Validación | Tipo de error | HTTP |
|---|---|---|---|
| `AuthService.prepareRegistration` | Email no registrado previamente | `ConflictError` | 409 |
| `AuthService.prepareRegistration` | Username no tomado | `ConflictError` | 409 |
| `AuthService.login` | Usuario existe y contraseña coincide | `UnauthorizedError` | 401 |
| `SubmissionService.submit` | Laboratorio existe y está publicado | `NotFoundError` | 404 |
| `SubmissionService.submit` | Exactamente 5 respuestas enviadas | `BadRequestError` | 400 |
| `SubmissionService.submit` | Usuario inscrito en el curso padre | `ForbiddenError` | 403 |
| `SubmissionService.submit` | Cada `questionId` pertenece al lab | `BadRequestError` | 400 |
| `CourseService.getLaboratory` | Usuario inscrito para ver el lab | `ForbiddenError` | 403 |
| `ForumService.createReply` | El comentario padre existe y es raíz (no es ya una respuesta) | `BadRequestError` | 400 |
| `ForumService.deleteComment` | El solicitante es dueño del comentario o tiene rol `admin` | `ForbiddenError` | 403 |

### 5.4 Proyecciones de Datos (Principio de Mínimo Privilegio)

Cada modelo expone distintas "vistas" de sus datos para evitar exponer información sensible. El Service usa la proyección apropiada según el contexto:

| Método | Datos expuestos | Usado en |
|---|---|---|
| `user.toSession()` | `id, username, email, role` | Payload del JWT |
| `user.toPublic()` | `id, username, bio, points` | Perfil público (`/u/:username`) |
| `user.toProfile()` | `id, username, email, bio, points, role, createdAt` | Propio perfil (`/users/me`) |
| `user.toRankingRow()` | `id, username, bio, points` | Tabla de ranking |
| `course.toPublic()` | `id, slug, title, description, difficulty` | Lista de cursos |
| `course.toAdmin()` | Todos los campos incluyendo `isPublished`, `createdBy` | Panel admin |
| `lab.toSummary()` | Sin `contentMarkdown` | Listado de labs en módulo |
| `lab.toPublic()` | Con `contentMarkdown` | Vista completa del lab |
| `question.toQuiz()` | Sin `explanation` | Durante el quiz activo |
| `question.toResult()` | Con `explanation` | Retroalimentación post-submission |
| `user.toAdmin()` | `id, username, email, bio, role, points, createdAt, updatedAt` (sin `passwordHash` ni `profileImage`) | Panel admin — gestión de usuarios |

---

## 6. Base de Datos

### 6.1 Motor y Conexión

Se usa **PostgreSQL** (alojado en Supabase). La conexión se configura en `src/db/index.ts`:

```typescript
const sql = postgres(process.env.DATABASE_URL, {
  transform: {
    // Convierte nombres de columnas de snake_case (DB) a camelCase (JS)
    // Ejemplo: password_hash → passwordHash
    column: { from: camelCaseConverter }
  },
  ssl: { rejectUnauthorized: false },  // Requerido por Supabase
  prepare: false,   // Desactivado para compatibilidad con el pooler de Supabase
  max: 10,          // Máximo 10 conexiones simultáneas
  idle_timeout: 20  // Cierra conexiones inactivas después de 20 segundos
})
```

> **Nota sobre `prepare: false`:** Supabase usa un *connection pooler* (PgBouncer) que no soporta *prepared statements*. Por eso se desactiva esta optimización.

### 6.2 Jerarquía de Contenido

```
courses
  └── course_modules  (un curso tiene varios módulos)
        └── laboratories  (un módulo tiene varios laboratorios)
              └── laboratory_questions  (un lab tiene exactamente 5 preguntas)
                    ├── laboratory_question_options  (opciones de respuesta múltiple)
                    └── question_activities  (actividad práctica, relación 1:1)
```

### 6.3 Tablas Principales

#### `users`
Almacena todos los usuarios de la plataforma.

| Columna | Tipo | Descripción |
|---|---|---|
| `id` | UUID | Identificador único generado automáticamente |
| `username` | VARCHAR(50) | Nombre de usuario único |
| `email` | VARCHAR(120) | Email único |
| `password_hash` | TEXT | Contraseña hasheada (nunca en texto plano) |
| `role` | ENUM | `'user'` o `'admin'` |
| `bio` | TEXT | Descripción del perfil |
| `profile_image` | BYTEA | Imagen guardada como bytes (no como URL) |
| `points` | INTEGER | Puntos acumulados, empieza en 0 |
| `deleted_at` | TIMESTAMPTZ | Si tiene valor, el usuario está eliminado (soft delete) |

> **Soft delete:** En vez de borrar el registro de la base de datos (lo que podría causar problemas de integridad), se marca con una fecha en `deleted_at`. Las consultas filtran por `WHERE deleted_at IS NULL`.

#### `courses`
| Columna | Tipo | Descripción |
|---|---|---|
| `slug` | VARCHAR(120) | Identificador legible en URLs, ej: `intro-linux-seguridad` |
| `difficulty` | ENUM | `principiante`, `intermedio`, `avanzado` |
| `is_published` | BOOLEAN | Solo los publicados aparecen para usuarios normales |

#### `laboratories`
| Columna | Tipo | Descripción |
|---|---|---|
| `content_markdown` | TEXT | Contenido del laboratorio en formato Markdown |
| `quiz_questions_required` | SMALLINT | Siempre 5 — número obligatorio de preguntas del quiz |
| `points` | INTEGER | Puntos que se otorgan al completarlo por primera vez |
| `estimated_minutes` | INTEGER | Tiempo estimado de completación |

#### `laboratory_questions`
| Columna | Tipo | Descripción |
|---|---|---|
| `question_order` | SMALLINT (1-5) | Posición de la pregunta en el quiz |
| `question_type` | ENUM | `multiple_choice` o `activity_response` |
| `explanation` | TEXT | Explicación que se muestra después de responder |

#### `submissions`
Cada vez que un usuario envía el quiz de un laboratorio.

| Columna | Tipo | Descripción |
|---|---|---|
| `attempt_number` | INTEGER | Intento número 1, 2, 3... |
| `answers` | JSONB | Array JSON con las 5 respuestas enviadas |
| `score_percent` | NUMERIC | Porcentaje de aciertos: 0, 20, 40, 60, 80 o 100 |
| `correct_answers_count` | SMALLINT | Número de respuestas correctas |

#### `user_laboratory_progress`
Estado del usuario en cada laboratorio.

| Columna | Tipo | Descripción |
|---|---|---|
| `status` | ENUM | `not_started`, `in_progress`, `completed` |
| `best_score_percent` | NUMERIC | El mejor puntaje de todos los intentos |
| `attempts_count` | INTEGER | Cuántas veces ha enviado el quiz |

#### `user_activity_progress`
Estado del usuario en cada actividad práctica.

| Columna | Tipo | Descripción |
|---|---|---|
| `generated_response` | TEXT | Hash único generado al completar la actividad |
| `status` | ENUM | `not_started`, `in_progress`, `completed` |

#### `activity_action_logs`
Registro de cada intento de actividad. Es un log inmutable (sin `UPDATE`).

#### `forum_comments`
Comentarios del foro comunitario. Soporta un único nivel de anidamiento.

| Columna | Tipo | Descripción |
|---|---|---|
| `user_id` | UUID | Autor del comentario. `SET NULL` al eliminar el usuario (el comentario persiste) |
| `content` | TEXT | Cuerpo del comentario (1–2000 caracteres) |
| `parent_id` | UUID | `NULL` = comentario raíz; `≠ NULL` = respuesta al comentario con ese id |
| `deleted_at` | TIMESTAMPTZ | Soft-delete: si tiene valor, el contenido se muestra como `[comentario eliminado]` |

> **Un solo nivel:** La API rechaza crear una respuesta a una respuesta (`parent_id` del padre debe ser `NULL`). El modelo de árbol es plano: raíz → respuestas, sin más profundidad.

### 6.4 Triggers de la Base de Datos

Los **triggers** son funciones que PostgreSQL ejecuta automáticamente cuando ocurre cierto evento (INSERT, UPDATE, DELETE) en una tabla. Se usan para mantener datos derivados sincronizados sin que el código del servidor tenga que preocuparse.

```
Trigger 1: trg_updated_at
  Evento: BEFORE UPDATE en cualquier tabla
  Acción: Pone updated_at = NOW() automáticamente

Trigger 2: trg_sync_user_activity_progress_from_action
  Evento: AFTER INSERT en activity_action_logs
  Acción: Crea o actualiza el registro en user_activity_progress
          (incrementa intentos, guarda si fue correcto, guarda el hash generado)

Trigger 3: trg_sync_user_laboratory_progress_from_submission
  Evento: AFTER INSERT en submissions
  Acción: Crea o actualiza user_laboratory_progress
          (actualiza mejor puntaje, estado, número de intentos)

Trigger 4: trg_award_laboratory_points
  Evento: AFTER UPDATE en user_laboratory_progress
  Condición: status cambió a 'completed' por PRIMERA vez
  Acción: Suma laboratories.points al campo users.points del usuario
```

> **Por qué usar triggers:** Desacoplan la lógica de puntuación del código de la aplicación. No importa desde dónde se inserte un `submission` (backend, migración, script), los puntos siempre se otorgan correctamente. Son una garantía a nivel de base de datos.

---

## 7. Autenticación y Autorización

### 7.1 JWT — JSON Web Token

La autenticación funciona con **tokens JWT**. Un JWT es como un "pase de acceso" que el servidor le entrega al usuario cuando inicia sesión. En cada petición posterior, el usuario adjunta ese pase y el servidor puede verificar su identidad sin consultar la base de datos.

```
┌──────────┐     POST /api/auth/login          ┌──────────────┐
│ Frontend │  ──────────────────────────────►  │   Backend    │
│          │     { email, password }            │              │
│          │  ◄──────────────────────────────  │              │
│          │     { token: "eyJ..." }            │              │
│          │                                    │              │
│          │     GET /api/users/me              │              │
│          │     Authorization: Bearer eyJ...   │              │
│          │  ──────────────────────────────►  │              │
│          │     { id, username, email, ... }   │              │
│          │  ◄──────────────────────────────  │              │
└──────────┘                                    └──────────────┘
```

**Estructura del JWT:**
```json
Header:  { "alg": "HS256", "typ": "JWT" }
Payload: { "id": "uuid", "username": "simon", "email": "...", "role": "user", "iat": 123, "exp": 456 }
Firma:   HMAC-SHA256(header + payload, JWT_SECRET)
```

El token expira después de **7 días**. Si un usuario tiene el token de otra persona, no puede forjarlo porque no conoce el `JWT_SECRET` con el que fue firmado.

### 7.2 Verificación de Email al Registro

El registro es un proceso de **dos pasos** para asegurar que el email pertenece realmente al usuario:

```
Paso 1 — POST /api/auth/register
  1. AuthService.prepareRegistration() valida los datos y hashea la contraseña.
  2. Se genera un código numérico de 6 dígitos (100000–999999).
  3. Los datos del registro pendiente se guardan en memoria (Map pendingRegistrations).
  4. Se envía el código al email del usuario con sendVerificationEmail().
  5. El usuario AÚN NO se crea en la base de datos.
  6. Respuesta: { message, email }

Paso 2 — POST /api/auth/verify-email
  1. Se busca el registro pendiente por email.
  2. Se verifica que el código no haya expirado y que coincida.
  3. AuthService.createUser() crea el usuario en la base de datos.
  4. Se elimina la entrada del Map pendingRegistrations.
  5. Respuesta: { token, user } — igual que un login exitoso.
```

```typescript
// En AuthController:
const pendingRegistrations = new Map<string, {
  username: string
  email: string
  passwordHash: string
  code: string
  expiresAt: number
}>()
```

- El código es de 6 dígitos numéricos generado con `Math.random()`.
- Expira en **15 minutos** (`Date.now() + 900_000`).
- Al reiniciar el servidor, todos los registros pendientes se pierden (el usuario debe volver a registrarse).
- Existe un endpoint adicional `POST /api/auth/resend-verification` para reenviar un nuevo código al mismo email, reemplazando el anterior.
- Se usa la misma respuesta en `resend-verification` para emails registrados y no registrados, evitando *email enumeration*.

### 7.3 Reset de Contraseña

Los tokens de restablecimiento de contraseña se almacenan **en memoria** (no en la base de datos):

```typescript
// En AuthController:
const resetTokens = new Map<string, { userId: string; expiresAt: number }>()
```

- El token es un UUID aleatorio (`crypto.randomUUID()`).
- Expira en **1 hora** (`Date.now() + 3_600_000`).
- Al reiniciar el servidor, todos los tokens pendientes se pierden.
- El enlace de reset se construye como `${FRONTEND_URL}/reset-password?token=...`. **`FRONTEND_URL` debe configurarse como variable de entorno en Railway** (`https://rutseg.vercel.app`); si no está definida, el fallback es `http://localhost:5173`.
- El correo se envía con `sendPasswordResetEmail()` del módulo `src/utils/email.ts` usando la Gmail REST API con OAuth2. No usa SMTP — usa HTTPS directamente, compatible con Railway que bloquea puertos SMTP salientes.
- Se usa la misma respuesta para correos registrados y no registrados, evitando *email enumeration*.

### 7.5 Módulo de correo (`src/utils/email.ts`)

Centraliza todo el envío de correos. Está organizado en helpers internos y dos funciones exportadas:

**Helpers internos:**

| Función | Descripción |
|---|---|
| `getAccessToken()` | Intercambia `GMAIL_REFRESH_TOKEN` por un `access_token` de corta duración vía `POST https://oauth2.googleapis.com/token` (`grant_type=refresh_token`) |
| `base64UrlEncode(input)` / `encodeHeaderWord(text)` | Codifican el mensaje MIME crudo y el asunto (RFC 2047, para tildes/ñ) en base64url, formato que exige la API de Gmail |
| `sendRawEmail(to, subject, html)` | Arma un mensaje MIME (`From`/`To`/`Subject`/`Content-Type: text/html`) y hace `POST` a `https://gmail.googleapis.com/gmail/v1/users/me/messages/send` con el `access_token` en `Authorization: Bearer`. Usado por ambas funciones exportadas para evitar duplicación |
| `emailHeader(title, subtitle)` | Genera el bloque HTML de cabecera de todos los correos: fondo `#0A1545`, logo 🔐, nombre en amarillo `#F5C500`, subtítulo monoespacio, barra de degradado amarillo→cyan |
| `emailFooter(note)` | Genera el bloque HTML de pie de todos los correos: nota legal en gris, barra oscura `#060D1F` con la URL de la plataforma |

> **Historial:** este módulo usó Brevo entre mayo y agosto de 2026 porque el `refresh_token` de Gmail expiraba cada 7 días mientras el proyecto de Google Cloud estuviera en modo "Testing" (no verificado), exigiendo re-autenticación manual periódica. Se volvió a la Gmail REST API con OAuth2 porque Brevo empezó a marcar el remitente `@gmail.com` como no alineado con los nuevos requisitos DKIM/DMARC de Google/Yahoo/Microsoft (no se puede firmar DKIM para un dominio que no controlas). **Para que esta vez no vuelva a expirar cada 7 días, el proyecto de Google Cloud debe pasar por la verificación del scope `gmail.send`** (ver checklist en README) — mientras siga en "Testing", el problema original se repite.

**Funciones exportadas:**

```typescript
sendVerificationEmail(to, username, code)   // Registro — código de 6 dígitos
sendPasswordResetEmail(to, resetLink)        // Contraseña olvidada — botón con enlace
```

Ambas comparten la misma estructura visual:
- Fondo exterior `#EEF3FC` (igual al tema claro del sitio)
- Tarjeta con borde redondeado y sombra
- Header unificado con branding de RutSeg
- Cuerpo blanco con contenido específico de cada correo
- Footer oscuro con URL de la plataforma

### 7.4 Middleware de Autenticación

En `src/middleware/auth.ts` hay tres funciones que actúan como "porteros":

```typescript
optionalAuth    // Intenta verificar el token; si no hay token, continúa sin usuario.
                // Usado en: GET /api/courses (ver cursos sin estar logueado)

requireAuth     // El token es obligatorio y debe ser válido.
                // Lanza 401 Unauthorized si falta o está vencido.
                // Usado en: matrícula, envío de quizzes, ver laboratorios

requireAdmin    // El token debe ser válido Y el rol debe ser 'admin'.
                // Lanza 403 Forbidden si el usuario es normal.
                // Usado en: crear/editar cursos, módulos, laboratorios
```

Cuando el middleware aprueba la petición, guarda los datos del usuario en el **contexto de Hono** (`c.set('user', payload)`) para que el controlador pueda accederlos con `c.get('user')`.

---

## 8. Endpoints de la API

Todos los endpoints comienzan con el prefijo `/api`.

### 8.1 Autenticación (`/api/auth`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/register` | ❌ | Paso 1 del registro: valida datos y envía código al email |
| POST | `/verify-email` | ❌ | Paso 2 del registro: verifica el código y crea el usuario |
| POST | `/resend-verification` | ❌ | Reenviar el código de verificación al mismo email |
| POST | `/login` | ❌ | Iniciar sesión, recibe token JWT |
| POST | `/logout` | ✅ | Cierra sesión (el token es stateless, solo es simbólico) |
| POST | `/forgot-password` | ❌ | Solicitar enlace de restablecimiento de contraseña |
| POST | `/reset-password` | ❌ | Restablecer contraseña con el token recibido por email |

**Registro paso 1 — body esperado:**
```json
{ "username": "simon", "email": "simon@ejemplo.com", "password": "min8chars" }
```

**Registro paso 1 — respuesta:**
```json
{ "message": "Código de verificación enviado. Revisa tu correo.", "email": "simon@ejemplo.com" }
```

**Registro paso 2 (verify-email) — body esperado:**
```json
{ "email": "simon@ejemplo.com", "code": "483920" }
```

**Respuesta de verify-email (y de login):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": "uuid", "username": "simon", "email": "...", "role": "user" }
}
```

### 8.2 Usuarios (`/api/users`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/me` | ✅ | Ver mi perfil completo (puntos, labs completados, rango) |
| PUT | `/me` | ✅ | Actualizar username, email o bio |
| POST | `/me/password` | ✅ | Cambiar contraseña |
| POST | `/me/avatar` | ✅ | Subir foto de perfil (JPG, máx 5 MB) |
| GET | `/:username` | ❌ | Ver perfil público de cualquier usuario |

### 8.3 Cursos (`/api/courses`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | Opcional | Listar cursos publicados con estadísticas |
| GET | `/:slug` | Opcional | Ver detalle de un curso |
| POST | `/:slug/enroll` | ✅ | Matricularse en un curso |
| GET | `/:slug/modules` | ❌ | Ver módulos del curso |
| GET | `/:slug/modules/:moduleSlug/labs` | ❌ | Ver laboratorios del módulo |
| GET | `/:slug/modules/:moduleSlug/labs/:labSlug` | ✅ | Ver laboratorio completo con preguntas y progreso |

> **Nota sobre el último endpoint:** Requiere que el usuario esté matriculado en el curso padre. Si no lo está, recibe HTTP 403. Los administradores no necesitan matrícula.

**Respuesta de GET `/api/courses`:**
```json
[
  {
    "id": "uuid",
    "slug": "intro-linux",
    "title": "Introducción a Linux",
    "difficulty": "principiante",
    "moduleCount": 3,
    "labCount": 12,
    "totalPoints": 450,
    "isEnrolled": false
  }
]
```

### 8.4 Actividades (`/api/activities`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/:activityId/attempt` | ✅ | Intentar una actividad práctica |

El body es un JSON libre que representa la acción del usuario. El servidor lo compara contra la `expected_action_key` de la actividad.

**Respuesta:**
```json
{
  "isCorrect": true,
  "feedback": "¡Correcto! Ejecutaste el comando adecuado.",
  "generatedResponse": "A3F1B2C4D5E6F7A8",
  "alreadyCompleted": false
}
```

### 8.5 Envío de Quizzes (`/api/labs`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| POST | `/:labId/submit` | ✅ | Enviar respuestas del quiz del laboratorio |

**Body esperado:**
```json
{
  "answers": [
    { "questionId": "uuid-1", "selectedOptionId": "uuid-opcion" },
    { "questionId": "uuid-2", "selectedOptionId": "uuid-opcion" },
    { "questionId": "uuid-3", "responseText": "A3F1B2C4D5E6F7A8" },
    { "questionId": "uuid-4", "selectedOptionId": "uuid-opcion" },
    { "questionId": "uuid-5", "selectedOptionId": "uuid-opcion" }
  ]
}
```

**Respuesta:**
```json
{
  "submissionId": "uuid",
  "attemptNumber": 2,
  "correctAnswersCount": 4,
  "totalQuestions": 5,
  "scorePercent": 80,
  "pointsEarned": 150
}
```

### 8.6 Estadísticas Públicas (`/api/stats`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | ❌ | Métricas globales de la plataforma para mostrar en la landing |

**Respuesta:**
```json
{
  "courseCount": 3,
  "labCount": 18,
  "totalPoints": 5400,
  "userCount": 127
}
```

### 8.7 Ranking (`/api/ranking`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/?page=1&limit=20` | ❌ | Tabla de posiciones paginada |

**Respuesta:**
```json
{
  "data": [
    { "rank": 1, "username": "hacker_pro", "points": 2400, "bio": "..." },
    { "rank": 2, "username": "simon", "points": 1800, "bio": "..." }
  ],
  "total": 42,
  "page": 1,
  "limit": 20,
  "totalPages": 3
}
```

### 8.8 Foro (`/api/forum`)

| Método | Ruta | Auth | Descripción |
|---|---|---|---|
| GET | `/` | Opcional | Comentarios raíz paginados (20/página), incluye `replyCount` y autor |
| GET | `/:id/replies` | Opcional | Todas las respuestas de un comentario raíz |
| POST | `/` | ✅ | Crear comentario raíz |
| POST | `/:id/replies` | ✅ | Responder a un comentario raíz |
| DELETE | `/:id` | ✅ | Eliminar comentario propio (o cualquiera si `admin`) |

**Query params de `GET /api/forum`:** `?page=1` (defecto). Devuelve:
```json
{
  "comments": [
    {
      "id": "uuid",
      "content": "Texto del comentario",
      "author": { "username": "simon", "profileImage": null },
      "parentId": null,
      "replyCount": 3,
      "createdAt": "2026-05-16T12:00:00Z",
      "isDeleted": false
    }
  ],
  "total": 42,
  "page": 1,
  "totalPages": 3
}
```

Comentarios eliminados: `content = "[comentario eliminado]"`, `author = null`, `isDeleted = true`.

**Body de POST `/api/forum` y POST `/api/forum/:id/replies`:**
```json
{ "content": "Texto del comentario (máx. 2000 caracteres)" }
```

### 8.9 Admin (`/api/admin`) — Solo para rol `admin`

Todos estos endpoints requieren token de administrador.

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/courses` | Crear curso |
| PUT | `/courses/:id` | Editar curso |
| DELETE | `/courses/:id` | Borrar curso (cascada: módulos, labs, matrículas, progreso) |
| POST | `/courses/:courseId/modules` | Crear módulo |
| PUT | `/modules/:id` | Editar módulo |
| DELETE | `/modules/:id` | Borrar módulo (cascada: labs, preguntas, progreso) |
| GET | `/labs/:id` | Detalle de un laboratorio con sus preguntas, opciones y actividades |
| POST | `/modules/:moduleId/labs` | Crear laboratorio |
| PUT | `/labs/:id` | Editar laboratorio (despublica automáticamente si queda incompleto) |
| DELETE | `/labs/:id` | Borrar laboratorio (cascada: preguntas, progreso) |
| POST | `/labs/:labId/questions` | Crear pregunta (máx 5 por lab) |
| PUT | `/questions/:id` | Editar pregunta |
| DELETE | `/questions/:id` | Borrar pregunta (despublica el lab si queda incompleto) |
| POST | `/questions/:questionId/options` | Crear opción de respuesta múltiple |
| PUT | `/questions/:questionId/options/:id` | Editar opción (marcar como correcta desmarca las demás) |
| DELETE | `/questions/:questionId/options/:id` | Borrar opción |
| POST | `/questions/:questionId/activity` | Crear actividad práctica |
| PUT | `/activities/:id` | Editar actividad |
| GET | `/users?page=&limit=&search=` | Listado paginado de usuarios (búsqueda por username/email) |
| GET | `/users/:id` | Detalle de un usuario |
| PUT | `/users/:id` | Editar username/email/bio/rol (bloquea que un admin se quite el rol a sí mismo) |
| POST | `/users/:id/password` | Establece una nueva contraseña sin pedir la actual |
| DELETE | `/users/:id` | Borra un usuario (soft-delete; bloquea el auto-borrado) |

---

## 9. Lógica de Negocio Clave

### 9.1 Sistema de Actividades Prácticas

Las preguntas de tipo `activity_response` requieren que el usuario "complete una tarea" (por ejemplo, ejecutar un comando específico en una terminal web). El flujo es:

```
1. El usuario envía un intento → POST /api/activities/:activityId/attempt
   Body: { "action": "ls -la /etc" }

2. ActivityService compara la acción enviada contra activity.expectedActionKey
   guardado en la base de datos.

3. Si es correcto:
   a. Se genera un hash determinístico:
      HMAC-SHA256("activity:{userId}:{activityId}", JWT_SECRET)
      Se toma solo los primeros 16 caracteres en mayúsculas.
      Ejemplo: "A3F1B2C4D5E6F7A8"

   b. Se guarda en activity_action_logs (trigger actualiza user_activity_progress)

   c. Se devuelve generatedResponse al usuario.
      Este valor es su "evidencia" de haber completado la actividad.

4. Cuando el usuario luego envía el quiz, en la pregunta activity_response
   debe pegar ese hash exactamente. Si coincide con user_activity_progress.generated_response,
   la respuesta es correcta.
```

**¿Por qué un hash determinístico?**

El hash es siempre el mismo para la misma combinación de usuario y actividad (gracias a `JWT_SECRET` como llave). Esto significa:
- Si el usuario recarga la página y vuelve a intentar la actividad, recibirá el mismo código.
- El código no puede ser adivinado ni compartido entre usuarios (cada uno tiene un código diferente).

### 9.2 Calificación del Quiz

```typescript
// En SubmissionService:
let correctCount = 0;

for (const answer of answers) {
  const question = questions.find(q => q.id === answer.questionId)!

  if (question.questionType === 'multiple_choice') {
    const option = await optionDAO.findById(answer.selectedOptionId)
    if (option?.questionId === question.id && option.isCorrect) correctCount++

  } else {
    // activity_response: correcto solo si coincide con el hash del propio usuario
    const activity = await activityDAO.findByQuestionId(question.id)
    const progress = await activityProgressDAO.find(userId, activity.id)
    if (progress?.generatedResponse === answer.responseText.trim()) correctCount++
  }
}

const scorePercent = (correctCount / 5) * 100
// Posibles valores: 0, 20, 40, 60, 80, 100
```

### 9.3 Sistema de Puntos

Los puntos se otorgan **una sola vez** por laboratorio, y solo si el usuario supera el umbral mínimo de aprobación. El flujo exacto es:

```
1. Usuario envía quiz → se inserta en submissions
2. Trigger actualiza user_laboratory_progress
3. Si status cambia a 'completed' por primera vez:
   UPDATE users SET points = points + laboratories.points WHERE id = userId

En el Service, pointsEarned se calcula como:
  const passed = scorePercent >= 60   // ← umbral de aprobación: 60%
  const pointsEarned = passed && !wasAlreadyCompleted ? lab.points : 0
```

> **Nota:** Se necesita al menos **60% de aciertos** (3 de 5 preguntas) para que el submission cuente como aprobado y se otorguen los puntos. El usuario puede seguir intentando hasta pasar, y siempre se guarda el mejor puntaje (`best_score_percent`).

### 9.4 Control de Acceso a Laboratorios

Para ver el contenido completo de un laboratorio (incluyendo preguntas), el usuario debe estar **matriculado** en el curso padre. El proceso es:

```
GET /:courseSlug/modules/:moduleSlug/labs/:labSlug (con JWT)

CourseService.getLaboratory():
  1. Busca el curso por slug
  2. Busca el módulo por slug dentro de ese curso
  3. Busca el laboratorio por slug dentro de ese módulo
  4. Busca la matrícula: CourseEnrollmentDAO.find(userId, courseId)
  5. Si no hay matrícula → throw ForbiddenError("Debes estar matriculado")
  6. Si hay matrícula → devuelve lab con todas las preguntas y el progreso del usuario
```

Los administradores saltan este control (para poder revisar el contenido sin matricularse).

---

## 10. Manejo de Errores

### 10.1 Sistema de Errores Unificado

El backend usa un **sistema de errores de dominio**: los errores se definen con semántica del negocio, sin acoplarlos al protocolo HTTP. Esto significa que un `Service` puede lanzar un `NotFoundError` sin saber que el transporte es HTTP; es el adaptador HTTP (el manejador global en `index.ts`) el único lugar del sistema que traduce cada tipo de error a un código de estado.

**¿Por qué importa?** Si el sistema se integra con otra interfaz (una aplicación de escritorio, una CLI, o tests automatizados), los Services se reutilizan sin cambios porque no contienen códigos HTTP.

### 10.2 Jerarquía de Clases de Error

En `src/utils/errors.ts` se define la jerarquía completa:

```typescript
// Clase base — todos los errores de dominio heredan de aquí
class AppError extends Error { }

// Subclases — cada una representa una situación de negocio específica
class NotFoundError     extends AppError { }  // El recurso solicitado no existe
class ForbiddenError    extends AppError { }  // El usuario no tiene permiso
class ConflictError     extends AppError { }  // El recurso ya existe o hay un conflicto
class UnauthorizedError extends AppError { }  // El usuario no está autenticado
class BadRequestError   extends AppError { }  // La petición tiene datos inválidos

// Caso especial: lleva un array de mensajes de validación
class ValidationError extends AppError {
  constructor(public readonly errors: string[]) {
    super(errors.join(' | '))  // Cada mensaje separado por " | "
  }
}
```

**Cuándo usar cada tipo:**

| Clase | Se lanza cuando | HTTP resultante |
|---|---|---|
| `NotFoundError` | El recurso no existe en la base de datos | 404 |
| `UnauthorizedError` | No hay token, el token es inválido, o las credenciales son incorrectas | 401 |
| `ForbiddenError` | El usuario está autenticado pero no tiene permisos | 403 |
| `ConflictError` | El recurso ya existe (email, username duplicado) | 409 |
| `BadRequestError` | La petición viola una regla de negocio puntual (no es validación de campos) | 400 |
| `ValidationError` | Uno o varios campos no pasan la validación de formato | 400 |

### 10.3 Manejador Global de Errores

En `src/index.ts` hay un único manejador global que captura cualquier error lanzado en cualquier parte de la aplicación y lo traduce al status HTTP correcto:

```typescript
app.onError((err, c) => {
  if (err instanceof NotFoundError)     return c.json({ error: err.message }, 404)
  if (err instanceof UnauthorizedError) return c.json({ error: err.message }, 401)
  if (err instanceof ForbiddenError)    return c.json({ error: err.message }, 403)
  if (err instanceof ConflictError)     return c.json({ error: err.message }, 409)
  if (err instanceof ValidationError)   return c.json({ error: err.message }, 400)
  if (err instanceof AppError)          return c.json({ error: err.message }, 400)
  // Error inesperado (bug, fallo de DB, etc.) → log + 500
  console.error(err)
  return c.json({ error: 'Error interno del servidor.' }, 500)
})
```

Este es el **único lugar** en todo el backend que conoce los códigos HTTP de cada error. El orden importa: `AppError` va al final como fallback porque todas las subclases también son instancias de `AppError`.

### 10.4 Flujo de un error desde el origen hasta el cliente

```
Service lanza → throw new ForbiddenError('Debes inscribirte al curso.')
                         ↓
          El error sube por la cadena de llamadas (sin ser capturado)
                         ↓
          app.onError() en index.ts lo intercepta
                         ↓
          err instanceof ForbiddenError → true
                         ↓
          c.json({ error: 'Debes inscribirte al curso.' }, 403)
                         ↓
          Cliente recibe: HTTP 403 + { "error": "Debes inscribirte al curso." }
```

### 10.5 Formato de Respuestas de Error

Todos los errores tienen el mismo formato JSON:

```json
{ "error": "Descripción del error en español" }
```

**Códigos de estado HTTP usados:**

| Código | Significado | Ejemplo |
|---|---|---|
| 400 | Bad Request — datos inválidos o regla de negocio puntual | Username muy corto, menos de 5 respuestas enviadas |
| 401 | Unauthorized — sin autenticación o credenciales incorrectas | Sin token en header, contraseña incorrecta |
| 403 | Forbidden — autenticado pero sin permisos | Usuario normal en ruta admin, sin matrícula en el curso |
| 404 | Not Found — recurso no existe | Curso con ese slug no existe |
| 409 | Conflict — ya existe | Email ya registrado, username ya en uso |
| 500 | Internal Server Error | Error inesperado en el servidor (bug, caída de DB) |

---

## 11. Variables de Entorno

El backend necesita las siguientes variables en el archivo `.env` (o en Railway):

| Variable | Obligatoria | Descripción |
|---|---|---|
| `DATABASE_URL` | ✅ | URL de conexión a PostgreSQL de Supabase |
| `JWT_SECRET` | ✅ | Clave secreta para firmar y verificar tokens JWT. Debe ser larga y aleatoria. |
| `PORT` | ❌ | Puerto donde escucha el servidor. Railway lo inyecta automáticamente. |
| `FRONTEND_URL` | ❌ | URL(s) del frontend para CORS (comma-separated). Default: `http://localhost:5173` |
| `GMAIL_SENDER_EMAIL` | ✅ | Dirección de Gmail desde la que se envían los correos (`From` y cuenta autorizada por OAuth2). |
| `GMAIL_CLIENT_ID` | ✅ | Client ID del OAuth Client creado en Google Cloud Console (tipo "Web application"). |
| `GMAIL_CLIENT_SECRET` | ✅ | Client Secret del mismo OAuth Client. |
| `GMAIL_REFRESH_TOKEN` | ✅ | Token de larga duración obtenido una sola vez autorizando el scope `gmail.send` para `GMAIL_SENDER_EMAIL`. Se intercambia por un `access_token` en cada envío. |

> **Por qué Gmail API y no SMTP:** Railway bloquea los puertos SMTP salientes (25, 465, 587), así que el envío debe hablar HTTPS — la API de Gmail lo hace. Es la segunda vez que el proyecto usa este enfoque: se abandonó en mayo de 2026 a favor de Brevo porque el `refresh_token` expiraba cada 7 días con el proyecto de Google Cloud en modo "Testing" (no verificado). **Si el proyecto no completa la verificación del scope `gmail.send`, ese mismo problema se repite.** Se volvió a Gmail porque Brevo empezó a marcar el remitente `@gmail.com` como no alineado con los requisitos DKIM/DMARC de Google/Yahoo/Microsoft — un problema sin solución mientras el remitente sea un dominio que no controlas.

**Ejemplo de `DATABASE_URL` de Supabase:**
```
postgresql://postgres.[ref]:[password]@aws-0-us-east-1.pooler.supabase.com:6543/postgres
```

> **Seguridad:** Nunca se deben subir los valores reales de estas variables a Git. Solo se sube `.env.example` con los nombres de las variables sin valores.

---

## 12. Despliegue

### 12.1 Base de Datos — Supabase

1. Crear un proyecto en [supabase.com](https://supabase.com).
2. Ir al **SQL Editor** y ejecutar el contenido de `backend/database/schema.sql`.
3. Copiar la **connection string** del pooler (modo *transaction*) como `DATABASE_URL`.

El schema es **idempotente**: usa `CREATE TABLE IF NOT EXISTS`, `CREATE TYPE IF NOT EXISTS`, etc. Se puede ejecutar múltiples veces sin error.

### 12.2 Backend — Railway

La configuración de despliegue está en `backend/railway.json`:

```json
{
  "build": {
    "builder": "RAILPACK",
    "buildCommand": "bun install"
  },
  "deploy": {
    "startCommand": "bun run src/index.ts",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

**Pasos:**
1. Crear un nuevo servicio en Railway conectado al repositorio de GitHub.
2. Configurar las variables de entorno: `DATABASE_URL`, `JWT_SECRET`, `FRONTEND_URL`.
3. Railway detecta automáticamente el `railway.json` y hace el deploy.

> **RAILPACK** es el builder de Railway que detecta el runtime (Bun en este caso) y construye una imagen optimizada. Es más rápido y liviano que Nixpacks.

### 12.3 Frontend — Vercel

El frontend es estático (React compilado). Se despliega conectando el repositorio en Vercel:
1. **Root Directory**: `frontend`
2. **Framework Preset**: Vite
3. Variables de entorno: `VITE_API_URL` y `VITE_CHATBOT_URL` con las URLs de Railway.

Vercel genera automáticamente una URL de producción estable (`rutseg.vercel.app`) y URLs de preview únicas por cada deploy (`cyberseclabs-xxxx.vercel.app`, el proyecto de Vercel conserva el nombre original).

### 12.4 Diagrama de Infraestructura

```
┌──────────────────┐     HTTPS      ┌──────────────────┐
│    Vercel        │ ─────────────► │    Railway       │
│  (React Frontend)│                │    (Bun + Hono)  │
│                  │ ◄──────────── │    Backend       │
└────────┬─────────┘                └────────┬─────────┘
         │                                   │ SSL/PostgreSQL
         │ HTTPS (SSE)                       ▼
         │                          ┌──────────────────┐
         │                          │    Supabase      │
         ▼                          │   PostgreSQL     │
┌──────────────────┐                └──────────────────┘
│    Railway       │
│  (FastAPI+Python)│
│  Chatbot (Groq)  │
└──────────────────┘
```

---

## 13. Glosario de Términos

**API REST** — Interfaz de comunicación entre aplicaciones basada en HTTP. El frontend hace peticiones a URLs específicas del backend y recibe respuestas JSON.

**Bun** — Runtime moderno para JavaScript/TypeScript, alternativa a Node.js. Es más rápido para arrancar y tiene herramientas integradas (bundler, test runner, gestor de paquetes).

**BYTEA** — Tipo de dato de PostgreSQL para almacenar bytes crudos (imágenes, archivos binarios).

**camelCase** — Convención de nombres donde la primera letra es minúscula y cada palabra siguiente comienza con mayúscula: `firstName`, `passwordHash`.

**Connection Pooler** — Componente que reutiliza conexiones abiertas a la base de datos. Supabase usa PgBouncer: en vez de abrir una conexión nueva por cada petición, las reutiliza de un "pool" (pileta de conexiones).

**CORS** — *Cross-Origin Resource Sharing*. Política de seguridad del navegador que bloquea peticiones de un dominio a otro. El backend configura qué orígenes tienen permiso, en este caso solo el dominio del frontend.

**DAO** — *Data Access Object*. Objeto cuya única responsabilidad es acceder a la base de datos. Encapsula todas las consultas SQL de una entidad específica.

**Determinístico** — Un proceso que, dado los mismos inputs, siempre produce el mismo output. El generador de hashes para actividades es determinístico: mismo usuario + misma actividad = siempre el mismo hash.

**Email Enumeration** — Ataque donde se descubre si un email está registrado probando la respuesta del servidor. El endpoint de forgot-password siempre responde igual para evitarlo.

**Enum** — Tipo de dato con un conjunto fijo de valores posibles. En PostgreSQL: `CREATE TYPE user_role AS ENUM ('user', 'admin')`.

**Framework HTTP** — Librería que simplifica la creación de servidores web. Hono maneja el routing, middlewares, y la lectura/escritura de requests y responses.

**Hash** — Resultado de una función matemática que convierte datos de cualquier tamaño en una cadena de longitud fija. Es unidireccional: no se puede recuperar el original a partir del hash.

**HMAC** — *Hash-based Message Authentication Code*. Es un hash que usa una clave secreta adicional. Solo quien conoce la clave puede generar o verificar el hash.

**Hono** — Framework web ultra-ligero para TypeScript. Define rutas con `app.get('/ruta', handler)`, aplica middleware, y gestiona peticiones HTTP.

**Idempotente** — Una operación que puede ejecutarse múltiples veces sin efectos secundarios adicionales. `CREATE TABLE IF NOT EXISTS` es idempotente.

**JSONB** — Tipo de dato de PostgreSQL para almacenar JSON de forma binaria. Permite búsquedas e índices sobre el contenido JSON.

**JWT** — *JSON Web Token*. Estándar para transmitir información de forma segura entre partes como un string compacto. Tiene tres partes separadas por puntos: `header.payload.signature`.

**Middleware** — Función que se ejecuta "en el medio" entre que llega una petición HTTP y llega al handler final. Puede rechazar la petición, modificarla, o pasarla al siguiente paso.

**Modelo de Dominio** — Clase TypeScript que representa una entidad del sistema (User, Course, Laboratory, etc.). Contiene validación de datos y métodos para proyectar solo la información necesaria según el contexto.

**ORM** — *Object-Relational Mapper*. Librería que traduce entre objetos JavaScript y tablas de base de datos. En este proyecto se **usan consultas SQL crudas** en los DAOs en vez de un ORM, para mayor control.

**PostgreSQL** — Sistema de gestión de bases de datos relacional de código abierto.

**Proyección** — Método de un modelo que devuelve solo un subconjunto de sus campos. Principio de mínimo privilegio: cada respuesta expone solo lo necesario (`toPublic`, `toProfile`, `toAdmin`, etc.).

**Railway** — Plataforma de despliegue en la nube. Conecta con GitHub, detecta el lenguaje y despliega automáticamente.

**RAILPACK** — Builder de Railway que analiza el proyecto y construye una imagen Docker optimizada para el runtime detectado.

**Slug** — Versión de un título optimizada para URLs. Sin espacios, sin caracteres especiales, todo en minúsculas. Ejemplo: "Introducción a Linux" → `introduccion-a-linux`.

**snake_case** — Convención de nombres donde las palabras se separan con guión bajo: `first_name`, `password_hash`. PostgreSQL usa snake_case por convención.

**Soft Delete** — Patrón donde en vez de eliminar un registro físicamente, se marca con una fecha de eliminación. Permite recuperar datos y mantiene la integridad referencial.

**Supabase** — Plataforma de backend como servicio basada en PostgreSQL. En este proyecto solo se usa como host de PostgreSQL.

**Trigger** — Función que PostgreSQL ejecuta automáticamente en respuesta a eventos en una tabla (INSERT, UPDATE, DELETE).

**TypeScript** — Superset de JavaScript que añade tipos estáticos. El código TypeScript se verifica antes de ejecutarse, reduciendo errores en tiempo de ejecución.

**UUID** — *Universally Unique Identifier*. Identificador de 128 bits generado aleatoriamente. Se usa como clave primaria en vez de números enteros para mayor seguridad y escalabilidad.

**AppError** — Clase base de todos los errores de dominio del backend. Extiende `Error` nativo de JavaScript. Solo el manejador global de Hono sabe qué código HTTP le corresponde a cada subclase; los Services no lo saben.

**ValidationError** — Subclase de `AppError` (HTTP 400) que acepta un array de mensajes de validación en español. Se lanza cuando uno o más campos no pasan las reglas de formato definidas en los modelos. Los mensajes individuales se unen con `' | '` en el mensaje final.

**NotFoundError / ForbiddenError / ConflictError / UnauthorizedError / BadRequestError** — Subclases de `AppError` que representan situaciones específicas de negocio. No contienen códigos HTTP; el manejador global de `index.ts` es el único que los asigna al responder al cliente.
