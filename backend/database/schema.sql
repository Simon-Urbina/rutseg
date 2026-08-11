CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ENUMS
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE user_role AS ENUM ('user', 'admin');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'laboratory_progress_status') THEN
    CREATE TYPE laboratory_progress_status AS ENUM ('not_started', 'in_progress', 'completed');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_progress_status') THEN
    CREATE TYPE activity_progress_status AS ENUM ('not_started', 'in_progress', 'completed');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_diff') THEN
    CREATE TYPE course_diff AS ENUM ('principiante', 'intermedio', 'avanzado');
  END IF;

  IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'course_diff') THEN
    ALTER TYPE course_diff ADD VALUE IF NOT EXISTS 'principiante';
    ALTER TYPE course_diff ADD VALUE IF NOT EXISTS 'intermedio';
    ALTER TYPE course_diff ADD VALUE IF NOT EXISTS 'avanzado';
  END IF;
END$$;

-- FUNCION GENERICA PARA updated_at
CREATE OR REPLACE FUNCTION trg_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- USERS
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(120) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role user_role NOT NULL DEFAULT 'user',
  bio TEXT,
  profile_image BYTEA,
  points INTEGER NOT NULL DEFAULT 0 CHECK (points >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

DROP TRIGGER IF EXISTS users_updated_at_trg ON users;
CREATE TRIGGER users_updated_at_trg
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- Privacy consent columns (idempotent migration — safe to re-run)
ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_accepted_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS privacy_policy_version VARCHAR(10);

-- COURSES -> MODULES -> LABORATORIES
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(120) UNIQUE NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT,
  difficulty course_diff NOT NULL DEFAULT 'principiante',
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

DO $$
DECLARE
  difficulty_udt text;
  c record;
BEGIN
  SELECT udt_name
  INTO difficulty_udt
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name = 'courses'
    AND column_name = 'difficulty';

  IF difficulty_udt IS NULL THEN
    RETURN;
  END IF;

  FOR c IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'courses'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%difficulty%'
  LOOP
    EXECUTE format('ALTER TABLE courses DROP CONSTRAINT %I', c.conname);
  END LOOP;

  IF difficulty_udt <> 'course_diff' THEN
    EXECUTE $sql$
      ALTER TABLE courses
      ALTER COLUMN difficulty TYPE course_diff
      USING (
        CASE lower(difficulty::text)
          WHEN 'beginner' THEN 'principiante'
          WHEN 'intermediate' THEN 'intermedio'
          WHEN 'advanced' THEN 'avanzado'
          WHEN 'principiante' THEN 'principiante'
          WHEN 'intermedio' THEN 'intermedio'
          WHEN 'avanzado' THEN 'avanzado'
          ELSE 'principiante'
        END
      )::course_diff
    $sql$;
  END IF;

  ALTER TABLE courses
  ALTER COLUMN difficulty SET DEFAULT 'principiante';
END$$;

DROP TRIGGER IF EXISTS courses_updated_at_trg ON courses;
CREATE TRIGGER courses_updated_at_trg
BEFORE UPDATE ON courses
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- MODULES (antes course_units)
CREATE TABLE IF NOT EXISTS course_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  slug VARCHAR(120) NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT,
  position INTEGER NOT NULL CHECK (position > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(course_id, slug),
  UNIQUE(course_id, position)
);

CREATE INDEX IF NOT EXISTS idx_course_modules_course_id ON course_modules(course_id);

DROP TRIGGER IF EXISTS course_modules_updated_at_trg ON course_modules;
CREATE TRIGGER course_modules_updated_at_trg
BEFORE UPDATE ON course_modules
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- LABORATORIES (antes lessons)
CREATE TABLE IF NOT EXISTS laboratories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  slug VARCHAR(120) NOT NULL,
  title VARCHAR(180) NOT NULL,
  content_markdown TEXT NOT NULL,
  position INTEGER NOT NULL CHECK (position > 0),
  estimated_minutes INTEGER NOT NULL DEFAULT 10 CHECK (estimated_minutes > 0),
  quiz_questions_required SMALLINT NOT NULL DEFAULT 5 CHECK (quiz_questions_required = 5),
  points INTEGER NOT NULL DEFAULT 0 CHECK (points >= 0),
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(module_id, slug),
  UNIQUE(module_id, position)
);

CREATE INDEX IF NOT EXISTS idx_laboratories_module_id ON laboratories(module_id);

