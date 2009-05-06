BEGIN;


CREATE TABLE release_name (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    refcount            INTEGER DEFAULT 0
);

ALTER TABLE release_name ADD CONSTRAINT release_name_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX release_name_idx_name ON release_name (name);


CREATE TABLE release_group_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE release_group_type ADD CONSTRAINT release_group_type_pk PRIMARY KEY (id);


CREATE TABLE release_group (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references release_name.id
    artist_credit       INTEGER, -- references artist_credit.id
    type                INTEGER, -- references release_group_type.id
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE release_group ADD CONSTRAINT release_group_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX release_group_idx_gid ON release_group (gid);
CREATE INDEX release_group_idx_name ON release_group (name);
CREATE INDEX release_group_idx_artist_credit ON release_group (artist_credit);

ALTER TABLE release_group ADD CONSTRAINT release_group_fk_name
    FOREIGN KEY (name) REFERENCES release_name(id);

ALTER TABLE release_group ADD CONSTRAINT release_group_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE release_group ADD CONSTRAINT release_group_fk_type
    FOREIGN KEY (type) REFERENCES release_group_type(id);



CREATE OR REPLACE FUNCTION a_ins_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('release', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_group() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('release', OLD.name, 1);
        PERFORM inc_name_refcount('release', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_group() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('release', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_release_group AFTER INSERT ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release_group();

CREATE TRIGGER a_upd_release_group AFTER UPDATE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release_group();

CREATE TRIGGER a_del_release_group AFTER DELETE ON release_group
    FOR EACH ROW EXECUTE PROCEDURE a_del_release_group();


COMMIT;
