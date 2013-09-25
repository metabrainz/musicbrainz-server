\set ON_ERROR_STOP 1
BEGIN;

------------------
-- foreign keys --
------------------
-- intrinsic to tables
ALTER TABLE artist ADD CONSTRAINT artist_fk_type FOREIGN KEY (type) REFERENCES artist_type(id);
ALTER TABLE artist ADD CONSTRAINT artist_fk_area FOREIGN KEY (area) REFERENCES area(id);
ALTER TABLE artist ADD CONSTRAINT artist_fk_gender FOREIGN KEY (gender) REFERENCES gender(id);
ALTER TABLE artist ADD CONSTRAINT artist_fk_begin_area FOREIGN KEY (begin_area) REFERENCES area(id);
ALTER TABLE artist ADD CONSTRAINT artist_fk_end_area FOREIGN KEY (end_area) REFERENCES area(id);

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_type FOREIGN KEY (type) REFERENCES artist_alias_type(id);

ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_fk_artist_credit FOREIGN KEY (artist_credit) REFERENCES artist_credit(id) ON DELETE CASCADE;
ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_fk_artist FOREIGN KEY (artist) REFERENCES artist(id) ON DELETE CASCADE;

ALTER TABLE label ADD CONSTRAINT label_fk_type FOREIGN KEY (type) REFERENCES label_type(id);
ALTER TABLE label ADD CONSTRAINT label_fk_area FOREIGN KEY (area) REFERENCES area(id);

ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_type FOREIGN KEY (type) REFERENCES label_alias_type(id);

ALTER TABLE recording ADD CONSTRAINT recording_fk_artist_credit FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE release ADD CONSTRAINT release_fk_artist_credit FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);
ALTER TABLE release ADD CONSTRAINT release_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release ADD CONSTRAINT release_fk_status FOREIGN KEY (status) REFERENCES release_status(id);
ALTER TABLE release ADD CONSTRAINT release_fk_packaging FOREIGN KEY (packaging) REFERENCES release_packaging(id);
ALTER TABLE release ADD CONSTRAINT release_fk_language FOREIGN KEY (language) REFERENCES language(id);
ALTER TABLE release ADD CONSTRAINT release_fk_script FOREIGN KEY (script) REFERENCES script(id);

ALTER TABLE release_group ADD CONSTRAINT release_group_fk_artist_credit FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);
ALTER TABLE release_group ADD CONSTRAINT release_group_fk_type FOREIGN KEY (type) REFERENCES release_group_primary_type(id);

ALTER TABLE track ADD CONSTRAINT track_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE track ADD CONSTRAINT track_fk_medium FOREIGN KEY (medium) REFERENCES medium(id);
ALTER TABLE track ADD CONSTRAINT track_fk_artist_credit FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE work ADD CONSTRAINT work_fk_type FOREIGN KEY (type) REFERENCES work_type(id);
ALTER TABLE work ADD CONSTRAINT work_fk_language FOREIGN KEY (language) REFERENCES language(id);

ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_type FOREIGN KEY (type) REFERENCES work_alias_type(id);

-- artist
ALTER TABLE artist_annotation ADD CONSTRAINT artist_annotation_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_gid_redirect ADD CONSTRAINT artist_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES artist(id);
ALTER TABLE artist_ipi ADD CONSTRAINT artist_ipi_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_isni ADD CONSTRAINT artist_isni_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_meta ADD CONSTRAINT artist_meta_fk_id FOREIGN KEY (id) REFERENCES artist(id) ON DELETE CASCADE;
ALTER TABLE artist_rating_raw ADD CONSTRAINT artist_rating_raw_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_tag ADD CONSTRAINT artist_tag_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE artist_tag_raw ADD CONSTRAINT artist_tag_raw_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE edit_artist ADD CONSTRAINT edit_artist_fk_artist FOREIGN KEY (artist) REFERENCES artist(id) ON DELETE CASCADE;
ALTER TABLE editor_subscribe_artist ADD CONSTRAINT editor_subscribe_artist_fk_artist FOREIGN KEY (artist) REFERENCES artist(id);
ALTER TABLE editor_watch_artist ADD CONSTRAINT editor_watch_artist_fk_artist FOREIGN KEY (artist) REFERENCES artist(id) ON DELETE CASCADE;