DROP TRIGGER IF EXISTS laboratories_updated_at_trg ON laboratories;
CREATE TRIGGER laboratories_updated_at_trg
BEFORE UPDATE ON laboratories
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- QUIZ DE CADA LABORATORIO
CREATE TABLE IF NOT EXISTS laboratory_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  laboratory_id uuid NOT NULL REFERENCES laboratories(id) ON DELETE CASCADE,
  question_order SMALLINT NOT NULL CHECK (question_order BETWEEN 1 AND 5),
  question_type VARCHAR(20) NOT NULL DEFAULT 'multiple_choice',
  question_text TEXT NOT NULL,
  explanation TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT laboratory_questions_type_chk
    CHECK (question_type IN ('multiple_choice', 'activity_response')),
  UNIQUE(laboratory_id, question_order)
);

CREATE INDEX IF NOT EXISTS idx_laboratory_questions_laboratory_id ON laboratory_questions(laboratory_id);

DROP TRIGGER IF EXISTS laboratory_questions_updated_at_trg ON laboratory_questions;
CREATE TRIGGER laboratory_questions_updated_at_trg
BEFORE UPDATE ON laboratory_questions
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- ACTIVIDAD POR PREGUNTA 1:1 (antes question_labs)
CREATE TABLE IF NOT EXISTS question_activities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL UNIQUE REFERENCES laboratory_questions(id) ON DELETE CASCADE,
  title VARCHAR(180) NOT NULL,
  instructions_markdown TEXT NOT NULL,
  expected_action_key VARCHAR(120) NOT NULL,
  success_feedback TEXT NOT NULL DEFAULT 'Accion correcta. Usa esta respuesta en el quiz.',
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_question_activities_question_id ON question_activities(question_id);

DROP TRIGGER IF EXISTS question_activities_updated_at_trg ON question_activities;
CREATE TRIGGER question_activities_updated_at_trg
BEFORE UPDATE ON question_activities
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- PROGRESO DE ACTIVIDAD POR USUARIO (antes user_laboratory_progress)
CREATE TABLE IF NOT EXISTS user_activity_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_id uuid NOT NULL REFERENCES question_activities(id) ON DELETE CASCADE,
  status activity_progress_status NOT NULL DEFAULT 'not_started',
  attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
  generated_response TEXT,
  generated_response_issued_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  last_action_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, activity_id)
);

CREATE INDEX IF NOT EXISTS idx_user_activity_progress_user_id ON user_activity_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_progress_activity_id ON user_activity_progress(activity_id);

DROP TRIGGER IF EXISTS user_activity_progress_updated_at_trg ON user_activity_progress;
CREATE TRIGGER user_activity_progress_updated_at_trg
BEFORE UPDATE ON user_activity_progress
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- REGISTRO DE ACCIONES DEL USUARIO EN LA ACTIVIDAD (antes lab_action_logs)
CREATE TABLE IF NOT EXISTS activity_action_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  activity_id uuid NOT NULL REFERENCES question_activities(id) ON DELETE CASCADE,
  action_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  feedback TEXT,
  generated_response TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_action_logs_user_activity ON activity_action_logs(user_id, activity_id);
CREATE INDEX IF NOT EXISTS idx_activity_action_logs_created_at ON activity_action_logs(created_at);

-- Migracion de FK
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'user_activity_progress'
  ) THEN
    ALTER TABLE user_activity_progress
      DROP CONSTRAINT IF EXISTS user_activity_progress_activity_id_fkey;

    ALTER TABLE user_activity_progress
      ADD CONSTRAINT user_activity_progress_activity_id_fkey
      FOREIGN KEY (activity_id) REFERENCES question_activities(id) ON DELETE CASCADE NOT VALID;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'activity_action_logs'
  ) THEN
    ALTER TABLE activity_action_logs
      DROP CONSTRAINT IF EXISTS activity_action_logs_activity_id_fkey;

    ALTER TABLE activity_action_logs
      ADD CONSTRAINT activity_action_logs_activity_id_fkey
      FOREIGN KEY (activity_id) REFERENCES question_activities(id) ON DELETE CASCADE NOT VALID;
  END IF;
END$$;

