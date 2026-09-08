-- =============================================================================
-- seed_owasp_a09_logging.sql
-- Curso OWASP Top 10 2025 — A09: Fallos de Registro y Alertas de Seguridad
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 2 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A09 — Fallos de Registro y Alertas de Seguridad (principiante)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a09-logging-alertas',
  'OWASP A09: Fallos de Registro y Alertas de Seguridad',
  'Sin registro no hay forma de detectar un ataque, y sin alertas no hay forma de responder a tiempo. Aprende qué se debe registrar (y qué nunca), cómo detectar un ataque simplemente leyendo logs, y por qué un log mal protegido puede ser manipulado por el propio atacante.',
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
-- MÓDULO 1: Por Qué Importa el Registro de Eventos
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'por-que-importa-el-logging',
  'Por Qué Importa el Registro de Eventos',
  'Qué eventos vale la pena registrar, qué información nunca debería aparecer en un log, y cómo un simple archivo de texto con los eventos correctos puede ser la diferencia entre detectar un ataque en minutos o nunca enterarse.',
  1
FROM courses c WHERE c.slug = 'owasp-a09-logging-alertas'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Qué se Debe Registrar (y Qué No) ───────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-se-debe-registrar',
  'Qué se Debe Registrar (y Qué No)',
  E'## El fallo silencioso\n\nA diferencia de una inyección SQL, un fallo de registro y alertas no se nota el día que ocurre. Se nota **meses o años después**, cuando alguien pregunta "¿desde cuándo estaba pasando esto?" y nadie tiene una respuesta, porque nadie lo registró.\n\nOWASP es explícito sobre esto: esta categoría es difícil de medir con datos de vulnerabilidades conocidas, precisamente porque su ausencia no deja el mismo rastro técnico que otros fallos. Aun así, la comunidad de seguridad la vota consistentemente como una de las diez más importantes.\n\n## Qué SÍ se debe registrar\n\n| Evento | Por qué importa |\n|---|---|\n| Inicios de sesión (exitosos y fallidos) | Un patrón de fallos repetidos indica un posible ataque de fuerza bruta |\n| Cambios de permisos o de rol | Permite detectar una escalada de privilegios no autorizada |\n| Transacciones de alto valor | Da un rastro de auditoría para disputas o fraude |\n| Fallos de validación en el servidor | Puede indicar que alguien está probando los límites de la aplicación |\n| Accesos denegados por control de acceso (403) | Un patrón de muchos 403 seguidos sugiere reconocimiento activo |\n\n## Qué NUNCA se debe registrar\n\n| Nunca en el log | Por qué |\n|---|---|\n| Contraseñas, aunque estén "solo de paso" | Un log comprometido no debería convertirse en una filtración de credenciales |\n| Números completos de tarjetas de crédito | Viola estándares como PCI DSS |\n| Tokens de sesión completos | Un atacante con acceso a logs podría secuestrar sesiones activas |\n| Datos personales sensibles sin necesidad | Multiplica el daño de cualquier filtración del propio log |\n\n## Registrar tanto éxitos como fallos\n\nUn error común es registrar solo los intentos de login **fallidos**. Sin registrar también los exitosos, es imposible responder preguntas como "¿esta cuenta inició sesión alguna vez desde ese país?" — el registro incompleto deja huecos justo donde más se necesitan.\n\n## La regla de oro\n\nPregúntate, por cada evento sensible de tu aplicación: si esto sale mal dentro de seis meses, ¿tendré suficiente información registrada hoy para reconstruir qué pasó?\n\n---\nCompleta el quiz para ganar **90 puntos**.',
  1, 15, 90, TRUE
FROM course_modules cm WHERE cm.slug = 'por-que-importa-el-logging'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué un fallo de registro y alertas es más difícil de notar que una inyección SQL?',
  'Porque no se nota el día que ocurre: se nota meses o años después, cuando alguien pregunta desde cuándo estaba pasando algo y nadie tiene una respuesta porque nunca se registró.'
FROM laboratories l WHERE l.slug = 'que-se-debe-registrar'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué es importante registrar tanto los inicios de sesión exitosos como los fallidos?',
  'Porque registrar solo los fallidos deja huecos: sin los exitosos, es imposible responder preguntas como si una cuenta inició sesión alguna vez desde un lugar inusual.'
