\set ON_ERROR_STOP 1
BEGIN;


CREATE TRIGGER a_ins_artist AFTER INSERT ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist();

CREATE TRIGGER a_upd_artist AFTER UPDATE ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist();

CREATE TRIGGER a_del_artist AFTER DELETE ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist();


CREATE TRIGGER a_ins_artist_alias AFTER INSERT ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist_alias();

CREATE TRIGGER a_upd_artist_alias AFTER UPDATE ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist_alias();

CREATE TRIGGER a_del_artist_alias AFTER DELETE ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist_alias();


CREATE TRIGGER a_ins_artist_credit_name AFTER INSERT ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist_credit_name();

CREATE TRIGGER a_upd_artist_credit_name AFTER UPDATE ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist_credit_name();

CREATE TRIGGER a_del_artist_credit_name AFTER DELETE ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist_credit_name();


CREATE TRIGGER a_ins_label AFTER INSERT ON label
    FOR EACH ROW EXECUTE PROCEDURE a_ins_label();

CREATE TRIGGER a_upd_label AFTER UPDATE ON label
    FOR EACH ROW EXECUTE PROCEDURE a_upd_label();

CREATE TRIGGER a_del_label AFTER DELETE ON label
    FOR EACH ROW EXECUTE PROCEDURE a_del_label();


CREATE TRIGGER a_ins_label_alias AFTER INSERT ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_ins_label_alias();

CREATE TRIGGER a_upd_label_alias AFTER UPDATE ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_upd_label_alias();

CREATE TRIGGER a_del_label_alias AFTER DELETE ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE a_del_label_alias();


CREATE TRIGGER a_ins_recording AFTER INSERT ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_ins_recording();

CREATE TRIGGER a_upd_recording AFTER UPDATE ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_upd_recording();

CREATE TRIGGER a_del_recording AFTER DELETE ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_del_recording();


CREATE TRIGGER a_ins_release AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release();

CREATE TRIGGER a_upd_release AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release();

CREATE TRIGGER a_del_release AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release();


CREATE TRIGGER a_ins_release_group AFTER INSERT ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group();

CREATE TRIGGER a_upd_release_group AFTER UPDATE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group();

CREATE TRIGGER a_del_release_group AFTER DELETE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group();


CREATE TRIGGER a_ins_track AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track();

CREATE TRIGGER a_upd_track AFTER UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_upd_track();

CREATE TRIGGER a_del_track AFTER DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track();


CREATE TRIGGER a_ins_work AFTER INSERT ON work
    FOR EACH ROW EXECUTE PROCEDURE a_ins_work();

CREATE TRIGGER a_upd_work AFTER UPDATE ON work
    FOR EACH ROW EXECUTE PROCEDURE a_upd_work();

CREATE TRIGGER a_del_work AFTER DELETE ON work
    FOR EACH ROW EXECUTE PROCEDURE a_del_work();


COMMIT;

-- vi: set ts=4 sw=4 et :
