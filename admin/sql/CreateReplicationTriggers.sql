-- Adjust this setting to control where the objects get created.
SET search_path = public;

SET autocommit TO 'on';

CREATE TRIGGER "a_idu_album" 
AFTER INSERT OR DELETE OR UPDATE ON "album"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_albumjoin" 
AFTER INSERT OR DELETE OR UPDATE ON "albumjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_albummeta" 
AFTER INSERT OR DELETE OR UPDATE ON "albummeta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_albumwords" 
AFTER INSERT OR DELETE OR UPDATE ON "albumwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_artist" 
AFTER INSERT OR DELETE OR UPDATE ON "artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_artistwords" 
AFTER INSERT OR DELETE OR UPDATE ON "artistwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_artist_relation" 
AFTER INSERT OR DELETE OR UPDATE ON "artist_relation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_artistalias" 
AFTER INSERT OR DELETE OR UPDATE ON "artistalias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_clientversion" 
AFTER INSERT OR DELETE OR UPDATE ON "clientversion"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_discid" 
AFTER INSERT OR DELETE OR UPDATE ON "discid"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_toc" 
AFTER INSERT OR DELETE OR UPDATE ON "toc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_track" 
AFTER INSERT OR DELETE OR UPDATE ON "track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_trackwords" 
AFTER INSERT OR DELETE OR UPDATE ON "trackwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_trm" 
AFTER INSERT OR DELETE OR UPDATE ON "trm"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_trmjoin" 
AFTER INSERT OR DELETE OR UPDATE ON "trmjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "a_idu_wordlist" 
AFTER INSERT OR DELETE OR UPDATE ON "wordlist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

