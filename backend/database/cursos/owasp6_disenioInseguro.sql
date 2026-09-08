-- =============================================================================
-- seed_owasp_a06_diseno_inseguro.sql
-- Curso OWASP Top 10 2025 — A06: Diseño Inseguro
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 2 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A06 — Diseño Inseguro (avanzado)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a06-diseno-inseguro',
  'OWASP A06: Diseño Inseguro',
  'Aprende por qué un diseño inseguro no se puede corregir con una implementación perfecta: la protección nunca se pensó desde el inicio. Modelado de amenazas, lógica de negocio rota, y los principios de diseño seguro que todo sistema debería tener antes de escribir la primera línea de código.',
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
-- MÓDULO 1: Amenazas de Diseño y Modelado de Amenazas
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'amenazas-de-diseno-y-modelado',
  'Amenazas de Diseño y Modelado de Amenazas',
  'La diferencia entre un fallo de diseño y un fallo de implementación, y cómo la lógica de negocio (no solo el código) puede ser explotada si nadie pensó en el "mal uso" del sistema, solo en su uso previsto.',
  1
FROM courses c WHERE c.slug = 'owasp-a06-diseno-inseguro'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Diseño Inseguro vs Implementación Insegura ─────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'diseno-inseguro-vs-implementacion-insegura',
  'Diseño Inseguro vs Implementación Insegura',
  E'## Dos tipos de fallo con causas y arreglos distintos\n\nEs tentador tratar toda vulnerabilidad como "un bug que hay que arreglar", pero OWASP distingue dos categorías con raíces completamente distintas:\n\n| | Fallo de implementación | Fallo de diseño |\n|---|---|---|\n| Causa | Un error al escribir el código de un control que sí se pensó | El control de seguridad necesario **nunca se diseñó** |\n| Ejemplo | Una consulta SQL sin parametrizar | Un flujo de recuperación de cuenta que nunca consideró que alguien podría abusarlo |\n| Se arregla con | Corregir esa parte del código | Rediseñar el flujo completo, no solo parchar una línea |\n\n**La idea central de esta categoría:** un diseño inseguro no se puede arreglar con una implementación perfecta. Si nadie diseñó un control contra cierto ataque, no importa cuán bien escrito esté el código: el control simplemente no existe.\n\n## Ejemplo real: preguntas de seguridad\n\nUn flujo clásico de recuperación de cuenta pregunta "¿cuál es el nombre de tu primera mascota?". El estándar NIST 800-63B, el OWASP ASVS y el propio OWASP Top 10 **prohíben explícitamente** este mecanismo, no porque esté mal implementado, sino porque está mal diseñado desde la raíz: más de una persona puede conocer la respuesta, así que nunca fue una prueba confiable de identidad, sin importar qué tan bien se codifique.\n\nLa solución no es "escribir mejor código para las preguntas de seguridad". Es eliminar el mecanismo y diseñar uno distinto.\n\n## Modelado de amenazas: pensar como atacante antes de construir\n\nEl **threat modeling** (modelado de amenazas) es la práctica de, durante el diseño, preguntarse sistemáticamente: ¿quién podría querer atacar esto, cómo lo haría, y qué necesitamos para evitarlo? Se aplica especialmente a los flujos críticos: autenticación, control de acceso, lógica de negocio central.\n\n```\nDiseño tradicional:    Construir → Lanzar → Esperar el primer incidente → Reaccionar\nDiseño con modelado:   Modelar amenazas → Diseñar controles → Construir → Lanzar\n```\n\n## Por qué esta categoría bajó dos puestos en 2025\n\nOWASP reporta una mejora real de la industria en threat modeling y diseño seguro desde que la categoría se introdujo en 2021 — evidencia de que pensar en el diseño, no solo en el código, sí reduce el riesgo con el tiempo.\n\n---\nCompleta el quiz para ganar **180 puntos**.',
  1, 25, 180, TRUE
FROM course_modules cm WHERE cm.slug = 'amenazas-de-diseno-y-modelado'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la diferencia central entre un fallo de diseño y un fallo de implementación?',
  'En el fallo de implementación, el control de seguridad sí se pensó pero se codificó mal. En el fallo de diseño, el control necesario nunca se diseñó, así que no existe sin importar qué tan bien esté escrito el código.'
FROM laboratories l WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué un diseño inseguro no se puede arreglar con una implementación perfecta?',
  'Porque si el control necesario nunca se diseñó, no hay nada que "implementar bien": la protección simplemente no forma parte del sistema, independientemente de la calidad del código.'
