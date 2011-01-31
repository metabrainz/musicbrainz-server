\set ON_ERROR_STOP 1

-- No BEGIN/COMMIT here.  Each index is created in its own transaction;
-- this is mainly because if you're setting up a big database, it
-- could get really annoying if it takes a long time to create the indexes,
-- only for the last one to fail and the whole lot gets rolled back.
-- It should also be more efficient, of course.

-- Alphabetical order by table

CREATE INDEX edit_idx_editor ON edit (editor);
CREATE INDEX edit_idx_type ON edit (type);

-- Partial index for status (excludes applied edits)
CREATE INDEX edit_idx_status ON edit (status) WHERE status != 2;

-- Entity indexes
CREATE INDEX edit_artist_idx ON edit_artist (artist);
CREATE INDEX edit_label_idx ON edit_label (label);
CREATE INDEX edit_release_idx ON edit_release (release);
CREATE INDEX edit_release_group_idx ON edit_release_group (release_group);
CREATE INDEX edit_recording_idx ON edit_recording (recording);
CREATE INDEX edit_work_idx ON edit_work (work);
CREATE INDEX edit_url_idx ON edit_url (url);

CREATE INDEX edit_note_idx_edit ON edit_note (edit);
CREATE INDEX vote_idx_edit ON vote (edit);
CREATE INDEX vote_idx_editor ON vote (editor);

CREATE INDEX artist_rating_raw_idx_artist ON artist_rating_raw (artist);
CREATE INDEX artist_rating_raw_idx_editor ON artist_rating_raw (editor);

CREATE INDEX artist_tag_raw_idx_artist ON artist_tag_raw (artist);
CREATE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE INDEX artist_tag_raw_idx_editor ON artist_tag_raw (editor);

CREATE INDEX release_group_rating_raw_idx_release_group ON release_group_rating_raw (release_group);
CREATE INDEX release_group_rating_raw_idx_editor ON release_group_rating_raw (editor);

CREATE INDEX cdtoc_raw_discid ON cdtoc_raw (discid);
CREATE INDEX cdtoc_raw_track_offset ON cdtoc_raw (track_offset);
CREATE UNIQUE INDEX cdtoc_raw_toc ON cdtoc_raw (track_count, leadout_offset, track_offset);

CREATE INDEX label_tag_raw_idx_label ON label_tag_raw (label);
CREATE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE INDEX label_tag_raw_idx_editor ON label_tag_raw (editor);

CREATE INDEX release_raw_idx_last_modified ON release_raw (last_modified);
CREATE INDEX release_raw_idx_lookup_count ON release_raw (lookup_count);
CREATE INDEX release_raw_idx_modify_count ON release_raw (modify_count);

CREATE INDEX release_group_tag_raw_idx_release ON release_group_tag_raw (release_group);
CREATE INDEX release_group_tag_raw_idx_tag ON release_group_tag_raw (tag);
CREATE INDEX release_group_tag_raw_idx_editor ON release_group_tag_raw (editor);

CREATE INDEX recording_rating_raw_idx_track ON recording_rating_raw (recording);
CREATE INDEX recording_rating_raw_idx_editor ON recording_rating_raw (editor);

CREATE INDEX track_raw_idx_release ON track_raw (release);

CREATE INDEX recording_tag_raw_idx_track ON recording_tag_raw (recording);
CREATE INDEX recording_tag_raw_idx_tag ON recording_tag_raw (tag);
CREATE INDEX recording_tag_raw_idx_editor ON recording_tag_raw (editor);

CREATE INDEX label_rating_raw_idx_label ON label_rating_raw (label);
CREATE INDEX label_rating_raw_idx_editor ON label_rating_raw (editor);

-- vi: set ts=4 sw=4 et :
