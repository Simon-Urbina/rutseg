-- =============================================================================
-- seed_owasp_a08_integridad.sql
-- Curso OWASP Top 10 2025 — A08: Fallos de Integridad de Software y Datos
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 2 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A08 — Fallos de Integridad de Software y Datos (avanzado)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a08-integridad-software',
  'OWASP A08: Fallos de Integridad de Software y Datos',
  'Aprende qué pasa cuando una aplicación trata código o datos no confiables como si fueran válidos: actualizaciones sin firmar, pipelines de CI/CD que confían ciegamente en fuentes externas, y el riesgo real de la deserialización insegura, una de las vías más directas hacia la ejecución remota de código.',
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
-- MÓDULO 1: Verificación de Integridad y Confianza en el Código
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'verificacion-de-integridad',
  'Verificación de Integridad y Confianza en el Código',
  'Qué distingue un fallo de integridad de un fallo de cadena de suministro, y por qué confiar en una actualización o un dato sin verificar su origen es un riesgo de ejecución, no solo de distribución.',
  1
FROM courses c WHERE c.slug = 'owasp-a08-integridad-software'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Qué es un Fallo de Integridad de Software y Datos ──────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-es-un-fallo-de-integridad',
  'Qué es un Fallo de Integridad de Software y Datos',
  E'## Un nivel más específico que la cadena de suministro\n\nEsta categoría es cercana a A03 (Fallos en la Cadena de Suministro), pero opera en un nivel más concreto: mientras A03 se enfoca en todo el proceso de construir y distribuir software, A08 se enfoca en el momento exacto en que **una pieza de código o de datos se trata como confiable sin haberlo verificado**.\n\n## La pregunta central\n\n¿Tu sistema verifica que lo que está a punto de ejecutar, cargar o procesar es realmente lo que dice ser, y no algo que fue alterado en el camino?\n\nSi la respuesta es "no lo verifica, simplemente confía", existe un fallo de integridad, sin importar qué tan buena sea la intención original del diseño.\n\n## Ejemplo real: dominios de soporte externos\n\nUna empresa usa un proveedor externo de soporte técnico y configura un registro DNS como `soporte.miempresa.com` apuntando al proveedor. El problema: todas las cookies del dominio `miempresa.com`, incluidas las de sesión autenticada, viajan también hacia ese subdominio externo. Cualquiera con acceso a la infraestructura del proveedor de soporte puede robar esas cookies y secuestrar sesiones de usuarios reales.\n\nAquí no hubo ningún "hackeo" técnico: la empresa simplemente confió en la integridad de un tercero sin aislar ese límite de confianza.\n\n## Tres superficies típicas de este fallo\n\n| Superficie | Riesgo |\n|---|---|\n| Actualizaciones de software/firmware | Se instalan sin verificar que vienen realmente del fabricante |\n| Paquetes de dependencias | Se instalan desde una fuente no oficial "porque no encontré la versión en el registro habitual" |\n| Datos serializados de un cliente | Se deserializan asumiendo que el cliente no los manipuló |\n\n## Por qué esto no se resuelve "revisando el código una vez"\n\nUn fallo de integridad no vive en una función específica que se pueda auditar de una vez. Vive en la ausencia de un mecanismo estructural (firma, checksum, validación de origen) que debería existir en cada punto donde el sistema decide confiar en algo externo.\n\n---\nCompleta el quiz para ganar **180 puntos**.',
  1, 25, 180, TRUE
FROM course_modules cm WHERE cm.slug = 'verificacion-de-integridad'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿En qué se diferencia A08 (Fallos de Integridad) de A03 (Cadena de Suministro)?',
  'A03 abarca todo el proceso de construir y distribuir software. A08 opera en un nivel más específico: el momento exacto en que algo se trata como confiable sin haberse verificado.'
FROM laboratories l WHERE l.slug = 'que-es-un-fallo-de-integridad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuál es la pregunta central que define si existe un fallo de integridad?',
  'Si el sistema verifica que lo que va a ejecutar, cargar o procesar es realmente lo que dice ser, o simplemente confía sin comprobarlo.'
