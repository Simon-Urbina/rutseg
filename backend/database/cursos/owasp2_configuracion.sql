-- =============================================================================
-- seed_owasp_a02_configuracion.sql
-- Curso OWASP Top 10 2025 — A02: Configuración de Seguridad
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 2 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A02 — Configuración de Seguridad (principiante)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a02-configuracion',
  'OWASP A02: Configuración de Seguridad',
  'Domina la vulnerabilidad #1 del OWASP Top 10 2025 (subió desde el puesto #5). Aprende a identificar cuentas por defecto, archivos y paneles expuestos, cabeceras de seguridad HTTP faltantes y servicios en la nube mal configurados — el fallo más común y más fácil de prevenir de toda la lista.',
  'principiante',
  TRUE,
  id
FROM users WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title        = EXCLUDED.title,
  description  = EXCLUDED.description,
  difficulty   = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- =============================================================================
-- MÓDULO 1: Fundamentos de la Configuración Segura
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'fundamentos-configuracion-segura',
  'Fundamentos de la Configuración Segura',
  'Qué es una mala configuración de seguridad, por qué es hoy el fallo más común del OWASP Top 10 2025, y cómo reconocer cuentas por defecto, paneles expuestos y archivos olvidados en un servidor.',
  1
FROM courses c WHERE c.slug = 'owasp-a02-configuracion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Qué es una Configuración de Seguridad Insegura ────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-es-configuracion-insegura',
  'Qué es una Configuración de Seguridad Insegura',
  E'## La vulnerabilidad #1 del OWASP Top 10 2025\n\nLa **Configuración de Seguridad** (Security Misconfiguration) subió del puesto #5 al puesto **#1** en la edición 2025. No es casualidad: el 100% de las aplicaciones analizadas en el estudio de OWASP presentaban algún tipo de mala configuración.\n\nA diferencia de una inyección SQL o un XSS, este fallo casi nunca está en el código fuente. Vive en cómo se **instala, despliega y mantiene** el sistema: el servidor, el framework, la base de datos, el proveedor de nube y cada pieza intermedia.\n\n## Los síntomas más comunes\n\n| Síntoma | Ejemplo |\n|---|---|\n| Funciones innecesarias habilitadas | Puertos, servicios, cuentas de prueba o frameworks de testing activos en producción |\n| Cuentas por defecto sin cambiar | Panel de administración con usuario admin y contraseña admin |\n| Mensajes de error demasiado informativos | Un stack trace completo mostrado al usuario final |\n| Funciones de seguridad deshabilitadas | Un sistema actualizado que sigue con las protecciones antiguas desactivadas |\n| Configuración por defecto de servicios en la nube | Un bucket de almacenamiento con permisos abiertos a Internet |\n| Cabeceras de seguridad ausentes | El servidor no envía directivas como Content-Security-Policy |\n\n## No es un bug de código, es un problema de proceso\n\nUna inyección SQL se corrige cambiando una línea de código. Una mala configuración se corrige con un **proceso repetible**: si hoy alguien instala el servidor a mano y olvida un paso, la próxima persona que lo haga probablemente cometerá el mismo error.\n\nPor eso la recomendación central de OWASP no es "revisa la configuración una vez", sino automatizar el endurecimiento (hardening) para que sea imposible desplegar un entorno sin él.\n\n## Regla rápida para reconocerlo\n\nPregúntate: ¿esta falla existiría igual si el código fuente fuera perfecto? Si la respuesta es sí (porque el problema está en cómo se instaló o configuró algo), estás ante una Configuración de Seguridad insegura.\n\n---\nCompleta el quiz para ganar **90 puntos**.',
  1, 15, 90, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-configuracion-segura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  'En el OWASP Top 10 2025, ¿en qué posición quedó la Configuración de Seguridad?',
  'Quedó en el puesto #1, subiendo desde el puesto #5 de la edición anterior. El 100% de las aplicaciones analizadas presentaban algún tipo de mala configuración.'
