\set ON_ERROR_STOP 1
BEGIN;

CREATE UNIQUE INDEX artist_idx_gid ON artist (gid);
CREATE INDEX artist_idx_name ON artist (name);
CREATE INDEX artist_idx_sortname ON artist (sortname);

CREATE INDEX artist_alias_idx_artist ON artist_alias (artist);
CREATE UNIQUE INDEX artist_alias_idx_name_artist ON artist_alias (name, artist, locale);

CREATE INDEX artist_credit_name_idx_artist ON artist_credit_name (artist);

CREATE UNIQUE INDEX artist_name_idx_name ON artist_name (name);
CREATE INDEX artist_name_idx_page ON artist_name (page_index(name));

CREATE INDEX artist_tag_idx_tag ON artist_tag (tag);
CREATE INDEX artist_tag_idx_artist ON artist_tag (artist);

CREATE UNIQUE INDEX country_idx_isocode ON country (isocode);

CREATE INDEX currentstat_name ON currentstat (name);

CREATE INDEX dbmirror_Pending_XID_Index ON dbmirror_Pending (XID);

CREATE INDEX editor_idx_name ON editor (LOWER(name));
CREATE INDEX editor_collection_idx_editor ON editor_collection (editor);

CREATE INDEX editor_subscribe_artist_idx_uniq ON editor_subscribe_artist (editor, artist);
CREATE INDEX editor_subscribe_label_idx_uniq ON editor_subscribe_label (editor, label);
CREATE INDEX editor_subscribe_editor_idx_uniq ON editor_subscribe_editor (editor, subscribededitor);

CREATE INDEX historicalstat_date ON historicalstat (snapshotdate);
CREATE INDEX historicalstat_name_snapshotdate ON historicalstat (name, snapshotdate);

CREATE INDEX isrc_idx_isrc ON isrc (isrc);

CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_label_idx_uniq ON l_artist_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_recording_idx_uniq ON l_artist_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_release_idx_uniq ON l_artist_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_release_group_idx_uniq ON l_artist_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_artist_work_idx_uniq ON l_artist_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_label_label_idx_uniq ON l_label_label (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_recording_idx_uniq ON l_label_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_release_idx_uniq ON l_label_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_release_group_idx_uniq ON l_label_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_url_idx_uniq ON l_label_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_label_work_idx_uniq ON l_label_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_recording_recording_idx_uniq ON l_recording_recording (entity0, entity1, link);
CREATE UNIQUE INDEX l_recording_release_idx_uniq ON l_recording_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_recording_release_group_idx_uniq ON l_recording_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_recording_url_idx_uniq ON l_recording_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_recording_work_idx_uniq ON l_recording_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_release_release_idx_uniq ON l_release_release (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_release_group_idx_uniq ON l_release_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_url_idx_uniq ON l_release_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_work_idx_uniq ON l_release_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_release_group_release_group_idx_uniq ON l_release_group_release_group (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_group_url_idx_uniq ON l_release_group_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_release_group_work_idx_uniq ON l_release_group_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (entity0, entity1, link);
CREATE UNIQUE INDEX l_url_work_idx_uniq ON l_url_work (entity0, entity1, link);

CREATE UNIQUE INDEX l_work_work_idx_uniq ON l_work_work (entity0, entity1, link);

CREATE INDEX l_artist_artist_idx_entity1 ON l_artist_artist (entity1);
CREATE INDEX l_artist_label_idx_entity1 ON l_artist_label (entity1);
CREATE INDEX l_artist_recording_idx_entity1 ON l_artist_recording (entity1);
CREATE INDEX l_artist_release_idx_entity1 ON l_artist_release (entity1);
CREATE INDEX l_artist_release_group_idx_entity1 ON l_artist_release_group (entity1);
CREATE INDEX l_artist_url_idx_entity1 ON l_artist_url (entity1);
CREATE INDEX l_artist_work_idx_entity1 ON l_artist_work (entity1);

CREATE INDEX l_label_label_idx_entity1 ON l_label_label (entity1);
CREATE INDEX l_label_recording_idx_entity1 ON l_label_recording (entity1);
CREATE INDEX l_label_release_idx_entity1 ON l_label_release (entity1);
CREATE INDEX l_label_release_group_idx_entity1 ON l_label_release_group (entity1);
CREATE INDEX l_label_url_idx_entity1 ON l_label_url (entity1);
CREATE INDEX l_label_work_idx_entity1 ON l_label_work (entity1);

CREATE INDEX l_recording_recording_idx_entity1 ON l_recording_recording (entity1);
CREATE INDEX l_recording_release_idx_entity1 ON l_recording_release (entity1);
CREATE INDEX l_recording_release_group_idx_entity1 ON l_recording_release_group (entity1);
CREATE INDEX l_recording_url_idx_entity1 ON l_recording_url (entity1);
CREATE INDEX l_recording_work_idx_entity1 ON l_recording_work (entity1);

CREATE INDEX l_release_release_idx_entity1 ON l_release_release (entity1);
CREATE INDEX l_release_release_group_idx_entity1 ON l_release_release_group (entity1);
CREATE INDEX l_release_url_idx_entity1 ON l_release_url (entity1);
CREATE INDEX l_release_work_idx_entity1 ON l_release_work (entity1);

CREATE INDEX l_release_group_release_group_idx_entity1 ON l_release_group_release_group (entity1);
CREATE INDEX l_release_group_url_idx_entity1 ON l_release_group_url (entity1);
CREATE INDEX l_release_group_work_idx_entity1 ON l_release_group_work (entity1);

CREATE INDEX l_url_url_idx_entity1 ON l_url_url (entity1);
CREATE INDEX l_url_work_idx_entity1 ON l_url_work (entity1);

CREATE INDEX l_work_work_idx_entity1 ON l_work_work (entity1);

CREATE UNIQUE INDEX link_type_idx_gid ON link_type (gid);
CREATE UNIQUE INDEX link_attribute_type_idx_gid ON link_attribute_type (gid);

CREATE INDEX link_idx_type_attr ON link (link_type, attributecount);

CREATE UNIQUE INDEX label_idx_gid ON label (gid);
CREATE INDEX label_idx_name ON label (name);
CREATE INDEX label_idx_sortname ON label (sortname);

CREATE INDEX label_alias_idx_label ON label_alias (label);
CREATE UNIQUE INDEX label_alias_idx_name_label ON label_alias (name, label, locale);

CREATE UNIQUE INDEX label_name_idx_name ON label_name (name);
CREATE INDEX label_name_idx_page ON label_name (page_index(name));

CREATE INDEX label_tag_idx_tag ON label_tag (tag);
CREATE INDEX label_tag_idx_label ON label_tag (label);

CREATE UNIQUE INDEX language_idx_isocode_3b ON language (isocode_3b);
CREATE UNIQUE INDEX language_idx_isocode_3t ON language (isocode_3t);
CREATE UNIQUE INDEX language_idx_isocode_2 ON language (isocode_2);

CREATE UNIQUE INDEX medium_idx_release ON medium (release, position);
CREATE INDEX medium_idx_tracklist ON medium (tracklist);

CREATE UNIQUE INDEX puid_idx_puid ON puid (puid);

CREATE UNIQUE INDEX recording_idx_gid ON recording (gid);
CREATE INDEX recording_idx_name ON recording (name);
CREATE INDEX recording_idx_artist_credit ON recording (artist_credit);

CREATE UNIQUE INDEX recording_puid_idx_uniq ON recording_puid (recording, puid);

CREATE INDEX recording_tag_idx_tag ON recording_tag (tag);
CREATE INDEX recording_tag_idx_recording ON recording_tag (recording);


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
CREATE INDEX release_group_tag_idx_release_group ON release_group_tag (release_group);


CREATE UNIQUE INDEX release_name_idx_name ON release_name (name);
CREATE INDEX release_name_idx_page ON release_name (page_index(name));

CREATE UNIQUE INDEX script_idx_isocode ON script (isocode);

CREATE UNIQUE INDEX tag_idx_name ON tag (name);

CREATE INDEX track_idx_recording ON track (recording);
CREATE INDEX track_idx_tracklist ON track (tracklist, position);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_artist_credit ON track (artist_credit);

CREATE UNIQUE INDEX track_name_idx_name ON track_name (name);

CREATE INDEX tracklist_idx_trackcount ON tracklist (trackcount);

CREATE INDEX tracklist_index_idx ON tracklist_index USING gist (toc);

CREATE UNIQUE INDEX url_idx_gid ON url (gid);
CREATE UNIQUE INDEX url_idx_url ON url (url);

CREATE UNIQUE INDEX work_idx_gid ON work (gid);
CREATE INDEX work_idx_name ON work (name);
CREATE INDEX work_idx_artist_credit ON work (artist_credit);

CREATE INDEX work_alias_idx_work ON work_alias (work);
CREATE UNIQUE INDEX work_alias_idx_name_work ON work_alias (name, work, locale);

CREATE UNIQUE INDEX work_name_idx_name ON work_name (name);
CREATE INDEX work_name_idx_page ON work_name (page_index(name));

CREATE INDEX work_tag_idx_tag ON work_tag (tag);

-- lowercase indexes for javascript autocomplete
CREATE INDEX artist_name_idx_lower_name ON artist_name (lower(name));
CREATE INDEX label_name_idx_lower_name ON label_name (lower(name));

COMMIT;

-- vi: set ts=4 sw=4 et :
