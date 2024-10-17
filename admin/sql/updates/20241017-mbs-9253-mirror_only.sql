\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS a_upd_release_group_primary_type_mirror ON release_group_primary_type;

CREATE TRIGGER a_upd_release_group_primary_type_mirror AFTER UPDATE ON release_group_primary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_primary_type_mirror();

DROP TRIGGER IF EXISTS a_upd_release_group_secondary_type_mirror ON release_group_secondary_type;

CREATE TRIGGER a_upd_release_group_secondary_type_mirror AFTER UPDATE ON release_group_secondary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_secondary_type_mirror();

DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release_group_primary_type;

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER UPDATE ON release_group_primary_type DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    WHEN (OLD.child_order IS DISTINCT FROM NEW.child_order)
    EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

DROP TRIGGER IF EXISTS apply_artist_release_group_pending_updates_mirror ON release_group_secondary_type;

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER UPDATE ON release_group_secondary_type DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    WHEN (OLD.child_order IS DISTINCT FROM NEW.child_order)
    EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

COMMIT;