ALTER TABLE l_area_artist ADD CONSTRAINT l_area_artist_fk_entity1 FOREIGN KEY (entity1) REFERENCES artist(id);
ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_artist ADD CONSTRAINT l_artist_artist_fk_entity1 FOREIGN KEY (entity1) REFERENCES artist(id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_url ADD CONSTRAINT l_artist_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES artist(id);
-- artist_alias (no FKs)

-- artist_credit (all done above)
-- artist_credit_name (no FKs)

-- label
ALTER TABLE edit_label ADD CONSTRAINT edit_label_fk_label FOREIGN KEY (label) REFERENCES label(id) ON DELETE CASCADE;
ALTER TABLE editor_subscribe_label ADD CONSTRAINT editor_subscribe_label_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_annotation ADD CONSTRAINT label_annotation_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_gid_redirect ADD CONSTRAINT label_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES label(id);
ALTER TABLE label_ipi ADD CONSTRAINT label_ipi_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_isni ADD CONSTRAINT label_isni_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_meta ADD CONSTRAINT label_meta_fk_id FOREIGN KEY (id) REFERENCES label(id) ON DELETE CASCADE;
ALTER TABLE label_rating_raw ADD CONSTRAINT label_rating_raw_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_tag ADD CONSTRAINT label_tag_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE label_tag_raw ADD CONSTRAINT label_tag_raw_fk_label FOREIGN KEY (label) REFERENCES label(id);
ALTER TABLE release_label ADD CONSTRAINT release_label_fk_label FOREIGN KEY (label) REFERENCES label(id);

ALTER TABLE l_area_label ADD CONSTRAINT l_area_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);
ALTER TABLE l_artist_label ADD CONSTRAINT l_artist_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_label ADD CONSTRAINT l_label_label_fk_entity1 FOREIGN KEY (entity1) REFERENCES label(id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_url ADD CONSTRAINT l_label_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES label(id);
-- label_alias (no FKs)

-- release
ALTER TABLE edit_release ADD CONSTRAINT edit_release_fk_release FOREIGN KEY (release) REFERENCES release(id) ON DELETE CASCADE;
ALTER TABLE editor_collection_release ADD CONSTRAINT editor_collection_release_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE medium ADD CONSTRAINT medium_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_annotation ADD CONSTRAINT release_annotation_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_country ADD CONSTRAINT release_country_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_coverart ADD CONSTRAINT release_coverart_fk_id FOREIGN KEY (id) REFERENCES release(id) ON DELETE CASCADE;
ALTER TABLE release_gid_redirect ADD CONSTRAINT release_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES release(id);
ALTER TABLE release_label ADD CONSTRAINT release_label_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_meta ADD CONSTRAINT release_meta_fk_id FOREIGN KEY (id) REFERENCES release(id) ON DELETE CASCADE;
ALTER TABLE release_tag ADD CONSTRAINT release_tag_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_tag_raw ADD CONSTRAINT release_tag_raw_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE release_unknown_country ADD CONSTRAINT release_unknown_country_fk_release FOREIGN KEY (release) REFERENCES release(id);
ALTER TABLE cover_art_archive.cover_art ADD CONSTRAINT cover_art_fk_release FOREIGN KEY (release) REFERENCES musicbrainz.release(id) ON DELETE CASCADE;
ALTER TABLE cover_art_archive.release_group_cover_art ADD CONSTRAINT release_group_cover_art_fk_release FOREIGN KEY (release) REFERENCES musicbrainz.release(id);

ALTER TABLE l_area_release ADD CONSTRAINT l_area_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_artist_release ADD CONSTRAINT l_artist_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_label_release ADD CONSTRAINT l_label_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_release ADD CONSTRAINT l_release_release_fk_entity1 FOREIGN KEY (entity1) REFERENCES release(id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_url ADD CONSTRAINT l_release_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES release(id);

-- release_group
ALTER TABLE edit_release_group ADD CONSTRAINT edit_release_group_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id) ON DELETE CASCADE;
ALTER TABLE release_group_annotation ADD CONSTRAINT release_group_annotation_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release_group_gid_redirect ADD CONSTRAINT release_group_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES release_group(id);
ALTER TABLE release_group_meta ADD CONSTRAINT release_group_meta_fk_id FOREIGN KEY (id) REFERENCES release_group(id) ON DELETE CASCADE;
ALTER TABLE release_group_rating_raw ADD CONSTRAINT release_group_rating_raw_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release_group_secondary_type_join ADD CONSTRAINT release_group_secondary_type_join_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release_group_tag ADD CONSTRAINT release_group_tag_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE release_group_tag_raw ADD CONSTRAINT release_group_tag_raw_fk_release_group FOREIGN KEY (release_group) REFERENCES release_group(id);
ALTER TABLE cover_art_archive.release_group_cover_art ADD CONSTRAINT release_group_cover_art_fk_release_group FOREIGN KEY (release_group) REFERENCES musicbrainz.release_group(id);

ALTER TABLE l_area_release_group ADD CONSTRAINT l_area_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_artist_release_group ADD CONSTRAINT l_artist_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_label_release_group ADD CONSTRAINT l_label_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_release_group ADD CONSTRAINT l_release_group_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);
ALTER TABLE l_release_group_url ADD CONSTRAINT l_release_group_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES release_group(id);
ALTER TABLE l_release_release_group ADD CONSTRAINT l_release_release_group_fk_entity1 FOREIGN KEY (entity1) REFERENCES release_group(id);

