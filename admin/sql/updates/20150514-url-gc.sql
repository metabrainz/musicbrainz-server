\set ON_ERROR_STOP 1;
BEGIN;

CREATE OR REPLACE FUNCTION remove_unused_url()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME LIKE 'l_url_%' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity0]);
    END IF;

    IF TG_TABLE_NAME LIKE 'l_%_url' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.entity1]);
    END IF;

    IF TG_TABLE_NAME LIKE 'url' THEN
      EXECUTE delete_unused_url(ARRAY[OLD.id, NEW.id]);
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE CONSTRAINT TRIGGER url_gc_a_upd_url
AFTER UPDATE ON url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