FROM laboratories l WHERE l.slug = 'que-es-un-fallo-de-integridad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'En el ejemplo del subdominio de soporte externo, ¿cuál fue la causa real del riesgo?',
  'Que las cookies del dominio principal, incluidas las de sesión, viajaban también hacia el subdominio del proveedor externo, sin que existiera un aislamiento del límite de confianza entre ambos.'
FROM laboratories l WHERE l.slug = 'que-es-un-fallo-de-integridad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué un fallo de integridad no se puede corregir "revisando el código una vez"?',
  'Porque no vive en una función específica auditable, sino en la ausencia de un mecanismo estructural (firma, checksum, validación de origen) en cada punto donde el sistema decide confiar en algo externo.'
FROM laboratories l WHERE l.slug = 'que-es-un-fallo-de-integridad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Cuál de estas es una superficie típica de fallo de integridad según el laboratorio?',
  'Instalar un paquete de dependencias desde una fuente no oficial porque no se encontró en el registro habitual — exactamente el tipo de decisión que salta la verificación de origen.'
FROM laboratories l WHERE l.slug = 'que-es-un-fallo-de-integridad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'A08 se enfoca en el momento de confiar sin verificar, A03 en todo el proceso', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Son exactamente la misma categoría con nombres distintos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'A08 solo aplica a bases de datos NoSQL', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'A03 fue reemplazada por completo por A08 en 2025', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Si el sistema verifica el origen de lo que va a ejecutar o procesar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Si el sistema usa un lenguaje de programación compilado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Si el sistema tiene más de un año en producción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Si el sistema tiene más de mil usuarios activos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Las cookies del dominio principal viajaban sin aislamiento hacia el subdominio', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El proveedor de soporte no usaba contraseñas seguras', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El registro DNS estaba mal escrito técnicamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El subdominio no tenía certificado TLS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque falta un mecanismo estructural en cada punto de confianza', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque los fallos de integridad no dejan rastro en los logs', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque ocurren solo en tiempo de compilación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque solo afectan a sistemas heredados (legacy)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Instalar un paquete desde una fuente no oficial por conveniencia', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usar una contraseña de más de 12 caracteres', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Activar la autenticación multifactor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Configurar un firewall en la red interna', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-un-fallo-de-integridad' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Actualizaciones sin Firmar y CI/CD sin Verificación ────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'actualizaciones-sin-firmar-y-cicd',
  'Actualizaciones sin Firmar y CI/CD sin Verificación',
  E'## El problema de las actualizaciones automáticas\n\nMuchos dispositivos y aplicaciones se actualizan solos, sin intervención del usuario. Esa comodidad se convierte en un riesgo grave si el mecanismo de actualización no verifica que el nuevo código realmente viene de quien dice venir.\n\n## Caso real: firmware sin firmar\n\nMuchos routers domésticos, decodificadores y dispositivos IoT históricamente no verifican firmas criptográficas en sus actualizaciones de firmware. Si un atacante logra interceptar o suplantar ese proceso, puede distribuir una actualización maliciosa que el dispositivo instalará sin sospechar nada, ya que "parece" una actualización normal.\n\nEste tipo de fallo es particularmente grave porque, a diferencia de una aplicación web, muchos de estos dispositivos no tienen un mecanismo fácil de remediar más allá de esperar una futura versión que corrija el problema.\n\n## CI/CD que confía sin verificar\n\nUn pipeline de CI/CD que descarga dependencias, imágenes base o artefactos de terceros sin verificar su firma o checksum está exactamente en la misma situación que el router sin firmware firmado: confía en que lo que descargó es legítimo, sin ninguna forma de comprobarlo.\n\n## Verificando una firma GPG de un archivo descargado\n\nCuando un proyecto publica tanto un archivo como su firma GPG por separado, puedes verificar la integridad y autenticidad antes de usarlo:\n\n```bash\ngpg --verify archivo.tar.gz.sig archivo.tar.gz\n```\n\nSi la firma es válida, GPG confirma que el archivo no fue alterado y que fue firmado con la clave privada correspondiente a la clave pública que tienes importada. Si la firma no es válida o no se puede verificar, el archivo no debería usarse.\n\n## La regla general\n\nCualquier proceso automatizado (una actualización, un pipeline, una integración con un tercero) que instale o ejecute algo sin un paso explícito de verificación de integridad está, por diseño, confiando ciegamente. Esa confianza ciega es exactamente lo que esta categoría busca eliminar.\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  2, 30, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'verificacion-de-integridad'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué muchos dispositivos IoT y routers son un blanco frecuente de este tipo de fallo?',
  'Porque históricamente no verifican firmas criptográficas en sus actualizaciones de firmware, y además suelen carecer de un mecanismo fácil de remediar el problema una vez descubierto.'
