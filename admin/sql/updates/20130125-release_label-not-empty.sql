BEGIN;

DELETE FROM release_label WHERE catalog_number IS NULL AND label IS NULL;

ALTER TABLE release_label ADD CHECK (catalog_number IS NOT NULL OR label IS NOT NULL);

COMMIT;
