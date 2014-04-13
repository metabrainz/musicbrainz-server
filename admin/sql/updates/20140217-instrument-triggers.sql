\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION a_ins_instrument() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO link_attribute_type (parent, root, child_order, gid, name, description) VALUES (14, 14, 0, NEW.gid, NEW.name, NEW.description);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_upd_instrument() RETURNS TRIGGER AS $$
BEGIN
    UPDATE link_attribute_type SET name = NEW.name, description = NEW.description WHERE gid = NEW.gid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_del_instrument() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM link_attribute_type WHERE gid = OLD.gid;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_ins_instrument AFTER INSERT ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_ins_instrument();

CREATE TRIGGER a_upd_instrument AFTER UPDATE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_upd_instrument();

CREATE TRIGGER a_del_instrument AFTER DELETE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_del_instrument();


ALTER TABLE instrument ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE instrument
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),

ALTER TABLE instrument_alias
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != ''),
  ADD CONSTRAINT control_for_whitespace_sort_name CHECK (controlled_for_whitespace(sort_name)),
  ADD CONSTRAINT only_non_empty_sort_name CHECK (sort_name != '');

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_instrument
   ADD CONSTRAINT edit_instrument_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id)
   ON DELETE CASCADE;

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

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_instrument
   FOREIGN KEY (instrument)
   REFERENCES instrument(id);

ALTER TABLE instrument_annotation
   ADD CONSTRAINT instrument_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);

ALTER TABLE instrument_gid_redirect
   ADD CONSTRAINT instrument_gid_redirect_fk_new_id
   FOREIGN KEY (new_id)
   REFERENCES instrument(id);

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

COMMIT;
