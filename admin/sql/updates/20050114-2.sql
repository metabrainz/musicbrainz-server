-- Abstract: Create the AR tables: url, link_attribute_type, l_* and lt_*
-- Abstract: Part 2: replication triggers

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_l_album_album"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_album"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_artist"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_artist"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_track_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_track_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_track_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_track_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_url_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_link_attribute_type"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_type"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_album_album"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_album"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_album_artist"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_album_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_album_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_artist"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_track_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_track_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_track_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_track_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_url_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_url"
AFTER INSERT OR DELETE OR UPDATE ON "url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