FROM laboratories l WHERE l.slug = 'que-se-debe-registrar'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué nunca se debe registrar una contraseña en un log, ni siquiera "de paso"?',
  'Porque un log comprometido no debería convertirse en una filtración de credenciales. Si la contraseña nunca se registró, no hay nada que robar de ese log en particular.'
FROM laboratories l WHERE l.slug = 'que-se-debe-registrar'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué podría indicar un patrón de muchos accesos denegados (403) seguidos, dirigidos a distintos endpoints?',
  'Reconocimiento activo: alguien probando sistemáticamente qué rutas existen y a cuáles no tiene permiso, un comportamiento típico de la fase previa a un ataque dirigido.'
FROM laboratories l WHERE l.slug = 'que-se-debe-registrar'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  'Según la "regla de oro" del laboratorio, ¿qué pregunta deberías hacerte por cada evento sensible de tu aplicación?',
  'Si esto sale mal dentro de seis meses, ¿tendré suficiente información registrada hoy para reconstruir qué pasó? Es una forma práctica de decidir qué vale la pena registrar desde ahora.'
FROM laboratories l WHERE l.slug = 'que-se-debe-registrar'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Se nota meses o años después, no el mismo día', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque siempre ocurre fuera del horario laboral', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque no existen herramientas para detectarlo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque solo afecta a aplicaciones móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Sin los exitosos, quedan huecos que impiden reconstruir el historial completo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque los inicios exitosos ocupan más espacio en el log', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque los fallidos nunca son relevantes', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque la ley lo exige en todos los países', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un log comprometido no debería filtrar credenciales que nunca se registraron', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque los logs no pueden almacenar texto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque ralentiza el sistema de logging', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque las contraseñas ya están cifradas siempre', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Reconocimiento activo, probando qué rutas existen', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un problema de conexión a Internet del usuario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un error de configuración del navegador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un servidor que necesita mantenimiento', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Si esto sale mal en seis meses, ¿podré reconstruir qué pasó?', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '¿Cuánto espacio en disco tengo disponible?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '¿Cuántos usuarios tiene la aplicación hoy?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '¿Qué color debería tener el mensaje de error?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-se-debe-registrar' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Detectando Ataques Leyendo Logs ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'detectando-ataques-leyendo-logs',
  'Detectando Ataques Leyendo Logs',
  E'## Un archivo de texto puede contar una historia\n\nLos logs de autenticación de un servidor suelen verse así, una línea por evento:\n\n```\n2026-09-01 03:14:02 LOGIN_FAILED user=admin ip=203.0.113.7\n2026-09-01 03:14:05 LOGIN_FAILED user=admin ip=203.0.113.7\n2026-09-01 03:14:08 LOGIN_FAILED user=admin ip=203.0.113.7\n2026-09-01 03:14:11 LOGIN_FAILED user=admin ip=203.0.113.7\n2026-09-01 03:14:14 LOGIN_SUCCESS user=admin ip=203.0.113.7\n```\n\nSin herramientas sofisticadas, cualquiera que lea estas cinco líneas puede reconstruir la historia: alguien intentó adivinar la contraseña del usuario "admin" cuatro veces seguidas, con solo tres segundos entre cada intento (demasiado rápido para ser una persona escribiendo a mano), y en el quinto intento tuvo éxito.\n\n## Contar en vez de leer una por una\n\nCuando el archivo tiene miles de líneas, contar patrones es más rápido que leerlas todas:\n\n```bash\ngrep "LOGIN_FAILED" auth.log | wc -l\n```\n\nEste comando busca todas las líneas que contienen "LOGIN_FAILED" (`grep`) y cuenta cuántas son (`wc -l`). Un número inusualmente alto en un período corto de tiempo es la señal más básica de un posible ataque de fuerza bruta.\n\n## Ir un paso más allá: agrupar por IP\n\n```bash\ngrep "LOGIN_FAILED" auth.log | awk -F"ip=" "{print \\$2}" | sort | uniq -c | sort -rn\n```\n\nEste comando extrae la IP de cada línea fallida, cuenta cuántas veces aparece cada una, y ordena de mayor a menor. Si una sola IP concentra la mayoría de los fallos, es mucho más probable que sea un ataque automatizado que actividad normal de usuarios distintos.\n\n## Por qué esto es un buen punto de entrada a la seguridad\n\nNo hace falta un sistema de detección de intrusos sofisticado para empezar: la mayoría de los patrones de ataque más comunes son visibles a simple vista en los logs correctos, si alguien se toma el tiempo de mirarlos.\n\n---\nCompleta el quiz y la actividad para ganar **150 puntos**.',
  2, 20, 150, TRUE
