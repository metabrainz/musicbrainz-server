SET search_path = musicbrainz;

\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER "reptg_artist_alias_type" ON "artist_alias_type";
CREATE TRIGGER "reptg_artist_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "artist_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

DROP TRIGGER "reptg_artist_gid_redirect" ON "artist_gid_redirect";
CREATE TRIGGER "reptg_artist_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "artist_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_l_artist_work" ON "l_artist_work";
CREATE TRIGGER "reptg_l_artist_work"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_work"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_label_alias_type" ON "label_alias_type";
CREATE TRIGGER "reptg_label_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "label_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

DROP TRIGGER "reptg_label_gid_redirect" ON "label_gid_redirect";
CREATE TRIGGER "reptg_label_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "label_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_recording_gid_redirect" ON "recording_gid_redirect";
CREATE TRIGGER "reptg_recording_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "recording_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_release_gid_redirect" ON "release_gid_redirect";
CREATE TRIGGER "reptg_release_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "release_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_release_group_gid_redirect" ON "release_group_gid_redirect";
CREATE TRIGGER "reptg_release_group_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_release_group_secondary_type" ON "release_group_secondary_type_join";
CREATE TRIGGER "reptg_release_group_secondary_type_join"
AFTER INSERT OR DELETE OR UPDATE ON "release_group_secondary_type_join"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

DROP TRIGGER "reptg_work_alias_type" ON "work_alias_type";
CREATE TRIGGER "reptg_work_alias_type"
AFTER INSERT OR DELETE OR UPDATE ON "work_alias_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

DROP TRIGGER "reptg_work_gid_redirect" ON "work_gid_redirect";
CREATE TRIGGER "reptg_work_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "work_gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ('verbose');

COMMIT;
