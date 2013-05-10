-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

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

ALTER TABLE area_annotation
   ADD CONSTRAINT area_annotation_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE area_annotation
   ADD CONSTRAINT area_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE area_gid_redirect
   ADD CONSTRAINT area_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES area(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_name
   FOREIGN KEY (name)
   REFERENCES artist_name(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_sort_name
   FOREIGN KEY (sort_name)
   REFERENCES artist_name(id);

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
   ADD CONSTRAINT artist_alias_fk_name
   FOREIGN KEY (name)
   REFERENCES artist_name(id);

ALTER TABLE artist_alias
   ADD CONSTRAINT artist_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES artist_alias_type(id);

ALTER TABLE artist_alias
   ADD CONSTRAINT artist_alias_fk_sort_name
   FOREIGN KEY (sort_name)
   REFERENCES artist_name(id);

ALTER TABLE artist_annotation
   ADD CONSTRAINT artist_annotation_fk_artist
   FOREIGN KEY (artist)
   REFERENCES artist(id);

ALTER TABLE artist_annotation
   ADD CONSTRAINT artist_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE artist_credit
   ADD CONSTRAINT artist_credit_fk_name
   FOREIGN KEY (name)
   REFERENCES artist_name(id);

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

ALTER TABLE artist_credit_name
   ADD CONSTRAINT artist_credit_name_fk_name
   FOREIGN KEY (name)
   REFERENCES artist_name(id);

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

ALTER TABLE editor_collection_release
   ADD CONSTRAINT editor_collection_release_fk_collection
   FOREIGN KEY (collection)
   REFERENCES editor_collection(id);

ALTER TABLE editor_collection_release
   ADD CONSTRAINT editor_collection_release_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

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
   ADD CONSTRAINT label_fk_name
   FOREIGN KEY (name)
   REFERENCES label_name(id);

ALTER TABLE label
   ADD CONSTRAINT label_fk_sort_name
   FOREIGN KEY (sort_name)
   REFERENCES label_name(id);

ALTER TABLE label
   ADD CONSTRAINT label_fk_area
   FOREIGN KEY (area)
   REFERENCES area(id);

ALTER TABLE label
   ADD CONSTRAINT label_fk_type
   FOREIGN KEY (type)
   REFERENCES label_type(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_name
   FOREIGN KEY (name)
   REFERENCES label_name(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES label_alias_type(id);

ALTER TABLE label_alias
   ADD CONSTRAINT label_alias_fk_sort_name
   FOREIGN KEY (sort_name)
   REFERENCES label_name(id);

ALTER TABLE label_annotation
   ADD CONSTRAINT label_annotation_fk_label
   FOREIGN KEY (label)
   REFERENCES label(id);

ALTER TABLE label_annotation
   ADD CONSTRAINT label_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

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

ALTER TABLE puid
   ADD CONSTRAINT puid_fk_version
   FOREIGN KEY (version)
   REFERENCES clientversion(id);

ALTER TABLE recording
   ADD CONSTRAINT recording_fk_name
   FOREIGN KEY (name)
   REFERENCES track_name(id);

ALTER TABLE recording
   ADD CONSTRAINT recording_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE recording_annotation
   ADD CONSTRAINT recording_annotation_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

ALTER TABLE recording_annotation
   ADD CONSTRAINT recording_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE recording_gid_redirect
   ADD CONSTRAINT recording_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES recording(id);

ALTER TABLE recording_meta
   ADD CONSTRAINT recording_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES recording(id)
   ON DELETE CASCADE;

ALTER TABLE recording_puid
   ADD CONSTRAINT recording_puid_fk_puid
   FOREIGN KEY (puid)
   REFERENCES puid(id);

ALTER TABLE recording_puid
   ADD CONSTRAINT recording_puid_fk_recording
   FOREIGN KEY (recording)
   REFERENCES recording(id);

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
   ADD CONSTRAINT release_fk_name
   FOREIGN KEY (name)
   REFERENCES release_name(id);

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

ALTER TABLE release_annotation
   ADD CONSTRAINT release_annotation_fk_release
   FOREIGN KEY (release)
   REFERENCES release(id);

ALTER TABLE release_annotation
   ADD CONSTRAINT release_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

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
   ADD CONSTRAINT release_group_fk_name
   FOREIGN KEY (name)
   REFERENCES release_name(id);

ALTER TABLE release_group
   ADD CONSTRAINT release_group_fk_artist_credit
   FOREIGN KEY (artist_credit)
   REFERENCES artist_credit(id);

ALTER TABLE release_group
   ADD CONSTRAINT release_group_fk_type
   FOREIGN KEY (type)
   REFERENCES release_group_primary_type(id);

ALTER TABLE release_group_annotation
   ADD CONSTRAINT release_group_annotation_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_annotation
   ADD CONSTRAINT release_group_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE release_group_gid_redirect
   ADD CONSTRAINT release_group_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES release_group(id);

ALTER TABLE release_group_meta
   ADD CONSTRAINT release_group_meta_fk_id
   FOREIGN KEY (id)
   REFERENCES release_group(id)
   ON DELETE CASCADE;

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_release_group
   FOREIGN KEY (release_group)
   REFERENCES release_group(id);

ALTER TABLE release_group_rating_raw
   ADD CONSTRAINT release_group_rating_raw_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

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

ALTER TABLE script_language
   ADD CONSTRAINT script_language_fk_script
   FOREIGN KEY (script)
   REFERENCES script(id);

ALTER TABLE script_language
   ADD CONSTRAINT script_language_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

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
   ADD CONSTRAINT track_fk_name
   FOREIGN KEY (name)
   REFERENCES track_name(id);

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
   ADD CONSTRAINT work_fk_name
   FOREIGN KEY (name)
   REFERENCES work_name(id);

ALTER TABLE work
   ADD CONSTRAINT work_fk_type
   FOREIGN KEY (type)
   REFERENCES work_type(id);

ALTER TABLE work
   ADD CONSTRAINT work_fk_language
   FOREIGN KEY (language)
   REFERENCES language(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_name
   FOREIGN KEY (name)
   REFERENCES work_name(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES work_alias_type(id);

ALTER TABLE work_alias
   ADD CONSTRAINT work_alias_fk_sort_name
   FOREIGN KEY (sort_name)
   REFERENCES work_name(id);

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

ALTER TABLE work_attribute_type_allowed_value
   ADD CONSTRAINT work_attribute_type_allowed_value_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_gid_redirect
   ADD CONSTRAINT work_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES work(id);

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

