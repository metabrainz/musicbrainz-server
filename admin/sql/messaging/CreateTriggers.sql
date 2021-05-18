\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER ensure_editor_is_connected_to_message BEFORE INSERT OR UPDATE ON hidden_message
    FOR EACH ROW EXECUTE PROCEDURE ensure_editor_is_connected_to_message();

COMMIT;
