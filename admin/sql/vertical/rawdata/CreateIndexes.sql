\set ON_ERROR_STOP 1

-- No BEGIN/COMMIT here.  Each index is created in its own transaction;
-- this is mainly because if you're setting up a big database, it
-- could get really annoying if it takes a long time to create the indexes,
-- only for the last one to fail and the whole lot gets rolled back.
-- It should also be more efficient, of course.

-- Alphabetical order by table

CREATE INDEX artist_rating_raw_idx_artist ON artist_rating_raw (artist);
CREATE INDEX artist_rating_raw_idx_editor ON artist_rating_raw (editor);
    	
CREATE INDEX artist_tag_raw_idx_artist ON artist_tag_raw (artist);
CREATE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE INDEX artist_tag_raw_idx_moderator ON artist_tag_raw (moderator);

CREATE INDEX release_rating_raw_idx_release ON release_rating_raw (release);
CREATE INDEX release_rating_raw_idx_editor ON release_rating_raw (editor);
    	
CREATE INDEX release_tag_raw_idx_release ON release_tag_raw (release);
CREATE INDEX release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX release_tag_raw_idx_moderator ON release_tag_raw (moderator);

CREATE INDEX track_rating_raw_idx_track ON track_rating_raw (track);
CREATE INDEX track_rating_raw_idx_editor ON track_rating_raw (editor);
    	
CREATE INDEX track_tag_raw_idx_track ON track_tag_raw (track);
CREATE INDEX track_tag_raw_idx_tag ON track_tag_raw (tag);
CREATE INDEX track_tag_raw_idx_moderator ON track_tag_raw (moderator);

CREATE INDEX label_rating_raw_idx_label ON label_rating_raw (label);
CREATE INDEX label_rating_raw_idx_editor ON label_rating_raw (editor);

CREATE INDEX label_tag_raw_idx_label ON label_tag_raw (label);
CREATE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE INDEX label_tag_raw_idx_moderator ON label_tag_raw (moderator);

-- vi: set ts=4 sw=4 et :
