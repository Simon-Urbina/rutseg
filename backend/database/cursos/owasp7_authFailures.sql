-- =============================================================================
-- seed_owasp_a07_auth_failures.sql
-- Curso OWASP Top 10 2025 — A07: Fallos de Autenticación
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas (todas multiple_choice, sin
-- actividad de terminal — ver nota de limpieza abajo).
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- Limpieza: una versión anterior de este seed enganchaba una "actividad de
-- terminal" (question_activities) a la pregunta 5 de cada lab, pero esa
-- pregunta es multiple_choice — el backend nunca la muestra (ver
-- CourseService.getLabDetail). Además, el expected_action_key era una frase
-- tipo ensayo, no un comando real, así que si algún día se hubiera mostrado
-- habría sido imposible de resolver. Este DELETE limpia esas filas huérfanas
-- si llegaste a correr esa versión anterior contra tu base de datos.
DELETE FROM question_activities
WHERE question_id IN (
  SELECT lq.id FROM laboratory_questions lq
  JOIN laboratories l ON lq.laboratory_id = l.id
  WHERE l.slug IN (
    'que-son-fallos-autenticacion',
    'contrasenas-enumeracion-y-recuperacion',
    'sesiones-fixation-y-cookie',
    'mfa-recuperacion-y-monitoreo'
  )
  AND lq.question_order = 5
  AND lq.question_type = 'multiple_choice'
);

