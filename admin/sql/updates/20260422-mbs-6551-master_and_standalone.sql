\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE release_label
  ADD CONSTRAINT no_empty_string_catalog_number
  CHECK (catalog_number != '');

ALTER TABLE release_label
  ADD CONSTRAINT release_label_uniq
  UNIQUE NULLS NOT DISTINCT (release, label, catalog_number)
  DEFERRABLE INITIALLY DEFERRED;

COMMIT;
