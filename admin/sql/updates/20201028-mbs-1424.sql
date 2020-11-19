\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

CREATE TABLE recording_first_release_date (
  recording   INTEGER NOT NULL,
  year        SMALLINT,
  month       SMALLINT,
  day         SMALLINT
);

CREATE OR REPLACE VIEW recording_release_dates AS
    SELECT track.recording,
           release.id AS release,
           date_year AS year,
           date_month AS month,
           date_day AS day
      FROM track
      JOIN medium ON (medium.id = track.medium)
      JOIN release ON (release.id = medium.release)
      LEFT JOIN (
          SELECT release, date_year, date_month, date_day
            FROM release_country
           UNION
          SELECT release, date_year, date_month, date_day
            FROM release_unknown_country
      ) release_dates
        ON release_dates.release = release.id;

INSERT INTO recording_first_release_date
SELECT DISTINCT ON (recording)
       recording, year, month, day
  FROM recording_release_dates
 ORDER BY recording,
          year NULLS LAST,
          month NULLS LAST,
          day NULLS LAST;

ALTER TABLE recording_first_release_date
  ADD CONSTRAINT recording_first_release_date_pkey
  PRIMARY KEY (recording);

CREATE INDEX recording_first_release_date_idx
  ON recording_first_release_date (year, month, day);

CREATE OR REPLACE FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  INSERT INTO recording_first_release_date
  (
    SELECT DISTINCT ON (recording)
           recording, year, month, day
      FROM recording_release_dates
     WHERE recording = ANY(recording_ids)
     ORDER BY recording, year NULLS LAST, month NULLS LAST, day NULLS LAST
  )
  ON CONFLICT (recording) DO UPDATE
  SET year = excluded.year,
      month = excluded.month,
      day = excluded.day;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_releases_recordings_first_release_dates(release_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  INSERT INTO recording_first_release_date
  (
    SELECT DISTINCT ON (recording)
           recording, year, month, day
      FROM recording_release_dates
     WHERE release = ANY(release_ids)
     ORDER BY recording, year NULLS LAST, month NULLS LAST, day NULLS LAST
  )
  ON CONFLICT (recording) DO UPDATE
  SET year = excluded.year,
      month = excluded.month,
      day = excluded.day;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment track_count in the parent medium
    UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    PERFORM materialise_recording_length(NEW.recording);
    PERFORM set_recordings_first_release_dates(ARRAY[NEW.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.medium != OLD.medium THEN
        -- medium is changed, decrement track_count in the original medium, increment in the new one
        UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
        UPDATE medium SET track_count = track_count + 1 WHERE id = NEW.medium;
    END IF;
    IF OLD.recording <> NEW.recording THEN
      PERFORM materialise_recording_length(OLD.recording);
      PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording, NEW.recording]);
    END IF;
    PERFORM materialise_recording_length(NEW.recording);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement track_count in the parent medium
    UPDATE medium SET track_count = track_count - 1 WHERE id = OLD.medium;
    PERFORM materialise_recording_length(OLD.recording);
    PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = NEW.release;
  PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id IN (NEW.release, OLD.release);
  PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release, OLD.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = OLD.release;
  PERFORM set_releases_recordings_first_release_dates(ARRAY[OLD.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
