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
DROP INDEX trmjoin_trmtrack;

drop index AlbumJoin_AlbumIndex;
drop index AlbumJoin_TrackIndex;
DROP INDEX albumjoin_albumtrack;

drop index Discid_DiscIndex;
drop index Discid_AlbumIndex;

drop index TOC_DiscIndex;
drop index TOC_AlbumIndex;

drop index Moderator_NameIndex;

DROP INDEX moderation_open_idx_moderator;
DROP INDEX moderation_open_idx_expiretime;
DROP INDEX moderation_open_idx_status;
DROP INDEX moderation_open_idx_artist;
DROP INDEX moderation_open_idx_rowid;

DROP INDEX moderation_note_open_idx_moderation;

DROP INDEX vote_open_idx_moderator;
DROP INDEX vote_open_idx_moderation;

DROP INDEX moderation_closed_idx_moderator;
DROP INDEX moderation_closed_idx_expiretime;
DROP INDEX moderation_closed_idx_status;
DROP INDEX moderation_closed_idx_artist;
DROP INDEX moderation_closed_idx_rowid;

DROP INDEX moderation_note_closed_idx_moderation;

DROP INDEX vote_closed_idx_moderator;
DROP INDEX vote_closed_idx_moderation;

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

drop index Stats_TimestampIndex;

drop index ClientVersion_Version;

DROP INDEX historicalstat_date;
DROP INDEX historicalstat_namedate;

drop index artist_relation_artist;
drop index artist_relation_ref;

DROP INDEX country_isocode;
DROP INDEX country_name;

DROP INDEX release_album;

DROP INDEX album_amazon_asin_asin;

-- vi: set ts=4 sw=4 et :
