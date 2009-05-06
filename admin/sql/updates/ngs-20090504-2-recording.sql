BEGIN;


CREATE TABLE track_name (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    refcount            INTEGER DEFAULT 0
);

ALTER TABLE track_name ADD CONSTRAINT track_name_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX track_name_idx_name ON track_name (name);


CREATE TABLE recording (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references track_name.id
    artist_credit       INTEGER, -- references artist_credit.id
    length              INTEGER,
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE recording ADD CONSTRAINT recording_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX recording_idx_gid ON recording (gid);
CREATE INDEX recording_idx_name ON recording (name);
CREATE INDEX recording_idx_artist_credit ON recording (artist_credit);

ALTER TABLE recording ADD CONSTRAINT recording_fk_name
    FOREIGN KEY (name) REFERENCES track_name(id);

ALTER TABLE recording ADD CONSTRAINT recording_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);


CREATE OR REPLACE FUNCTION a_ins_recording() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('track', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_recording() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('track', OLD.name, 1);
        PERFORM inc_name_refcount('track', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_recording() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('track', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_recording AFTER INSERT ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_ins_recording();

CREATE TRIGGER a_upd_recording AFTER UPDATE ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_upd_recording();

CREATE TRIGGER a_del_recording AFTER DELETE ON recording
    FOR EACH ROW EXECUTE PROCEDURE a_del_recording();


COMMIT;
