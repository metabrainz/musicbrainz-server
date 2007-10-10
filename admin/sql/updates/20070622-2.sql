-- Abstract: Create tag tables in the main DB

\set ON_ERROR_STOP 1

BEGIN;

-- foreign keys
ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_artist
    FOREIGN KEY (artist)
    REFERENCES artist(id);

ALTER TABLE artist_tag
    ADD CONSTRAINT fk_artist_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_release
    FOREIGN KEY (release)
    REFERENCES album(id);

ALTER TABLE release_tag
    ADD CONSTRAINT fk_release_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_track
    FOREIGN KEY (track)
    REFERENCES track(id);

ALTER TABLE track_tag
    ADD CONSTRAINT fk_track_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_track
    FOREIGN KEY (label)
    REFERENCES label(id);

ALTER TABLE label_tag
    ADD CONSTRAINT fk_label_tag_tag
    FOREIGN KEY (tag)
    REFERENCES tag(id);

-- Triggers

CREATE TRIGGER a_ins_artist_tag AFTER INSERT ON artist_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_artist_tag AFTER DELETE ON artist_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_release_tag AFTER INSERT ON release_tag
     FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_release_tag AFTER DELETE ON release_tag
     FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_track_tag AFTER INSERT ON track_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_track_tag AFTER DELETE ON track_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

CREATE TRIGGER a_ins_label_tag AFTER INSERT ON label_tag
    FOR EACH ROW EXECUTE PROCEDURE a_ins_tag();
CREATE TRIGGER a_del_label_tag AFTER DELETE ON label_tag
    FOR EACH ROW EXECUTE PROCEDURE a_del_tag();

COMMIT;

-- vi: set ts=8 sw=8 et tw=0 :
