BEGIN;

ALTER TABLE medium_format ADD COLUMN has_discids BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE medium_format SET has_discids = TRUE WHERE id IN ( 1, 3, 4, 13, 25 );

COMMIT;
