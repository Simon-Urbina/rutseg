# Notas para la ponencia de RutSeg — estructuradas por SSDLC

> Documento de trabajo personal para preparar la presentación. Son notas, no un guion cerrado —
> cada sección trae el "qué" y sobre todo el "por qué" de cada decisión, para poder responder
> preguntas del jurado sin quedarme en la superficie.
>
> Fuentes: `docs/documentacion/Documentacion-Backend.md`, `Documentacion-Frontend.md`,
> `Documentacion-Seguridad.md`, `Documentacion-Errores-Historicos.md`, `README.md`.

---

## 0. Idea del hilo narrativo

SSDLC = Secure Software Development Life Cycle. La idea de la ponencia es mostrar que la
seguridad no fue una capa pegada al final, sino una decisión presente en cada fase — natural,
además, porque el proyecto nace de un semillero de **ciberseguridad**. Voy a narrar en 6 fases:

1. Concepción / Requisitos
2. Diseño (arquitectura + elección de stack)
3. Desarrollo (backend → chatbot → frontend)
4. Pruebas / aseguramiento de calidad (incluye la auditoría de seguridad y los incidentes reales)
5. Despliegue
6. Mantenimiento

Cierre con el guion sugerido de exposición (sección 7).

---

## 1. Concepción y Análisis de Requisitos

- **Qué es:** RutSeg — plataforma de aprendizaje en ciberseguridad. Cursos → módulos →
  laboratorios prácticos → quiz de 5 preguntas por laboratorio. Gamificación por puntos,
  ranking global, certificado PDF al completar el 100% de un curso, foro comunitario, y un
  asistente de IA (Uchi) disponible en toda la plataforma.
- **Origen:** proyecto del Semillero de Investigación en Ciberseguridad y Desarrollo de
  Software, USTA Tunja, dirigido por el docente Harrizon Alexander Soler Galindo.
- **Problema que resuelve:** enseñar conceptos de ciberseguridad (OWASP: control de acceso,
  inyección, fallos de autenticación) de forma práctica, no solo teórica — los laboratorios
  OWASP existen como *contenido* (markdown) dentro de la plataforma, no como vulnerabilidades
  reales explotables (ver §4, decisión de diseño importante para la charla de seguridad).
- **Requisitos no funcionales que guiaron todo el diseño posterior:**
  - Seguridad desde el día uno (es un proyecto de un semillero de ciberseguridad — "dogfooding":
    predicar con el ejemplo).
  - Debía poder desplegarse gratis/barato (stack pensado para tiers gratuitos: Supabase, Railway,
    Vercel).
  - Debía sostenerse con mantenimiento de un equipo pequeño (arquitectura simple, sin
    sobre-ingeniería: sin Redux, sin ORM pesado, sin microservicios innecesarios — solo el
    chatbot se separó, y por una razón concreta de seguridad, ver §2).

---

## 2. Diseño — arquitectura y elección de stack (el "por qué" de todo)

### 2.1 Vista general de la arquitectura

Tres piezas desplegadas por separado:

```
Frontend (React, Vercel) ──HTTP/JSON──► Backend (Bun+Hono, Railway) ──SQL──► PostgreSQL (Supabase)
        │
        └──HTTP/SSE──► Chatbot (FastAPI+Python, Railway) ──HTTPS──► Groq (LLM)
```

El chatbot es un **microservicio aparte**, no una ruta más del backend. Esa es la decisión de
diseño más importante para justificar en la charla: **aislamiento de seguridad**. El chatbot no
tiene ni puede tener credenciales de base de datos — si se compromete (prompt injection, RCE en
una dependencia), el atacante no gana ningún camino hacia los datos de usuarios. Solo puede hacer
que Uchi responda mal o gastar la cuota de la API de Groq. Esto es "seguridad por diseño",
justo el tipo de decisión que un SSDLC pide tomar en la fase de diseño, no parchear después.

### 2.2 Por qué cada tecnología — tabla de argumentos

