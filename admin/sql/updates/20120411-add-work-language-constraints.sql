\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE work ADD CONSTRAINT work_fk_language FOREIGN KEY (language) REFERENCES language (id);

COMMIT;
