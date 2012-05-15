-- MBS-842, Allow vinyl style track numbers and sides by adding a free-text trackno column.

BEGIN;

CREATE TABLE tmp_track AS SELECT *, position::text AS number FROM track;

DROP TABLE track;

CREATE INDEX track_idx_recording ON tmp_track (recording);
CREATE INDEX track_idx_tracklist ON tmp_track (tracklist, position);
CREATE INDEX track_idx_name ON tmp_track (name);
CREATE INDEX track_idx_artist_credit ON tmp_track (artist_credit);

ALTER TABLE tmp_track ADD CONSTRAINT track_edits_pending_check CHECK (edits_pending >= 0);
ALTER TABLE tmp_track ADD CONSTRAINT track_length_check CHECK (length IS NULL OR length > 0);

CREATE SEQUENCE track_id_seq OWNED BY tmp_track.id;
ALTER TABLE tmp_track ALTER COLUMN id            SET DEFAULT nextval('track_id_seq'::regclass);
ALTER TABLE tmp_track ALTER COLUMN recording     SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN tracklist     SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN position      SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN number        SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN name          SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN artist_credit SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN last_updated  SET DEFAULT now();
ALTER TABLE tmp_track ALTER COLUMN edits_pending SET NOT NULL;
ALTER TABLE tmp_track ALTER COLUMN edits_pending SET DEFAULT 0;

CREATE UNIQUE INDEX track_idx_pkey ON tmp_track (id);
ALTER TABLE tmp_track ADD PRIMARY KEY (id) USING INDEX track_idx_pkey;

ALTER TABLE tmp_track RENAME TO track;

COMMIT;