FROM laboratories l WHERE l.slug = 'que-es-configuracion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'A diferencia de una inyección SQL, ¿dónde suele vivir el problema en una mala configuración?',
  'La inyección SQL es casi siempre un error en el código fuente. La mala configuración, en cambio, suele estar en cómo se instaló, desplegó o mantuvo el sistema (servidor, framework, nube), no en el código en sí.'
FROM laboratories l WHERE l.slug = 'que-es-configuracion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'De las siguientes, ¿cuál NO es un ejemplo de mala configuración de seguridad?',
  'Almacenar contraseñas con un algoritmo de hash fuerte como bcrypt es una buena práctica de seguridad, no una falla de configuración. Las otras tres opciones sí son ejemplos clásicos de configuración insegura según OWASP 2025.'
FROM laboratories l WHERE l.slug = 'que-es-configuracion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  'Un servidor muestra el stack trace completo cuando ocurre un error interno. ¿Qué tipo de fallo es este?',
  'Es un caso clásico de configuración insegura: la aplicación revela información interna (rutas de archivos, versiones de librerías, estructura del código) que un atacante puede usar para planear un ataque más preciso.'
FROM laboratories l WHERE l.slug = 'que-es-configuracion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué OWASP recomienda automatizar el proceso de endurecimiento (hardening) en vez de hacerlo manualmente cada vez?',
  'Un proceso manual depende de que una persona recuerde todos los pasos cada vez. Automatizarlo garantiza que desarrollo, QA y producción queden configurados de forma idéntica y segura, sin depender de la memoria de nadie.'
FROM laboratories l WHERE l.slug = 'que-es-configuracion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '#1 — subió desde el puesto #5', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '#5 — se mantuvo igual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '#8 — bajó de posición', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '#10 — es la última de la lista', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'En cómo se instala, despliega o mantiene el sistema', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Siempre en una línea específica del código fuente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Únicamente en la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo en el navegador del cliente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Guardar las contraseñas con bcrypt y una sal aleatoria', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Dejar activa una aplicación de ejemplo del servidor en producción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'No cambiar la contraseña por defecto del panel de administración', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Dejar el listado de directorios habilitado en el servidor web', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Configuración insegura: revela información interna aprovechable por un atacante', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Inyección SQL, porque el error viene de la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Fallo criptográfico, porque el error está cifrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No es una falla de seguridad, solo un detalle visual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque garantiza que todos los entornos queden configurados igual de forma segura', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque automatizar siempre es más barato que pagar personal', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque elimina por completo la necesidad de pruebas de seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque así ya no hace falta revisar la configuración nunca más', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-configuracion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Cuentas por Defecto, Paneles y Backups Expuestos ───────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'cuentas-por-defecto-y-exposicion',
  'Cuentas por Defecto, Paneles y Backups Expuestos',
  E'## Cuentas y paneles que nadie cambió\n\nMuchos productos vienen con una cuenta de administración lista para usar el primer día, pensada para configurarse y luego cambiarse. El problema aparece cuando nadie la cambia.\n\n| Producto (ejemplo genérico) | Cuenta típica por defecto |\n|---|---|\n| Router doméstico | admin / admin |\n| Panel de administración de base de datos | root / (vacío) |\n| Servidor de aplicaciones | manager / manager |\n\nUn atacante no necesita adivinar nada: estas combinaciones están documentadas públicamente por el propio fabricante.\n\n## Archivos que se quedan atrás\n\nDurante el desarrollo se generan archivos que nunca deberían llegar a producción:\n\n```\n.git/config              → historial completo del repositorio, a veces con credenciales antiguas\n.env                     → variables de entorno, incluyendo secretos\nbackup.zip, db_dump.sql  → copias de seguridad olvidadas en una carpeta pública\nconfig.php.bak           → el ".bak" hace que el servidor lo sirva como texto plano en vez de ejecutarlo\n```\n\nSi el listado de directorios está habilitado, cualquiera puede simplemente navegar la carpeta y encontrarlos.\n\n## Detectando exposición de forma defensiva\n\nUna forma simple y segura de auditar tu propio servidor es revisar qué headers HTTP expone, ya que ahí suele filtrarse el software y la versión que corres:\n\n```bash\ncurl -sI https://httpbin.org/get\n```\n\nEsto imprime solo las cabeceras de la respuesta (`-I`) en modo silencioso (`-s`), sin descargar el cuerpo. Presta atención al header `Server`: si expone el nombre y la versión exacta del software, un atacante ya sabe qué vulnerabilidades conocidas buscar para esa versión específica.\n\n## Prevención\n\n- Cambiar toda credencial por defecto antes de exponer un servicio.\n- Nunca subir `.env`, `.git` ni copias de seguridad al mismo directorio público que sirve la aplicación.\n- Deshabilitar el listado de directorios en el servidor web.\n\n---\nCompleta el quiz y la actividad para ganar **150 puntos**.',
  2, 20, 150, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-configuracion-segura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué las credenciales por defecto son tan peligrosas?',
  'Porque están documentadas públicamente por el propio fabricante del producto. Un atacante no necesita adivinarlas ni forzarlas: solo prueba las combinaciones conocidas de ese modelo o software.'