FROM laboratories l WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Por qué las "preguntas de seguridad" para recuperar una cuenta están prohibidas por estándares como NIST 800-63B?',
  'Porque más de una persona puede conocer la respuesta (familiares, redes sociales), así que nunca fueron una prueba confiable de identidad — es un fallo de diseño, no algo que un mejor código pueda corregir.'
FROM laboratories l WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué pregunta busca responder el modelado de amenazas durante la fase de diseño?',
  'Quién podría querer atacar el sistema, cómo lo haría, y qué controles se necesitan para evitarlo — antes de construir, no después de un incidente.'
FROM laboratories l WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  '¿Por qué la categoría de Diseño Inseguro bajó de posición en el Top 10 2025 respecto a ediciones anteriores?',
  'Porque OWASP reporta una mejora real de la industria en threat modeling y prácticas de diseño seguro desde que la categoría se introdujo en 2021, no porque el riesgo haya dejado de importar.'
FROM laboratories l WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'En el de diseño, el control necesario nunca se pensó', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No hay ninguna diferencia real entre ambos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El de diseño siempre es más fácil de corregir', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El de implementación solo ocurre en bases de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque la protección necesaria no forma parte del sistema en absoluto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque los desarrolladores nunca revisan su propio código', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque los frameworks modernos no lo permiten', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque el código perfecto no existe', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque más de una persona puede conocer la respuesta', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque son demasiado difíciles de recordar para el usuario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque ocupan demasiado espacio en la base de datos', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque no funcionan en dispositivos móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Quién atacaría el sistema, cómo, y qué controles se necesitan', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cuánto costará el proyecto en total', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Qué lenguaje de programación usar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Cuántos servidores se necesitan', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque la industria ha mejorado en threat modeling y diseño seguro', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque ya no representa ningún riesgo real', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque se eliminó del Top 10 por error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque ahora se mide de una forma que oculta los casos reales', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'diseno-inseguro-vs-implementacion-insegura' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- ── Lab 2: Lógica de Negocio Rota ──────────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'logica-de-negocio-rota',
  'Lógica de Negocio Rota',
  E'## Cuando el sistema hace exactamente lo que se le pidió que hiciera\n\nUn ataque de lógica de negocio no explota un bug técnico: explota una regla de negocio que nadie protegió contra el mal uso. El sistema funciona "correctamente" según su código — el problema es que nadie diseñó ese código pensando en un usuario malicioso.\n\n## Caso 1: reservas sin límite real\n\nUna cadena de cines permite reservas grupales con descuento, con un máximo de 15 asistentes antes de requerir un depósito. Un atacante que analiza este flujo podría intentar reservar 600 asientos repartidos en varias peticiones de menos de 15 cada una, evitando el control de depósito y causando una pérdida masiva de ingresos.\n\n```json\n{"reserva_id": "A1", "asientos": 14, "requiere_deposito": false}\n{"reserva_id": "A2", "asientos": 14, "requiere_deposito": false}\n{"reserva_id": "A3", "asientos": 14, "requiere_deposito": false}\n```\n\nCada petición individual es "válida" según la regla escrita (menos de 15 asientos). El problema es que nadie pensó en limitar el total acumulado por usuario o por sesión.\n\n## Caso 2: bots de reventa (scalping)\n\nUn sitio de comercio electrónico lanza un producto de edición limitada. Sin protección anti-bot ni reglas de dominio que detecten compras inauténticas (por ejemplo, compras completadas en menos de un segundo desde que el producto se hizo disponible), bots automatizados agotan el stock antes de que cualquier persona real pueda comprar.\n\n## Probando los límites de una regla de negocio\n\nUna forma segura de practicar cómo se prueban estos límites es enviar valores que la interfaz normal nunca enviaría, y observar cómo responde el backend:\n\n```bash\ncurl -X POST https://httpbin.org/post -d "cantidad=-5&precio_total=100"\n```\n\nEste comando envía una cantidad negativa a un endpoint de prueba seguro (httpbin.org simplemente devuelve lo que recibió, no procesa ningún pedido real). En una aplicación real, si el backend no valida que "cantidad" sea un número positivo, un valor negativo podría, dependiendo de la lógica interna, generar un total a favor del atacante en vez de en su contra.\n\n## La lección de diseño\n\nNinguna de estas fallas se arregla añadiendo una validación aislada. Se arreglan diseñando la regla de negocio completa: ¿cuál es el límite real que importa (por reserva, por usuario, por día)?, ¿qué patrones de uso son imposibles para una persona real?, ¿qué pasa si alguien envía valores que la interfaz nunca enviaría?\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  2, 30, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'amenazas-de-diseno-y-modelado'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué caracteriza a un ataque de lógica de negocio, a diferencia de un ataque técnico como la inyección SQL?',
  'El sistema hace exactamente lo que su código dice que debe hacer — no hay ningún bug técnico. El problema es que nadie diseñó esa regla de negocio pensando en un usuario malicioso.'
