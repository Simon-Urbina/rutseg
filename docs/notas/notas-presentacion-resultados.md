# Notas para la ponencia de RutSeg — resultados y funcionalidad

> Complemento de `notas-presentacion-ssdlc.md`. Ese otro documento es sobre el **proceso**
> (arquitectura, stack, por qué se eligió cada cosa). Este es sobre el **resultado**: qué existe
> hoy, qué hace, qué se administra y qué valor entrega — pensado para una audiencia a la que no
> le importa cómo está hecho por dentro, salvo el punto de seguridad.
>
> Fuentes: mismas que el documento anterior (`docs/documentacion/*.md`, `README.md`).

---

## 0. Frase de apertura

RutSeg es una plataforma de aprendizaje práctico en ciberseguridad — cursos, laboratorios
interactivos y quizzes, con gamificación por puntos, certificación verificable y una comunidad —
**funcionando hoy en producción**, no un prototipo.

---

## 1. Qué puede hacer un estudiante (la cara pública)

- **Registro seguro:** formulario + código de verificación de 6 dígitos enviado al correo (o
  login directo con Google en un clic).
- **Explorar el catálogo de cursos:** dificultad, número de módulos/labs, puntos totales que se
  pueden ganar, y si ya está matriculado o no.
- **Matricularse y avanzar laboratorio por laboratorio:** cada laboratorio combina contenido
  explicativo (markdown), una **actividad práctica interactiva** (ejecutar una acción, como un
  comando en una terminal simulada) y un **quiz de 5 preguntas**.
- **Feedback inmediato:** aciertos/fallos, explicación de cada respuesta, animación y sonido de
  resultado al aprobar.
- **Progreso persistente:** se puede reintentar cuantas veces se quiera; siempre se guarda el
  mejor puntaje obtenido.
- **Gamificación real:** puntos otorgados automáticamente al aprobar un laboratorio (≥60% de
  aciertos), acumulados en un **ranking global** con posición, puntos y biografía de cada usuario.
- **Perfil público** por usuario (`/u/:username`), visible sin necesidad de iniciar sesión.
- **Certificado de finalización en PDF**, descargable al completar el 100% de un curso —
  incluye un código que **cualquiera puede verificar públicamente** (sin iniciar sesión) para
  confirmar que es auténtico, no falsificable.
- **Foro comunitario:** publicar preguntas/comentarios y responder, lectura libre para cualquiera.
- **Asistente de IA "Uchi":** disponible en toda la plataforma, responde en tiempo real
  (streaming, texto apareciendo palabra por palabra) sobre cómo usar RutSeg y sobre conceptos de
  ciberseguridad en general, adaptando su respuesta a la página donde está el usuario.
- **Modo oscuro / claro**, con la preferencia recordada entre visitas.
- **Uso desde el celular** — la interfaz es responsive, incluido el chat de Uchi.
- **Transparencia legal:** banner de consentimiento de cookies, política de privacidad y
  términos de uso accesibles desde cualquier página.

---

## 2. Qué se administra (panel de administración)

Todo el contenido y los usuarios se gestionan **desde la interfaz web**, sin tocar código ni la
base de datos directamente:

- **Catálogo completo:** crear, editar y borrar cursos → módulos → laboratorios → preguntas →
  opciones de respuesta, todo desde formularios del panel admin.
- **Control de calidad automático del contenido:** si se borra una pregunta y un laboratorio
  queda incompleto (menos de 5 preguntas), **se despublica automáticamente** — evita que un
  estudiante encuentre un laboratorio roto a medio editar.
- **Gestión de usuarios:** buscar por username/email, ver el detalle de cualquier cuenta, editar
  sus datos, cambiar su contraseña sin pedir la actual, cambiar su rol, o eliminar la cuenta
  (con confirmación explícita y salvaguardas: un administrador no puede eliminarse a sí mismo ni
  quitarse su propio rol de admin — evita quedarse sin acceso por accidente).
- **Panel de analíticas:** KPIs y 11 gráficas (usuarios nuevos, puntos otorgados, cursos
  completados, actividad general) filtrables por rango de tiempo — últimos 7 días, 1 mes, 1 año
  o 5 años. Da visibilidad real de cómo está creciendo/usándose la plataforma, no solo de que
  "funciona".
- En resumen: **el equipo puede operar el día a día de la plataforma (nuevo curso, corregir una
  pregunta, resetear la contraseña de alguien) sin depender de un desarrollador ni de tocar
  Supabase/Railway directamente.**

