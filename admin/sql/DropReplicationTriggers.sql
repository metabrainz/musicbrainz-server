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
-- Not replicated: moderation_open, moderation_note_open
-- Not replicated: moderation_closed, moderation_note_closed
-- Not replicated: moderator
-- Not replicated: moderator_preference
-- Not replicated: moderator_subscribe_artist
DROP TRIGGER "reptg_release" ON "release";
DROP TRIGGER "reptg_replication_control" ON "replication_control";
DROP TRIGGER "reptg_stats" ON "stats";
DROP TRIGGER "reptg_track" ON "track";
DROP TRIGGER "reptg_trackwords" ON "trackwords";
DROP TRIGGER "reptg_trm" ON "trm";
DROP TRIGGER "reptg_trmjoin" ON "trmjoin";
-- Not replicated: vote_closed, vote_open
DROP TRIGGER "reptg_wordlist" ON "wordlist";