FROM laboratories l WHERE l.slug = 'logica-de-negocio-rota'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  'En el caso del cine con el límite de 15 asistentes, ¿cuál fue el error real de diseño?',
  'No limitar el total acumulado de asientos por usuario o por sesión. Cada petición individual cumplía la regla de "menos de 15 asistentes", pero nadie protegió contra repetir esa petición muchas veces.'
FROM laboratories l WHERE l.slug = 'logica-de-negocio-rota'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué señal de comportamiento ayuda a detectar bots de reventa (scalping) en una tienda en línea?',
  'Compras completadas en tiempos imposibles para una persona real, como en menos de un segundo desde que el producto se hizo disponible — un patrón de uso que solo un sistema automatizado puede lograr.'
FROM laboratories l WHERE l.slug = 'logica-de-negocio-rota'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué httpbin.org es un destino seguro para practicar el envío de valores inusuales como una cantidad negativa?',
  'Porque httpbin.org simplemente devuelve lo que recibió, sin procesar ningún pedido ni transacción real — permite practicar la técnica sin afectar ningún sistema de producción.'
FROM laboratories l WHERE l.slug = 'logica-de-negocio-rota'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Envía por POST a httpbin.org un cuerpo con una cantidad negativa y un precio total, simulando cómo se probaría el límite de una regla de negocio. Copia el comando que usarías.',
  'Enviar valores que la interfaz normal nunca produciría (como una cantidad negativa) es una técnica estándar para probar si el backend valida correctamente los límites de una regla de negocio.'
FROM laboratories l WHERE l.slug = 'logica-de-negocio-rota'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El sistema ejecuta correctamente su código, pero la regla nunca contempló el mal uso', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Siempre involucra una consulta a la base de datos mal escrita', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo puede ocurrir en aplicaciones bancarias', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Requiere siempre acceso administrativo previo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No limitar el total acumulado por usuario o sesión', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No cifrar los datos de la reserva', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'No usar HTTPS en el formulario de reserva', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No validar el formato del correo electrónico', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Compras completadas en un tiempo imposible para una persona real', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Compras hechas desde dispositivos móviles', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Compras realizadas en horario nocturno', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Compras pagadas con tarjeta de crédito', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque solo devuelve lo recibido, sin procesar pedidos reales', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque pertenece a la misma empresa que RutSeg', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque no acepta peticiones POST', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque requiere autenticación previa', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Probando los límites de una regla de negocio con curl',
  E'## Objetivo\n\nPractica de forma segura cómo se envían valores fuera de lo esperado para probar si un backend valida correctamente los límites de una regla de negocio.\n\n## Instrucciones\n\n```bash\ncurl -X POST https://httpbin.org/post -d "cantidad=-5&precio_total=100"\n```\n\n**Desglose:**\n- `-X POST`: usa el método HTTP POST\n- `-d "cantidad=-5&precio_total=100"`: envía datos de formulario con una cantidad negativa\n- `https://httpbin.org/post`: endpoint de prueba público que solo refleja lo que recibió\n\n**Qué observar:**\n\nhttpbin.org te devolverá exactamente los datos que enviaste, incluida la cantidad negativa, sin ninguna validación. Esa es justamente la pregunta que debes hacerte sobre un sistema real: ¿el backend rechaza este valor, o lo procesa como si fuera válido?\n\nEn una aplicación real bien diseñada, cualquier endpoint que reciba una cantidad debería validar explícitamente que sea un número positivo dentro de un rango razonable, tanto en el Model (formato) como en el Service (regla de negocio).\n\nCopia el **comando exacto** que usarías para enviar esta prueba y úsalo en el quiz.',
  'curl -X POST https://httpbin.org/post -d "cantidad=-5&precio_total=100"',
  '¡Correcto! Ya sabes cómo se prueban los límites de una regla de negocio de forma segura. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'logica-de-negocio-rota' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: Principios de Diseño Seguro
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'principios-de-diseno-seguro',
  'Principios de Diseño Seguro',
  'Fallar de forma segura, defensa en profundidad, y cómo construir un ciclo de vida de desarrollo que integre la seguridad desde la primera conversación sobre requisitos, no como un paso final antes del lanzamiento.',
  2
