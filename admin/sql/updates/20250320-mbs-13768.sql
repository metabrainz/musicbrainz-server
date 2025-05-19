\set ON_ERROR_STOP 1

BEGIN;

-- Medium GID

-- Creating column
ALTER TABLE medium ADD COLUMN gid uuid;

-- Generating GIDs
UPDATE medium SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'medium' || id);

-- Adding NOT NULL constraint
ALTER TABLE medium ALTER COLUMN gid SET NOT NULL;

-- Creating index
CREATE UNIQUE INDEX medium_idx_gid ON medium (gid);

-- Medium GID redirect
CREATE TABLE medium_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references medium.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE medium_gid_redirect ADD CONSTRAINT medium_gid_redirect_pkey PRIMARY KEY (gid);

CREATE INDEX medium_gid_redirect_idx_new_id ON medium_gid_redirect (new_id);

COMMIT;
