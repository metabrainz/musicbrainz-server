\set ON_ERROR_STOP 1

DROP TABLE artist;
DROP TABLE artistalias;
DROP TABLE album;
DROP TABLE albummeta;
DROP TABLE track;
DROP TABLE albumjoin;
DROP TABLE clientversion;
DROP TABLE trm;
DROP TABLE trmjoin;
DROP TABLE discid;
DROP TABLE toc;
DROP TABLE moderator;
DROP TABLE moderation_closed;
DROP TABLE moderation_note_closed;
DROP TABLE moderation_note_open;
DROP TABLE moderation_open;
DROP TABLE vote_closed;
DROP TABLE vote_open;
DROP TABLE wordlist;
DROP TABLE artistwords;
DROP TABLE albumwords;
DROP TABLE trackwords;
DROP TABLE stats;

DROP TABLE currentstat;
DROP TABLE historicalstat;
DROP TABLE moderator_preference;
DROP TABLE moderator_subscribe_artist;
DROP TABLE country;
DROP TABLE release;
DROP TABLE album_amazon_asin;

DROP SEQUENCE album_id_seq;
DROP SEQUENCE albumjoin_id_seq;
DROP SEQUENCE artist_id_seq;
DROP SEQUENCE artistalias_id_seq;
DROP SEQUENCE clientversion_id_seq;
DROP SEQUENCE discid_id_seq;
DROP SEQUENCE moderation_open_id_seq;
DROP SEQUENCE moderation_note_open_id_seq;
DROP SEQUENCE moderator_id_seq;
DROP SEQUENCE stats_id_seq;
DROP SEQUENCE toc_id_seq;
DROP SEQUENCE track_id_seq;
DROP SEQUENCE trm_id_seq;
DROP SEQUENCE trmjoin_id_seq;
DROP SEQUENCE vote_open_id_seq;
DROP SEQUENCE wordlist_id_seq;
DROP SEQUENCE country_id_seq;
DROP SEQUENCE release_id_seq;

-- vi: set ts=4 sw=4 et :
