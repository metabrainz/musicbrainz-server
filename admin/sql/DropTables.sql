begin;

select 'Are you sure you want to use this script?';
select 'If so, you better uncomment the rollback. :-)';

-- Uncomment the rollback to make this script do something.
--rollback;
commit;

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
drop table Moderator_Sanitised;
drop table Moderation;
drop table ModerationNote;
drop table Votes;
drop table WordList;
drop table ArtistWords;
drop table AlbumWords;
drop table TrackWords;
drop table Stats;

drop sequence album_id_seq;
drop sequence albumjoin_id_seq;
drop sequence artist_id_seq;
drop sequence artistalias_id_seq;
drop sequence clientversion_id_seq;
drop sequence discid_id_seq;
drop sequence moderation_id_seq;
drop sequence moderationnote_id_seq;
drop sequence moderator_id_seq;
drop sequence moderator_sanitised_id_seq;
drop sequence stats_id_seq;
drop sequence toc_id_seq;
drop sequence track_id_seq;
drop sequence trm_id_seq;
drop sequence trmjoin_id_seq;
drop sequence votes_id_seq;
drop sequence wordlist_id_seq;
