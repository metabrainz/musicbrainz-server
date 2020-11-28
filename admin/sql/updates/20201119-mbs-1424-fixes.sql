\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

BEGIN;

DROP VIEW IF EXISTS recording_release_dates;

CREATE TABLE release_first_release_date (
    release     INTEGER NOT NULL,
    year        SMALLINT,
    month       SMALLINT,
    day         SMALLINT
);

INSERT INTO release_first_release_date (
  SELECT DISTINCT ON (release)
    release, date_year, date_month, date_day
    FROM (
      SELECT release, date_year, date_month, date_day
        FROM release_country
       UNION ALL
      SELECT release, date_year, date_month, date_day
        FROM release_unknown_country
    ) all_dates
    ORDER BY
      release,
      date_year NULLS LAST,
      date_month NULLS LAST,
      date_day NULLS LAST
);

TRUNCATE recording_first_release_date;

INSERT INTO recording_first_release_date (
  SELECT DISTINCT ON (track.recording)
      track.recording,
      rd.year,
      rd.month,
      rd.day
    FROM track
    JOIN medium ON medium.id = track.medium
    JOIN release_first_release_date rd ON rd.release = medium.release
    ORDER BY
      track.recording,
      rd.year NULLS LAST,
      rd.month NULLS LAST,
      rd.day NULLS LAST
);

ALTER TABLE release_first_release_date
  ADD CONSTRAINT release_first_release_date_pkey
  PRIMARY KEY (release);

ALTER TABLE release_first_release_date
   ADD CONSTRAINT release_first_release_date_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id)
   ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION set_release_first_release_date(release_id INTEGER)
RETURNS VOID AS $$
BEGIN
  INSERT INTO release_first_release_date (release, year, month, day) (
    SELECT release_id, date_year, date_month, date_day FROM (
      SELECT date_year, date_month, date_day
        FROM release_country
       WHERE release = release_id
       UNION ALL
      SELECT date_year, date_month, date_day
        FROM release_unknown_country
       WHERE release = release_id
       UNION ALL
      SELECT NULL, NULL, NULL
    ) release_dates
    ORDER BY
      date_year NULLS LAST,
      date_month NULLS LAST,
      date_day NULLS LAST
    LIMIT 1
  )
  ON CONFLICT (release)
  DO UPDATE SET year = excluded.year,
                month = excluded.month,
                day = excluded.day;

  DELETE FROM release_first_release_date
   WHERE release = release_id
     AND year IS NULL
     AND month IS NULL
     AND day IS NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_release_group_first_release_date(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET first_release_date_year = first.year,
                                  first_release_date_month = first.month,
                                  first_release_date_day = first.day
      FROM (
        SELECT rd.year, rd.month, rd.day
        FROM release
        LEFT JOIN release_first_release_date rd ON (rd.release = release.id)
        WHERE release.release_group = release_group_id
        ORDER BY
          rd.year NULLS LAST,
          rd.month NULLS LAST,
          rd.day NULLS LAST
        LIMIT 1
      ) AS first
    WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  INSERT INTO recording_first_release_date
  (
    SELECT DISTINCT ON (track.recording)
        track.recording,
        rd.year,
        rd.month,
        rd.day
      FROM track
      JOIN medium ON medium.id = track.medium
      LEFT JOIN release_first_release_date rd ON rd.release = medium.release
     WHERE track.recording = ANY(recording_ids)
     ORDER BY
      track.recording,
      rd.year NULLS LAST,
      rd.month NULLS LAST,
      rd.day NULLS LAST
  )
  ON CONFLICT (recording) DO UPDATE
  SET year = excluded.year,
      month = excluded.month,
      day = excluded.day;

  DELETE FROM recording_first_release_date
   WHERE recording = ANY(recording_ids)
     AND year IS NULL
     AND month IS NULL
     AND day IS NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION set_releases_recordings_first_release_dates(release_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  PERFORM set_recordings_first_release_dates((
    SELECT array_agg(recording)
      FROM track
      JOIN medium ON medium.id = track.medium
     WHERE medium.release = any(release_ids)
  ));
  RETURN;
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
  PERFORM set_release_first_release_date(NEW.release);

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
  PERFORM set_release_first_release_date(OLD.release);
  PERFORM set_release_first_release_date(NEW.release);

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
  PERFORM set_release_first_release_date(OLD.release);

  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = OLD.release;

  PERFORM set_releases_recordings_first_release_dates(ARRAY[OLD.release]);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
