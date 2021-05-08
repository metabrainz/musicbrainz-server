\set ON_ERROR_STOP 1

BEGIN;

CREATE TYPE oauth_code_challenge_method AS ENUM ('plain', 'S256');
ALTER TABLE editor_oauth_token ADD COLUMN code_challenge TEXT;
ALTER TABLE editor_oauth_token ADD COLUMN code_challenge_method oauth_code_challenge_method;
ALTER TABLE editor_oauth_token ADD CONSTRAINT valid_code_challenge CHECK (
  (code_challenge IS NULL) = (code_challenge_method IS NULL) AND
  (code_challenge IS NULL OR code_challenge ~ E'^[A-Za-z0-9.~_-]{43,128}$')
);

COMMIT;
