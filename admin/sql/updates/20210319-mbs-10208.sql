\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE editor_collection_gid_redirect (
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references editor_collection.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE editor_collection_gid_redirect
    ADD CONSTRAINT editor_collection_gid_redirect_pkey
    PRIMARY KEY (gid);

CREATE INDEX editor_collection_gid_redirect_idx_new_id ON editor_collection_gid_redirect (new_id);

COMMIT;
