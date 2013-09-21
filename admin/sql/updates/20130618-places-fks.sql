BEGIN;

ALTER TABLE edit_place
   ADD CONSTRAINT edit_place_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_place
   ADD CONSTRAINT edit_place_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id)
   ON DELETE CASCADE;

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

ALTER TABLE place_annotation
   ADD CONSTRAINT place_annotation_fk_place
   FOREIGN KEY (place)
   REFERENCES place(id);

ALTER TABLE place_annotation
   ADD CONSTRAINT place_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

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

ALTER TABLE place         ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE place
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE place_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

CREATE TRIGGER b_upd_l_area_place BEFORE UPDATE ON l_area_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_artist_place BEFORE UPDATE ON l_artist_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_label_place BEFORE UPDATE ON l_label_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_place BEFORE UPDATE ON l_place_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_recording BEFORE UPDATE ON l_place_recording
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_release BEFORE UPDATE ON l_place_release
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_release_group BEFORE UPDATE ON l_place_release_group
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_url BEFORE UPDATE ON l_place_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_place_work BEFORE UPDATE ON l_place_work
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_place BEFORE UPDATE ON place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON place
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON place_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_place_alias BEFORE UPDATE ON place_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON place_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_place_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON place_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE TRIGGER b_upd_place_tag BEFORE UPDATE ON place_tag
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

COMMIT;
