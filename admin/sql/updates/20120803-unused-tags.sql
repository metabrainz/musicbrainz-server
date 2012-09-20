BEGIN;

SET search_path = 'musicbrainz';

CREATE OR REPLACE FUNCTION delete_unused_tag(tag_id INT)
RETURNS void AS $$
  BEGIN
    DELETE FROM tag WHERE id = tag_id;
  EXCEPTION
    WHEN foreign_key_violation THEN RETURN;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION trg_delete_unused_tag()
RETURNS trigger AS $$
  BEGIN
    PERFORM delete_unused_tag(NEW.id);
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION trg_delete_unused_tag_ref()
RETURNS trigger AS $$
  BEGIN
    PERFORM delete_unused_tag(OLD.tag);
    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER INSERT ON tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON artist_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON label_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON release_group_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

CREATE CONSTRAINT TRIGGER delete_unused_tag
AFTER DELETE ON work_tag DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE trg_delete_unused_tag_ref();

COMMIT;
