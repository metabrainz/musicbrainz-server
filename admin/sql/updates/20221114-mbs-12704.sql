\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS a_ins_editor ON editor;

DROP FUNCTION a_ins_editor();

DROP TABLE editor_watch_artist;
DROP TABLE editor_watch_preferences;
DROP TABLE editor_watch_release_group_type;
DROP TABLE editor_watch_release_status;

COMMIT;