FROM laboratories l WHERE l.slug = 'cuentas-por-defecto-y-exposicion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué riesgo tiene subir la carpeta ".git" al mismo directorio público que sirve la aplicación?',
  'La carpeta ".git" contiene el historial completo del repositorio, incluyendo commits antiguos que a veces guardan credenciales o secretos que ya se "eliminaron" del código actual pero siguen visibles en el historial.'
FROM laboratories l WHERE l.slug = 'cuentas-por-defecto-y-exposicion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'Un archivo llamado "config.php.bak" queda en el servidor. ¿Por qué es peligroso, más allá de estar "olvidado"?',
  'El servidor no reconoce la extensión ".bak" como código PHP ejecutable, así que en vez de ejecutar el archivo lo sirve como texto plano — exponiendo credenciales de base de datos y configuración interna en texto legible.'
FROM laboratories l WHERE l.slug = 'cuentas-por-defecto-y-exposicion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué revela típicamente el header HTTP "Server" en una respuesta?',
  'El header Server suele indicar el software del servidor web y, en configuraciones descuidadas, hasta la versión exacta — información que un atacante usa para buscar vulnerabilidades conocidas de esa versión específica.'
FROM laboratories l WHERE l.slug = 'cuentas-por-defecto-y-exposicion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa curl para revisar solo las cabeceras HTTP (sin el cuerpo) de una petición GET a httpbin.org. Copia el comando que usarías.',
  'La bandera -I pide solo las cabeceras y -s activa el modo silencioso. Es la forma más rápida de auditar qué información expone un servidor antes de mirar cualquier otra cosa.'
FROM laboratories l WHERE l.slug = 'cuentas-por-defecto-y-exposicion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque están documentadas públicamente por el fabricante del producto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque siempre usan cifrado débil', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque solo existen en routers domésticos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque requieren un ataque de fuerza bruta muy largo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Puede exponer credenciales o secretos que quedaron en commits antiguos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ninguno, Git siempre cifra su historial', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo ralentiza la carga de la página', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Ocupa espacio en disco, nada más', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El servidor lo sirve como texto plano en vez de ejecutarlo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El servidor lo ejecuta dos veces por error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El navegador lo bloquea automáticamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Provoca un error 500 y nada más', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El software del servidor web y, a veces, su versión exacta', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'La contraseña del administrador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El contenido completo de la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La ubicación física del servidor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Auditando cabeceras HTTP con curl',
  E'## Objetivo\n\nRevisa qué información expone un servidor en sus cabeceras HTTP, sin descargar el contenido de la página.\n\n## Instrucciones\n\n```bash\ncurl -sI https://httpbin.org/get\n```\n\n**Desglose:**\n- `-s`: modo silencioso, sin barra de progreso\n- `-I`: pide solo las cabeceras (HEAD), no el cuerpo de la respuesta\n\n**Qué buscar en la salida:**\n\n```\nHTTP/2 200\nserver: gunicorn/19.9.0\ndate: ...\ncontent-type: application/json\n```\n\nEl header `server` revela el software exacto que corre httpbin.org. En una auditoría real, esta es información que un atacante recolecta en la fase de reconocimiento, antes de buscar vulnerabilidades conocidas para esa versión puntual.\n\n**Para practicar en tu propio proyecto:**\n\n```bash\ncurl -sI https://tu-dominio.com | grep -i server\n```\n\nCopia el **comando exacto** que usarías para pedir solo las cabeceras de httpbin.org y úsalo en el quiz.',
  'curl -sI https://httpbin.org/get',
  '¡Correcto! Ya sabes revisar qué expone un servidor antes de mirar cualquier otra cosa. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cuentas-por-defecto-y-exposicion' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Cabeceras, la Nube y el Endurecimiento del Sistema
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'cabeceras-nube-endurecimiento',
  'Cabeceras HTTP, la Nube y el Endurecimiento del Sistema',
  'Cabeceras de seguridad HTTP que toda aplicación debería enviar, errores comunes en servicios de almacenamiento en la nube, y cómo construir un proceso de endurecimiento que no dependa de la memoria de una persona.',
  2
