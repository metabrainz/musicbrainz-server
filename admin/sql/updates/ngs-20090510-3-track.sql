BEGIN;

CREATE TABLE track
(
    id                 SERIAL,
    recording          INTEGER NOT NULL, -- references recording.id
    tracklist          INTEGER NOT NULL, -- references tracklist.id
    position           INTEGER NOT NULL,
    name               INTEGER NOT NULL, -- references track_name.id
    artist_credit      INTEGER NOT NULL, -- references artist_credit.id
    length             INTEGER,
    editpending        INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE track ADD CONSTRAINT track_pk PRIMARY KEY (id);

CREATE INDEX track_idx_recording ON track (recording);
CREATE UNIQUE INDEX track_idx_tracklist ON track (tracklist, position);
CREATE INDEX track_idx_name ON track (name);
CREATE INDEX track_idx_artist_credit ON track (artist_credit);

ALTER TABLE track ADD CONSTRAINT track_fk_recording
    FOREIGN KEY (recording) REFERENCES recording(id);

ALTER TABLE track ADD CONSTRAINT track_fk_tracklist
    FOREIGN KEY (tracklist) REFERENCES tracklist(id);

ALTER TABLE track ADD CONSTRAINT track_fk_name
    FOREIGN KEY (name) REFERENCES track_name(id);

ALTER TABLE track ADD CONSTRAINT track_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

CREATE OR REPLACE FUNCTION a_ins_track() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('track', NEW.name, 1);
    UPDATE tracklist SET trackcount = trackcount + 1 WHERE id = NEW.tracklist;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_track() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('track', OLD.name, 1);
        PERFORM inc_name_refcount('track', NEW.name, 1);
    END IF;
    IF NEW.tracklist != OLD.tracklist THEN
        UPDATE tracklist SET trackcount = trackcount - 1 WHERE id = OLD.tracklist;
        UPDATE tracklist SET trackcount = trackcount + 1 WHERE id = NEW.tracklist;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_track() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('track', OLD.name, 1);
    UPDATE tracklist SET trackcount = trackcount - 1 WHERE id = OLD.tracklist;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_track AFTER INSERT ON track
    FOR EACH ROW EXECUTE PROCEDURE a_ins_track();

CREATE TRIGGER a_upd_track AFTER UPDATE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_upd_track();

CREATE TRIGGER a_del_track AFTER DELETE ON track
    FOR EACH ROW EXECUTE PROCEDURE a_del_track();

COMMIT;
