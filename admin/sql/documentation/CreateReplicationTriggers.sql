SET search_path = documentation, musicbrainz, public;

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_area_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_artist_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_area_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_artist_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_label_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_recording_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release_group_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_work_example"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "link_type_documentation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
