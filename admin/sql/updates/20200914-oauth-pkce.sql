\set ON_ERROR_STOP 1

BEGIN;

DO $$
BEGIN
  PERFORM 1 FROM pg_type
  WHERE typname = 'oauth_code_challenge_method';

  IF NOT FOUND THEN
    CREATE TYPE oauth_code_challenge_method AS ENUM ('plain', 'S256');
  END IF;
END
$$;

ALTER TABLE editor_oauth_token ADD COLUMN IF NOT EXISTS code_challenge TEXT;
ALTER TABLE editor_oauth_token ADD COLUMN IF NOT EXISTS code_challenge_method oauth_code_challenge_method;

DO $$
BEGIN
  PERFORM 1 FROM information_schema.constraint_column_usage
  WHERE table_name = 'editor_oauth_token'
  AND constraint_name = 'valid_code_challenge';

  IF NOT FOUND THEN
    ALTER TABLE editor_oauth_token ADD CONSTRAINT valid_code_challenge CHECK (
      (code_challenge IS NULL) = (code_challenge_method IS NULL) AND
      (code_challenge IS NULL OR code_challenge ~ E'^[A-Za-z0-9.~_-]{43,128}$')
    );
  END IF;
END
$$;

COMMIT;
