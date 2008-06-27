-- Abstract: Labels & catalog numbers
--           Part 3: Replication triggers

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_label" 
AFTER INSERT OR DELETE OR UPDATE ON "label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_labelwords" 
AFTER INSERT OR DELETE OR UPDATE ON "labelwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_label_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_label_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_album_label"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_label"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_label_label"
AFTER INSERT OR DELETE OR UPDATE ON "lt_label_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_label_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_label_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_label_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_label_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_labelalias"
AFTER INSERT OR DELETE OR UPDATE ON "labelalias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
