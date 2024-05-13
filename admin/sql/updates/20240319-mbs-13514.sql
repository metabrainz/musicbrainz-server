\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE label ADD CONSTRAINT label_code_length CHECK (label_code > 0 AND label_code < 1000000);

COMMIT;
