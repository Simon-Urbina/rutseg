# Plan de Desarrollo — Certificados de Finalización en PDF

> **Estado:** Propuesta aprobada, **no implementada**. Este documento es el plan de desarrollo
> para cuando se decida ejecutarlo.
> **Fecha:** 2026-08-12
> **Origen:** idea capturada en `Documentacion-Backend.md` §14.2 (Futuras Actualizaciones), ahora
> desarrollada como plan concreto a pedido del autor.

---

## 1. Objetivo y alcance

Cuando un usuario completa el 100% de los laboratorios publicados de un curso, puede descargar un
certificado en PDF con el logo, nombre y colores de RutSeg.

**Decisión explícita de producto — léase antes de implementar:** este certificado acredita
**finalización de contenido**, no competencia ni aptitud profesional. El texto del certificado debe
dejar esto claro (ver §5). No es una credencial de habilidad — es intencionalmente básico.

**Incluye:**
- Descarga del PDF desde `CoursePage` al completar un curso.
- Verificación pública del certificado (código + URL, sin necesidad de sesión).

**No incluye (fuera de alcance de este plan):**
- Panel de administración para gestionar/revocar certificados.
- Envío del PDF por correo.
- Certificados a nivel de módulo o de plataforma completa (solo a nivel de curso).
- Listado de "certificados obtenidos" en el dashboard o perfil (se descartó explícitamente — el
  botón vive solo en `CoursePage`, ver decisión de producto tomada el 2026-08-12).

---

## 2. Definición de "curso completado"

Un curso está completado por un usuario cuando **todos los laboratorios publicados** del curso
tienen `status = 'completed'` en su progreso — es decir, `completedLabsCount === labCount` y
`labCount > 0`.

Esto **no se cachea** como un estado persistente (no hay columna `completed_at` a nivel de curso).
Se recalcula en vivo en cada request, reutilizando el mismo dato que ya calcula
`CourseDAO.findBySlugWithStats(slug, userId)` — la misma consulta que ya alimenta la barra de
progreso de `CoursePage` (ver `backend/src/daos/CourseDAO.ts:72-111`). Ventaja de no cachear: si se
agrega un laboratorio nuevo a un curso después de que un usuario ya lo había completado, ese usuario
simplemente deja de calificar para el certificado hasta completar el lab nuevo — sin migraciones de
datos ni estados inconsistentes que limpiar.

---

## 3. Backend

### 3.1 Nueva dependencia

```
bun add pdfkit svg-to-pdfkit
bun add -d @types/pdfkit
```

**Por qué esta combinación y no otra:**
- `pdf-lib` (alternativa evaluada) no soporta SVG — habría que rasterizar `public/logo.svg` a PNG
  primero, con una herramienta externa (`sharp`/`resvg`, dependencias nativas que complican el
  build en Railway).
- `pdfkit` + `svg-to-pdfkit` dibuja el `logo.svg` **actual, tal cual está**, directamente en el PDF
  vectorialmente. Cero pasos de conversión, cero dependencias nativas — compatible con Bun/Railway
  igual que el resto del stack.

### 3.2 Código de verificación determinístico

Nuevo archivo `backend/src/utils/certificate.ts`, siguiendo exactamente el mismo patrón que ya
existe en `backend/src/utils/response.ts` (`generateActivityResponse`, usado para las actividades
prácticas — ver `Documentacion-Backend.md` §9.1):

```typescript
import { createHmac } from 'crypto'

/** Código de verificación determinista por par usuario+curso. Mismo patrón que
 * generateActivityResponse() en response.ts — no requiere guardar nada en base de datos,
 * el código se puede recalcular siempre que se necesite verificar. */
export function generateCertificateCode(userId: string, courseId: string): string {
  const secret = process.env.JWT_SECRET ?? 'fallback-secret'
  return createHmac('sha256', secret)
    .update(`certificate:${userId}:${courseId}`)
    .digest('hex')
    .slice(0, 12)
    .toUpperCase()
}
```

No se crea ninguna tabla nueva. El código se recalcula tanto al generar el PDF como al verificarlo.

