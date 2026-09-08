-- =============================================================================
-- seed_owasp_a03_cadena_suministro.sql
-- Curso OWASP Top 10 2025 — A03: Fallos en la Cadena de Suministro de Software
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 3 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A03 — Fallos en la Cadena de Suministro de Software (avanzado)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a03-cadena-suministro',
  'OWASP A03: Fallos en la Cadena de Suministro de Software',
  'La categoría más votada como #1 en la encuesta comunitaria de OWASP 2025. Aprende por qué confiar en una dependencia, un pipeline de CI/CD o un paquete de terceros sin verificarlo puede comprometer todo tu sistema, con casos reales como SolarWinds, Log4Shell y los gusanos de npm de 2025.',
  'avanzado',
  TRUE,
  id
FROM users WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title        = EXCLUDED.title,
  description  = EXCLUDED.description,
  difficulty   = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- =============================================================================
-- MÓDULO 1: Gestión de Dependencias y Vulnerabilidades Conocidas
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'gestion-de-dependencias',
  'Gestión de Dependencias y Vulnerabilidades Conocidas',
  'Qué es un fallo de cadena de suministro, por qué la comunidad de seguridad lo votó como el riesgo #1 de 2025, y cómo auditar las dependencias de un proyecto con un Software Bill of Materials (SBOM).',
  1
FROM courses c WHERE c.slug = 'owasp-a03-cadena-suministro'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Qué es una Falla de Cadena de Suministro ───────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-es-una-falla-de-cadena-de-suministro',
  'Qué es una Falla de Cadena de Suministro',
  E'## El riesgo que la comunidad votó como el más urgente\n\nEn la encuesta comunitaria previa al OWASP Top 10 2025, exactamente el 50% de los participantes ubicó esta categoría en el puesto #1. Nació en el Top 10 de 2013 como "Uso de Componentes con Vulnerabilidades Conocidas", pero en 2025 su alcance creció: ya no es solo sobre dependencias vulnerables, sino sobre **todo el proceso** de construir, distribuir y actualizar software.\n\n## No es tu código, es todo lo que confías\n\nTu aplicación no es solo el código que escribiste. Es también:\n\n- Cada librería y framework que importaste (y las dependencias de esas dependencias).\n- El sistema operativo y el runtime sobre el que corre.\n- Las herramientas de tu pipeline de CI/CD.\n- Los repositorios y registries desde donde descargas paquetes.\n\nUn fallo en cualquiera de esos eslabones compromete tu aplicación exactamente igual que un fallo en tu propio código, aunque tu código sea perfecto.\n\n## Tres casos reales para entender el impacto\n\n| Caso | Qué pasó |\n|---|---|\n| **SolarWinds (2019)** | Un proveedor de confianza fue comprometido; su actualización de software, ya firmada y "legítima", distribuyó una puerta trasera a cerca de 18.000 organizaciones. |\n| **Log4Shell (2021)** | Una vulnerabilidad crítica en Log4j, una librería de logging usada por miles de aplicaciones Java sin que sus desarrolladores lo supieran, permitió ejecución remota de código a gran escala. |\n| **Gusanos de npm (2025)** | Ataques como Shai-Hulud publicaron versiones maliciosas de paquetes populares que, al instalarse, robaban credenciales y se auto-propagaban a otros paquetes del mismo desarrollador. |\n\nEn los tres casos, la organización afectada no tenía ningún bug en su propio código: confió en un eslabón externo que fue comprometido.\n\n## Por qué es tan difícil de detectar\n\nA diferencia de una inyección SQL, que se puede probar directamente contra la aplicación, un fallo de cadena de suministro depende de factores externos: qué versión exacta de cada dependencia usas, si esa versión sigue mantenida, y si alguien en algún punto de esa cadena fue comprometido. Por eso la prevención no es una prueba puntual, sino un proceso continuo de inventario y monitoreo.\n\n---\nCompleta el quiz para ganar **180 puntos**.',
  1, 25, 180, TRUE
FROM course_modules cm WHERE cm.slug = 'gestion-de-dependencias'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  'En la encuesta comunitaria previa al OWASP Top 10 2025, ¿qué porcentaje de participantes ubicó esta categoría en el puesto #1?',
  'Exactamente el 50% de los participantes la votó como el riesgo #1, la señal comunitaria más fuerte de todo el Top 10 2025.'
