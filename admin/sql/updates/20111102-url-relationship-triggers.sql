BEGIN;

CREATE OR REPLACE FUNCTION delete_unused_url(ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  DELETE FROM url url_row WHERE id = any(ids)
  AND NOT (
    EXISTS (
      SELECT TRUE FROM l_artist_url
      WHERE entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_label_url
      WHERE entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_recording_url
      WHERE entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_release_url
      WHERE entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_release_group_url
      WHERE entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_url_url
      WHERE entity0 = url_row.id OR entity1 = url_row.id
      LIMIT 1
    ) OR
    EXISTS (
      SELECT TRUE FROM l_url_work
      WHERE entity0 = url_row.id
      LIMIT 1
    )
  );
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION remove_unused_url()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME LIKE 'l_url_%' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity0]);
    END IF;

    IF TG_TABLE_NAME LIKE 'l_%_url' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity1]);
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER url_gc_a_upd_l_artist_url
AFTER UPDATE ON l_artist_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_artist_url
AFTER DELETE ON l_artist_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_label_url
AFTER UPDATE ON l_label_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_label_url
AFTER DELETE ON l_label_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_recording_url
AFTER UPDATE ON l_recording_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_recording_url
AFTER DELETE ON l_recording_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_release_url
AFTER UPDATE ON l_release_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_release_url
AFTER DELETE ON l_release_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_release_group_url
AFTER UPDATE ON l_release_group_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_release_group_url
AFTER DELETE ON l_release_group_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_url_url
AFTER UPDATE ON l_url_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_url_url
AFTER DELETE ON l_url_url FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE TRIGGER url_gc_a_upd_l_url_work
AFTER UPDATE ON l_url_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();
CREATE TRIGGER url_gc_a_del_l_url_work
AFTER DELETE ON l_url_work FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
