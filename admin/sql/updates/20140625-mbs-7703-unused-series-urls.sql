\set ON_ERROR_STOP 1
BEGIN;

DO $$
DECLARE
    relevant_urls integer[];
BEGIN
    SELECT array_agg(url) FROM edit_url eu JOIN edit_series es ON es.edit = eu.edit INTO relevant_urls;
    PERFORM delete_unused_url(relevant_urls);
END $$;

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_series_url
AFTER UPDATE ON l_series_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_series_url
AFTER DELETE ON l_series_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
