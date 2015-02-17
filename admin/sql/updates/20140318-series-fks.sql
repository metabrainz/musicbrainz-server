\set ON_ERROR_STOP 1
BEGIN;

------------------
-- constraints  --
------------------

ALTER TABLE series ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE link_attribute_text_value
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(text_value)),
  ADD CONSTRAINT only_non_empty CHECK (text_value != '');

ALTER TABLE series
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE series_type ADD CONSTRAINT allowed_series_entity_type
  CHECK (
    entity_type IN (
      'recording',
      'release',
      'release_group',
      'work'
    )
  );

------------------
-- foreign keys --
------------------

ALTER TABLE documentation.l_area_series_example ADD CONSTRAINT l_area_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_area_series(id);
ALTER TABLE documentation.l_artist_series_example ADD CONSTRAINT l_artist_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_artist_series(id);
ALTER TABLE documentation.l_instrument_series_example ADD CONSTRAINT l_instrument_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_instrument_series(id);
ALTER TABLE documentation.l_label_series_example ADD CONSTRAINT l_label_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_label_series(id);
ALTER TABLE documentation.l_place_series_example ADD CONSTRAINT l_place_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_place_series(id);
ALTER TABLE documentation.l_recording_series_example ADD CONSTRAINT l_recording_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_recording_series(id);
ALTER TABLE documentation.l_release_group_series_example ADD CONSTRAINT l_release_group_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_release_group_series(id);
ALTER TABLE documentation.l_release_series_example ADD CONSTRAINT l_release_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_release_series(id);
ALTER TABLE documentation.l_series_series_example ADD CONSTRAINT l_series_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_series_series(id);
ALTER TABLE documentation.l_series_url_example ADD CONSTRAINT l_series_url_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_series_url(id);
ALTER TABLE documentation.l_series_work_example ADD CONSTRAINT l_series_work_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_series_work(id);

ALTER TABLE editor_subscribe_series ADD CONSTRAINT editor_subscribe_series_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE editor_subscribe_series ADD CONSTRAINT editor_subscribe_series_fk_series FOREIGN KEY (series) REFERENCES series(id);
ALTER TABLE editor_subscribe_series ADD CONSTRAINT editor_subscribe_series_fk_last_edit_sent FOREIGN KEY (last_edit_sent) REFERENCES edit(id);

ALTER TABLE editor_subscribe_series_deleted ADD CONSTRAINT editor_subscribe_series_deleted_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE editor_subscribe_series_deleted ADD CONSTRAINT editor_subscribe_series_deleted_fk_gid FOREIGN KEY (gid) REFERENCES series_deletion(gid);
ALTER TABLE editor_subscribe_series_deleted ADD CONSTRAINT editor_subscribe_series_deleted_fk_deleted_by FOREIGN KEY (deleted_by) REFERENCES edit(id);

ALTER TABLE l_area_series ADD CONSTRAINT l_area_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_area_series ADD CONSTRAINT l_area_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES area(id);
ALTER TABLE l_area_series ADD CONSTRAINT l_area_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_artist_series ADD CONSTRAINT l_artist_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_series ADD CONSTRAINT l_artist_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_series ADD CONSTRAINT l_artist_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_instrument_series ADD CONSTRAINT l_instrument_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_instrument_series ADD CONSTRAINT l_instrument_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES instrument(id);
ALTER TABLE l_instrument_series ADD CONSTRAINT l_instrument_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_label_series ADD CONSTRAINT l_label_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_label_series ADD CONSTRAINT l_label_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_series ADD CONSTRAINT l_label_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_place_series ADD CONSTRAINT l_place_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_place_series ADD CONSTRAINT l_place_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES place(id);
ALTER TABLE l_place_series ADD CONSTRAINT l_place_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_recording_series ADD CONSTRAINT l_recording_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_recording_series ADD CONSTRAINT l_recording_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_series ADD CONSTRAINT l_recording_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_release_group_series ADD CONSTRAINT l_release_group_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_group_series ADD CONSTRAINT l_release_group_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_series ADD CONSTRAINT l_release_group_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_release_series ADD CONSTRAINT l_release_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_release_series ADD CONSTRAINT l_release_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_series ADD CONSTRAINT l_release_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_series_series ADD CONSTRAINT l_series_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_series_series ADD CONSTRAINT l_series_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES series(id);
ALTER TABLE l_series_series ADD CONSTRAINT l_series_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_series_url ADD CONSTRAINT l_series_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_series_url ADD CONSTRAINT l_series_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES series(id);
ALTER TABLE l_series_url ADD CONSTRAINT l_series_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);

ALTER TABLE l_series_work ADD CONSTRAINT l_series_work_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_series_work ADD CONSTRAINT l_series_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES series(id);
ALTER TABLE l_series_work ADD CONSTRAINT l_series_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);

ALTER TABLE link_attribute_text_value ADD CONSTRAINT link_attribute_text_value_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE link_attribute_text_value ADD CONSTRAINT link_attribute_text_value_fk_attribute_type FOREIGN KEY (attribute_type) REFERENCES link_text_attribute_type(attribute_type);
ALTER TABLE link_text_attribute_type ADD CONSTRAINT link_text_attribute_type_fk_attribute_type FOREIGN KEY (attribute_type) REFERENCES link_attribute_type(id) ON DELETE CASCADE;

ALTER TABLE orderable_link_type ADD CONSTRAINT orderable_link_type_fk_link_type FOREIGN KEY (link_type) REFERENCES link_type(id);

ALTER TABLE series ADD CONSTRAINT series_fk_type FOREIGN KEY (type) REFERENCES series_type(id);
ALTER TABLE series ADD CONSTRAINT series_fk_ordering_attribute FOREIGN KEY (ordering_attribute) REFERENCES link_text_attribute_type(attribute_type);
ALTER TABLE series ADD CONSTRAINT series_fk_ordering_type FOREIGN KEY (ordering_type) REFERENCES series_ordering_type(id);

ALTER TABLE series_alias ADD CONSTRAINT series_alias_fk_series FOREIGN KEY (series) REFERENCES series(id);
ALTER TABLE series_alias ADD CONSTRAINT series_alias_fk_type FOREIGN KEY (type) REFERENCES series_alias_type(id);

ALTER TABLE series_annotation ADD CONSTRAINT series_annotation_fk_series FOREIGN KEY (series) REFERENCES series(id);
ALTER TABLE series_annotation ADD CONSTRAINT series_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);

ALTER TABLE series_gid_redirect ADD CONSTRAINT series_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES series(id);

ALTER TABLE series_ordering_type ADD CONSTRAINT series_ordering_type_fk_parent FOREIGN KEY (parent) REFERENCES series_ordering_type(id);

ALTER TABLE series_type ADD CONSTRAINT series_type_fk_parent FOREIGN KEY (parent) REFERENCES series_type(id);

COMMIT;