FROM course_modules cm WHERE cm.slug = 'por-que-importa-el-logging'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  'En el ejemplo de log del laboratorio, ¿qué historia cuentan las cinco líneas mostradas?',
  'Alguien intentó adivinar la contraseña del usuario admin cuatro veces seguidas en pocos segundos, y en el quinto intento tuvo éxito — un patrón típico de fuerza bruta seguida de un acceso logrado.'
FROM laboratories l WHERE l.slug = 'detectando-ataques-leyendo-logs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué logra el comando "grep \"LOGIN_FAILED\" auth.log | wc -l"?',
  'Cuenta cuántas líneas del archivo contienen "LOGIN_FAILED", dando un número rápido de intentos fallidos sin necesidad de leer el archivo línea por línea.'
FROM laboratories l WHERE l.slug = 'detectando-ataques-leyendo-logs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué agrupar los fallos de login por dirección IP ayuda a detectar un ataque automatizado?',
  'Porque si una sola IP concentra la mayoría de los fallos, es mucho más probable que sea un script automatizado que actividad dispersa de usuarios legítimos distintos.'
FROM laboratories l WHERE l.slug = 'detectando-ataques-leyendo-logs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué mensaje central transmite este laboratorio sobre detección de ataques?',
  'Que muchos patrones de ataque comunes son visibles a simple vista en los logs correctos, sin necesitar herramientas sofisticadas de detección de intrusos para empezar.'
FROM laboratories l WHERE l.slug = 'detectando-ataques-leyendo-logs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Cuenta cuántas líneas de un archivo llamado auth.log contienen el texto "LOGIN_FAILED". Copia el comando que usarías.',
  'grep busca las líneas que contienen el patrón, y wc -l cuenta cuántas líneas resultaron de esa búsqueda — la forma más simple de cuantificar un patrón en un log.'
FROM laboratories l WHERE l.slug = 'detectando-ataques-leyendo-logs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un ataque de fuerza bruta que finalmente logró acceder', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un usuario que olvidó su contraseña de forma normal', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un fallo del servidor de correo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un problema de sincronización de reloj entre servidores', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cuenta cuántas líneas contienen "LOGIN_FAILED"', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Elimina las líneas que contienen "LOGIN_FAILED"', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Bloquea automáticamente las IPs que fallan', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Envía un correo de alerta automáticamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Una IP concentrando todos los fallos sugiere un script, no personas distintas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque cada IP corresponde siempre a un país distinto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque las IPs nunca se repiten en un log real', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque agrupar por IP cifra automáticamente los datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Muchos ataques comunes son visibles a simple vista en los logs correctos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo un sistema de IA puede detectar ataques hoy en día', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Los logs nunca contienen información útil', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Analizar logs siempre requiere un equipo dedicado grande', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Contando eventos en un log con grep',
  E'## Objetivo\n\nAprende el patrón más básico para cuantificar un evento dentro de un archivo de log.\n\n## Instrucciones\n\n```bash\ngrep "LOGIN_FAILED" auth.log | wc -l\n```\n\n**Desglose:**\n- `grep "LOGIN_FAILED" auth.log`: busca todas las líneas del archivo auth.log que contienen el texto "LOGIN_FAILED"\n- `|`: envía esa salida como entrada al siguiente comando\n- `wc -l`: cuenta cuántas líneas recibió\n\n**Ejemplo de salida:**\n\n```\n47\n```\n\nEste número por sí solo no dice si hay un ataque — depende del contexto (¿47 fallos en un mes es normal? ¿47 fallos en dos minutos, con el mismo usuario, no lo es). Pero es el primer paso: convertir un archivo de texto en un número que se pueda evaluar.\n\nCopia el **comando exacto** que usarías para contar las líneas con "LOGIN_FAILED" en auth.log y úsalo en el quiz.',
  'grep "LOGIN_FAILED" auth.log | wc -l',
  '¡Correcto! Ya sabes el patrón más básico para cuantificar eventos en un log. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'detectando-ataques-leyendo-logs' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Alertas, Integridad de Logs e Inyección en Logs
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'alertas-integridad-e-inyeccion-en-logs',
  'Alertas, Integridad de Logs e Inyección en Logs',
  'Cómo un atacante puede manipular el propio contenido de un log, por qué los logs necesitan protección contra tampering, y qué hace que una alerta sea realmente útil en vez de ruido que nadie revisa.',
  2
