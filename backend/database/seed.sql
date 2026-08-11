-- Seed de datos iniciales para la plataforma de ciberseguridad
-- Ejecutar en Supabase SQL Editor después del schema.sql

-- Usuario admin con consentimiento de tratamiento de datos registrado
-- Credenciales:
--   admin → admin@cybersec.com / Admin1234!

INSERT INTO users (username, email, password_hash, role, privacy_accepted_at, privacy_policy_version)
VALUES
  ('admin', 'admin@cybersec.com', '$2b$10$abcdefghijklmnopqrstuvwx.yzABCDEFGHIJKLMNOPQRSTUVWXYZ12', 'admin', now(), '1.0')
ON CONFLICT (username) DO UPDATE SET
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  role = EXCLUDED.role,
  privacy_accepted_at = COALESCE(users.privacy_accepted_at, EXCLUDED.privacy_accepted_at),
  privacy_policy_version = COALESCE(users.privacy_policy_version, EXCLUDED.privacy_policy_version);

-- Curso principal
INSERT INTO courses (slug, title, description, difficulty, is_published, created_by)
SELECT
  'fundamentos-ciberseguridad',
  'Fundamentos de Ciberseguridad',
  'Aprende los conceptos base de la ciberseguridad: reconocimiento, escaneo, extracción de credenciales en Windows y explotación de vulnerabilidades web.',
  'principiante',
  TRUE,
  id
FROM users
WHERE username = 'admin'
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty = EXCLUDED.difficulty,
  is_published = EXCLUDED.is_published;

-- Módulo 1: Reconocimiento y Escaneo
INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'reconocimiento-escaneo', 'Reconocimiento y Escaneo', 'Herramientas y técnicas para descubrir activos, puertos y servicios en una red.', 1
FROM courses c
WHERE c.slug = 'fundamentos-ciberseguridad'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  position = EXCLUDED.position;

-- Lab 1: Introducción a Nmap
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'introduccion-nmap',
  'Introducción a Nmap',
  E'## ¿Qué es Nmap?\n\nImagina que llegas a un vecindario nuevo y quieres saber qué casas están habitadas, cuáles tienen la puerta sin seguro y qué tipo de negocio funciona en cada una antes de tocar. Eso es justo lo que hace **Nmap** (*Network Mapper*) en una red: recorre un rango de direcciones, descubre qué equipos (hosts) están "en casa" (activos), qué "puertas" (puertos) tienen abiertas, y qué "servicio" atiende detrás de cada una. Es la herramienta de escaneo de redes más usada en ciberseguridad, tanto para atacar como para defender.\n\n## Cómo "toca la puerta": el modelo OSI\n\nPara entender en qué nivel trabaja Nmap, ayuda pensar en cómo viaja la información en una red usando el **modelo OSI**: una forma de dividir todo lo que pasa cuando dos computadores se comunican en 7 capas, cada una responsable de una tarea distinta — como un edificio de correos donde cada piso hace un trabajo diferente antes de que la carta llegue a su destinatario.\n\nPara este lab nos importan cuatro pisos de ese edificio:\n\n| Capa OSI | Qué hace | Analogía postal |\n|---|---|---|\n| Capa 2 – Enlace | Identifica dispositivos en la misma red local por su dirección física (MAC) | El repartidor que conoce cada casa de *su* cuadra |\n| Capa 3 – Red | Enruta paquetes entre redes distintas usando direcciones IP | El código postal que decide a qué ciudad va el paquete |\n| Capa 4 – Transporte | Abre "puertos" para que cada servicio reciba lo suyo | El número de apartamento dentro del edificio |\n| Capa 7 – Aplicación | El contenido real: HTTP, SSH, lo que el servicio dice | La carta que finalmente lees |\n\nCuando Nmap **descubre hosts** —es decir, cuando todavía ni siquiera sabe si hay alguien en esa dirección— trabaja principalmente en la **capa 3 (Red)**: envía paquetes ICMP, TCP o UDP a una IP y espera respuesta, igual que tocar el timbre de una casa sin saber aún quién vive ahí. Solo después, al escanear puertos y versiones, sube a las capas 4 y 7 para averiguar qué "apartamento" (puerto) responde y qué "idioma" (servicio) habla.\n\n## Flags esenciales\n\nCon esa idea clara, estos son los flags que más vas a usar:\n\n| Flag | Función |\n|------|---------|\n| `-sV` | Detecta la versión del servicio en cada puerto (como escuchar la voz de quien abre la puerta para reconocerlo) |\n| `-sn` | Ping scan: solo pregunta si el host está activo, sin tocar puertos (tocar el timbre, sin entrar) |\n| `-O`  | Intenta detectar el sistema operativo |\n| `-A`  | Modo agresivo: combina detección de SO, versiones y scripts |\n| `-p-` | Escanea los 65 535 puertos posibles, no solo los más comunes |\n\n## Ejemplo básico\n\n```bash\nnmap -sV 10.10.10.1\n```\n\nEste comando le pide a Nmap que primero confirme que `10.10.10.1` está activo (capa 3), luego revise sus puertos más comunes (capa 4), y finalmente identifique qué software corre detrás de cada uno (capa 7) — todo en una sola pasada.\n\n---\nCompleta el quiz y la actividad para ganar **100 puntos**.',
  1, 20, 100, TRUE
