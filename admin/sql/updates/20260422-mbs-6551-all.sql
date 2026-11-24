\set ON_ERROR_STOP 1

BEGIN;

-- Prepare data for the `no_empty_string_catalog_number` constraint
-- in admin/sql/updates/20260422-mbs-6551-master_and_standalone.sql.
UPDATE release_label SET catalog_number = NULL WHERE catalog_number = '';

-- This is mainly present for standalone databases. "Remove release label"
-- edits were already manually entered for the few duplicates that existed
-- in production.
DELETE FROM release_label dupe
USING release_label orig
WHERE dupe.release = orig.release
  AND dupe.label IS NOT DISTINCT FROM orig.label
  AND dupe.catalog_number IS NOT DISTINCT FROM orig.catalog_number
  AND dupe.id > orig.id;

COMMIT;
