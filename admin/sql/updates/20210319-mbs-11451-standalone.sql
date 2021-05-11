\set ON_ERROR_STOP 1
BEGIN;

DROP TRIGGER IF EXISTS a_ins_place ON place;

CREATE TRIGGER a_ins_place AFTER INSERT ON place
    FOR EACH ROW EXECUTE PROCEDURE a_ins_place();

ALTER TABLE ONLY musicbrainz.place_meta
    ADD CONSTRAINT place_meta_fk_id
    FOREIGN KEY (id)
    REFERENCES musicbrainz.place(id)
    ON DELETE CASCADE;

ALTER TABLE ONLY musicbrainz.place_rating_raw
    ADD CONSTRAINT place_rating_raw_fk_editor
    FOREIGN KEY (editor)
    REFERENCES musicbrainz.editor(id);

ALTER TABLE ONLY musicbrainz.place_rating_raw
    ADD CONSTRAINT place_rating_raw_fk_place
    FOREIGN KEY (place)
    REFERENCES musicbrainz.place(id);

COMMIT;