FROM laboratories l WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué situación de riesgo comparte un pipeline de CI/CD con un router de firmware sin firmar?',
  'Ambos confían en que lo que descargan (una actualización, una dependencia, una imagen) es legítimo, sin tener ninguna forma explícita de comprobarlo.'
FROM laboratories l WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué confirma una verificación exitosa con "gpg --verify"?',
  'Que el archivo no fue alterado y que fue firmado con la clave privada correspondiente a la clave pública que se tiene importada — confirmando tanto integridad como autenticidad del origen.'
FROM laboratories l WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  'Según la regla general del laboratorio, ¿qué caracteriza a un proceso automatizado que "confía ciegamente"?',
  'Que instala o ejecuta algo (una actualización, una dependencia, un artefacto) sin un paso explícito de verificación de integridad, exactamente lo que esta categoría de OWASP busca eliminar.'
FROM laboratories l WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa gpg para verificar la firma de un archivo llamado archivo.tar.gz contra su firma archivo.tar.gz.sig. Copia el comando que usarías.',
  'gpg --verify compara la firma contra el archivo y la clave pública importada, confirmando si el archivo es auténtico y no fue alterado.'
FROM laboratories l WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No verifican firmas de firmware y son difíciles de remediar después', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque siempre usan contraseñas muy débiles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque no tienen dirección IP propia', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque solo funcionan con Bluetooth', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Confían en el origen de lo descargado sin verificarlo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ambos requieren electricidad para funcionar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Ambos se actualizan una vez al año', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Ambos requieren una pantalla para configurarse', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que el archivo es auténtico y no fue alterado', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que el archivo no contiene ningún virus', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que el archivo se descomprimirá sin errores', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que el archivo es compatible con todos los sistemas operativos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Instala o ejecuta algo sin verificar su integridad', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Se ejecuta más lento que un proceso manual', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Requiere más memoria RAM de la esperada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Genera más logs de lo normal', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Verificando una firma GPG',
  E'## Objetivo\n\nAprende el comando estándar para verificar la firma digital de un archivo antes de confiar en él.\n\n## Instrucciones\n\n```bash\ngpg --verify archivo.tar.gz.sig archivo.tar.gz\n```\n\n**Desglose:**\n- `gpg --verify`: verifica una firma digital\n- `archivo.tar.gz.sig`: el archivo de firma, publicado por separado por el autor\n- `archivo.tar.gz`: el archivo original que se quiere validar\n\n**Salida con firma válida:**\n\n```\ngpg: Good signature from "Nombre del Proyecto <releases@proyecto.org>"\n```\n\n**Salida con firma inválida o archivo alterado:**\n\n```\ngpg: BAD signature from "Nombre del Proyecto <releases@proyecto.org>"\n```\n\nUna firma "BAD" es una señal de alarma inmediata: el archivo no coincide con lo que el autor firmó originalmente, y no debería instalarse ni ejecutarse bajo ninguna circunstancia.\n\nCopia el **comando exacto** que usarías para verificar archivo.tar.gz contra su firma y úsalo en el quiz.',
  'gpg --verify archivo.tar.gz.sig archivo.tar.gz',
  '¡Correcto! Ya sabes verificar la autenticidad de un archivo antes de confiar en él. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'actualizaciones-sin-firmar-y-cicd' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Deserialización Insegura
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'deserializacion-insegura',
  'Deserialización Insegura',
  'Qué es serializar y deserializar datos, por qué hacerlo con datos no confiables es una de las vías más directas hacia la ejecución remota de código, y cómo prevenirlo en el diseño de una aplicación.',
  2
