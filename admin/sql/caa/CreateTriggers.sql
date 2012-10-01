BEGIN;

SET search_path = 'cover_art_archive';

CREATE TRIGGER update_release_coverart AFTER INSERT OR DELETE
ON cover_art_archive.cover_art
FOR EACH ROW EXECUTE PROCEDURE materialize_caa_presence();

CREATE CONSTRAINT TRIGGER resquence_cover_art AFTER INSERT OR UPDATE OR DELETE
ON cover_art_archive.cover_art DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE resequence_cover_art_trigger();

COMMIT;
