\set ON_ERROR_STOP 1

DROP INDEX artist_rating_raw_idx_artist;
DROP INDEX artist_rating_raw_idx_editor;
    	
DROP INDEX artist_tag_raw_idx_artist;
DROP INDEX artist_tag_raw_idx_tag;
DROP INDEX artist_tag_raw_idx_moderator;

DROP INDEX release_rating_raw_idx_release;
DROP INDEX release_rating_raw_idx_editor;
    	
DROP INDEX cdtoc_raw_discid;
DROP INDEX cdtoc_raw_trackoffset;
DROP INDEX cdtoc_raw_toc;

DROP INDEX label_tag_raw_idx_label;
DROP INDEX label_tag_raw_idx_tag;
DROP INDEX label_tag_raw_idx_moderator;

DROP INDEX release_raw_idx_lastmodified;
DROP INDEX release_raw_idx_lookupcount;
DROP INDEX release_raw_idx_modifycount;

DROP INDEX release_tag_raw_idx_release;
DROP INDEX release_tag_raw_idx_tag;
DROP INDEX release_tag_raw_idx_moderator;

DROP INDEX track_rating_raw_idx_track;
DROP INDEX track_rating_raw_idx_editor;
    	
DROP INDEX track_raw_idx_release;

DROP INDEX track_tag_raw_idx_track;
DROP INDEX track_tag_raw_idx_tag;
DROP INDEX track_tag_raw_idx_moderator;

DROP INDEX label_rating_raw_idx_label;
DROP INDEX label_rating_raw_idx_editor;

DROP INDEX collection_has_release_join_combined_index;
DROP INDEX collection_discography_artist_join_combined_index;
DROP INDEX collection_ignore_release_combined_index;
DROP INDEX collection_watch_artist_combined_index;

DROP INDEX collection_has_release_join_album;
DROP INDEX collection_ignore_release_join_album;
DROP INDEX collection_discography_artist_join_artist;
DROP INDEX collection_watch_artist_join_artist;

DROP INDEX collection_info_moderator;

-- vi: set ts=4 sw=4 et :