---

## 3. Contenido real ya construido (no es una plataforma vacía)

- **3 cursos ya publicados** sobre el OWASP Top 10, con contenido educativo completo:
  - Control de Acceso Roto (*Broken Access Control*)
  - Inyección (SQL Injection)
  - Fallos de Identificación y Autenticación
- Cada curso trae sus módulos, sus laboratorios, su actividad práctica y sus 5 preguntas de quiz
  por laboratorio — contenido curado, no relleno de ejemplo.

---

## 4. Seguridad, como resultado (el punto que sí les va a importar)

Sin entrar en el cómo — solo lo que la plataforma **logra**:

- **Auditoría de seguridad completa realizada y documentada**, no una suposición de que "está
  seguro".
- **Cero vulnerabilidades de inyección SQL encontradas** — se verificó explícitamente todo el
  código en busca de consultas sin parametrizar.
- **Protección contra XSS** en todo el contenido escrito por usuarios (foro, biografías).
- **Protección contra fuerza bruta** en login/registro, diseñada para no bloquear a un grupo
  grande de personas presentando la plataforma en vivo desde la misma red — protege por cuenta,
  no solo por IP.
- **Los puntos y el rol de cada usuario no se pueden manipular desde el cliente** — solo el
  servidor decide cuántos puntos gana alguien y nadie puede auto-asignarse el rol de
  administrador.
- **Certificados imposibles de falsificar** — el código de verificación se recalcula del lado del
  servidor, no se puede inventar uno válido desde afuera.
- **El asistente de IA está aislado de la base de datos** — aunque alguien lograra comprometerlo
  por completo, no obtendría ningún acceso a los datos de usuarios.
- **Transparencia sobre lo que falta:** hay un pendiente declarado (confirmar una configuración
  de seguridad adicional en el panel de la base de datos en la nube) — se documenta abiertamente
  en vez de ocultarlo, que es justo la postura que un proyecto de un semillero de ciberseguridad
  debería mostrar.

---

## 5. Qué se consigue con todo esto (el cierre de valor)

- Una **herramienta educativa completa y funcional**, en producción, no una maqueta ni un
  prototipo de clase.
- **Aprendizaje práctico verificable:** el estudiante no solo lee teoría, hace algo y se le
  otorga evidencia descargable y verificable de que lo logró.
- **Motivación por diseño:** puntos, ranking y comunidad en vez de contenido pasivo — se
  construyó pensando en que la gente vuelva, no solo en que el contenido exista.
- **Costo de operación mínimo:** todo el stack corre en planes gratuitos/económicos, así que la
  plataforma se sostiene sin presupuesto de infraestructura.
- **Un caso de estudio real de buenas prácticas:** la propia plataforma es evidencia de lo que
  enseña — un semillero de ciberseguridad construyó una herramienta de ciberseguridad aplicando
  los mismos principios que enseña en sus laboratorios.
- **Espacio para crecer sin rehacer nada:** ya hay ideas evaluadas para el futuro (audio de
  laboratorios para accesibilidad, más cursos, traducción) que se apoyan en lo que ya existe.

---

## 6. Para la demo en vivo

- El endpoint público de estadísticas (`/api/stats`) expone en tiempo real el número de cursos,
  laboratorios, usuarios registrados y puntos totales otorgados — se puede mostrar en pantalla
  durante la charla como prueba de que los números son reales, no inventados para la
  presentación.
- Buen recorrido de demo: login/registro → explorar un curso → completar un laboratorio (actividad
  + quiz) → ver los puntos sumados en el ranking → descargar el certificado (si aplica) →
  abrir el chat de Uchi y hacerle una pregunta → mostrar brevemente el panel admin (crear/editar
  algo en vivo) → cerrar con el panel de analíticas.

---

## 7. Guion sugerido para esta parte de la charla

1. Frase de apertura (§0) — qué es, en una línea, y que está en producción.
2. Demo en vivo del flujo de estudiante (§1 + §6) — es la parte que más engancha.
3. Vista rápida del panel admin (§2) — mostrar que no es solo una demo bonita, hay una
   herramienta real de gestión detrás.
4. Mencionar el contenido ya construido (§3) — refuerza que no es una cáscara vacía.
5. Bloque de seguridad como resultado (§4) — el único "cómo" que vale la pena tocar aquí, en
   términos de logros, no de implementación.
6. Cierre de valor (§5) — por qué esto importa, para quién, y hacia dónde puede crecer.