-- recording
ALTER TABLE edit_recording ADD CONSTRAINT edit_recording_fk_recording FOREIGN KEY (recording) REFERENCES recording(id) ON DELETE CASCADE;
ALTER TABLE isrc ADD CONSTRAINT isrc_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE recording_annotation ADD CONSTRAINT recording_annotation_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE recording_gid_redirect ADD CONSTRAINT recording_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES recording(id);
ALTER TABLE recording_meta ADD CONSTRAINT recording_meta_fk_id FOREIGN KEY (id) REFERENCES recording(id) ON DELETE CASCADE;
ALTER TABLE recording_rating_raw ADD CONSTRAINT recording_rating_raw_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE recording_tag ADD CONSTRAINT recording_tag_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);
ALTER TABLE recording_tag_raw ADD CONSTRAINT recording_tag_raw_fk_recording FOREIGN KEY (recording) REFERENCES recording(id);

ALTER TABLE l_area_recording ADD CONSTRAINT l_area_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_artist_recording ADD CONSTRAINT l_artist_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_label_recording ADD CONSTRAINT l_label_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_recording ADD CONSTRAINT l_recording_recording_fk_entity1 FOREIGN KEY (entity1) REFERENCES recording(id);
ALTER TABLE l_recording_release ADD CONSTRAINT l_recording_release_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_release_group ADD CONSTRAINT l_recording_release_group_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_url ADD CONSTRAINT l_recording_url_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES recording(id);

-- track
ALTER TABLE track_gid_redirect ADD CONSTRAINT track_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES track(id);

-- work
ALTER TABLE edit_work ADD CONSTRAINT edit_work_fk_work FOREIGN KEY (work) REFERENCES work(id) ON DELETE CASCADE;
ALTER TABLE iswc ADD CONSTRAINT iswc_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_annotation ADD CONSTRAINT work_annotation_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_attribute ADD CONSTRAINT work_attribute_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_gid_redirect ADD CONSTRAINT work_gid_redirect_fk_new_id FOREIGN KEY (new_id) REFERENCES work(id);
ALTER TABLE work_meta ADD CONSTRAINT work_meta_fk_id FOREIGN KEY (id) REFERENCES work(id) ON DELETE CASCADE;
ALTER TABLE work_rating_raw ADD CONSTRAINT work_rating_raw_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_tag ADD CONSTRAINT work_tag_fk_work FOREIGN KEY (work) REFERENCES work(id);
ALTER TABLE work_tag_raw ADD CONSTRAINT work_tag_raw_fk_work FOREIGN KEY (work) REFERENCES work(id);

ALTER TABLE l_area_work ADD CONSTRAINT l_area_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_artist_work ADD CONSTRAINT l_artist_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_label_work ADD CONSTRAINT l_label_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_recording_work ADD CONSTRAINT l_recording_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_release_group_work ADD CONSTRAINT l_release_group_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_release_work ADD CONSTRAINT l_release_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_url_work ADD CONSTRAINT l_url_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_fk_entity0 FOREIGN KEY (entity0) REFERENCES work(id);
ALTER TABLE l_work_work ADD CONSTRAINT l_work_work_fk_entity1 FOREIGN KEY (entity1) REFERENCES work(id);
-- work_alias (no FKs)

-- artist_deletion
ALTER TABLE editor_subscribe_artist_deleted ADD CONSTRAINT editor_subscribe_artist_deleted_fk_gid FOREIGN KEY (gid) REFERENCES artist_deletion(gid);

-- label_deletion
ALTER TABLE editor_subscribe_label_deleted ADD CONSTRAINT editor_subscribe_label_deleted_fk_gid FOREIGN KEY (gid) REFERENCES label_deletion(gid);

-----------------
-- constraints --
-----------------
ALTER TABLE artist        ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE label         ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE recording     ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release       ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE release_group ADD CHECK (controlled_for_whitespace(comment));
ALTER TABLE track         ADD CHECK (controlled_for_whitespace(number));
ALTER TABLE work          ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE artist
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist_credit
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE artist_credit_name
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE label
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE label_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE release
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE release_group
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE track
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE recording
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE work
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE work_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE artist
ADD CONSTRAINT group_type_implies_null_gender CHECK (
  (gender IS NULL AND type = 2)
  OR type IS DISTINCT FROM 2
);

