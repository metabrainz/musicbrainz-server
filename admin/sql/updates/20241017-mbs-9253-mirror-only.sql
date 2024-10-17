\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS a_upd_release_group_primary_type_mirror ON release_group_primary_type;
DROP TRIGGER IF EXISTS a_upd_release_group_secondary_type_mirror ON release_group_secondary_type;

CREATE TRIGGER a_upd_release_group_primary_type_mirror AFTER UPDATE ON release_group_primary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_primary_type_mirror();

CREATE TRIGGER a_upd_release_group_secondary_type_mirror AFTER UPDATE ON release_group_secondary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_secondary_type_mirror();

COMMIT;
