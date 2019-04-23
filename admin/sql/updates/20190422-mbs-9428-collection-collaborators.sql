\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE editor_collection_collaborator (
    collection INTEGER NOT NULL, -- PK, references editor_collection.id
    editor INTEGER NOT NULL -- references editor.id
);

ALTER TABLE editor_collection_collaborator ADD CONSTRAINT editor_collection_collaborator_pkey PRIMARY KEY (collection, editor);

COMMIT;