CREATE OR REPLACE FUNCTION trg_sync_user_activity_progress_from_action()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO user_activity_progress (
    user_id,
    activity_id,
    status,
    attempts_count,
    generated_response,
    generated_response_issued_at,
    completed_at,
    last_action_payload
  )
  VALUES (
    NEW.user_id,
    NEW.activity_id,
    CASE WHEN NEW.is_correct THEN 'completed'::activity_progress_status ELSE 'in_progress'::activity_progress_status END,
    1,
    CASE WHEN NEW.is_correct THEN NEW.generated_response ELSE NULL END,
    CASE WHEN NEW.is_correct AND NEW.generated_response IS NOT NULL THEN NEW.created_at ELSE NULL END,
    CASE WHEN NEW.is_correct THEN NEW.created_at ELSE NULL END,
    NEW.action_payload
  )
  ON CONFLICT (user_id, activity_id)
  DO UPDATE SET
    status = CASE
      WHEN NEW.is_correct THEN 'completed'::activity_progress_status
      WHEN user_activity_progress.status = 'not_started' THEN 'in_progress'::activity_progress_status
      ELSE user_activity_progress.status
    END,
    attempts_count = user_activity_progress.attempts_count + 1,
    generated_response = CASE
      WHEN NEW.is_correct AND NEW.generated_response IS NOT NULL THEN NEW.generated_response
      ELSE user_activity_progress.generated_response
    END,
    generated_response_issued_at = CASE
      WHEN NEW.is_correct AND NEW.generated_response IS NOT NULL
        THEN COALESCE(user_activity_progress.generated_response_issued_at, NEW.created_at)
      ELSE user_activity_progress.generated_response_issued_at
    END,
    completed_at = CASE
      WHEN NEW.is_correct THEN COALESCE(user_activity_progress.completed_at, NEW.created_at)
      ELSE user_activity_progress.completed_at
    END,
    last_action_payload = NEW.action_payload,
    updated_at = now();

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS activity_action_logs_sync_progress_trg ON activity_action_logs;
CREATE TRIGGER activity_action_logs_sync_progress_trg
AFTER INSERT ON activity_action_logs
FOR EACH ROW EXECUTE FUNCTION trg_sync_user_activity_progress_from_action();

-- OPCIONES DE PREGUNTA (antes lesson_question_options)
CREATE TABLE IF NOT EXISTS laboratory_question_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL REFERENCES laboratory_questions(id) ON DELETE CASCADE,
  option_order SMALLINT NOT NULL CHECK (option_order > 0),
  option_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(question_id, option_order)
);

CREATE INDEX IF NOT EXISTS idx_laboratory_question_options_question_id ON laboratory_question_options(question_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_laboratory_question_single_correct_option
  ON laboratory_question_options(question_id)
  WHERE is_correct = TRUE;

-- ENROLLMENT DE USUARIO EN CURSO
CREATE TABLE IF NOT EXISTS course_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_course_enrollments_user_id ON course_enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_course_enrollments_course_id ON course_enrollments(course_id);

-- SUBMISSIONS (1 intento = 5 preguntas respondidas)
CREATE TABLE IF NOT EXISTS submissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  laboratory_id uuid NOT NULL REFERENCES laboratories(id) ON DELETE CASCADE,
  attempt_number INTEGER NOT NULL CHECK (attempt_number > 0),
  answers JSONB NOT NULL,
  answered_questions_count SMALLINT NOT NULL DEFAULT 5 CHECK (answered_questions_count = 5),
  correct_answers_count SMALLINT NOT NULL CHECK (correct_answers_count BETWEEN 0 AND 5),
  score_percent NUMERIC(5,2) NOT NULL CHECK (score_percent BETWEEN 0 AND 100),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, laboratory_id, attempt_number),
  CHECK (jsonb_typeof(answers) = 'array'),
  CHECK (jsonb_array_length(answers) = 5)
);

CREATE INDEX IF NOT EXISTS idx_submissions_user_laboratory ON submissions(user_id, laboratory_id);
CREATE INDEX IF NOT EXISTS idx_submissions_submitted_at ON submissions(submitted_at);

-- PROGRESO POR USUARIO/LABORATORIO (antes user_lesson_progress)
CREATE TABLE IF NOT EXISTS user_laboratory_progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  laboratory_id uuid NOT NULL REFERENCES laboratories(id) ON DELETE CASCADE,
  status laboratory_progress_status NOT NULL DEFAULT 'not_started',
  attempts_count INTEGER NOT NULL DEFAULT 0 CHECK (attempts_count >= 0),
  best_score_percent NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (best_score_percent BETWEEN 0 AND 100),
  last_score_percent NUMERIC(5,2) CHECK (last_score_percent BETWEEN 0 AND 100),
  completed_at TIMESTAMPTZ,
  last_submission_at TIMESTAMPTZ,
  last_submission_id uuid REFERENCES submissions(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, laboratory_id)
);

CREATE INDEX IF NOT EXISTS idx_user_laboratory_progress_user_id ON user_laboratory_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_laboratory_progress_laboratory_id ON user_laboratory_progress(laboratory_id);

