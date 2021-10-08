\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION restore_collection_sub_on_public()
RETURNS trigger AS $$
  BEGIN
    IF NEW.public = TRUE AND OLD.public = FALSE THEN
      UPDATE editor_subscribe_collection sub
         SET available = TRUE,
             last_seen_name = NEW.name
       WHERE sub.collection = OLD.id
         AND sub.available = FALSE;
    END IF;

    RETURN NULL;
  END;
$$ LANGUAGE 'plpgsql';

-- Create triggers
CREATE TRIGGER restore_collection_sub_on_public AFTER UPDATE ON editor_collection
    FOR EACH ROW EXECUTE PROCEDURE restore_collection_sub_on_public();

COMMIT;
