\set ON_ERROR_STOP 1
BEGIN;

------------------
-- constraints  --
------------------

ALTER TABLE event ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE event
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE event_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE series_type ADD CONSTRAINT allowed_series_entity_type
  CHECK (
    entity_type IN (
      'event',
      'recording',
      'release',
      'release_group',
      'work'
    )
  );

------------------
-- foreign keys --
------------------

ALTER TABLE documentation.l_area_event_example ADD CONSTRAINT l_area_event_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_area_event(id);
ALTER TABLE documentation.l_artist_event_example ADD CONSTRAINT l_artist_event_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_artist_event(id);
ALTER TABLE documentation.l_event_event_example ADD CONSTRAINT l_event_event_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_event(id);
ALTER TABLE documentation.l_event_instrument_example ADD CONSTRAINT l_event_instrument_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_instrument(id);
ALTER TABLE documentation.l_event_label_example ADD CONSTRAINT l_event_label_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_label(id);
ALTER TABLE documentation.l_event_place_example ADD CONSTRAINT l_event_place_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_place(id);
ALTER TABLE documentation.l_event_recording_example ADD CONSTRAINT l_event_recording_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_recording(id);
ALTER TABLE documentation.l_event_release_group_example ADD CONSTRAINT l_event_release_group_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_release_group(id);
ALTER TABLE documentation.l_event_release_example ADD CONSTRAINT l_event_release_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_release(id);
ALTER TABLE documentation.l_event_series_example ADD CONSTRAINT l_event_series_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_series(id);
ALTER TABLE documentation.l_event_url_example ADD CONSTRAINT l_event_url_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_url(id);
ALTER TABLE documentation.l_event_work_example ADD CONSTRAINT l_event_work_example_fk_id FOREIGN KEY (id) REFERENCES musicbrainz.l_event_work(id);

ALTER TABLE l_area_event ADD CONSTRAINT l_area_event_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_area_event ADD CONSTRAINT l_area_event_fk_entity0 FOREIGN KEY (entity0) REFERENCES area(id);
ALTER TABLE l_area_event ADD CONSTRAINT l_area_event_fk_entity1 FOREIGN KEY (entity1) REFERENCES event(id);

ALTER TABLE l_artist_event ADD CONSTRAINT l_artist_event_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_artist_event ADD CONSTRAINT l_artist_event_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_event ADD CONSTRAINT l_artist_event_fk_entity1 FOREIGN KEY (entity1) REFERENCES event(id);

ALTER TABLE l_event_event ADD CONSTRAINT l_event_event_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_event ADD CONSTRAINT l_event_event_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_event ADD CONSTRAINT l_event_event_fk_entity1 FOREIGN KEY (entity1) REFERENCES event(id);

ALTER TABLE l_event_instrument ADD CONSTRAINT l_event_instrument_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_instrument ADD CONSTRAINT l_event_instrument_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_instrument ADD CONSTRAINT l_event_instrument_fk_entity1 FOREIGN KEY (entity1) REFERENCES instrument(id);

ALTER TABLE l_event_label ADD CONSTRAINT l_event_label_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_label ADD CONSTRAINT l_event_label_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_label ADD CONSTRAINT l_event_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);

ALTER TABLE l_event_place ADD CONSTRAINT l_event_place_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_place ADD CONSTRAINT l_event_place_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_place ADD CONSTRAINT l_event_place_fk_entity1 FOREIGN KEY (entity1) REFERENCES place(id);

ALTER TABLE l_event_recording ADD CONSTRAINT l_event_recording_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_recording ADD CONSTRAINT l_event_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_recording ADD CONSTRAINT l_event_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);

ALTER TABLE l_event_release ADD CONSTRAINT l_event_release_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_release ADD CONSTRAINT l_event_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_release ADD CONSTRAINT l_event_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);

ALTER TABLE l_event_release_group ADD CONSTRAINT l_event_release_group_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_release_group ADD CONSTRAINT l_event_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_release_group ADD CONSTRAINT l_event_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);

ALTER TABLE l_event_series ADD CONSTRAINT l_event_series_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_series ADD CONSTRAINT l_event_series_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_series ADD CONSTRAINT l_event_series_fk_entity1 FOREIGN KEY (entity1) REFERENCES series(id);

ALTER TABLE l_event_url ADD CONSTRAINT l_event_url_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_url ADD CONSTRAINT l_event_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_url ADD CONSTRAINT l_event_url_fk_entity1 FOREIGN KEY (entity1) REFERENCES url(id);

ALTER TABLE l_event_work ADD CONSTRAINT l_event_work_fk_link FOREIGN KEY (link) REFERENCES link(id);
ALTER TABLE l_event_work ADD CONSTRAINT l_event_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES event(id);
ALTER TABLE l_event_work ADD CONSTRAINT l_event_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);

ALTER TABLE edit_event ADD CONSTRAINT edit_event_fk_edit FOREIGN KEY (edit) REFERENCES edit(id);
ALTER TABLE edit_event ADD CONSTRAINT edit_event_fk_event FOREIGN KEY (event) REFERENCES event(id) ON DELETE CASCADE;

ALTER TABLE event ADD CONSTRAINT event_fk_type FOREIGN KEY (type) REFERENCES event_type(id);

ALTER TABLE event_alias ADD CONSTRAINT event_alias_fk_event FOREIGN KEY (event) REFERENCES event(id);
ALTER TABLE event_alias ADD CONSTRAINT event_alias_fk_type FOREIGN KEY (type) REFERENCES event_alias_type(id);

ALTER TABLE event_alias_type ADD CONSTRAINT event_alias_type_fk_parent FOREIGN KEY (parent) REFERENCES event_alias_type(id);

ALTER TABLE event_annotation ADD CONSTRAINT event_annotation_fk_event FOREIGN KEY (event) REFERENCES event(id);
ALTER TABLE event_annotation ADD CONSTRAINT event_annotation_fk_annotation FOREIGN KEY (annotation) REFERENCES annotation(id);

ALTER TABLE event_gid_redirect ADD CONSTRAINT event_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES event(id);

ALTER TABLE event_tag ADD CONSTRAINT event_tag_fk_event FOREIGN KEY (event) REFERENCES event(id);
ALTER TABLE event_tag ADD CONSTRAINT event_tag_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE event_tag_raw ADD CONSTRAINT event_tag_raw_fk_event FOREIGN KEY (event) REFERENCES event(id);
ALTER TABLE event_tag_raw ADD CONSTRAINT event_tag_raw_fk_editor FOREIGN KEY (editor) REFERENCES editor(id);
ALTER TABLE event_tag_raw ADD CONSTRAINT event_tag_raw_fk_tag FOREIGN KEY (tag) REFERENCES tag(id);

ALTER TABLE event_type ADD CONSTRAINT event_type_fk_parent FOREIGN KEY (parent) REFERENCES event_type(id);

--------------
-- triggers --
--------------

CREATE TRIGGER b_upd_event BEFORE UPDATE ON event
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON event
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_event_alias BEFORE UPDATE ON event_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON event_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON event_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_event_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON event_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE TRIGGER b_upd_event_tag BEFORE UPDATE ON event_tag
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

COMMIT;
