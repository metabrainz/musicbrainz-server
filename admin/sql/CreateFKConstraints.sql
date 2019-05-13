-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

ALTER TABLE alternative_medium
   ADD CONSTRAINT alternative_medium_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id);

ALTER TABLE alternative_medium
   ADD CONSTRAINT alternative_medium_fk_alternative_release
   FOREIGN KEY (alternative_release)
   REFERENCES alternative_release(id);

ALTER TABLE alternative_medium_track
   ADD CONSTRAINT alternative_medium_track_fk_alternative_medium
   FOREIGN KEY (alternative_medium)
   REFERENCES alternative_medium(id);

ALTER TABLE alternative_medium_track
   ADD CONSTRAINT alternative_medium_track_fk_track
   FOREIGN KEY (track)
   REFERENCES track(id);

ALTER TABLE alternative_medium_track
   ADD CONSTRAINT alternative_medium_track_fk_alternative_track
   FOREIGN KEY (alternative_track)
   REFERENCES alternative_track(id);

ALTER TABLE alternative_release
   ADD CONSTRAINT alternative_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE alternative_release
   ADD CONSTRAINT alternative_release_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE alternative_release
   ADD CONSTRAINT alternative_release_fk_type
   FOREIGN KEY (type)
   REFERENCES alternative_release_type(id);

ALTER TABLE alternative_release
   ADD CONSTRAINT alternative_release_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE alternative_release
   ADD CONSTRAINT alternative_release_fk_script
   FOREIGN KEY (script)
   REFERENCES script(id);

ALTER TABLE alternative_release_type
   ADD CONSTRAINT alternative_release_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES alternative_release_type(id);

ALTER TABLE alternative_track
   ADD CONSTRAINT alternative_track_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE annotation
   ADD CONSTRAINT annotation_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE application
   ADD CONSTRAINT application_fk_owner
   FOREIGN KEY (owner)
   REFERENCES editor(id);

ALTER TABLE area
   ADD CONSTRAINT area_fk_type
   FOREIGN KEY (type)
   REFERENCES area_type(id);

ALTER TABLE area_alias
   ADD CONSTRAINT area_alias_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_alias
   ADD CONSTRAINT area_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES area_alias_type(id);

ALTER TABLE area_alias_type
   ADD CONSTRAINT area_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_alias_type(id);

ALTER TABLE area_annotation
   ADD CONSTRAINT area_annotation_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_annotation
   ADD CONSTRAINT area_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area_attribute_type
   FOREIGN KEY (area_attribute_type)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute
   ADD CONSTRAINT area_attribute_fk_area_attribute_type_allowed_value
   FOREIGN KEY (area_attribute_type_allowed_value)
   REFERENCES area_attribute_type_allowed_value(id);

ALTER TABLE area_attribute_type
   ADD CONSTRAINT area_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute_type_allowed_value
   ADD CONSTRAINT area_attribute_type_allowed_value_fk_area_attribute_type
   FOREIGN KEY (area_attribute_type)
   REFERENCES area_attribute_type(id);

ALTER TABLE area_attribute_type_allowed_value
   ADD CONSTRAINT area_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_attribute_type_allowed_value(id);

ALTER TABLE area_gid_redirect
   ADD CONSTRAINT area_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES area(id);

ALTER TABLE area_tag
   ADD CONSTRAINT area_tag_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_tag
   ADD CONSTRAINT area_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE area_tag_raw
   ADD CONSTRAINT area_tag_raw_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_tag_raw
   ADD CONSTRAINT area_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE area_tag_raw
   ADD CONSTRAINT area_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE area_type
   ADD CONSTRAINT area_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_type(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_type
   FOREIGN KEY (type)
   REFERENCES artist_type(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_gender
   FOREIGN KEY (gender)
   REFERENCES gender(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_begin_area
   FOREIGN KEY (begin_area)
   REFERENCES area(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_end_area
   FOREIGN KEY (end_area)
   REFERENCES area(id);

ALTER TABLE artist_alias
   ADD CONSTRAINT artist_alias_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_alias
   ADD CONSTRAINT artist_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES artist_alias_type(id);

ALTER TABLE artist_alias_type
   ADD CONSTRAINT artist_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_alias_type(id);

ALTER TABLE artist_annotation
   ADD CONSTRAINT artist_annotation_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_annotation
   ADD CONSTRAINT artist_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist_attribute_type
   FOREIGN KEY (artist_attribute_type)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute
   ADD CONSTRAINT artist_attribute_fk_artist_attribute_type_allowed_value
   FOREIGN KEY (artist_attribute_type_allowed_value)
   REFERENCES artist_attribute_type_allowed_value(id);

ALTER TABLE artist_attribute_type
   ADD CONSTRAINT artist_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute_type_allowed_value
   ADD CONSTRAINT artist_attribute_type_allowed_value_fk_artist_attribute_type
   FOREIGN KEY (artist_attribute_type)
   REFERENCES artist_attribute_type(id);

ALTER TABLE artist_attribute_type_allowed_value
   ADD CONSTRAINT artist_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_attribute_type_allowed_value(id);

ALTER TABLE artist_credit_name
   ADD CONSTRAINT artist_credit_name_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id)
   ON DELETE CASCADE;

ALTER TABLE artist_credit_name
   ADD CONSTRAINT artist_credit_name_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE artist_gid_redirect
   ADD CONSTRAINT artist_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES artist(id);

ALTER TABLE artist_ipi
   ADD CONSTRAINT artist_ipi_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_isni
   ADD CONSTRAINT artist_isni_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_meta
   ADD CONSTRAINT artist_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE artist_rating_raw
   ADD CONSTRAINT artist_rating_raw_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_rating_raw
   ADD CONSTRAINT artist_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE artist_tag
   ADD CONSTRAINT artist_tag_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_tag
   ADD CONSTRAINT artist_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE artist_tag_raw
   ADD CONSTRAINT artist_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE artist_type
   ADD CONSTRAINT artist_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_type(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_candidate
   FOREIGN KEY (candidate)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_proposer
   FOREIGN KEY (proposer)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_seconder_1
   FOREIGN KEY (seconder_1)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election
   ADD CONSTRAINT autoeditor_election_fk_seconder_2
   FOREIGN KEY (seconder_2)
   REFERENCES editor(id);

ALTER TABLE autoeditor_election_vote
   ADD CONSTRAINT autoeditor_election_vote_fk_autoeditor_election
   FOREIGN KEY (autoeditor_election)
   REFERENCES autoeditor_election(id);

ALTER TABLE autoeditor_election_vote
   ADD CONSTRAINT autoeditor_election_vote_fk_voter
   FOREIGN KEY (voter)
   REFERENCES editor(id);

ALTER TABLE cdtoc_raw
   ADD CONSTRAINT cdtoc_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release_raw(id);

ALTER TABLE country_area
   ADD CONSTRAINT country_area_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE edit
   ADD CONSTRAINT edit_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE edit
   ADD CONSTRAINT edit_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE edit_area
   ADD CONSTRAINT edit_area_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_area
   ADD CONSTRAINT edit_area_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id)
   ON DELETE CASCADE;

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE edit_data
   ADD CONSTRAINT edit_data_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_event
   ADD CONSTRAINT edit_event_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_event
   ADD CONSTRAINT edit_event_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id)
   ON DELETE CASCADE;

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id)
   ON DELETE CASCADE;

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id)
   ON DELETE CASCADE;