### 3.3 Nuevo servicio: `CertificateService`

Nuevo archivo `backend/src/services/CertificateService.ts`:

- `getCompletionStatus(userId, courseSlug)` → llama a `CourseDAO.findBySlugWithStats(slug, userId)`,
  lanza `NotFoundError` si el curso no existe, `ForbiddenError` si `!isEnrolled`, y devuelve
  `{ course, isCompleted: completedLabsCount === labCount && labCount > 0, completedLabsCount, labCount }`.
- `generatePdf(user, course)` → arma el documento con `pdfkit` (ver §5 para el layout exacto),
  calcula `generateCertificateCode(user.id, course.id)`, devuelve un `Buffer`.
- `verify(username, courseSlug, code)` → busca `UserDAO.findByUsername`, `CourseDAO.findBySlug`,
  recalcula `generateCertificateCode` y `getCompletionStatus`, devuelve
  `{ valid: boolean, courseTitle?, username?, completedAt? }` sin filtrar datos sensibles del
  usuario (nunca el email).

### 3.4 Nuevos endpoints

En `backend/src/routes/courses.ts`, junto a la ruta de `enroll`:

```typescript
router.get('/:slug/certificate', requireAuth, CourseController.getCertificate)
```

`CourseController.getCertificate` — devuelve el PDF como descarga binaria directa (primer endpoint
del backend que hace esto; hasta ahora los binarios, como el avatar, se devuelven en base64 dentro
de JSON — ver `UserService.getMyProfile`). Con Hono:

```typescript
static async getCertificate(c: Context) {
  const user = c.get('user') as TokenPayload
  const { course } = await CertificateService.getCompletionStatus(user.id, c.req.param('slug')!)
  // getCompletionStatus lanza ForbiddenError si no está 100% completado
  const pdfBuffer = await CertificateService.generatePdf(user, course)
  c.header('Content-Type', 'application/pdf')
  c.header('Content-Disposition', `attachment; filename="rutseg-${course.slug}.pdf"`)
  return c.body(pdfBuffer)
}
```

Nuevo archivo de rutas `backend/src/routes/certificates.ts`, montado en `index.ts` como
`app.route('/api/certificates', certificateRoutes)`:

```typescript
router.get('/verify', CertificateController.verify)
// GET /api/certificates/verify?username=...&courseSlug=...&code=...
```

Sin `requireAuth` — es un endpoint público a propósito (cualquiera debe poder verificar un
certificado sin iniciar sesión).

---

## 4. Frontend

### 4.1 Botón de descarga en `CoursePage.tsx`

Junto al bloque de "Progress bar" ya existente (`frontend/src/pages/CoursePage.tsx:209-234`), agregar
un botón condicionado a `completed === total && total > 0`:

```tsx
{course.isEnrolled && total > 0 && completed === total && (
  <button onClick={handleDownloadCertificate} className="btn-gold mt-4 ...">
    Descargar certificado
  </button>
)}
```

`handleDownloadCertificate` hace `fetch` directo (no pasa por `api.ts`, igual que la subida de
avatar, porque la respuesta es un blob binario, no JSON):

```tsx
const res = await fetch(`${BASE_URL}/api/courses/${slug}/certificate`, {
  headers: { Authorization: `Bearer ${token}` },
})
const blob = await res.blob()
const url = URL.createObjectURL(blob)
const a = document.createElement('a')
a.href = url
a.download = `rutseg-${slug}.pdf`
a.click()
URL.revokeObjectURL(url)
```

### 4.2 Página pública de verificación

Nueva página `frontend/src/pages/VerifyCertificatePage.tsx`, ruta pública
`/verify/:username/:courseSlug/:code` (sin `PrivateRoute` ni `PublicRoute` — accesible con o sin
sesión, igual que `/u/:username`). Al montar, llama a
`GET /api/certificates/verify?username=...&courseSlug=...&code=...` y muestra:
- **Válido:** "✓ Certificado válido — {username} completó {courseTitle} en RutSeg."
- **No válido:** "✗ No se pudo verificar este certificado."

