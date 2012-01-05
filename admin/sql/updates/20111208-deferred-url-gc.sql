BEGIN;

DROP TRIGGER url_gc_a_upd_l_artist_url ON l_artist_url;
DROP TRIGGER url_gc_a_del_l_artist_url ON l_artist_url;
DROP TRIGGER url_gc_a_upd_l_label_url ON l_label_url;
DROP TRIGGER url_gc_a_del_l_label_url ON l_label_url;
DROP TRIGGER url_gc_a_upd_l_recording_url ON l_recording_url;
DROP TRIGGER url_gc_a_del_l_recording_url ON l_recording_url;
DROP TRIGGER url_gc_a_upd_l_release_url ON l_release_url;
DROP TRIGGER url_gc_a_del_l_release_url ON l_release_url;
DROP TRIGGER url_gc_a_upd_l_release_group_url ON l_release_group_url;
DROP TRIGGER url_gc_a_del_l_release_group_url ON l_release_group_url;
DROP TRIGGER url_gc_a_upd_l_url_url ON l_url_url;
DROP TRIGGER url_gc_a_del_l_url_url ON l_url_url;
DROP TRIGGER url_gc_a_upd_l_url_work ON l_url_work;
DROP TRIGGER url_gc_a_del_l_url_work ON l_url_work;

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_artist_url
AFTER UPDATE ON l_artist_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_artist_url
AFTER DELETE ON l_artist_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_label_url
AFTER UPDATE ON l_label_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_label_url
AFTER DELETE ON l_label_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_recording_url
AFTER UPDATE ON l_recording_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_recording_url
AFTER DELETE ON l_recording_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_release_url
AFTER UPDATE ON l_release_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_release_url
AFTER DELETE ON l_release_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_release_group_url
AFTER UPDATE ON l_release_group_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_release_group_url
AFTER DELETE ON l_release_group_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_url_url
AFTER UPDATE ON l_url_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_url_url
AFTER DELETE ON l_url_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_url_work
AFTER UPDATE ON l_url_work DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_url_work
AFTER DELETE ON l_url_work DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