| Tecnología | Rol | Por qué se eligió |
|---|---|---|
| **Bun** | Runtime backend + frontend (bundler/pkg manager) | Todo-en-uno: runtime + instalador de paquetes + bundler, sin herramientas adicionales. Arranque más rápido que Node. Trae `Bun.password` nativo (hash de contraseñas sin librería externa) — menos superficie de dependencias que auditar. |
| **Hono** | Framework HTTP del backend | Ultra-ligero, pensado específicamente para runtimes como Bun/Workers (no es Express con overhead heredado de Node). Sintaxis de rutas y middleware simple, ideal para una API que no necesita nada más que routing + middleware. |
| **TypeScript sin ORM** (SQL crudo con `postgres`) | Acceso a datos | Se instaló `drizzle-orm` pero **conscientemente no se usa** — se prefirió SQL parametrizado explícito en los DAOs. Razón: control total sobre las queries (importante para un proyecto de seguridad — se puede auditar cada consulta a mano) y evitar la capa de "magia" de un ORM. Se verificó que **no existe ningún uso de `sql.unsafe()`** en el código — 100% de las queries parametrizadas, cero superficie de SQL injection. |
| **PostgreSQL en Supabase** | Base de datos | Relacional — encaja con la jerarquía natural del dominio (`courses → modules → labs → questions → options`). Supabase = Postgres gestionado con tier gratuito, sin operar servidores propios. Importante: **solo se usa como hosting de Postgres** — el backend se conecta con el driver `postgres` directo a `DATABASE_URL`, no con el SDK de Supabase (`@supabase/supabase-js`). Decisión deliberada: evita exponer una `anon key` en el frontend y depender de RLS como única barrera. |
| **JWT (jsonwebtoken)** | Autenticación | Stateless — el servidor no guarda sesiones, escala sin estado compartido. Expira a los 7 días. Firma HS256 con `JWT_SECRET`. |
| **React 19 + Vite + TypeScript** | Frontend SPA | Vite = arranque de dev server casi instantáneo y build optimizado (Rolldown). React 19 + componentes reutilizables para una UI con bastante interactividad (quiz, chat, panel admin). |
| **Tailwind CSS v4** | Estilos | Utility-first — velocidad de iteración visual sin escribir CSS a mano por componente. |
| **React Router v7** | Enrutamiento SPA | Rutas protegidas por rol (`PrivateRoute`, `PublicRoute`, `AdminRoute`) sin recargar el navegador. |
| **React Context (no Redux/Zustand)** | Estado global | El proyecto no tiene la complejidad de estado que justifique una librería externa — 3 contexts (`AuthContext`, `ThemeContext`, `ToastContext`) cubren todo. Ejemplo de "no sobre-ingeniería". |
| **Python + FastAPI** | Microservicio del chatbot | Python porque el ecosistema de RAG/NLP es más maduro ahí (scikit-learn para TF-IDF). FastAPI porque soporta streaming SSE nativo con `async`, necesario para la respuesta token-a-token de Uchi. |
| **Groq (modelo `openai/gpt-oss-120b`)** | Proveedor del LLM | Groq da inferencia muy rápida (hardware LPU) — clave para que el streaming se sienta natural. Expone API compatible con OpenAI (`openai.AsyncOpenAI` apuntando a otro `base_url`), así que no hace falta un SDK propietario. Nota para la charla: el modelo ha cambiado dos veces (deepseek-r1-distill-llama-70b → llama-3.3-70b-versatile → gpt-oss-120b) porque Groq **descontinúa modelos**; es un riesgo de proveedor a mencionar. |
| **scikit-learn (TF-IDF)** | RAG del chatbot | En vez de meter las 56 FAQs completas en cada prompt (caro y ruidoso), se vectorizan con TF-IDF y se recuperan solo las 3-4 más relevantes por similitud coseno. Barato, sin necesitar una base de datos vectorial. |
| **Railway** | Despliegue backend + chatbot | Soporta contenedores de larga duración (necesario para un backend con conexiones persistentes a Postgres y para el loop en background que refresca el catálogo del chatbot). Usa el builder **RAILPACK** (no Nixpacks) porque tiene soporte nativo de Bun — esto costó un incidente real de despliegue, ver §4. |
| **Vercel** | Despliegue frontend | Especializado en sitios estáticos/SPA con CDN global y preview deployments automáticos por PR — encaja con un frontend que es solo HTML/CSS/JS compilado. |
| **Gmail API (OAuth2, no SMTP)** | Envío de correos | Railway bloquea puertos SMTP salientes, así que el envío debe ser HTTPS — la API REST de Gmail lo permite. Ya hubo un intento con Brevo (SMTP de terceros) que se abandonó por problemas de alineación DKIM/DMARC con un remitente `@gmail.com` (ver incidentes, §4). |