FROM courses c WHERE c.slug = 'owasp-a08-integridad-software'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Qué es la Deserialización Insegura ─────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'que-es-la-deserializacion-insegura',
  'Qué es la Deserialización Insegura',
  E'## Serializar: convertir un objeto en algo transportable\n\nLa serialización convierte una estructura de datos en memoria (un objeto, con su estado y su tipo) en una secuencia de bytes que se puede guardar en disco o enviar por red. La deserialización hace el proceso inverso: reconstruye el objeto original a partir de esos bytes.\n\n```\nObjeto en memoria --[serializar]--> bytes/texto --[deserializar]--> Objeto reconstruido\n```\n\nEsto es completamente normal y necesario. El problema aparece cuando esos bytes vienen de un **cliente no confiable**, y el sistema los deserializa asumiendo que representan exactamente lo que dicen representar.\n\n## Por qué es tan peligroso\n\nAlgunos formatos de serialización nativos (como los de Java o Python `pickle`) no solo guardan datos: pueden guardar información sobre **qué código ejecutar** al reconstruir el objeto. Si un atacante controla los bytes que se van a deserializar, puede construir una secuencia maliciosa que, al reconstruirse, ejecute código arbitrario en el servidor — sin necesitar ninguna otra vulnerabilidad adicional.\n\n## Reconociendo datos serializados\n\nLos objetos serializados de Java, por ejemplo, comienzan con una secuencia de bytes característica que en base64 suele empezar con las letras "rO0". Reconocer estas firmas es el primer paso, puramente defensivo, para identificar dónde una aplicación podría estar deserializando datos de forma riesgosa.\n\n```bash\necho "rO0ABXQABGRhdGE=" | base64 -d | xxd | head -1\n```\n\nEste comando decodifica una cadena base64 de ejemplo y muestra sus primeros bytes en hexadecimal — una forma segura de **inspeccionar**, sin ejecutar nada, qué formato tiene un dato antes de decidir si es seguro procesarlo.\n\n## Un escenario típico\n\nUn frontend en React se comunica con microservicios backend. Para mantener el estado "inmutable" entre peticiones, el equipo decide serializar el estado del usuario y pasarlo de ida y vuelta con cada petición. Un atacante que identifica el formato de serialización nativo del backend puede, en el peor de los casos, sustituir ese estado por una secuencia maliciosa diseñada para ejecutarse al deserializarse.\n\n---\nCompleta el quiz y la actividad para ganar **350 puntos**.',
  1, 35, 350, TRUE
FROM course_modules cm WHERE cm.slug = 'deserializacion-insegura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué hace la serialización de un objeto?',
  'Convierte una estructura de datos en memoria, con su estado y tipo, en una secuencia de bytes que se puede guardar en disco o enviar por red.'
FROM laboratories l WHERE l.slug = 'que-es-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuándo se convierte la deserialización en un riesgo de seguridad?',
  'Cuando los bytes a deserializar provienen de un cliente no confiable, y el sistema los procesa asumiendo que representan exactamente lo que dicen representar, sin validarlos.'
FROM laboratories l WHERE l.slug = 'que-es-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué algunos formatos de serialización nativos son especialmente peligrosos frente a datos no confiables?',
  'Porque pueden guardar información sobre qué código ejecutar al reconstruir el objeto, permitiendo a un atacante construir una secuencia maliciosa que ejecute código arbitrario al deserializarse.'
FROM laboratories l WHERE l.slug = 'que-es-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué logra decodificar y examinar en hexadecimal los primeros bytes de un dato serializado?',
  'Permite identificar de forma puramente defensiva qué formato tiene un dato antes de decidir si es seguro procesarlo, sin necesidad de ejecutar ni deserializar nada.'
