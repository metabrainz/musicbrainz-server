\set ON_ERROR_STOP 1
BEGIN;

DROP TRIGGER IF EXISTS b_upd_l_event_url ON l_event_url;
DROP TRIGGER IF EXISTS remove_unused_links ON l_event_url;
DROP TRIGGER IF EXISTS url_gc_a_del_l_event_url ON l_event_url;
DROP TRIGGER IF EXISTS url_gc_a_upd_l_event_url ON l_event_url;

CREATE TRIGGER b_upd_l_event_url
    BEFORE UPDATE ON l_event_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_event_url
    AFTER DELETE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_event_url
    AFTER UPDATE ON l_event_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