DROP TRIGGER IF EXISTS user_laboratory_progress_updated_at_trg ON user_laboratory_progress;
CREATE TRIGGER user_laboratory_progress_updated_at_trg
BEFORE UPDATE ON user_laboratory_progress
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- Trigger: submission -> actualiza user_laboratory_progress
CREATE OR REPLACE FUNCTION trg_sync_user_laboratory_progress_from_submission()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO user_laboratory_progress (
    user_id,
    laboratory_id,
    status,
    attempts_count,
    best_score_percent,
    last_score_percent,
    completed_at,
    last_submission_at,
    last_submission_id
  )
  VALUES (
    NEW.user_id,
    NEW.laboratory_id,
    'completed',
    1,
    NEW.score_percent,
    NEW.score_percent,
    NEW.submitted_at,
    NEW.submitted_at,
    NEW.id
  )
  ON CONFLICT (user_id, laboratory_id)
  DO UPDATE SET
    status = 'completed',
    attempts_count = user_laboratory_progress.attempts_count + 1,
    best_score_percent = GREATEST(user_laboratory_progress.best_score_percent, NEW.score_percent),
    last_score_percent = NEW.score_percent,
    completed_at = COALESCE(user_laboratory_progress.completed_at, NEW.submitted_at),
    last_submission_at = NEW.submitted_at,
    last_submission_id = NEW.id,
    updated_at = now();

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS submissions_sync_progress_trg ON submissions;
CREATE TRIGGER submissions_sync_progress_trg
AFTER INSERT ON submissions
FOR EACH ROW EXECUTE FUNCTION trg_sync_user_laboratory_progress_from_submission();

-- Trigger: suma points del laboratorio al usuario al completarlo por primera vez
CREATE OR REPLACE FUNCTION trg_award_laboratory_points()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_lab_points INTEGER;
  v_already_completed BOOLEAN;
BEGIN
  -- Solo actuar cuando el laboratorio pasa a 'completed' por primera vez
  SELECT (OLD.status = 'completed') INTO v_already_completed;
  IF v_already_completed THEN
    RETURN NEW;
  END IF;

  IF NEW.status <> 'completed' THEN
    RETURN NEW;
  END IF;

  SELECT points INTO v_lab_points
  FROM laboratories
  WHERE id = NEW.laboratory_id;

  IF v_lab_points > 0 THEN
    UPDATE users
    SET points = points + v_lab_points
    WHERE id = NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS user_laboratory_progress_award_points_trg ON user_laboratory_progress;
CREATE TRIGGER user_laboratory_progress_award_points_trg
AFTER INSERT OR UPDATE OF status ON user_laboratory_progress
FOR EACH ROW EXECUTE FUNCTION trg_award_laboratory_points();

-- SEED opcional (admin inicial)
INSERT INTO users (username, email, password_hash, role)
VALUES ('admin', 'admin@example.com', '<hash-aqui>', 'admin')
ON CONFLICT DO NOTHING;

-- Notas:
-- 1) Arquitectura recomendada: Routes -> Controllers -> Services -> DAO -> Database.
-- 2) El backend debe validar que las 5 respuestas pertenezcan a preguntas del laboratorio.
-- 3) score_percent y correct_answers_count se calculan en Services antes de insertar en submissions.
-- 4) Para preguntas de tipo 'activity_response', Services debe comparar response_text contra user_activity_progress.generated_response.
-- 5) El trigger trg_award_laboratory_points suma laboratories.points a users.points al completar un laboratorio por primera vez.

-- FORUM COMMENTS
CREATE TABLE IF NOT EXISTS forum_comments (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid REFERENCES users(id) ON DELETE SET NULL,
  content    TEXT NOT NULL CHECK (char_length(content) >= 1 AND char_length(content) <= 2000),
  parent_id  uuid REFERENCES forum_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_forum_comments_parent  ON forum_comments(parent_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_user    ON forum_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_forum_comments_created ON forum_comments(created_at DESC);

DROP TRIGGER IF EXISTS forum_comments_updated_at_trg ON forum_comments;
CREATE TRIGGER forum_comments_updated_at_trg
BEFORE UPDATE ON forum_comments
FOR EACH ROW EXECUTE FUNCTION trg_updated_at();

-- LOGIN SOCIAL (Google / Microsoft)
-- Las cuentas creadas vía OAuth no tienen contraseña propia.
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- Identidades externas vinculadas a una cuenta. Un mismo usuario puede tener
-- Google Y Microsoft enganchados (una fila por proveedor), pero cada identidad
-- externa (provider + provider_user_id) solo puede pertenecer a un usuario.
CREATE TABLE IF NOT EXISTS user_oauth_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider VARCHAR(20) NOT NULL,
  provider_user_id VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT user_oauth_accounts_provider_chk CHECK (provider IN ('google', 'microsoft')),
  UNIQUE(provider, provider_user_id),
  UNIQUE(user_id, provider)
);

CREATE INDEX IF NOT EXISTS idx_user_oauth_accounts_user_id ON user_oauth_accounts(user_id);