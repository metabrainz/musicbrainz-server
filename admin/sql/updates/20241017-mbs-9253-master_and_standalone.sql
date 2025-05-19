\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

ALTER TABLE artist_release_group
   ADD CONSTRAINT artist_release_group_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE artist_release_group
   ADD CONSTRAINT artist_release_group_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id)
   ON DELETE CASCADE;

CREATE TRIGGER a_upd_release_group_primary_type AFTER UPDATE ON release_group_primary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_primary_type_mirror();

CREATE TRIGGER a_upd_release_group_secondary_type AFTER UPDATE ON release_group_secondary_type
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_secondary_type_mirror();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER UPDATE ON release_group_primary_type DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    WHEN (OLD.child_order IS DISTINCT FROM NEW.child_order)
    EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates
    AFTER UPDATE ON release_group_secondary_type DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    WHEN (OLD.child_order IS DISTINCT FROM NEW.child_order)
    EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

COMMIT;
