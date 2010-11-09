
\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE medium_format ADD COLUMN child_order INTEGER;
ALTER TABLE medium_format ADD COLUMN parent INTEGER;

ALTER TABLE medium_format
   ADD CONSTRAINT medium_format_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_format(id);

INSERT INTO medium_format (id, name, year, child_order, parent) VALUES
    (29, '7"', NULL, 0, 7),
    (30, '12"', NULL, 1, 7);

COMMIT;
