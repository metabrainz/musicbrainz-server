\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE work_language
   ADD CONSTRAINT work_language_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_language
   ADD CONSTRAINT work_language_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

COMMIT;