FROM courses c WHERE c.slug = 'owasp-a02-configuracion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Cabeceras de Seguridad HTTP ────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'cabeceras-de-seguridad-http',
  'Cabeceras de Seguridad HTTP',
  E'## Directivas que el navegador necesita para protegerte\n\nUn servidor puede decirle al navegador, mediante cabeceras HTTP, cómo comportarse de forma más segura frente a esa página. Si esas cabeceras faltan, el navegador simplemente usa su comportamiento por defecto, que suele ser menos estricto.\n\n| Cabecera | Qué previene |\n|---|---|\n| `Strict-Transport-Security` (HSTS) | Que el navegador vuelva a intentar la conexión sin cifrar (HTTP) alguna vez |\n| `X-Content-Type-Options: nosniff` | Que el navegador adivine el tipo de un archivo y lo ejecute como algo que no es |\n| `X-Frame-Options` / `frame-ancestors` | Que tu sitio se cargue dentro de un iframe ajeno (clickjacking) |\n| `Content-Security-Policy` (CSP) | Que se ejecuten scripts desde orígenes no autorizados |\n| `Referrer-Policy` | Que la URL completa de tu sitio viaje como referer hacia sitios externos |\n\nNinguna de estas cabeceras reemplaza una buena validación en el backend — son una capa adicional, no la única defensa.\n\n## Revisando las cabeceras de un sitio real\n\n```bash\ncurl -sI https://owasp.org\n```\n\nCon este comando puedes inspeccionar qué cabeceras de seguridad envía cualquier sitio público, incluido el propio OWASP. Es exactamente la misma técnica del laboratorio anterior, aplicada esta vez a la búsqueda de directivas de seguridad en lugar del header Server.\n\n## Por qué esto es "configuración" y no "código"\n\nEstas cabeceras casi nunca se configuran línea por línea en cada endpoint. Se definen **una vez**, a nivel del servidor web o del framework, y aplican a toda la aplicación. Olvidarlas no es un bug de lógica de negocio: es un paso de configuración que faltó.\n\n---\nCompleta el quiz y la actividad para ganar **180 puntos**.',
  1, 20, 180, TRUE
FROM course_modules cm WHERE cm.slug = 'cabeceras-nube-endurecimiento'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué previene la cabecera "Strict-Transport-Security" (HSTS)?',
  'HSTS le indica al navegador que jamás intente cargar el sitio por HTTP sin cifrar, ni siquiera si el usuario escribe la URL sin "https://". Esto cierra la puerta a ataques de downgrade de HTTPS a HTTP.'
FROM laboratories l WHERE l.slug = 'cabeceras-de-seguridad-http'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué tipo de ataque previene principalmente "X-Frame-Options"?',
  'Previene el clickjacking: que un sitio malicioso cargue tu página dentro de un iframe invisible y engañe al usuario para que haga clic en algo que en realidad pertenece a tu sitio.'
FROM laboratories l WHERE l.slug = 'cabeceras-de-seguridad-http'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Es correcto decir que las cabeceras de seguridad HTTP reemplazan la validación del backend?',
  'No. Son una capa adicional de defensa en el navegador, no un sustituto de la validación y autorización que siempre debe ocurrir en el servidor.'
