-- Adjust this setting to control where the objects get created.
SET search_path = public;

\set ON_ERROR_STOP 1

BEGIN;

CREATE TRIGGER "reptg_album" 
AFTER INSERT OR DELETE OR UPDATE ON "album"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_album_amazon_asin" 
AFTER INSERT OR DELETE OR UPDATE ON "album_amazon_asin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_album_cdtoc" 
AFTER INSERT OR DELETE OR UPDATE ON "album_cdtoc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_albumjoin" 
AFTER INSERT OR DELETE OR UPDATE ON "albumjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_albummeta" 
AFTER INSERT OR DELETE OR UPDATE ON "albummeta"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_albumwords" 
AFTER INSERT OR DELETE OR UPDATE ON "albumwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_annotation" 
AFTER INSERT OR DELETE OR UPDATE ON "annotation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist" 
AFTER INSERT OR DELETE OR UPDATE ON "artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artist_relation" 
AFTER INSERT OR DELETE OR UPDATE ON "artist_relation"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artistalias" 
AFTER INSERT OR DELETE OR UPDATE ON "artistalias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_artistwords" 
AFTER INSERT OR DELETE OR UPDATE ON "artistwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: automod_election, automod_election_vote

CREATE TRIGGER "reptg_cdtoc" 
AFTER INSERT OR DELETE OR UPDATE ON "cdtoc"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_clientversion" 
AFTER INSERT OR DELETE OR UPDATE ON "clientversion"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_country" 
AFTER INSERT OR DELETE OR UPDATE ON "country"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_currentstat" 
AFTER INSERT OR DELETE OR UPDATE ON "currentstat"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_historicalstat" 
AFTER INSERT OR DELETE OR UPDATE ON "historicalstat"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: moderation_open, moderation_note_open
-- Not replicated: moderation_closed, moderation_note_closed
-- Not replicated: moderator
-- Not replicated: moderator_preference
-- Not replicated: moderator_subscribe_artist

CREATE TRIGGER "reptg_release" 
AFTER INSERT OR DELETE OR UPDATE ON "release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_replication_control" 
AFTER INSERT OR DELETE OR UPDATE ON "replication_control"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_stats" 
AFTER INSERT OR DELETE OR UPDATE ON "stats"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_track" 
AFTER INSERT OR DELETE OR UPDATE ON "track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_trackwords" 
AFTER INSERT OR DELETE OR UPDATE ON "trackwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_trm" 
AFTER INSERT OR DELETE ON "trm"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_trmjoin" 
AFTER INSERT OR DELETE ON "trmjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: vote_closed, vote_open

CREATE TRIGGER "reptg_wordlist" 
AFTER INSERT OR DELETE OR UPDATE ON "wordlist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