FROM courses c WHERE c.slug = 'owasp-a06-diseno-inseguro'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Fallar de Forma Segura y Defensa en Profundidad ────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'fail-secure-y-defensa-en-profundidad',
  'Fallar de Forma Segura y Defensa en Profundidad',
  E'## Fail closed vs fail open\n\nCuando algo sale mal (un servicio no responde, una verificación falla, ocurre una excepción), el sistema tiene que decidir qué hacer. Hay dos posturas de diseño opuestas:\n\n| Postura | Qué hace ante un fallo | Ejemplo |\n|---|---|---|\n| **Fail open** (fallar abierto) | Permite el acceso por defecto | Un control de acceso que, si no puede verificar el permiso, deja pasar la petición "para no bloquear al usuario" |\n| **Fail closed / fail secure** (fallar cerrado) | Deniega el acceso por defecto | Ese mismo control, si no puede verificar el permiso, rechaza la petición aunque eso signifique una mala experiencia momentánea |\n\nOWASP es explícito: **fail open es casi siempre la decisión incorrecta** en un contexto de seguridad. Es preferible que un usuario legítimo tenga que reintentar, a que un fallo técnico se convierta silenciosamente en una puerta abierta.\n\n## Defensa en profundidad\n\nNingún control de seguridad es infalible por sí solo. La defensa en profundidad consiste en colocar **varias capas independientes**, de modo que si una falla, las siguientes todavía protegen el sistema:\n\n```\nCapa 1: Validación en el frontend       (UX, no seguridad real)\nCapa 2: Autenticación en el backend\nCapa 3: Autorización por endpoint\nCapa 4: Validación de datos en el Service\nCapa 5: Restricciones a nivel de base de datos\n```\n\nSi un atacante logra saltarse la Capa 1 (trivial, ocurre constantemente), las capas 2 a 5 todavía deben detenerlo.\n\n## Segregación de inquilinos (tenants)\n\nEn un sistema donde múltiples clientes u organizaciones comparten la misma infraestructura, la segregación garantiza que los datos de un inquilino nunca sean accesibles para otro, incluso si hay un error en algún punto del código. Esto va más allá del control de acceso normal: es una capa de aislamiento estructural.\n\n## Observando el comportamiento ante un error\n\n```bash\ncurl -o /dev/null -s -w "%{http_code}\\n" https://httpbin.org/status/500\n```\n\nEste comando fuerza una respuesta de error 500 en un endpoint de prueba y solo imprime el código de estado HTTP resultante. En un sistema real, vale la pena preguntarse: cuando ocurre un error como este en un endpoint protegido, ¿la aplicación cae hacia "acceso denegado" (fail closed) o hacia "acceso permitido" (fail open)?\n\n---\nCompleta el quiz y la actividad para ganar **330 puntos**.',
  1, 35, 330, TRUE
FROM course_modules cm WHERE cm.slug = 'principios-de-diseno-seguro'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué hace un sistema diseñado con la postura "fail open" cuando un control de seguridad falla?',
  'Permite el acceso por defecto, priorizando no bloquear al usuario por encima de la seguridad — la postura que OWASP considera casi siempre incorrecta.'
FROM laboratories l WHERE l.slug = 'fail-secure-y-defensa-en-profundidad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué OWASP recomienda "fail closed" en vez de "fail open" para controles de seguridad?',
  'Porque es preferible que un usuario legítimo tenga que reintentar a que un fallo técnico se convierta silenciosamente en una puerta abierta para cualquiera.'
FROM laboratories l WHERE l.slug = 'fail-secure-y-defensa-en-profundidad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué logra la defensa en profundidad frente a un único control de seguridad muy robusto?',
  'Si una capa falla o es superada, las siguientes capas independientes todavía protegen el sistema — a diferencia de depender de un único punto de falla, por robusto que parezca.'
