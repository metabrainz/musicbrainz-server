\set ON_ERROR_STOP 1
BEGIN;

CREATE UNIQUE INDEX artist_idx_gid ON artist (gid);
CREATE INDEX artist_idx_name ON artist (name);
CREATE INDEX artist_idx_sortname ON artist (sortname);

CREATE INDEX artist_alias_idx_name ON artist_alias (name);
CREATE INDEX artist_alias_idx_artist ON artist_alias (artist);

CREATE UNIQUE INDEX artist_name_idx_name ON artist_name (name);
CREATE INDEX artist_name_idx_page ON artist_name (page_index(name));

CREATE INDEX artist_tag_idx_tag ON artist_tag (tag);

CREATE UNIQUE INDEX country_idx_isocode ON country (isocode);

CREATE UNIQUE INDEX editor_idx_name ON editor (LOWER(name));

CREATE UNIQUE INDEX label_idx_gid ON label (gid);
CREATE INDEX label_idx_name ON label (name);
CREATE INDEX label_idx_sortname ON label (sortname);

CREATE INDEX label_alias_idx_name ON label_alias (name);
CREATE INDEX label_alias_idx_label ON label_alias (label);

CREATE UNIQUE INDEX label_name_idx_name ON label_name (name);
CREATE INDEX label_name_idx_page ON label_name (page_index(name));

CREATE INDEX label_tag_idx_tag ON label_tag (tag);

CREATE UNIQUE INDEX language_idx_isocode_3b ON language (isocode_3b);
CREATE UNIQUE INDEX language_idx_isocode_3t ON language (isocode_3t);
CREATE UNIQUE INDEX language_idx_isocode_2 ON language (isocode_2);

CREATE UNIQUE INDEX medium_idx_release ON medium (release, position);
CREATE INDEX medium_idx_tracklist ON medium (tracklist);

CREATE UNIQUE INDEX recording_idx_gid ON recording (gid);
CREATE INDEX recording_idx_name ON recording (name);
CREATE INDEX recording_idx_artist_credit ON recording (artist_credit);

CREATE INDEX recording_tag_idx_tag ON recording_tag (tag);

CREATE UNIQUE INDEX release_idx_gid ON release (gid);
CREATE INDEX release_idx_name ON release (name);
CREATE INDEX release_idx_release_group ON release (release_group);
CREATE INDEX release_idx_artist_credit ON release (artist_credit);
CREATE INDEX release_idx_date ON release (date_year, date_month, date_day);

CREATE INDEX release_label_idx_release ON release_label (release);
CREATE INDEX release_label_idx_label ON release_label (label);

CREATE UNIQUE INDEX release_group_idx_gid ON release_group (gid);
CREATE INDEX release_group_idx_name ON release_group (name);
CREATE INDEX release_group_idx_artist_credit ON release_group (artist_credit);

CREATE INDEX release_group_tag_idx_tag ON release_group_tag (tag);

CREATE UNIQUE INDEX release_name_idx_name ON release_name (name);
CREATE INDEX release_name_idx_page ON release_name (page_index(name));

CREATE UNIQUE INDEX script_idx_isocode ON script (isocode);

CREATE UNIQUE INDEX tag_idx_name ON tag (name);

CREATE INDEX track_idx_recording ON track (recording);
CREATE UNIQUE INDEX track_idx_tracklist ON track (tracklist, position);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_artist_credit ON track (artist_credit);

CREATE UNIQUE INDEX track_name_idx_name ON track_name (name);
CREATE INDEX track_name_idx_page ON track_name (page_index(name));

CREATE INDEX tracklist_idx_trackcount ON tracklist (trackcount);

CREATE UNIQUE INDEX url_idx_gid ON url (gid);
CREATE UNIQUE INDEX url_idx_url ON url (url);

CREATE UNIQUE INDEX work_idx_gid ON work (gid);
CREATE INDEX work_idx_name ON work (name);
CREATE INDEX work_idx_artist_credit ON work (artist_credit);

CREATE UNIQUE INDEX work_name_idx_name ON work_name (name);
CREATE INDEX work_name_idx_page ON work_name (page_index(name));

CREATE INDEX work_tag_idx_tag ON work_tag (tag);

COMMIT;

-- vi: set ts=4 sw=4 et :
