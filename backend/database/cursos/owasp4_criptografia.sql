-- =============================================================================
-- seed_owasp_a04_criptografia.sql
-- Curso OWASP Top 10 2025 — A04: Fallos Criptográficos
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 3 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A04 — Fallos Criptográficos (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a04-fallos-criptograficos',
  'OWASP A04: Fallos Criptográficos',
  'Domina la vulnerabilidad #4 del OWASP Top 10 2025. Aprende la diferencia entre cifrado y hashing, cómo almacenar contraseñas de forma segura, por qué el TLS antiguo es peligroso y qué significa realmente la aleatoriedad criptográfica.',
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
-- MÓDULO 1: Fundamentos de Cifrado y Hashing
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'fundamentos-cifrado-hashing',
  'Fundamentos de Cifrado y Hashing',
  'Cifrado simétrico vs asimétrico, qué es el hashing y por qué no es lo mismo que cifrar, y cómo almacenar contraseñas de forma que ni siquiera un administrador de base de datos pueda leerlas.',
  1
FROM courses c WHERE c.slug = 'owasp-a04-fallos-criptograficos'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Cifrado Simétrico, Asimétrico y Hashing ────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'cifrado-simetrico-asimetrico-y-hashing',
  'Cifrado Simétrico, Asimétrico y Hashing',
  E'## Tres herramientas, tres propósitos distintos\n\nUn error muy común es tratar "cifrado" y "hashing" como sinónimos. Son operaciones matemáticas completamente distintas, pensadas para problemas diferentes.\n\n| Operación | Reversible | Para qué sirve |\n|---|---|---|\n| Cifrado simétrico | Sí, con la misma clave | Proteger datos que necesitas recuperar en su forma original (ej. un archivo) |\n| Cifrado asimétrico | Sí, con la clave privada correspondiente | Intercambiar información sin haber compartido antes una clave secreta (ej. TLS) |\n| Hashing | No, es de una sola vía | Verificar integridad o identidad sin necesitar el dato original (ej. contraseñas) |\n\n## Cifrado simétrico\n\nUsa la **misma clave** para cifrar y descifrar. Es rápido, ideal para grandes volúmenes de datos, pero exige un problema aparte: ¿cómo le entregas esa clave a la otra parte sin que nadie más la intercepte?\n\n```\nTexto plano --[clave K]--> Texto cifrado --[misma clave K]--> Texto plano\n```\n\n## Cifrado asimétrico\n\nUsa un **par de claves matemáticamente relacionadas**: una pública (se puede compartir libremente) y una privada (nunca se comparte). Lo que se cifra con la pública solo se descifra con la privada correspondiente.\n\n```\nTexto plano --[clave pública de B]--> Texto cifrado --[clave privada de B]--> Texto plano\n```\n\nEsto resuelve el problema de intercambio de claves del cifrado simétrico, pero es más lento — por eso TLS en la práctica usa cifrado asimétrico solo al inicio de la conexión, para acordar una clave simétrica temporal.\n\n## Hashing: la vía de un solo sentido\n\nUn hash toma una entrada de cualquier tamaño y produce una salida de tamaño fijo, de forma que sea prácticamente imposible reconstruir la entrada original a partir de la salida.\n\n```bash\necho -n "contraseña123" | sha256sum\n```\n\nSi cambias un solo carácter de la entrada, el hash resultante cambia por completo — eso es lo que permite usarlo para verificar integridad ("¿este archivo es idéntico al original?") o identidad ("¿esta contraseña coincide con la que se guardó?") sin necesitar guardar el dato original.\n\n## Algoritmos que ya no deberían usarse\n\nMD5 y SHA-1 fueron diseñados como funciones de hash de propósito general, no específicamente para contraseñas, y hoy se consideran **criptográficamente rotos**: existen técnicas conocidas para generar colisiones (dos entradas distintas con el mismo hash) o para revertirlos con suficiente potencia de cómputo.\n\n---\nCompleta el quiz para ganar **120 puntos**.',
  1, 20, 120, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-cifrado-hashing'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la diferencia fundamental entre cifrado y hashing?',
  'El cifrado es reversible: se puede recuperar el texto original con la clave correcta. El hashing es de una sola vía: no está pensado para recuperar el dato original, solo para verificar integridad o identidad.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'En el cifrado simétrico, ¿qué problema aparte hay que resolver siempre?',
  'Cómo entregar la clave compartida a la otra parte sin que sea interceptada en el camino, ya que la misma clave se usa tanto para cifrar como para descifrar.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué TLS usa cifrado asimétrico solo al inicio de la conexión, y no durante toda la sesión?',
  'Porque el cifrado asimétrico es más lento. Se usa al inicio únicamente para acordar de forma segura una clave simétrica temporal, y el resto de la sesión se cifra con esa clave simétrica, mucho más rápida.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué característica de un hash permite usarlo para verificar la integridad de un archivo?',
  'Que cambiar un solo carácter de la entrada produce un hash completamente distinto en la salida. Comparar el hash actual contra uno de referencia revela inmediatamente si el archivo fue modificado.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué MD5 y SHA-1 se consideran hoy criptográficamente rotos?',
  'Porque existen técnicas conocidas para generar colisiones (dos entradas distintas con el mismo hash) o para revertirlos con suficiente potencia de cómputo, algo que un algoritmo de hash seguro no debería permitir.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El cifrado es reversible, el hashing es de una sola vía', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Son exactamente lo mismo con nombres distintos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El hashing es más rápido pero siempre reversible', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El cifrado solo funciona con números, el hashing con texto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cómo entregar la clave sin que sea interceptada', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cómo hacer que el cifrado sea reversible', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cómo evitar que el texto cifrado ocupe espacio', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Cómo elegir el idioma del texto a cifrar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque el cifrado asimétrico es más lento que el simétrico', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque el cifrado asimétrico no es seguro para sesiones largas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque las claves asimétricas expiran cada pocos segundos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque el navegador no soporta cifrado asimétrico continuo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que un cambio mínimo en la entrada produce un hash totalmente distinto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que el hash siempre tiene el mismo tamaño que la entrada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el hash se puede revertir fácilmente al original', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que el hash es más corto mientras más larga sea la entrada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Existen técnicas conocidas para generar colisiones o revertirlos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque ya no están disponibles en ningún lenguaje de programación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque producen hashes demasiado largos para bases de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque requieren demasiada memoria RAM para calcularse', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'cifrado-simetrico-asimetrico-y-hashing' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Almacenamiento Seguro de Contraseñas ───────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'almacenamiento-seguro-de-contrasenas',
  'Almacenamiento Seguro de Contraseñas',
  E'## Por qué "hashear" no siempre es suficiente\n\nGuardar `sha256("contraseña123")` en vez de la contraseña en texto plano es mejor que nada, pero no es suficiente por sí solo. Si dos usuarios distintos eligen la misma contraseña, tendrán exactamente el mismo hash — y eso es explotable.\n\n## Rainbow tables: hashes precalculados\n\nUna rainbow table es, en esencia, un diccionario gigantesco de contraseñas comunes ya hasheadas de antemano. Si un atacante roba tu base de datos de hashes sin sal, solo necesita buscar cada hash en esa tabla para recuperar la contraseña original, sin calcular nada en el momento.\n\n```\nhash robado:        ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94\nrainbow table dice:  ese hash corresponde a "password123"\n```\n\n## La sal (salt): la primera defensa\n\nUna sal es un valor aleatorio único, generado por usuario, que se combina con la contraseña antes de hashear:\n\n```\nhash = HASH(contraseña + sal_aleatoria_del_usuario)\n```\n\nCon sal, dos usuarios con la misma contraseña tienen hashes completamente distintos, y una rainbow table genérica deja de servir porque tendría que calcularse de nuevo para cada sal específica.\n\n## Por qué ni siquiera SHA-256 con sal es suficiente\n\nSHA-256 fue diseñado para ser **rápido**, una cualidad excelente para verificar la integridad de un archivo, pero pésima para contraseñas: un atacante con hardware moderno (GPUs) puede probar miles de millones de combinaciones por segundo.\n\nPor eso, para contraseñas se usan funciones diseñadas para ser **deliberadamente lentas**, con un "factor de trabajo" configurable:\n\n| Algoritmo | Característica |\n|---|---|\n| bcrypt | Estándar de la industria desde hace años, incluye la sal automáticamente |\n| Argon2 | Ganador de la Password Hashing Competition, resistente también a ataques con GPU/ASIC |\n| PBKDF2-HMAC-SHA-512 | Ampliamente soportado, requiere muchas iteraciones configurables |\n\n## Verificando el concepto de hash con sal\n\n```bash\necho -n "contraseña123$(openssl rand -hex 8)" | sha256sum\n```\n\nCada vez que ejecutes este comando obtendrás un hash distinto, aunque la contraseña sea la misma, porque la sal generada por `openssl rand -hex 8` cambia en cada ejecución.\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  2, 25, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-cifrado-hashing'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué problema tiene guardar contraseñas con un hash simple, sin sal?',
  'Dos usuarios con la misma contraseña producen exactamente el mismo hash, lo que hace posible usar tablas de hashes precalculados (rainbow tables) para revertirlos masivamente.'
FROM laboratories l WHERE l.slug = 'almacenamiento-seguro-de-contrasenas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué es una rainbow table?',
  'Un diccionario gigantesco de contraseñas comunes ya hasheadas de antemano, que permite a un atacante buscar un hash robado y recuperar la contraseña original sin calcular nada en el momento.'
FROM laboratories l WHERE l.slug = 'almacenamiento-seguro-de-contrasenas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué logra agregar una sal aleatoria única por usuario antes de hashear la contraseña?',
  'Que dos usuarios con la misma contraseña tengan hashes completamente distintos, y que una rainbow table genérica deje de ser útil, ya que tendría que recalcularse para cada sal específica.'
FROM laboratories l WHERE l.slug = 'almacenamiento-seguro-de-contrasenas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué SHA-256, aunque se use con sal, no es ideal para hashear contraseñas?',
  'Porque fue diseñado para ser rápido, lo cual permite a un atacante con GPUs modernas probar miles de millones de combinaciones por segundo. Para contraseñas se necesitan funciones deliberadamente lentas, como bcrypt o Argon2.'
FROM laboratories l WHERE l.slug = 'almacenamiento-seguro-de-contrasenas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Genera 8 bytes de datos aleatorios en formato hexadecimal usando openssl, tal como se usaría para crear una sal. Copia el comando que usarías.',
  'openssl rand -hex 8 genera 8 bytes aleatorios criptográficamente seguros, representados como 16 caracteres hexadecimales — el tipo de valor que se usaría como sal en un esquema de hashing de contraseñas.'
FROM laboratories l WHERE l.slug = 'almacenamiento-seguro-de-contrasenas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Contraseñas iguales producen el mismo hash, vulnerable a rainbow tables', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El hash ocupa demasiado espacio en la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El hash tarda demasiado tiempo en generarse', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No es compatible con bases de datos relacionales', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un diccionario de contraseñas comunes ya hasheadas de antemano', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un servidor especializado en cifrado TLS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Una tabla de la base de datos donde se guardan las sesiones', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un algoritmo de cifrado asimétrico', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que contraseñas iguales generen hashes distintos entre usuarios', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que la contraseña se pueda recuperar más fácilmente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el hash resultante sea más corto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que ya no haga falta ninguna otra medida de seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque su velocidad facilita probar miles de millones de combinaciones', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque SHA-256 no acepta sal de ningún tipo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque SHA-256 solo funciona con números', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque SHA-256 ya no está disponible en librerías modernas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Generando una sal criptográfica con openssl',
  E'## Objetivo\n\nAprende a generar un valor aleatorio criptográficamente seguro, del tipo que se usaría como sal en un esquema de hashing de contraseñas.\n\n## Instrucciones\n\n```bash\nopenssl rand -hex 8\n```\n\n**Desglose:**\n- `openssl rand`: genera bytes aleatorios usando el generador criptográficamente seguro de OpenSSL\n- `-hex`: presenta la salida en formato hexadecimal, fácil de almacenar como texto\n- `8`: cantidad de bytes a generar (8 bytes = 16 caracteres hexadecimales)\n\n**Salida de ejemplo:**\n\n```\nc3f1a9e2b47d0f6a\n```\n\nCada ejecución produce un valor distinto. En un sistema real, este valor se generaría una vez por usuario, se guardaría junto al hash de su contraseña, y se combinaría con la contraseña antes de aplicar bcrypt o Argon2.\n\nCopia el **comando exacto** que usarías para generar 8 bytes aleatorios en hexadecimal y úsalo en el quiz.',
  'openssl rand -hex 8',
  '¡Correcto! Ya sabes generar una sal criptográficamente segura. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'almacenamiento-seguro-de-contrasenas' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: TLS, Aleatoriedad y Gestión de Claves
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'tls-aleatoriedad-gestion-claves',
  'TLS, Aleatoriedad y Gestión de Claves',
  'Por qué el TLS antiguo o mal configurado sigue siendo un riesgo real, qué diferencia a un generador de números aleatorios criptográficamente seguro de uno común, y buenas prácticas de gestión de claves.',
  2
FROM courses c WHERE c.slug = 'owasp-a04-fallos-criptograficos'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: TLS, Certificados y Downgrade Attacks ──────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'tls-certificados-y-downgrade',
  'TLS, Certificados y Ataques de Downgrade',
  E'## El escenario clásico: wifi pública\n\nUn atacante conectado a la misma red wifi pública que tú puede intentar interceptar tu tráfico. Si tu conexión no usa HTTPS, o el sitio permite caer de HTTPS a HTTP, el atacante puede leer o incluso modificar los datos que envías, incluida tu cookie de sesión.\n\n```\nTú -----HTTP (sin cifrar)-----> Sitio\n      ↑\n   atacante en la misma red intercepta todo el tráfico\n```\n\n## Qué es un downgrade attack\n\nEs cuando un atacante fuerza que la conexión use una versión más débil de TLS, o incluso HTTP puro, aunque el sitio sí soporte una versión más segura. El navegador y el servidor negocian qué protocolo usar, y ese proceso de negociación puede ser manipulado.\n\n## HSTS como defensa\n\n`Strict-Transport-Security` le dice al navegador: "nunca vuelvas a intentar cargar este sitio por HTTP, ni siquiera si alguien te lo pide". Esto cierra la ventana de tiempo en la que un downgrade sería posible.\n\n## Certificados: la otra mitad de la confianza\n\nTLS no solo cifra, también verifica identidad mediante certificados. Un certificado puede fallar la validación por varias razones: estar expirado, no coincidir con el dominio, o no estar firmado por una autoridad certificadora reconocida.\n\n```bash\ncurl -vI https://expired.badssl.com\n```\n\n`badssl.com` es un sitio público construido específicamente para practicar la detección de este tipo de errores: `expired.badssl.com` sirve, a propósito, un certificado vencido. La bandera `-v` (verbose) muestra el proceso completo de negociación TLS, incluyendo el motivo exacto del rechazo del certificado.\n\n## Por qué "ignorar el error y continuar" es peligroso\n\nMuchas herramientas permiten deshabilitar la verificación del certificado para "que funcione". Hacerlo en producción anula por completo la protección de TLS contra ataques de intermediario (MITM): ya no importa si los datos van cifrados, porque cualquiera puede hacerse pasar por el servidor legítimo.\n\n---\nCompleta el quiz y la actividad para ganar **250 puntos**.',
  1, 30, 250, TRUE
FROM course_modules cm WHERE cm.slug = 'tls-aleatoriedad-gestion-claves'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  'En una red wifi pública, ¿qué riesgo corre una conexión que no usa HTTPS?',
  'Un atacante conectado a la misma red puede interceptar y leer, o incluso modificar, el tráfico sin cifrar, incluida información sensible como cookies de sesión.'
FROM laboratories l WHERE l.slug = 'tls-certificados-y-downgrade'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué es exactamente un ataque de downgrade en el contexto de TLS?',
  'Es cuando un atacante fuerza que la conexión use una versión más débil de TLS, o incluso HTTP sin cifrar, manipulando el proceso de negociación entre navegador y servidor, aunque el servidor sí soporte una versión segura.'
FROM laboratories l WHERE l.slug = 'tls-certificados-y-downgrade'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué le indica exactamente la cabecera Strict-Transport-Security al navegador?',
  'Que nunca vuelva a intentar cargar ese sitio por HTTP sin cifrar, cerrando la ventana de tiempo en la que un ataque de downgrade sería posible.'
FROM laboratories l WHERE l.slug = 'tls-certificados-y-downgrade'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué es peligroso deshabilitar la verificación del certificado TLS "para que funcione"?',
  'Porque anula por completo la protección de TLS contra ataques de intermediario (MITM): sin verificar el certificado, cualquiera puede hacerse pasar por el servidor legítimo, sin importar que la conexión vaya cifrada.'
FROM laboratories l WHERE l.slug = 'tls-certificados-y-downgrade'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa curl en modo verboso para inspeccionar solo las cabeceras de expired.badssl.com y ver el motivo del rechazo del certificado. Copia el comando que usarías.',
  'curl -vI muestra el proceso completo de negociación TLS, incluyendo por qué se rechaza un certificado expirado, algo invisible con un curl normal sin la bandera verbose.'
FROM laboratories l WHERE l.slug = 'tls-certificados-y-downgrade'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Puede ser interceptada y leída por otros en la misma red', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ninguno, si la contraseña del wifi es fuerte', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo se puede leer si el atacante conoce tu contraseña', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Ninguno, el router siempre cifra el tráfico interno', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Forzar el uso de una versión más débil de TLS o HTTP sin cifrar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Reducir la velocidad de la conexión a propósito', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Descargar una versión antigua del navegador de la víctima', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Bloquear el acceso al sitio por completo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que nunca intente cargar el sitio por HTTP sin cifrar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que guarde la contraseña del usuario de forma local', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que bloquee automáticamente todas las cookies', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que active un antivirus en el navegador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cualquiera puede hacerse pasar por el servidor legítimo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'La conexión se vuelve más lenta de forma permanente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El servidor deja de responder peticiones', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El navegador borra automáticamente las cookies', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Inspeccionando un certificado expirado con curl',
  E'## Objetivo\n\nObserva cómo se ve, desde la línea de comandos, el rechazo de un certificado TLS expirado, usando un sitio público construido exactamente para practicar esto.\n\n## Instrucciones\n\n```bash\ncurl -vI https://expired.badssl.com\n```\n\n**Desglose:**\n- `-v`: modo verboso, muestra todo el proceso de negociación TLS paso a paso\n- `-I`: pide solo las cabeceras, no el cuerpo de la respuesta\n- `expired.badssl.com`: un subdominio de badssl.com que sirve a propósito un certificado vencido, pensado para practicar la detección de este error de forma segura\n\n**Qué buscar en la salida:**\n\n```\n* SSL certificate problem: certificate has expired\n```\n\nEste es exactamente el tipo de error que debería detener cualquier conexión automatizada, y que nunca se debería silenciar con una bandera como `-k` (insecure) en producción.\n\nCopia el **comando exacto** que usarías para inspeccionar el certificado de expired.badssl.com y úsalo en el quiz.',
  'curl -vI https://expired.badssl.com',
  '¡Bien hecho! Ya sabes cómo se detecta un certificado TLS inválido desde la terminal. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'tls-certificados-y-downgrade' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Aleatoriedad Criptográfica y Gestión de Claves ─────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'aleatoriedad-criptografica-y-gestion-de-claves',
  'Aleatoriedad Criptográfica y Gestión de Claves',
  E'## No toda "aleatoriedad" es igual de aleatoria\n\nMuchos lenguajes de programación traen dos generadores de números aleatorios distintos, y usar el equivocado en un contexto de seguridad es un fallo criptográfico real:\n\n| Tipo | Ejemplo típico | Uso seguro |\n|---|---|---|\n| Pseudo-aleatorio general | `Math.random()`, `random.random()` | Barajar una lista, generar un color decorativo — NO seguridad |\n| Criptográficamente seguro (CSPRNG) | `crypto.randomBytes()`, `secrets.token_hex()`, `openssl rand` | Tokens de sesión, claves, sales, códigos de verificación |\n\nUn generador pseudo-aleatorio "general" suele ser predecible si un atacante conoce (o puede deducir) la semilla con la que se inicializó. Un CSPRNG está diseñado específicamente para que eso sea inviable.\n\n## Generando aleatoriedad segura desde la terminal\n\n```bash\nopenssl rand -hex 16\n```\n\nEste comando usa el generador criptográficamente seguro de OpenSSL para producir 16 bytes (128 bits) de datos verdaderamente impredecibles — el tipo de valor apropiado para un token de sesión o una clave de API.\n\n## Claves hardcodeadas: el error que nunca debería pasar\n\nUna clave de cifrado escrita directamente en el código fuente (`const SECRET_KEY = "abc123"`) queda expuesta a cualquiera con acceso al repositorio, incluyendo el historial completo de Git aunque se elimine después. Las claves deben vivir en variables de entorno o en un gestor de secretos dedicado, nunca en el código.\n\n## Rotación de claves\n\nUsar la misma clave para siempre significa que, si alguna vez se filtra, el daño es indefinido hacia atrás y hacia adelante en el tiempo. Rotar claves periódicamente (cambiarlas y invalidar las anteriores) limita la ventana de exposición de cualquier filtración que no se haya detectado todavía.\n\n## Autenticación además de cifrado\n\nOWASP recomienda usar siempre **cifrado autenticado** (que verifica que los datos cifrados no fueron alterados) en vez de cifrado simple. Cifrar datos sin autenticarlos deja abierta la puerta a que alguien modifique el texto cifrado de formas predecibles, incluso sin poder leerlo.\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  2, 30, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'tls-aleatoriedad-gestion-claves'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué usar "Math.random()" (o equivalentes) para generar un token de sesión es un fallo criptográfico?',
  'Porque estos generadores están diseñados para uso general, no para seguridad, y suelen ser predecibles si un atacante conoce o deduce la semilla con la que se inicializaron.'
FROM laboratories l WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué significa la sigla CSPRNG?',
  'Generador de Números Pseudo-Aleatorios Criptográficamente Seguro (Cryptographically Secure Pseudo-Random Number Generator), diseñado específicamente para que su salida sea inviable de predecir.'
FROM laboratories l WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué escribir una clave de cifrado directamente en el código fuente es peligroso incluso si luego se elimina?',
  'Porque queda expuesta en el historial de Git, accesible para cualquiera con acceso al repositorio, aunque la línea específica ya no exista en la versión actual del código.'
FROM laboratories l WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué ventaja tiene el cifrado autenticado sobre el cifrado simple?',
  'El cifrado autenticado verifica que los datos cifrados no fueron alterados. El cifrado simple no ofrece esa garantía, dejando abierta la posibilidad de modificar el texto cifrado de formas predecibles sin necesitar leerlo.'
FROM laboratories l WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Genera 16 bytes de datos aleatorios criptográficamente seguros en formato hexadecimal, del tipo apropiado para una clave de API. Copia el comando que usarías.',
  'openssl rand -hex 16 produce 128 bits de aleatoriedad verdaderamente impredecible usando el generador criptográficamente seguro de OpenSSL, muy distinto de un Math.random() de propósito general.'
FROM laboratories l WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque puede ser predecible si se conoce la semilla de inicialización', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque genera números demasiado largos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque no funciona en navegadores modernos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque solo puede generar números negativos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Generador de Números Pseudo-Aleatorios Criptográficamente Seguro', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Sistema de Protección contra Rastreo de Redes', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Protocolo de Certificación Segura de Redes de Grupo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Codificador Simétrico de Paquetes de Red Global', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque queda expuesta en el historial de Git', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque Git cifra automáticamente el código eliminado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque el código eliminado se ejecuta igual en producción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque las claves eliminadas se envían automáticamente por correo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Verifica que los datos cifrados no fueron alterados', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Hace que el cifrado sea siempre más rápido', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de usar una clave', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Reduce el tamaño del archivo cifrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Generando una clave criptográficamente segura',
  E'## Objetivo\n\nGenera un valor aleatorio de calidad criptográfica, del tipo apropiado para una clave de API o un token de sesión.\n\n## Instrucciones\n\n```bash\nopenssl rand -hex 16\n```\n\n**Desglose:**\n- `openssl rand`: usa el generador criptográficamente seguro de OpenSSL, no un generador de propósito general\n- `-hex`: presenta la salida en formato hexadecimal\n- `16`: genera 16 bytes (128 bits) de aleatoriedad\n\n**Salida de ejemplo:**\n\n```\n9f2a1c88e4b703d5f0a6c21e9d84b731\n```\n\n128 bits de aleatoriedad criptográfica son, en la práctica, imposibles de adivinar por fuerza bruta con la tecnología actual — muy distinto de lo que produciría un generador de propósito general como Math.random().\n\nCopia el **comando exacto** que usarías para generar 16 bytes aleatorios seguros en hexadecimal y úsalo en el quiz.',
  'openssl rand -hex 16',
  '¡Excelente! Ya sabes generar material criptográfico apto para claves y tokens. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'aleatoriedad-criptografica-y-gestion-de-claves' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A04 — intermedio)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (120, 200, 250, 280 puntos)
--   Preguntas:    20 nuevas (17 opción múltiple + 3 actividad)
--   Actividades:  3 nuevas
--   Puntos totales disponibles: 850
-- =============================================================================