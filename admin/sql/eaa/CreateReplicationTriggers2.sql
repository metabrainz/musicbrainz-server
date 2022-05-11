-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'event_art_archive', musicbrainz, public;

BEGIN;

CREATE TRIGGER reptg2_art_type
AFTER INSERT OR DELETE OR UPDATE ON art_type
FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();

CREATE TRIGGER reptg2_event_art
AFTER INSERT OR DELETE OR UPDATE ON event_art
FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();

CREATE TRIGGER reptg2_event_art_type
AFTER INSERT OR DELETE OR UPDATE ON event_art_type
FOR EACH ROW EXECUTE PROCEDURE dbmirror2.recordchange();

COMMIT;
