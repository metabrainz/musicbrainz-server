BEGIN;

DROP TRIGGER a_upd_l_artist_artist ON l_artist_artist;
DROP TRIGGER a_del_l_artist_artist ON l_artist_artist;
DROP TRIGGER a_upd_l_artist_label ON l_artist_label;
DROP TRIGGER a_del_l_artist_label ON l_artist_label;
DROP TRIGGER a_upd_l_artist_recording ON l_artist_recording;
DROP TRIGGER a_del_l_artist_recording ON l_artist_recording;
DROP TRIGGER a_upd_l_artist_release ON l_artist_release;
DROP TRIGGER a_del_l_artist_release ON l_artist_release;
DROP TRIGGER a_upd_l_artist_release_group ON l_artist_release_group;
DROP TRIGGER a_del_l_artist_release_group ON l_artist_release_group;
DROP TRIGGER a_upd_l_artist_url ON l_artist_url;
DROP TRIGGER a_del_l_artist_url ON l_artist_url;
DROP TRIGGER a_upd_l_artist_work ON l_artist_work;
DROP TRIGGER a_del_l_artist_work ON l_artist_work;
DROP TRIGGER a_upd_l_label_label ON l_label_label;
DROP TRIGGER a_del_l_label_label ON l_label_label;
DROP TRIGGER a_upd_l_label_recording ON l_label_recording;
DROP TRIGGER a_del_l_label_recording ON l_label_recording;
DROP TRIGGER a_upd_l_label_release ON l_label_release;
DROP TRIGGER a_del_l_label_release ON l_label_release;
DROP TRIGGER a_upd_l_label_release_group ON l_label_release_group;
DROP TRIGGER a_del_l_label_release_group ON l_label_release_group;
DROP TRIGGER a_upd_l_label_url ON l_label_url;
DROP TRIGGER a_del_l_label_url ON l_label_url;
DROP TRIGGER a_upd_l_label_work ON l_label_work;
DROP TRIGGER a_del_l_label_work ON l_label_work;
DROP TRIGGER a_upd_l_recording_recording ON l_recording_recording;
DROP TRIGGER a_del_l_recording_recording ON l_recording_recording;
DROP TRIGGER a_upd_l_recording_release ON l_recording_release;
DROP TRIGGER a_del_l_recording_release ON l_recording_release;
DROP TRIGGER a_upd_l_recording_release_group ON l_recording_release_group;
DROP TRIGGER a_del_l_recording_release_group ON l_recording_release_group;
DROP TRIGGER a_upd_l_recording_url ON l_recording_url;
DROP TRIGGER a_del_l_recording_url ON l_recording_url;
DROP TRIGGER a_upd_l_recording_work ON l_recording_work;
DROP TRIGGER a_del_l_recording_work ON l_recording_work;
DROP TRIGGER a_upd_l_release_release ON l_release_release;
DROP TRIGGER a_del_l_release_release ON l_release_release;
DROP TRIGGER a_upd_l_release_release_group ON l_release_release_group;
DROP TRIGGER a_del_l_release_release_group ON l_release_release_group;
DROP TRIGGER a_upd_l_release_url ON l_release_url;
DROP TRIGGER a_del_l_release_url ON l_release_url;
DROP TRIGGER a_upd_l_release_work ON l_release_work;
DROP TRIGGER a_del_l_release_work ON l_release_work;
DROP TRIGGER a_upd_l_release_group_release_group ON l_release_group_release_group;
DROP TRIGGER a_del_l_release_group_release_group ON l_release_group_release_group;
DROP TRIGGER a_upd_l_release_group_url ON l_release_group_url;
DROP TRIGGER a_del_l_release_group_url ON l_release_group_url;
DROP TRIGGER a_upd_l_release_group_work ON l_release_group_work;
DROP TRIGGER a_del_l_release_group_work ON l_release_group_work;
DROP TRIGGER a_upd_l_url_url ON l_url_url;
DROP TRIGGER a_del_l_url_url ON l_url_url;
DROP TRIGGER a_upd_l_url_work ON l_url_work;
DROP TRIGGER a_del_l_url_work ON l_url_work;
DROP TRIGGER a_upd_l_work_work ON l_work_work;
DROP TRIGGER a_del_l_work_work ON l_work_work;

--------------------------------------------------------------------------------
CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_artist DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_recording_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_recording_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_recording_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_recording_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_recording_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_group_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_group_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_release_group_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_url_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_url_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_work_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
--------------------------------------------------------------------------------

ROLLBACK;
