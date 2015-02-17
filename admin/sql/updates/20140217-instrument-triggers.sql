\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION a_ins_instrument() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO link_attribute_type (parent, root, child_order, gid, name, description) VALUES (14, 14, 0, NEW.gid, NEW.name, NEW.description);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_upd_instrument() RETURNS trigger AS $$
BEGIN
    UPDATE link_attribute_type SET name = NEW.name, description = NEW.description WHERE gid = NEW.gid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'no link_attribute_type found for instrument %', NEW.gid;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_del_instrument() RETURNS trigger AS $$
BEGIN
    DELETE FROM link_attribute_type WHERE gid = OLD.gid;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'no link_attribute_type found for instrument %', NEW.gid;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION unique_primary_instrument_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE instrument_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND instrument = NEW.instrument;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


ALTER TABLE instrument ADD CHECK (controlled_for_whitespace(comment));

ALTER TABLE instrument
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

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


CREATE TRIGGER b_upd_instrument BEFORE UPDATE ON instrument
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON instrument_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_instrument_alias BEFORE UPDATE ON instrument_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON instrument_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_instrument_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON instrument_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);
CREATE TRIGGER b_upd_l_area_instrument BEFORE UPDATE ON l_area_instrument
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_artist_instrument BEFORE UPDATE ON l_artist_instrument
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_instrument BEFORE UPDATE ON l_instrument_instrument
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_label BEFORE UPDATE ON l_instrument_label
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_place BEFORE UPDATE ON l_instrument_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_recording BEFORE UPDATE ON l_instrument_recording
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_release BEFORE UPDATE ON l_instrument_release
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_release_group BEFORE UPDATE ON l_instrument_release_group
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_url BEFORE UPDATE ON l_instrument_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_work BEFORE UPDATE ON l_instrument_work
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER a_ins_instrument AFTER INSERT ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_ins_instrument();

CREATE TRIGGER a_upd_instrument AFTER UPDATE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_upd_instrument();

CREATE TRIGGER a_del_instrument AFTER DELETE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_del_instrument();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_instrument DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();
CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_instrument DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

 CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_instrument DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_instrument_url
    AFTER UPDATE ON l_instrument_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_instrument_url
    AFTER DELETE ON l_instrument_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

ALTER TABLE documentation.l_area_instrument_example
   ADD CONSTRAINT l_area_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_instrument(id);

ALTER TABLE documentation.l_artist_instrument_example
   ADD CONSTRAINT l_artist_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_instrument(id);

ALTER TABLE documentation.l_instrument_instrument_example
   ADD CONSTRAINT l_instrument_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_instrument(id);

ALTER TABLE documentation.l_instrument_label_example
   ADD CONSTRAINT l_instrument_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_label(id);

ALTER TABLE documentation.l_instrument_place_example
   ADD CONSTRAINT l_instrument_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_place(id);

ALTER TABLE documentation.l_instrument_recording_example
   ADD CONSTRAINT l_instrument_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_recording(id);

ALTER TABLE documentation.l_instrument_release_example
   ADD CONSTRAINT l_instrument_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release(id);

ALTER TABLE documentation.l_instrument_release_group_example
   ADD CONSTRAINT l_instrument_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_release_group(id);

ALTER TABLE documentation.l_instrument_url_example
   ADD CONSTRAINT l_instrument_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_url(id);

ALTER TABLE documentation.l_instrument_work_example
   ADD CONSTRAINT l_instrument_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_instrument_work(id);

COMMIT;