### 2.3 Arquitectura en capas del backend (el patrón central para explicar el código)

```
HTTP Request → Routes → Middleware (JWT) → Controllers → Services → Models (validación) → DAOs → PostgreSQL
```

- **Por qué separar así:** cada capa se puede cambiar sin tocar las demás. Si cambia la DB, solo
  se tocan los DAOs. Si cambia una regla de negocio, solo Service+Model. Si cambia el formato de
  respuesta HTTP, solo el Controller. Es el argumento clásico de arquitectura en capas, y vale la
  pena decirlo explícito en la ponencia porque es la base de todo lo demás.
- **Validación en dos lugares:** los Models validan *formato* (sin tocar la DB); los Services
  validan *reglas de negocio* que sí requieren consultar la DB (unicidad de email, matrícula,
  etc.). Separar esto evita que un Model dependa de la base de datos y facilita testear reglas de
  formato de forma aislada.

---

## 3. Desarrollo

### 3.1 Backend — lo más interesante para mostrar

- **Autenticación en dos pasos:** el registro no crea el usuario de inmediato — genera un código
  de 6 dígitos, lo manda por correo, y solo crea el usuario cuando se verifica el código
  (`pendingRegistrations` en memoria, expira a los 15 min). Esto nació de un incidente real de
  seguridad (§4.2 en errores históricos): antes cualquiera podía registrarse con el correo de
  otra persona.
- **Login social (Google):** verifica el `idToken` con las JWKS públicas de Google
  (`jose`), y usa una lógica de "find-or-create" que vincula cuentas existentes por email
  verificado antes de crear una nueva — evita duplicar cuentas.
- **Sistema de actividades prácticas:** cuando el usuario completa una actividad correctamente,
  se genera un hash HMAC-SHA256 **determinístico** (`HMAC(userId:activityId, JWT_SECRET)`). El
  mismo usuario + misma actividad siempre produce el mismo hash — no se puede adivinar ni
  compartir entre usuarios, y no requiere guardar un secreto nuevo por actividad. El mismo patrón
  se reutiliza para generar y verificar el código de los certificados PDF.
- **Sistema de puntos protegido por trigger de base de datos:** los puntos nunca los envía el
  cliente — se calculan en el servidor (aciertos/5) y un trigger de Postgres
  (`trg_award_laboratory_points`) los suma automáticamente cuando el estado pasa a `completed`
  por primera vez. Ventaja de seguridad: es imposible manipular los puntos vía el endpoint de
  edición de perfil, porque ese campo ni siquiera está en la lista de campos aceptados por el
  `PATCH`.
- **Certificados PDF:** se generan con `pdfkit` + `svg-to-pdfkit`, solo si el usuario está
  matriculado y completó el 100% de los labs publicados — se recalcula en cada request (no se
  cachea "completado"), así que si se agrega un lab nuevo al curso, el certificado deja de estar
  disponible hasta completarlo también.
- **Manejo de errores tipado:** jerarquía `AppError` → `NotFoundError` / `UnauthorizedError` /
  `ForbiddenError` / `ConflictError` / `ValidationError` / `BadRequestError`, sin acoplarse a
  HTTP — un único `app.onError()` en `index.ts` traduce cada tipo a su código HTTP. Esto también
  nació de un bug real (duck-typing de errores antes de esta jerarquía, ver §4).

### 3.2 Chatbot (Uchi) — el microservicio Python

```
ChatWidget (React) → POST /chat/stream (SSE) → FastAPI
                                                  ├─ retriever.py (TF-IDF sobre knowledge.json)
                                                  ├─ prompts.py (system prompt + contexto de página)
                                                  ├─ catalog.py (refresca catálogo de cursos c/1h)
                                                  └─ config.py (cliente Groq)
```