FROM laboratories l WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'Originalmente, en el Top 10 de 2013, ¿cómo se llamaba esta categoría?',
  'Se llamaba "Uso de Componentes con Vulnerabilidades Conocidas". Su alcance se amplió con los años hasta cubrir todo el proceso de construir, distribuir y actualizar software, no solo las dependencias vulnerables.'
FROM laboratories l WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'En el incidente de SolarWinds (2019), ¿cómo llegó la puerta trasera a las organizaciones afectadas?',
  'A través de una actualización de software legítima y firmada por un proveedor de confianza que había sido comprometido. Las organizaciones confiaron en la actualización precisamente porque venía de una fuente confiable.'
FROM laboratories l WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué hizo particularmente grave a la vulnerabilidad Log4Shell (2021)?',
  'Afectaba a Log4j, una librería de logging usada indirectamente por miles de aplicaciones Java, muchas veces sin que sus propios desarrolladores supieran que dependían de ella. Eso hizo que el impacto fuera masivo y difícil de rastrear.'
FROM laboratories l WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué un fallo de cadena de suministro es más difícil de detectar que una inyección SQL?',
  'Una inyección SQL se puede probar directamente contra la aplicación. Un fallo de cadena de suministro depende de factores externos y cambiantes (versiones, mantenimiento, integridad de terceros), por lo que requiere monitoreo continuo, no una prueba puntual.'
FROM laboratories l WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '50%', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '10%', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '25%', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '75%', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Uso de Componentes con Vulnerabilidades Conocidas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Configuración de Seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Diseño Inseguro', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Fallos de Integridad de Software', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'A través de una actualización legítima y firmada de un proveedor comprometido', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'A través de un correo de phishing enviado a cada organización', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Explotando una contraseña débil del administrador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Mediante un ataque de fuerza bruta a la red interna', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Afectaba a una librería usada indirectamente por miles de aplicaciones', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo afectaba a una aplicación específica y poco usada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Requería acceso físico al servidor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo afectaba a bases de datos NoSQL', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque depende de factores externos y cambiantes que requieren monitoreo continuo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque no existen herramientas para detectarla', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque solo ocurre en aplicaciones sin base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque es en realidad menos grave que una inyección SQL', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-una-falla-de-cadena-de-suministro' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Auditoría de Dependencias y SBOM ───────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'auditoria-de-dependencias-y-sbom',
  'Auditoría de Dependencias y SBOM',
  E'## Qué es un SBOM\n\nUn **SBOM (Software Bill of Materials)** es un inventario completo de todos los componentes que forman tu software: librerías directas, sus dependencias transitivas, versiones exactas y su origen. Es literalmente una "lista de ingredientes" para el software.\n\nSin un SBOM, responder a la pregunta "¿usamos en algún lugar la versión vulnerable de Log4j?" puede tomar días de búsqueda manual. Con un SBOM, es una consulta.\n\n## Dependencias transitivas: el problema invisible\n\nCuando instalas una librería, esa librería probablemente depende de otras, y esas de otras más. Rara vez revisas ese árbol completo:\n\n```\ntu-aplicacion\n  └── libreria-a@2.1.0\n        └── libreria-b@1.4.0        ← no la instalaste tú directamente\n              └── libreria-c@0.9.2  ← ni siquiera sabes que existe\n```\n\nUna vulnerabilidad en `libreria-c` te afecta igual, aunque nunca hayas escrito `import libreria-c` en tu código.\n\n## Herramientas de auditoría\n\n| Herramienta | Qué hace |\n|---|---|\n| `npm audit` | Compara las dependencias de un proyecto Node.js contra una base de datos de vulnerabilidades conocidas |\n| OWASP Dependency-Check | Analiza dependencias Java/.NET contra el National Vulnerability Database (NVD) |\n| OWASP Dependency-Track | Plataforma centralizada para monitorear SBOMs de múltiples proyectos a la vez |\n| retire.js | Detecta librerías JavaScript del lado del cliente con vulnerabilidades conocidas |\n\n## Auditando un proyecto Node.js\n\n```bash\nnpm audit --production\n```\n\nEste comando revisa únicamente las dependencias de producción (ignorando las de desarrollo, que no llegan al usuario final) y reporta vulnerabilidades conocidas junto con su severidad.\n\n## Buenas prácticas\n\n- Elegir deliberadamente qué versión de una dependencia usar, en vez de actualizar automáticamente a la última sin revisar.\n- Suscribirse a boletines de seguridad de las dependencias críticas del proyecto.\n- Eliminar dependencias que ya no se usan activamente: cada una es superficie de ataque adicional.\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  2, 30, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'gestion-de-dependencias'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué es un SBOM (Software Bill of Materials)?',
  'Es un inventario completo de todos los componentes de un software: dependencias directas, transitivas, versiones exactas y origen. Funciona como una "lista de ingredientes" que permite auditar rápidamente qué se está usando.'
