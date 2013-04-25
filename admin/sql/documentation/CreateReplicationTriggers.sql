SET search_path = documentation;

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_recording_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_release_group_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_recording"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_release_group"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "l_work_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

CREATE TRIGGER "replicate"
AFTER INSERT OR DELETE OR UPDATE ON "link_type_documentation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