- **RAG con TF-IDF, no embeddings/vector DB:** para 56 FAQs es suficiente y evita infraestructura
  extra (sin Pinecone/pgvector). Solo se inyectan los FAQs con `score >= 0.12` (umbral), máximo 4.
  Si la pregunta es de ciberseguridad general, normalmente no supera el umbral y el modelo
  responde desde su conocimiento base — el RAG es un complemento, no un reemplazo del modelo.
- **Catálogo de cursos dinámico:** el chatbot llama al propio `GET /api/courses` del backend
  (público, sin credenciales) cada hora en background, para que Uchi sepa de cursos nuevos sin
  que alguien tenga que editar `prompts.py` a mano. Si el backend no responde, conserva el último
  catálogo bueno conocido — nunca deja a Uchi sin catálogo.
- **Streaming SSE:** el frontend lee el stream con un patrón de buffer acumulativo (los chunks de
  red no respetan los límites de línea del protocolo SSE).
- **Aislamiento de seguridad (repetir en la charla de seguridad):** sin driver de base de datos,
  sin `DATABASE_URL`, la única credencial es `GROQ_API_KEY`. Es la decisión de diseño con más
  peso argumental de toda la ponencia.

### 3.3 Frontend

- **Rutas por nivel de acceso:** públicas, autenticación (`PublicRoute`, redirige si ya hay
  sesión), privadas (`PrivateRoute`), admin (`AdminRoute`, guard de UI — la seguridad real la
  impone `requireAdmin` en el backend en cada request, el guard del frontend es solo UX).
- **Cliente HTTP centralizado (`lib/api.ts`):** inyecta el JWT automáticamente en cada petición,
  normaliza errores. Excepciones documentadas: subida de avatar (FormData) y descarga de
  certificado (blob binario) usan `fetch` directo porque `api.ts` asume JSON.
- **Sistema visual "consola técnica" (`.hud-panel`):** rediseño de agosto 2026 que reemplazó
  tarjetas genéricas `rounded-xl` por paneles con esquina cortada (`clip-path` + `mask-composite`)
  — parte de la identidad visual distintiva del proyecto, vale la pena mostrarlo en pantalla.
- **Accesibilidad de contraste (WCAG):** hubo una auditoría real que encontró ratios de contraste
  tan bajos como 1.6:1 en modo claro (mínimo AA es 4.5:1) — se corrigió separando un `textColor`
  del `color` base para los tonos vivos (dorado, verde/rojo neón). Buen ejemplo de que "se ve
  bien en dark mode" no es suficiente — hay que medir.

---

## 4. Pruebas y aseguramiento de calidad — el bloque más fuerte para "seguridad"

Esta sección es la que más conecta con SSDLC: no es solo "hicimos tests", es "encontramos fallos
reales, con causa raíz documentada, y cambiamos el proceso para no repetirlos".

### 4.1 Auditoría de seguridad (resumen ejecutivo para la charla)

| Control | Estado |
|---|---|
| Rate limiting (backend + chatbot) | ✅ Implementado — por **cuenta** (IP+email) en `/api/auth/*`, no solo por IP, para no bloquear una demo en vivo con muchas personas en la misma red |
| RBAC (roles user/admin) | ✅ Correcto — `requireAdmin` aplicado a nivel de router completo, no ruta por ruta |
| Protección del sistema de puntos | ✅ Correcto — nunca editable por el cliente |
| SQL injection | ✅ 100% parametrizado, cero `sql.unsafe()` |
| XSS | ✅ React escapa contenido de usuario; el markdown de labs tiene un escapador propio antes de renderizar |
| Aislamiento del chatbot vs. la BD | ✅ Sin ningún camino a la base de datos |
| **RLS de Supabase** | 🔴 **No verificable desde el código** — requiere confirmarse manualmente en el dashboard de Supabase (riesgo: la API REST automática de Supabase podría estar abierta sin RLS) |
| CORS del chatbot | 🟡 `allow_origins=["*"]` — pendiente restringir a los dominios reales |
| Logging de intentos de ataque | 🟡 No implementado — no hay alertas si alguien prueba a escalar privilegios |

