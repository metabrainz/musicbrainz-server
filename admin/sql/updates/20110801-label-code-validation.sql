BEGIN;

UPDATE label SET label_code = NULL WHERE label_code <= 0;
ALTER TABLE label ADD CONSTRAINT label_label_code_check CHECK (label_code > 0);

COMMIT;
