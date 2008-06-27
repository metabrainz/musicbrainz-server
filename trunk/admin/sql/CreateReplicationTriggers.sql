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

CREATE TRIGGER "reptg_artist_tag" 
AFTER INSERT OR DELETE OR UPDATE ON "artist_tag"
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

CREATE TRIGGER "reptg_label" 
AFTER INSERT OR DELETE OR UPDATE ON "label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_labelalias"
AFTER INSERT OR DELETE OR UPDATE ON "labelalias"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_label_tag"
AFTER INSERT OR DELETE OR UPDATE ON "label_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_labelwords" 
AFTER INSERT OR DELETE OR UPDATE ON "labelwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_album"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_album"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_artist"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_artist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_album_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_album_label"
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

CREATE TRIGGER "reptg_l_artist_label"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_artist_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_artist_url"
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

CREATE TRIGGER "reptg_l_track_track"
AFTER INSERT OR DELETE OR UPDATE ON "l_track_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_track_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_track_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_l_url_url"
AFTER INSERT OR DELETE OR UPDATE ON "l_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_language" 
AFTER INSERT OR DELETE OR UPDATE ON "language"
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

CREATE TRIGGER "reptg_lt_album_label"
AFTER INSERT OR DELETE OR UPDATE ON "lt_album_label"
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

CREATE TRIGGER "reptg_lt_artist_label"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_label"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_artist_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_artist_url"
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

CREATE TRIGGER "reptg_lt_track_track"
AFTER INSERT OR DELETE OR UPDATE ON "lt_track_track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_track_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_track_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_lt_url_url"
AFTER INSERT OR DELETE OR UPDATE ON "lt_url_url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: moderation_open, moderation_note_open
-- Not replicated: moderation_closed, moderation_note_closed
-- Not replicated: moderator
-- Not replicated: moderator_preference
-- Not replicated: moderator_subscribe_artist
-- Not replicated: moderator_subscribe_label

CREATE TRIGGER "reptg_puid" 
AFTER INSERT OR DELETE ON "puid"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_puidjoin" 
AFTER INSERT OR DELETE ON "puidjoin"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release" 
AFTER INSERT OR DELETE OR UPDATE ON "release"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_release_tag" 
AFTER INSERT OR DELETE OR UPDATE ON "release_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_replication_control" 
AFTER INSERT OR DELETE OR UPDATE ON "replication_control"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_script" 
AFTER INSERT OR DELETE OR UPDATE ON "script"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_script_language" 
AFTER INSERT OR DELETE OR UPDATE ON "script_language"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_stats" 
AFTER INSERT OR DELETE OR UPDATE ON "stats"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_tag" 
AFTER INSERT OR DELETE OR UPDATE ON "tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_track" 
AFTER INSERT OR DELETE OR UPDATE ON "track"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_track_tag" 
AFTER INSERT OR DELETE OR UPDATE ON "track_tag"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_trackwords" 
AFTER INSERT OR DELETE OR UPDATE ON "trackwords"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_url"
AFTER INSERT OR DELETE OR UPDATE ON "url"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

CREATE TRIGGER "reptg_gid_redirect"
AFTER INSERT OR DELETE OR UPDATE ON "gid_redirect"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

-- Not replicated: vote_closed, vote_open

CREATE TRIGGER "reptg_wordlist" 
AFTER INSERT OR DELETE OR UPDATE ON "wordlist"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

COMMIT;

-- vi: set ts=4 sw=4 et :