FROM laboratories l WHERE l.slug = 'fail-secure-y-defensa-en-profundidad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué garantiza la segregación de inquilinos (tenants) en un sistema multi-cliente?',
  'Que los datos de un inquilino nunca sean accesibles para otro, incluso si ocurre un error en algún punto del código — es una capa de aislamiento estructural, más allá del control de acceso normal.'
FROM laboratories l WHERE l.slug = 'fail-secure-y-defensa-en-profundidad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Fuerza una respuesta de error 500 contra httpbin.org e imprime solo el código de estado HTTP resultante. Copia el comando que usarías.',
  'curl -o /dev/null -s -w descarta el cuerpo de la respuesta y solo muestra el código HTTP, una forma rápida de observar cómo responde un sistema ante una condición de error forzada.'
FROM laboratories l WHERE l.slug = 'fail-secure-y-defensa-en-profundidad'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Permite el acceso por defecto', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Bloquea el acceso a todos los usuarios sin excepción', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Reinicia automáticamente el servidor', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Envía una alerta automática al equipo de seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Porque un fallo técnico no debe convertirse en una puerta abierta silenciosa', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Porque fail closed siempre es más rápido de implementar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Porque fail open no está soportado por ningún framework', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Porque fail closed reduce el costo de infraestructura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Si una capa falla, las siguientes todavía protegen el sistema', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Hace que el sistema sea más rápido de desarrollar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de pruebas de seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Garantiza que nunca ocurrirá ningún error', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Que los datos de un inquilino nunca sean accesibles para otro', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Que todos los inquilinos paguen la misma tarifa', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Que la infraestructura sea más barata de mantener', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Que todos los inquilinos compartan la misma cuenta de administrador', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Observando el código HTTP ante un error forzado',
  E'## Objetivo\n\nAprende a forzar y observar una respuesta de error para razonar sobre si un sistema falla abierto o cerrado.\n\n## Instrucciones\n\n```bash\ncurl -o /dev/null -s -w "%{http_code}\\n" https://httpbin.org/status/500\n```\n\n**Desglose:**\n- `https://httpbin.org/status/500`: endpoint de prueba que siempre responde con el código HTTP que le pidas en la URL\n- `-o /dev/null`: descarta el cuerpo de la respuesta, no lo necesitas para esta prueba\n- `-s`: modo silencioso\n- `-w "%{http_code}\\n"`: imprime únicamente el código de estado HTTP recibido\n\n**Qué preguntarte con la salida:**\n\nEl comando confirma que el servidor devolvió 500. En un sistema real, la pregunta importante no es solo "¿qué código HTTP devuelve?", sino "¿qué hizo el sistema *antes* de devolver ese código?" — ¿denegó el acceso al recurso protegido (fail closed) o lo entregó de todas formas y solo falló al registrar el evento (fail open)?\n\nCopia el **comando exacto** que usarías para forzar un error 500 e imprimir solo el código HTTP y úsalo en el quiz.',
  'curl -o /dev/null -s -w "%{http_code}\n" https://httpbin.org/status/500',
  '¡Bien hecho! Ya sabes cómo observar el comportamiento de un sistema ante una condición de error forzada. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fail-secure-y-defensa-en-profundidad' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Patrones de Diseño Seguro y el Ciclo de Vida Seguro ────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'patrones-de-diseno-seguro-y-sdl',
  'Patrones de Diseño Seguro y el Ciclo de Vida Seguro',
  E'## Tres momentos donde se decide la seguridad de un sistema\n\nOWASP organiza el diseño seguro en tres partes que deben ocurrir en orden:\n\n1. **Recolección de requisitos y gestión de recursos:** negociar con el negocio qué nivel de protección necesita cada dato (confidencialidad, integridad, disponibilidad) antes de escribir una sola línea de código.\n2. **Diseño seguro:** integrar el modelado de amenazas en las sesiones de planificación, no como un trámite aparte.\n3. **Ciclo de vida de desarrollo seguro (SDL):** mantener esa disciplina durante todo el proyecto, con post-mortems de incidentes que retroalimenten el propio proceso de diseño.\n\n## Bibliotecas de patrones de diseño seguro\n\nUn "paved road" (camino pavimentado) es un conjunto de componentes y patrones ya revisados por seguridad que el equipo puede reutilizar, en vez de que cada desarrollador resuelva el mismo problema (autenticación, manejo de sesiones, validación) de cero y con distinto nivel de cuidado cada vez.\n\n```\nSin camino pavimentado:  cada equipo implementa su propio login  → 5 implementaciones, 5 niveles de riesgo distintos\nCon camino pavimentado:  todos usan el mismo módulo de auth revisado → 1 implementación, 1 nivel de riesgo conocido\n```\n\n## Casos de uso y casos de mal uso\n\nDiseñar pensando solo en el "camino feliz" (cómo un usuario legítimo completa una tarea) deja fuera la otra mitad de la ecuación. Escribir explícitamente **casos de mal uso** ("¿qué pasa si alguien envía esto mismo mil veces por segundo?", "¿qué pasa si el usuario A intenta esto sobre el recurso del usuario B?") durante el diseño obliga a decidir el comportamiento correcto antes de que ocurra en producción.\n\n## OWASP SAMM como marco de madurez\n\nEl **Software Assurance Maturity Model (SAMM)** de OWASP ayuda a una organización a medir en qué nivel de madurez está su proceso de seguridad (desde prácticas ad-hoc hasta un programa institucionalizado) y a priorizar qué mejorar primero, en vez de intentar implementar todo a la vez.\n\n## Cerrando el círculo con esta categoría\n\nEl diseño inseguro no se resuelve con una herramienta ni con una librería: se resuelve con una **cultura** que trata la seguridad como una conversación temprana y continua, no como una revisión final antes de lanzar.\n\n---\nCompleta el quiz para ganar **400 puntos**.',
  2, 40, 400, TRUE