FROM laboratories l WHERE l.slug = 'cabeceras-de-seguridad-http'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué la ausencia de cabeceras de seguridad se clasifica como "configuración" y no como un bug de lógica?',
  'Porque estas cabeceras se definen una sola vez a nivel del servidor o framework, aplicando a toda la aplicación. Olvidarlas es un paso de configuración faltante, no un error en la lógica de negocio de una función específica.'
FROM laboratories l WHERE l.slug = 'cabeceras-de-seguridad-http'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa curl para revisar solo las cabeceras HTTP del sitio de OWASP. Copia el comando que usarías.',
  'El mismo patrón -sI aplicado a cualquier dominio te permite auditar qué cabeceras de seguridad envía, incluidas las organizaciones que enseñan buenas prácticas.'
FROM laboratories l WHERE l.slug = 'cabeceras-de-seguridad-http'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que el navegador cargue el sitio por HTTP sin cifrar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que se ejecuten scripts de otros dominios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el sitio se cargue dentro de un iframe ajeno', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que un archivo se ejecute como un tipo distinto al declarado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Clickjacking, mediante iframes ocultos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Inyección SQL', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Fuerza bruta sobre contraseñas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Deserialización insegura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No, son una capa adicional, no un sustituto de la validación en backend', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Sí, si están todas presentes ya no hace falta validar nada más', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Sí, pero solo para aplicaciones pequeñas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Sí, siempre que se usen todas a la vez', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque se definen una vez a nivel de servidor y aplican a toda la app', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque siempre las agrega automáticamente el navegador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque solo importan en aplicaciones móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque son parte del código de cada función de negocio', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Auditando cabeceras de seguridad con curl',
  E'## Objetivo\n\nRevisa qué cabeceras de seguridad envía un sitio real usando la misma técnica del laboratorio anterior.\n\n## Instrucciones\n\n```bash\ncurl -sI https://owasp.org\n```\n\n**Qué buscar en la salida:**\n\nBusca líneas como:\n\n```\nstrict-transport-security: max-age=31536000\nx-content-type-options: nosniff\ncontent-security-policy: default-src ''self''\n```\n\nSi alguna de estas cabeceras no aparece en la respuesta, ese sitio no está enviando esa directiva de seguridad al navegador — es exactamente el tipo de hallazgo que documentarías en una auditoría real.\n\nCopia el **comando exacto** que usarías para revisar las cabeceras de owasp.org y úsalo en el quiz.',
  'curl -sI https://owasp.org',
  '¡Bien hecho! Ya puedes auditar las cabeceras de seguridad de cualquier sitio público. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cabeceras-de-seguridad-http' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Buckets en la Nube y Endurecimiento del Sistema ────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'nube-y-endurecimiento-del-sistema',
  'Buckets en la Nube y Endurecimiento del Sistema',
  E'## El mismo error, en la nube\n\nLos proveedores de nube (AWS, Google Cloud, Azure) suelen tener permisos de "compartir" bastante abiertos por defecto en sus servicios de almacenamiento. Si nadie revisa esa configuración, un bucket pensado para uso interno puede terminar siendo accesible desde cualquier parte de Internet.\n\nEste ha sido, en la práctica, uno de los orígenes de filtración de datos más comunes de la última década: no fue una inyección SQL ni un exploit sofisticado, fue un permiso que nadie cerró.\n\n## El principio de paridad de entornos\n\nUna causa raíz frecuente de mala configuración es que **desarrollo, pruebas (QA) y producción no están configurados igual**. Un desarrollador prueba algo en su entorno local con todas las protecciones desactivadas "para ir más rápido", y esa misma configuración relajada termina copiándose a producción sin que nadie lo note.\n\nLa recomendación de OWASP es simple: los tres entornos deben partir de la **misma base endurecida**, con credenciales distintas en cada uno pero la misma postura de seguridad.\n\n## Infraestructura como código (IaC)\n\nCuando la configuración de servidores y permisos se define en archivos versionados en Git (Terraform, CloudFormation, Pulumi) en lugar de clics manuales en una consola web, cualquier cambio queda documentado, revisado en un pull request, y es reproducible. Es la versión "de infraestructura" de la misma disciplina que ya aplicas al código.\n\n## Segmentación\n\nSeparar componentes por redes, contenedores o grupos de seguridad limita el daño si algo falla: si un servicio se compromete, la segmentación evita que el atacante salte automáticamente a todo lo demás.\n\n## Checklist mínimo de endurecimiento\n\n- Revisar los permisos de cualquier servicio de almacenamiento en la nube al crearlo, no después de un incidente.\n- Automatizar la verificación de configuraciones en cada entorno, no solo revisarlas una vez al año.\n- Retirar cualquier función, cuenta o dependencia que no se esté usando activamente.\n\n---\nCompleta el quiz para ganar **200 puntos**.',
  2, 25, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'cabeceras-nube-endurecimiento'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué ha causado, en la práctica, varias filtraciones de datos reales en servicios de almacenamiento en la nube?',
  'Permisos de "compartir" abiertos a Internet dejados por descuido en buckets pensados para uso interno — no un exploit sofisticado, sino una configuración que nadie revisó ni cerró.'
