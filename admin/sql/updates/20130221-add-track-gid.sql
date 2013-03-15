\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE track ADD COLUMN gid UUID;
UPDATE track SET gid = generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8',
       'http://musicbrainz.org/track/' || id);
        -- ^ fake URI, like ian's /country/ URI for MBS-5919.


COMMIT; -- execute triggers.

BEGIN;

ALTER TABLE track ALTER COLUMN gid SET not null;

CREATE TABLE track_gid_redirect
(
    gid                 UUID NOT NULL, -- PK
    new_id              INTEGER NOT NULL, -- references track.id
    created             TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE track_gid_redirect
    ADD CONSTRAINT track_gid_redirect_pkey
    PRIMARY KEY (gid);

COMMIT;