FROM course_modules cm WHERE cm.slug = 'principios-de-diseno-seguro'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  'Según el marco de OWASP, ¿qué debe ocurrir antes de escribir la primera línea de código de una funcionalidad crítica?',
  'Negociar con el negocio qué nivel de protección necesita cada dato en términos de confidencialidad, integridad y disponibilidad — la fase de recolección de requisitos y gestión de recursos.'
FROM laboratories l WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué ventaja ofrece un "camino pavimentado" (paved road) de componentes de seguridad reutilizables?',
  'Evita que cada equipo implemente por su cuenta el mismo problema de seguridad (como autenticación) con distinto nivel de cuidado, concentrando el riesgo en una sola implementación ya revisada.'
FROM laboratories l WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué son los "casos de mal uso" en el diseño de una funcionalidad?',
  'Escenarios explícitos de cómo alguien podría abusar de una funcionalidad (repetirla mil veces por segundo, aplicarla sobre el recurso de otro usuario), diseñados junto a los casos de uso normales, no como una idea posterior.'
FROM laboratories l WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Para qué sirve el OWASP SAMM (Software Assurance Maturity Model)?',
  'Para medir en qué nivel de madurez está el proceso de seguridad de una organización y priorizar qué mejorar primero, en vez de intentar implementar todas las prácticas de seguridad a la vez.'
FROM laboratories l WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'multiple_choice',
  'Según el cierre de esta categoría, ¿con qué se resuelve realmente el diseño inseguro?',
  'Con una cultura que trata la seguridad como una conversación temprana y continua durante todo el proyecto, no con una herramienta puntual ni con una revisión final antes de lanzar.'
FROM laboratories l WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Negociar el nivel de protección necesario para cada dato', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Elegir el proveedor de nube más barato', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Contratar un equipo de marketing', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Definir el logo de la aplicación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Concentra el riesgo en una sola implementación ya revisada', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Hace que cada equipo trabaje totalmente aislado', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Elimina la necesidad de threat modeling', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Reduce el número de servidores necesarios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Escenarios explícitos de cómo alguien podría abusar de la funcionalidad', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Errores de sintaxis comunes al programar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Reportes de errores enviados por los usuarios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Casos de prueba unitaria sin relación con seguridad', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Medir la madurez del proceso de seguridad y priorizar mejoras', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cifrar automáticamente todo el tráfico de red', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Generar certificados TLS automáticamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Reemplazar al equipo de seguridad con un modelo de IA', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q5
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Con una cultura de seguridad temprana y continua', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Con un firewall de última generación', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Con una auditoría única antes de lanzar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Con una licencia de software antivirus', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id WHERE l.slug = 'patrones-de-diseno-seguro-y-sdl' AND q.question_order = 5
ON CONFLICT (question_id, option_order) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A06 — avanzado)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos (180, 280, 330, 400 puntos)
--   Preguntas:    20 nuevas (18 opción múltiple + 2 actividad)
--   Actividades:  2 nuevas
--   Puntos totales disponibles: 1190
-- =============================================================================