BEGIN;

SET search_path = 'event_art_archive';

CREATE TRIGGER update_event_art AFTER INSERT OR DELETE
ON event_art_archive.event_art
FOR EACH ROW EXECUTE PROCEDURE materialize_eaa_presence();

CREATE CONSTRAINT TRIGGER resquence_event_art AFTER INSERT OR UPDATE OR DELETE
ON event_art_archive.event_art DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE resequence_event_art_trigger();

COMMIT;
