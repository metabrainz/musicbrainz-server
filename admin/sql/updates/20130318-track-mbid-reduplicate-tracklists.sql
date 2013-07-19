\set ON_ERROR_STOP 1
BEGIN;

-- Rebuild tracklist_index as medium_index
CREATE TABLE medium_index AS
  SELECT medium.id AS medium, toc
  FROM tracklist_index
  JOIN tracklist ON tracklist.id = tracklist_index.tracklist
  JOIN medium ON tracklist.id = medium.tracklist;

DROP TABLE tracklist_index;

ALTER TABLE medium_index
  ALTER COLUMN medium SET NOT NULL,
  ADD PRIMARY KEY (medium);

CREATE INDEX medium_index_idx ON medium_index USING GIST (toc);


-- Rebuild track to point to medium, not tracklist
CREATE SEQUENCE track2013_id_seq START 1;

CREATE TABLE track2013 AS
    SELECT nextval('track2013_id_seq')::int AS id,
           generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8',
           'http://musicbrainz.org/track/' || currval('track2013_id_seq') ) AS gid,
           track.recording, medium.id AS medium,
           track.position, track.number,
           track.name, track.artist_credit, track.length,
           track.edits_pending, track.last_updated
    FROM track
    JOIN medium ON medium.tracklist = track.tracklist
    ORDER BY track.id, medium.id;

DROP TABLE track;

ALTER SEQUENCE track2013_id_seq OWNED BY track2013.id;
ALTER SEQUENCE track2013_id_seq RENAME TO track_id_seq;

ALTER TABLE track2013
  ADD CHECK (controlled_for_whitespace(number)),
  ADD CHECK (edits_pending >= 0),
  ADD CHECK (length IS NULL OR length > 0),
  ADD PRIMARY KEY (id),
  ALTER COLUMN artist_credit SET NOT NULL,
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN gid SET NOT NULL,
  ALTER COLUMN id SET DEFAULT nextval('track_id_seq'),
  ALTER COLUMN last_updated SET DEFAULT NOW(),
  ALTER COLUMN medium SET NOT NULL,
  ALTER COLUMN name SET NOT NULL,
  ALTER COLUMN number SET NOT NULL,
  ALTER COLUMN position SET NOT NULL,
  ALTER COLUMN recording SET NOT NULL;


-- Rebuild medium to have track_count but no track_list
CREATE TABLE medium2013 AS
  SELECT medium.id, medium.release, medium.position, medium.format, medium.name,
    medium.edits_pending, medium.last_updated, tracklist.track_count
  FROM medium
  JOIN tracklist ON tracklist.id = medium.tracklist;

ALTER TABLE medium2013
  ADD CONSTRAINT medium_edits_pending CHECK (edits_pending >= 0),
  ADD PRIMARY KEY (id),
  ALTER COLUMN edits_pending SET DEFAULT 0,
  ALTER COLUMN edits_pending SET NOT NULL,
  ALTER COLUMN id SET DEFAULT nextval('medium_id_seq'),
  ALTER COLUMN id SET NOT NULL,
  ALTER COLUMN last_updated SET DEFAULT now(),
  ALTER COLUMN position SET NOT NULL,
  ALTER COLUMN release SET NOT NULL,
  ALTER COLUMN track_count SET NOT NULL,
  ALTER COLUMN track_count SET DEFAULT 0;

ALTER SEQUENCE medium_id_seq OWNED BY medium2013.id;

ALTER TABLE medium_cdtoc
  DROP CONSTRAINT IF EXISTS medium_cdtoc_fk_medium;

DROP TABLE medium;
DROP TABLE tracklist;

ALTER TABLE track2013 RENAME TO track;
ALTER TABLE medium2013 RENAME TO medium;

CREATE INDEX medium_idx_track_count ON medium (track_count);

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