FROM laboratories l WHERE l.slug = 'que-es-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Decodifica la cadena base64 "rO0ABXQABGRhdGE=" y muestra sus primeros bytes en hexadecimal. Copia el comando que usarías.',
  'Decodificar en base64 y visualizar en hexadecimal permite inspeccionar de forma segura el formato de un dato serializado, sin ejecutar ni deserializar nada.'
FROM laboratories l WHERE l.slug = 'que-es-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Convierte un objeto en memoria en una secuencia de bytes transportable', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cifra un objeto para que nadie pueda leerlo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina un objeto de la memoria de forma segura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Comprime un archivo para ocupar menos espacio', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Cuando los bytes vienen de un cliente no confiable y no se validan', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cuando el objeto es demasiado grande', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cuando se usa un formato de texto como JSON', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Solo cuando ocurre en el frontend', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Pueden guardar información sobre qué código ejecutar al reconstruirse', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ocupan más espacio en disco que otros formatos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Son más lentos de procesar que JSON', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No son compatibles con microservicios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Identificar de forma segura el formato antes de procesarlo', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ejecutar automáticamente el objeto serializado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifrar automáticamente los datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Enviar el dato a un servidor remoto para análisis', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Inspeccionando bytes serializados de forma segura',
  E'## Objetivo\n\nAprende a inspeccionar, sin ejecutar nada, el formato binario de un dato antes de decidir si procesarlo es seguro.\n\n## Instrucciones\n\n```bash\necho "rO0ABXQABGRhdGE=" | base64 -d | xxd | head -1\n```\n\n**Desglose:**\n- `echo "..."`: imprime la cadena base64 de ejemplo\n- `base64 -d`: la decodifica a sus bytes originales\n- `xxd`: muestra esos bytes en formato hexadecimal legible\n- `head -1`: limita la salida a la primera línea\n\n**Qué observar:**\n\nLos primeros bytes de un objeto serializado de Java tienen una firma reconocible. Detectar esa firma en un flujo de datos que tu aplicación va a procesar es una señal de alarma: significa que en algún punto se está recibiendo un objeto serializado nativo desde una fuente externa, exactamente el escenario que este laboratorio busca que sepas reconocer.\n\nEsta técnica es puramente de **inspección**: solo estás mirando bytes, en ningún momento estás deserializando ni ejecutando el contenido.\n\nCopia el **comando exacto** que usarías para decodificar e inspeccionar esos bytes y úsalo en el quiz.',
  'echo "rO0ABXQABGRhdGE=" | base64 -d | xxd | head -1',
  '¡Excelente! Ya sabes inspeccionar datos serializados sin ejecutarlos, la base de un análisis defensivo. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'que-es-la-deserializacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Previniendo la Deserialización Insegura ────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'previniendo-la-deserializacion-insegura',
  'Previniendo la Deserialización Insegura',
  E'## La primera regla: evitarla por completo cuando se pueda\n\nLa defensa más efectiva contra la deserialización insegura no es "hacerla con más cuidado", es **no aceptar formatos de serialización nativos desde fuentes no confiables en absoluto**. Si el cliente solo necesita enviar datos simples (texto, números, listas), un formato de datos puro como JSON no tiene la capacidad de "ejecutar código" al procesarse — es solo texto estructurado.\n\n```\nFormato de serialización nativo:  puede incluir instrucciones de reconstrucción de objetos y tipos\nFormato de datos puro (JSON):     solo describe valores, sin lógica de ejecución asociada\n```\n\n## Cuando no se puede evitar del todo\n\nSi el sistema realmente necesita deserializar datos complejos de una fuente externa, OWASP recomienda varias capas:\n\n- Firmar digitalmente los datos serializados y verificar la firma antes de deserializar, para detectar cualquier manipulación.\n- Ejecutar la deserialización con privilegios mínimos, en un entorno aislado que limite el daño si algo sale mal.\n- Mantener actualizadas las librerías de serialización, ya que muchas vulnerabilidades conocidas de deserialización son parches disponibles que simplemente no se aplicaron.\n\n## Revisión de código y configuración\n\nUn proceso de revisión que incluya explícitamente la pregunta "¿este endpoint deserializa algo que viene del cliente, y con qué formato?" durante el desarrollo, en vez de descubrirlo durante una auditoría de seguridad posterior, reduce drásticamente la ventana de exposición.\n\n## Conectando con el resto del curso\n\nEste laboratorio cierra el círculo de A08: verificar el origen de una actualización (Lab 2) y evitar deserializar datos no confiables (este laboratorio) son dos aplicaciones concretas del mismo principio — nunca tratar como válido algo que no se ha verificado, sin importar cuán natural parezca el flujo de datos.\n\n---\nCompleta el quiz para ganar **400 puntos**.',
  2, 40, 400, TRUE
