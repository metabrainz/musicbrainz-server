\set ON_ERROR_STOP 1

drop table Artist;
drop table ArtistAlias;
drop table Album;
drop table AlbumMeta;
drop table Track;
drop table AlbumJoin;
drop table ClientVersion;
drop table TRM;
drop table TRMJoin;
drop table Discid;
drop table TOC;
drop table Moderator;
drop table moderation_closed;
drop table moderation_note_closed;
drop table moderation_note_open;
drop table moderation_open;
drop table vote_closed;
drop table vote_open;
drop table WordList;
drop table ArtistWords;
drop table AlbumWords;
drop table TrackWords;
drop table Stats;

DROP TABLE currentstat;
DROP TABLE historicalstat;
DROP TABLE moderator_preference;
DROP TABLE moderator_subscribe_artist;
DROP TABLE country;
DROP TABLE release;

drop sequence album_id_seq;
drop sequence albumjoin_id_seq;
drop sequence artist_id_seq;
drop sequence artistalias_id_seq;
drop sequence clientversion_id_seq;
drop sequence discid_id_seq;
drop sequence moderation_open_id_seq;
drop sequence moderation_note_open_id_seq;
drop sequence moderator_id_seq;
drop sequence stats_id_seq;
drop sequence toc_id_seq;
drop sequence track_id_seq;
drop sequence trm_id_seq;
drop sequence trmjoin_id_seq;
drop sequence vote_open_id_seq;
drop sequence wordlist_id_seq;
drop sequence country_id_seq;
drop sequence release_id_seq;

-- vi: set ts=4 sw=4 et :