ALTER TABLE artist ADD CONSTRAINT artist_va_check
    CHECK (id <> 1 OR
           (type = 3 AND
            gender IS NULL AND
            area IS NULL AND
            begin_area IS NULL AND
            end_area IS NULL AND
            begin_date_year IS NULL AND
            begin_date_month IS NULL AND
            begin_date_day IS NULL AND
            end_date_year IS NULL AND
            end_date_month IS NULL AND
            end_date_day IS NULL));

--------------
-- triggers --
--------------

CREATE TRIGGER a_ins_artist AFTER INSERT ON artist FOR EACH ROW EXECUTE PROCEDURE a_ins_artist();
CREATE TRIGGER b_upd_artist BEFORE UPDATE ON artist FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE TRIGGER b_del_artist_special BEFORE DELETE ON artist FOR EACH ROW WHEN (OLD.id IN (1, 2)) EXECUTE PROCEDURE deny_special_purpose_deletion();
CREATE TRIGGER end_area_implies_ended BEFORE UPDATE OR INSERT ON artist FOR EACH ROW EXECUTE PROCEDURE end_area_implies_ended();
CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON artist FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_artist_alias BEFORE UPDATE ON artist_alias FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON artist_alias FOR EACH ROW EXECUTE PROCEDURE unique_primary_artist_alias();
CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON artist_alias FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(3);

CREATE TRIGGER a_ins_label AFTER INSERT ON label FOR EACH ROW EXECUTE PROCEDURE a_ins_label();
CREATE TRIGGER b_del_label_special BEFORE DELETE ON label FOR EACH ROW WHEN (OLD.id = 1) EXECUTE PROCEDURE deny_special_purpose_deletion();
CREATE TRIGGER b_upd_label BEFORE UPDATE ON label FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON label FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_label_alias BEFORE UPDATE ON label_alias FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON label_alias FOR EACH ROW EXECUTE PROCEDURE unique_primary_label_alias();
CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON label_alias FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE TRIGGER a_ins_recording AFTER INSERT ON recording FOR EACH ROW EXECUTE PROCEDURE a_ins_recording();
CREATE TRIGGER a_upd_recording AFTER UPDATE ON recording FOR EACH ROW EXECUTE PROCEDURE a_upd_recording();
CREATE TRIGGER a_del_recording AFTER DELETE ON recording FOR EACH ROW EXECUTE PROCEDURE a_del_recording();
CREATE TRIGGER b_upd_recording BEFORE UPDATE ON recording FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER a_ins_release AFTER INSERT ON release FOR EACH ROW EXECUTE PROCEDURE a_ins_release();
CREATE TRIGGER a_upd_release AFTER UPDATE ON release FOR EACH ROW EXECUTE PROCEDURE a_upd_release();
CREATE TRIGGER a_del_release AFTER DELETE ON release FOR EACH ROW EXECUTE PROCEDURE a_del_release();
CREATE TRIGGER b_upd_release BEFORE UPDATE ON release FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER a_ins_release_group AFTER INSERT ON release_group FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group();
CREATE TRIGGER a_upd_release_group AFTER UPDATE ON release_group FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group();
CREATE TRIGGER a_del_release_group AFTER DELETE ON release_group FOR EACH ROW EXECUTE PROCEDURE a_del_release_group();
CREATE TRIGGER b_upd_release_group BEFORE UPDATE ON release_group FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER a_ins_track AFTER INSERT ON track FOR EACH ROW EXECUTE PROCEDURE a_ins_track();
CREATE TRIGGER a_upd_track AFTER UPDATE ON track FOR EACH ROW EXECUTE PROCEDURE a_upd_track();
CREATE TRIGGER a_del_track AFTER DELETE ON track FOR EACH ROW EXECUTE PROCEDURE a_del_track();
CREATE TRIGGER b_upd_track BEFORE UPDATE ON track FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE CONSTRAINT TRIGGER remove_orphaned_tracks AFTER DELETE OR UPDATE ON track DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE delete_orphaned_recordings();

CREATE TRIGGER a_ins_work AFTER INSERT ON work FOR EACH ROW EXECUTE PROCEDURE a_ins_work();
CREATE TRIGGER b_upd_work BEFORE UPDATE ON work FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_work_alias BEFORE UPDATE ON work_alias FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();
CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON work_alias FOR EACH ROW EXECUTE PROCEDURE unique_primary_work_alias();
CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON work_alias FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

COMMIT;
