\set ON_ERROR_STOP 1
BEGIN;

CREATE INDEX application_idx_owner ON application (owner);
CREATE UNIQUE INDEX application_idx_oauth_id ON application (oauth_id);

CREATE UNIQUE INDEX area_type_idx_gid ON area_type (gid);

CREATE UNIQUE INDEX area_idx_gid ON area (gid);
CREATE INDEX area_idx_name ON area (name);

CREATE UNIQUE INDEX area_alias_type_idx_gid ON area_alias_type (gid);

CREATE UNIQUE INDEX artist_alias_type_idx_gid ON artist_alias_type (gid);

CREATE INDEX iso_3166_1_idx_area ON iso_3166_1 (area);
CREATE INDEX iso_3166_2_idx_area ON iso_3166_2 (area);
CREATE INDEX iso_3166_3_idx_area ON iso_3166_3 (area);

CREATE INDEX area_alias_idx_area ON area_alias (area);
CREATE UNIQUE INDEX area_alias_idx_primary ON area_alias (area, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX area_attribute_idx_area ON area_attribute (area);

CREATE UNIQUE INDEX area_attribute_type_idx_gid ON area_attribute_type (gid);

CREATE INDEX area_attribute_type_allowed_value_idx_name ON area_attribute_type_allowed_value (area_attribute_type);
CREATE UNIQUE INDEX area_attribute_type_allowed_value_idx_gid ON area_attribute_type_allowed_value (gid);

CREATE INDEX area_tag_idx_tag ON area_tag (tag);

CREATE INDEX area_tag_raw_idx_area ON area_tag_raw (area);
CREATE INDEX area_tag_raw_idx_tag ON area_tag_raw (tag);
CREATE INDEX area_tag_raw_idx_editor ON area_tag_raw (editor);

CREATE UNIQUE INDEX artist_idx_gid ON artist (gid);
CREATE INDEX artist_idx_name ON artist (name);
CREATE INDEX artist_idx_sort_name ON artist (sort_name);

CREATE INDEX artist_idx_area ON artist (area);
CREATE INDEX artist_idx_begin_area ON artist (begin_area);
CREATE INDEX artist_idx_end_area ON artist (end_area);

CREATE UNIQUE INDEX artist_idx_null_comment ON artist (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX artist_idx_uniq_name_comment ON artist (name, comment) WHERE comment IS NOT NULL;

CREATE INDEX artist_alias_idx_artist ON artist_alias (artist);
CREATE UNIQUE INDEX artist_alias_idx_primary ON artist_alias (artist, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX artist_attribute_idx_artist ON artist_attribute (artist);

CREATE UNIQUE INDEX artist_attribute_type_idx_gid ON artist_attribute_type (gid);

CREATE INDEX artist_attribute_type_allowed_value_idx_name ON artist_attribute_type_allowed_value (artist_attribute_type);
CREATE UNIQUE INDEX artist_attribute_type_allowed_value_idx_gid ON artist_attribute_type_allowed_value (gid);

CREATE INDEX artist_credit_name_idx_artist ON artist_credit_name (artist);

CREATE UNIQUE INDEX artist_type_idx_gid ON artist_type (gid);

CREATE INDEX artist_tag_idx_tag ON artist_tag (tag);

CREATE INDEX artist_rating_raw_idx_artist ON artist_rating_raw (artist);
CREATE INDEX artist_rating_raw_idx_editor ON artist_rating_raw (editor);

CREATE INDEX artist_tag_raw_idx_tag ON artist_tag_raw (tag);
CREATE INDEX artist_tag_raw_idx_editor ON artist_tag_raw (editor);

CREATE INDEX cdtoc_raw_discid ON cdtoc_raw (discid);
CREATE INDEX cdtoc_raw_track_offset ON cdtoc_raw (track_offset);
CREATE UNIQUE INDEX cdtoc_raw_toc ON cdtoc_raw (track_count, leadout_offset, track_offset);

CREATE UNIQUE INDEX editor_idx_name ON editor (LOWER(name));
CREATE UNIQUE INDEX old_editor_name_idx_name ON old_editor_name (LOWER(name));
CREATE INDEX editor_language_idx_language ON editor_language (language);

CREATE INDEX editor_oauth_token_idx_editor ON editor_oauth_token (editor);
CREATE UNIQUE INDEX editor_oauth_token_idx_access_token ON editor_oauth_token (access_token);
CREATE UNIQUE INDEX editor_oauth_token_idx_refresh_token ON editor_oauth_token (refresh_token);

CREATE UNIQUE INDEX editor_preference_idx_editor_name ON editor_preference (editor, name);

CREATE UNIQUE INDEX editor_subscribe_artist_idx_uniq ON editor_subscribe_artist (editor, artist);
CREATE INDEX editor_subscribe_artist_idx_artist ON editor_subscribe_artist (artist);
CREATE UNIQUE INDEX editor_subscribe_collection_idx_uniq ON editor_subscribe_collection (editor, collection);
CREATE INDEX editor_subscribe_collection_idx_collection ON editor_subscribe_collection (collection);
CREATE UNIQUE INDEX editor_subscribe_label_idx_uniq ON editor_subscribe_label (editor, label);
CREATE INDEX editor_subscribe_label_idx_label ON editor_subscribe_label (label);
CREATE UNIQUE INDEX editor_subscribe_series_idx_uniq ON editor_subscribe_series (editor, series);
CREATE INDEX editor_subscribe_series_idx_series ON editor_subscribe_series (series);
CREATE UNIQUE INDEX editor_subscribe_editor_idx_uniq ON editor_subscribe_editor (editor, subscribed_editor);

CREATE UNIQUE INDEX event_type_idx_gid ON event_type (gid);

CREATE UNIQUE INDEX gender_idx_gid ON gender (gid);

CREATE UNIQUE INDEX instrument_type_idx_gid ON instrument_type (gid);

CREATE UNIQUE INDEX instrument_alias_type_idx_gid ON instrument_alias_type (gid);

CREATE INDEX edit_idx_editor_id_desc ON edit (editor, id DESC); -- DESC only for historical reasons
CREATE INDEX edit_idx_type_id ON edit (type, id);

-- Index for the "last 24 hours" edit count on the user profile
CREATE INDEX edit_idx_editor_open_time ON edit (editor, open_time);

-- Partial index for status (excludes applied edits)
CREATE INDEX edit_idx_status_id ON edit (status, id) WHERE status <> 2;

-- Indexes for materialized edit status
CREATE INDEX edit_artist_idx_status ON edit_artist (status);
CREATE INDEX edit_label_idx_status ON edit_label (status);

CREATE INDEX edit_idx_open_time ON edit USING BRIN (open_time);
CREATE INDEX edit_idx_close_time ON edit USING BRIN (close_time);
CREATE INDEX edit_idx_expire_time ON edit USING BRIN (expire_time);

CREATE INDEX edit_data_idx_link_type ON edit_data USING GIN (
    array_remove(ARRAY[
                     (data#>>'{link_type,id}')::int,
                     (data#>>'{link,link_type,id}')::int,
                     (data#>>'{old,link_type,id}')::int,
                     (data#>>'{new,link_type,id}')::int,
                     (data#>>'{relationship,link_type,id}')::int
                 ], NULL)
);

-- Entity indexes
CREATE INDEX edit_area_idx ON edit_area (area);
CREATE INDEX edit_artist_idx ON edit_artist (artist);
CREATE INDEX edit_event_idx ON edit_event (event);
CREATE INDEX edit_instrument_idx ON edit_instrument (instrument);
CREATE INDEX edit_label_idx ON edit_label (label);
CREATE INDEX edit_place_idx ON edit_place (place);
CREATE INDEX edit_release_idx ON edit_release (release);
CREATE INDEX edit_release_group_idx ON edit_release_group (release_group);
CREATE INDEX edit_recording_idx ON edit_recording (recording);
CREATE INDEX edit_series_idx ON edit_series (series);
CREATE INDEX edit_work_idx ON edit_work (work);
CREATE INDEX edit_url_idx ON edit_url (url);

CREATE INDEX edit_note_idx_edit ON edit_note (edit);
CREATE INDEX edit_note_idx_editor ON edit_note (editor);
CREATE INDEX edit_note_idx_post_time ON edit_note USING BRIN (post_time);
CREATE INDEX edit_note_idx_post_time_edit ON edit_note (post_time DESC NULLS LAST, edit DESC);

CREATE INDEX edit_note_recipient_idx_recipient ON edit_note_recipient (recipient);

CREATE UNIQUE INDEX event_idx_gid ON event (gid);
CREATE INDEX event_idx_name ON event (name);

CREATE UNIQUE INDEX event_alias_type_idx_gid ON event_alias_type (gid);

CREATE INDEX event_alias_idx_event ON event_alias (event);
CREATE UNIQUE INDEX event_alias_idx_primary ON event_alias (event, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX event_attribute_idx_event ON event_attribute (event);

CREATE UNIQUE INDEX event_attribute_type_idx_gid ON event_attribute_type (gid);

CREATE INDEX event_attribute_type_allowed_value_idx_name ON event_attribute_type_allowed_value (event_attribute_type);
CREATE UNIQUE INDEX event_attribute_type_allowed_value_idx_gid ON event_attribute_type_allowed_value (gid);

CREATE INDEX event_rating_raw_idx_event ON event_rating_raw (event);
CREATE INDEX event_rating_raw_idx_editor ON event_rating_raw (editor);

CREATE INDEX event_tag_idx_tag ON event_tag (tag);

CREATE INDEX event_tag_raw_idx_tag ON event_tag_raw (tag);
CREATE INDEX event_tag_raw_idx_editor ON event_tag_raw (editor);

CREATE UNIQUE INDEX instrument_idx_gid ON instrument (gid);
CREATE INDEX instrument_idx_name ON instrument (name);

CREATE INDEX instrument_alias_idx_instrument ON instrument_alias (instrument);
CREATE UNIQUE INDEX instrument_alias_idx_primary ON instrument_alias (instrument, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX instrument_attribute_idx_instrument ON instrument_attribute (instrument);

CREATE UNIQUE INDEX instrument_attribute_type_idx_gid ON instrument_attribute_type (gid);

CREATE INDEX instrument_attribute_type_allowed_value_idx_name ON instrument_attribute_type_allowed_value (instrument_attribute_type);
CREATE UNIQUE INDEX instrument_attribute_type_allowed_value_idx_gid ON instrument_attribute_type_allowed_value (gid);

CREATE INDEX instrument_tag_idx_tag ON instrument_tag (tag);

CREATE INDEX instrument_tag_raw_idx_instrument ON instrument_tag_raw (instrument);
CREATE INDEX instrument_tag_raw_idx_tag ON instrument_tag_raw (tag);
CREATE INDEX instrument_tag_raw_idx_editor ON instrument_tag_raw (editor);

CREATE INDEX isrc_idx_isrc ON isrc (isrc);
CREATE INDEX isrc_idx_recording ON isrc (recording);
CREATE UNIQUE INDEX isrc_idx_isrc_recording ON isrc (isrc, recording);

CREATE INDEX iswc_idx_work ON iswc (work);
CREATE UNIQUE INDEX iswc_idx_iswc ON iswc (iswc, work);

CREATE UNIQUE INDEX l_area_area_idx_uniq ON l_area_area (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_artist_idx_uniq ON l_area_artist (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_event_idx_uniq ON l_area_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_instrument_idx_uniq ON l_area_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_label_idx_uniq ON l_area_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_place_idx_uniq ON l_area_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_recording_idx_uniq ON l_area_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_release_idx_uniq ON l_area_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_release_group_idx_uniq ON l_area_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_series_idx_uniq ON l_area_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_url_idx_uniq ON l_area_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_area_work_idx_uniq ON l_area_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_artist_artist_idx_uniq ON l_artist_artist (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_event_idx_uniq ON l_artist_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_instrument_idx_uniq ON l_artist_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_label_idx_uniq ON l_artist_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_place_idx_uniq ON l_artist_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_recording_idx_uniq ON l_artist_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_release_idx_uniq ON l_artist_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_release_group_idx_uniq ON l_artist_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_series_idx_uniq ON l_artist_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_url_idx_uniq ON l_artist_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_artist_work_idx_uniq ON l_artist_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_event_event_idx_uniq ON l_event_event (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_instrument_idx_uniq ON l_event_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_label_idx_uniq ON l_event_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_place_idx_uniq ON l_event_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_recording_idx_uniq ON l_event_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_release_idx_uniq ON l_event_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_release_group_idx_uniq ON l_event_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_series_idx_uniq ON l_event_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_url_idx_uniq ON l_event_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_event_work_idx_uniq ON l_event_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_instrument_instrument_idx_uniq ON l_instrument_instrument (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_label_idx_uniq ON l_instrument_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_place_idx_uniq ON l_instrument_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_recording_idx_uniq ON l_instrument_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_release_idx_uniq ON l_instrument_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_release_group_idx_uniq ON l_instrument_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_series_idx_uniq ON l_instrument_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_url_idx_uniq ON l_instrument_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_instrument_work_idx_uniq ON l_instrument_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_label_label_idx_uniq ON l_label_label (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_place_idx_uniq ON l_label_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_recording_idx_uniq ON l_label_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_release_idx_uniq ON l_label_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_release_group_idx_uniq ON l_label_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_series_idx_uniq ON l_label_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_url_idx_uniq ON l_label_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_label_work_idx_uniq ON l_label_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_place_place_idx_uniq ON l_place_place (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_recording_idx_uniq ON l_place_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_release_idx_uniq ON l_place_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_release_group_idx_uniq ON l_place_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_series_idx_uniq ON l_place_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_url_idx_uniq ON l_place_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_place_work_idx_uniq ON l_place_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_recording_recording_idx_uniq ON l_recording_recording (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_release_idx_uniq ON l_recording_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_release_group_idx_uniq ON l_recording_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_series_idx_uniq ON l_recording_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_url_idx_uniq ON l_recording_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_recording_work_idx_uniq ON l_recording_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_release_release_idx_uniq ON l_release_release (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_release_group_idx_uniq ON l_release_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_series_idx_uniq ON l_release_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_url_idx_uniq ON l_release_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_work_idx_uniq ON l_release_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_release_group_release_group_idx_uniq ON l_release_group_release_group (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_series_idx_uniq ON l_release_group_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_url_idx_uniq ON l_release_group_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_release_group_work_idx_uniq ON l_release_group_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_series_series_idx_uniq ON l_series_series (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_series_url_idx_uniq ON l_series_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_series_work_idx_uniq ON l_series_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_url_url_idx_uniq ON l_url_url (entity0, entity1, link, link_order);
CREATE UNIQUE INDEX l_url_work_idx_uniq ON l_url_work (entity0, entity1, link, link_order);

CREATE UNIQUE INDEX l_work_work_idx_uniq ON l_work_work (entity0, entity1, link, link_order);

CREATE INDEX l_area_area_idx_entity1 ON l_area_area (entity1);
CREATE INDEX l_area_artist_idx_entity1 ON l_area_artist (entity1);
CREATE INDEX l_area_event_idx_entity1 ON l_area_event (entity1);
CREATE INDEX l_area_instrument_idx_entity1 ON l_area_instrument (entity1);
CREATE INDEX l_area_label_idx_entity1 ON l_area_label (entity1);
CREATE INDEX l_area_place_idx_entity1 ON l_area_place (entity1);
CREATE INDEX l_area_recording_idx_entity1 ON l_area_recording (entity1);
CREATE INDEX l_area_release_idx_entity1 ON l_area_release (entity1);
CREATE INDEX l_area_release_group_idx_entity1 ON l_area_release_group (entity1);
CREATE INDEX l_area_series_idx_entity1 ON l_area_series (entity1);
CREATE INDEX l_area_url_idx_entity1 ON l_area_url (entity1);
CREATE INDEX l_area_work_idx_entity1 ON l_area_work (entity1);

CREATE INDEX l_artist_artist_idx_entity1 ON l_artist_artist (entity1);
CREATE INDEX l_artist_event_idx_entity1 ON l_artist_event (entity1);
CREATE INDEX l_artist_instrument_idx_entity1 ON l_artist_instrument (entity1);
CREATE INDEX l_artist_label_idx_entity1 ON l_artist_label (entity1);
CREATE INDEX l_artist_place_idx_entity1 ON l_artist_place (entity1);
CREATE INDEX l_artist_recording_idx_entity1 ON l_artist_recording (entity1);
CREATE INDEX l_artist_release_idx_entity1 ON l_artist_release (entity1);
CREATE INDEX l_artist_release_group_idx_entity1 ON l_artist_release_group (entity1);
CREATE INDEX l_artist_series_idx_entity1 ON l_artist_series (entity1);
CREATE INDEX l_artist_url_idx_entity1 ON l_artist_url (entity1);
CREATE INDEX l_artist_work_idx_entity1 ON l_artist_work (entity1);

CREATE INDEX l_event_event_idx_entity1 ON l_event_event (entity1);
CREATE INDEX l_event_instrument_idx_entity1 ON l_event_instrument (entity1);
CREATE INDEX l_event_label_idx_entity1 ON l_event_label (entity1);
CREATE INDEX l_event_place_idx_entity1 ON l_event_place (entity1);
CREATE INDEX l_event_recording_idx_entity1 ON l_event_recording (entity1);
CREATE INDEX l_event_release_idx_entity1 ON l_event_release (entity1);
CREATE INDEX l_event_release_group_idx_entity1 ON l_event_release_group (entity1);
CREATE INDEX l_event_series_idx_entity1 ON l_event_series (entity1);
CREATE INDEX l_event_url_idx_entity1 ON l_event_url (entity1);
CREATE INDEX l_event_work_idx_entity1 ON l_event_work (entity1);

CREATE INDEX l_instrument_instrument_idx_entity1 ON l_instrument_instrument (entity1);
CREATE INDEX l_instrument_label_idx_entity1 ON l_instrument_label (entity1);
CREATE INDEX l_instrument_place_idx_entity1 ON l_instrument_place (entity1);
CREATE INDEX l_instrument_recording_idx_entity1 ON l_instrument_recording (entity1);
CREATE INDEX l_instrument_release_idx_entity1 ON l_instrument_release (entity1);
CREATE INDEX l_instrument_release_group_idx_entity1 ON l_instrument_release_group (entity1);
CREATE INDEX l_instrument_series_idx_entity1 ON l_instrument_series (entity1);
CREATE INDEX l_instrument_url_idx_entity1 ON l_instrument_url (entity1);
CREATE INDEX l_instrument_work_idx_entity1 ON l_instrument_work (entity1);

CREATE INDEX l_label_label_idx_entity1 ON l_label_label (entity1);
CREATE INDEX l_label_place_idx_entity1 ON l_label_place (entity1);
CREATE INDEX l_label_recording_idx_entity1 ON l_label_recording (entity1);
CREATE INDEX l_label_release_idx_entity1 ON l_label_release (entity1);
CREATE INDEX l_label_release_group_idx_entity1 ON l_label_release_group (entity1);
CREATE INDEX l_label_series_idx_entity1 ON l_label_series (entity1);
CREATE INDEX l_label_url_idx_entity1 ON l_label_url (entity1);
CREATE INDEX l_label_work_idx_entity1 ON l_label_work (entity1);

CREATE INDEX l_place_place_idx_entity1 ON l_place_place (entity1);
CREATE INDEX l_place_recording_idx_entity1 ON l_place_recording (entity1);
CREATE INDEX l_place_release_idx_entity1 ON l_place_release (entity1);
CREATE INDEX l_place_release_group_idx_entity1 ON l_place_release_group (entity1);
CREATE INDEX l_place_series_idx_entity1 ON l_place_series (entity1);
CREATE INDEX l_place_url_idx_entity1 ON l_place_url (entity1);
CREATE INDEX l_place_work_idx_entity1 ON l_place_work (entity1);

CREATE INDEX l_recording_recording_idx_entity1 ON l_recording_recording (entity1);
CREATE INDEX l_recording_release_idx_entity1 ON l_recording_release (entity1);
CREATE INDEX l_recording_release_group_idx_entity1 ON l_recording_release_group (entity1);
CREATE INDEX l_recording_series_idx_entity1 ON l_recording_series (entity1);
CREATE INDEX l_recording_url_idx_entity1 ON l_recording_url (entity1);
CREATE INDEX l_recording_work_idx_entity1 ON l_recording_work (entity1);

CREATE INDEX l_release_release_idx_entity1 ON l_release_release (entity1);
CREATE INDEX l_release_release_group_idx_entity1 ON l_release_release_group (entity1);
CREATE INDEX l_release_series_idx_entity1 ON l_release_series (entity1);
CREATE INDEX l_release_url_idx_entity1 ON l_release_url (entity1);
CREATE INDEX l_release_work_idx_entity1 ON l_release_work (entity1);

CREATE INDEX l_release_group_release_group_idx_entity1 ON l_release_group_release_group (entity1);
CREATE INDEX l_release_group_series_idx_entity1 ON l_release_group_series (entity1);
CREATE INDEX l_release_group_url_idx_entity1 ON l_release_group_url (entity1);
CREATE INDEX l_release_group_work_idx_entity1 ON l_release_group_work (entity1);

CREATE INDEX l_series_series_idx_entity1 ON l_series_series (entity1);
CREATE INDEX l_series_url_idx_entity1 ON l_series_url (entity1);
CREATE INDEX l_series_work_idx_entity1 ON l_series_work (entity1);

CREATE INDEX l_url_url_idx_entity1 ON l_url_url (entity1);
CREATE INDEX l_url_work_idx_entity1 ON l_url_work (entity1);

CREATE INDEX l_work_work_idx_entity1 ON l_work_work (entity1);

CREATE UNIQUE INDEX link_type_idx_gid ON link_type (gid);
CREATE UNIQUE INDEX link_attribute_type_idx_gid ON link_attribute_type (gid);

CREATE INDEX link_idx_type_attr ON link (link_type, attribute_count);

CREATE UNIQUE INDEX label_idx_gid ON label (gid);
CREATE INDEX label_idx_name ON label (name);

CREATE INDEX label_idx_area ON label (area);

CREATE UNIQUE INDEX label_idx_null_comment ON label (name) WHERE comment IS NULL;
CREATE UNIQUE INDEX label_idx_uniq_name_comment ON label (name, comment) WHERE comment IS NOT NULL;

CREATE UNIQUE INDEX label_alias_type_idx_gid ON label_alias_type (gid);

CREATE INDEX label_alias_idx_label ON label_alias (label);
CREATE UNIQUE INDEX label_alias_idx_primary ON label_alias (label, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX label_attribute_idx_label ON label_attribute (label);

CREATE UNIQUE INDEX label_attribute_type_idx_gid ON label_attribute_type (gid);

CREATE INDEX label_attribute_type_allowed_value_idx_name ON label_attribute_type_allowed_value (label_attribute_type);
CREATE UNIQUE INDEX label_attribute_type_allowed_value_idx_gid ON label_attribute_type_allowed_value (gid);

CREATE INDEX label_tag_idx_tag ON label_tag (tag);

CREATE INDEX label_tag_raw_idx_tag ON label_tag_raw (tag);
CREATE INDEX label_tag_raw_idx_editor ON label_tag_raw (editor);

CREATE INDEX label_rating_raw_idx_label ON label_rating_raw (label);
CREATE INDEX label_rating_raw_idx_editor ON label_rating_raw (editor);

CREATE UNIQUE INDEX label_type_idx_gid ON label_type (gid);

CREATE UNIQUE INDEX language_idx_iso_code_2b ON language (iso_code_2b);
CREATE UNIQUE INDEX language_idx_iso_code_2t ON language (iso_code_2t);
CREATE UNIQUE INDEX language_idx_iso_code_1 ON language (iso_code_1);
CREATE UNIQUE INDEX language_idx_iso_code_3 ON language (iso_code_3);

CREATE UNIQUE INDEX editor_collection_idx_gid ON editor_collection (gid);
CREATE INDEX editor_collection_idx_name ON editor_collection (name);
CREATE INDEX editor_collection_idx_editor ON editor_collection (editor);

CREATE UNIQUE INDEX editor_collection_type_idx_gid ON editor_collection_type (gid);

CREATE UNIQUE INDEX cdtoc_idx_discid ON cdtoc (discid);
CREATE INDEX cdtoc_idx_freedb_id ON cdtoc (freedb_id);

CREATE INDEX medium_attribute_idx_medium ON medium_attribute (medium);

CREATE UNIQUE INDEX medium_attribute_type_idx_gid ON medium_attribute_type (gid);

CREATE INDEX medium_attribute_type_allowed_value_idx_name ON medium_attribute_type_allowed_value (medium_attribute_type);
CREATE UNIQUE INDEX medium_attribute_type_allowed_value_idx_gid ON medium_attribute_type_allowed_value (gid);

CREATE INDEX medium_cdtoc_idx_medium ON medium_cdtoc (medium);
CREATE INDEX medium_cdtoc_idx_cdtoc ON medium_cdtoc (cdtoc);
CREATE UNIQUE INDEX medium_cdtoc_idx_uniq ON medium_cdtoc (medium, cdtoc);

CREATE UNIQUE INDEX medium_format_idx_gid ON medium_format (gid);

CREATE UNIQUE INDEX place_idx_gid ON place (gid);
CREATE INDEX place_idx_name ON place (name);
CREATE INDEX place_idx_area ON place (area);
CREATE INDEX place_idx_geo ON place USING gist (ll_to_earth(coordinates[0], coordinates[1])) WHERE coordinates IS NOT NULL;

CREATE INDEX place_alias_idx_place ON place_alias (place);
CREATE UNIQUE INDEX place_alias_idx_primary ON place_alias (place, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX place_attribute_idx_place ON place_attribute (place);

CREATE UNIQUE INDEX place_attribute_type_idx_gid ON place_attribute_type (gid);

CREATE INDEX place_attribute_type_allowed_value_idx_name ON place_attribute_type_allowed_value (place_attribute_type);
CREATE UNIQUE INDEX place_attribute_type_allowed_value_idx_gid ON place_attribute_type_allowed_value (gid);

CREATE UNIQUE INDEX place_alias_type_idx_gid ON place_alias_type (gid);

CREATE INDEX place_tag_idx_tag ON place_tag (tag);

CREATE INDEX place_tag_raw_idx_tag ON place_tag_raw (tag);
CREATE INDEX place_tag_raw_idx_editor ON place_tag_raw (editor);

CREATE UNIQUE INDEX place_type_idx_gid ON place_type (gid);

CREATE UNIQUE INDEX recording_idx_gid ON recording (gid);
CREATE INDEX recording_idx_name ON recording (name);
CREATE INDEX recording_idx_artist_credit ON recording (artist_credit);

CREATE UNIQUE INDEX recording_alias_type_idx_gid ON recording_alias_type (gid);

CREATE INDEX recording_alias_idx_recording ON recording_alias (recording);
CREATE UNIQUE INDEX recording_alias_idx_primary ON recording_alias (recording, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX recording_attribute_idx_recording ON recording_attribute (recording);

CREATE UNIQUE INDEX recording_attribute_type_idx_gid ON recording_attribute_type (gid);

CREATE INDEX recording_attribute_type_allowed_value_idx_name ON recording_attribute_type_allowed_value (recording_attribute_type);
CREATE UNIQUE INDEX recording_attribute_type_allowed_value_idx_gid ON recording_attribute_type_allowed_value (gid);

CREATE INDEX recording_tag_idx_tag ON recording_tag (tag);

CREATE INDEX recording_rating_raw_idx_editor ON recording_rating_raw (editor);

CREATE INDEX recording_tag_raw_idx_track ON recording_tag_raw (recording);
CREATE INDEX recording_tag_raw_idx_tag ON recording_tag_raw (tag);
CREATE INDEX recording_tag_raw_idx_editor ON recording_tag_raw (editor);

CREATE UNIQUE INDEX release_idx_gid ON release (gid);
CREATE INDEX release_idx_name ON release (name);
CREATE INDEX release_idx_release_group ON release (release_group);
CREATE INDEX release_idx_artist_credit ON release (artist_credit);

CREATE INDEX release_alias_idx_release ON release_alias (release);
CREATE UNIQUE INDEX release_alias_idx_primary ON release_alias (release, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX release_attribute_idx_release ON release_attribute (release);

CREATE UNIQUE INDEX release_attribute_type_idx_gid ON release_attribute_type (gid);

CREATE INDEX release_attribute_type_allowed_value_idx_name ON release_attribute_type_allowed_value (release_attribute_type);
CREATE UNIQUE INDEX release_attribute_type_allowed_value_idx_gid ON release_attribute_type_allowed_value (gid);

CREATE INDEX release_tag_idx_tag ON release_tag (tag);

CREATE INDEX release_tag_raw_idx_tag ON release_tag_raw (tag);
CREATE INDEX release_tag_raw_idx_editor ON release_tag_raw (editor);

CREATE INDEX release_raw_idx_last_modified ON release_raw (last_modified);
CREATE INDEX release_raw_idx_lookup_count ON release_raw (lookup_count);
CREATE INDEX release_raw_idx_modify_count ON release_raw (modify_count);

CREATE INDEX release_label_idx_release ON release_label (release);
CREATE INDEX release_label_idx_label ON release_label (label);

CREATE UNIQUE INDEX release_packaging_idx_gid ON release_packaging (gid);

CREATE UNIQUE INDEX release_status_idx_gid ON release_status (gid);

CREATE INDEX release_country_idx_country ON release_country (country);

CREATE UNIQUE INDEX release_group_idx_gid ON release_group (gid);
CREATE INDEX release_group_idx_name ON release_group (name);
CREATE INDEX release_group_idx_artist_credit ON release_group (artist_credit);

CREATE UNIQUE INDEX release_group_alias_type_idx_gid ON release_group_alias_type (gid);

CREATE INDEX release_group_alias_idx_release_group ON release_group_alias (release_group);
CREATE UNIQUE INDEX release_group_alias_idx_primary ON release_group_alias (release_group, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX release_group_attribute_idx_release_group ON release_group_attribute (release_group);

CREATE UNIQUE INDEX release_group_attribute_type_idx_gid ON release_group_attribute_type (gid);

CREATE INDEX release_group_attribute_type_allowed_value_idx_name ON release_group_attribute_type_allowed_value (release_group_attribute_type);
CREATE UNIQUE INDEX release_group_attribute_type_allowed_value_idx_gid ON release_group_attribute_type_allowed_value (gid);

CREATE INDEX release_group_tag_idx_tag ON release_group_tag (tag);

CREATE INDEX release_group_rating_raw_idx_release_group ON release_group_rating_raw (release_group);
CREATE INDEX release_group_rating_raw_idx_editor ON release_group_rating_raw (editor);

CREATE INDEX release_group_tag_raw_idx_tag ON release_group_tag_raw (tag);
CREATE INDEX release_group_tag_raw_idx_editor ON release_group_tag_raw (editor);

CREATE UNIQUE INDEX release_group_primary_type_idx_gid ON release_group_primary_type (gid);

CREATE UNIQUE INDEX release_group_secondary_type_idx_gid ON release_group_secondary_type (gid);

CREATE UNIQUE INDEX script_idx_iso_code ON script (iso_code);

CREATE UNIQUE INDEX series_idx_gid ON series (gid);
CREATE INDEX series_idx_name ON series (name);

CREATE UNIQUE INDEX series_type_idx_gid ON series_type (gid);

CREATE UNIQUE INDEX series_ordering_type_idx_gid ON series_ordering_type (gid);

CREATE UNIQUE INDEX series_alias_type_idx_gid ON series_alias_type (gid);

CREATE INDEX series_alias_idx_series ON series_alias (series);
CREATE UNIQUE INDEX series_alias_idx_primary ON series_alias (series, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX series_attribute_idx_series ON series_attribute (series);

CREATE UNIQUE INDEX series_attribute_type_idx_gid ON series_attribute_type (gid);

CREATE INDEX series_attribute_type_allowed_value_idx_name ON series_attribute_type_allowed_value (series_attribute_type);
CREATE UNIQUE INDEX series_attribute_type_allowed_value_idx_gid ON series_attribute_type_allowed_value (gid);

CREATE INDEX series_tag_idx_tag ON series_tag (tag);

CREATE INDEX series_tag_raw_idx_series ON series_tag_raw (series);
CREATE INDEX series_tag_raw_idx_tag ON series_tag_raw (tag);
CREATE INDEX series_tag_raw_idx_editor ON series_tag_raw (editor);

CREATE UNIQUE INDEX tag_idx_name ON tag (name);

CREATE UNIQUE INDEX track_idx_gid ON track (gid);

CREATE INDEX track_idx_recording ON track (recording);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_artist_credit ON track (artist_credit);

CREATE INDEX track_raw_idx_release ON track_raw (release);

CREATE INDEX medium_idx_track_count ON medium (track_count);
CREATE INDEX medium_index_idx ON medium_index USING gist (toc);

CREATE UNIQUE INDEX url_idx_gid ON url (gid);
CREATE UNIQUE INDEX url_idx_url ON url (url);

CREATE INDEX vote_idx_edit ON vote (edit);
CREATE INDEX vote_idx_editor_vote_time ON vote (editor, vote_time);
CREATE INDEX vote_idx_editor_edit ON vote (editor, edit) WHERE superseded = FALSE;
CREATE INDEX vote_idx_vote_time ON vote USING BRIN (vote_time);

CREATE UNIQUE INDEX work_idx_gid ON work (gid);
CREATE INDEX work_idx_name ON work (name);

CREATE UNIQUE INDEX work_alias_type_idx_gid ON work_alias_type (gid);

CREATE INDEX work_alias_idx_work ON work_alias (work);
CREATE UNIQUE INDEX work_alias_idx_primary ON work_alias (work, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE INDEX work_attribute_idx_work ON work_attribute (work);

CREATE UNIQUE INDEX work_attribute_type_idx_gid ON work_attribute_type (gid);

CREATE INDEX work_attribute_type_allowed_value_idx_name ON work_attribute_type_allowed_value (work_attribute_type);
CREATE UNIQUE INDEX work_attribute_type_allowed_value_idx_gid ON work_attribute_type_allowed_value (gid);

CREATE INDEX work_tag_idx_tag ON work_tag (tag);

CREATE INDEX work_tag_raw_idx_tag ON work_tag_raw (tag);

CREATE UNIQUE INDEX work_type_idx_gid ON work_type (gid);

-- lowercase indexes for javascript autocomplete
CREATE INDEX artist_idx_lower_name ON artist (lower(name));
CREATE INDEX label_idx_lower_name ON label (lower(name));

-- musicbrainz_collate indexes for unicode sorting
CREATE INDEX release_idx_musicbrainz_collate ON release (musicbrainz_collate(name));
CREATE INDEX release_group_idx_musicbrainz_collate ON release_group (musicbrainz_collate(name));
CREATE INDEX artist_idx_musicbrainz_collate ON artist (musicbrainz_collate(name));
CREATE INDEX artist_credit_idx_musicbrainz_collate ON artist_credit (musicbrainz_collate(name));
CREATE INDEX artist_credit_name_idx_musicbrainz_collate ON artist_credit_name (musicbrainz_collate(name));
CREATE INDEX label_idx_musicbrainz_collate ON label (musicbrainz_collate(name));
CREATE INDEX track_idx_musicbrainz_collate ON track (musicbrainz_collate(name));
CREATE INDEX recording_idx_musicbrainz_collate ON recording (musicbrainz_collate(name));
CREATE INDEX work_idx_musicbrainz_collate ON work (musicbrainz_collate(name));

CREATE INDEX alternative_release_idx_release ON alternative_release (release);
CREATE INDEX alternative_release_idx_name ON alternative_release (name);
CREATE INDEX alternative_release_idx_artist_credit ON alternative_release (artist_credit);
CREATE INDEX alternative_release_idx_language_script ON alternative_release (language, script);
CREATE UNIQUE INDEX alternative_release_idx_gid ON alternative_release (gid);
CREATE INDEX alternative_medium_idx_alternative_release ON alternative_medium (alternative_release);
CREATE INDEX alternative_track_idx_name ON alternative_track (name);
CREATE INDEX alternative_track_idx_artist_credit ON alternative_track (artist_credit);

CREATE INDEX area_gid_redirect_idx_new_id ON area_gid_redirect (new_id);
CREATE INDEX artist_gid_redirect_idx_new_id ON artist_gid_redirect (new_id);
CREATE INDEX event_gid_redirect_idx_new_id ON event_gid_redirect (new_id);
CREATE INDEX instrument_gid_redirect_idx_new_id ON instrument_gid_redirect (new_id);
CREATE INDEX label_gid_redirect_idx_new_id ON label_gid_redirect (new_id);
CREATE INDEX place_gid_redirect_idx_new_id ON place_gid_redirect (new_id);
CREATE INDEX recording_gid_redirect_idx_new_id ON recording_gid_redirect (new_id);
CREATE INDEX release_gid_redirect_idx_new_id ON release_gid_redirect (new_id);
CREATE INDEX release_group_gid_redirect_idx_new_id ON release_group_gid_redirect (new_id);
CREATE INDEX series_gid_redirect_idx_new_id ON series_gid_redirect (new_id);
CREATE INDEX track_gid_redirect_idx_new_id ON track_gid_redirect (new_id);
CREATE INDEX url_gid_redirect_idx_new_id ON url_gid_redirect (new_id);
CREATE INDEX work_gid_redirect_idx_new_id ON work_gid_redirect (new_id);

COMMIT;

-- vi: set ts=4 sw=4 et :
