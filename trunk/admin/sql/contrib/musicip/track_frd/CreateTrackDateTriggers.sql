\set ON_ERROR_STOP 1

CREATE TRIGGER a_ins_release_frd AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_frd();
CREATE TRIGGER a_upd_release_frd AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_frd();
CREATE TRIGGER a_del_release_frd AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_frd();

CREATE TRIGGER a_ins_albumjoin_frd AFTER INSERT ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_ins_albumjoin_frd();
CREATE TRIGGER a_upd_albumjoin_frd AFTER UPDATE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_upd_albumjoin_frd();
CREATE TRIGGER a_del_albumjoin_frd AFTER DELETE ON albumjoin
    FOR EACH ROW EXECUTE PROCEDURE a_del_albumjoin_frd();

CREATE TRIGGER a_ins_track_frd AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track_frd();
CREATE TRIGGER b_del_track_frd BEFORE DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track_frd();

-- vi: set ts=4 sw=4 et :
