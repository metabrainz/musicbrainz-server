\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE l_area_genre ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_area_genre ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_artist_genre ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_artist_genre ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_event_genre ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_event_genre ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_genre ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_genre ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));
ALTER TABLE l_genre_genre ADD CONSTRAINT non_loop_relationship CHECK (entity0 != entity1);

ALTER TABLE l_genre_instrument ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_instrument ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_label ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_label ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_place ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_place ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_recording ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_recording ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_release ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_release ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_release_group ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_release_group ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_series ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_series ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_url ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_url ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));

ALTER TABLE l_genre_work ADD CONSTRAINT control_for_whitespace_entity0_credit CHECK (controlled_for_whitespace(entity0_credit));
ALTER TABLE l_genre_work ADD CONSTRAINT control_for_whitespace_entity1_credit CHECK (controlled_for_whitespace(entity1_credit));


ALTER TABLE l_area_genre
   ADD CONSTRAINT l_area_genre_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_area_genre
   ADD CONSTRAINT l_area_genre_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES area(id);

ALTER TABLE l_area_genre
   ADD CONSTRAINT l_area_genre_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES genre(id);

ALTER TABLE l_artist_genre
   ADD CONSTRAINT l_artist_genre_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_artist_genre
   ADD CONSTRAINT l_artist_genre_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES artist(id);

ALTER TABLE l_artist_genre
   ADD CONSTRAINT l_artist_genre_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES genre(id);

ALTER TABLE l_event_genre
   ADD CONSTRAINT l_event_genre_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_event_genre
   ADD CONSTRAINT l_event_genre_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES event(id);

ALTER TABLE l_event_genre
   ADD CONSTRAINT l_event_genre_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES genre(id);

ALTER TABLE l_genre_genre
   ADD CONSTRAINT l_genre_genre_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_genre
   ADD CONSTRAINT l_genre_genre_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_genre
   ADD CONSTRAINT l_genre_genre_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES genre(id);

ALTER TABLE l_genre_instrument
   ADD CONSTRAINT l_genre_instrument_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_instrument
   ADD CONSTRAINT l_genre_instrument_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_instrument
   ADD CONSTRAINT l_genre_instrument_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES instrument(id);

ALTER TABLE l_genre_label
   ADD CONSTRAINT l_genre_label_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_label
   ADD CONSTRAINT l_genre_label_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_label
   ADD CONSTRAINT l_genre_label_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES label(id);

ALTER TABLE l_genre_place
   ADD CONSTRAINT l_genre_place_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_place
   ADD CONSTRAINT l_genre_place_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_place
   ADD CONSTRAINT l_genre_place_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES place(id);

ALTER TABLE l_genre_recording
   ADD CONSTRAINT l_genre_recording_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_recording
   ADD CONSTRAINT l_genre_recording_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_recording
   ADD CONSTRAINT l_genre_recording_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES recording(id);

ALTER TABLE l_genre_release
   ADD CONSTRAINT l_genre_release_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_release
   ADD CONSTRAINT l_genre_release_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_release
   ADD CONSTRAINT l_genre_release_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release(id);

ALTER TABLE l_genre_release_group
   ADD CONSTRAINT l_genre_release_group_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_release_group
   ADD CONSTRAINT l_genre_release_group_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_release_group
   ADD CONSTRAINT l_genre_release_group_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES release_group(id);

ALTER TABLE l_genre_series
   ADD CONSTRAINT l_genre_series_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_series
   ADD CONSTRAINT l_genre_series_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_series
   ADD CONSTRAINT l_genre_series_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES series(id);

ALTER TABLE l_genre_url
   ADD CONSTRAINT l_genre_url_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_url
   ADD CONSTRAINT l_genre_url_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_url
   ADD CONSTRAINT l_genre_url_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES url(id);

ALTER TABLE l_genre_work
   ADD CONSTRAINT l_genre_work_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE l_genre_work
   ADD CONSTRAINT l_genre_work_fk_entity0
   FOREIGN KEY (entity0)
   REFERENCES genre(id);

ALTER TABLE l_genre_work
   ADD CONSTRAINT l_genre_work_fk_entity1
   FOREIGN KEY (entity1)
   REFERENCES work(id);


CREATE TRIGGER b_upd_l_area_genre BEFORE UPDATE ON l_area_genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_artist_genre BEFORE UPDATE ON l_artist_genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_event_genre BEFORE UPDATE ON l_event_genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_genre BEFORE UPDATE ON l_genre_genre
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_instrument BEFORE UPDATE ON l_genre_instrument
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_label BEFORE UPDATE ON l_genre_label
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_place BEFORE UPDATE ON l_genre_place
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_recording BEFORE UPDATE ON l_genre_recording
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_release BEFORE UPDATE ON l_genre_release
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_release_group BEFORE UPDATE ON l_genre_release_group
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_url BEFORE UPDATE ON l_genre_url
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_l_genre_work BEFORE UPDATE ON l_genre_work
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_area_genre DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_artist_genre DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_event_genre DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_genre DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_instrument DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_label DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_place DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_recording DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_release DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_release_group DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_url DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER remove_unused_links
    AFTER DELETE OR UPDATE ON l_genre_work DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE PROCEDURE remove_unused_links();

CREATE CONSTRAINT TRIGGER url_gc_a_upd_l_genre_url
AFTER UPDATE ON l_genre_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();

CREATE CONSTRAINT TRIGGER url_gc_a_del_l_genre_url
AFTER DELETE ON l_genre_url DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE PROCEDURE remove_unused_url();


ALTER TABLE documentation.l_area_genre_example
   ADD CONSTRAINT l_area_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_area_genre(id);

ALTER TABLE documentation.l_artist_genre_example
   ADD CONSTRAINT l_artist_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_artist_genre(id);

ALTER TABLE documentation.l_event_genre_example
   ADD CONSTRAINT l_event_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_event_genre(id);

ALTER TABLE documentation.l_genre_genre_example
   ADD CONSTRAINT l_genre_genre_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_genre(id);

ALTER TABLE documentation.l_genre_instrument_example
   ADD CONSTRAINT l_genre_instrument_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_instrument(id);

ALTER TABLE documentation.l_genre_label_example
   ADD CONSTRAINT l_genre_label_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_label(id);

ALTER TABLE documentation.l_genre_place_example
   ADD CONSTRAINT l_genre_place_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_place(id);

ALTER TABLE documentation.l_genre_recording_example
   ADD CONSTRAINT l_genre_recording_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_recording(id);

ALTER TABLE documentation.l_genre_release_example
   ADD CONSTRAINT l_genre_release_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_release(id);

ALTER TABLE documentation.l_genre_release_group_example
   ADD CONSTRAINT l_genre_release_group_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_release_group(id);

ALTER TABLE documentation.l_genre_series_example
   ADD CONSTRAINT l_genre_series_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_series(id);

ALTER TABLE documentation.l_genre_url_example
   ADD CONSTRAINT l_genre_url_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_url(id);

ALTER TABLE documentation.l_genre_work_example
   ADD CONSTRAINT l_genre_work_example_fk_id
   FOREIGN KEY (id)
   REFERENCES musicbrainz.l_genre_work(id);

COMMIT;
