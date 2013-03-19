\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE medium ADD COLUMN track_count INTEGER NOT NULL DEFAULT 0;

UPDATE medium SET track_count = tracklist.track_count
    FROM tracklist WHERE medium.tracklist = tracklist.id;

CREATE INDEX medium_idx_track_count ON medium (track_count);

CREATE SEQUENCE track2013_id_seq START 1;
CREATE TABLE track2013 AS
    SELECT nextval('track2013_id_seq') AS id, generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8',
                        'http://musicbrainz.org/track/' || currval('track2013_id_seq') ) AS gid,
           track.recording, medium.id AS medium,
           track.position, track.number,
           track.name, track.artist_credit, track.length,
           track.edits_pending, track.last_updated
    FROM track
    JOIN medium ON medium.tracklist = track.tracklist;

DROP TABLE track;
ALTER TABLE medium DROP COLUMN tracklist;
DROP TABLE tracklist;

ALTER TABLE track2013 RENAME TO track;
ALTER SEQUENCE track2013_id_seq RENAME TO track_id_seq;

ALTER TABLE track ADD PRIMARY KEY (id);
ALTER TABLE track ALTER COLUMN id SET DEFAULT nextval('track_id_seq');

ALTER TABLE track ALTER COLUMN gid SET NOT NULL;
ALTER TABLE track ALTER COLUMN recording SET NOT NULL;
ALTER TABLE track ALTER COLUMN medium SET NOT NULL;
ALTER TABLE track ALTER COLUMN position SET NOT NULL;
ALTER TABLE track ALTER COLUMN number SET NOT NULL;
ALTER TABLE track ADD CHECK (controlled_for_whitespace(number));
ALTER TABLE track ALTER COLUMN name SET NOT NULL;
ALTER TABLE track ALTER COLUMN artist_credit SET NOT NULL;
ALTER TABLE track ADD CHECK (length IS NULL OR length > 0);
ALTER TABLE track ALTER COLUMN edits_pending SET NOT NULL;
ALTER TABLE track ALTER COLUMN edits_pending SET DEFAULT 0;
ALTER TABLE track ADD CHECK (edits_pending >= 0);
ALTER TABLE track ALTER COLUMN last_updated SET DEFAULT NOW();

CREATE INDEX track_idx_artist_credit ON track (artist_credit);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_recording ON track (recording);
CREATE INDEX track_idx_medium ON track (medium, position);
CREATE UNIQUE INDEX track_idx_gid ON track (gid);

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