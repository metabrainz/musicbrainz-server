begin;

drop index Artist_NameIndex;
drop index Artist_SortNameIndex;
drop index Artist_GIDIndex;
drop index Artist_PageIndex;

drop index Album_NameIndex;
drop index Album_GIDIndex;
drop index Album_ArtistIndex;
drop index Album_PageIndex;

drop index Track_NameIndex;
drop index Track_GIDIndex;
drop index Track_ArtistIndex;

drop index TRM_TRMIndex;

drop index TRMJoin_TRMIndex;
drop index TRMJoin_TrackIndex;

drop index AlbumJoin_AlbumIndex;
drop index AlbumJoin_TrackIndex;

drop index Discid_DiscIndex;
drop index Discid_AlbumIndex;

drop index TOC_DiscIndex;
drop index TOC_AlbumIndex;

drop index Moderator_NameIndex;

drop index Moderation_ModeratorIndex;
drop index Moderation_ExpireTimeIndex;
drop index Moderation_StatusIndex;

drop index Votes_UidIndex;
drop index Votes_RowidIndex;

drop index ArtistAlias_NameIndex;
drop index ArtistAlias_RefIndex;

drop index WordList_WordIndex;

drop index AlbumWords_WordidIndex;
drop index AlbumWords_AlbumidIndex;
drop index AlbumWords_AlbumWordIndex;

drop index ArtistWords_WordidIndex;
drop index ArtistWords_ArtistidIndex;
drop index ArtistWords_ArtistWordIndex ;

drop index TrackWords_WordidIndex;
drop index TrackWords_TrackidIndex;
drop index TrackWords_TrackWordIndex;

drop index ModerationNote_ModIndex;

drop index Stats_TimestampIndex;

drop index ClientVersion_Version;

commit;
