\set ON_ERROR_STOP 1

-- This file contains triggers that are necessary (and safe) to create
-- on slave databases. These are NOT created on master/standalone
-- databases.
--
-- The primary use case is to allow materialized tables to be kept
-- up-to-date on slaves without having to replicate that information.
-- Since the materialized information can be fully derived from primary
-- table data, we avoid packet bloat this way.
--
-- Any functions these call should NEVER modify a replicated table! As
-- a convention, functions that are safe to call here generally end in
-- `_slave`.

BEGIN;

CREATE TRIGGER a_ins_release_slave AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_slave();

CREATE TRIGGER a_upd_release_slave AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_slave();

CREATE TRIGGER a_del_release_slave AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_slave();

CREATE TRIGGER a_ins_release_event_slave AFTER INSERT ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_slave();

CREATE TRIGGER a_upd_release_event_slave AFTER UPDATE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_slave();

CREATE TRIGGER a_del_release_event_slave AFTER DELETE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_slave();

CREATE TRIGGER a_ins_release_event_slave AFTER INSERT ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_slave();

CREATE TRIGGER a_upd_release_event_slave AFTER UPDATE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_slave();

CREATE TRIGGER a_del_release_event_slave AFTER DELETE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_slave();

CREATE TRIGGER a_ins_release_group_slave AFTER INSERT ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group_slave();

CREATE TRIGGER a_upd_release_group_slave AFTER UPDATE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_slave();

CREATE TRIGGER a_del_release_group_slave AFTER DELETE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group_slave();

CREATE TRIGGER a_upd_release_group_meta_slave AFTER UPDATE ON release_group_meta
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group_meta_slave();

CREATE TRIGGER a_ins_release_group_secondary_type_join_slave AFTER INSERT ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group_secondary_type_join_slave();

CREATE TRIGGER a_del_release_group_secondary_type_join_slave AFTER DELETE ON release_group_secondary_type_join
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group_secondary_type_join_slave();

CREATE TRIGGER a_ins_release_label_slave AFTER INSERT ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_label_slave();

CREATE TRIGGER a_upd_release_label_slave AFTER UPDATE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_label_slave();

CREATE TRIGGER a_del_release_label_slave AFTER DELETE ON release_label
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_label_slave();

CREATE TRIGGER a_ins_track_slave AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track_slave();

CREATE TRIGGER a_upd_track_slave AFTER UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_upd_track_slave();

CREATE TRIGGER a_del_track_slave AFTER DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track_slave();

COMMIT;
