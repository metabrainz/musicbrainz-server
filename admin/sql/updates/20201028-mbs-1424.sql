\set ON_ERROR_STOP 1

BEGIN;

DROP TABLE IF EXISTS release_first_release_date CASCADE;
DROP TABLE IF EXISTS recording_first_release_date CASCADE;

CREATE TABLE release_first_release_date (
    release     INTEGER NOT NULL,
    year        SMALLINT,
    month       SMALLINT,
    day         SMALLINT
);

CREATE TABLE recording_first_release_date (
  recording   INTEGER NOT NULL,
  year        SMALLINT,
  month       SMALLINT,
  day         SMALLINT
);

CREATE OR REPLACE FUNCTION get_release_first_release_date_rows(condition TEXT)
RETURNS SETOF release_first_release_date AS $$
BEGIN
    RETURN QUERY EXECUTE '
        SELECT DISTINCT ON (release) release,
            date_year AS year,
            date_month AS month,
            date_day AS day
        FROM (
            SELECT release, date_year, date_month, date_day FROM release_country
            WHERE (date_year IS NOT NULL OR date_month IS NOT NULL OR date_day IS NOT NULL)
            UNION ALL
            SELECT release, date_year, date_month, date_day FROM release_unknown_country
        ) all_dates
        WHERE ' || condition ||
        ' ORDER BY release, year NULLS LAST, month NULLS LAST, day NULLS LAST';
END;
$$ LANGUAGE 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION set_release_first_release_date(release_id INTEGER)
RETURNS VOID AS $$
BEGIN
  -- DO NOT modify any replicated tables in this function; it's used
  -- by a trigger on slaves.
  DELETE FROM release_first_release_date
  WHERE release = release_id;

  INSERT INTO release_first_release_date
  SELECT * FROM get_release_first_release_date_rows(
    format('release = %L', release_id)
  );
END;
$$ LANGUAGE 'plpgsql' STRICT;

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

CREATE OR REPLACE FUNCTION get_recording_first_release_date_rows(condition TEXT)
RETURNS SETOF recording_first_release_date AS $$
BEGIN
    RETURN QUERY EXECUTE '
        SELECT DISTINCT ON (track.recording)
            track.recording, rd.year, rd.month, rd.day
        FROM track
        JOIN medium ON medium.id = track.medium
        JOIN release_first_release_date rd ON rd.release = medium.release
        WHERE ' || condition || '
        ORDER BY track.recording,
            rd.year NULLS LAST,
            rd.month NULLS LAST,
            rd.day NULLS LAST';
END;
$$ LANGUAGE 'plpgsql' STRICT;

CREATE OR REPLACE FUNCTION set_recordings_first_release_dates(recording_ids INTEGER[])
RETURNS VOID AS $$
BEGIN
  -- DO NOT modify any replicated tables in this function; it's used
  -- by a trigger on slaves.
  DELETE FROM recording_first_release_date
  WHERE recording = ANY(recording_ids);

  INSERT INTO recording_first_release_date
  SELECT * FROM get_recording_first_release_date_rows(
    format('track.recording = any(%L)', recording_ids)
  );
END;
$$ LANGUAGE 'plpgsql' STRICT;

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
$$ LANGUAGE 'plpgsql' STRICT;

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

ALTER TABLE release_first_release_date
  ADD CONSTRAINT release_first_release_date_pkey
  PRIMARY KEY (release);

ALTER TABLE recording_first_release_date
  ADD CONSTRAINT recording_first_release_date_pkey
  PRIMARY KEY (recording);

-- **NOTE**: The new triggers overlap with ones created in
-- admin/sql/updates/20210311-mbs-11438.sql,
-- so somes changes have been consolidated into there.
--
-- This includes the following functions:
--   a_ins_release_event
--   a_upd_release_event
--   a_del_release_event
--   a_ins_track
--   a_upd_track
--   a_del_track

COMMIT;
