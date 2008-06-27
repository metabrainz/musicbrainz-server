\unset ON_ERROR_STOP

SET autocommit TO 'on';

DROP TRIGGER "reptg_album" ON "album";
DROP TRIGGER "reptg_album_amazon_asin" ON "album_amazon_asin";
DROP TRIGGER "reptg_album_cdtoc" ON "album_cdtoc";
DROP TRIGGER "reptg_albumjoin" ON "albumjoin";
DROP TRIGGER "reptg_albummeta" ON "albummeta";
DROP TRIGGER "reptg_albumwords" ON "albumwords";
DROP TRIGGER "reptg_annotation" ON "annotation";
DROP TRIGGER "reptg_artist" ON "artist";
DROP TRIGGER "reptg_artist_relation" ON "artist_relation";
DROP TRIGGER "reptg_artistalias" ON "artistalias";
DROP TRIGGER "reptg_artistwords" ON "artistwords";
-- Not replicated: automod_election, automod_election_vote
DROP TRIGGER "reptg_cdtoc" ON "cdtoc";
DROP TRIGGER "reptg_clientversion" ON "clientversion";
DROP TRIGGER "reptg_country" ON "country";
DROP TRIGGER "reptg_currentstat" ON "currentstat";
DROP TRIGGER "reptg_historicalstat" ON "historicalstat";
DROP TRIGGER "reptg_label" ON "label";
DROP TRIGGER "reptg_labelalias" ON "labelalias";
DROP TRIGGER "reptg_labelwords" ON "labelwords";
DROP TRIGGER "reptg_l_album_album" ON "l_album_album";
DROP TRIGGER "reptg_l_album_artist" ON "l_album_artist";
DROP TRIGGER "reptg_l_album_label" ON "l_album_label";
DROP TRIGGER "reptg_l_album_track" ON "l_album_track";
DROP TRIGGER "reptg_l_album_url" ON "l_album_url";
DROP TRIGGER "reptg_l_artist_artist" ON "l_artist_artist";
DROP TRIGGER "reptg_l_artist_label" ON "l_artist_label";
DROP TRIGGER "reptg_l_artist_track" ON "l_artist_track";
DROP TRIGGER "reptg_l_artist_url" ON "l_artist_url";
DROP TRIGGER "reptg_l_label_label" ON "l_label_label";
DROP TRIGGER "reptg_l_label_track" ON "l_label_track";
DROP TRIGGER "reptg_l_label_url" ON "l_label_url";
DROP TRIGGER "reptg_l_track_track" ON "l_track_track";
DROP TRIGGER "reptg_l_track_url" ON "l_track_url";
DROP TRIGGER "reptg_l_url_url" ON "l_url_url";
DROP TRIGGER "reptg_language" ON "language";
DROP TRIGGER "reptg_link_attribute" ON "link_attribute";
DROP TRIGGER "reptg_link_attribute_type" ON "link_attribute_type";
DROP TRIGGER "reptg_lt_album_album" ON "lt_album_album";
DROP TRIGGER "reptg_lt_album_artist" ON "lt_album_artist";
DROP TRIGGER "reptg_lt_album_label" ON "lt_album_label";
DROP TRIGGER "reptg_lt_album_track" ON "lt_album_track";
DROP TRIGGER "reptg_lt_album_url" ON "lt_album_url";
DROP TRIGGER "reptg_lt_artist_artist" ON "lt_artist_artist";
DROP TRIGGER "reptg_lt_artist_label" ON "lt_artist_label";
DROP TRIGGER "reptg_lt_artist_track" ON "lt_artist_track";
DROP TRIGGER "reptg_lt_artist_url" ON "lt_artist_url";
DROP TRIGGER "reptg_lt_label_label" ON "lt_label_label";
DROP TRIGGER "reptg_lt_label_track" ON "lt_label_track";
DROP TRIGGER "reptg_lt_label_url" ON "lt_label_url";
DROP TRIGGER "reptg_lt_track_track" ON "lt_track_track";
DROP TRIGGER "reptg_lt_track_url" ON "lt_track_url";
DROP TRIGGER "reptg_lt_url_url" ON "lt_url_url";
-- Not replicated: moderation_open, moderation_note_open
-- Not replicated: moderation_closed, moderation_note_closed
-- Not replicated: moderator
-- Not replicated: moderator_preference
-- Not replicated: moderator_subscribe_artist
-- Not replicated: moderator_subscribe_label
DROP TRIGGER "reptg_puid" ON "puid";
DROP TRIGGER "reptg_puidjoin" ON "puidjoin";
DROP TRIGGER "reptg_release" ON "release";
DROP TRIGGER "reptg_replication_control" ON "replication_control";
DROP TRIGGER "reptg_script" ON "script";
DROP TRIGGER "reptg_script_language" ON "script_language";
DROP TRIGGER "reptg_stats" ON "stats";
DROP TRIGGER "reptg_track" ON "track";
DROP TRIGGER "reptg_trackwords" ON "trackwords";
DROP TRIGGER "reptg_url" ON "url";
DROP TRIGGER "reptg_gid_redirect" ON "gid_redirect";
-- Not replicated: vote_closed, vote_open
DROP TRIGGER "reptg_wordlist" ON "wordlist";

-- vi: set ts=4 sw=4 et :
