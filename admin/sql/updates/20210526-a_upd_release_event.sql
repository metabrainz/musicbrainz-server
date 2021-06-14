\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION a_upd_release_event()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    NEW.release != OLD.release OR
    NEW.date_year IS DISTINCT FROM OLD.date_year OR
    NEW.date_month IS DISTINCT FROM OLD.date_month OR
    NEW.date_day IS DISTINCT FROM OLD.date_day
  ) THEN
    PERFORM set_release_first_release_date(OLD.release);
    IF NEW.release != OLD.release THEN
        PERFORM set_release_first_release_date(NEW.release);
    END IF;

    PERFORM set_release_group_first_release_date(release_group)
    FROM release
    WHERE release.id IN (NEW.release, OLD.release);

    PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release, OLD.release]);
  END IF;

  IF TG_TABLE_NAME = 'release_country' THEN
    IF NEW.country != OLD.country THEN
      INSERT INTO artist_release_pending_update VALUES (OLD.release);
    END IF;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
