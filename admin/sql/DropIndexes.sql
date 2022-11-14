-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

DROP INDEX alternative_medium_idx_alternative_release;
DROP INDEX alternative_release_idx_artist_credit;
DROP INDEX alternative_release_idx_gid;
DROP INDEX alternative_release_idx_language_script;
DROP INDEX alternative_release_idx_name;
DROP INDEX alternative_release_idx_release;
DROP INDEX alternative_track_idx_artist_credit;
DROP INDEX alternative_track_idx_name;
DROP INDEX application_idx_oauth_id;
DROP INDEX application_idx_owner;
DROP INDEX area_alias_idx_area;
DROP INDEX area_alias_idx_primary;
DROP INDEX area_alias_type_idx_gid;
DROP INDEX area_attribute_idx_area;
DROP INDEX area_attribute_type_allowed_value_idx_gid;
DROP INDEX area_attribute_type_allowed_value_idx_name;
DROP INDEX area_attribute_type_idx_gid;
DROP INDEX area_containment_idx_parent;
DROP INDEX area_gid_redirect_idx_new_id;
DROP INDEX area_idx_gid;
DROP INDEX area_idx_name;
DROP INDEX area_tag_idx_tag;
DROP INDEX area_tag_raw_idx_area;
DROP INDEX area_tag_raw_idx_editor;
DROP INDEX area_tag_raw_idx_tag;
DROP INDEX area_type_idx_gid;
DROP INDEX artist_alias_idx_artist;
DROP INDEX artist_alias_idx_lower_unaccent_name;
DROP INDEX artist_alias_idx_primary;
DROP INDEX artist_alias_type_idx_gid;
DROP INDEX artist_attribute_idx_artist;
DROP INDEX artist_attribute_type_allowed_value_idx_gid;
DROP INDEX artist_attribute_type_allowed_value_idx_name;
DROP INDEX artist_attribute_type_idx_gid;
DROP INDEX artist_credit_gid_redirect_idx_new_id;
DROP INDEX artist_credit_idx_gid;
DROP INDEX artist_credit_idx_musicbrainz_collate;
DROP INDEX artist_credit_name_idx_artist;
DROP INDEX artist_credit_name_idx_musicbrainz_collate;
DROP INDEX artist_gid_redirect_idx_new_id;
DROP INDEX artist_idx_area;
DROP INDEX artist_idx_begin_area;
DROP INDEX artist_idx_end_area;
DROP INDEX artist_idx_gid;
DROP INDEX artist_idx_lower_unaccent_name_comment;
DROP INDEX artist_idx_musicbrainz_collate;
DROP INDEX artist_idx_name;
DROP INDEX artist_idx_null_comment;
DROP INDEX artist_idx_sort_name;
DROP INDEX artist_idx_uniq_name_comment;
DROP INDEX artist_rating_raw_idx_editor;
DROP INDEX artist_release_group_nonva_idx_sort;
DROP INDEX artist_release_group_nonva_idx_uniq;
DROP INDEX artist_release_group_pending_update_idx_release_group;
DROP INDEX artist_release_group_va_idx_sort;
DROP INDEX artist_release_group_va_idx_uniq;
DROP INDEX artist_release_nonva_idx_sort;
DROP INDEX artist_release_nonva_idx_uniq;
DROP INDEX artist_release_pending_update_idx_release;
DROP INDEX artist_release_va_idx_sort;
DROP INDEX artist_release_va_idx_uniq;
DROP INDEX artist_tag_idx_tag;
DROP INDEX artist_tag_raw_idx_editor;
DROP INDEX artist_tag_raw_idx_tag;
DROP INDEX artist_type_idx_gid;
DROP INDEX cdtoc_idx_discid;
DROP INDEX cdtoc_idx_freedb_id;
DROP INDEX cdtoc_raw_discid;
DROP INDEX cdtoc_raw_toc;
DROP INDEX edit_area_idx;
DROP INDEX edit_artist_idx;
DROP INDEX edit_artist_idx_status;
DROP INDEX edit_data_idx_link_type;
DROP INDEX edit_event_idx;
DROP INDEX edit_genre_idx;
DROP INDEX edit_idx_close_time;
DROP INDEX edit_idx_editor_id_desc;
DROP INDEX edit_idx_editor_open_time;
DROP INDEX edit_idx_expire_time;
DROP INDEX edit_idx_open_time;
DROP INDEX edit_idx_status_id;
DROP INDEX edit_idx_type_id;
DROP INDEX edit_instrument_idx;
DROP INDEX edit_label_idx;
DROP INDEX edit_label_idx_status;
DROP INDEX edit_mood_idx;
DROP INDEX edit_note_idx_edit;
DROP INDEX edit_note_idx_editor;
DROP INDEX edit_note_recipient_idx_recipient;
DROP INDEX edit_place_idx;
DROP INDEX edit_recording_idx;
DROP INDEX edit_release_group_idx;
DROP INDEX edit_release_idx;
DROP INDEX edit_series_idx;
DROP INDEX edit_url_idx;
DROP INDEX edit_work_idx;
DROP INDEX editor_collection_gid_redirect_idx_new_id;
DROP INDEX editor_collection_idx_editor;
DROP INDEX editor_collection_idx_gid;
DROP INDEX editor_collection_type_idx_gid;
DROP INDEX editor_idx_name;
DROP INDEX editor_language_idx_language;
DROP INDEX editor_oauth_token_idx_access_token;
DROP INDEX editor_oauth_token_idx_editor;
DROP INDEX editor_oauth_token_idx_refresh_token;
DROP INDEX editor_preference_idx_editor_name;
DROP INDEX editor_subscribe_artist_idx_artist;
DROP INDEX editor_subscribe_artist_idx_uniq;
DROP INDEX editor_subscribe_collection_idx_collection;
DROP INDEX editor_subscribe_collection_idx_uniq;
DROP INDEX editor_subscribe_editor_idx_uniq;
DROP INDEX editor_subscribe_label_idx_label;
DROP INDEX editor_subscribe_label_idx_uniq;
DROP INDEX editor_subscribe_series_idx_series;
DROP INDEX editor_subscribe_series_idx_uniq;
DROP INDEX event_alias_idx_event;
DROP INDEX event_alias_idx_primary;
DROP INDEX event_alias_type_idx_gid;
DROP INDEX event_attribute_idx_event;
DROP INDEX event_attribute_type_allowed_value_idx_gid;
DROP INDEX event_attribute_type_allowed_value_idx_name;
DROP INDEX event_attribute_type_idx_gid;
DROP INDEX event_gid_redirect_idx_new_id;
DROP INDEX event_idx_gid;
DROP INDEX event_idx_name;
DROP INDEX event_rating_raw_idx_editor;
DROP INDEX event_tag_idx_tag;
DROP INDEX event_tag_raw_idx_editor;
DROP INDEX event_tag_raw_idx_tag;
DROP INDEX event_type_idx_gid;
DROP INDEX gender_idx_gid;
DROP INDEX genre_alias_idx_genre;
DROP INDEX genre_alias_idx_primary;
DROP INDEX genre_alias_type_idx_gid;
DROP INDEX genre_idx_gid;
DROP INDEX genre_idx_name;
DROP INDEX instrument_alias_idx_instrument;
DROP INDEX instrument_alias_idx_primary;
DROP INDEX instrument_alias_type_idx_gid;
DROP INDEX instrument_attribute_idx_instrument;
DROP INDEX instrument_attribute_type_allowed_value_idx_gid;
DROP INDEX instrument_attribute_type_allowed_value_idx_name;
DROP INDEX instrument_attribute_type_idx_gid;
DROP INDEX instrument_gid_redirect_idx_new_id;
DROP INDEX instrument_idx_gid;
DROP INDEX instrument_idx_name;
DROP INDEX instrument_tag_idx_tag;
DROP INDEX instrument_tag_raw_idx_editor;
DROP INDEX instrument_tag_raw_idx_instrument;
DROP INDEX instrument_tag_raw_idx_tag;
DROP INDEX instrument_type_idx_gid;
DROP INDEX iso_3166_1_idx_area;
DROP INDEX iso_3166_2_idx_area;
DROP INDEX iso_3166_3_idx_area;
DROP INDEX isrc_idx_isrc;
DROP INDEX isrc_idx_isrc_recording;
DROP INDEX isrc_idx_recording;
DROP INDEX iswc_idx_iswc;
DROP INDEX iswc_idx_work;
DROP INDEX l_area_area_idx_entity1;
DROP INDEX l_area_area_idx_uniq;
DROP INDEX l_area_artist_idx_entity1;
DROP INDEX l_area_artist_idx_uniq;
DROP INDEX l_area_event_idx_entity1;
DROP INDEX l_area_event_idx_uniq;
DROP INDEX l_area_genre_idx_entity1;
DROP INDEX l_area_genre_idx_uniq;
DROP INDEX l_area_instrument_idx_entity1;
DROP INDEX l_area_instrument_idx_uniq;
DROP INDEX l_area_label_idx_entity1;
DROP INDEX l_area_label_idx_uniq;
DROP INDEX l_area_mood_idx_entity1;
DROP INDEX l_area_mood_idx_uniq;
DROP INDEX l_area_place_idx_entity1;
DROP INDEX l_area_place_idx_uniq;
DROP INDEX l_area_recording_idx_entity1;
DROP INDEX l_area_recording_idx_uniq;
DROP INDEX l_area_release_group_idx_entity1;
DROP INDEX l_area_release_group_idx_uniq;
DROP INDEX l_area_release_idx_entity1;
DROP INDEX l_area_release_idx_uniq;
DROP INDEX l_area_series_idx_entity1;
DROP INDEX l_area_series_idx_uniq;
DROP INDEX l_area_url_idx_entity1;
DROP INDEX l_area_url_idx_uniq;
DROP INDEX l_area_work_idx_entity1;
DROP INDEX l_area_work_idx_uniq;
DROP INDEX l_artist_artist_idx_entity1;
DROP INDEX l_artist_artist_idx_uniq;
DROP INDEX l_artist_event_idx_entity1;
DROP INDEX l_artist_event_idx_uniq;
DROP INDEX l_artist_genre_idx_entity1;
DROP INDEX l_artist_genre_idx_uniq;
DROP INDEX l_artist_instrument_idx_entity1;
DROP INDEX l_artist_instrument_idx_uniq;
DROP INDEX l_artist_label_idx_entity1;
DROP INDEX l_artist_label_idx_uniq;
DROP INDEX l_artist_mood_idx_entity1;
DROP INDEX l_artist_mood_idx_uniq;
DROP INDEX l_artist_place_idx_entity1;
DROP INDEX l_artist_place_idx_uniq;
DROP INDEX l_artist_recording_idx_entity1;
DROP INDEX l_artist_recording_idx_uniq;
DROP INDEX l_artist_release_group_idx_entity1;
DROP INDEX l_artist_release_group_idx_uniq;
DROP INDEX l_artist_release_idx_entity1;
DROP INDEX l_artist_release_idx_uniq;
DROP INDEX l_artist_series_idx_entity1;
DROP INDEX l_artist_series_idx_uniq;
DROP INDEX l_artist_url_idx_entity1;
DROP INDEX l_artist_url_idx_uniq;
DROP INDEX l_artist_work_idx_entity1;
DROP INDEX l_artist_work_idx_uniq;
DROP INDEX l_event_event_idx_entity1;
DROP INDEX l_event_event_idx_uniq;
DROP INDEX l_event_genre_idx_entity1;
DROP INDEX l_event_genre_idx_uniq;
DROP INDEX l_event_instrument_idx_entity1;
DROP INDEX l_event_instrument_idx_uniq;
DROP INDEX l_event_label_idx_entity1;
DROP INDEX l_event_label_idx_uniq;
DROP INDEX l_event_mood_idx_entity1;
DROP INDEX l_event_mood_idx_uniq;
DROP INDEX l_event_place_idx_entity1;
DROP INDEX l_event_place_idx_uniq;
DROP INDEX l_event_recording_idx_entity1;
DROP INDEX l_event_recording_idx_uniq;
DROP INDEX l_event_release_group_idx_entity1;
DROP INDEX l_event_release_group_idx_uniq;
DROP INDEX l_event_release_idx_entity1;
DROP INDEX l_event_release_idx_uniq;
DROP INDEX l_event_series_idx_entity1;
DROP INDEX l_event_series_idx_uniq;
DROP INDEX l_event_url_idx_entity1;
DROP INDEX l_event_url_idx_uniq;
DROP INDEX l_event_work_idx_entity1;
DROP INDEX l_event_work_idx_uniq;
DROP INDEX l_genre_genre_idx_entity1;
DROP INDEX l_genre_genre_idx_uniq;
DROP INDEX l_genre_instrument_idx_entity1;
DROP INDEX l_genre_instrument_idx_uniq;
DROP INDEX l_genre_label_idx_entity1;
DROP INDEX l_genre_label_idx_uniq;
DROP INDEX l_genre_mood_idx_entity1;
DROP INDEX l_genre_mood_idx_uniq;
DROP INDEX l_genre_place_idx_entity1;
DROP INDEX l_genre_place_idx_uniq;
DROP INDEX l_genre_recording_idx_entity1;
DROP INDEX l_genre_recording_idx_uniq;
DROP INDEX l_genre_release_group_idx_entity1;
DROP INDEX l_genre_release_group_idx_uniq;
DROP INDEX l_genre_release_idx_entity1;
DROP INDEX l_genre_release_idx_uniq;
DROP INDEX l_genre_series_idx_entity1;
DROP INDEX l_genre_series_idx_uniq;
DROP INDEX l_genre_url_idx_entity1;
DROP INDEX l_genre_url_idx_uniq;
DROP INDEX l_genre_work_idx_entity1;
DROP INDEX l_genre_work_idx_uniq;
DROP INDEX l_instrument_instrument_idx_entity1;
DROP INDEX l_instrument_instrument_idx_uniq;
DROP INDEX l_instrument_label_idx_entity1;
DROP INDEX l_instrument_label_idx_uniq;
DROP INDEX l_instrument_mood_idx_entity1;
DROP INDEX l_instrument_mood_idx_uniq;
DROP INDEX l_instrument_place_idx_entity1;
DROP INDEX l_instrument_place_idx_uniq;
DROP INDEX l_instrument_recording_idx_entity1;
DROP INDEX l_instrument_recording_idx_uniq;
DROP INDEX l_instrument_release_group_idx_entity1;
DROP INDEX l_instrument_release_group_idx_uniq;
DROP INDEX l_instrument_release_idx_entity1;
DROP INDEX l_instrument_release_idx_uniq;
DROP INDEX l_instrument_series_idx_entity1;
DROP INDEX l_instrument_series_idx_uniq;
DROP INDEX l_instrument_url_idx_entity1;
DROP INDEX l_instrument_url_idx_uniq;
DROP INDEX l_instrument_work_idx_entity1;
DROP INDEX l_instrument_work_idx_uniq;
DROP INDEX l_label_label_idx_entity1;
DROP INDEX l_label_label_idx_uniq;
DROP INDEX l_label_mood_idx_entity1;
DROP INDEX l_label_mood_idx_uniq;
DROP INDEX l_label_place_idx_entity1;
DROP INDEX l_label_place_idx_uniq;
DROP INDEX l_label_recording_idx_entity1;
DROP INDEX l_label_recording_idx_uniq;
DROP INDEX l_label_release_group_idx_entity1;
DROP INDEX l_label_release_group_idx_uniq;
DROP INDEX l_label_release_idx_entity1;
DROP INDEX l_label_release_idx_uniq;
DROP INDEX l_label_series_idx_entity1;
DROP INDEX l_label_series_idx_uniq;
DROP INDEX l_label_url_idx_entity1;
DROP INDEX l_label_url_idx_uniq;
DROP INDEX l_label_work_idx_entity1;
DROP INDEX l_label_work_idx_uniq;
DROP INDEX l_mood_mood_idx_entity1;
DROP INDEX l_mood_mood_idx_uniq;
DROP INDEX l_mood_place_idx_entity1;
DROP INDEX l_mood_place_idx_uniq;
DROP INDEX l_mood_recording_idx_entity1;
DROP INDEX l_mood_recording_idx_uniq;
DROP INDEX l_mood_release_group_idx_entity1;
DROP INDEX l_mood_release_group_idx_uniq;
DROP INDEX l_mood_release_idx_entity1;
DROP INDEX l_mood_release_idx_uniq;
DROP INDEX l_mood_series_idx_entity1;
DROP INDEX l_mood_series_idx_uniq;
DROP INDEX l_mood_url_idx_entity1;
DROP INDEX l_mood_url_idx_uniq;
DROP INDEX l_mood_work_idx_entity1;
DROP INDEX l_mood_work_idx_uniq;
DROP INDEX l_place_place_idx_entity1;
DROP INDEX l_place_place_idx_uniq;
DROP INDEX l_place_recording_idx_entity1;
DROP INDEX l_place_recording_idx_uniq;
DROP INDEX l_place_release_group_idx_entity1;
DROP INDEX l_place_release_group_idx_uniq;
DROP INDEX l_place_release_idx_entity1;
DROP INDEX l_place_release_idx_uniq;
DROP INDEX l_place_series_idx_entity1;
DROP INDEX l_place_series_idx_uniq;
DROP INDEX l_place_url_idx_entity1;
DROP INDEX l_place_url_idx_uniq;
DROP INDEX l_place_work_idx_entity1;
DROP INDEX l_place_work_idx_uniq;
DROP INDEX l_recording_recording_idx_entity1;
DROP INDEX l_recording_recording_idx_uniq;
DROP INDEX l_recording_release_group_idx_entity1;
DROP INDEX l_recording_release_group_idx_uniq;
DROP INDEX l_recording_release_idx_entity1;
DROP INDEX l_recording_release_idx_uniq;
DROP INDEX l_recording_series_idx_entity1;
DROP INDEX l_recording_series_idx_uniq;
DROP INDEX l_recording_url_idx_entity1;
DROP INDEX l_recording_url_idx_uniq;
DROP INDEX l_recording_work_idx_entity1;
DROP INDEX l_recording_work_idx_uniq;
DROP INDEX l_release_group_release_group_idx_entity1;
DROP INDEX l_release_group_release_group_idx_uniq;
DROP INDEX l_release_group_series_idx_entity1;
DROP INDEX l_release_group_series_idx_uniq;
DROP INDEX l_release_group_url_idx_entity1;
DROP INDEX l_release_group_url_idx_uniq;
DROP INDEX l_release_group_work_idx_entity1;
DROP INDEX l_release_group_work_idx_uniq;
DROP INDEX l_release_release_group_idx_entity1;
DROP INDEX l_release_release_group_idx_uniq;
DROP INDEX l_release_release_idx_entity1;
DROP INDEX l_release_release_idx_uniq;
DROP INDEX l_release_series_idx_entity1;
DROP INDEX l_release_series_idx_uniq;
DROP INDEX l_release_url_idx_entity1;
DROP INDEX l_release_url_idx_uniq;
DROP INDEX l_release_work_idx_entity1;
DROP INDEX l_release_work_idx_uniq;
DROP INDEX l_series_series_idx_entity1;
DROP INDEX l_series_series_idx_uniq;
DROP INDEX l_series_url_idx_entity1;
DROP INDEX l_series_url_idx_uniq;
DROP INDEX l_series_work_idx_entity1;
DROP INDEX l_series_work_idx_uniq;
DROP INDEX l_url_url_idx_entity1;
DROP INDEX l_url_url_idx_uniq;
DROP INDEX l_url_work_idx_entity1;
DROP INDEX l_url_work_idx_uniq;
DROP INDEX l_work_work_idx_entity1;
DROP INDEX l_work_work_idx_uniq;
DROP INDEX label_alias_idx_label;
DROP INDEX label_alias_idx_lower_unaccent_name;
DROP INDEX label_alias_idx_primary;
DROP INDEX label_alias_type_idx_gid;
DROP INDEX label_attribute_idx_label;
DROP INDEX label_attribute_type_allowed_value_idx_gid;
DROP INDEX label_attribute_type_allowed_value_idx_name;
DROP INDEX label_attribute_type_idx_gid;
DROP INDEX label_gid_redirect_idx_new_id;
DROP INDEX label_idx_area;
DROP INDEX label_idx_gid;
DROP INDEX label_idx_lower_unaccent_name_comment;
DROP INDEX label_idx_musicbrainz_collate;
DROP INDEX label_idx_name;
DROP INDEX label_idx_null_comment;
DROP INDEX label_idx_uniq_name_comment;
DROP INDEX label_rating_raw_idx_editor;
DROP INDEX label_tag_idx_tag;
DROP INDEX label_tag_raw_idx_editor;
DROP INDEX label_tag_raw_idx_tag;
DROP INDEX label_type_idx_gid;
DROP INDEX language_idx_iso_code_1;
DROP INDEX language_idx_iso_code_2b;
DROP INDEX language_idx_iso_code_2t;
DROP INDEX language_idx_iso_code_3;
DROP INDEX link_attribute_type_idx_gid;
DROP INDEX link_idx_type_attr;
DROP INDEX link_type_idx_gid;
DROP INDEX medium_attribute_idx_medium;
DROP INDEX medium_attribute_type_allowed_value_idx_gid;
DROP INDEX medium_attribute_type_allowed_value_idx_name;
DROP INDEX medium_attribute_type_idx_gid;
DROP INDEX medium_cdtoc_idx_cdtoc;
DROP INDEX medium_cdtoc_idx_medium;
DROP INDEX medium_cdtoc_idx_uniq;
DROP INDEX medium_format_idx_gid;
DROP INDEX medium_idx_track_count;
DROP INDEX medium_index_idx;
DROP INDEX mood_alias_idx_mood;
DROP INDEX mood_alias_idx_primary;
DROP INDEX mood_alias_type_idx_gid;
DROP INDEX mood_idx_gid;
DROP INDEX mood_idx_name;
DROP INDEX old_editor_name_idx_name;
DROP INDEX place_alias_idx_lower_unaccent_name;
DROP INDEX place_alias_idx_place;
DROP INDEX place_alias_idx_primary;
DROP INDEX place_alias_type_idx_gid;
DROP INDEX place_attribute_idx_place;
DROP INDEX place_attribute_type_allowed_value_idx_gid;
DROP INDEX place_attribute_type_allowed_value_idx_name;
DROP INDEX place_attribute_type_idx_gid;
DROP INDEX place_gid_redirect_idx_new_id;
DROP INDEX place_idx_area;
DROP INDEX place_idx_geo;
DROP INDEX place_idx_gid;
DROP INDEX place_idx_lower_unaccent_name_comment;
DROP INDEX place_idx_name;
DROP INDEX place_rating_raw_idx_editor;
DROP INDEX place_tag_idx_tag;
DROP INDEX place_tag_raw_idx_editor;
DROP INDEX place_tag_raw_idx_tag;
DROP INDEX place_type_idx_gid;
DROP INDEX recording_alias_idx_primary;
DROP INDEX recording_alias_idx_recording;
DROP INDEX recording_alias_type_idx_gid;
DROP INDEX recording_attribute_idx_recording;
DROP INDEX recording_attribute_type_allowed_value_idx_gid;
DROP INDEX recording_attribute_type_allowed_value_idx_name;
DROP INDEX recording_attribute_type_idx_gid;
DROP INDEX recording_gid_redirect_idx_new_id;
DROP INDEX recording_idx_artist_credit;
DROP INDEX recording_idx_gid;
DROP INDEX recording_idx_musicbrainz_collate;
DROP INDEX recording_idx_name;
DROP INDEX recording_rating_raw_idx_editor;
DROP INDEX recording_tag_idx_tag;
DROP INDEX recording_tag_raw_idx_editor;
DROP INDEX recording_tag_raw_idx_tag;
DROP INDEX recording_tag_raw_idx_track;
DROP INDEX release_alias_idx_primary;
DROP INDEX release_alias_idx_release;
DROP INDEX release_attribute_idx_release;
DROP INDEX release_attribute_type_allowed_value_idx_gid;
DROP INDEX release_attribute_type_allowed_value_idx_name;
DROP INDEX release_attribute_type_idx_gid;
DROP INDEX release_country_idx_country;
DROP INDEX release_gid_redirect_idx_new_id;
DROP INDEX release_group_alias_idx_primary;
DROP INDEX release_group_alias_idx_release_group;
DROP INDEX release_group_alias_type_idx_gid;
DROP INDEX release_group_attribute_idx_release_group;
DROP INDEX release_group_attribute_type_allowed_value_idx_gid;
DROP INDEX release_group_attribute_type_allowed_value_idx_name;
DROP INDEX release_group_attribute_type_idx_gid;
DROP INDEX release_group_gid_redirect_idx_new_id;
DROP INDEX release_group_idx_artist_credit;
DROP INDEX release_group_idx_gid;
DROP INDEX release_group_idx_musicbrainz_collate;
DROP INDEX release_group_idx_name;
DROP INDEX release_group_primary_type_idx_gid;
DROP INDEX release_group_rating_raw_idx_editor;
DROP INDEX release_group_secondary_type_idx_gid;
DROP INDEX release_group_tag_idx_tag;
DROP INDEX release_group_tag_raw_idx_editor;
DROP INDEX release_group_tag_raw_idx_tag;
DROP INDEX release_idx_artist_credit;
DROP INDEX release_idx_gid;
DROP INDEX release_idx_musicbrainz_collate;
DROP INDEX release_idx_name;
DROP INDEX release_idx_release_group;
DROP INDEX release_label_idx_label;
DROP INDEX release_label_idx_release;
DROP INDEX release_packaging_idx_gid;
DROP INDEX release_status_idx_gid;
DROP INDEX release_tag_idx_tag;
DROP INDEX release_tag_raw_idx_editor;
DROP INDEX release_tag_raw_idx_tag;
DROP INDEX script_idx_iso_code;
DROP INDEX series_alias_idx_lower_unaccent_name;
DROP INDEX series_alias_idx_primary;
DROP INDEX series_alias_idx_series;
DROP INDEX series_alias_type_idx_gid;
DROP INDEX series_attribute_idx_series;
DROP INDEX series_attribute_type_allowed_value_idx_gid;
DROP INDEX series_attribute_type_allowed_value_idx_name;
DROP INDEX series_attribute_type_idx_gid;
DROP INDEX series_gid_redirect_idx_new_id;
DROP INDEX series_idx_gid;
DROP INDEX series_idx_lower_unaccent_name_comment;
DROP INDEX series_idx_name;
DROP INDEX series_ordering_type_idx_gid;
DROP INDEX series_tag_idx_tag;
DROP INDEX series_tag_raw_idx_editor;
DROP INDEX series_tag_raw_idx_series;
DROP INDEX series_tag_raw_idx_tag;
DROP INDEX series_type_idx_gid;
DROP INDEX tag_idx_name;
DROP INDEX track_gid_redirect_idx_new_id;
DROP INDEX track_idx_artist_credit;
DROP INDEX track_idx_gid;
DROP INDEX track_idx_recording;
DROP INDEX track_raw_idx_release;
DROP INDEX unreferenced_row_log_idx_inserted;
DROP INDEX url_gid_redirect_idx_new_id;
DROP INDEX url_idx_gid;
DROP INDEX url_idx_url;
DROP INDEX vote_idx_edit;
DROP INDEX vote_idx_editor_edit;
DROP INDEX vote_idx_editor_vote_time;
DROP INDEX work_alias_idx_primary;
DROP INDEX work_alias_idx_work;
DROP INDEX work_alias_type_idx_gid;
DROP INDEX work_attribute_idx_work;
DROP INDEX work_attribute_type_allowed_value_idx_gid;
DROP INDEX work_attribute_type_allowed_value_idx_name;
DROP INDEX work_attribute_type_idx_gid;
DROP INDEX work_gid_redirect_idx_new_id;
DROP INDEX work_idx_gid;
DROP INDEX work_idx_musicbrainz_collate;
DROP INDEX work_idx_name;
DROP INDEX work_tag_idx_tag;
DROP INDEX work_tag_raw_idx_tag;
DROP INDEX work_type_idx_gid;
