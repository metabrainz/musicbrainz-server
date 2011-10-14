BEGIN;

CREATE OR REPLACE FUNCTION remove_unused_links()
RETURNS TRIGGER AS $$
DECLARE
    other_ars_exist BOOLEAN;
BEGIN
    EXECUTE 'SELECT EXISTS (SELECT TRUE FROM ' || quote_ident(TG_TABLE_NAME) ||
            ' WHERE link = $1)'
    INTO other_ars_exist
    USING OLD.link;

    RAISE NOTICE '%', other_ars_exist;
    IF NOT other_ars_exist THEN
       RAISE NOTICE 'no other ARs exist';
       DELETE FROM link_attribute WHERE link = OLD.link;
       DELETE FROM link WHERE id = OLD.link;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_upd_l_artist_artist AFTER UPDATE ON l_artist_artist FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_artist AFTER DELETE ON l_artist_artist FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_label AFTER UPDATE ON l_artist_label FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_label AFTER DELETE ON l_artist_label FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_recording AFTER UPDATE ON l_artist_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_recording AFTER DELETE ON l_artist_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_release AFTER UPDATE ON l_artist_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_release AFTER DELETE ON l_artist_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_release_group AFTER UPDATE ON l_artist_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_release_group AFTER DELETE ON l_artist_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_url AFTER UPDATE ON l_artist_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_url AFTER DELETE ON l_artist_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_artist_work AFTER UPDATE ON l_artist_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_artist_work AFTER DELETE ON l_artist_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_label AFTER UPDATE ON l_label_label FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_label AFTER DELETE ON l_label_label FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_recording AFTER UPDATE ON l_label_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_recording AFTER DELETE ON l_label_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_release AFTER UPDATE ON l_label_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_release AFTER DELETE ON l_label_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_release_group AFTER UPDATE ON l_label_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_release_group AFTER DELETE ON l_label_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_url AFTER UPDATE ON l_label_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_url AFTER DELETE ON l_label_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_label_work AFTER UPDATE ON l_label_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_label_work AFTER DELETE ON l_label_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_recording_recording AFTER UPDATE ON l_recording_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_recording_recording AFTER DELETE ON l_recording_recording FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_recording_release AFTER UPDATE ON l_recording_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_recording_release AFTER DELETE ON l_recording_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_recording_release_group AFTER UPDATE ON l_recording_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_recording_release_group AFTER DELETE ON l_recording_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_recording_url AFTER UPDATE ON l_recording_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_recording_url AFTER DELETE ON l_recording_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_recording_work AFTER UPDATE ON l_recording_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_recording_work AFTER DELETE ON l_recording_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_release AFTER UPDATE ON l_release_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_release AFTER DELETE ON l_release_release FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_release_group AFTER UPDATE ON l_release_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_release_group AFTER DELETE ON l_release_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_url AFTER UPDATE ON l_release_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_url AFTER DELETE ON l_release_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_work AFTER UPDATE ON l_release_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_work AFTER DELETE ON l_release_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_group_release_group AFTER UPDATE ON l_release_group_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_group_release_group AFTER DELETE ON l_release_group_release_group FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_group_url AFTER UPDATE ON l_release_group_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_group_url AFTER DELETE ON l_release_group_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_release_group_work AFTER UPDATE ON l_release_group_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_release_group_work AFTER DELETE ON l_release_group_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_url_url AFTER UPDATE ON l_url_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_url_url AFTER DELETE ON l_url_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_url_work AFTER UPDATE ON l_url_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_url_work AFTER DELETE ON l_url_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE TRIGGER a_upd_l_work_work AFTER UPDATE ON l_work_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE TRIGGER a_del_l_work_work AFTER DELETE ON l_work_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

COMMIT;