FROM course_modules cm
WHERE cm.slug = 'reconocimiento-escaneo'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas del Lab 1
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Qué significan las siglas Nmap?', 'Nmap es la abreviatura de "Network Mapper", una herramienta de código abierto para exploración de redes.'
FROM laboratories l WHERE l.slug = 'introduccion-nmap'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Qué flag de Nmap detecta la versión del servicio que corre en cada puerto?', 'El flag -sV activa la detección de versiones. Nmap envía sondas específicas para identificar el software.'
FROM laboratories l WHERE l.slug = 'introduccion-nmap'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué flag realiza únicamente un ping scan sin escanear puertos?', '-sn (antes -sP) solo verifica si el host responde, como tocar el timbre; no llega a revisar si alguna puerta (puerto) está abierta.'
FROM laboratories l WHERE l.slug = 'introduccion-nmap'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿En qué capa del modelo OSI opera principalmente Nmap al descubrir hosts?', 'Nmap opera en la capa 3 (Red): usa paquetes ICMP, TCP o UDP para preguntar si hay alguien en esa IP, igual que tocar el timbre de una casa sin saber aún quién vive ahí. Descubrir hosts no necesita llegar hasta la capa 7 (Aplicación); eso viene después, al escanear puertos y versiones.'
FROM laboratories l WHERE l.slug = 'introduccion-nmap'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Ejecuta el comando de Nmap que escanea versiones de servicios sobre el host objetivo 10.10.10.1. Copia la respuesta generada y selecciónala aquí.', 'El comando correcto es: nmap -sV 10.10.10.1'
FROM laboratories l WHERE l.slug = 'introduccion-nmap'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones para preguntas 1-4 del Lab 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Network Mapper', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Node Monitoring App', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Net Map Analyzer', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Null Map Protocol', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones para pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '-sV', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '-sn', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '-O', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '-A', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones para pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '-sn', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '-sV', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '-O', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '-p-', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones para pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Capa 3 - Red', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Capa 7 - Aplicación', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Capa 2 - Enlace', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Capa 4 - Transporte', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad para pregunta 5 del Lab 1
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Escaneo de versiones con Nmap',
  E'## Objetivo\n\nYa sabes que Nmap primero toca la puerta (capa 3) para saber si hay alguien en casa. Ahora vas a ir un paso más allá: usa Nmap para escanear el host `10.10.10.1` y detectar las versiones de los servicios que corren en sus puertos.\n\n## Instrucciones\n\n1. Abre una terminal.\n2. Ejecuta el siguiente comando:\n\n```bash\nnmap -sV 10.10.10.1\n```\n\n3. Copia la **respuesta generada** que aparecerá aquí y pégala en la pregunta del quiz.\n\n> **Pista:** el flag `-sV` activa la detección de versiones.',
  'nmap -sV 10.10.10.1',
  '¡Correcto! Has ejecutado el escaneo. Copia esta respuesta y úsala en la pregunta del quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'introduccion-nmap' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Lab 2: Reconocimiento Web con Gobuster y curl
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'reconocimiento-web',
  'Reconocimiento Web con Gobuster y curl',
  E'## Reconocimiento web\n\nYa sabes tocar la puerta de un host y ver qué "apartamentos" (puertos) tiene abiertos. Ahora vas a entrar a uno de esos apartamentos —el que atiende en el puerto 80, el servidor web— y explorar el edificio por dentro: ¿qué habitaciones (directorios) existen?, ¿hay una oficina de administración (`/admin`) sin cerrar?, ¿quedó algún archivo de configuración tirado en el pasillo?\n\n## Gobuster: tocar cada puerta del pasillo\n\n**Gobuster** hace fuerza bruta: toma una lista larga de nombres típicos de habitaciones (`/admin`, `/backup`, `/login`, etc.) y toca cada una para ver cómo responde el servidor.\n\n```bash\ngobuster dir -u http://10.10.10.1 -w /usr/share/wordlists/dirb/common.txt\n```\n\nCada intento recibe un **código de respuesta HTTP**, que es literalmente cómo responde la puerta:\n\n| Código | Qué significa | Analogía |\n|---|---|---|\n| `200` | La habitación existe y está abierta | Alguien abre la puerta |\n| `301` / `302` | La habitación existe, pero se mudó | "Ya no vivo aquí, ahora estoy en..." |\n| `403` | La habitación existe, pero no puedes entrar | La puerta está con seguro |\n| `404` | No existe ninguna habitación con ese nombre | Nadie responde, no hay puerta ahí |\n\nGobuster solo te dice **cuáles puertas existen** — no te dice nada de quién vive detrás de cada una.\n\n## curl: leer la placa en la puerta\n\nCada puerta HTTP trae una especie de placa con datos del dueño: son los **headers** de la respuesta. El header `Server`, por ejemplo, suele delatar qué software corre el servidor (por ejemplo `Apache/2.4.41`) — información valiosa para un atacante, porque una versión vieja puede tener vulnerabilidades conocidas.\n\n```bash\ncurl -I http://10.10.10.1\n```\n\nEl flag `-I` le pide a curl que solo lea la "placa" (los headers), sin abrir la puerta completa (sin descargar el contenido de la página).\n\n---\nCompleta el quiz y las actividades para ganar **150 puntos**.',
  2, 25, 150, TRUE