FROM laboratories l WHERE l.slug = 'auditoria-de-dependencias-y-sbom'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué es una dependencia transitiva?',
  'Es una dependencia de una dependencia: una librería que tu proyecto usa indirectamente porque otra librería que sí instalaste la necesita, sin que tú la hayas elegido ni sepas necesariamente que existe.'
FROM laboratories l WHERE l.slug = 'auditoria-de-dependencias-y-sbom'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué hace la herramienta OWASP Dependency-Track?',
  'Es una plataforma centralizada para monitorear los SBOM de múltiples proyectos a la vez, permitiendo detectar en un solo lugar si alguno de ellos usa una versión vulnerable de algún componente.'
FROM laboratories l WHERE l.slug = 'auditoria-de-dependencias-y-sbom'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué "npm audit" se ejecuta a menudo con la bandera "--production"?',
  'Para revisar únicamente las dependencias que realmente llegan al usuario final, ignorando las herramientas de desarrollo (testing, linters) que nunca se despliegan en producción y no representan el mismo riesgo.'
FROM laboratories l WHERE l.slug = 'auditoria-de-dependencias-y-sbom'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa npm para auditar solo las dependencias de producción de un proyecto Node.js. Copia el comando que usarías.',
  'npm audit --production compara el árbol de dependencias de producción contra una base de datos de vulnerabilidades conocidas, sin ejecutar ni modificar nada — es una auditoría de solo lectura.'
FROM laboratories l WHERE l.slug = 'auditoria-de-dependencias-y-sbom'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un inventario completo de todos los componentes de un software', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Un firewall específico para aplicaciones web', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Un algoritmo de cifrado para proteger dependencias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Un tipo de prueba de penetración automatizada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Una dependencia de una dependencia, instalada indirectamente', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Una dependencia que se instala solo temporalmente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Una dependencia escrita en otro lenguaje de programación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Una dependencia ya eliminada del proyecto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Monitorea centralizadamente los SBOM de múltiples proyectos', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Genera automáticamente pruebas unitarias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Reemplaza la necesidad de un pipeline de CI/CD', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Cifra automáticamente todas las dependencias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Para enfocar la auditoría en lo que realmente llega al usuario final', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque en desarrollo no existen dependencias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque hace que el comando se ejecute más rápido siempre', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque es obligatorio por la licencia de npm', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Auditando dependencias de producción con npm',
  E'## Objetivo\n\nAprende el comando estándar para auditar las dependencias de producción de un proyecto Node.js en busca de vulnerabilidades conocidas.\n\n## Instrucciones\n\n```bash\nnpm audit --production\n```\n\n**Desglose:**\n- `npm audit`: compara el árbol de dependencias instalado contra una base de datos pública de vulnerabilidades\n- `--production`: excluye las dependencias de desarrollo (testing, linters, bundlers), que nunca llegan al usuario final\n\n**Salida típica:**\n\n```\nfound 3 vulnerabilities (1 low, 1 moderate, 1 high)\n  run \\`npm audit fix\\` to fix them\n```\n\nEste comando **no modifica nada por sí solo**: solo reporta. Corregir las vulnerabilidades es una decisión deliberada del equipo, normalmente con `npm audit fix` o actualizando la dependencia específica de forma manual.\n\nCopia el **comando exacto** que usarías para auditar solo las dependencias de producción y úsalo en el quiz.',
  'npm audit --production',
  '¡Correcto! Ya sabes auditar de forma segura las dependencias de un proyecto. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'auditoria-de-dependencias-y-sbom' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Endurecimiento del Pipeline CI/CD
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'endurecimiento-del-pipeline',
  'Endurecimiento del Pipeline CI/CD',
  'Cómo proteger el proceso de construcción y despliegue de software: separación de responsabilidades, verificación de integridad de artefactos y despliegues escalonados para limitar el impacto de un proveedor comprometido.',
  2
