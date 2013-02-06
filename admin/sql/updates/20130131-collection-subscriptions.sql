BEGIN;

CREATE TABLE editor_subscribe_collection
(
    id                  SERIAL,
    editor              INTEGER NOT NULL, -- references editor.id
    collection          INTEGER NOT NULL, -- weakly references collection
    last_edit_sent      INTEGER NOT NULL  -- weakly references edit
);

ALTER TABLE editor_subscribe_collection ADD CONSTRAINT editor_subscribe_collection_pkey PRIMARY KEY (id);

ALTER TABLE editor_subscribe_collection
   ADD CONSTRAINT editor_subscribe_collection_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

CREATE UNIQUE INDEX editor_subscribe_collection_idx_uniq ON editor_subscribe_collection (editor, collection);
CREATE INDEX editor_subscribe_collection_idx_collection ON editor_subscribe_collection (collection);

COMMIT;
