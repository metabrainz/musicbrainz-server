\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE area          ADD CHECK (controlled_for_whitespace(comment));

COMMIT;