FROM courses c WHERE c.slug = 'owasp-a09-logging-alertas'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Inyección en Logs y Manipulación ────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'inyeccion-en-logs-y-manipulacion',
  'Inyección en Logs y Manipulación',
  E'## Cuando el atacante escribe en tu log\n\nSi tu aplicación registra directamente lo que un usuario escribió, sin codificar caracteres especiales, un atacante puede insertar saltos de línea dentro de su entrada para **fabricar líneas de log falsas**, como si fueran eventos reales generados por el sistema.\n\n```\n// Lo que la aplicación registra normalmente:\nLOGIN_ATTEMPT user=juan123\n\n// Lo que un atacante podría lograr si el usuario no se sanitiza:\nLOGIN_ATTEMPT user=juan123\nLOGIN_SUCCESS user=admin ip=127.0.0.1  ← línea falsa, fabricada por el atacante\n```\n\nSi alguien revisa el log más tarde buscando accesos de "admin", esa línea fabricada se ve idéntica a un evento real del sistema. Este tipo de fallo tiene su propio identificador técnico: **CWE-117, neutralización inadecuada de salida para logs**.\n\n## Probando el concepto de forma segura\n\n```bash\ncurl -X POST https://httpbin.org/post -d "usuario=admin%0ALOGIN_SUCCESS-admin-desde-IP-falsa"\n```\n\n`%0A` es la representación URL-encoded de un salto de línea. Este comando envía ese salto de línea dentro de un campo normal a un endpoint de prueba seguro (httpbin.org solo refleja lo recibido, no tiene ningún sistema de logging real detrás). En una aplicación vulnerable que registrara este campo sin codificarlo, ese salto de línea fabricaría una línea de log adicional.\n\n## La defensa: codificar antes de registrar\n\nLa solución es simple en concepto: cualquier dato proporcionado por el usuario debe pasar por una función de codificación de salida antes de escribirse en el log, de modo que un salto de línea dentro del dato se represente como texto literal (`\\n`), no como un salto de línea real que rompe el formato del archivo.\n\n## Integridad del log en sí mismo\n\nMás allá de la inyección, un log al que cualquiera con acceso al servidor pueda editar libremente tampoco es confiable: un atacante que comprometió el sistema podría simplemente borrar las líneas que lo delatan. Por eso se recomiendan mecanismos de solo-anexado (append-only) o el envío inmediato de logs a un sistema centralizado fuera del alcance del atacante.\n\n---\nCompleta el quiz y la actividad para ganar **180 puntos**.',
  1, 20, 180, TRUE
FROM course_modules cm WHERE cm.slug = 'alertas-integridad-e-inyeccion-en-logs'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué logra un atacante al insertar un salto de línea dentro de un campo que se registra sin codificar?',
  'Puede fabricar líneas de log falsas que se ven idénticas a eventos reales generados por el sistema, engañando a quien revise el log después.'
FROM laboratories l WHERE l.slug = 'inyeccion-en-logs-y-manipulacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué identificador técnico corresponde a la neutralización inadecuada de salida para logs?',
  'CWE-117, el identificador estándar para este tipo específico de fallo de manipulación de logs.'
FROM laboratories l WHERE l.slug = 'inyeccion-en-logs-y-manipulacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué representa "%0A" en una URL o en datos enviados por HTTP?',
  'Es la representación URL-encoded de un salto de línea, usada para probar de forma controlada si un sistema es vulnerable a inyección de logs.'
