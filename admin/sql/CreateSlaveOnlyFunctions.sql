\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION a_ins_track_slave()
RETURNS trigger AS $$
BEGIN
    PERFORM set_recordings_first_release_dates(ARRAY[NEW.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track_slave()
RETURNS trigger AS $$
BEGIN
    IF OLD.recording <> NEW.recording THEN
        PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording, NEW.recording]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track_slave()
RETURNS trigger AS $$
BEGIN
    PERFORM set_recordings_first_release_dates(ARRAY[OLD.recording]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_event_slave()
RETURNS trigger AS $$
BEGIN
    PERFORM set_release_first_release_date(NEW.release);
    PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_event_slave()
RETURNS trigger AS $$
BEGIN
    PERFORM set_release_first_release_date(OLD.release);
    PERFORM set_release_first_release_date(NEW.release);
    PERFORM set_releases_recordings_first_release_dates(ARRAY[NEW.release, OLD.release]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_event_slave()
RETURNS trigger AS $$
BEGIN
    PERFORM set_release_first_release_date(OLD.release);
    PERFORM set_releases_recordings_first_release_dates(ARRAY[OLD.release]);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
