\set ON_ERROR_STOP 1

BEGIN;

-- FKs

ALTER TABLE edit_mood
   ADD CONSTRAINT edit_mood_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_mood
   ADD CONSTRAINT edit_mood_fk_mood
   FOREIGN KEY (mood)
   REFERENCES mood(id)
   ON DELETE CASCADE;

ALTER TABLE l_area_mood
   ADD CONSTRAINT l_area_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_mood
   ADD CONSTRAINT l_area_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_mood
   ADD CONSTRAINT l_area_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_artist_mood
   ADD CONSTRAINT l_artist_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_mood
   ADD CONSTRAINT l_artist_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_mood
   ADD CONSTRAINT l_artist_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_event_mood
   ADD CONSTRAINT l_event_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_mood
   ADD CONSTRAINT l_event_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_mood
   ADD CONSTRAINT l_event_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_genre_mood
   ADD CONSTRAINT l_genre_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_mood
   ADD CONSTRAINT l_genre_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_mood
   ADD CONSTRAINT l_genre_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_instrument_mood
   ADD CONSTRAINT l_instrument_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_instrument_mood
   ADD CONSTRAINT l_instrument_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES instrument(id);

ALTER TABLE l_instrument_mood
   ADD CONSTRAINT l_instrument_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_label_mood
   ADD CONSTRAINT l_label_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_label_mood
   ADD CONSTRAINT l_label_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES label(id);

ALTER TABLE l_label_mood
   ADD CONSTRAINT l_label_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_mood_mood
   ADD CONSTRAINT l_mood_mood_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_mood
   ADD CONSTRAINT l_mood_mood_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_mood
   ADD CONSTRAINT l_mood_mood_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES mood(id);

ALTER TABLE l_mood_place
   ADD CONSTRAINT l_mood_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_place
   ADD CONSTRAINT l_mood_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_place
   ADD CONSTRAINT l_mood_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_mood_recording
   ADD CONSTRAINT l_mood_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_recording
   ADD CONSTRAINT l_mood_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_recording
   ADD CONSTRAINT l_mood_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_mood_release
   ADD CONSTRAINT l_mood_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_release
   ADD CONSTRAINT l_mood_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_release
   ADD CONSTRAINT l_mood_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_mood_release_group
   ADD CONSTRAINT l_mood_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_release_group
   ADD CONSTRAINT l_mood_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_release_group
   ADD CONSTRAINT l_mood_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_mood_series
   ADD CONSTRAINT l_mood_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_series
   ADD CONSTRAINT l_mood_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_series
   ADD CONSTRAINT l_mood_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_mood_url
   ADD CONSTRAINT l_mood_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_url
   ADD CONSTRAINT l_mood_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_url
   ADD CONSTRAINT l_mood_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_mood_work
   ADD CONSTRAINT l_mood_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_mood_work
   ADD CONSTRAINT l_mood_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES mood(id);

ALTER TABLE l_mood_work
   ADD CONSTRAINT l_mood_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);

ALTER TABLE mood_alias
   ADD CONSTRAINT mood_alias_fk_mood
   FOREIGN KEY (mood)
   REFERENCES mood(id);

ALTER TABLE mood_alias
   ADD CONSTRAINT mood_alias_fk_type
   FOREIGN KEY (type)
   REFERENCES mood_alias_type(id);

ALTER TABLE mood_alias_type
   ADD CONSTRAINT mood_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES mood_alias_type(id);

ALTER TABLE mood_annotation
   ADD CONSTRAINT mood_annotation_fk_mood
   FOREIGN KEY (mood)
   REFERENCES mood(id);

ALTER TABLE mood_annotation
   ADD CONSTRAINT mood_annotation_fk_annotation
   FOREIGN KEY (annotation)
   REFERENCES annotation(id);


-- Constraints

ALTER TABLE l_area_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_instrument_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_instrument_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_label_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_label_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_mood ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_mood ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_mood_mood ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_mood_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_mood_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_mood_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

-- Triggers

CREATE TRIGGER b_upd_l_area_mood BEFORE UPDATE ON l_area_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_artist_mood BEFORE UPDATE ON l_artist_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_event_mood BEFORE UPDATE ON l_event_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_mood BEFORE UPDATE ON l_genre_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_instrument_mood BEFORE UPDATE ON l_instrument_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_label_mood BEFORE UPDATE ON l_label_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_mood BEFORE UPDATE ON l_mood_mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_place BEFORE UPDATE ON l_mood_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_recording BEFORE UPDATE ON l_mood_recording
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_release BEFORE UPDATE ON l_mood_release
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_release_group BEFORE UPDATE ON l_mood_release_group
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_url BEFORE UPDATE ON l_mood_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_mood_work BEFORE UPDATE ON l_mood_work
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_mood BEFORE UPDATE ON mood
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON mood_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER b_upd_mood_alias BEFORE UPDATE ON mood_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON mood_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_event_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_instrument_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_label_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_mood DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_mood_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_mood_url
AFTER UPDATE ON l_mood_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_mood_url
AFTER DELETE ON l_mood_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

COMMIT;
