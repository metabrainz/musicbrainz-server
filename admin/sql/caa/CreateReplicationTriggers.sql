-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive', musicbrainz, public;

BEGIN;

CREATE TRIGGER "reptg_art_type"
AFTER INSERT OR DELETE OR UPDATE ON "art_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_cover_art"
AFTER INSERT OR DELETE OR UPDATE ON "cover_art"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_cover_art_type"
AFTER INSERT OR DELETE OR UPDATE ON "cover_art_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_image_type"
AFTER INSERT OR DELETE OR UPDATE ON "image_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "reptg_release_group_cover_art"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_cover_art"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
