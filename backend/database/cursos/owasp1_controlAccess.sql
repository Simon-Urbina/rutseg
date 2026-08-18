-- =============================================================================
-- seed_owasp_a01_control_acceso.sql
-- Curso OWASP Top 10 2025 — A01: Control de Acceso Roto
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 4 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A01 — Control de Acceso Roto (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a01-control-acceso',
  'OWASP A01: Control de Acceso Roto',
  'Domina la vulnerabilidad #1 del OWASP Top 10 2025. Aprende a identificar y explotar fallos de control de acceso: IDOR, escalada de privilegios horizontal y vertical, bypass de restricciones y referencias directas a objetos expuestas.',
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
-- MÓDULO 1: Fundamentos del Control de Acceso
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'fundamentos-control-acceso',
  'Fundamentos del Control de Acceso',
  'Conceptos clave de autenticación vs autorización, modelos DAC/MAC/RBAC y IDOR: la causa raíz más común del fallo de control de acceso según OWASP 2025.',
  1
FROM courses c WHERE c.slug = 'owasp-a01-control-acceso'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Autenticación vs Autorización ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'autenticacion-vs-autorizacion',
  'Autenticación vs Autorización: la diferencia crítica',
  E'## ¿Qué es el Control de Acceso Roto?\n\nEl **Control de Acceso Roto** (Broken Access Control) es la vulnerabilidad #1 del OWASP Top 10 2025. Ocurre cuando una aplicación no verifica correctamente si un usuario autenticado tiene **permiso** para realizar una acción o acceder a un recurso.\n\nEsta vulnerabilidad es la principal causa de filtraciones de datos a nivel mundial.\n\n## Autenticación ≠ Autorización\n\nSon conceptos distintos y ambos son necesarios:\n\n| Concepto | Pregunta que responde | Ejemplo |\n|---|---|---|\n| **Autenticación** | ¿Quién eres? | Usuario inicia sesión con contraseña |\n| **Autorización** | ¿Qué puedes hacer? | ¿Puede este usuario ver la factura #1234? |\n\nUn sistema puede autenticar correctamente a un usuario y aun así fallar en la autorización, permitiéndole acceder a recursos de otros usuarios.\n\n## Modelos de control de acceso\n\n| Modelo | Descripción | Ejemplo |\n|---|---|---|\n| **DAC** (Discretionary) | El propietario del recurso decide quién accede | Permisos de archivos en Linux |\n| **MAC** (Mandatory) | El sistema impone políticas, no el usuario | Clasificación militar (secreto, top secret) |\n| **RBAC** (Role-Based) | El acceso se basa en roles asignados | Admin, Editor, Lector en un CMS |\n| **ABAC** (Attribute-Based) | El acceso depende de atributos del usuario y recurso | Acceso solo desde IP corporativa y en horario laboral |\n\n## ¿Por qué falla el control de acceso?\n\nSegún OWASP 2025, los errores más comunes son:\n\n- Confiar en parámetros controlados por el cliente (IDs en la URL, campos ocultos).\n- Verificar el acceso solo en la UI y no en el backend.\n- Elevar privilegios modificando tokens o cookies.\n- Acceder a APIs sin validar la autorización en cada endpoint.\n- Permitir el método HTTP incorrecto (GET cuando solo debería permitirse POST).\n\n---\nCompleta el quiz para ganar **120 puntos**.',
  1, 20, 120, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-control-acceso'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la posición del Control de Acceso Roto en el OWASP Top 10 2025?',
  'El Control de Acceso Roto ocupa el puesto #1 del OWASP Top 10 2025, siendo la vulnerabilidad más crítica y frecuente en aplicaciones web. Es también la principal causa de filtraciones de datos.'
FROM laboratories l WHERE l.slug = 'autenticacion-vs-autorizacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué pregunta responde la AUTORIZACIÓN en un sistema de seguridad?',
  'La autorización responde "¿qué puedes hacer?", es decir, qué recursos y acciones están permitidos para un usuario ya identificado. La autenticación responde "¿quién eres?".'
FROM laboratories l WHERE l.slug = 'autenticacion-vs-autorizacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué modelo de control de acceso basa los permisos en roles asignados al usuario?',
  'RBAC (Role-Based Access Control) asigna permisos a roles (Admin, Editor, Lector) y luego asigna roles a usuarios. Es el modelo más utilizado en aplicaciones web empresariales.'
FROM laboratories l WHERE l.slug = 'autenticacion-vs-autorizacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Cuál de estos es un error clásico de control de acceso roto según OWASP?',
  'Verificar el acceso solo en la interfaz de usuario (frontend) y no en el backend es un error crítico. Un atacante puede saltarse la UI y llamar directamente al API, sin que haya validación real.'
FROM laboratories l WHERE l.slug = 'autenticacion-vs-autorizacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Qué modelo de control de acceso es más adecuado para clasificaciones de seguridad militar?',
  'MAC (Mandatory Access Control) impone etiquetas de clasificación (secreto, confidencial, top secret) a los objetos y sujetos. El sistema controla el acceso, no el propietario del recurso.'
FROM laboratories l WHERE l.slug = 'autenticacion-vs-autorizacion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '#1 — la vulnerabilidad más crítica', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '#3 — tercer lugar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '#5 — en el medio de la lista', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '#7 — fallos de autenticación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '¿Qué puedes hacer? — permisos y recursos permitidos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '¿Quién eres? — verificación de identidad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '¿Desde dónde te conectas? — verificación de IP', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '¿Cuándo iniciaste sesión? — timestamp de sesión', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'RBAC (Role-Based Access Control)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'MAC (Mandatory Access Control)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'DAC (Discretionary Access Control)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'ACL (Access Control List)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Verificar el acceso solo en la UI y no en el backend', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usar HTTPS para todas las comunicaciones', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Hashear contraseñas con bcrypt', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Implementar autenticación multifactor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'MAC (Mandatory Access Control)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'RBAC (Role-Based Access Control)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'DAC (Discretionary Access Control)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'ABAC (Attribute-Based Access Control)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'autenticacion-vs-autorizacion' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: IDOR — Insecure Direct Object References ──────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'idor-referencias-directas',
  'IDOR: Referencias Directas a Objetos Inseguras',
  E'## ¿Qué es IDOR?\n\n**IDOR (Insecure Direct Object Reference)** es el tipo más común de control de acceso roto. Ocurre cuando una aplicación usa identificadores controlados por el usuario (IDs en URL, parámetros, cookies) para acceder a objetos sin verificar si ese usuario tiene permiso.\n\n## Ejemplo clásico\n\n```\n# Usuario legítimo accede a su factura:\nGET /api/facturas/1001\nAuthorization: Bearer <token_usuario_A>\n\n# El mismo usuario modifica el ID y accede a la factura de otro:\nGET /api/facturas/1002\nAuthorization: Bearer <token_usuario_A>\n\n# Si el servidor responde con la factura de otro usuario → IDOR confirmado\n```\n\n## IDOR en diferentes contextos\n\n| Contexto | Ejemplo vulnerable |\n|---|---|\n| **URL path** | `/perfil/usuario/42` → cambiar 42 por otro ID |\n| **Query param** | `/descarga?archivo=reporte_2024.pdf` |\n| **Body JSON** | `{"user_id": 42, "accion": "eliminar"}` |\n| **Cookie** | `user_role=admin` (manipulable desde el cliente) |\n| **Header** | `X-User-ID: 42` |\n\n## IDOR de tipo referencia indirecta\n\nAlgunas aplicaciones intentan usar tokens o hashes en lugar de IDs numéricos, pero si la lógica de autorización falta en el backend, el problema persiste:\n\n```\nGET /api/documentos/a1b2c3d4e5f6  ← hash predecible o bruteforceable\n```\n\n## Cómo detectar IDOR\n\n```bash\n# Con curl, enumerar recursos cambiando el ID\nfor id in $(seq 1 100); do\n  curl -s -o /dev/null -w "%{http_code} id=$id\\n" \\\n    -H "Authorization: Bearer TU_TOKEN" \\\n    https://api.ejemplo.com/facturas/$id\ndone\n```\n\n## Prevención\n\n- Validar en el backend que el recurso solicitado pertenezca al usuario autenticado.\n- Usar UUIDs en lugar de IDs secuenciales (dificulta la enumeración, pero no reemplaza la validación).\n- Implementar tests de autorización en cada endpoint.\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  2, 30, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'fundamentos-control-acceso'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué significa IDOR en seguridad web?',
  'IDOR significa Insecure Direct Object Reference (Referencia Directa a Objetos Insegura). Ocurre cuando la aplicación permite acceder a objetos usando identificadores del cliente sin verificar la autorización en el servidor.'
FROM laboratories l WHERE l.slug = 'idor-referencias-directas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuál de estos ejemplos representa un IDOR clásico en una URL?',
  'Cambiar el ID numérico de /api/facturas/1001 a /api/facturas/1002 para acceder a recursos de otro usuario es el ejemplo más clásico de IDOR. El servidor no verifica que ese ID pertenezca al usuario autenticado.'
FROM laboratories l WHERE l.slug = 'idor-referencias-directas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Usar UUIDs en lugar de IDs numéricos secuenciales elimina completamente la vulnerabilidad IDOR?',
  'No. Los UUIDs dificultan la enumeración pero NO reemplazan la validación de autorización en el backend. Si no se verifica que el UUID solicitado pertenece al usuario autenticado, el IDOR persiste.'
FROM laboratories l WHERE l.slug = 'idor-referencias-directas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Dónde debe realizarse la validación de autorización para prevenir IDOR?',
  'La validación SIEMPRE debe estar en el backend/servidor. Cualquier control solo en el frontend puede ser saltado trivialmente por un atacante que intercepte o modifique las peticiones HTTP.'
FROM laboratories l WHERE l.slug = 'idor-referencias-directas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Enumera recursos de una API cambiando el parámetro ID del 1 al 5. Copia la respuesta generada.',
  'El bucle for con curl es la técnica básica de enumeración IDOR. Observando qué IDs responden con 200 vs 403/404 se identifican recursos accesibles sin autorización.'
FROM laboratories l WHERE l.slug = 'idor-referencias-directas'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Insecure Direct Object Reference', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Internal Data Object Redirect', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Injection-Driven Object Routing', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Invalid Data Override Request', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cambiar /api/facturas/1001 por /api/facturas/1002 con el token de otro usuario', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Inyectar SQL en un campo de búsqueda', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Interceptar y modificar un token JWT', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Realizar un ataque de fuerza bruta sobre la contraseña', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No, los UUIDs dificultan la enumeración pero no reemplazan la validación en el backend', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Sí, los UUIDs son imposibles de adivinar y eliminan el IDOR', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Sí, siempre que el UUID tenga más de 128 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo si se combinan con HTTPS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'En el backend/servidor, siempre', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'En el frontend, ocultando los IDs sensibles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo en la capa de base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'En el CDN o proxy inverso', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Enumeración IDOR con curl',
  E'## Objetivo\n\nUsa curl para enumerar IDs de una API e identificar posibles vulnerabilidades IDOR.\n\n## Instrucciones\n\n```bash\nfor id in $(seq 1 5); do curl -s -o /dev/null -w "%{http_code} id=$id\\n" https://httpbin.org/get?id=$id; done\n```\n\n**Desglose del comando:**\n- `seq 1 5`: genera la secuencia 1 2 3 4 5\n- `curl -s`: modo silencioso (sin barra de progreso)\n- `-o /dev/null`: descarta el body de la respuesta\n- `-w "%{http_code} id=$id\\n"`: imprime solo el código HTTP y el ID\n\n**En una prueba real**, reemplazarías `https://httpbin.org/get?id=$id` por el endpoint objetivo con tu token de sesión:\n\n```bash\nfor id in $(seq 1 50); do\n  curl -s -o /dev/null -w "%{http_code} id=$id\\n" \\\n    -H "Authorization: Bearer TU_TOKEN" \\\n    https://api.objetivo.com/facturas/$id\ndone\n```\n\nCódigos HTTP relevantes:\n- **200**: recurso accesible → posible IDOR\n- **403**: prohibido → control de acceso activo\n- **404**: no existe\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'for id in $(seq 1 5); do curl -s -o /dev/null -w "%{http_code} id=$id\\n" https://httpbin.org/get?id=$id; done',
  '¡Correcto! Has ejecutado una enumeración básica de IDOR. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'idor-referencias-directas' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Escalada de Privilegios y Bypass
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'escalada-privilegios-bypass',
  'Escalada de Privilegios y Bypass de Controles',
  'Ataques de escalada horizontal y vertical, manipulación de tokens JWT, bypass de restricciones por método HTTP y técnicas de explotación en APIs REST.',
  2
FROM courses c WHERE c.slug = 'owasp-a01-control-acceso'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Escalada Horizontal y Vertical ────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'escalada-horizontal-vertical',
  'Escalada de Privilegios: Horizontal y Vertical',
  E'## Tipos de escalada de privilegios\n\nExisten dos tipos fundamentales de escalada de privilegios en control de acceso:\n\n### Escalada Horizontal\n\nEl usuario accede a recursos de **otro usuario con el mismo nivel de privilegios**.\n\n```\nUsuario A (cliente)  →  accede a datos del  →  Usuario B (cliente)\n         ↑ mismo nivel de privilegios ↑\n```\n\n**Ejemplo:** Un usuario cambia su `user_id` en la petición y ve el historial de pedidos de otro cliente.\n\n### Escalada Vertical\n\nEl usuario accede a funciones de **un rol más privilegiado**.\n\n```\nUsuario normal  →  accede a funciones de  →  Administrador\n      ↑ salto a nivel superior de privilegios ↑\n```\n\n**Ejemplo:** Un usuario modifica el parámetro `role=admin` en una cookie o token y accede al panel de administración.\n\n## Vectores comunes de escalada\n\n```http\n# 1. Manipulación de parámetro en body\nPATCH /api/usuarios/perfil\nContent-Type: application/json\n\n{"nombre": "Nuevo nombre", "role": "admin"}  ← campo no debería ser modificable por el usuario\n\n# 2. Manipulación del JWT (si la firma no se verifica)\n# Decodificar el payload y cambiar el rol:\n{"sub": "123", "role": "user"}  →  {"sub": "123", "role": "admin"}\n\n# 3. Parameter pollution\nGET /admin/panel?admin=true\nGET /perfil?user_id=1&user_id=999\n```\n\n## Escalada en APIs REST\n\nLas APIs REST son especialmente vulnerables porque exponen la estructura de datos directamente.\n\n```bash\n# Endpoint de usuario propio (legítimo)\nGET /api/v1/users/me\n\n# Intentar acceso a endpoint de administración\nGET /api/v1/admin/users          ← ¿responde con lista de usuarios?\nGET /api/v1/users/1/permissions  ← ¿expone permisos internos?\nDELETE /api/v1/users/999         ← ¿puede un usuario borrar cuentas ajenas?\n```\n\n## Herramienta: jwt.io\n\nPara analizar tokens JWT:\n\n```bash\n# Decodificar un JWT desde la terminal\necho "eyJ..." | cut -d. -f2 | base64 -d 2>/dev/null | python3 -m json.tool\n```\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  1, 35, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'escalada-privilegios-bypass'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué escalada ocurre cuando un usuario accede a datos de otro con el mismo nivel de privilegios?',
  'La escalada horizontal implica acceder lateralmente a recursos de otro usuario con el mismo rol. No se ganan más privilegios, pero se viola la privacidad e integridad de datos ajenos.'
FROM laboratories l WHERE l.slug = 'escalada-horizontal-vertical'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuál de estos escenarios es un ejemplo de escalada VERTICAL de privilegios?',
  'Modificar el parámetro role a "admin" para acceder al panel de administración siendo usuario normal es escalada vertical: se salta a un nivel de privilegios superior al propio.'
FROM laboratories l WHERE l.slug = 'escalada-horizontal-vertical'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué parte de un token JWT contiene los claims (datos del usuario como el rol)?',
  'Un JWT tiene tres partes: Header.Payload.Signature. El Payload (segunda parte) contiene los claims, incluyendo el rol del usuario (sub, role, exp, etc.). Es codificado en Base64 pero no cifrado.'
FROM laboratories l WHERE l.slug = 'escalada-horizontal-vertical'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué es peligroso que el usuario pueda editar campos como "role" o "is_admin" en el body JSON?',
  'Si el backend procesa todos los campos del body sin filtrar, un atacante puede incluir campos extra como "role: admin" o "is_admin: true" y el servidor los podría aplicar. Esto se llama Mass Assignment.'
FROM laboratories l WHERE l.slug = 'escalada-horizontal-vertical'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Decodifica el payload de un JWT desde la terminal para inspeccionar sus claims. Copia la respuesta generada.',
  'Los JWT están codificados en Base64 pero no cifrados. Decodificar el payload revela claims como el rol del usuario, lo que permite identificar si son manipulables desde el cliente.'
FROM laboratories l WHERE l.slug = 'escalada-horizontal-vertical'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Escalada horizontal', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Escalada vertical', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Inyección de privilegios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Bypass de autenticación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Modificar el parámetro "role=admin" en la petición para acceder al panel de administración', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ver el historial de pedidos de otro cliente cambiando el user_id', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Acceder a la factura de otro usuario con el mismo plan de suscripción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Leer mensajes privados de otro usuario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El Payload (segunda parte, codificada en Base64)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El Header (primera parte)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'La Signature (tercera parte)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'En ninguna parte, los JWTs cifran todo el contenido', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un atacante puede incluir campos extra como "role: admin" y el servidor los podría aplicar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El JSON se cifra automáticamente al enviarse por HTTPS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Los campos extra son ignorados por todos los frameworks modernos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo es un problema si el usuario conoce el nombre exacto del campo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Decodificación de JWT en terminal',
  E'## Objetivo\n\nDecodifica el payload de un token JWT desde la terminal para analizar sus claims y entender qué información expone.\n\n## Instrucciones\n\nEjecuta exactamente este comando (ya es el payload del JWT, sin el header ni la firma):\n\n```bash\necho "eyJzdWIiOiIxMjM0NTY3ODkwIiwicm9sZSI6InVzZXIifQ==" | base64 -d\n```\n\n**Desglose del comando:**\n- `echo "..."`: el payload del JWT, ya extraído\n- `| base64 -d`: decodifica el Base64 y muestra el JSON en texto plano\n\n**Resultado esperado (esto es exactamente lo que verás):**\n\n```json\n{"sub":"1234567890","role":"user"}\n```\n\n**Implicaciones de seguridad:**\n- El payload es legible por cualquiera que tenga el token — Base64 es una codificación reversible, no un cifrado.\n- Si el backend no verifica la firma, modificar "role" a "admin" y reconstruir el token podría funcionar.\n- NUNCA almacenar secretos en el payload de un JWT.\n\nCopia la **respuesta generada** (el JSON de arriba) y úsala en el quiz.',
  'echo "eyJzdWIiOiIxMjM0NTY3ODkwIiwicm9sZSI6InVzZXIifQ==" | base64 -d',
  '¡Muy bien! Has decodificado el payload JWT y puedes ver los claims. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'escalada-horizontal-vertical' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Bypass de controles y prevención ───────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'bypass-controles-prevencion',
  'Bypass de Controles HTTP y Estrategias de Prevención',
  E'## Bypass por método HTTP\n\nAlgunas aplicaciones aplican controles de acceso para ciertos métodos HTTP pero olvidan restringir otros. Un atacante puede explotar esto cambiando el método de la petición.\n\n```http\n# La aplicación restringe POST /admin/borrar-usuario → 403\nPOST /admin/borrar-usuario HTTP/1.1\n\n# Pero no restringe el mismo path con otros métodos:\nGET /admin/borrar-usuario?id=42     ← ¿funciona?\nPUT /admin/borrar-usuario           ← ¿funciona?\nX-HTTP-Method-Override: DELETE      ← header para "tunelizar" métodos\n```\n\n## Bypass por ruta alternativa\n\n```\n# Ruta protegida:\n/admin/usuarios    → requiere rol admin\n\n# Variantes que podrían no tener el mismo control:\n/ADMIN/usuarios\n/admin/usuarios/\n/admin/./usuarios\n/api/v1/../admin/usuarios\n/admin/usuarios%2e\n```\n\n## Bypass de controles basados en referrer o IP\n\n```http\n# Algunos sistemas solo permiten acceso "interno" por IP o header:\nX-Forwarded-For: 127.0.0.1\nX-Real-IP: 127.0.0.1\nX-Original-URL: /admin\nForwarded: for=127.0.0.1\n```\n\n## Estrategias de prevención (OWASP 2025)\n\n| Estrategia | Descripción |\n|---|---|\n| **Denegar por defecto** | Todo está prohibido salvo lo explícitamente permitido |\n| **Validación centralizada** | Un único módulo de autorización para toda la app |\n| **Logs y alertas** | Registrar fallos de acceso y alertar sobre patrones anómalos |\n| **Rate limiting** | Limitar intentos de enumeración |\n| **Tests de autorización** | Incluir pruebas de acceso cruzado en el pipeline CI/CD |\n| **Principio de mínimo privilegio** | Asignar solo los permisos estrictamente necesarios |\n\n## Herramienta: Burp Suite\n\nBurp Suite permite interceptar peticiones y modificar métodos HTTP, headers y parámetros en tiempo real, siendo la herramienta estándar para pruebas de control de acceso.\n\n```bash\n# Verificar métodos HTTP permitidos en un endpoint\ncurl -X OPTIONS https://api.ejemplo.com/admin/users -i\n```\n\n---\nCompleta el quiz y la actividad para ganar **250 puntos**.',
  2, 30, 250, TRUE
FROM course_modules cm WHERE cm.slug = 'escalada-privilegios-bypass'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿En qué consiste el bypass de control de acceso por método HTTP?',
  'Si una aplicación restringe un endpoint para POST pero no para GET, un atacante puede ejecutar la misma acción usando GET. Los controles de acceso deben aplicarse al path, independientemente del método HTTP.'
FROM laboratories l WHERE l.slug = 'bypass-controles-prevencion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué header HTTP puede usarse para suplantar una IP interna y hacer bypass de controles basados en IP?',
  'X-Forwarded-For es un header que algunos proxies usan para indicar la IP original del cliente. Si el backend confía en él sin validación, un atacante puede falsificarlo con 127.0.0.1 para parecer un cliente interno.'
FROM laboratories l WHERE l.slug = 'bypass-controles-prevencion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué principio de seguridad establece que todo acceso esté prohibido por defecto, salvo lo autorizado?',
  'El principio de "denegar por defecto" (deny by default / default deny) es la estrategia más efectiva contra el control de acceso roto. Si no hay una regla que permita explícitamente una acción, debe ser denegada.'
FROM laboratories l WHERE l.slug = 'bypass-controles-prevencion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué comando curl permite consultar qué métodos HTTP acepta un endpoint?',
  'curl -X OPTIONS hace una petición OPTIONS al servidor, que responde con el header Allow listando los métodos HTTP aceptados (GET, POST, PUT, DELETE, etc.) para ese endpoint.'
FROM laboratories l WHERE l.slug = 'bypass-controles-prevencion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Consulta los métodos HTTP permitidos en un endpoint con curl OPTIONS. Copia la respuesta generada.',
  'La petición OPTIONS es el método estándar para descubrir las capacidades de un endpoint. El servidor responde con un header Allow que lista los métodos habilitados, información valiosa en una prueba de penetración.'
FROM laboratories l WHERE l.slug = 'bypass-controles-prevencion'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Usar un método HTTP diferente (GET, PUT) para un endpoint que solo restringe POST', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Enviar más de 100 peticiones por segundo para colapsar el servidor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifrar el payload para evitar la inspección del WAF', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Cambiar el Content-Type de la petición a multipart/form-data', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'X-Forwarded-For', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Authorization', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Content-Type', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'User-Agent', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Denegar por defecto (deny by default)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Principio de mínima exposición', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Defensa en profundidad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Separación de privilegios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'curl -X OPTIONS https://api.ejemplo.com/admin/users -i', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'curl --list-methods https://api.ejemplo.com/admin/users', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'curl -H "Check-Methods: true" https://api.ejemplo.com/admin/users', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'curl --verbose GET https://api.ejemplo.com/admin/users', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Descubrimiento de métodos HTTP con OPTIONS',
  E'## Objetivo\n\nUsa curl para enviar una petición OPTIONS y descubrir qué métodos HTTP acepta un endpoint. Esta técnica es parte de la fase de reconocimiento en pruebas de control de acceso.\n\n## Instrucciones\n\n```bash\ncurl -X OPTIONS https://httpbin.org/get -i\n```\n\n**Desglose:**\n- `-X OPTIONS`: usa el método HTTP OPTIONS\n- `https://httpbin.org/get`: endpoint de prueba público\n- `-i`: incluye los headers HTTP en la salida\n\n**¿Qué buscar en la respuesta?**\n\nEl header `Allow` lista los métodos permitidos:\n```\nAllow: GET, POST, PUT, DELETE, OPTIONS, HEAD\n```\n\n**En una prueba real**, busca endpoints críticos como `/admin`, `/api/users`, `/api/delete` y verifica:\n1. ¿Qué métodos están habilitados?\n2. ¿Están todos bajo el mismo control de acceso?\n3. ¿Responde el servidor a métodos no estándar (TRACE, CONNECT)?\n\n```bash\n# También puedes probar métodos uno por uno:\ncurl -X DELETE https://api.objetivo.com/users/42 -H "Authorization: Bearer TU_TOKEN_USUARIO"\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'curl -X OPTIONS https://httpbin.org/get -i',
  '¡Excelente! Has consultado los métodos HTTP del endpoint. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'bypass-controles-prevencion' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A01 — intermedio)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (120, 200, 280, 250 puntos)
--   Preguntas:    20 nuevas (16 opción múltiple + 4 actividad)
--   Actividades:  4 nuevas
--   Puntos totales disponibles: 850
-- =============================================================================