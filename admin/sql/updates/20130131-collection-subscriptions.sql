BEGIN;

CREATE TABLE editor_subscribe_collection
(
    id                  SERIAL,
    editor              INTEGER NOT NULL,              -- references editor.id
    collection          INTEGER NOT NULL,              -- weakly references collection
    last_edit_sent      INTEGER NOT NULL,              -- weakly references edit
    available           BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_name      VARCHAR(255)
);

ALTER TABLE editor_subscribe_collection ADD CONSTRAINT editor_subscribe_collection_pkey PRIMARY KEY (id);

ALTER TABLE editor_subscribe_collection
   ADD CONSTRAINT editor_subscribe_collection_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

CREATE UNIQUE INDEX editor_subscribe_collection_idx_uniq ON editor_subscribe_collection (editor, collection);
CREATE INDEX editor_subscribe_collection_idx_collection ON editor_subscribe_collection (collection);

-- Create functions for UPDATE/DELETE triggers
CREATE OR REPLACE FUNCTION replace_old_sub_on_add()
RETURNS trigger AS $$
  BEGIN
    UPDATE editor_subscribe_collection
     SET available = TRUE, last_seen_name = NULL,
      last_edit_sent = NEW.last_edit_sent
     WHERE editor = NEW.editor AND collection = NEW.collection;

    IF FOUND THEN
      RETURN NULL;
    ELSE
      RETURN NEW;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION del_collection_sub_on_delete()
RETURNS trigger AS $$
  BEGIN
    UPDATE editor_subscribe_collection sub
     SET available = FALSE, last_seen_name = OLD.name
     FROM editor_collection coll
     WHERE sub.collection = OLD.id AND sub.collection = coll.id;

    RETURN OLD;
  END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION del_collection_sub_on_private()
RETURNS trigger AS $$
  BEGIN
    IF NEW.public = FALSE AND OLD.public = TRUE THEN
      UPDATE editor_subscribe_collection sub
       SET available = FALSE, last_seen_name = OLD.name
       FROM editor_collection coll
       WHERE sub.collection = OLD.id AND sub.collection = coll.id
       AND sub.editor != coll.editor;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

-- Create triggers
CREATE TRIGGER replace_old_sub_on_add BEFORE INSERT ON editor_subscribe_collection
    FOR EACH ROW EXECUTE PROCEDURE replace_old_sub_on_add();

CREATE TRIGGER del_collection_sub_on_delete BEFORE DELETE ON editor_collection
    FOR EACH ROW EXECUTE PROCEDURE del_collection_sub_on_delete();

CREATE TRIGGER del_collection_sub_on_private BEFORE UPDATE ON editor_collection
    FOR EACH ROW EXECUTE PROCEDURE del_collection_sub_on_private();

COMMIT;