FROM courses c WHERE c.slug = 'owasp-a03-cadena-suministro'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Asegurando el Pipeline CI/CD ────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'asegurando-el-pipeline-cicd',
  'Asegurando el Pipeline CI/CD',
  E'## El pipeline como parte de la cadena de suministro\n\nSi tu aplicación está muy bien protegida pero cualquier persona puede modificar el pipeline que la construye y despliega, esa protección no sirve de mucho. El pipeline de CI/CD debería tener una seguridad **igual o mayor** a la de los sistemas que construye y despliega.\n\n## Separación de responsabilidades\n\nUn principio central: ninguna persona debería poder escribir código y promoverlo hasta producción **sin que otra persona lo revise**. Esto no es desconfianza personal, es una salvaguarda contra errores honestos y contra una cuenta comprometida.\n\n```\nDeveloper escribe código → Pull Request → Otra persona revisa y aprueba → CI/CD construye → Despliegue\n                                    ↑\n                    ningún paso se puede saltar sin registro\n```\n\n## Qué proteger específicamente\n\n| Elemento | Riesgo si no se protege |\n|---|---|\n| Repositorio de código | Ramas sin protección permiten subir cambios directos a producción sin revisión |\n| Credenciales del pipeline | Si están en texto plano en la configuración, cualquiera con acceso al repo las lee |\n| Registro de contenedores/artefactos | Un artefacto sin firmar puede ser reemplazado por uno malicioso |\n| Estaciones de trabajo de desarrolladores | Un equipo de desarrollo comprometido es una vía directa hacia el código fuente |\n\n## Verificando la firma de un commit\n\nLos commits firmados con GPG permiten confirmar que realmente los creó quien dice haberlos creado, no solo alguien que configuró el mismo nombre y correo en Git.\n\n```bash\ngit log --show-signature -1\n```\n\nEste comando muestra el último commit e indica si su firma GPG es válida, inválida o si no tiene firma.\n\n## Actualizaciones y rollouts escalonados\n\nDesplegar una actualización a todos los sistemas al mismo tiempo significa que, si el proveedor de esa actualización fue comprometido, el impacto es inmediato y total. Un despliegue escalonado (staged rollout o canary deployment) limita cuántos sistemas reciben la actualización antes de confirmar que es segura.\n\n---\nCompleta el quiz y la actividad para ganar **350 puntos**.',
  1, 35, 350, TRUE
FROM course_modules cm WHERE cm.slug = 'endurecimiento-del-pipeline'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué nivel de seguridad debería tener el pipeline de CI/CD respecto a los sistemas que construye y despliega?',
  'Igual o mayor. Si el pipeline es más débil que la aplicación que produce, un atacante simplemente ataca el pipeline en vez de la aplicación directamente.'
FROM laboratories l WHERE l.slug = 'asegurando-el-pipeline-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué garantiza el principio de separación de responsabilidades en un pipeline?',
  'Que ninguna persona pueda escribir código y promoverlo hasta producción sin que otra persona lo revise, protegiendo contra errores honestos y contra una cuenta individual comprometida.'
FROM laboratories l WHERE l.slug = 'asegurando-el-pipeline-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué riesgo específico corre un registro de contenedores o artefactos sin verificación de firmas?',
  'Un artefacto sin firmar puede ser reemplazado por una versión maliciosa sin que el sistema tenga forma de detectarlo, ya que no hay nada que confirme que el artefacto sigue siendo el original.'
FROM laboratories l WHERE l.slug = 'asegurando-el-pipeline-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué confirma un commit firmado con GPG que un commit normal no puede confirmar?',
  'Confirma que el commit realmente lo creó quien dice haberlo creado, en vez de solo alguien que configuró el mismo nombre y correo en Git, algo que cualquiera puede hacer sin firma.'
