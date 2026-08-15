# Documentación de Errores Históricos — RutSeg

> **Audience:** Equipo del proyecto (Semillero de Investigación en Ciberseguridad y Desarrollo de
> Software, USTA Tunja) y cualquier persona que necesite entender qué problemas reales ha tenido la
> plataforma en producción y cómo se resolvieron.
> **Fecha:** 2026-08-15
> **Alcance:** Reconstrucción a partir del historial de `git` (122 commits, desde el primer commit
> el 2026-02-27 hasta hoy) más observación directa de la sesión de trabajo del 2026-08-15. Cada
> hallazgo cita el o los commits donde ocurrió el arreglo (`git show <hash>` reproduce el diff
> exacto). Se excluyen deliberadamente los commits que son solo features nuevas, rebrands o
> refactors sin un bug real detrás — donde un commit mezcla ambas cosas, se documenta solo la parte
> que corrige algo roto.

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [Autenticación, Correo Electrónico y Google OAuth](#2-autenticación-correo-electrónico-y-google-oauth)
3. [CORS y Despliegue](#3-cors-y-despliegue)
4. [Integridad de Datos y Panel de Administración](#4-integridad-de-datos-y-panel-de-administración)
5. [Frontend, Accesibilidad y UX](#5-frontend-accesibilidad-y-ux)
6. [Sonido y Política de Autoplay del Navegador](#6-sonido-y-política-de-autoplay-del-navegador)
7. [Panel de Analíticas (agosto 2026)](#7-panel-de-analíticas-agosto-2026)
8. [Patrones Recurrentes y Lecciones Aprendidas](#8-patrones-recurrentes-y-lecciones-aprendidas)

---

## 1. Resumen Ejecutivo

| # | Incidente | Categoría | Fecha | Severidad real |
|---|---|---|---|---|
| 2.1 | Envío de correos roto en producción (3 intentos) | Auth/Email | 2026-05-11 | 🔴 Alta — reset de contraseña no funcionaba |
| 2.2 | Registro sin verificar propiedad del correo | Auth/Seguridad | 2026-05-16 | 🔴 Alta — cualquiera podía registrarse con el correo de otro |
| 2.3 | Headers de correo sin codificar (RFC 2047) | Auth/Email | 2026-05-16 | 🟡 Media — asunto/remitente corruptos con tildes |
| 2.4 | Manejo de errores por duck-typing | Backend | 2026-05-20 | 🟡 Media — errores mal clasificados, sin garantías de tipo |
| 3.1 | CORS no soportaba previews de Vercel | Despliegue | 2026-05-11 | 🟡 Media — bloqueaba pruebas antes de producción |
| 3.2 | Regex de CORS desactualizado tras el rebrand | Despliegue | 2026-05-16 | 🟡 Media |
| 3.3 | Builder de Railway incompatible con Bun | Despliegue | 2026-05-03 | 🔴 Alta — el backend no desplegaba |
| 4.1 | Violación de índice único al marcar opción correcta | Backend/Datos | 2026-08-06 | 🟡 Media — bloqueaba edición de preguntas |
| 4.2 | Estadísticas de curso nuevo incorrectas | Backend/Frontend | 2026-08-06 | 🟢 Baja — solo visual, momentáneo |
| 4.3 | Slugs rotos con tildes y guiones sobrantes | Backend | 2026-08-06 | 🟡 Media — URLs de contenido inválidas |
| 4.4 | Build roto en producción durante varios días | Despliegue | 2026-08-10 | 🔴 Alta — Vercel servía una versión vieja sin que nadie lo notara |
| 4.5 | Markdown mal renderizado en laboratorios | Frontend | 2026-08-10 | 🟡 Media — contenido educativo ilegible |
| 5.1–5.6 | Contraste, tamaños inconsistentes, avatar roto, CSS reset | Frontend/UX | 2026-05-06 a 2026-08-10 | 🟡 Media, acumulativa |
| 6.1–6.4 | Sonidos silenciados por política de autoplay | Frontend/UX | 2026-05-17 | 🟢 Baja — cosmético pero recurrente (4 iteraciones) |
| 7 | Panel de Analíticas: 9 bugs reales encontrados en 3 rondas de revisión, incluyendo un "falso" error de CORS cuya causa real era agotamiento del pool de conexiones | Full-stack | 2026-08-15 | 🔴 Alta — la página no cargaba en producción |

**Lectura rápida:** los incidentes más graves (correo roto, registro sin verificar, build roto durante días, y el falso-CORS de hoy) comparten una causa raíz común: **algo que funcionaba en el entorno de desarrollo local fallaba silenciosamente en producción**, y el síntoma visible (un error de red, un botón que no hace nada) no apuntaba directamente a la causa real. La sección 8 desarrolla este patrón.

---

## 2. Autenticación, Correo Electrónico y Google OAuth

### 2.1 Envío de correos roto en producción — 3 intentos hasta estabilizarse

**Commits:** `28df6bb` "Arreglo del correo" → `a26e58d` "fix: regenerate bun.lock after removing nodemailer" → `2f44de8` "fix: usar Buffer.from para codificar el email en base64 compatible con Bun" (los tres el 2026-05-11, en menos de 20 minutos entre el primero y el último)

**Qué estaba roto:** El envío de correos (reset de contraseña) usaba `nodemailer` con SMTP de Gmail (usuario + contraseña de aplicación). No funcionaba de forma confiable en el entorno de despliegue (Bun en Railway).

**Causa raíz y arreglo, en 3 pasos:**
1. **`28df6bb`** — se abandonó `nodemailer`/SMTP por completo, migrando a la API REST de Gmail (OAuth2: refresh token → access token → `POST /gmail/v1/users/me/messages/send` con el mensaje MIME en base64).
2. **`a26e58d`** — al quitar `nodemailer` de `package.json` se olvidó regenerar `bun.lock`, que quedó con la entrada vieja. Cualquier instalación limpia (`bun install --frozen-lockfile`) fallaba porque el lockfile ya no coincidía con `package.json`.
3. **`2f44de8`** — la codificación del mensaje MIME usaba `btoa(unescape(encodeURIComponent(mime)))`, un hack heredado de navegador para base64 seguro con UTF-8 que es frágil fuera de ese contexto. Se reemplazó por `Buffer.from(mime, 'utf-8').toString('base64')`, la forma nativa correcta en Bun.

> **Nota:** esta secuencia exacta — quitar una dependencia sin regenerar el lockfile correcto — se repitió el 2026-08-15 en la sesión de Analíticas (ver §7), con `bun.lock` vs. un `package-lock.json` de npm generado por error. Ver §8.

### 2.2 Registro sin verificar que el correo le pertenece al usuario

**Commit:** `36a3fbe` "Validación de Correo con Código" (2026-05-16)

**Qué estaba roto:** `AuthController.register` creaba el usuario en la base de datos **inmediatamente**, sin comprobar que el correo ingresado le perteneciera a quien se registraba. Cualquier persona podía registrarse con el correo de otra persona, o uno que no existiera, y la plataforma lo aceptaba como válido — un hueco de seguridad real, no solo un detalle de UX.

**Cómo se arregló:** se separó el registro en dos pasos:
- `AuthService.prepareRegistration()` valida y prepara los datos, pero **no** crea el usuario — el registro queda "pendiente" en memoria (`Map`, expira a los 15 minutos) junto a un código de 6 dígitos enviado por correo.
- `AuthService.createUser()` solo se llama después de que `AuthController.verifyEmail` confirma que el código ingresado es correcto.

Incluye reenvío de código con el mismo patrón anti-enumeración que ya usaba el reset de contraseña (la respuesta no revela si el correo existe o no).

**Limitación conocida (no es un bug, es una decisión de diseño a esta escala):** tanto los registros pendientes como los tokens de reset de contraseña viven en memoria del proceso — se pierden si el servidor se reinicia mientras un usuario tiene un registro a medias. Aceptable hoy, pero relevante si los reinicios/deploys se vuelven frecuentes.

### 2.3 Headers de correo sin codificar (RFC 2047)

**Commit:** `b1e2eee` "Mejora de correos" (2026-05-16, 40 minutos después de §2.2)

**Qué estaba roto:** los headers `Subject:` y el nombre visible en `From:` ("CyberSec Labs") se insertaban como texto plano en el MIME. El estándar MIME exige que los headers sean ASCII — cualquier tilde o ñ en esos headers específicamente (el cuerpo HTML sí declaraba `charset=utf-8` correctamente) podía llegar corrupta o hacer que clientes de correo estrictos rechazaran el mensaje.

**Cómo se arregló:** se agregó una función `encodeHeader()` que codifica en RFC 2047 (`=?UTF-8?B?...?=`), aplicada al asunto y al nombre del remitente. De paso se eliminó la duplicación entre las dos funciones de envío (verificación y reset de contraseña) en un helper compartido `sendRawEmail`.

### 2.4 Manejo de errores por duck-typing → jerarquía de excepciones tipada

**Commit:** `465ce18` "Autofocus y Manejo de Errores" (2026-05-20)

**Qué estaba roto:** todo error HTTP intencional era una sola clase `HTTPError` con una propiedad `status: number` libre. El handler global de errores hacía `err as HTTPError` (cast sin garantía) y comprobaba `typeof httpErr.status === 'number'` — cualquier error que no fuera explícitamente un `HTTPError` con `.status` seteado caía en silencio al 500 genérico, aunque semánticamente debiera ser un 404/401/403.

**Cómo se arregló:** se introdujo una clase base `AppError` con subclases explícitas por caso — `NotFoundError`, `ForbiddenError`, `ConflictError`, `UnauthorizedError`, `BadRequestError`, `ValidationError` — cada una mapeada a su código HTTP correcto vía `instanceof` en el handler global. Esta es la arquitectura de manejo de errores que sigue vigente hoy en todo el backend, incluyendo el código nuevo del Panel de Analíticas (§7).

### No fueron bugs (verificado, no se fuerzan como error)

- **`6c1d80e`** "Simplifica login con Google" (2026-08-12) — decisión de UX/legal: antes el botón de Google quedaba deshabilitado hasta marcar el checkbox de privacidad del formulario manual; se cambió para que el botón esté siempre activo con el aviso de consentimiento debajo. No corrige ningún bug.
- **`ed6d849`** "Actualización" (2026-08-10) — es donde nace Google OAuth por primera vez (`UserOAuthDAO`, `SocialAuthButtons.tsx`), no una corrección.

---

## 3. CORS y Despliegue

### 3.1 → 3.2 CORS: de un string exacto a un patrón, y su mantenimiento tras el rebrand

**Commits:** `58a5ca4` "fix: allow vercel preview URLs in CORS" (2026-05-11) → `da9739c` "CORS de la FRONTEND_URL" (2026-05-16)

**Qué estaba roto (3.1):** la configuración original de CORS comparaba el origin contra un único string exacto (`process.env.FRONTEND_URL`). Cada deploy de preview de Vercel (por rama/PR) genera una URL distinta, así que **ningún preview funcionaba** — solo la URL de producción exacta pasaba CORS.

**Cómo se arregló:** se cambió a una función `origin: (origin) => ...` que acepta cualquier origin que matchee un patrón de subdominio de Vercel del proyecto, además de la lista explícita de `FRONTEND_URL` (ahora soporta múltiples orígenes separados por coma).

**Qué pasó después (3.2):** cuando el proyecto se renombró de "CyberSec Labs" a "RutSeg", el regex quedó desactualizado (seguía buscando `cyberseclabs...`) y hubo que actualizarlo a `rutseg[^.]*\.vercel\.app`. Es el mismo regex que sigue en el código hoy, y el que se confirmó funcionando correctamente durante la investigación del falso-CORS de esta sesión (§7.2) — un rebrand de nombre de producto es exactamente el tipo de cambio que rompe silenciosamente una regla de CORS basada en el nombre.

### 3.3 Builder de Railway incompatible con Bun

**Commit:** `07cefb0` "fix: cambiar builder de NIXPACKS a RAILPACK para soporte nativo de Bun" (2026-05-03)

**Qué estaba roto:** el backend (Bun) no desplegaba correctamente en Railway.

**Causa raíz:** `backend/railway.json` especificaba `"builder": "NIXPACKS"`, que no tiene soporte nativo robusto para Bun.

**Cómo se arregló:** cambio de una línea a `"builder": "RAILPACK"`.

### 3.4 Tipos de Bun/Node contaminando el tsconfig del frontend

**Commits:** `199eacf` "fix: remove bun/node types from frontend tsconfig" → `199ccc3` "fix: add @types/node to frontend for vite.config.ts" (2026-05-11, 4 minutos de diferencia)

**Qué estaba roto:** `frontend/tsconfig.app.json` incluía `"types": ["vite/client", "bun"]` — el tipo `"bun"` es para código de runtime Bun (backend), no para código de navegador, y mezclarlo puede sombrear tipos DOM/Web API. El primer commit lo corrigió, pero en el mismo cambio vació `tsconfig.node.json`'s `"types"` a `[]`, rompiendo el tipado de `vite.config.ts` (que sí necesita tipos de Node — `process`, `path`).

**Cómo se arregló:** el commit siguiente, 4 minutos después, instaló `@types/node` como devDependency real y restauró `"types": ["node"]` en `tsconfig.node.json`.

---

## 4. Integridad de Datos y Panel de Administración

### 4.1 Violación de índice único al marcar una opción de quiz como correcta

**Commit:** `694d2fd` "fix(admin): unset sibling options before marking one correct (unique index ordering)" (2026-08-06)

**Qué estaba roto:** al crear o editar una opción de respuesta marcándola como correcta desde el panel admin, la transacción fallaba por violación de índice único.

**Causa raíz:** el código insertaba/actualizaba la opción con `is_correct=true` **antes** de desmarcar las opciones hermanas de la misma pregunta, dejando momentáneamente dos filas con `is_correct=true` — violando el índice único que garantiza una sola respuesta correcta por pregunta.

**Cómo se arregló:** se invirtió el orden — desmarcar todas las hermanas primero, luego marcar la nueva — evitando el estado transitorio inválido.

### 4.2 Estadísticas de curso nuevo incorrectas justo después de crearlo

**Commit:** `87a7aa7` "fix(admin): default new-course stats to 0 instead of trusting incomplete create response" (2026-08-06)

**Qué estaba roto:** tras crear un curso desde el panel admin, la tarjeta mostraba datos de módulos/labs/puntos inconsistentes.

**Causa raíz:** `POST /api/admin/courses` devuelve la fila cruda de la tabla (sin las columnas calculadas `moduleCount`/`labCount`/`totalPoints`, que solo calcula el `GET` de listado). El frontend asumía que la respuesta del `POST` tenía la forma completa y la insertaba tal cual en el estado local.

**Cómo se arregló:** se tipó la respuesta del `POST` reflejando los campos que realmente trae, y al insertar el curso nuevo en el estado local se rellenan esos 3 campos explícitamente en `0` en vez de confiar en datos que el backend nunca envió. (El mismo tipo de disciplina de contrato explícito front↔back que se aplicó hoy en el Panel de Analíticas, §7.)

### 4.3 Slugs rotos con tildes y guiones sobrantes

**Commit:** `703bc4a` "refactor(admin): tighten adminApi types and fix slugify hyphen edges" (2026-08-06)

**Qué estaba roto:** al generar el slug de un curso/módulo/lab con tildes (ej. "Introducción") o con signos al inicio/final (ej. "¿Qué es XSS?"), el slug resultante quedaba mal formado — tildes sin remover, o guiones al inicio/final (`-que-es-xss-`).

**Cómo se arregló:** se corrigió el rango de escape Unicode usado para remover diacríticos (`̀-ͯ`, explícito y no ambiguo) y se agregó un recorte de guiones sobrantes al inicio/final del slug.

### 4.4 → 4.5 Build roto en producción durante varios días + Markdown mal renderizado

**Commit:** `7be63eb` "fix: reparar build roto y renderizado de Markdown en laboratorios" (2026-08-10)

**Qué estaba roto (4.4, el más grave de este bloque):** `DashboardPage.tsx` tenía `justify-content` como key de un objeto de estilos en JS (debía ser `justifyContent`, camelCase) — esto rompía `tsc`/`vite build` por completo. Como consecuencia, **el deploy de Vercel llevaba fallando desde varios commits atrás**, y en producción seguía sirviéndose una versión vieja de la interfaz sin que nadie lo notara hasta este fix.

**Qué estaba roto (4.5):** el conversor de Markdown casero (sin librería) de los laboratorios no soportaba cursivas, listas numeradas, citas ni líneas horizontales — el contenido educativo real aparecía literal en pantalla (asteriscos y todo) en vez de renderizado.

**Cómo se arregló:** corrección del typo camelCase; se agregó soporte para esos 4 casos de Markdown al conversor casero (incluyendo renumeración correcta de listas interrumpidas por bloques de código); se agregaron los estilos CSS faltantes para el contenido generado.

### No fueron bugs (verificado)

- `dab2a68`, `22164ad` — endpoints y salvaguardas nuevas del panel admin, sin un incidente previo documentable.
- `029afb0` — es el commit inicial que crea todo el esquema de base de datos; "correcciones de triggers" en el mensaje no se puede aislar de la construcción inicial.
- `7fd56db` "Seeds y Arreglo de Preguntas" — mayormente contenido nuevo (3 seeds OWASP) y una feature de búsqueda; no hay evidencia de un bug de código corregido.

---

## 5. Frontend, Accesibilidad y UX

### 5.1 CSS reset sin `@layer` pisaba todas las utilities de Tailwind v4

**Commit:** `1121faf` "fix: corregir espaciado roto y suavizar color blanco en dark mode" (2026-05-06)

**Qué estaba roto:** el espaciado (`px-6`, `py-20`, `mx-auto`, etc.) no se aplicaba en ninguna parte de la app.

**Causa raíz** (del propio commit): el reset CSS (`*, *::before, *::after { margin:0; padding:0; ... }`) estaba fuera de cualquier `@layer`. En Tailwind v4, las reglas sin capa tienen mayor especificidad de cascada que las utilities generadas dentro de `@layer utilities`.

**Cómo se arregló:** mover el reset dentro de `@layer base { ... }`.

### 5.2 Tarjetas invisibles en modo oscuro (matemática de color)

**Commit:** `2845e42` "fix: mejorar contraste de tarjetas en tema oscuro" (2026-05-07)

**Qué estaba roto:** las tarjetas (landing, dashboard, ranking, auth) eran prácticamente invisibles en modo oscuro.

**Causa raíz:** el fondo de tarjeta (`rgba(6,13,31,0.x)`) era el mismo color que el fondo de página (`#060D1F`) con transparencia — al componerse matemáticamente sobre un fondo casi idéntico, la tarjeta se "mezclaba" y desaparecía visualmente.

**Cómo se arregló:** cambio a `rgba(13,27,70,0.85)` — un azul más claro y más opaco, visualmente distinto del fondo. **Este es exactamente el mismo token de color que se usó en todas las tarjetas del Panel de Analíticas (§7)** — se volvió el estándar del proyecto desde este fix.

### 5.3 Avatar no se mostraba (contrato de campo desalineado)

**Commit:** `f4e7a99` "fix: corregir display del avatar y añadir UI de subida de foto" (2026-05-07)

**Qué estaba roto:** la foto de perfil nunca se veía en el dashboard.

**Causa raíz:** el frontend esperaba un campo `avatar_url`, pero el backend en realidad devuelve `profileImage` como string base64 crudo, sin el prefijo `data:image/jpeg;base64,` que un `<img src=...>` necesita para renderizarlo.

**Cómo se arregló:** usar el campo correcto y anteponer el prefijo `data:` antes de asignarlo a `src`.

### 5.4 Tamaño de tarjeta inconsistente entre temas + placeholder invisible en modo claro

**Commit:** `82b0248` "fix: rebrand login/registro a paleta USTA y corregir tamaño en light mode" (2026-05-07)

**Qué estaba roto:** la tarjeta de login/registro cambiaba de tamaño entre modo claro y oscuro (padding/radio de borde distintos); el placeholder del input estilo terminal era invisible en modo claro.

**Cómo se arregló:** unificar padding y border-radius en ambos temas; agregar un color de placeholder específico para modo claro.

### 5.5 Auditoría de contraste WCAG en modo claro (multi-componente)

**Commit:** `2dd6c90` "fix(ui): contraste en modo claro y navegacion/filtros en dashboards" (2026-08-10)

**Qué estaba roto** (con ratios de contraste reales medidos en el propio commit):
- Bordes de panel (`.hud-panel`) invisibles en modo claro (opacidad 0.16).
- Botones deshabilitados con `opacity:0.5` difuminando texto y fondo juntos — "Crear cuenta gratis" leía a ~2.8:1 (el mínimo WCAG AA es 4.5:1).
- Candado de labs bloqueados a ~2.2:1 sobre fondo casi blanco.
- Colores vivos (dorado, verde/rojo neón, azul plata) usados como texto sólido en tarjetas claras: 1.6–2.7:1, "se veían lavados".

**Causa raíz:** los colores se diseñaron y probaron solo en modo oscuro, nunca validados contra fondos claros.

**Cómo se arregló:** subir opacidad de bordes; estado fijo legible para botones deshabilitados; **separar un campo `textColor` del campo `color` para los tonos de dificultad** — el dorado es ilegible como texto sólido, se necesita un tono más oscuro para texto.

> **Esto es el precedente directo de lo que se hizo hoy en el Panel de Analíticas:** el mismo color dorado (`#F5C500`) con el mismo problema de contraste insuficiente, resuelto con el mismo patrón (un tono más oscuro dedicado a texto/series), mano en aquel momento — hoy con la skill `dataviz`, que además detectó dos colores adicionales con el mismo problema que esta auditoría manual no había cubierto (ver §7 y §8).

---

## 6. Sonido y Política de Autoplay del Navegador

Cuatro commits el mismo día (2026-05-17), resolviendo capas sucesivas del mismo problema real: los navegadores bloquean la reproducción de audio que no ocurre de forma síncrona dentro de un gesto del usuario (click, tap).

### 6.1 Sonidos no sonaban en absoluto

**Commit:** `9ad94d9` "fix: move sound triggers to LabPage to respect browser autoplay policy"

**Causa raíz:** el sonido se disparaba dentro de un `useEffect` de un componente (`ResultModal`) que se monta *después* de un `await` (la respuesta del submit del quiz) — para entonces ya se salió del contexto síncrono de gesto de usuario que los navegadores exigen. Además, un hook `useSound('', { volume: 0.6 })` con URL vacía corrompía el `AudioContext` completo, silenciando también los demás sonidos.

**Cómo se arregló:** mover los hooks de sonido al componente que sí está en la cadena del gesto del usuario (el click de "Enviar" en `LabPage`), disparar el sonido *antes* del primer `await`, y eliminar el hook roto.

### 6.2 Documentación del constraint

**Commit:** `4fc0f94` — agrega una nota permanente en la documentación técnica: los hooks de sonido deben instanciarse en el componente que tiene el evento de usuario.

### 6.3 Checkbox seguía fallando + sonido de más

**Commit:** `6e889ef` "fix: consolidate checkbox sounds into onClick, lower and stop rising-percent"

**Causa raíz:** `onMouseDown` dispara *antes* de que `AudioContext.resume()` complete tras el primer gesto de la página — el sonido se perdía en esa ventana de milisegundos.

**Cómo se arregló:** mover el trigger a `onClick`; cortar el sonido de "rising percent" con un `setTimeout` a los 1500ms.

### 6.4 Aprobar un lab se quedó sin sonido de éxito

**Commit:** `7b30177` "fix: Sonido success"

**Causa raíz:** el fix de §6.1 quitó el hook roto de sonido de aprobación, pero nunca lo reemplazó por uno funcional — reprobar tenía sonido, aprobar no.

**Cómo se arregló:** agregar un archivo de audio real y conectarlo condicionalmente al resultado del quiz.

---

## 7. Panel de Analíticas (agosto 2026)

Esta es la feature más reciente y la que más pasó por revisión activa antes de darse por cerrada — 8 tareas implementadas y revisadas individualmente, más 3 rondas de revisión adicionales que encontraron 9 bugs reales antes de considerar el trabajo terminado.

### 7.1 Bugs encontrados en la revisión final de la feature (commits `1ddf180`, `d7e3089`, `8d0ed49`)

| # | Bug | Causa raíz | Fix |
|---|---|---|---|
| 1 | El lockfile de `recharts` nunca se generó con `bun` | El plan de implementación pedía `npm install recharts`, pero el frontend usa `bun.lock` como lockfile — se commiteó un `package-lock.json` de npm con binarios nativos solo de Windows, que habría roto el build en el servidor Linux de Vercel | Regenerar `bun.lock` con `bun install`, eliminar el `package-lock.json` |
| 2 | Colisión de IDs de gradiente SVG | 3 de 4 gráficas de área compartían `dataKey="count"`, y el ID del gradiente se construía solo a partir de eso — 2 de las 4 gráficas pintaban con el color equivocado | ID único combinando `dataKey` + color |
| 3 | Etiquetas de fecha con un día de desfase | Los buckets se calculan en UTC en la base de datos, pero el frontend formateaba la fecha en la zona horaria local del navegador | Forzar `timeZone: 'UTC'` en el formateo |
| 4 | Rangos de 1 año/5 años con etiquetas ambiguas | El formato de fecha estaba fijo a día+mes sin importar si el bucket real era mensual | Formato condicional según la unidad de bucket, con año quando corresponde |
| 5 | La tasa de finalización de curso podía superar el 100% | La query contaba finalizaciones de labs de **cualquier** usuario con progreso, sin exigir que estuviera inscrito en el curso (un admin puede acceder a labs sin inscribirse) | Restringir el numerador a usuarios efectivamente inscritos |

### 7.2 El "falso" error de CORS — causa real: agotamiento del pool de conexiones

El usuario reportó en producción: `Access to fetch at '.../api/admin/analytics' ... blocked by CORS policy: No 'Access-Control-Allow-Origin' header` + `net::ERR_FAILED`.

**Investigación (no se asumió que el mensaje del navegador era literal):**
1. Se probó el backend desplegado directamente: tanto el preflight `OPTIONS` como una petición sin autenticar devolvían correctamente el header `Access-Control-Allow-Origin` — incluso en la respuesta de error 401. Esto descartó una mala configuración de CORS real.
2. Se reprodujo el stack completo localmente (servidor Hono real + token de admin generado localmente + la misma base de datos de producción) — una sola petición funcionaba perfectamente.
3. Se instrumentó cada una de las 12 queries que dispara la página (vía `Promise.all`) en dos tandas sucesivas simulando una segunda carga/cambio de rango. En la segunda tanda, 10 de 12 queries terminaban en menos de 700ms, pero las 2 restantes se quedaban colgadas **indefinidamente**.

**Causa raíz confirmada:** el pool de conexiones de PostgreSQL (`max: 10`) era menor que las 12 queries concurrentes que dispara cada carga de esta página. Sin una respuesta HTTP completa, ningún header (incluido el de CORS) podía llegar al navegador — de ahí el mensaje engañoso.

**Commit `1ddf180`:** primer intento, subir `max` a 20 — mitiga pero no resuelve de raíz (2 administradores cargando la página a la vez ya vuelven a saturar el pool).

### 7.3 Hallazgos de la revisión de los fixes anteriores (commit `eff538d`)

Una revisión independiente de los commits `1ddf180`/`d7e3089`/`8d0ed49`/`b29978c`/`516845a` encontró que 4 de los arreglos solo corregían el problema a medias:

1. **El aumento del pool solo subía el umbral, no lo eliminaba.** Se cambió `AdminAnalyticsService.getAnalytics` para correr las 12 queries en tandas de 4 en vez de las 12 a la vez, acotando la concurrencia que esta ruta necesita sin importar cuántos administradores la usen a la vez.
2. **No había ningún timeout** — si algo se colgaba igual, la petición seguía sin fallar rápido. Se agregó un límite de 15 segundos: si se excede, la petición falla con un 500 real (con headers CORS, que Hono preserva incluso en la respuesta de error) en vez de colgarse hasta que el navegador la reporte como error de CORS.
3. **El primer bucket de cada gráfica de serie de tiempo quedaba parcial** (`since` sin truncar al inicio del período), mostrando una caída falsa al inicio de cada gráfica que no reflejaba actividad real.
4. **El fix de "método de registro" (auth) solo arreglaba el conteo doble, no la atribución** — un usuario que se registró con contraseña y luego vinculó Google seguía apareciendo como "google" en vez de "password". Se corrigió priorizando `password_hash IS NOT NULL` sobre el proveedor OAuth vinculado.

**Total de bugs reales encontrados y corregidos en esta feature antes de considerarla estable: 9**, en 3 rondas de revisión (revisión final de las 8 tareas, investigación del falso-CORS, y revisión de los fixes del falso-CORS).

---

## 8. Patrones Recurrentes y Lecciones Aprendidas

Mirando el historial completo, los mismos tipos de error aparecen más de una vez, en momentos distintos del proyecto:

1. **Quitar una dependencia sin regenerar el lockfile correcto.** Pasó con `nodemailer` en mayo (§2.1, paso 2) y otra vez con `recharts`/`bun.lock` en agosto (§7.1, bug 1) — ambas veces el lockfile quedó desincronizado de `package.json` y solo se detectó porque alguien probó una instalación limpia o el build de producción falló.
2. **Contraste de color insuficiente en modo claro, específicamente con el dorado (`#F5C500`).** Se corrigió a mano en agosto 10 (§5.5) separando un `textColor` del `color` base, y volvió a aparecer en el mismo tono dorado el 15 de agosto en las gráficas del Panel de Analíticas — esta vez detectado automáticamente por la skill `dataviz` antes de llegar a producción, junto con dos colores adicionales que la auditoría manual de agosto no había cubierto.
3. **Un rebrand de nombre de producto rompe silenciosamente reglas basadas en el nombre.** El regex de CORS (§3.2) tuvo que actualizarse cuando el proyecto pasó de "CyberSec Labs" a "RutSeg" — cualquier configuración futura que compare contra el nombre del proyecto debería revisarse si el proyecto se renombra otra vez.
4. **Un error de red en el navegador no siempre significa lo que dice.** El mensaje "bloqueado por CORS" del 15 de agosto (§7.2) no tenía nada que ver con CORS — la causa real era un pool de conexiones agotado en el backend. Cuando una petición nunca recibe una respuesta HTTP completa, el navegador no tiene forma de distinguir "el servidor rechazó esto por CORS" de "el servidor nunca respondió", y por defecto reporta lo primero.
5. **Un build roto en producción puede pasar desapercibido.** El typo `justify-content` (§4.4) dejó a Vercel sirviendo una versión vieja de la interfaz durante varios commits, sin que nadie lo notara hasta que alguien revisó por qué el markdown de los laboratorios se veía mal — vale la pena, a futuro, verificar el estado del último deploy después de cada push, no solo confiar en que el pipeline avisará si algo se rompe.
6. **Los bugs de "primer gesto del usuario" (autoplay de audio) necesitaron 4 iteraciones** antes de estabilizarse (§6) — cada fix resolvía un síntoma pero dejaba otro sin cubrir (el checkbox, el sonido de éxito) hasta que se documentó la regla general ("los hooks de sonido van en el componente con el evento de usuario") en vez de parchear caso por caso.
