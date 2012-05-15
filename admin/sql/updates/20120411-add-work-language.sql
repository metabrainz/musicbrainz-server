-- MBS-1798, Add work language

BEGIN;

ALTER TABLE work ADD COLUMN language INTEGER;

COMMIT;