FROM course_modules cm
WHERE cm.slug = 'reconocimiento-escaneo'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas del Lab 2
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Qué hace Gobuster en modo "dir"?', 'Gobuster en modo dir realiza fuerza bruta sobre rutas de un servidor web usando un diccionario de palabras.'
FROM laboratories l WHERE l.slug = 'reconocimiento-web'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Qué código de respuesta HTTP indica que un recurso no fue encontrado?', 'El código 404 Not Found significa que no hay ninguna "puerta" con ese nombre: el servidor no encontró el recurso solicitado.'
FROM laboratories l WHERE l.slug = 'reconocimiento-web'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué header HTTP suele revelar el software y versión del servidor web?', 'El header "Server" es como la placa en la puerta: expone el software del servidor (ej: Apache/2.4.41), una fuente clave de información para un atacante.'
FROM laboratories l WHERE l.slug = 'reconocimiento-web'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'activity_response', 'Enumera los directorios del servidor objetivo usando Gobuster. Copia la respuesta generada.', 'gobuster dir -u http://10.10.10.1 -w /usr/share/wordlists/dirb/common.txt'
FROM laboratories l WHERE l.slug = 'reconocimiento-web'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Inspecciona los headers HTTP del servidor objetivo con curl. Copia la respuesta generada.', 'curl -I http://10.10.10.1'
FROM laboratories l WHERE l.slug = 'reconocimiento-web'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones para Lab 2 pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Fuerza bruta de directorios y archivos en un servidor web', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Escanea puertos abiertos en un host', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Intercepta tráfico de red', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Explota vulnerabilidades SQL', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones para Lab 2 pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '404', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '200', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '301', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '500', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones para Lab 2 pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Server', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Content-Type', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Accept', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Authorization', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividades para Lab 2 preguntas 4 y 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Enumeración de directorios con Gobuster',
  E'## Objetivo\n\nDescubre directorios ocultos en el servidor web objetivo usando Gobuster.\n\n## Instrucciones\n\n```bash\ngobuster dir -u http://10.10.10.1 -w /usr/share/wordlists/dirb/common.txt\n```\n\nCopia la **respuesta generada** y úsala en la pregunta del quiz.',
  'gobuster dir -u http://10.10.10.1 -w /usr/share/wordlists/dirb/common.txt',
  '¡Bien! Has enumerado el servidor. Copia esta respuesta y úsala en la pregunta del quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 4
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Inspección de headers HTTP',
  E'## Objetivo\n\nUsa `curl` para ver los headers de respuesta del servidor y obtener información sobre su tecnología.\n\n## Instrucciones\n\n```bash\ncurl -I http://10.10.10.1\n```\n\nEl flag `-I` hace una petición HEAD: solo descarga los headers, no el cuerpo de la respuesta.\n\nCopia la **respuesta generada** y úsala en la pregunta del quiz.',
  'curl -I http://10.10.10.1',
  '¡Correcto! Has inspeccionado los headers. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'reconocimiento-web' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Lab 3: Nikto - Escáner de vulnerabilidades web
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'nikto-web-scanner',
  'Nikto: Escáner de Vulnerabilidades Web',
  E'## ¿Qué es Nikto?\n\nGobuster te dijo qué puertas existen. **Nikto** va más allá: es como un inspector de seguridad que entra a cada habitación y revisa si el detector de humo funciona, si la cerradura es vieja y vulnerable, o si dejaron una ventana sin seguro. Es un escáner de código abierto que analiza servidores web en busca de más de 6700 archivos/programas potencialmente peligrosos, versiones desactualizadas y problemas de configuración.\n\n## Headers de seguridad: los "seguros" de la puerta\n\nAsí como una puerta puede tener o no cadena, mirilla y cerrojo, una respuesta HTTP puede traer o no headers de seguridad que protegen al visitante. Uno de los que Nikto revisa es **X-Frame-Options**.\n\nSin ese header, un atacante puede montar tu sitio dentro de un `<iframe>` invisible sobre una página falsa —como pegar un vidrio con un botón falso justo encima de tu puerta real— y cuando la víctima cree estar haciendo clic en el botón falso, en realidad hace clic en tu página real por debajo. Esto se llama **clickjacking**. `X-Frame-Options` es el cartel que dice "nadie más puede poner mi puerta detrás de su vidrio".\n\n## Flags esenciales\n\n| Flag | Función |\n|------|---------|\n| `-h` | Especifica el host objetivo |\n| `-p` | Puerto (por defecto 80) |\n| `-o` | Guarda el resultado en un archivo |\n| `-Tuning` | Filtra el tipo de pruebas a ejecutar |\n| `-ssl` | Fuerza escaneo sobre HTTPS |\n\n## Ejemplo básico\n\n```bash\nnikto -h http://10.10.10.1\n```\n\nNikto informa de headers de seguridad ausentes (como X-Frame-Options), versiones de software vulnerables, directorios expuestos y más.\n\n## ¿Por qué usarlo si ya tengo Gobuster?\n\nGobuster solo enumera qué puertas existen. Nikto va más allá: revisa las cerraduras de cada una — identifica configuraciones inseguras y vulnerabilidades conocidas, lo que lo hace ideal para la fase de reconocimiento activo.\n\n---\nCompleta el quiz y la actividad para ganar **150 puntos**.',
  3, 20, 150, TRUE
