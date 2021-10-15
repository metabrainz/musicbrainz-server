\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION del_collection_sub_on_private()
RETURNS trigger AS $$
  BEGIN
    IF NEW.public = FALSE AND OLD.public = TRUE THEN
      UPDATE editor_subscribe_collection sub
         SET available = FALSE,
             last_seen_name = OLD.name
       WHERE sub.collection = OLD.id
         AND sub.editor != NEW.editor
         AND sub.editor NOT IN (SELECT ecc.editor
                                  FROM editor_collection_collaborator ecc
                                 WHERE ecc.collection = sub.collection);
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

COMMIT;
