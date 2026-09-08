-- =============================================================================
-- seed_owasp_a10_excepciones.sql
-- Curso OWASP Top 10 2025 — A10: Manejo Inadecuado de Condiciones Excepcionales
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 2 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A10 — Manejo Inadecuado de Condiciones Excepcionales (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a10-condiciones-excepcionales',
  'OWASP A10: Manejo Inadecuado de Condiciones Excepcionales',
  'Categoría nueva del OWASP Top 10 2025. Aprende qué pasa cuando una aplicación no previene, no detecta o no responde bien ante una situación inesperada: mensajes de error que filtran información, agotamiento de recursos, condiciones de carrera en transacciones, y un caso real de este mismo tipo de fallo.',
  'intermedio',
  TRUE,
  id
FROM users WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title        = EXCLUDED.title,
  description  = EXCLUDED.description,
  difficulty   = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- =============================================================================
-- MÓDULO 1: Fallar Abierto vs Fallar Cerrado, y Errores que Filtran Información
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'fail-open-vs-fail-closed-y-errores',
  'Fallar Abierto vs Fallar Cerrado, y Errores que Filtran Información',
  'Qué es exactamente un manejo inadecuado de condiciones excepcionales, por qué se convirtió en categoría propia en 2025, y cómo un mensaje de error demasiado detallado puede convertirse en información de reconocimiento para un atacante.',
  1
FROM courses c WHERE c.slug = 'owasp-a10-condiciones-excepcionales'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Qué es un Manejo Inadecuado de Condiciones Excepcionales ───────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-es-un-manejo-inadecuado-de-excepciones',
  'Qué es un Manejo Inadecuado de Condiciones Excepcionales',
  E'## Una categoría nueva en 2025\n\nEsta es una categoría completamente nueva del OWASP Top 10 2025. Antes, muchos de estos problemas se agrupaban bajo la etiqueta general de "mala calidad de código" — una descripción demasiado amplia como para guiar una corrección concreta. En 2025, OWASP le da nombre propio y agrupa 24 tipos de debilidad (CWE) relacionados.\n\n## Tres formas de fallar ante lo inesperado\n\nToda aplicación se va a encontrar, tarde o temprano, con una situación que no esperaba: un parámetro ausente, una conexión de red caída, una condición de memoria agotada. Lo que distingue a una aplicación bien diseñada no es que esas situaciones nunca ocurran, sino cómo responde cuando ocurren. OWASP identifica tres fallas posibles, y basta con que ocurra una para tener este problema:\n\n1. **No prevenir** la situación inusual desde el principio (por ejemplo, no validar un parámetro antes de usarlo).\n2. **No detectar** que la situación está ocurriendo (una excepción que se ignora silenciosamente).\n3. **No responder bien** una vez detectada (capturar el error pero no hacer nada útil con él).\n\n## Un ejemplo simple\n\n```\nfunción procesarPago(monto):\n    resultado = banco.cobrar(monto)   ← ¿qué pasa si esto lanza una excepción?\n    registrarVenta(resultado)\n    devolverConfirmacion()\n```\n\nSi `banco.cobrar()` lanza una excepción y nadie la captura, tres cosas pueden pasar según cómo esté construido el sistema: la aplicación se cae por completo (mala experiencia, pero al menos visible), la excepción se propaga hasta un manejador genérico que oculta el detalle (mejor, pero puede que nadie se entere), o —el peor caso— el código continúa ejecutándose como si el pago hubiera funcionado, registrando una venta que nunca se cobró.\n\n## Por qué "código de mala calidad" no era suficiente como categoría\n\nUn typo o una variable mal nombrada es mala calidad de código, pero no necesariamente un riesgo de seguridad. OWASP decidió separar específicamente los fallos de manejo de excepciones porque, a diferencia de un typo, **sí tienen un impacto directo y predecible en la seguridad**: exposición de información, denegación de servicio, o estados de datos corruptos que un atacante puede aprovechar deliberadamente.\n\n---\nCompleta el quiz para ganar **120 puntos**.',
  1, 20, 120, TRUE
FROM course_modules cm WHERE cm.slug = 'fail-open-vs-fail-closed-y-errores'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cómo se agrupaban muchos de estos problemas antes de que A10:2025 existiera como categoría propia?',
  'Bajo la etiqueta general de "mala calidad de código", una descripción demasiado amplia para guiar una corrección concreta y específica.'
FROM laboratories l WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'Según OWASP, ¿cuántos tipos de debilidad (CWE) agrupa esta nueva categoría?',
  '24 CWEs distintos, relacionados con la prevención, detección y respuesta ante situaciones inesperadas en el software.'
FROM laboratories l WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Cuáles son las tres formas en que una aplicación puede fallar ante una condición excepcional?',
  'No prevenirla, no detectarla, o no responder bien una vez detectada. Basta con que ocurra una de las tres para tener este tipo de fallo.'
FROM laboratories l WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  'En el ejemplo de "procesarPago", ¿cuál es el peor escenario posible si nadie captura la excepción del cobro?',
  'Que el código continúe ejecutándose como si el pago hubiera funcionado, registrando una venta que en realidad nunca se cobró — un estado de datos corrupto y potencialmente aprovechable.'
FROM laboratories l WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué OWASP separó específicamente los fallos de manejo de excepciones de la categoría general de "mala calidad de código"?',
  'Porque, a diferencia de un typo o error cosmético, estos fallos tienen un impacto directo y predecible en la seguridad: exposición de información, denegación de servicio, o datos corruptos explotables.'
FROM laboratories l WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Bajo "mala calidad de código", una etiqueta demasiado amplia', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No se agrupaban en ningún lado, eran ignorados', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Bajo Inyección, por error de clasificación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Bajo Diseño Inseguro exclusivamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '24', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '5', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '50', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '1', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No prevenirla, no detectarla, o no responder bien ante ella', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usar demasiadas variables globales, pocas funciones, código muy largo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Usar un lenguaje interpretado en vez de compilado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No comentar el código adecuadamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El sistema registra una venta que nunca se cobró realmente', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El sistema se reinicia automáticamente sin pérdida de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El usuario recibe un mensaje de error muy claro', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El banco bloquea la cuenta del usuario preventivamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque tienen un impacto directo y predecible en la seguridad', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque son más fáciles de corregir que otros errores', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque ocurren solo en lenguajes orientados a objetos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque afectan solo a la velocidad de la aplicación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-manejo-inadecuado-de-excepciones' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Mensajes de Error que Filtran Información ──────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'mensajes-de-error-que-filtran-informacion',
  'Mensajes de Error que Filtran Información',
  E'## El error como fuente de reconocimiento\n\nCuando algo falla en un servidor y la respuesta incluye el stack trace completo, un atacante no ve solo "hubo un error" — ve el framework exacto que corre, la versión de una librería, la ruta de archivos en el servidor, y a veces hasta fragmentos de la consulta a la base de datos que falló.\n\n```\n// Respuesta de error mal diseñada:\nUnhandledPromiseRejectionWarning: SequelizeConnectionError:\n  at Connection.connect (/app/node_modules/sequelize/lib/dialects/postgres/connection-manager.js:87)\n  DATABASE_URL: postgresql://admin:***@10.0.4.12:5432/produccion\n```\n\nEste único mensaje revela: el ORM usado, su versión, la ruta interna del proyecto, la IP interna de la base de datos, y el nombre del usuario de la base de datos. Ninguna de esas piezas es una vulnerabilidad por sí sola, pero juntas son un mapa detallado para el siguiente paso del ataque.\n\n## Comparando: qué debería ver el usuario vs qué debería registrarse\n\n| Destino | Qué debe contener |\n|---|---|\n| Respuesta al usuario | Un mensaje genérico ("Ocurrió un error, intenta de nuevo") y, como mucho, un ID de referencia |\n| Log interno del servidor | El stack trace completo, con todo el detalle técnico necesario para depurar |\n\nEsta separación no es un capricho: el usuario nunca necesita el detalle técnico para actuar, y el atacante nunca debería recibirlo.\n\n## Observando una respuesta de error real\n\n```bash\ncurl -s https://httpbin.org/status/500\n```\n\nEste comando fuerza una respuesta 500 en un endpoint de prueba seguro y muestra el cuerpo completo de la respuesta. httpbin.org, de forma responsable, no filtra ningún detalle interno — es exactamente el comportamiento que cualquier aplicación real debería imitar ante un error inesperado.\n\n## La relación con A02 (Configuración de Seguridad)\n\nEste fallo está muy relacionado con la configuración insegura: muchos frameworks tienen un "modo debug" que muestra estos detalles, pensado para desarrollo local, y el error ocurre cuando ese modo queda activo en producción por descuido.\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  2, 25, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'fail-open-vs-fail-closed-y-errores'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué un stack trace completo mostrado al usuario es valioso para un atacante?',
  'Porque revela detalles técnicos como el framework exacto, versiones de librerías y rutas internas del servidor — información de reconocimiento que facilita planear el siguiente paso de un ataque.'
FROM laboratories l WHERE l.slug = 'mensajes-de-error-que-filtran-informacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'Según la buena práctica de separación, ¿qué debería recibir el usuario final ante un error interno?',
  'Un mensaje genérico, como mucho con un ID de referencia — el detalle técnico completo debe quedar únicamente en el log interno del servidor.'
FROM laboratories l WHERE l.slug = 'mensajes-de-error-que-filtran-informacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué httpbin.org es un buen ejemplo de comportamiento deseable ante un error 500?',
  'Porque no filtra ningún detalle interno en su respuesta de error, exactamente el comportamiento que cualquier aplicación real debería imitar ante una condición excepcional.'
FROM laboratories l WHERE l.slug = 'mensajes-de-error-que-filtran-informacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Cómo se relaciona este fallo con A02 (Configuración de Seguridad)?',
  'Muchos frameworks tienen un "modo debug" pensado para desarrollo local que muestra estos detalles; el fallo ocurre cuando ese modo queda activo en producción por una mala configuración.'
FROM laboratories l WHERE l.slug = 'mensajes-de-error-que-filtran-informacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Fuerza una respuesta de error 500 contra httpbin.org y muestra el cuerpo completo de la respuesta en modo silencioso. Copia el comando que usarías.',
  'curl -s https://httpbin.org/status/500 muestra la respuesta completa de un error forzado, sin barra de progreso, permitiendo observar si el cuerpo de la respuesta filtra algún detalle técnico.'
FROM laboratories l WHERE l.slug = 'mensajes-de-error-que-filtran-informacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Revela detalles técnicos útiles para reconocimiento', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque ejecuta código automáticamente en el navegador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque siempre contiene contraseñas en texto plano', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque bloquea el acceso de usuarios legítimos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un mensaje genérico, con un ID de referencia como mucho', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El stack trace completo, para que pueda reportarlo mejor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'La consulta SQL exacta que falló', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La IP interna del servidor de base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No filtra ningún detalle interno en su respuesta de error', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque nunca devuelve errores 500', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque requiere autenticación para cualquier petición', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque cifra automáticamente todas sus respuestas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un modo debug pensado para desarrollo queda activo en producción', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No tienen ninguna relación entre sí', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'A02 siempre causa este fallo directamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo se relacionan en aplicaciones móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Observando una respuesta de error con curl',
  E'## Objetivo\n\nAprende a forzar y observar una respuesta de error completa, para evaluar si un sistema filtra información sensible en sus mensajes de error.\n\n## Instrucciones\n\n```bash\ncurl -s https://httpbin.org/status/500\n```\n\n**Desglose:**\n- `https://httpbin.org/status/500`: endpoint de prueba que devuelve el código HTTP que le pidas en la URL\n- `-s`: modo silencioso, sin barra de progreso\n\n**Qué observar:**\n\nLa respuesta de httpbin.org ante este error es intencionalmente mínima, sin ningún detalle técnico interno. Compara mentalmente esto con el ejemplo del laboratorio, donde un stack trace completo revelaba el ORM, la versión y hasta la IP interna de la base de datos — esa es exactamente la diferencia entre un manejo de errores correcto y uno que filtra información.\n\nCopia el **comando exacto** que usarías para observar esta respuesta y úsalo en el quiz.',
  'curl -s https://httpbin.org/status/500',
  '¡Correcto! Ya sabes cómo evaluar si un sistema filtra información en sus respuestas de error. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mensajes-de-error-que-filtran-informacion' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Agotamiento de Recursos, Condiciones de Carrera y un Caso Real
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'recursos-condiciones-de-carrera-y-un-caso-real',
  'Agotamiento de Recursos, Condiciones de Carrera y un Caso Real',
  'Cómo un manejo inadecuado de excepciones puede convertirse en denegación de servicio o en un estado de datos corrupto, y una historia real de un incidente de producción causado exactamente por este tipo de fallo.',
  2
FROM courses c WHERE c.slug = 'owasp-a10-condiciones-excepcionales'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Agotamiento de Recursos y Condiciones de Carrera ───────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'agotamiento-de-recursos-y-condiciones-de-carrera',
  'Agotamiento de Recursos y Condiciones de Carrera',
  E'## Cuando un error "menor" se convierte en denegación de servicio\n\nImagina un endpoint que abre una conexión o reserva un recurso (un archivo, una conexión de base de datos, un lock) antes de procesar una petición. Si ocurre una excepción a mitad de camino y el código nunca libera ese recurso, cada petición fallida deja el sistema un poco más cerca de agotar sus recursos disponibles.\n\n```\nPetición 1 falla → recurso queda reservado, nunca liberado\nPetición 2 falla → otro recurso queda reservado, nunca liberado\n...\nPetición N falla → ya no quedan recursos disponibles → el sistema deja de responder a TODOS los usuarios\n```\n\nNinguna petición individual fue un ataque. La denegación de servicio surgió de que el manejo de errores nunca contempló liberar lo que se había reservado.\n\n## Observando el comportamiento con peticiones lentas\n\n```bash\ncurl -s -o /dev/null -w "codigo=%{http_code} tiempo=%{time_total}s\\n" https://httpbin.org/delay/2\n```\n\nEste comando mide cuánto tarda en responder un endpoint deliberadamente lento (`httpbin.org/delay/2` espera 2 segundos antes de responder). En un sistema real con un límite de conexiones concurrentes, varias peticiones lentas al mismo tiempo son exactamente el tipo de escenario que puede agotar ese límite si el manejo de errores no libera recursos a tiempo.\n\n## Condiciones de carrera en transacciones de varios pasos\n\nUna transacción financiera típica tiene varios pasos: debitar la cuenta de origen, acreditar la cuenta de destino, registrar el movimiento. Si el sistema se interrumpe (por una excepción, un corte de red) entre el paso 1 y el paso 2, y **no revierte todo el proceso** al fallar, puede quedar en un estado intermedio explotable: dinero debitado que nunca se acreditó en ningún lado, o —peor— una condición de carrera que permite ejecutar el paso de acreditación varias veces antes de que el sistema note el error.\n\n## La regla de "fallar cerrado" en transacciones\n\nCualquier transacción de varios pasos interrumpida a mitad de camino debe **revertirse por completo** ("fallar cerrado"), no continuar desde donde se quedó ni dejar el estado a medias. Intentar "recuperar" una transacción parcial suele ser, en la práctica, donde se crean los errores más difíciles de corregir después.\n\n---\nCompleta el quiz y la actividad para ganar **260 puntos**.',
  1, 30, 260, TRUE
FROM course_modules cm WHERE cm.slug = 'recursos-condiciones-de-carrera-y-un-caso-real'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cómo puede una excepción "menor" convertirse en una denegación de servicio para todos los usuarios?',
  'Si el código nunca libera un recurso reservado cuando ocurre una excepción, cada petición fallida acerca al sistema al agotamiento total de ese recurso, hasta dejar de responder a todos.'
FROM laboratories l WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué hace el endpoint "httpbin.org/delay/2" usado en la actividad de este laboratorio?',
  'Espera deliberadamente 2 segundos antes de responder, útil para simular y medir el comportamiento de peticiones lentas que podrían agotar recursos si son muchas a la vez.'
FROM laboratories l WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'En una transacción financiera de varios pasos interrumpida a mitad de camino, ¿qué riesgo aparece si no se revierte todo?',
  'Puede quedar un estado intermedio explotable: dinero debitado que nunca se acreditó, o incluso una condición de carrera que permita ejecutar un paso varias veces antes de que el sistema note el error.'
FROM laboratories l WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué recomienda la regla de "fallar cerrado" para una transacción de varios pasos interrumpida?',
  'Revertirla por completo, no continuar desde donde se quedó ni dejar el estado a medias — intentar "recuperar" una transacción parcial suele generar los errores más difíciles de corregir después.'
FROM laboratories l WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Mide el código de estado y el tiempo total de una petición al endpoint de prueba que responde con 2 segundos de retraso. Copia el comando que usarías.',
  'curl con -w permite imprimir métricas como el código HTTP y el tiempo total de la petición, útil para observar el impacto de endpoints lentos en el comportamiento del sistema.'
FROM laboratories l WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cada fallo deja un recurso reservado sin liberar, hasta agotarlos todos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque cada excepción borra automáticamente la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque las excepciones se propagan al navegador del atacante', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque cada excepción reinicia el servidor por completo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Espera 2 segundos antes de responder', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Bloquea la IP del solicitante por 2 segundos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Devuelve un archivo de 2 megabytes', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Repite la petición automáticamente 2 veces', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un estado intermedio explotable, como dinero debitado sin acreditar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo un mensaje de error visual sin consecuencias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Una mejora automática en el rendimiento del sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Una desconexión temporal sin ningún otro efecto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Revertirla por completo, no dejar el estado a medias', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Continuar desde el último paso completado exitosamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Reintentar automáticamente hasta veinte veces', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Notificar al usuario y dejar la transacción como estaba', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Midiendo el impacto de una petición lenta',
  E'## Objetivo\n\nAprende a medir el tiempo de respuesta de un endpoint, para razonar sobre cómo peticiones lentas podrían agotar recursos limitados.\n\n## Instrucciones\n\n```bash\ncurl -s -o /dev/null -w "codigo=%{http_code} tiempo=%{time_total}s\\n" https://httpbin.org/delay/2\n```\n\n**Desglose:**\n- `https://httpbin.org/delay/2`: endpoint de prueba que espera 2 segundos antes de responder\n- `-o /dev/null`: descarta el cuerpo de la respuesta\n- `-w "codigo=%{http_code} tiempo=%{time_total}s\\n"`: imprime el código HTTP y el tiempo total que tomó la petición\n\n**Salida de ejemplo:**\n\n```\ncodigo=200 tiempo=2.034s\n```\n\nSi un sistema tiene, por ejemplo, un límite de 10 conexiones simultáneas y recibe 15 peticiones como esta al mismo tiempo, las últimas 5 tendrán que esperar — y si el manejo de errores no libera conexiones que fallan a tiempo, ese límite se agota mucho más rápido de lo esperado.\n\nCopia el **comando exacto** que usarías para medir esta petición y úsalo en el quiz.',
  'curl -s -o /dev/null -w "codigo=%{http_code} tiempo=%{time_total}s\n" https://httpbin.org/delay/2',
  '¡Bien hecho! Ya sabes medir el impacto de una petición lenta en el comportamiento de un sistema. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'agotamiento-de-recursos-y-condiciones-de-carrera' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Manejo Centralizado de Errores — Lección de un Caso Real ───────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'manejo-centralizado-de-errores-leccion-de-un-caso-real',
  'Manejo Centralizado de Errores: Lección de un Caso Real',
  E'## Un manejador de errores, no diez\n\nOWASP recomienda que el manejo de errores, el logging y las alertas ocurran en **un único lugar centralizado**, en vez de que cada función maneje sus propios errores a su manera. Esto no es solo una preferencia de estilo: cuando cada parte del sistema decide por su cuenta qué hacer ante una excepción, revisar y auditar el comportamiento del sistema ante errores se vuelve prácticamente imposible.\n\n```\nSin manejo centralizado:  cada función decide su propia lógica de error → comportamiento inconsistente, difícil de auditar\nCon manejo centralizado:  todas las excepciones pasan por un único punto → un solo lugar que revisar y mejorar\n```\n\n## Una jerarquía de errores tipada\n\nUna buena práctica es definir tipos de error específicos (por ejemplo: recurso no encontrado, no autorizado, prohibido, conflicto, error de validación) en vez de lanzar errores genéricos que un manejador central tiene que **adivinar** cómo traducir a una respuesta HTTP. Cuando el tipo de error ya viene definido desde su origen, el manejador central solo necesita un mapeo simple y directo entre cada tipo y su código HTTP correspondiente.\n\n## Un caso real: cuando el error correcto tenía la causa equivocada\n\nUna plataforma en producción empezó a mostrar, en su panel de administración, un error de "bloqueado por política de origen cruzado" (CORS) en el navegador. Habría sido fácil asumir que el mensaje era literal y tocar la configuración de CORS. En vez de eso, el equipo verificó paso a paso: confirmaron que el backend sí enviaba los headers correctos incluso en sus respuestas de error, reprodujeron el problema en un entorno local (donde funcionaba sin problema), e instrumentaron cada una de las doce consultas que esa página disparaba a la vez.\n\nLa causa real: el límite de conexiones simultáneas a la base de datos se agotaba con esas doce consultas ejecutándose en paralelo. Cuando una petición nunca recibe una respuesta HTTP completa, el navegador no tiene forma de distinguir "el servidor la bloqueó por CORS" de "el servidor nunca respondió" — y por defecto, reporta lo primero.\n\nLa solución no fue tocar CORS: fue ejecutar esas consultas en tandas más pequeñas y agregar un límite de tiempo explícito, para que una petición fallara rápido y con una respuesta clara en vez de colgarse indefinidamente.\n\n## La lección que conecta todo el curso\n\nUn mensaje de error, por claro que parezca, puede señalar hacia la causa equivocada si el sistema nunca fue diseñado para fallar de forma legible. Verificar cada hipótesis con evidencia, en vez de arreglar lo primero que parece el problema, es la disciplina que convierte un manejo de excepciones reactivo en uno realmente confiable.\n\n---\nCompleta el quiz para ganar **280 puntos**.',
  2, 30, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'recursos-condiciones-de-carrera-y-un-caso-real'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué OWASP recomienda un manejo de errores centralizado en vez de que cada función decida por su cuenta?',
  'Porque cuando cada parte del sistema maneja los errores a su manera, el comportamiento se vuelve inconsistente y prácticamente imposible de auditar como un todo.'
FROM laboratories l WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué ventaja ofrece una jerarquía de errores tipada frente a lanzar errores genéricos?',
  'El manejador central ya no tiene que adivinar cómo traducir cada error a una respuesta HTTP: solo necesita un mapeo simple entre cada tipo definido y su código correspondiente.'
FROM laboratories l WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'En el caso real descrito, ¿cuál fue la causa verdadera del error que el navegador reportaba como "CORS"?',
  'El límite de conexiones simultáneas a la base de datos se agotaba con doce consultas en paralelo, y sin una respuesta HTTP completa, el navegador reportó por defecto un bloqueo de CORS en vez de la falta de respuesta real.'
FROM laboratories l WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué el navegador reportó "bloqueado por CORS" cuando el problema real era otro?',
  'Porque cuando una petición nunca recibe una respuesta HTTP completa, el navegador no puede distinguir entre un bloqueo real de CORS y la ausencia total de respuesta, así que por defecto reporta lo primero.'
FROM laboratories l WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Cuál fue la disciplina clave que permitió encontrar la causa real del incidente en vez de quedarse con la primera suposición?',
  'Verificar cada hipótesis con evidencia concreta (confirmar los headers, reproducir en local, instrumentar las consultas) en vez de arreglar lo primero que parecía ser el problema.'
FROM laboratories l WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Hace el comportamiento consistente y auditable en un solo lugar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Hace que el sistema use menos memoria RAM', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de logging', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Hace que el código se ejecute más rápido siempre', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un mapeo simple y directo entre cada tipo y su código HTTP', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Elimina por completo la posibilidad de errores', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifra automáticamente cada mensaje de error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Reduce el tamaño del código en un 50%', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El límite de conexiones a la base de datos se agotaba con 12 consultas paralelas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'La configuración de CORS realmente estaba mal escrita', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El navegador del usuario estaba desactualizado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El certificado TLS del sitio había expirado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No puede distinguir un bloqueo real de CORS de la ausencia total de respuesta', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque CORS siempre se reporta cuando hay lentitud', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque el navegador tenía un error interno de caché', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque el servidor envió un mensaje de CORS por error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Verificar cada hipótesis con evidencia, no arreglar lo primero que parece', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Reiniciar el servidor apenas aparece cualquier error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Confiar siempre en el primer mensaje de error mostrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Deshabilitar CORS por completo para evitar el mensaje', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'manejo-centralizado-de-errores-leccion-de-un-caso-real' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A10 — intermedio)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (120, 200, 260, 280 puntos)
--   Preguntas:    20 nuevas (18 opción múltiple + 2 actividad)
--   Actividades:  2 nuevas
--   Puntos totales disponibles: 860
-- =============================================================================