FROM laboratories l WHERE l.slug = 'inyeccion-en-logs-y-manipulacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué un log editable libremente por cualquiera con acceso al servidor no es confiable?',
  'Porque un atacante que comprometió el sistema podría simplemente borrar las líneas que lo delatan, dejando un registro incompleto o engañoso.'
FROM laboratories l WHERE l.slug = 'inyeccion-en-logs-y-manipulacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Envía por POST a httpbin.org un campo "usuario" con un salto de línea URL-encoded seguido de una línea de log falsa, para probar el concepto de inyección en logs de forma segura. Copia el comando que usarías.',
  'Enviar %0A (salto de línea URL-encoded) dentro de un campo normal es la técnica estándar y segura para probar si un sistema registra datos de usuario sin codificar correctamente.'
FROM laboratories l WHERE l.slug = 'inyeccion-en-logs-y-manipulacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Puede fabricar líneas de log falsas que parecen eventos reales', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Puede borrar el log por completo de forma remota', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Puede cifrar el log para que nadie lo lea', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Puede aumentar el tamaño máximo del archivo de log', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'CWE-117', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'CWE-79', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'CWE-89', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'CWE-502', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un salto de línea', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un espacio en blanco', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Una comilla doble', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El símbolo de arroba', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque un atacante podría borrar las líneas que lo delatan', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque ocupa más espacio en disco', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque se vuelve más lento de leer', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque no es compatible con todos los formatos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Probando inyección en logs de forma segura',
  E'## Objetivo\n\nPractica de forma segura cómo se prueba si un sistema es vulnerable a inyección de logs, usando un endpoint que no tiene ningún log real detrás.\n\n## Instrucciones\n\n```bash\ncurl -X POST https://httpbin.org/post -d "usuario=admin%0ALOGIN_SUCCESS-admin-desde-IP-falsa"\n```\n\n**Desglose:**\n- `-X POST`: usa el método HTTP POST\n- `-d "usuario=admin%0A..."`: envía un campo "usuario" que contiene un salto de línea codificado (%0A) seguido de una línea que simula un evento de log falso\n- `https://httpbin.org/post`: endpoint de prueba público que solo refleja los datos recibidos\n\n**Qué observar:**\n\nhttpbin.org te devolverá el campo tal cual lo enviaste, con el salto de línea incluido. En un sistema real, la pregunta clave es: si esta aplicación registrara el campo "usuario" directamente en un archivo de log de texto plano sin codificar los saltos de línea, ¿ese log terminaría con una línea falsa que parece un evento real del sistema?\n\nCopia el **comando exacto** que usarías para esta prueba y úsalo en el quiz.',
  'curl -X POST https://httpbin.org/post -d "usuario=admin%0ALOGIN_SUCCESS-admin-desde-IP-falsa"',
  '¡Bien hecho! Ya sabes cómo se prueba la inyección en logs de forma segura. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'inyeccion-en-logs-y-manipulacion' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Alertas Efectivas y Honeytokens ────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'alertas-efectivas-y-honeytokens',
  'Alertas Efectivas y Honeytokens',
  E'## Registrar no es lo mismo que alertar\n\nUn sistema puede tener el mejor registro de eventos del mundo y aun así fallar en seguridad, si nadie revisa esos logs a tiempo. El registro responde "¿qué pasó?" — la alerta responde "¿alguien se está enterando de que está pasando **ahora mismo**?".\n\n## El problema de la fatiga de alertas\n\nSi un sistema genera cientos de alertas al día, la mayoría falsos positivos, el equipo termina ignorándolas todas por agotamiento — incluida la única alerta real entre las 300 falsas. Este fenómeno se conoce como **fatiga de alertas**, y es tan peligroso como no tener alertas en absoluto.\n\n```\nDemasiadas alertas:  300 alertas/día → nadie las revisa a fondo → la real se pierde entre el ruido\nAlertas bien calibradas: 3 alertas/día, cada una accionable → el equipo las revisa todas\n```\n\n## Honeytokens: trampas silenciosas\n\nUn **honeytoken** es un dato falso (una cuenta de usuario que no debería usarse nunca, una fila "trampa" en una tabla, una credencial que no le pertenece a nadie) colocado deliberadamente donde solo un atacante en fase de reconocimiento lo encontraría. Como nadie legítimo debería tocarlo jamás, **cualquier acceso a un honeytoken genera una alerta con prácticamente cero falsos positivos**.\n\n## Umbrales y planes de respuesta\n\nUna alerta útil necesita dos cosas más allá de dispararse: un **umbral razonable** (¿cuántos fallos en cuánto tiempo justifican una alerta?) y un **plan claro de qué hacer** cuando se dispara. Una alerta sin un procedimiento de respuesta documentado (un "playbook") termina siendo, en la práctica, solo otro correo que nadie sabe cómo atender.\n\nEstándares como el NIST 800-61r2 ofrecen marcos de referencia para estructurar un plan de respuesta a incidentes, en vez de improvisar cada vez que algo se dispara.\n\n## Cerrando el círculo\n\nRegistrar bien (Lab 1), leer esos registros con criterio (Lab 2), protegerlos de manipulación (Lab 3), y convertirlos en alertas accionables (este laboratorio) son las cuatro piezas que, juntas, hacen que un ataque se detecte en minutos en vez de descubrirse por accidente años después.\n\n---\nCompleta el quiz para ganar **200 puntos**.',
  2, 25, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'alertas-integridad-e-inyeccion-en-logs'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la diferencia central entre registrar (logging) y alertar?',
  'El registro responde "¿qué pasó?" de forma pasiva. La alerta responde si alguien se está enterando activamente de que algo está pasando en el momento en que ocurre.'
