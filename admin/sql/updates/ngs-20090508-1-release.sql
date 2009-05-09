BEGIN;

CREATE TABLE release (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    release_group       INTEGER NOT NULL, -- references release_group.id
    status              INTEGER, -- references release_status.id
    packaging           INTEGER, -- references release_packaging.id
    date_year           SMALLINT,
    date_month          SMALLINT,
    date_day            SMALLINT,
    barcode             VARCHAR(255),
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE release ADD CONSTRAINT release_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX release_idx_gid ON release (gid);
CREATE INDEX release_idx_name ON release (name);
CREATE INDEX release_idx_release_group ON release (release_group);
CREATE INDEX release_idx_artist_credit ON release (artist_credit);
CREATE INDEX release_idx_date ON release (date_year, date_month, date_day);

ALTER TABLE release ADD CONSTRAINT release_fk_name
    FOREIGN KEY (name) REFERENCES release_name(id);

ALTER TABLE release ADD CONSTRAINT release_fk_release_group
    FOREIGN KEY (release_group) REFERENCES release_group(id);

ALTER TABLE release ADD CONSTRAINT release_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE release ADD CONSTRAINT release_fk_status
    FOREIGN KEY (status) REFERENCES release_status(id);

ALTER TABLE release ADD CONSTRAINT release_fk_packaging
    FOREIGN KEY (packaging) REFERENCES release_packaging(id);



CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('release', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('release', OLD.name, 1);
        PERFORM inc_name_refcount('release', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('release', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_release AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release();

CREATE TRIGGER a_upd_release AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release();

CREATE TRIGGER a_del_release AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release();


COMMIT;