FROM laboratories l WHERE l.slug = 'asegurando-el-pipeline-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa git para revisar si el último commit del repositorio tiene una firma GPG válida. Copia el comando que usarías.',
  'git log --show-signature -1 muestra el commit más reciente junto con el estado de su firma: válida, inválida o ausente.'
FROM laboratories l WHERE l.slug = 'asegurando-el-pipeline-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Igual o mayor que la de los sistemas que construye', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Puede ser menor, ya que no es visible al público', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'No importa, solo cuenta la seguridad del producto final', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Depende únicamente del proveedor de nube usado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que ningún cambio llegue a producción sin revisión de otra persona', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que cada desarrollador tenga su propio servidor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el código se escriba en varios lenguajes distintos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que solo una persona tenga acceso a todo el sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Puede ser reemplazado por una versión maliciosa sin que nadie lo note', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ocupa más espacio de almacenamiento', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Se descarga más lentamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No es compatible con todos los sistemas operativos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que el autor real coincide con quien dice haberlo creado', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que el código no tiene errores de sintaxis', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el commit se hizo en horario laboral', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que el commit pasó todas las pruebas automatizadas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Verificando la firma de un commit con git',
  E'## Objetivo\n\nAprende a revisar si el commit más reciente de un repositorio tiene una firma GPG válida.\n\n## Instrucciones\n\n```bash\ngit log --show-signature -1\n```\n\n**Desglose:**\n- `git log`: muestra el historial de commits\n- `--show-signature`: incluye la verificación de la firma GPG de cada commit mostrado\n- `-1`: limita la salida a un solo commit, el más reciente\n\n**Salida típica con firma válida:**\n\n```\ngpg: Signature made ...\ngpg: Good signature from "Nombre Apellido <correo@ejemplo.com>"\ncommit a1b2c3d ...\n```\n\nSi la firma dice "BAD signature" o no aparece ninguna línea de gpg, ese commit no está firmado o su firma no es confiable — información valiosa antes de fusionar cambios críticos.\n\nCopia el **comando exacto** que usarías para revisar la firma del último commit y úsalo en el quiz.',
  'git log --show-signature -1',
  '¡Bien hecho! Ya sabes verificar la autenticidad de un commit antes de confiar en él. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'asegurando-el-pipeline-cicd' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Verificación de Integridad y Despliegues Escalonados ───────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'verificacion-de-integridad-y-despliegues-escalonados',
  'Verificación de Integridad y Despliegues Escalonados',
  E'## Confiar, pero verificar\n\nCuando descargas un paquete, una imagen de contenedor o un instalador, ¿cómo sabes que es exactamente el archivo que el autor original publicó, y no una versión alterada en el camino? La respuesta técnica es verificar su **hash criptográfico**.\n\n## Checksums: la huella digital de un archivo\n\nUn checksum (o hash) es un valor único calculado a partir del contenido de un archivo. Si un solo byte del archivo cambia, el checksum resultante es completamente distinto.\n\n```bash\nsha256sum paquete-descargado.tar.gz\n```\n\nEste comando calcula el hash SHA-256 del archivo. Lo comparas contra el hash que el autor original publicó (normalmente en su sitio oficial o en la página de releases): si coinciden, el archivo no fue alterado; si no coinciden, algo cambió en el camino y no deberías usarlo.\n\n## Firma vs checksum\n\n| Mecanismo | Qué confirma |\n|---|---|\n| Checksum (SHA-256, SHA-512) | Que el archivo no cambió respecto a una versión conocida |\n| Firma digital (GPG, firma de código) | Que el archivo, además de no haber cambiado, proviene realmente del autor que dice haberlo publicado |\n\nUn checksum solo protege si obtienes el valor de referencia por un canal distinto y confiable (por ejemplo, el sitio oficial del proyecto, no el mismo lugar de donde descargaste el archivo).\n\n## Despliegues escalonados (staged rollouts)\n\nEn vez de actualizar el 100% de los sistemas a la vez, un despliegue escalonado libera el cambio primero a un pequeño porcentaje ("canary"), observa si algo falla, y solo entonces continúa con el resto.\n\n```\nDespliegue directo:    100% de los sistemas reciben el cambio de inmediato\nDespliegue escalonado: 5% → observar → 25% → observar → 100%\n```\n\nSi un proveedor de confianza es comprometido y distribuye una actualización maliciosa, un despliegue escalonado limita cuántos de tus propios sistemas la reciben antes de que alguien note el problema.\n\n## Por qué esto cierra el ciclo de la cadena de suministro\n\nInventariar dependencias (Lab 2), proteger el pipeline (Lab 3) y verificar la integridad de cada artefacto (este laboratorio) son las tres capas que, juntas, hacen que confiar en un componente externo deje de ser un acto de fe y se convierta en algo verificable.\n\n---\nCompleta el quiz y la actividad para ganar **420 puntos**.',
  2, 40, 420, TRUE
