BEGIN;

ALTER TABLE release_label ADD CHECK (controlled_for_whitespace(catalog_number));

COMMIT;
