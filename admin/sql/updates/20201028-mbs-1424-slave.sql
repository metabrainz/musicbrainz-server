\set ON_ERROR_STOP 1

SET search_path = musicbrainz;

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

DROP TRIGGER IF EXISTS a_ins_track_slave ON track;
CREATE TRIGGER a_ins_track_slave AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track_slave();

DROP TRIGGER IF EXISTS a_upd_track_slave ON track;
CREATE TRIGGER a_upd_track_slave AFTER UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_upd_track_slave();

DROP TRIGGER IF EXISTS a_del_track_slave ON track;
CREATE TRIGGER a_del_track_slave AFTER DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track_slave();

DROP TRIGGER IF EXISTS a_ins_release_event_slave ON release_country;
CREATE TRIGGER a_ins_release_event_slave AFTER INSERT ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_slave();

DROP TRIGGER IF EXISTS a_upd_release_event_slave ON release_country;
CREATE TRIGGER a_upd_release_event_slave AFTER UPDATE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_slave();

DROP TRIGGER IF EXISTS a_del_release_event_slave ON release_country;
CREATE TRIGGER a_del_release_event_slave AFTER DELETE ON release_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_slave();

DROP TRIGGER IF EXISTS a_del_release_event_slave ON release_unknown_country;
CREATE TRIGGER a_ins_release_event_slave AFTER INSERT ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_event_slave();

DROP TRIGGER IF EXISTS a_upd_release_event_slave ON release_unknown_country;
CREATE TRIGGER a_upd_release_event_slave AFTER UPDATE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_event_slave();

DROP TRIGGER IF EXISTS a_del_release_event_slave ON release_unknown_country;
CREATE TRIGGER a_del_release_event_slave AFTER DELETE ON release_unknown_country
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_event_slave();

COMMIT;
