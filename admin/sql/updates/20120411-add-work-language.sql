-- MBS-1798, Add work language

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE work ADD COLUMN language INTEGER;

COMMIT;