FROM laboratories l WHERE l.slug = 'alertas-efectivas-y-honeytokens'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué es la "fatiga de alertas" y por qué es peligrosa?',
  'Es cuando demasiadas alertas, en su mayoría falsos positivos, hacen que el equipo termine ignorándolas todas por agotamiento, incluida la única alerta real entre cientos de falsas.'
FROM laboratories l WHERE l.slug = 'alertas-efectivas-y-honeytokens'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué un honeytoken genera alertas con casi cero falsos positivos?',
  'Porque es un dato falso que nadie legítimo debería tocar jamás — cualquier acceso a él, por definición, indica actividad de reconocimiento no autorizada.'
FROM laboratories l WHERE l.slug = 'alertas-efectivas-y-honeytokens'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué le falta a una alerta que se dispara correctamente pero no tiene un procedimiento documentado de respuesta?',
  'Se vuelve, en la práctica, solo otro correo que nadie sabe cómo atender — la alerta técnica funcionó, pero no hay un plan claro sobre qué hacer con ella.'
FROM laboratories l WHERE l.slug = 'alertas-efectivas-y-honeytokens'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Qué ofrece un estándar como NIST 800-61r2 en el contexto de este laboratorio?',
  'Un marco de referencia para estructurar un plan de respuesta a incidentes, en vez de improvisar el procedimiento cada vez que una alerta se dispara.'
FROM laboratories l WHERE l.slug = 'alertas-efectivas-y-honeytokens'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El registro es pasivo, la alerta es activa y en tiempo real', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No hay ninguna diferencia real entre ambos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El registro solo aplica a errores, la alerta a éxitos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La alerta reemplaza por completo al registro', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Demasiados falsos positivos hacen que se ignore hasta la alerta real', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Es cuando el sistema deja de enviar alertas por completo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Es un tipo de ataque de denegación de servicio', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Es cuando las alertas se envían muy lentamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque ningún usuario legítimo debería tocarlo jamás', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque está cifrado con un algoritmo especial', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque se actualiza cada segundo automáticamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque solo existe en memoria, nunca en disco', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un procedimiento claro de qué hacer cuando se dispara', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un color más llamativo en el correo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un número de ticket más largo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Más destinatarios en copia', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un marco de referencia para estructurar la respuesta a incidentes', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un lenguaje de programación para escribir alertas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un proveedor específico de servidores en la nube', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un algoritmo de cifrado recomendado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'alertas-efectivas-y-honeytokens' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A09 — principiante)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (90, 150, 180, 200 puntos)
--   Preguntas:    20 nuevas (18 opción múltiple + 2 actividad)
--   Actividades:  2 nuevas
--   Puntos totales disponibles: 620
-- =============================================================================