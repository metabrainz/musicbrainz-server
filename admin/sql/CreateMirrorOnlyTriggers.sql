\set ON_ERROR_STOP 1

-- This file contains triggers that are necessary (and safe) to create
-- on mirror databases. These are NOT created on master/standalone
-- databases.
--
-- The primary use case is to allow materialized tables to be kept
-- up-to-date on mirrors without having to replicate that information.
-- Since the materialized information can be fully derived from primary
-- table data, we avoid packet bloat this way.
--
-- Any functions these call should NEVER modify a replicated table! As
-- a convention, functions that are safe to call here generally end in
-- `_mirror`.

BEGIN;

CREATE TRIGGER a_ins_release_mirror AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_mirror();

CREATE TRIGGER a_upd_release_mirror AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_mirror();

CREATE TRIGGER a_del_release_mirror AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_mirror();

CREATE TRIGGER a_ins_release_event_mirror AFTER INSERT ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_mirror();

CREATE TRIGGER a_upd_release_event_mirror AFTER UPDATE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_mirror();

CREATE TRIGGER a_del_release_event_mirror AFTER DELETE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_mirror();

CREATE TRIGGER a_ins_release_event_mirror AFTER INSERT ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_mirror();

CREATE TRIGGER a_upd_release_event_mirror AFTER UPDATE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_mirror();

CREATE TRIGGER a_del_release_event_mirror AFTER DELETE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_mirror();

CREATE TRIGGER a_ins_release_group_mirror AFTER INSERT ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group_mirror();

CREATE TRIGGER a_upd_release_group_mirror AFTER UPDATE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_mirror();

CREATE TRIGGER a_del_release_group_mirror AFTER DELETE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group_mirror();

CREATE TRIGGER a_upd_release_group_meta_mirror AFTER UPDATE ON release_group_meta
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_meta_mirror();

CREATE TRIGGER a_ins_release_group_secondary_type_join_mirror AFTER INSERT ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group_secondary_type_join_mirror();

CREATE TRIGGER a_del_release_group_secondary_type_join_mirror AFTER DELETE ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group_secondary_type_join_mirror();

CREATE TRIGGER a_ins_release_label_mirror AFTER INSERT ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_label_mirror();

CREATE TRIGGER a_upd_release_label_mirror AFTER UPDATE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_label_mirror();

CREATE TRIGGER a_del_release_label_mirror AFTER DELETE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_label_mirror();

CREATE TRIGGER a_ins_track_mirror AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track_mirror();

CREATE TRIGGER a_upd_track_mirror AFTER UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_upd_track_mirror();

CREATE TRIGGER a_del_track_mirror AFTER DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track_mirror();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release_country DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release_first_release_date DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER UPDATE ON release_group_meta DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER INSERT OR DELETE ON release_group_secondary_type_join DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON release_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_group_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON track DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_group_pending_updates();

CREATE CONSTRAINT TRIGGER apply_artist_release_pending_updates_mirror
    AFTER INSERT OR UPDATE OR DELETE ON track DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE apply_artist_release_pending_updates();

COMMIT;