**Punto para la charla:** el hallazgo más alto (RLS) no es "un bug" — es la diferencia entre una
decisión de configuración de infraestructura (fuera del repo) y una garantía de código. Buen
ejemplo de que un SSDLC también audita lo que el código *no puede* garantizar por sí solo.

### 4.2 Incidentes reales, con causa raíz (elegir 3-4 para contar como historias)

- **Registro sin verificar el correo (mayo 2026):** cualquiera podía registrarse con el email de
  otra persona — hueco de seguridad real, no solo UX. Se arregló con el flujo de 2 pasos +
  código de verificación (ver §3.1). Buen ejemplo de "encontramos un problema de seguridad real
  en nuestro propio producto y lo corregimos".
- **Envío de correo roto en producción, 3 intentos en 20 minutos (mayo 2026):** SMTP vía
  `nodemailer` no funcionaba de forma confiable en Bun/Railway → migración a Gmail REST API vía
  OAuth2. Un paso intermedio olvidó regenerar el lockfile (`bun.lock`), rompiendo instalaciones
  limpias — el mismo error (quitar una dependencia sin regenerar el lockfile correcto) **se
  repitió en agosto** con `recharts`. Buen ejemplo de "patrón recurrente documentado para no
  repetirlo la tercera vez".
- **Build roto en producción durante varios días, sin que nadie lo notara (agosto 2026):** un
  typo (`justify-content` en vez de `justifyContent` en un objeto de estilos JS) rompía el build
  de TypeScript — Vercel seguía sirviendo una versión vieja del sitio silenciosamente. Se detectó
  por accidente, revisando por qué el markdown de los labs se veía mal. Lección: verificar el
  estado del último deploy después de cada push, no asumir que "si no hay alerta, todo bien".
- **El "falso" error de CORS (15 de agosto 2026) — la mejor historia de debugging metódico:** en
  producción, el navegador reportaba un error de CORS en el panel de analíticas. En vez de
  asumir que el mensaje era literal, se investigó paso a paso: se confirmó que el backend sí
  mandaba los headers CORS correctos incluso en errores; se reprodujo el stack completo en local
  (funcionaba); se instrumentaron las 12 queries que dispara la página. Causa real: el pool de
  conexiones de Postgres (`max: 10`) se agotaba con 12 queries concurrentes — sin respuesta HTTP
  completa, el navegador no puede distinguir "CORS bloqueado" de "el servidor nunca respondió", y
  por defecto reporta lo primero. Se arregló corriendo las queries en tandas de 4 y agregando un
  timeout de 15s. **Esta es la mejor anécdota para mostrar pensamiento sistemático de debugging**
  (no se arregla lo primero que parece el problema, se verifica cada hipótesis).

### 4.3 Patrón general para cerrar el bloque

Los incidentes más graves del historial comparten una causa raíz común: *algo que funcionaba en
desarrollo local fallaba silenciosamente en producción*, y el síntoma visible no apuntaba
directamente a la causa real. Es el argumento central para justificar por qué un proceso
disciplinado (documentar causa raíz, no solo "ya quedó") importa más que "funciona en mi máquina".

---

## 5. Despliegue

```
┌──────────────────┐     HTTPS      ┌──────────────────┐
│    Vercel         │ ─────────────► │    Railway        │
│  (React Frontend) │ ◄───────────── │   (Bun + Hono)     │
└────────┬───────────┘                └────────┬───────────┘
         │                                     │ SSL / PostgreSQL
         │ HTTPS (SSE)                         ▼
         │                            ┌──────────────────┐
         │                            │    Supabase       │
         ▼                            │   PostgreSQL       │
┌──────────────────┐                  └──────────────────┘
│    Railway         │
│ (FastAPI + Python)  │
│  Chatbot (Groq)     │
└──────────────────┘
```

- **Backend en Railway** con builder **RAILPACK** (no Nixpacks — incidente real de despliegue en
  mayo, Nixpacks no soportaba bien Bun).