Reutiliza `Header`/`Footer` como el resto de páginas públicas (`AboutPage`, `PrivacyPolicyPage`).

---

## 5. Diseño visual y texto del certificado (aprobado 2026-08-12)

- **Orientación:** horizontal (landscape), tamaño carta.
- **Colores de marca:** azul oscuro `#1A3F96`, cian `#2596be`, amarillo `#F5C500` (paleta ya
  documentada en `Documentacion-Frontend.md` §8).
- **Logo:** `frontend/public/logo.svg` dibujado vectorialmente vía `svg-to-pdfkit`, centrado arriba,
  junto al texto "RutSeg".
- **Título:** *"Certificado de Finalización"* — nunca "de competencia", "de aprobación" ni "de
  aptitud".
- **Cuerpo:**
  > Se certifica que **{username}** completó el curso **"{Título del Curso}"** en RutSeg,
  > plataforma de laboratorios prácticos en ciberseguridad del Semillero de Investigación en
  > Ciberseguridad y Desarrollo de Software — Universidad Santo Tomás, Tunja.
- **Fecha:** fecha de finalización (fecha del request de generación, ya que no se cachea un
  `completed_at` a nivel de curso — ver §2).
- **Disclaimer al pie (obligatorio, no omitir):**
  > Este certificado acredita la finalización del contenido del curso. No constituye una
  > evaluación ni una certificación de competencia profesional.
- **Código y URL de verificación**, en letra pequeña:
  `Código: {code}` · `Verificar en: rutseg.vercel.app/verify/{username}/{courseSlug}/{code}`

---

## 6. Pasos de implementación (orden sugerido)

1. `bun add pdfkit svg-to-pdfkit` + `@types/pdfkit` en `backend/`.
2. `backend/src/utils/certificate.ts` — `generateCertificateCode()`.
3. `backend/src/services/CertificateService.ts` — `getCompletionStatus()`, `verify()` (sin PDF
   todavía, para poder probar la lógica de completado/verificación con tests simples antes de meterle
   generación de PDF).
4. `backend/src/services/CertificateService.ts` — `generatePdf()` con el layout de §5.
5. `backend/src/controllers/CertificateController.ts` + `backend/src/routes/certificates.ts`
   (endpoint `verify`, público) — registrar en `index.ts`.
6. `CourseController.getCertificate` + ruta `GET /:slug/certificate` en `courses.ts`.
7. Frontend: botón en `CoursePage.tsx` + función de descarga.
8. Frontend: `VerifyCertificatePage.tsx` + ruta pública `/verify/:username/:courseSlug/:code` en
   `App.tsx`.
9. Actualizar `Documentacion-Backend.md` (nuevos endpoints en §8) y `Documentacion-Frontend.md`
   (nueva página en §4 y §5) — mismo estándar que se mantuvo para el flujo de login con Google.
10. Prueba manual end-to-end: completar un curso de prueba al 100%, descargar el PDF, verificar que
    el logo/colores/texto sean correctos, y confirmar el link de verificación desde una sesión sin
    login.

---

## 7. Riesgos y consideraciones abiertas

- **`svg-to-pdfkit` con el SVG actual:** el logo usa solo `path`/`stroke`/`fill` simples (sin
  gradientes ni filtros), que es lo que mejor soporta esta librería. Si el logo cambia a algo más
  complejo en el futuro, revisar compatibilidad antes de asumir que se sigue viendo igual en el PDF.
- **Nombre de usuario cambiante:** si un usuario cambia su `username` después de descargar un
  certificado, el PDF ya descargado sigue diciendo el username viejo, pero la URL de verificación
  (que incluye el username) dejaría de resolver. Aceptable para v1 dado el alcance básico — no se
  soluciona en este plan.
- **Fecha de finalización real vs. fecha de descarga:** como no se cachea `completed_at` a nivel de
  curso, la fecha impresa es la fecha en la que se **descarga** el PDF, no necesariamente la fecha en
  la que se completó el último lab. Si esto importa más adelante, se necesitaría agregar una columna
  o derivarla del `completed_at` más reciente entre los laboratorios del curso — no incluido en este
  plan por mantenerlo simple.
