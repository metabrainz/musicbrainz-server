\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS check_editor_name ON editor;
DROP FUNCTION IF EXISTS check_editor_name();
DROP TABLE IF EXISTS old_editor_name CASCADE;

COMMIT;
