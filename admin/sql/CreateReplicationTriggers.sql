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

CREATE TRIGGER "a_idu_country" 
AFTER INSERT OR DELETE OR UPDATE ON "country"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: currentstat

CREATE TRIGGER "a_idu_discid" 
AFTER INSERT OR DELETE OR UPDATE ON "discid"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: historicalstat
-- Not replicated: moderation_open, moderation_note_open
-- Not replicated: moderation_closed, moderation_note_closed
-- Not replicated: moderator
-- Not replicated: moderator_preference
-- Not replicated: moderator_subscribe_artist

CREATE TRIGGER "a_idu_release" 
AFTER INSERT OR DELETE OR UPDATE ON "release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: stats

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

-- Not replicated: vote_closed, vote_open

CREATE TRIGGER "a_idu_wordlist" 
AFTER INSERT OR DELETE OR UPDATE ON "wordlist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- vi: set ts=4 sw=4 et :
