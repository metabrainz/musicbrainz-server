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
CREATE UNIQUE INDEX trmjoin_trmtrack ON trmjoin (trm, track);

create index AlbumJoin_AlbumIndex on AlbumJoin (Album);
create index AlbumJoin_TrackIndex on AlbumJoin (Track);
CREATE UNIQUE INDEX albumjoin_albumtrack ON albumjoin (album, track);

CREATE UNIQUE INDEX discid_disc_key
    ON discid (disc);
create index Discid_AlbumIndex on Discid (Album);

create unique index TOC_DiscIndex on TOC (Discid);
create index TOC_AlbumIndex on TOC (Album);

create index Moderator_NameIndex on Moderator (Name);

CREATE INDEX moderation_open_idx_moderator ON moderation_open (moderator);
CREATE INDEX moderation_open_idx_expiretime ON moderation_open (expiretime);
CREATE INDEX moderation_open_idx_status ON moderation_open (status);
CREATE INDEX moderation_open_idx_artist ON moderation_open (artist);
CREATE INDEX moderation_open_idx_rowid ON moderation_open (rowid);

CREATE INDEX moderation_note_open_idx_moderation ON moderation_note_open (moderation);

CREATE INDEX vote_open_idx_moderator ON vote_open (moderator);
CREATE INDEX vote_open_idx_moderation ON vote_open (moderation);

CREATE INDEX moderation_closed_idx_moderator ON moderation_closed (moderator);
CREATE INDEX moderation_closed_idx_expiretime ON moderation_closed (expiretime);
CREATE INDEX moderation_closed_idx_status ON moderation_closed (status);
CREATE INDEX moderation_closed_idx_artist ON moderation_closed (artist);
CREATE INDEX moderation_closed_idx_rowid ON moderation_closed (rowid);

CREATE INDEX moderation_note_closed_idx_moderation ON moderation_note_closed (moderation);

CREATE INDEX vote_closed_idx_moderator ON vote_closed (moderator);
CREATE INDEX vote_closed_idx_moderation ON vote_closed (moderation);

create unique index ArtistAlias_NameIndex on ArtistAlias (Name);
create index ArtistAlias_RefIndex on ArtistAlias (Ref);

create unique index WordList_WordIndex on WordList (Word);

create index AlbumWords_AlbumidIndex on AlbumWords (Albumid);
create unique index AlbumWords_AlbumWordIndex on AlbumWords (Wordid,Albumid);

create index ArtistWords_ArtistidIndex on ArtistWords (Artistid);
create unique index ArtistWords_ArtistWordIndex  on ArtistWords (Wordid,Artistid);

create index TrackWords_TrackidIndex on TrackWords (Trackid);
create unique index TrackWords_TrackWordIndex on TrackWords (Wordid,Trackid);

create unique index Stats_TimestampIndex on Stats (timestamp);

create unique index ClientVersion_Version on ClientVersion (version);

CREATE INDEX historicalstat_date on historicalstat (snapshotdate);
CREATE UNIQUE INDEX historicalstat_namedate on historicalstat (name, snapshotdate);

create index artist_relation_artist  on artist_relation (artist);
create index artist_relation_ref  on artist_relation (ref);

CREATE UNIQUE INDEX moderator_preference_moderator_key
    ON moderator_preference (moderator, name);

CREATE UNIQUE INDEX moderator_subscribe_artist_moderator_key
    ON moderator_subscribe_artist (moderator, artist);

CREATE UNIQUE INDEX country_isocode ON country (isocode);
CREATE UNIQUE INDEX country_name ON country (name);

CREATE INDEX release_album ON release (album);

CREATE INDEX album_amazon_asin_asin ON album_amazon_asin (asin);

-- vi: set ts=4 sw=4 et :