ALTER TABLE edit_note
   ADD CONSTRAINT edit_note_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE edit_note
   ADD CONSTRAINT edit_note_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_recipient
   FOREIGN KEY (recipient)
   REFERENCES editor(id);

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_edit_note
   FOREIGN KEY (edit_note)
   REFERENCES edit_note(id);

ALTER TABLE edit_place
   ADD CONSTRAINT edit_place_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_place
   ADD CONSTRAINT edit_place_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id)
   ON DELETE CASCADE;

ALTER TABLE edit_recording
   ADD CONSTRAINT edit_recording_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_recording
   ADD CONSTRAINT edit_recording_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id)
   ON DELETE CASCADE;

ALTER TABLE edit_release
   ADD CONSTRAINT edit_release_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_release
   ADD CONSTRAINT edit_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id)
   ON DELETE CASCADE;

ALTER TABLE edit_release_group
   ADD CONSTRAINT edit_release_group_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_release_group
   ADD CONSTRAINT edit_release_group_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id)
   ON DELETE CASCADE;

ALTER TABLE edit_series
   ADD CONSTRAINT edit_series_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_series
   ADD CONSTRAINT edit_series_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id)
   ON DELETE CASCADE;

ALTER TABLE edit_url
   ADD CONSTRAINT edit_url_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_url
   ADD CONSTRAINT edit_url_fk_url
   FOREIGN KEY (url)
   REFERENCES url(id)
   ON DELETE CASCADE;

ALTER TABLE edit_work
   ADD CONSTRAINT edit_work_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_work
   ADD CONSTRAINT edit_work_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id)
   ON DELETE CASCADE;

ALTER TABLE editor
   ADD CONSTRAINT editor_fk_gender
   FOREIGN KEY (gender)
   REFERENCES gender(id);

ALTER TABLE editor
   ADD CONSTRAINT editor_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE editor_collection
   ADD CONSTRAINT editor_collection_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_collection
   ADD CONSTRAINT editor_collection_fk_type
   FOREIGN KEY (type)
   REFERENCES editor_collection_type(id);

ALTER TABLE editor_collection_area
   ADD CONSTRAINT editor_collection_area_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_area
   ADD CONSTRAINT editor_collection_area_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE editor_collection_artist
   ADD CONSTRAINT editor_collection_artist_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_artist
   ADD CONSTRAINT editor_collection_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_collaborator
   ADD CONSTRAINT editor_collection_collaborator_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_collection_deleted_entity
   ADD CONSTRAINT editor_collection_deleted_entity_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_deleted_entity
   ADD CONSTRAINT editor_collection_deleted_entity_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_collection_event
   ADD CONSTRAINT editor_collection_event_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_event
   ADD CONSTRAINT editor_collection_event_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE editor_collection_instrument
   ADD CONSTRAINT editor_collection_instrument_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_instrument
   ADD CONSTRAINT editor_collection_instrument_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE editor_collection_label
   ADD CONSTRAINT editor_collection_label_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_label
   ADD CONSTRAINT editor_collection_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE editor_collection_place
   ADD CONSTRAINT editor_collection_place_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_place
   ADD CONSTRAINT editor_collection_place_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE editor_collection_recording
   ADD CONSTRAINT editor_collection_recording_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_recording
   ADD CONSTRAINT editor_collection_recording_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE editor_collection_release
   ADD CONSTRAINT editor_collection_release_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_release
   ADD CONSTRAINT editor_collection_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE editor_collection_release_group
   ADD CONSTRAINT editor_collection_release_group_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_release_group
   ADD CONSTRAINT editor_collection_release_group_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE editor_collection_series
   ADD CONSTRAINT editor_collection_series_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_series
   ADD CONSTRAINT editor_collection_series_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE editor_collection_type
   ADD CONSTRAINT editor_collection_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES editor_collection_type(id);

ALTER TABLE editor_collection_work
   ADD CONSTRAINT editor_collection_work_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_work
   ADD CONSTRAINT editor_collection_work_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE editor_language
   ADD CONSTRAINT editor_language_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_language
   ADD CONSTRAINT editor_language_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE editor_oauth_token
   ADD CONSTRAINT editor_oauth_token_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_oauth_token
   ADD CONSTRAINT editor_oauth_token_fk_application
   FOREIGN KEY (application)
   REFERENCES application(id);

ALTER TABLE editor_preference
   ADD CONSTRAINT editor_preference_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_artist
   ADD CONSTRAINT editor_subscribe_artist_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_artist
   ADD CONSTRAINT editor_subscribe_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE editor_subscribe_artist
   ADD CONSTRAINT editor_subscribe_artist_fk_last_edit_sent
   FOREIGN KEY (last_edit_sent)
   REFERENCES edit(id);

ALTER TABLE editor_subscribe_artist_deleted
   ADD CONSTRAINT editor_subscribe_artist_deleted_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_artist_deleted
   ADD CONSTRAINT editor_subscribe_artist_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_subscribe_artist_deleted
   ADD CONSTRAINT editor_subscribe_artist_deleted_fk_deleted_by
   FOREIGN KEY (deleted_by)
   REFERENCES edit(id);

