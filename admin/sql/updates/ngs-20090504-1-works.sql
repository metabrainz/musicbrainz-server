BEGIN;


CREATE TABLE work_name (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    refcount            INTEGER DEFAULT 0
);

ALTER TABLE work_name ADD CONSTRAINT work_name_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX work_name_idx_name ON work_name (name);


CREATE TABLE work_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE work_type ADD CONSTRAINT work_type_pk PRIMARY KEY (id);


CREATE TABLE work (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references work_name.id
    artist_credit       INTEGER, -- references artist_credit.id
    type                INTEGER, -- references work_type.id
    iswc                CHAR(15),
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE work ADD CONSTRAINT work_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX work_idx_gid ON work (gid);
CREATE INDEX work_idx_name ON work (name);
CREATE INDEX work_idx_artist_credit ON work (artist_credit);

ALTER TABLE work ADD CONSTRAINT work_fk_name
    FOREIGN KEY (name) REFERENCES work_name(id);

ALTER TABLE work ADD CONSTRAINT work_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id);

ALTER TABLE work ADD CONSTRAINT work_fk_type
    FOREIGN KEY (type) REFERENCES work_type(id);


CREATE OR REPLACE FUNCTION a_ins_work() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('work', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_work() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('work', OLD.name, 1);
        PERFORM inc_name_refcount('work', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_work() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('work', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_work AFTER INSERT ON work
    FOR EACH ROW EXECUTE PROCEDURE a_ins_work();

CREATE TRIGGER a_upd_work AFTER UPDATE ON work
    FOR EACH ROW EXECUTE PROCEDURE a_upd_work();

CREATE TRIGGER a_del_work AFTER DELETE ON work
    FOR EACH ROW EXECUTE PROCEDURE a_del_work();


COMMIT;