- **Frontend en Vercel**, requiere `vercel.json` con rewrite `/(.*) → /index.html` para que React
  Router funcione en rutas directas (sin este archivo, recargar `/dashboard` da 404 — otro
  incidente real).
- **Chatbot en Railway** como servicio separado — refuerza el argumento de aislamiento: escalado
  y despliegue independientes del backend principal.
- **Variables de entorno por servicio** — nunca un secreto commiteado (se verificó todo el
  historial de git; solo existen los `.env.example`).

---

## 6. Mantenimiento y roadmap

- **Pendientes de seguridad priorizados** (checklist completo en `Documentacion-Seguridad.md`
  §13): verificar RLS en Supabase (alto), restringir CORS del chatbot (medio), logging de
  intentos de ataque (medio), TLS con verificación real hacia Supabase en vez de
  `rejectUnauthorized: false` (medio).
- **Roadmap evaluado pero no implementado:** texto-a-voz de laboratorios (ElevenLabs, pensado
  para accesibilidad — dislexia, baja visión), TTS en las respuestas de Uchi, traducción de labs
  al inglés. Se documentaron las consideraciones técnicas (almacenamiento de objetos, procesamiento
  async, costo recurrente) sin comprometerse a construirlo todavía — buena práctica de roadmap
  realista en vez de prometer de más.

---

## 7. Guion sugerido de exposición (orden para el día de la ponencia)

1. **Idea y problema** (§1) — 2-3 min. Quién, para quién, por qué existe.
2. **Diseño y arquitectura** (§2) — el bloque más largo. Mostrar el diagrama de 3 piezas y
   justificar cada tecnología con una frase corta (usar la tabla de §2.2 como chuleta).
3. **Desarrollo: backend** (§3.1) — mostrar la arquitectura en capas y 1-2 ejemplos concretos
   (hash determinístico de actividades, puntos protegidos por trigger).
4. **Desarrollo: chatbot** (§3.2) — el RAG con TF-IDF y sobre todo el aislamiento de seguridad
   (conecta directo con la sección de seguridad, sembrar la idea aquí).
5. **Desarrollo: frontend** (§3.3) — demo en vivo si es posible (dashboard, un lab, el chat de
   Uchi, el panel admin).
6. **Seguridad y pruebas** (§4) — el bloque diferenciador para un semillero de ciberseguridad.
   Auditoría (§4.1) + 2-3 anécdotas de incidentes reales (§4.2, especialmente el falso-CORS).
7. **Despliegue** (§5) — rápido, con el diagrama de infraestructura.
8. **Cierre: mantenimiento y roadmap** (§6) — qué falta, qué se evaluó y por qué no se hizo
   todavía (muestra madurez, no solo lista de features).

### Preguntas probables del jurado (para tenerlas pensadas de antemano)

- *"¿Por qué no usaron un ORM?"* → Control total sobre las queries, auditar SQL a mano, cero
  superficie de `sql.unsafe()` (mencionar que se verificó explícitamente).
- *"¿Por qué separar el chatbot en otro servicio en vez de una ruta más del backend?"* →
  Aislamiento de seguridad: el chatbot nunca tiene camino a la base de datos, aunque se
  comprometa por completo.
- *"¿Qué garantiza que los puntos no se puedan falsificar?"* → Se calculan en servidor, se
  otorgan por un trigger de Postgres, y el campo `points` ni siquiera es aceptado por el
  endpoint de edición de perfil/admin.
- *"¿Cómo saben que el sistema es seguro si el código está en un repo público?"* → Justo por eso
  se hizo la auditoría explícita (`Documentacion-Seguridad.md`) revisando SQL injection, RBAC,
  XSS, secretos commiteados (ninguno), y documentando honestamente lo que **no** se puede
  verificar solo con el código (RLS de Supabase).
- *"¿Tuvieron algún incidente de seguridad real?"* → Sí, uno concreto: el registro permitía
  crear una cuenta con el correo de otra persona sin verificarlo, corregido con el flujo de
  verificación en dos pasos (§4.2) — buena respuesta honesta en vez de decir "no, nunca".
