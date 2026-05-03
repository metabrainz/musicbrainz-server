\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER sanitize_dbmirror2_editor_data
    BEFORE INSERT ON dbmirror2.pending_data
    FOR EACH ROW WHEN (NEW.tablename = 'musicbrainz.editor')
    EXECUTE PROCEDURE sanitize_dbmirror2_editor_data();

COMMIT;