ALTER TABLE editor_subscribe_collection
   ADD CONSTRAINT editor_subscribe_collection_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_editor
   ADD CONSTRAINT editor_subscribe_editor_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_editor
   ADD CONSTRAINT editor_subscribe_editor_fk_subscribed_editor
   FOREIGN KEY (subscribed_editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_label
   ADD CONSTRAINT editor_subscribe_label_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_label
   ADD CONSTRAINT editor_subscribe_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE editor_subscribe_label
   ADD CONSTRAINT editor_subscribe_label_fk_last_edit_sent
   FOREIGN KEY (last_edit_sent)
   REFERENCES edit(id);

ALTER TABLE editor_subscribe_label_deleted
   ADD CONSTRAINT editor_subscribe_label_deleted_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_label_deleted
   ADD CONSTRAINT editor_subscribe_label_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_subscribe_label_deleted
   ADD CONSTRAINT editor_subscribe_label_deleted_fk_deleted_by
   FOREIGN KEY (deleted_by)
   REFERENCES edit(id);

ALTER TABLE editor_subscribe_series
   ADD CONSTRAINT editor_subscribe_series_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_series
   ADD CONSTRAINT editor_subscribe_series_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE editor_subscribe_series
   ADD CONSTRAINT editor_subscribe_series_fk_last_edit_sent
   FOREIGN KEY (last_edit_sent)
   REFERENCES edit(id);

ALTER TABLE editor_subscribe_series_deleted
   ADD CONSTRAINT editor_subscribe_series_deleted_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE editor_subscribe_series_deleted
   ADD CONSTRAINT editor_subscribe_series_deleted_fk_gid
   FOREIGN KEY (gid)
   REFERENCES deleted_entity(gid);

ALTER TABLE editor_subscribe_series_deleted
   ADD CONSTRAINT editor_subscribe_series_deleted_fk_deleted_by
   FOREIGN KEY (deleted_by)
   REFERENCES edit(id);

ALTER TABLE editor_watch_artist
   ADD CONSTRAINT editor_watch_artist_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_artist
   ADD CONSTRAINT editor_watch_artist_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_preferences
   ADD CONSTRAINT editor_watch_preferences_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_group_type
   ADD CONSTRAINT editor_watch_release_group_type_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_group_type
   ADD CONSTRAINT editor_watch_release_group_type_fk_release_group_type
   FOREIGN KEY (release_group_type)
   REFERENCES release_group_primary_type(id);

ALTER TABLE editor_watch_release_status
   ADD CONSTRAINT editor_watch_release_status_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id)
   ON DELETE CASCADE;

ALTER TABLE editor_watch_release_status
   ADD CONSTRAINT editor_watch_release_status_fk_release_status
   FOREIGN KEY (release_status)
   REFERENCES release_status(id);

ALTER TABLE event
   ADD CONSTRAINT event_fk_type
   FOREIGN KEY (type)
   REFERENCES event_type(id);

ALTER TABLE event_alias
   ADD CONSTRAINT event_alias_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_alias
   ADD CONSTRAINT event_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES event_alias_type(id);

ALTER TABLE event_alias_type
   ADD CONSTRAINT event_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_alias_type(id);

ALTER TABLE event_annotation
   ADD CONSTRAINT event_annotation_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_annotation
   ADD CONSTRAINT event_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event_attribute_type
   FOREIGN KEY (event_attribute_type)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute
   ADD CONSTRAINT event_attribute_fk_event_attribute_type_allowed_value
   FOREIGN KEY (event_attribute_type_allowed_value)
   REFERENCES event_attribute_type_allowed_value(id);

ALTER TABLE event_attribute_type
   ADD CONSTRAINT event_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute_type_allowed_value
   ADD CONSTRAINT event_attribute_type_allowed_value_fk_event_attribute_type
   FOREIGN KEY (event_attribute_type)
   REFERENCES event_attribute_type(id);

ALTER TABLE event_attribute_type_allowed_value
   ADD CONSTRAINT event_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_attribute_type_allowed_value(id);

ALTER TABLE event_gid_redirect
   ADD CONSTRAINT event_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES event(id);

ALTER TABLE event_meta
   ADD CONSTRAINT event_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES event(id)
   ON DELETE CASCADE;

ALTER TABLE event_rating_raw
   ADD CONSTRAINT event_rating_raw_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_rating_raw
   ADD CONSTRAINT event_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE event_tag
   ADD CONSTRAINT event_tag_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_tag
   ADD CONSTRAINT event_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE event_tag_raw
   ADD CONSTRAINT event_tag_raw_fk_event
   FOREIGN KEY (event)
   REFERENCES event(id);

ALTER TABLE event_tag_raw
   ADD CONSTRAINT event_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE event_tag_raw
   ADD CONSTRAINT event_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE event_type
   ADD CONSTRAINT event_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES event_type(id);

ALTER TABLE gender
   ADD CONSTRAINT gender_fk_parent
   FOREIGN KEY (parent)
   REFERENCES gender(id);

ALTER TABLE genre_alias
   ADD CONSTRAINT genre_alias_fk_genre
   FOREIGN KEY (genre)
   REFERENCES genre(id);

ALTER TABLE instrument
   ADD CONSTRAINT instrument_fk_type
   FOREIGN KEY (type)
   REFERENCES instrument_type(id);

ALTER TABLE instrument_alias
   ADD CONSTRAINT instrument_alias_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_alias
   ADD CONSTRAINT instrument_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES instrument_alias_type(id);

ALTER TABLE instrument_alias_type
   ADD CONSTRAINT instrument_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_alias_type(id);

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument_attribute_type
   FOREIGN KEY (instrument_attribute_type)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute
   ADD CONSTRAINT instrument_attribute_fk_instrument_attribute_type_allowed_value
   FOREIGN KEY (instrument_attribute_type_allowed_value)
   REFERENCES instrument_attribute_type_allowed_value(id);

ALTER TABLE instrument_attribute_type
   ADD CONSTRAINT instrument_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute_type_allowed_value
   ADD CONSTRAINT instrument_attribute_type_allowed_value_fk_instrument_attribute_type
   FOREIGN KEY (instrument_attribute_type)
   REFERENCES instrument_attribute_type(id);

ALTER TABLE instrument_attribute_type_allowed_value
   ADD CONSTRAINT instrument_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_attribute_type_allowed_value(id);

ALTER TABLE instrument_gid_redirect
   ADD CONSTRAINT instrument_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES instrument(id);

ALTER TABLE instrument_tag
   ADD CONSTRAINT instrument_tag_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_tag
   ADD CONSTRAINT instrument_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE instrument_tag_raw
   ADD CONSTRAINT instrument_tag_raw_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_tag_raw
   ADD CONSTRAINT instrument_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE instrument_tag_raw
   ADD CONSTRAINT instrument_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE instrument_type
   ADD CONSTRAINT instrument_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES instrument_type(id);