FROM course_modules cm WHERE cm.slug = 'deserializacion-insegura'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la defensa más efectiva contra la deserialización insegura, según el laboratorio?',
  'Evitar por completo aceptar formatos de serialización nativos desde fuentes no confiables, usando en su lugar un formato de datos puro como JSON, que no tiene capacidad de ejecutar código al procesarse.'
FROM laboratories l WHERE l.slug = 'previniendo-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué JSON es más seguro que un formato de serialización nativo frente a datos no confiables?',
  'Porque JSON solo describe valores (texto, números, listas), sin ninguna lógica de ejecución asociada, a diferencia de formatos nativos que pueden incluir instrucciones de reconstrucción de objetos.'
FROM laboratories l WHERE l.slug = 'previniendo-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  'Cuando no se puede evitar deserializar datos complejos, ¿qué medida recomienda OWASP como capa adicional?',
  'Firmar digitalmente los datos serializados y verificar esa firma antes de deserializar, para detectar cualquier manipulación previa a la reconstrucción del objeto.'
FROM laboratories l WHERE l.slug = 'previniendo-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué pregunta debería incluirse explícitamente en la revisión de código para prevenir este fallo a tiempo?',
  '¿Este endpoint deserializa algo que viene del cliente, y con qué formato? Hacer esta pregunta durante el desarrollo evita descubrir el problema recién en una auditoría de seguridad posterior.'
FROM laboratories l WHERE l.slug = 'previniendo-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Qué principio común comparten verificar el origen de una actualización y evitar deserializar datos no confiables?',
  'Nunca tratar como válido algo que no se ha verificado, sin importar cuán natural o cotidiano parezca el flujo de datos en cuestión.'
FROM laboratories l WHERE l.slug = 'previniendo-la-deserializacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Evitar formatos de serialización nativos desde fuentes no confiables', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cifrar todos los datos serializados sin excepción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Aumentar el tamaño máximo permitido del payload', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Usar siempre el mismo lenguaje de programación en todo el sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'JSON solo describe valores, sin lógica de ejecución asociada', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'JSON siempre viaja cifrado por defecto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'JSON solo puede usarse en aplicaciones móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'JSON ocupa menos espacio siempre que cualquier otro formato', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Firmar los datos y verificar la firma antes de deserializar', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Deshabilitar por completo el logging de la operación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Aumentar el tiempo de espera (timeout) del endpoint', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Permitir el acceso anónimo al endpoint', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Este endpoint deserializa algo del cliente, ¿con qué formato?', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '¿Cuántas líneas de código tiene este endpoint?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '¿Cuánto tiempo tomó desarrollar este endpoint?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '¿Qué color de fondo tiene la interfaz asociada?', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Nunca tratar como válido algo que no se ha verificado', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usar siempre el mismo proveedor de nube', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Reducir el número de servidores en producción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Documentar el código con más comentarios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'previniendo-la-deserializacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A08 — avanzado)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (180, 280, 350, 400 puntos)
--   Preguntas:    20 nuevas (18 opción múltiple + 2 actividad)
--   Actividades:  2 nuevas
--   Puntos totales disponibles: 1210
-- =============================================================================