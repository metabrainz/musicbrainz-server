\set ON_ERROR_STOP 1

create unique index Artist_NameIndex on Artist (Name);
create index Artist_SortNameIndex on Artist (SortName);
create unique index Artist_GIDIndex on Artist (GID);
create index Artist_PageIndex on Artist (Page);

create index Album_NameIndex on Album (Name);
create unique index Album_GIDIndex on Album (GID);
create index Album_ArtistIndex on Album (Artist);
create index Album_PageIndex on Album (Page);

create index Track_NameIndex on Track (Name);
create unique index Track_GIDIndex on Track (GID);
create index Track_ArtistIndex on Track (Artist);

create unique index TRM_TRMIndex on TRM (TRM);

create index TRMJoin_TRMIndex on TRMJoin (TRM);
create index TRMJoin_TrackIndex on TRMJoin (Track);

create index AlbumJoin_AlbumIndex on AlbumJoin (Album);
create index AlbumJoin_TrackIndex on AlbumJoin (Track);

create unique index Discid_DiscIndex on Discid (Disc);
create index Discid_AlbumIndex on Discid (Album);

create unique index TOC_DiscIndex on TOC (Discid);
create index TOC_AlbumIndex on TOC (Album);

create index Moderator_NameIndex on Moderator (Name);

create index Moderation_ModeratorIndex on Moderation (Moderator);
create index Moderation_ExpireTimeIndex on Moderation (ExpireTime);
create index Moderation_StatusIndex on Moderation (Status);

create index Votes_UidIndex on Votes (Uid);
create index Votes_RowidIndex on Votes (Rowid);

create unique index ArtistAlias_NameIndex on ArtistAlias (Name);
create index ArtistAlias_RefIndex on ArtistAlias (Ref);

create unique index WordList_WordIndex on WordList (Word);

create index AlbumWords_WordidIndex on AlbumWords (Wordid);
create index AlbumWords_AlbumidIndex on AlbumWords (Albumid);
create unique index AlbumWords_AlbumWordIndex on AlbumWords (Wordid,Albumid);

create index ArtistWords_WordidIndex on ArtistWords (Wordid);
create index ArtistWords_ArtistidIndex on ArtistWords (Artistid);
create unique index ArtistWords_ArtistWordIndex  on ArtistWords (Wordid,Artistid);

create index TrackWords_WordidIndex on TrackWords (Wordid);
create index TrackWords_TrackidIndex on TrackWords (Trackid);
create unique index TrackWords_TrackWordIndex on TrackWords (Wordid,Trackid);

create index ModerationNote_ModIndex on ModerationNote (Modid);

create unique index Stats_TimestampIndex on Stats (timestamp);

create unique index ClientVersion_Version on ClientVersion (version);