ALTER TABLE iso_3166_1
   ADD CONSTRAINT iso_3166_1_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE iso_3166_2
   ADD CONSTRAINT iso_3166_2_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE iso_3166_3
   ADD CONSTRAINT iso_3166_3_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE isrc
   ADD CONSTRAINT isrc_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE iswc
   ADD CONSTRAINT iswc_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE l_area_area
   ADD CONSTRAINT l_area_area_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_area
   ADD CONSTRAINT l_area_area_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_area
   ADD CONSTRAINT l_area_area_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES area(id);

ALTER TABLE l_area_artist
   ADD CONSTRAINT l_area_artist_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_artist
   ADD CONSTRAINT l_area_artist_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_artist
   ADD CONSTRAINT l_area_artist_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES artist(id);

ALTER TABLE l_area_event
   ADD CONSTRAINT l_area_event_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_event
   ADD CONSTRAINT l_area_event_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_event
   ADD CONSTRAINT l_area_event_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES event(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_instrument
   ADD CONSTRAINT l_area_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_area_label
   ADD CONSTRAINT l_area_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_label
   ADD CONSTRAINT l_area_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_label
   ADD CONSTRAINT l_area_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_area_place
   ADD CONSTRAINT l_area_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_place
   ADD CONSTRAINT l_area_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_place
   ADD CONSTRAINT l_area_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_area_recording
   ADD CONSTRAINT l_area_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_recording
   ADD CONSTRAINT l_area_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_recording
   ADD CONSTRAINT l_area_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_area_release
   ADD CONSTRAINT l_area_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_release
   ADD CONSTRAINT l_area_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_release
   ADD CONSTRAINT l_area_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_area_release_group
   ADD CONSTRAINT l_area_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_release_group
   ADD CONSTRAINT l_area_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_release_group
   ADD CONSTRAINT l_area_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_area_series
   ADD CONSTRAINT l_area_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_series
   ADD CONSTRAINT l_area_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_series
   ADD CONSTRAINT l_area_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_area_url
   ADD CONSTRAINT l_area_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_url
   ADD CONSTRAINT l_area_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_url
   ADD CONSTRAINT l_area_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_area_work
   ADD CONSTRAINT l_area_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_work
   ADD CONSTRAINT l_area_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_work
   ADD CONSTRAINT l_area_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_artist_artist
   ADD CONSTRAINT l_artist_artist_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_artist
   ADD CONSTRAINT l_artist_artist_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_artist
   ADD CONSTRAINT l_artist_artist_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES artist(id);

ALTER TABLE l_artist_event
   ADD CONSTRAINT l_artist_event_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_event
   ADD CONSTRAINT l_artist_event_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_event
   ADD CONSTRAINT l_artist_event_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES event(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_instrument
   ADD CONSTRAINT l_artist_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_artist_label
   ADD CONSTRAINT l_artist_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_label
   ADD CONSTRAINT l_artist_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_label
   ADD CONSTRAINT l_artist_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_artist_place
   ADD CONSTRAINT l_artist_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_place
   ADD CONSTRAINT l_artist_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_place
   ADD CONSTRAINT l_artist_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_artist_recording
   ADD CONSTRAINT l_artist_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_recording
   ADD CONSTRAINT l_artist_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_recording
   ADD CONSTRAINT l_artist_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_artist_release
   ADD CONSTRAINT l_artist_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_release
   ADD CONSTRAINT l_artist_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_release
   ADD CONSTRAINT l_artist_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_artist_release_group
   ADD CONSTRAINT l_artist_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_release_group
   ADD CONSTRAINT l_artist_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_release_group
   ADD CONSTRAINT l_artist_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_artist_series
   ADD CONSTRAINT l_artist_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_series
   ADD CONSTRAINT l_artist_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_series
   ADD CONSTRAINT l_artist_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_artist_url
   ADD CONSTRAINT l_artist_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_url
   ADD CONSTRAINT l_artist_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_url
   ADD CONSTRAINT l_artist_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_artist_work
   ADD CONSTRAINT l_artist_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_work
   ADD CONSTRAINT l_artist_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_work
   ADD CONSTRAINT l_artist_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_event_event
   ADD CONSTRAINT l_event_event_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_event
   ADD CONSTRAINT l_event_event_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_event
   ADD CONSTRAINT l_event_event_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES event(id);

ALTER TABLE l_event_instrument
   ADD CONSTRAINT l_event_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_instrument
   ADD CONSTRAINT l_event_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_instrument
   ADD CONSTRAINT l_event_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_event_label
   ADD CONSTRAINT l_event_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_label
   ADD CONSTRAINT l_event_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_label
   ADD CONSTRAINT l_event_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_event_place
   ADD CONSTRAINT l_event_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_place
   ADD CONSTRAINT l_event_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_place
   ADD CONSTRAINT l_event_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_event_recording
   ADD CONSTRAINT l_event_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_recording
   ADD CONSTRAINT l_event_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_recording
   ADD CONSTRAINT l_event_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_event_release
   ADD CONSTRAINT l_event_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_release
   ADD CONSTRAINT l_event_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_release
   ADD CONSTRAINT l_event_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_event_release_group
   ADD CONSTRAINT l_event_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_release_group
   ADD CONSTRAINT l_event_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_release_group
   ADD CONSTRAINT l_event_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_event_series
   ADD CONSTRAINT l_event_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_series
   ADD CONSTRAINT l_event_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_series
   ADD CONSTRAINT l_event_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_event_url
   ADD CONSTRAINT l_event_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_url
   ADD CONSTRAINT l_event_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_url
   ADD CONSTRAINT l_event_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_event_work
   ADD CONSTRAINT l_event_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_work
   ADD CONSTRAINT l_event_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_work
   ADD CONSTRAINT l_event_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_instrument
   ADD CONSTRAINT l_instrument_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_label
   ADD CONSTRAINT l_instrument_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_place
   ADD CONSTRAINT l_instrument_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_recording
   ADD CONSTRAINT l_instrument_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_release
   ADD CONSTRAINT l_instrument_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_release_group
   ADD CONSTRAINT l_instrument_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_instrument_series
   ADD CONSTRAINT l_instrument_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_series
   ADD CONSTRAINT l_instrument_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_series
   ADD CONSTRAINT l_instrument_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_url
   ADD CONSTRAINT l_instrument_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_work
   ADD CONSTRAINT l_instrument_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_label_label
   ADD CONSTRAINT l_label_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_label
   ADD CONSTRAINT l_label_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_label
   ADD CONSTRAINT l_label_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_label_place
   ADD CONSTRAINT l_label_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_place
   ADD CONSTRAINT l_label_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_place
   ADD CONSTRAINT l_label_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_label_recording
   ADD CONSTRAINT l_label_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_recording
   ADD CONSTRAINT l_label_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_recording
   ADD CONSTRAINT l_label_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_label_release
   ADD CONSTRAINT l_label_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_release
   ADD CONSTRAINT l_label_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_release
   ADD CONSTRAINT l_label_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_label_release_group
   ADD CONSTRAINT l_label_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_release_group
   ADD CONSTRAINT l_label_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_release_group
   ADD CONSTRAINT l_label_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_label_series
   ADD CONSTRAINT l_label_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_series
   ADD CONSTRAINT l_label_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_series
   ADD CONSTRAINT l_label_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_label_url
   ADD CONSTRAINT l_label_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_url
   ADD CONSTRAINT l_label_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_url
   ADD CONSTRAINT l_label_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_label_work
   ADD CONSTRAINT l_label_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_work
   ADD CONSTRAINT l_label_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_work
   ADD CONSTRAINT l_label_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_place_place
   ADD CONSTRAINT l_place_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_place
   ADD CONSTRAINT l_place_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_place
   ADD CONSTRAINT l_place_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_place_recording
   ADD CONSTRAINT l_place_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_recording
   ADD CONSTRAINT l_place_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_recording
   ADD CONSTRAINT l_place_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_place_release
   ADD CONSTRAINT l_place_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_release
   ADD CONSTRAINT l_place_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_release
   ADD CONSTRAINT l_place_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_place_release_group
   ADD CONSTRAINT l_place_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_release_group
   ADD CONSTRAINT l_place_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_release_group
   ADD CONSTRAINT l_place_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_place_series
   ADD CONSTRAINT l_place_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_series
   ADD CONSTRAINT l_place_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_series
   ADD CONSTRAINT l_place_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_place_url
   ADD CONSTRAINT l_place_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_url
   ADD CONSTRAINT l_place_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_url
   ADD CONSTRAINT l_place_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_place_work
   ADD CONSTRAINT l_place_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_place_work
   ADD CONSTRAINT l_place_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES place(id);

ALTER TABLE l_place_work
   ADD CONSTRAINT l_place_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_recording_recording
   ADD CONSTRAINT l_recording_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_recording
   ADD CONSTRAINT l_recording_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_recording
   ADD CONSTRAINT l_recording_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_recording_release
   ADD CONSTRAINT l_recording_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_release
   ADD CONSTRAINT l_recording_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_release
   ADD CONSTRAINT l_recording_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_recording_release_group
   ADD CONSTRAINT l_recording_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_release_group
   ADD CONSTRAINT l_recording_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_release_group
   ADD CONSTRAINT l_recording_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_recording_series
   ADD CONSTRAINT l_recording_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_series
   ADD CONSTRAINT l_recording_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_series
   ADD CONSTRAINT l_recording_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_recording_url
   ADD CONSTRAINT l_recording_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_url
   ADD CONSTRAINT l_recording_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_url
   ADD CONSTRAINT l_recording_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_recording_work
   ADD CONSTRAINT l_recording_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_recording_work
   ADD CONSTRAINT l_recording_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES recording(id);

ALTER TABLE l_recording_work
   ADD CONSTRAINT l_recording_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_release_group_release_group
   ADD CONSTRAINT l_release_group_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_group_release_group
   ADD CONSTRAINT l_release_group_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release_group(id);

ALTER TABLE l_release_group_release_group
   ADD CONSTRAINT l_release_group_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_release_group_series
   ADD CONSTRAINT l_release_group_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_group_series
   ADD CONSTRAINT l_release_group_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release_group(id);

ALTER TABLE l_release_group_series
   ADD CONSTRAINT l_release_group_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_release_group_url
   ADD CONSTRAINT l_release_group_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_group_url
   ADD CONSTRAINT l_release_group_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release_group(id);

ALTER TABLE l_release_group_url
   ADD CONSTRAINT l_release_group_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_release_group_work
   ADD CONSTRAINT l_release_group_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_group_work
   ADD CONSTRAINT l_release_group_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release_group(id);

ALTER TABLE l_release_group_work
   ADD CONSTRAINT l_release_group_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_release_release
   ADD CONSTRAINT l_release_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_release
   ADD CONSTRAINT l_release_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release(id);

ALTER TABLE l_release_release
   ADD CONSTRAINT l_release_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_release_release_group
   ADD CONSTRAINT l_release_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_release_group
   ADD CONSTRAINT l_release_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release(id);

ALTER TABLE l_release_release_group
   ADD CONSTRAINT l_release_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_release_series
   ADD CONSTRAINT l_release_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_series
   ADD CONSTRAINT l_release_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release(id);

ALTER TABLE l_release_series
   ADD CONSTRAINT l_release_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_release_url
   ADD CONSTRAINT l_release_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_url
   ADD CONSTRAINT l_release_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release(id);

ALTER TABLE l_release_url
   ADD CONSTRAINT l_release_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_release_work
   ADD CONSTRAINT l_release_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_release_work
   ADD CONSTRAINT l_release_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES release(id);

ALTER TABLE l_release_work
   ADD CONSTRAINT l_release_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_series_series
   ADD CONSTRAINT l_series_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_series_series
   ADD CONSTRAINT l_series_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES series(id);

ALTER TABLE l_series_series
   ADD CONSTRAINT l_series_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_series_url
   ADD CONSTRAINT l_series_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_series_url
   ADD CONSTRAINT l_series_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES series(id);

ALTER TABLE l_series_url
   ADD CONSTRAINT l_series_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_series_work
   ADD CONSTRAINT l_series_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_series_work
   ADD CONSTRAINT l_series_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES series(id);

ALTER TABLE l_series_work
   ADD CONSTRAINT l_series_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_url_url
   ADD CONSTRAINT l_url_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_url_url
   ADD CONSTRAINT l_url_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES url(id);

ALTER TABLE l_url_url
   ADD CONSTRAINT l_url_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_url_work
   ADD CONSTRAINT l_url_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_url_work
   ADD CONSTRAINT l_url_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES url(id);

ALTER TABLE l_url_work
   ADD CONSTRAINT l_url_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE l_work_work
   ADD CONSTRAINT l_work_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_work_work
   ADD CONSTRAINT l_work_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES work(id);

ALTER TABLE l_work_work
   ADD CONSTRAINT l_work_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE label
   ADD CONSTRAINT label_fk_type
   FOREIGN KEY (type)
   REFERENCES label_type(id);

ALTER TABLE label
   ADD CONSTRAINT label_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES label_alias_type(id);

ALTER TABLE label_alias_type
   ADD CONSTRAINT label_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_alias_type(id);

ALTER TABLE label_annotation
   ADD CONSTRAINT label_annotation_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_annotation
   ADD CONSTRAINT label_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label_attribute_type
   FOREIGN KEY (label_attribute_type)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute
   ADD CONSTRAINT label_attribute_fk_label_attribute_type_allowed_value
   FOREIGN KEY (label_attribute_type_allowed_value)
   REFERENCES label_attribute_type_allowed_value(id);

ALTER TABLE label_attribute_type
   ADD CONSTRAINT label_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute_type_allowed_value
   ADD CONSTRAINT label_attribute_type_allowed_value_fk_label_attribute_type
   FOREIGN KEY (label_attribute_type)
   REFERENCES label_attribute_type(id);

ALTER TABLE label_attribute_type_allowed_value
   ADD CONSTRAINT label_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_attribute_type_allowed_value(id);

ALTER TABLE label_gid_redirect
   ADD CONSTRAINT label_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES label(id);

ALTER TABLE label_ipi
   ADD CONSTRAINT label_ipi_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_isni
   ADD CONSTRAINT label_isni_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_meta
   ADD CONSTRAINT label_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES label(id)
   ON DELETE CASCADE;

ALTER TABLE label_rating_raw
   ADD CONSTRAINT label_rating_raw_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_rating_raw
   ADD CONSTRAINT label_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE label_tag
   ADD CONSTRAINT label_tag_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_tag
   ADD CONSTRAINT label_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE label_tag_raw
   ADD CONSTRAINT label_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE label_type
   ADD CONSTRAINT label_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_type(id);

ALTER TABLE link
   ADD CONSTRAINT link_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

ALTER TABLE link_attribute
   ADD CONSTRAINT link_attribute_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE link_attribute
   ADD CONSTRAINT link_attribute_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_attribute_type(id);

ALTER TABLE link_attribute_credit
   ADD CONSTRAINT link_attribute_credit_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE link_attribute_credit
   ADD CONSTRAINT link_attribute_credit_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_creditable_attribute_type(attribute_type);

ALTER TABLE link_attribute_text_value
   ADD CONSTRAINT link_attribute_text_value_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE link_attribute_text_value
   ADD CONSTRAINT link_attribute_text_value_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_text_attribute_type(attribute_type);

ALTER TABLE link_attribute_type
   ADD CONSTRAINT link_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES link_attribute_type(id);

ALTER TABLE link_attribute_type
   ADD CONSTRAINT link_attribute_type_fk_root
   FOREIGN KEY (root)
   REFERENCES link_attribute_type(id);

ALTER TABLE link_creditable_attribute_type
   ADD CONSTRAINT link_creditable_attribute_type_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_attribute_type(id)
   ON DELETE CASCADE;

ALTER TABLE link_text_attribute_type
   ADD CONSTRAINT link_text_attribute_type_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_attribute_type(id)
   ON DELETE CASCADE;

ALTER TABLE link_type
   ADD CONSTRAINT link_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES link_type(id);

ALTER TABLE link_type_attribute_type
   ADD CONSTRAINT link_type_attribute_type_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

ALTER TABLE link_type_attribute_type
   ADD CONSTRAINT link_type_attribute_type_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_attribute_type(id);

ALTER TABLE medium
   ADD CONSTRAINT medium_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE medium
   ADD CONSTRAINT medium_fk_format
   FOREIGN KEY (format)
   REFERENCES medium_format(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute
   ADD CONSTRAINT medium_attribute_fk_medium_attribute_type_allowed_value
   FOREIGN KEY (medium_attribute_type_allowed_value)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute_type
   ADD CONSTRAINT medium_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_format_fk_medium_format
   FOREIGN KEY (medium_format)
   REFERENCES medium_format(id);

ALTER TABLE medium_attribute_type_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_format_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_value
   ADD CONSTRAINT medium_attribute_type_allowed_value_fk_medium_attribute_type
   FOREIGN KEY (medium_attribute_type)
   REFERENCES medium_attribute_type(id);

ALTER TABLE medium_attribute_type_allowed_value
   ADD CONSTRAINT medium_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_attribute_type_allowed_value_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_value_allowed_format_fk_medium_format
   FOREIGN KEY (medium_format)
   REFERENCES medium_format(id);

ALTER TABLE medium_attribute_type_allowed_value_allowed_format
   ADD CONSTRAINT medium_attribute_type_allowed_value_allowed_format_fk_medium_attribute_type_allowed_value
   FOREIGN KEY (medium_attribute_type_allowed_value)
   REFERENCES medium_attribute_type_allowed_value(id);

ALTER TABLE medium_cdtoc
   ADD CONSTRAINT medium_cdtoc_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id);

ALTER TABLE medium_cdtoc
   ADD CONSTRAINT medium_cdtoc_fk_cdtoc
   FOREIGN KEY (cdtoc)
   REFERENCES cdtoc(id);

ALTER TABLE medium_format
   ADD CONSTRAINT medium_format_fk_parent
   FOREIGN KEY (parent)
   REFERENCES medium_format(id);

ALTER TABLE medium_index
   ADD CONSTRAINT medium_index_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id)
   ON DELETE CASCADE;

ALTER TABLE orderable_link_type
   ADD CONSTRAINT orderable_link_type_fk_link_type
   FOREIGN KEY (link_type)
   REFERENCES link_type(id);

ALTER TABLE place
   ADD CONSTRAINT place_fk_type
   FOREIGN KEY (type)
   REFERENCES place_type(id);

ALTER TABLE place
   ADD CONSTRAINT place_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE place_alias
   ADD CONSTRAINT place_alias_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_alias
   ADD CONSTRAINT place_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES place_alias_type(id);

ALTER TABLE place_alias_type
   ADD CONSTRAINT place_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_alias_type(id);

ALTER TABLE place_annotation
   ADD CONSTRAINT place_annotation_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_annotation
   ADD CONSTRAINT place_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place_attribute_type
   FOREIGN KEY (place_attribute_type)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute
   ADD CONSTRAINT place_attribute_fk_place_attribute_type_allowed_value
   FOREIGN KEY (place_attribute_type_allowed_value)
   REFERENCES place_attribute_type_allowed_value(id);

ALTER TABLE place_attribute_type
   ADD CONSTRAINT place_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute_type_allowed_value
   ADD CONSTRAINT place_attribute_type_allowed_value_fk_place_attribute_type
   FOREIGN KEY (place_attribute_type)
   REFERENCES place_attribute_type(id);

ALTER TABLE place_attribute_type_allowed_value
   ADD CONSTRAINT place_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_attribute_type_allowed_value(id);

ALTER TABLE place_gid_redirect
   ADD CONSTRAINT place_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES place(id);

ALTER TABLE place_tag
   ADD CONSTRAINT place_tag_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_tag
   ADD CONSTRAINT place_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE place_tag_raw
   ADD CONSTRAINT place_tag_raw_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_tag_raw
   ADD CONSTRAINT place_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE place_tag_raw
   ADD CONSTRAINT place_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE place_type
   ADD CONSTRAINT place_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_type(id);

ALTER TABLE recording
   ADD CONSTRAINT recording_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE recording_alias
   ADD CONSTRAINT recording_alias_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_alias
   ADD CONSTRAINT recording_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES recording_alias_type(id);

ALTER TABLE recording_alias_type
   ADD CONSTRAINT recording_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_alias_type(id);

ALTER TABLE recording_annotation
   ADD CONSTRAINT recording_annotation_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_annotation
   ADD CONSTRAINT recording_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording_attribute_type
   FOREIGN KEY (recording_attribute_type)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute
   ADD CONSTRAINT recording_attribute_fk_recording_attribute_type_allowed_value
   FOREIGN KEY (recording_attribute_type_allowed_value)
   REFERENCES recording_attribute_type_allowed_value(id);

ALTER TABLE recording_attribute_type
   ADD CONSTRAINT recording_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute_type_allowed_value
   ADD CONSTRAINT recording_attribute_type_allowed_value_fk_recording_attribute_type
   FOREIGN KEY (recording_attribute_type)
   REFERENCES recording_attribute_type(id);

ALTER TABLE recording_attribute_type_allowed_value
   ADD CONSTRAINT recording_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES recording_attribute_type_allowed_value(id);

ALTER TABLE recording_gid_redirect
   ADD CONSTRAINT recording_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES recording(id);

ALTER TABLE recording_meta
   ADD CONSTRAINT recording_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES recording(id)
   ON DELETE CASCADE;

ALTER TABLE recording_rating_raw
   ADD CONSTRAINT recording_rating_raw_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_rating_raw
   ADD CONSTRAINT recording_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE recording_tag
   ADD CONSTRAINT recording_tag_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_tag
   ADD CONSTRAINT recording_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE recording_tag_raw
   ADD CONSTRAINT recording_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_status
   FOREIGN KEY (status)
   REFERENCES release_status(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_packaging
   FOREIGN KEY (packaging)
   REFERENCES release_packaging(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE release
   ADD CONSTRAINT release_fk_script
   FOREIGN KEY (script)
   REFERENCES script(id);

ALTER TABLE release_alias
   ADD CONSTRAINT release_alias_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_alias
   ADD CONSTRAINT release_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES release_alias_type(id);

ALTER TABLE release_alias_type
   ADD CONSTRAINT release_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_alias_type(id);

ALTER TABLE release_annotation
   ADD CONSTRAINT release_annotation_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_annotation
   ADD CONSTRAINT release_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release_attribute_type
   FOREIGN KEY (release_attribute_type)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute
   ADD CONSTRAINT release_attribute_fk_release_attribute_type_allowed_value
   FOREIGN KEY (release_attribute_type_allowed_value)
   REFERENCES release_attribute_type_allowed_value(id);

ALTER TABLE release_attribute_type
   ADD CONSTRAINT release_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute_type_allowed_value
   ADD CONSTRAINT release_attribute_type_allowed_value_fk_release_attribute_type
   FOREIGN KEY (release_attribute_type)
   REFERENCES release_attribute_type(id);

ALTER TABLE release_attribute_type_allowed_value
   ADD CONSTRAINT release_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_attribute_type_allowed_value(id);

ALTER TABLE release_country
   ADD CONSTRAINT release_country_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_country
   ADD CONSTRAINT release_country_fk_country
   FOREIGN KEY (country)
   REFERENCES country_area(area);

ALTER TABLE release_coverart
   ADD CONSTRAINT release_coverart_fk_id
   FOREIGN KEY (id)
   REFERENCES release(id)
   ON DELETE CASCADE;

ALTER TABLE release_gid_redirect
   ADD CONSTRAINT release_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES release(id);

ALTER TABLE release_group
   ADD CONSTRAINT release_group_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE release_group
   ADD CONSTRAINT release_group_fk_type
   FOREIGN KEY (type)
   REFERENCES release_group_primary_type(id);

ALTER TABLE release_group_alias
   ADD CONSTRAINT release_group_alias_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_alias
   ADD CONSTRAINT release_group_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES release_group_alias_type(id);

ALTER TABLE release_group_alias_type
   ADD CONSTRAINT release_group_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_alias_type(id);

ALTER TABLE release_group_annotation
   ADD CONSTRAINT release_group_annotation_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_annotation
   ADD CONSTRAINT release_group_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group_attribute_type
   FOREIGN KEY (release_group_attribute_type)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute
   ADD CONSTRAINT release_group_attribute_fk_release_group_attribute_type_allowed_value
   FOREIGN KEY (release_group_attribute_type_allowed_value)
   REFERENCES release_group_attribute_type_allowed_value(id);

ALTER TABLE release_group_attribute_type
   ADD CONSTRAINT release_group_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute_type_allowed_value
   ADD CONSTRAINT release_group_attribute_type_allowed_value_fk_release_group_attribute_type
   FOREIGN KEY (release_group_attribute_type)
   REFERENCES release_group_attribute_type(id);

ALTER TABLE release_group_attribute_type_allowed_value
   ADD CONSTRAINT release_group_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_attribute_type_allowed_value(id);

ALTER TABLE release_group_gid_redirect
   ADD CONSTRAINT release_group_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES release_group(id);

ALTER TABLE release_group_meta
   ADD CONSTRAINT release_group_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES release_group(id)
   ON DELETE CASCADE;

ALTER TABLE release_group_primary_type
   ADD CONSTRAINT release_group_primary_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_primary_type(id);

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_group_secondary_type
   ADD CONSTRAINT release_group_secondary_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_secondary_type(id);

ALTER TABLE release_group_secondary_type_join
   ADD CONSTRAINT release_group_secondary_type_join_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_secondary_type_join
   ADD CONSTRAINT release_group_secondary_type_join_fk_secondary_type
   FOREIGN KEY (secondary_type)
   REFERENCES release_group_secondary_type(id);

ALTER TABLE release_group_tag
   ADD CONSTRAINT release_group_tag_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_tag
   ADD CONSTRAINT release_group_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_group_tag_raw
   ADD CONSTRAINT release_group_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_label
   ADD CONSTRAINT release_label_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_label
   ADD CONSTRAINT release_label_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE release_meta
   ADD CONSTRAINT release_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES release(id)
   ON DELETE CASCADE;

ALTER TABLE release_packaging
   ADD CONSTRAINT release_packaging_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_packaging(id);

ALTER TABLE release_status
   ADD CONSTRAINT release_status_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_status(id);

ALTER TABLE release_tag
   ADD CONSTRAINT release_tag_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_tag
   ADD CONSTRAINT release_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE release_tag_raw
   ADD CONSTRAINT release_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE release_unknown_country
   ADD CONSTRAINT release_unknown_country_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE series
   ADD CONSTRAINT series_fk_type
   FOREIGN KEY (type)
   REFERENCES series_type(id);

ALTER TABLE series
   ADD CONSTRAINT series_fk_ordering_attribute
   FOREIGN KEY (ordering_attribute)
   REFERENCES link_text_attribute_type(attribute_type);

ALTER TABLE series
   ADD CONSTRAINT series_fk_ordering_type
   FOREIGN KEY (ordering_type)
   REFERENCES series_ordering_type(id);

ALTER TABLE series_alias
   ADD CONSTRAINT series_alias_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_alias
   ADD CONSTRAINT series_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES series_alias_type(id);

ALTER TABLE series_alias_type
   ADD CONSTRAINT series_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_alias_type(id);

ALTER TABLE series_annotation
   ADD CONSTRAINT series_annotation_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_annotation
   ADD CONSTRAINT series_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series_attribute_type
   FOREIGN KEY (series_attribute_type)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute
   ADD CONSTRAINT series_attribute_fk_series_attribute_type_allowed_value
   FOREIGN KEY (series_attribute_type_allowed_value)
   REFERENCES series_attribute_type_allowed_value(id);

ALTER TABLE series_attribute_type
   ADD CONSTRAINT series_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute_type_allowed_value
   ADD CONSTRAINT series_attribute_type_allowed_value_fk_series_attribute_type
   FOREIGN KEY (series_attribute_type)
   REFERENCES series_attribute_type(id);

ALTER TABLE series_attribute_type_allowed_value
   ADD CONSTRAINT series_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_attribute_type_allowed_value(id);

ALTER TABLE series_gid_redirect
   ADD CONSTRAINT series_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES series(id);

ALTER TABLE series_ordering_type
   ADD CONSTRAINT series_ordering_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_ordering_type(id);

ALTER TABLE series_tag
   ADD CONSTRAINT series_tag_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_tag
   ADD CONSTRAINT series_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE series_tag_raw
   ADD CONSTRAINT series_tag_raw_fk_series
   FOREIGN KEY (series)
   REFERENCES series(id);

ALTER TABLE series_tag_raw
   ADD CONSTRAINT series_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE series_tag_raw
   ADD CONSTRAINT series_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE series_type
   ADD CONSTRAINT series_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES series_type(id);

ALTER TABLE tag_relation
   ADD CONSTRAINT tag_relation_fk_tag1
   FOREIGN KEY (tag1)
   REFERENCES tag(id);

ALTER TABLE tag_relation
   ADD CONSTRAINT tag_relation_fk_tag2
   FOREIGN KEY (tag2)
   REFERENCES tag(id);

ALTER TABLE track
   ADD CONSTRAINT track_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE track
   ADD CONSTRAINT track_fk_medium
   FOREIGN KEY (medium)
   REFERENCES medium(id);

ALTER TABLE track
   ADD CONSTRAINT track_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE track_gid_redirect
   ADD CONSTRAINT track_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES track(id);

ALTER TABLE track_raw
   ADD CONSTRAINT track_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release_raw(id);

ALTER TABLE url_gid_redirect
   ADD CONSTRAINT url_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES url(id);

ALTER TABLE vote
   ADD CONSTRAINT vote_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE vote
   ADD CONSTRAINT vote_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE work
   ADD CONSTRAINT work_fk_type
   FOREIGN KEY (type)
   REFERENCES work_type(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES work_alias_type(id);

ALTER TABLE work_alias_type
   ADD CONSTRAINT work_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_alias_type(id);

ALTER TABLE work_annotation
   ADD CONSTRAINT work_annotation_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_annotation
   ADD CONSTRAINT work_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work_attribute_type_allowed_value
   FOREIGN KEY (work_attribute_type_allowed_value)
   REFERENCES work_attribute_type_allowed_value(id);

ALTER TABLE work_attribute_type
   ADD CONSTRAINT work_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_attribute_type_allowed_value
   ADD CONSTRAINT work_attribute_type_allowed_value_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_attribute_type_allowed_value
   ADD CONSTRAINT work_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_attribute_type_allowed_value(id);

ALTER TABLE work_gid_redirect
   ADD CONSTRAINT work_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES work(id);

ALTER TABLE work_language
   ADD CONSTRAINT work_language_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_language
   ADD CONSTRAINT work_language_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE work_meta
   ADD CONSTRAINT work_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES work(id)
   ON DELETE CASCADE;

ALTER TABLE work_rating_raw
   ADD CONSTRAINT work_rating_raw_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_rating_raw
   ADD CONSTRAINT work_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE work_tag
   ADD CONSTRAINT work_tag_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_tag
   ADD CONSTRAINT work_tag_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE work_tag_raw
   ADD CONSTRAINT work_tag_raw_fk_tag
   FOREIGN KEY (tag)
   REFERENCES tag(id);

ALTER TABLE work_type
   ADD CONSTRAINT work_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_type(id);

