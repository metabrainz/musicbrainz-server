\set ON_ERROR_STOP 1
begin;
create unique index WordList_WordIndex on WordList (Word);
create index AlbumWords_WordidIndex on AlbumWords (Wordid);
create index AlbumWords_AlbumidIndex on AlbumWords (Albumid);
create unique index AlbumWords_AlbumWordIndex on AlbumWords (Wordid,Albumid);;
create index ArtistWords_WordidIndex on ArtistWords (Wordid);
create index ArtistWords_ArtistidIndex on ArtistWords (Artistid);
create unique index ArtistWords_ArtistWordIndex on ArtistWords (Wordid,Artistid);
create index TrackWords_WordidIndex on TrackWords (Wordid);
create index TrackWords_TrackidIndex on TrackWords (Trackid);
create unique index TrackWords_TrackWordIndex on TrackWords (Wordid,Trackid);
commit;