-- =============================================================================
-- CURSO: OWASP A07 — Fallos de Autenticación (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a07-fallos-autenticacion',
  'OWASP A07: Fallos de Autenticación',
  'Domina la vulnerabilidad #7 del OWASP Top 10 2025. Aprende a identificar fallos de autenticación: contraseñas débiles, enumeración de usuarios, restablecimiento de contraseña inseguro, sesiones vulnerables, MFA mal implementado y verificaciones de identidad rotas.',
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
-- MÓDULO 1: Fundamentos de Autenticación Segura
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'fundamentos-autenticacion-segura',
  'Fundamentos de Autenticación Segura',
  'Qué es autenticación, en qué se diferencia de autorización y cuáles son las fallas más comunes del login.',
  1
FROM courses c WHERE c.slug = 'owasp-a07-fallos-autenticacion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;


-- ── Lab 1: ¿Qué son los Fallos de Autenticación? ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-son-fallos-autenticacion',
  '¿Qué son los Fallos de Autenticación?',
  E'## ¿Qué es un fallo de autenticación?\n\nLos **fallos de autenticación** ocurren cuando una aplicación no valida correctamente la identidad de una persona que intenta iniciar sesión o recuperar el acceso a una cuenta. Esto permite que un atacante se haga pasar por un usuario legítimo, acceda a información sensible o tome control de la cuenta.\n\nOWASP Top 10 2025 mantiene esta categoría en el puesto **#7** y la describe como procesos de inicio de sesión débiles o comprobaciones de identidad rotas.\n\n## Autenticación vs autorización\n\n| Concepto | Pregunta | Ejemplo |\n|---|---|---|\n| **Autenticación** | ¿Quién eres? | Iniciar sesión con usuario y contraseña |\n| **Autorización** | ¿Qué puedes hacer? | Ver si puedes entrar al panel de admin |\n\nUn sistema puede autenticar mal, aunque sus permisos estén bien definidos. En ese caso, el problema no está en el acceso a recursos, sino en verificar correctamente la identidad.\n\n## Fallos más comunes\n\n- Contraseñas débiles o reutilizadas.\n- Formularios de login sin rate limiting.\n- Mensajes de error que permiten enumerar usuarios.\n- Restablecimiento de contraseña inseguro.\n- MFA inexistente o mal aplicado.\n- Sesiones que no expiran o que pueden fijarse.\n\n## Señales de alerta\n\n- El backend responde diferente si un usuario existe o no.\n- No hay bloqueo temporal tras múltiples intentos fallidos.\n- Un token de sesión sigue válido después de cerrar sesión.\n- El enlace de recuperación no caduca o se puede reutilizar.\n\n## Idea clave\n\nSi un atacante logra suplantar a un usuario real, cualquier control posterior pierde valor. Por eso la autenticación debe diseñarse, probarse y monitorearse con el mismo rigor que los permisos.\n\n---\nCompleta el quiz para ganar **120 puntos**.\n',
  1, 20, 120, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-autenticacion-segura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué pregunta responde la autenticación en un sistema?',
  'La autenticación responde a la pregunta ''¿quién eres?'', porque su función es verificar la identidad de la persona o servicio que intenta acceder.'
FROM laboratories l WHERE l.slug = 'que-son-fallos-autenticacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuál de estas situaciones describe mejor un fallo de autenticación?',
  'Un fallo de autenticación ocurre cuando la aplicación permite iniciar sesión sin verificar correctamente la identidad, como en un login débil o roto.'
FROM laboratories l WHERE l.slug = 'que-son-fallos-autenticacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué síntoma puede indicar enumeración de usuarios?',
  'Si el sistema responde distinto cuando el usuario existe y cuando no existe, el atacante puede deducir cuentas válidas.'
FROM laboratories l WHERE l.slug = 'que-son-fallos-autenticacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué un login sin rate limiting es peligroso?',
  'Porque permite ataques de fuerza bruta o credential stuffing con muchos intentos en poco tiempo.'
FROM laboratories l WHERE l.slug = 'que-son-fallos-autenticacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Cuál es la mejor forma de describir un fallo de autenticación?',
  'Es una verificación de identidad débil o rota que permite que un atacante actúe como si fuera un usuario legítimo.'
FROM laboratories l WHERE l.slug = 'que-son-fallos-autenticacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '¿Quién eres?', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '¿Qué puedes hacer?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '¿Qué datos están visibles?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '¿Qué permisos faltan?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Permitir acceso sin verificar identidad', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Bloquear solo el panel admin', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Ocultar campos en la interfaz', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Cambiar colores del formulario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Mensajes de error distintos para cuentas válidas e inválidas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Contraseña con símbolos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Uso de HTTPS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Logout manual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Facilita fuerza bruta y credential stuffing', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Mejora la privacidad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Evita el phishing', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Aumenta el cifrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Una comprobación de identidad rota o débil', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un error de autorización', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un problema de diseño visual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un fallo de almacenamiento', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-son-fallos-autenticacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Nota: este lab no tiene actividad de terminal — las 5 preguntas son multiple_choice.

-- ── Lab 2: Contraseñas, Enumeración y Recuperación de Cuenta ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'contrasenas-enumeracion-y-recuperacion',
  'Contraseñas, Enumeración y Recuperación de Cuenta',
  E'## Contraseñas: el primer punto de defensa\n\nLa mayoría de los ataques contra autenticación empiezan con credenciales robadas, débiles o reutilizadas. Una contraseña no protege por sí sola si el sistema no controla el volumen de intentos, no detecta patrones anómalos o expone información sobre la existencia de cuentas.\n\n## Errores frecuentes\n\n| Error | Riesgo |\n|---|---|\n| Contraseñas cortas | Se adivinan más rápido |\n| Reutilización entre servicios | Credential stuffing |\n| Sin bloqueo temporal | Fuerza bruta masiva |\n| Sin MFA | Una sola contraseña basta |\n| Mensajes detallados | Enumeración de usuarios |\n\n## Enumeración de usuarios\n\nLa enumeración ocurre cuando el atacante descubre si una cuenta existe. Esto puede pasar en:\n\n- Login\n- Registro\n- Recuperación de contraseña\n- Desbloqueo de cuenta\n- Cambio de correo\n\nUn buen sistema debe responder de forma parecida ante cuentas válidas e inválidas, sin revelar pistas.\n\n## Recuperación de contraseña\n\nEl proceso de ''olvidé mi contraseña'' también necesita seguridad. OWASP recomienda no cambiar la cuenta hasta presentar un token válido y de un solo uso; además, el token debe expirar y no ser reutilizable.\n\n## Buenas prácticas\n\n- Hash de contraseñas con algoritmos modernos y sal.\n- Políticas de bloqueo o enfriamiento tras varios fallos.\n- Mensajes genéricos para evitar enumeración.\n- Tokens de recuperación de un solo uso y de corta duración.\n- Notificación al usuario cuando se cambia la contraseña.\n\n## Idea clave\n\nLa autenticación falla no solo cuando el atacante entra, sino también cuando el sistema le da demasiadas pistas para llegar hasta allí.\n\n---\nCompleta el quiz para ganar **200 puntos**.\n',
  2, 25, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-autenticacion-segura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué es la enumeración de usuarios?',
  'Es la capacidad de descubrir qué cuentas existen observando diferencias en respuestas, tiempos o mensajes.'
FROM laboratories l WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué ataque aprovecha credenciales robadas y reutilizadas en varios servicios?',
  'Ese patrón corresponde a credential stuffing, donde se prueban pares usuario/contraseña filtrados en otros sitios.'
FROM laboratories l WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué buena práctica ayuda a reducir la fuerza bruta?',
  'Aplicar rate limiting o bloqueo temporal frena intentos masivos y reduce la eficacia de ataques automatizados.'
FROM laboratories l WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué debe tener un token de recuperación seguro?',
  'Debe ser de un solo uso, expirar pronto y no permitir cambios en la cuenta hasta validarse correctamente.'
FROM laboratories l WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Cuál es la mejor defensa contra el abuso de contraseñas reutilizadas?',
  'Usar MFA y controlar intentos de acceso ayuda a reducir el impacto de credenciales comprometidas.'
FROM laboratories l WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Descubrir si una cuenta existe', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cambiar la contraseña', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifrar la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Ocultar el menú', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Credential stuffing', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'SQL injection', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'XSS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'IDOR', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Rate limiting y bloqueo temporal', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cambiar el logo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Usar solo mayúsculas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Mostrar el stack trace', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Ser de un solo uso y expirar pronto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ser permanente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Poder compartirse', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No requerir validación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'MFA y control de intentos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Más anuncios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Campos ocultos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'URLs largas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'contrasenas-enumeracion-y-recuperacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Nota: este lab no tiene actividad de terminal — las 5 preguntas son multiple_choice.

-- =============================================================================
-- MÓDULO 2: Sesiones, MFA y Prevención
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'sesiones-mfa-y-prevencion',
  'Sesiones, MFA y Prevención',
  'Cómo se rompen las sesiones, por qué el MFA importa y qué controles reducen el impacto de los fallos de autenticación.',
  2
FROM courses c WHERE c.slug = 'owasp-a07-fallos-autenticacion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;


-- ── Lab 1: Sesiones, Session Fixation y Cookies ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'sesiones-fixation-y-cookie',
  'Sesiones, Session Fixation y Cookies',
  E'## El problema de la sesión\n\nAutenticar al usuario es solo el inicio. Después hay que mantener el estado de forma segura. Si la sesión se crea, se comparte o se reutiliza mal, el atacante puede quedarse dentro aunque no conozca la contraseña.\n\n## Session fixation\n\nLa fijación de sesión ocurre cuando el atacante consigue que la víctima use un identificador de sesión conocido previamente. Si la aplicación no regenera la sesión después del login, el atacante puede reutilizar ese valor.\n\n## Buenas prácticas para sesiones\n\n| Práctica | Beneficio |\n|---|---|\n| Regenerar sesión tras iniciar sesión | Evita fijación |\n| Expirar sesiones inactivas | Reduce secuestro |\n| Cookies `HttpOnly` | Protege de acceso por JavaScript |\n| Cookies `Secure` | Solo viajan por HTTPS |\n| `SameSite` | Mitiga ciertos ataques cross-site |\n\n## Riesgos comunes\n\n- Tokens expuestos en URLs.\n- Cookies sin expiración adecuada.\n- Sesiones válidas después de cerrar sesión.\n- Reutilización de JWT sin controles de revocación.\n- Almacenamiento inseguro en navegador o app móvil.\n\n## Sesión vs autenticación\n\nLa autenticación confirma la identidad una vez; la sesión mantiene ese estado durante la interacción. Un error en la sesión puede abrir la puerta aunque el login original haya sido correcto.\n\n## Idea clave\n\nProteger la sesión es proteger la continuidad de la identidad.\n\n---\nCompleta el quiz para ganar **240 puntos**.\n',
  1, 25, 240, TRUE
FROM course_modules cm WHERE cm.slug = 'sesiones-mfa-y-prevencion'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué es session fixation?',
  'Es cuando el atacante hace que la víctima use una sesión ya conocida para luego reutilizarla.'
FROM laboratories l WHERE l.slug = 'sesiones-fixation-y-cookie'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué acción reduce el riesgo de session fixation después del login?',
  'Regenerar el identificador de sesión al iniciar sesión rompe el valor previamente conocido por el atacante.'
FROM laboratories l WHERE l.slug = 'sesiones-fixation-y-cookie'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué atributo de cookie evita que JavaScript lea la sesión?',
  'HttpOnly impide el acceso directo desde scripts del navegador.'
FROM laboratories l WHERE l.slug = 'sesiones-fixation-y-cookie'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué atributo de cookie ayuda a que solo se envíe por HTTPS?',
  'Secure fuerza el envío de la cookie únicamente en conexiones cifradas.'
FROM laboratories l WHERE l.slug = 'sesiones-fixation-y-cookie'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Qué ocurre si una sesión sigue válida después de cerrar sesión?',
  'El atacante podría reutilizar el token o identificador robado y seguir actuando como el usuario.'
FROM laboratories l WHERE l.slug = 'sesiones-fixation-y-cookie'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Reutilizar un ID de sesión conocido por el atacante', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cambiar el color del formulario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Ocultar el botón de salir', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Aumentar el tamaño de la cookie', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Regenerar la sesión', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No registrar eventos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Guardar la contraseña en texto plano', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Eliminar el HTTPS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'HttpOnly', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Secure', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Path', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Domain', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Secure', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Max-Age', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Priority', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Expires', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Reutilización de sesión robada', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Mejor compresión', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Más velocidad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Menos latencia', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'sesiones-fixation-y-cookie' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Nota: este lab no tiene actividad de terminal — las 5 preguntas son multiple_choice.

-- ── Lab 2: MFA, Recuperación y Monitoreo ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'mfa-recuperacion-y-monitoreo',
  'MFA, Recuperación y Monitoreo',
  E'## MFA no es opcional\n\nLa autenticación multifactor añade una segunda barrera además de la contraseña. OWASP lo recomienda como defensa clave, aunque también advierte que puede introducir complejidad, costos y riesgo de bloqueo si se implementa mal.\n\n## Tipos de MFA\n\n| Factor | Ejemplo |\n|---|---|\n| Algo que sabes | Contraseña o PIN |\n| Algo que tienes | App autenticadora, llave física |\n| Algo que eres | Huella o rostro |\n\n## Riesgos de MFA mal implementado\n\n- Push fatigue o aprobación repetitiva sin control.\n- Recuperación de MFA demasiado débil.\n- Canales alternativos más inseguros que el login principal.\n- Dependencia de SMS cuando hay opciones más robustas.\n- Falsos positivos o bloqueos que impiden acceso legítimo.\n\n## Monitoreo y respuesta\n\nLa autenticación no termina en el login. Hay que observar:\n\n- intentos fallidos repetidos,\n- cambios de contraseña,\n- restablecimientos de MFA,\n- accesos desde ubicaciones anómalas,\n- cambios inesperados en dispositivos confiables.\n\nOWASP también destaca que el registro y la alerta ayudan a detectar actividad sospechosa en fases tempranas.\n\n## Prevención práctica\n\n- MFA fuerte y preferiblemente resistente a phishing.\n- Alertas ante cambios de credenciales y recuperación.\n- Políticas de bloqueo o enfriamiento inteligentes.\n- Mensajería uniforme para evitar enumeración.\n- Revisión de sesiones activas y revocación cuando sea necesario.\n\n## Idea clave\n\nUna cuenta segura no depende solo de pedir un segundo factor, sino de diseñar todo el ciclo de identidad para resistir abuso, recuperación fraudulenta y detección tardía.\n\n---\nCompleta el quiz para ganar **290 puntos**.\n',
  2, 30, 290, TRUE
FROM course_modules cm WHERE cm.slug = 'sesiones-mfa-y-prevencion'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué aporta MFA a la autenticación?',
  'Añade una capa adicional de verificación, haciendo más difícil que una contraseña robada sea suficiente.'
FROM laboratories l WHERE l.slug = 'mfa-recuperacion-y-monitoreo'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué problema aparece cuando la recuperación de MFA es débil?',
  'Un atacante puede saltarse el segundo factor usando un canal alternativo menos seguro.'
FROM laboratories l WHERE l.slug = 'mfa-recuperacion-y-monitoreo'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué comportamiento puede indicar ataque a una cuenta?',
  'Múltiples intentos fallidos, cambios de contraseña o restablecimientos inesperados son señales de alerta.'
FROM laboratories l WHERE l.slug = 'mfa-recuperacion-y-monitoreo'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué tipo de MFA suele ser más resistente al phishing?',
  'Los factores vinculados al dispositivo o a llaves físicas suelen ser más robustos que códigos fáciles de reenviar.'
FROM laboratories l WHERE l.slug = 'mfa-recuperacion-y-monitoreo'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué el monitoreo es importante en autenticación?',
  'Porque permite detectar abuso o compromiso antes de que el atacante mantenga el acceso por mucho tiempo.'
FROM laboratories l WHERE l.slug = 'mfa-recuperacion-y-monitoreo'
ON CONFLICT (laboratory_id, question_order) DO UPDATE SET
  question_type = EXCLUDED.question_type,
  question_text = EXCLUDED.question_text,
  explanation = EXCLUDED.explanation;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Una verificación adicional además de la contraseña', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un diseño visual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un tipo de base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un proxy', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Puede abrir un bypass del segundo factor', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Mejora automáticamente la contraseña', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina el phishing', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Aumenta el ancho de banda', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Accesos anómalos y cambios inesperados', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo la fecha del sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El tamaño de la pantalla', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El idioma del navegador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Llaves físicas o factores vinculados al dispositivo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Respuestas por color', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Contraseñas cortas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Mensajes de error detallados', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Permite detectar abuso temprano', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo mejora el diseño', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Sustituye el cifrado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Evita la necesidad de login', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'mfa-recuperacion-y-monitoreo' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Nota: este lab no tiene actividad de terminal — las 5 preguntas son multiple_choice.