FROM course_modules cm
WHERE cm.slug = 'reconocimiento-escaneo'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas del Lab 3 (nikto)
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Para qué se usa principalmente Nikto?', 'Nikto es un escáner web que detecta vulnerabilidades conocidas, malas configuraciones y software desactualizado en servidores web.'
FROM laboratories l WHERE l.slug = 'nikto-web-scanner'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Qué flag de Nikto especifica el host objetivo?', 'El flag -h (host) indica a Nikto la URL o IP del servidor que debe escanear.'
FROM laboratories l WHERE l.slug = 'nikto-web-scanner'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Cuál es la diferencia principal entre Nikto y Gobuster?', 'Gobuster solo enumera rutas por fuerza bruta. Nikto va más allá: identifica configuraciones inseguras, headers ausentes y vulnerabilidades conocidas en el servidor.'
FROM laboratories l WHERE l.slug = 'nikto-web-scanner'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿Qué header de seguridad HTTP reportaría Nikto como ausente si no está configurado?', 'X-Frame-Options protege contra clickjacking, el "vidrio con botón falso" pegado encima de tu página. Su ausencia es uno de los hallazgos más comunes de Nikto.'
FROM laboratories l WHERE l.slug = 'nikto-web-scanner'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Ejecuta Nikto sobre el host objetivo. Copia la respuesta generada.', 'nikto -h http://10.10.10.1 es el comando básico para escanear un servidor web con Nikto.'
FROM laboratories l WHERE l.slug = 'nikto-web-scanner'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Nikto pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Detectar vulnerabilidades y malas configuraciones en servidores web', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Enumerar directorios por fuerza bruta', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Escanear puertos TCP/UDP', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Interceptar y modificar tráfico HTTP', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Nikto pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, '-h', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, '-u', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, '-target', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, '-host', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Nikto pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Nikto identifica vulnerabilidades conocidas; Gobuster solo enumera rutas', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Gobuster es más rápido y completo que Nikto', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Nikto escanea puertos; Gobuster escanea aplicaciones', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Son exactamente lo mismo con diferente nombre', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Nikto pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'X-Frame-Options', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Content-Type', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Accept-Encoding', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Transfer-Encoding', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Nikto pregunta 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Escaneo de vulnerabilidades con Nikto',
  E'## Objetivo\n\nUsa Nikto para escanear el servidor web objetivo y detectar vulnerabilidades y malas configuraciones.\n\n## Instrucciones\n\n```bash\nnikto -h http://10.10.10.1\n```\n\nNikto analizará el servidor y mostrará:\n- Headers de seguridad ausentes\n- Versiones de software con CVEs conocidos\n- Directorios y archivos sensibles expuestos\n\nCopia la **respuesta generada** y úsala en la pregunta del quiz.',
  'nikto -h http://10.10.10.1',
  '¡Bien hecho! Has ejecutado un escaneo Nikto. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'nikto-web-scanner' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Módulo 2: Explotación de Sistemas y Aplicaciones Web (nota: el slug 'vulnerabilidades-web'