FROM laboratories l WHERE l.slug = 'nube-y-endurecimiento-del-sistema'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'Según el principio de paridad de entornos, ¿cómo deberían configurarse desarrollo, QA y producción?',
  'Con la misma base endurecida y la misma postura de seguridad, aunque usen credenciales distintas cada uno. Así una configuración relajada de desarrollo nunca termina copiándose a producción por descuido.'
FROM laboratories l WHERE l.slug = 'nube-y-endurecimiento-del-sistema'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué ventaja principal ofrece definir la infraestructura como código (IaC) frente a configurar todo manualmente en una consola web?',
  'Cada cambio queda versionado, documentado y revisable en un pull request, igual que el código de la aplicación — en vez de depender de que alguien recuerde qué clic hizo y cuándo.'
FROM laboratories l WHERE l.slug = 'nube-y-endurecimiento-del-sistema'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué logra la segmentación de una arquitectura en redes, contenedores o grupos de seguridad separados?',
  'Limita el daño si un componente se compromete: la segmentación evita que un atacante salte automáticamente desde un servicio comprometido hacia todo el resto de la infraestructura.'
FROM laboratories l WHERE l.slug = 'nube-y-endurecimiento-del-sistema'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  'Según el checklist del laboratorio, ¿cuándo se deben revisar los permisos de un servicio de almacenamiento en la nube?',
  'Al crearlo, no después de un incidente. Revisar la configuración de forma reactiva, solo cuando ya ocurrió una filtración, significa que la exposición ya estuvo activa todo ese tiempo.'
FROM laboratories l WHERE l.slug = 'nube-y-endurecimiento-del-sistema'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Permisos de "compartir" abiertos a Internet dejados por descuido', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un exploit de día cero muy sofisticado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un ataque de fuerza bruta sobre la consola del proveedor de nube', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Una vulnerabilidad exclusiva de un lenguaje de programación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Con la misma base endurecida y postura de seguridad en los tres', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Desarrollo puede estar totalmente abierto porque nadie lo ve', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo producción necesita configuración segura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'QA debe tener más restricciones que producción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cada cambio queda versionado, documentado y revisable', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Es siempre más rápido que usar la consola web', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de tener credenciales', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo sirve para proyectos muy grandes', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Limita el daño si un componente se compromete', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Elimina por completo la posibilidad de un ataque', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Hace que el sistema sea más rápido', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Sustituye la necesidad de cifrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Al crearlo, no después de un incidente', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Una vez al año, durante la auditoría anual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo si el proveedor de nube lo notifica', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Nunca, los valores por defecto del proveedor ya son seguros', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'nube-y-endurecimiento-del-sistema' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A02 — principiante)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (90, 150, 180, 200 puntos)
--   Preguntas:    20 nuevas (18 opción múltiple + 2 actividad)
--   Actividades:  2 nuevas
--   Puntos totales disponibles: 620
-- =============================================================================