FROM course_modules cm WHERE cm.slug = 'endurecimiento-del-pipeline'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué confirma un checksum (hash) como SHA-256 de un archivo descargado?',
  'Confirma que el archivo no cambió respecto a una versión de referencia conocida. Si un solo byte cambia, el hash resultante es completamente distinto.'
FROM laboratories l WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'Para que un checksum sea útil como verificación, ¿de dónde debe obtenerse el valor de referencia?',
  'De un canal distinto y confiable, como el sitio oficial del proyecto — nunca del mismo lugar de donde se descargó el archivo, porque si ese origen fue comprometido, también podría entregar un checksum falso que coincida con el archivo alterado.'
FROM laboratories l WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿En qué se diferencia una firma digital de un simple checksum?',
  'La firma digital confirma, además de que el archivo no cambió, que proviene realmente del autor que dice haberlo publicado. Un checksum por sí solo no dice nada sobre la identidad del autor.'
FROM laboratories l WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué ventaja ofrece un despliegue escalonado (staged rollout) frente a un despliegue directo al 100%?',
  'Limita cuántos sistemas reciben un cambio problemático antes de que alguien note el error, ya que primero se libera a un pequeño porcentaje y se observa antes de continuar con el resto.'
FROM laboratories l WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Calcula el hash SHA-256 de un archivo llamado paquete-descargado.tar.gz. Copia el comando que usarías.',
  'sha256sum calcula el hash SHA-256 de un archivo. Comparar ese valor contra el publicado por el autor original es la forma estándar de confirmar que un archivo descargado no fue alterado.'
FROM laboratories l WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que el archivo no cambió respecto a una versión conocida', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que el archivo está libre de virus', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el archivo se descargó desde un servidor seguro', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que el archivo es compatible con todos los sistemas operativos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'De un canal distinto y confiable, como el sitio oficial del proyecto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Del mismo archivo que se está verificando', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'No importa el origen, cualquier fuente sirve', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Del antivirus instalado localmente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'La firma también confirma la identidad del autor, el checksum no', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No hay diferencia real entre ambos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El checksum es más fuerte criptográficamente que cualquier firma', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La firma solo funciona en archivos comprimidos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Limita cuántos sistemas reciben un cambio problemático antes de detectarlo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Hace que el despliegue sea siempre más rápido', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de pruebas automatizadas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Reduce el costo del hosting', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Verificando integridad con sha256sum',
  E'## Objetivo\n\nAprende a calcular el checksum de un archivo para compararlo contra el valor publicado por su autor original.\n\n## Instrucciones\n\n```bash\nsha256sum paquete-descargado.tar.gz\n```\n\n**Salida típica:**\n\n```\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  paquete-descargado.tar.gz\n```\n\nEse valor hexadecimal es la huella digital del archivo. Si el autor original publicó, por ejemplo en la página de releases de su proyecto, ese mismo valor, tienes confirmación de que tu copia es idéntica al original. Si el valor no coincide, el archivo fue alterado en algún punto de la descarga o distribución.\n\nCopia el **comando exacto** que usarías para calcular el checksum de paquete-descargado.tar.gz y úsalo en el quiz.',
  'sha256sum paquete-descargado.tar.gz',
  '¡Excelente! Ya sabes verificar la integridad de un archivo antes de confiar en él. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'verificacion-de-integridad-y-despliegues-escalonados' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A03 — avanzado)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (180, 280, 350, 420 puntos)
--   Preguntas:    20 nuevas (17 opción múltiple + 3 actividad)
--   Actividades:  3 nuevas
--   Puntos totales disponibles: 1230
-- =============================================================================