\set ON_ERROR_STOP 1

BEGIN;

-- Artist credit GID

-- Creating column
ALTER TABLE artist_credit ADD COLUMN gid uuid;

-- Generating GIDs
UPDATE artist_credit SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'artist_credit' || id);

-- Adding NOT NULL constraint
ALTER TABLE artist_credit ALTER COLUMN gid SET NOT NULL;

-- Creating index
CREATE UNIQUE INDEX artist_credit_idx_gid ON artist_credit (gid);

-- Artist credit GID redirect
CREATE TABLE artist_credit_gid_redirect ( -- replicate (verbose)
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references artist_credit.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE artist_credit_gid_redirect ADD CONSTRAINT artist_credit_gid_redirect_pkey PRIMARY KEY (gid);

CREATE INDEX artist_credit_gid_redirect_idx_new_id ON artist_credit_gid_redirect (new_id);

COMMIT;
