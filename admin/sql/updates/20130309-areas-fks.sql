\set ON_ERROR_STOP 1
BEGIN;

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
   ADD CONSTRAINT artist_fk_begin_area
   FOREIGN KEY (begin_area)
   REFERENCES area(id);

ALTER TABLE artist
   ADD CONSTRAINT artist_fk_end_area
   FOREIGN KEY (end_area)
   REFERENCES area(id);

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
   REFERENCES area(id);

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

-- MIGRATIONS --
-- releases
ALTER TABLE release_country ADD CONSTRAINT release_country_fk_country FOREIGN KEY (country) REFERENCES country_area(area);

-- editors
ALTER TABLE editor ADD CONSTRAINT editor_fk_area FOREIGN KEY (area) REFERENCES area(id);

-- artists
ALTER TABLE artist ADD CONSTRAINT artist_fk_area FOREIGN KEY (area) REFERENCES area(id);

-- labels
ALTER TABLE label ADD CONSTRAINT label_fk_area FOREIGN KEY (area) REFERENCES area(id);

CREATE OR REPLACE FUNCTION unique_primary_area_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE area_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND area = NEW.area;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER b_upd_area BEFORE UPDATE ON area
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_area_alias BEFORE UPDATE ON area_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON area_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_area_alias();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON area
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_l_area_area BEFORE UPDATE ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_artist BEFORE UPDATE ON l_area_artist
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_label BEFORE UPDATE ON l_area_label
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_recording BEFORE UPDATE ON l_area_recording
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_release BEFORE UPDATE ON l_area_release
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_release_group BEFORE UPDATE ON l_area_release_group
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_url BEFORE UPDATE ON l_area_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_area_work BEFORE UPDATE ON l_area_work
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

COMMIT;