-- se mantiene sin cambios para no romper el upsert en despliegues ya existentes)
INSERT INTO course_modules (course_id, slug, title, description, position)
SELECT c.id, 'vulnerabilidades-web', 'Explotación de Sistemas y Aplicaciones Web', 'Extrae credenciales de sistemas Windows con Mimikatz, y aprende a identificar y explotar las vulnerabilidades web más comunes del OWASP Top 10.', 2
FROM courses c
WHERE c.slug = 'fundamentos-ciberseguridad'
ON CONFLICT (course_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  position = EXCLUDED.position;

-- Lab 4 (Módulo 2, posición 1): Introducción a Mimikatz
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'mimikatz-intro',
  'Introducción a Mimikatz',
  E'## ¿Qué es Mimikatz?\n\nImagina un edificio de oficinas donde, apenas entras, el guardia de seguridad anota tu credencial en un cuaderno para no pedírtela otra vez en cada puerta interna que cruces. Eso es lo que hace Windows con el proceso **LSASS** (Local Security Authority Subsystem Service): guarda en memoria las credenciales de las sesiones activas para no pedirlas constantemente.\n\n**Mimikatz** es una herramienta de código abierto, desarrollada por Benjamin Delpy, que le "lee el cuaderno" a LSASS: extrae credenciales en texto plano, hashes NTLM, tickets Kerberos y otros secretos directamente de esa memoria.\n\n## ¿Por qué es importante?\n\nMimikatz es una de las herramientas más utilizadas en ataques post-explotación y en pruebas de penetración. Comprender cómo funciona es esencial tanto para atacar como para defender sistemas Windows.\n\n## Requisitos previos\n\nPara leer el cuaderno del guardia primero hay que convencerlo de que tienes autoridad para verlo. En términos técnicos:\n\n- Privilegios de **Administrador** en el sistema\n- En algunos casos, privilegios de **SYSTEM**\n- El privilegio de depuración (`SeDebugPrivilege`) habilitado — es literalmente el permiso para leer la memoria de otros procesos, incluido LSASS\n\n## Comando básico\n\n```\nmimikatz # privilege::debug\nmimikatz # sekurlsa::logonpasswords\n```\n\nEl primer comando (`privilege::debug`) le pide permiso al sistema para acceder a la memoria de LSASS. El segundo (`sekurlsa::logonpasswords`) es el que realmente lee el cuaderno: extrae todas las credenciales activas en memoria, incluyendo contraseñas en texto plano si el sistema lo permite.\n\n---\nCompleta el quiz y la actividad para ganar **250 puntos**.',
  1, 30, 250, TRUE
FROM course_modules cm
WHERE cm.slug = 'vulnerabilidades-web'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas del Lab 4 (mimikatz-intro)
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Qué proceso de Windows contiene las credenciales que Mimikatz extrae de memoria?', 'LSASS (Local Security Authority Subsystem Service) es el proceso responsable de la autenticación en Windows y almacena credenciales en memoria.'
FROM laboratories l WHERE l.slug = 'mimikatz-intro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Quién desarrolló Mimikatz?', 'Benjamin Delpy, conocido como "gentilkiwi", desarrolló Mimikatz originalmente como prueba de concepto para demostrar vulnerabilidades en la gestión de credenciales de Windows.'
FROM laboratories l WHERE l.slug = 'mimikatz-intro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué privilegio necesita Mimikatz para acceder a LSASS?', 'SeDebugPrivilege permite a un proceso leer y escribir en la memoria de otros procesos. Es necesario para acceder a LSASS y extraer credenciales.'
FROM laboratories l WHERE l.slug = 'mimikatz-intro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿Qué módulo de Mimikatz se usa para extraer credenciales de sesiones activas?', 'El módulo sekurlsa contiene comandos para interactuar con LSASS. sekurlsa::logonpasswords extrae credenciales de todas las sesiones activas.'
FROM laboratories l WHERE l.slug = 'mimikatz-intro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Ejecuta Mimikatz para habilitar el privilegio de depuración y extraer credenciales. Copia la respuesta generada.', 'privilege::debug habilita SeDebugPrivilege. sekurlsa::logonpasswords extrae credenciales activas de LSASS.'
FROM laboratories l WHERE l.slug = 'mimikatz-intro'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Lab mimikatz-intro pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'LSASS (Local Security Authority Subsystem Service)', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'svchost.exe', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'winlogon.exe', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'explorer.exe', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-intro pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Benjamin Delpy', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Raphael Mudge', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'HD Moore', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Gordon Lyon', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-intro pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'SeDebugPrivilege', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'SeBackupPrivilege', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'SeTakeOwnershipPrivilege', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'SeNetworkLogonRight', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-intro pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'sekurlsa', TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'kerberos', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'lsadump', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'token', FALSE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Lab mimikatz-intro pregunta 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Extracción de credenciales con Mimikatz',
  E'## Objetivo\n\nUsa Mimikatz para habilitar el privilegio de depuración y extraer las credenciales de las sesiones activas en el sistema.\n\n## Instrucciones\n\nEjecuta estos dos comandos **en orden**, dentro de la consola de Mimikatz:\n\n```\nmimikatz # privilege::debug\nmimikatz # sekurlsa::logonpasswords\n```\n\n1. `privilege::debug` — habilita `SeDebugPrivilege` para poder acceder a LSASS. No genera la respuesta que necesitas para el quiz, solo abre la puerta para el siguiente paso.\n2. `sekurlsa::logonpasswords` — este es el comando que **sí** extrae las credenciales. La respuesta generada por este segundo comando es la que debes copiar y pegar en la pregunta del quiz.\n\n> **Importante:** copia la salida de `sekurlsa::logonpasswords`, no la de `privilege::debug`.',
  'sekurlsa::logonpasswords',
  '¡Muy bien! Has extraído credenciales de memoria con Mimikatz. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q
JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-intro' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Fix: eliminar el lab con slug incorrecto antes de insertar el correcto
DELETE FROM laboratories
WHERE slug = 'sql-injection-basico'
  AND module_id = (SELECT id FROM course_modules WHERE slug = 'vulnerabilidades-web');

-- Lab 5 (Módulo 2, posición 2): Mimikatz Avanzado
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'mimikatz-avanzado',
  'Mimikatz Avanzado',
  E'## Antes de empezar: ¿qué es un dominio de Active Directory?\n\nEn una empresa pequeña, cada computador tiene sus propios usuarios locales. En una empresa grande eso sería un caos: cientos de empleados necesitarían una cuenta distinta en cada máquina. **Active Directory (AD)** resuelve esto centralizando todo: es como la administración central de un edificio corporativo, que lleva un único registro de empleados, sus permisos y a qué oficinas pueden entrar. El servidor que guarda ese registro se llama **Domain Controller (DC)**.\n\nPara no pedirte tu credencial en cada oficina que visitas, AD usa un protocolo llamado **Kerberos**: te identificas una sola vez en la recepción central —el **KDC**, Key Distribution Center, que vive dentro del DC— y recibes un pase temporal, un **TGT** (Ticket Granting Ticket), que muestras en cada oficina interna sin volver a mostrar tu cédula. Ese TGT lo firma la recepción con una llave maestra que solo ella conoce: el hash de la cuenta de servicio **KRBTGT**.\n\nCon esa base, estas son las técnicas avanzadas de Mimikatz para moverte lateralmente y escalar privilegios dentro de un dominio.\n\n## Pass-the-Hash (PtH)\n\nEn vez de robar la contraseña de alguien, robas directamente su hash NTLM (una huella derivada de la contraseña) y lo usas para autenticarte — como mostrar una copia de una llave sin necesitar saber la combinación original.\n\n```\nmimikatz # sekurlsa::pth /user:Administrador /domain:CORP /ntlm:<hash> /run:cmd.exe\n```\n\n## Golden Ticket\n\nSi logras robar la **llave maestra de la recepción** —el hash de la cuenta KRBTGT—, puedes firmar tú mismo un TGT falso con la validez que quieras, para el usuario que quieras. Ya no necesitas pasar por la recepción real nunca más: tienes un pase maestro que abre cualquier oficina del edificio.\n\n```\nmimikatz # kerberos::golden /user:Administrador /domain:corp.local /sid:<SID> /krbtgt:<hash> /ticket:golden.kirbi\n```\n\n## DCSync\n\nEn vez de asaltar la recepción central directamente, te haces pasar por **otra sucursal** que pide sincronizar su copia de la base de empleados "por mantenimiento de rutina" — así es, literalmente, como los Domain Controllers se replican entre sí. El DC real, sin sospechar nada, te entrega los hashes de todas las cuentas, incluido KRBTGT, sin que tengas que ejecutar un solo comando dentro del DC.\n\n```\nmimikatz # lsadump::dcsync /domain:corp.local /user:krbtgt\n```\n\n---\nCompleta el quiz y la actividad para ganar **300 puntos**.',
  2, 30, 300, TRUE
FROM course_modules cm
WHERE cm.slug = 'vulnerabilidades-web'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas del Lab 5 (mimikatz-avanzado)
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Qué técnica permite autenticarse en Windows usando solo el hash NTLM sin conocer la contraseña?', 'Pass-the-Hash (PtH) explota el protocolo NTLM, que acepta el hash directamente en el proceso de autenticación sin necesitar la contraseña original.'
FROM laboratories l WHERE l.slug = 'mimikatz-avanzado'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Qué cuenta de Active Directory se compromete para crear un Golden Ticket?', 'KRBTGT es la llave maestra de la recepción central (el KDC) de Kerberos. Con su hash puedes firmar tú mismo TGTs válidos para cualquier usuario del dominio.'
FROM laboratories l WHERE l.slug = 'mimikatz-avanzado'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué módulo de Mimikatz implementa el ataque DCSync?', 'lsadump::dcsync simula la replicación de un DC usando el protocolo MS-DRSR, permitiendo obtener los hashes de contraseñas de cualquier cuenta del dominio.'
FROM laboratories l WHERE l.slug = 'mimikatz-avanzado'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿Qué tipo de ticket de Kerberos forja un ataque Golden Ticket?', 'Un TGT (Ticket Granting Ticket) es el pase temporal que la recepción (KDC) entrega tras identificarte. Un Golden Ticket es un TGT falso, firmado con la llave maestra robada, que permite acceder a cualquier servicio del dominio.'
FROM laboratories l WHERE l.slug = 'mimikatz-avanzado'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Usa Mimikatz para realizar un DCSync y extraer el hash de la cuenta krbtgt. Copia la respuesta generada.', 'lsadump::dcsync /domain:corp.local /user:krbtgt replica las credenciales del DC sin ejecutar código en él.'
FROM laboratories l WHERE l.slug = 'mimikatz-avanzado'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones Lab mimikatz-avanzado pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Pass-the-Hash (PtH)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Golden Ticket', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'DCSync', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Kerberoasting', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-avanzado pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'KRBTGT', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Administrator', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'SYSTEM', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Guest', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-avanzado pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'lsadump', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'sekurlsa', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'kerberos', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'token', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones Lab mimikatz-avanzado pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'TGT (Ticket Granting Ticket)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'TGS (Ticket Granting Service)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'ST (Service Ticket)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'PAC (Privilege Attribute Certificate)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad Lab mimikatz-avanzado pregunta 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'DCSync: extracción de hash KRBTGT',
  E'## Objetivo\n\nUsa Mimikatz para simular un controlador de dominio y extraer el hash de la cuenta krbtgt mediante DCSync.\n\n## Instrucciones\n\n```\nmimikatz # lsadump::dcsync /domain:corp.local /user:krbtgt\n```\n\n- `lsadump::dcsync`: replica credenciales usando el protocolo MS-DRSR\n- `/domain`: especifica el dominio objetivo\n- `/user`: la cuenta cuyo hash se quiere obtener\n\nEste ataque no requiere ejecutar código en el Domain Controller. Copia la **respuesta generada** y úsala en la pregunta del quiz.',
  'lsadump::dcsync /domain:corp.local /user:krbtgt',
  '¡Excelente! Has realizado un DCSync exitoso. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'mimikatz-avanzado' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Lab 6 (Módulo 2, posición 3): SQL Injection básico
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'sql-injection-basico',
  'SQL Injection Básico',
  E'## ¿Qué es SQL Injection?\n\nImagina que llenas un formulario en la ventanilla de un archivo, y el empleado toma literalmente lo que escribiste y lo pega dentro de una frase ya preparada para consultar el archivo: "buscar la carpeta de la persona llamada **[lo que escribiste]**". Si solo escribes tu nombre, no hay problema. Pero si escribes algo que *parece* parte de la instrucción —como cerrar la frase y agregar la tuya propia—, el empleado no tiene forma de distinguir tu "dato" de una "orden", y la ejecuta igual.\n\nEso es exactamente **SQL Injection (SQLi)**: una vulnerabilidad que permite a un atacante interferir en las consultas que una aplicación hace a su base de datos, insertando código SQL disfrazado de dato de entrada. Es consistentemente una de las vulnerabilidades más críticas del OWASP Top 10, dentro de la categoría **A03:2021 – Injection** (que agrupa cualquier caso donde datos no confiables se envían como parte de un comando o consulta).\n\n## ¿Cómo funciona?\n\nCuando la aplicación construye una consulta SQL concatenando directamente datos del usuario:\n\n```sql\nSELECT * FROM users WHERE username = ''admin'' AND password = ''1234'';\n```\n\nUn atacante puede escribir, en el campo de usuario, el payload:\n\n```\n'' OR 1=1--\n```\n\nY la consulta queda así:\n\n```sql\nSELECT * FROM users WHERE username = '''' OR 1=1--'' AND password = ''cualquier-cosa''\n```\n\nDos trucos en una sola línea: `OR 1=1` es una condición que siempre es verdadera, así que la consulta "encuentra" un usuario sin importar la contraseña; y `--` le dice a la base de datos "ignora todo lo que sigue", saltándose por completo la verificación de contraseña.\n\n## Tipos principales\n\n| Tipo | Descripción |\n|------|-------------|\n| **Error-based** | Extrae datos mediante mensajes de error |\n| **Union-based** | Usa UNION SELECT para recuperar datos de otras tablas |\n| **Blind (boolean)** | El empleado no te muestra nada directamente, pero su reacción (sí/no) confirma si tu suposición era correcta |\n| **Time-based** | Usa delays (SLEEP) para inferir información según cuánto tarda en responder |\n\n## sqlmap: automatización\n\nEn vez de probar payloads uno por uno a mano, **sqlmap** automatiza todo el proceso: detecta el tipo de inyección, y puede extraer bases de datos, tablas y datos completos.\n\n```bash\nsqlmap -u "http://10.10.10.1/login.php?id=1" --dbs\n```\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  3, 30, 200, TRUE
FROM course_modules cm
WHERE cm.slug = 'vulnerabilidades-web'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas Lab sql-injection-basico
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿En qué categoría del OWASP Top 10 (2021) se encuentra SQL Injection?', 'SQL Injection está dentro de "A03:2021 – Injection", que agrupa vulnerabilidades donde datos no confiables son enviados como parte de un comando o consulta.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', E'¿Qué hace el payload \' OR 1=1-- en un formulario de login vulnerable?', 'La condición OR 1=1 siempre es verdadera, haciendo que la consulta devuelva todos los registros. El -- comenta el resto de la consulta, saltándose la verificación de contraseña.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué tipo de SQLi infiere información basándose en respuestas verdadero/falso de la aplicación?', 'El Blind Boolean-based SQLi no recibe datos directamente, sino que hace preguntas y deduce la respuesta por el comportamiento de la aplicación.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿Qué herramienta automatiza la detección y explotación de SQL Injection?', 'sqlmap es la herramienta estándar para automatizar SQLi. Detecta el tipo de inyección, extrae bases de datos, tablas y datos, y puede obtener una shell del sistema.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Usa sqlmap para enumerar las bases de datos del objetivo. Copia la respuesta generada.', 'sqlmap -u "http://10.10.10.1/login.php?id=1" --dbs enumera todas las bases de datos accesibles.'
FROM laboratories l WHERE l.slug = 'sql-injection-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones SQLi pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'A03 – Injection', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'A01 – Broken Access Control', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'A07 – Identification and Authentication Failures', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'A05 – Security Misconfiguration', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones SQLi pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Omite la verificación de contraseña autenticando como cualquier usuario', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Elimina todos los registros de la tabla users', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Crea un nuevo usuario administrador', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Muestra un error de sintaxis SQL', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones SQLi pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Blind Boolean-based', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Union-based', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Error-based', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Out-of-band', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones SQLi pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'sqlmap', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Burp Suite', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Metasploit', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Hydra', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad SQLi pregunta 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Enumeración de bases de datos con sqlmap',
  E'## Objetivo\n\nUsa sqlmap para detectar y explotar una inyección SQL en el objetivo, enumerando las bases de datos disponibles.\n\n## Instrucciones\n\n```bash\nsqlmap -u "http://10.10.10.1/login.php?id=1" --dbs\n```\n\n- `-u`: URL objetivo con el parámetro vulnerable\n- `--dbs`: enumera todas las bases de datos\n\nsqlmap detectará automáticamente el tipo de inyección y extraerá la información. Copia la **respuesta generada** y úsala en la pregunta del quiz.',
  'sqlmap -u "http://10.10.10.1/login.php?id=1" --dbs',
  '¡Correcto! Has enumerado las bases de datos con sqlmap. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'sql-injection-basico' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;

-- Lab 7 (Módulo 2, posición 4): XSS básico
INSERT INTO laboratories (module_id, slug, title, content_markdown, position, estimated_minutes, points, is_published)
SELECT cm.id,
  'xss-basico',
  'XSS: Cross-Site Scripting',
  E'## ¿Qué es XSS?\n\nImagina un muro público de anuncios donde cualquiera puede pegar una nota. Los demás visitantes confían en que todo lo que está pegado ahí es del dueño del muro, así que si alguien logra pegar una nota que *parece* una instrucción oficial, la gente la sigue sin sospechar, porque está en el mismo muro de siempre.\n\nEso es **Cross-Site Scripting (XSS)**: una vulnerabilidad que permite a un atacante inyectar scripts maliciosos en páginas web vistas por otros usuarios. El navegador de la víctima no distingue entre el contenido legítimo del sitio y el script inyectado, simplemente lo ejecuta porque "vino pegado en el mismo muro". Aparece en el OWASP Top 10 dentro de la misma categoría que SQL Injection: **A03:2021 – Injection**.\n\n## Tipos de XSS\n\n| Tipo | Descripción | Analogía |\n|---|---|---|\n| **Reflected** | El script viene en la request y se refleja en la respuesta inmediata | Le gritas algo a alguien y te lo repite al instante, sin pegarlo en el muro |\n| **Stored** | El script se guarda en la BD y afecta a todos los usuarios que lo ven | Pegas la nota en el muro; todo el que pasa la lee |\n| **DOM-based** | La vulnerabilidad está en el JavaScript del cliente, no en el servidor | El problema no es el muro, es cómo cada quien interpreta lo que lee |\n\n## Payload básico\n\n```html\n<script>alert(''XSS'')</script>\n```\n\nSi la aplicación no sanitiza la entrada y este código aparece ejecutado en el navegador (en vez de mostrarse como texto plano), existe XSS.\n\n## Impacto real\n\nUna vez que tu script se ejecuta en el navegador de la víctima, puede:\n\n- Robar sus cookies de sesión (`document.cookie`) y secuestrar su sesión sin necesitar su contraseña\n- Redirigirla a sitios maliciosos\n- Registrar lo que escribe (keylogging) dentro de la página\n- Desfigurar el sitio (defacement)\n\n## Cómo se defiende un sitio: Content Security Policy\n\nSi el muro tuviera un cartel que dijera "solo se aceptan anuncios impresos por la administración, cualquier otra hoja se retira antes de que alguien la lea", el ataque anterior no funcionaría. Ese cartel, en la web, es el header **Content Security Policy (CSP)**: le dice al navegador exactamente de qué fuentes puede ejecutar scripts, bloqueando cualquier script inyectado que no venga de ahí.\n\n## Herramienta: XSStrike\n\n```bash\npython3 xsstrike.py -u "http://10.10.10.1/search?q=test"\n```\n\n---\nCompleta el quiz y la actividad para ganar **200 puntos**.',
  4, 30, 200, TRUE
FROM course_modules cm
WHERE cm.slug = 'vulnerabilidades-web'
ON CONFLICT (module_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  content_markdown = EXCLUDED.content_markdown,
  position = EXCLUDED.position,
  estimated_minutes = EXCLUDED.estimated_minutes,
  points = EXCLUDED.points,
  is_published = EXCLUDED.is_published;

-- Preguntas Lab xss-basico
INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 1, 'multiple_choice', '¿Qué tipo de XSS almacena el payload en la base de datos del servidor?', 'El XSS Stored (persistente) guarda el script en el servidor. Cada vez que un usuario visita la página afectada, el script se ejecuta en su navegador.'
FROM laboratories l WHERE l.slug = 'xss-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 2, 'multiple_choice', '¿Cuál es el impacto más crítico de un XSS exitoso?', 'El robo de cookies de sesión permite al atacante secuestrar la sesión del usuario (session hijacking) sin necesitar sus credenciales.'
FROM laboratories l WHERE l.slug = 'xss-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 3, 'multiple_choice', '¿Qué propiedad de JavaScript se usa en XSS para robar cookies de sesión?', 'document.cookie contiene todas las cookies del sitio actual. Un payload malicioso puede exfiltrarlas al atacante.'
FROM laboratories l WHERE l.slug = 'xss-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 4, 'multiple_choice', '¿Qué medida de defensa impide que el navegador ejecute scripts inyectados?', 'Content Security Policy (CSP) es el "cartel del muro": un header HTTP que indica al navegador qué fuentes de scripts son válidas, bloqueando la ejecución de scripts inyectados que no vengan de ahí.'
FROM laboratories l WHERE l.slug = 'xss-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

INSERT INTO laboratory_questions (laboratory_id, question_order, question_type, question_text, explanation)
SELECT l.id, 5, 'activity_response', 'Usa XSStrike para detectar XSS en el parámetro de búsqueda del objetivo. Copia la respuesta generada.', 'python3 xsstrike.py -u "http://10.10.10.1/search?q=test" analiza el parámetro q en busca de XSS.'
FROM laboratories l WHERE l.slug = 'xss-basico'
ON CONFLICT (laboratory_id, question_order) DO NOTHING;

-- Opciones XSS pregunta 1
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Stored (Persistente)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Reflected', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'DOM-based', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Blind', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 1
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones XSS pregunta 2
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Robo de cookies de sesión (session hijacking)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'Modificar la base de datos del servidor', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'Escanear puertos del servidor', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'Ejecutar comandos en el sistema operativo del servidor', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 2
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones XSS pregunta 3
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'document.cookie', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'window.localStorage', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'navigator.userAgent', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'document.title', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 3
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Opciones XSS pregunta 4
INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 1, 'Content Security Policy (CSP)', TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 2, 'CORS (Cross-Origin Resource Sharing)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 3, 'SSL/TLS', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

INSERT INTO laboratory_question_options (question_id, option_order, option_text, is_correct)
SELECT q.id, 4, 'HTTP Strict-Transport-Security (HSTS)', FALSE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 4
ON CONFLICT (question_id, option_order) DO NOTHING;

-- Actividad XSS pregunta 5
INSERT INTO question_activities (question_id, title, instructions_markdown, expected_action_key, success_feedback, is_published)
SELECT q.id,
  'Detección de XSS con XSStrike',
  E'## Objetivo\n\nUsa XSStrike para detectar vulnerabilidades XSS en el parámetro de búsqueda del servidor objetivo.\n\n## Instrucciones\n\n```bash\npython3 xsstrike.py -u "http://10.10.10.1/search?q=test"\n```\n\n- XSStrike analiza el parámetro `q` con múltiples payloads\n- Detecta si la aplicación refleja el input sin sanitizar\n- Genera payloads que evaden filtros básicos\n\nCopia la **respuesta generada** y úsala en la pregunta del quiz.',
  'python3 xsstrike.py -u "http://10.10.10.1/search?q=test"',
  '¡Muy bien! Has detectado XSS con XSStrike. Copia esta respuesta para el quiz.',
  TRUE
FROM laboratory_questions q JOIN laboratories l ON q.laboratory_id = l.id
WHERE l.slug = 'xss-basico' AND q.question_order = 5
ON CONFLICT (question_id) DO NOTHING;
