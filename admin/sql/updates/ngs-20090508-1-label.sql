BEGIN;


CREATE TABLE label_name (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    refcount            INTEGER DEFAULT 0
);

ALTER TABLE label_name ADD CONSTRAINT label_name_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX label_name_idx_name ON label_name (name);


CREATE TABLE label_type (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL
);

ALTER TABLE label_type ADD CONSTRAINT label_type_pk PRIMARY KEY (id);


CREATE TABLE label (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references label_name.id
    sortname            INTEGER NOT NULL, -- references label_name.id
    begindate_year      SMALLINT,
    begindate_month     SMALLINT,
    begindate_day       SMALLINT,
    enddate_year        SMALLINT,
    enddate_month       SMALLINT,
    enddate_day         SMALLINT,
    labelcode           INTEGER,
    type                INTEGER, -- references label_type.id
    country             INTEGER, -- references country.id
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE label ADD CONSTRAINT label_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX label_idx_gid ON label (gid);
CREATE INDEX label_idx_name ON label (name);
CREATE INDEX label_idx_sortname ON label (sortname);

ALTER TABLE label ADD CONSTRAINT label_fk_name
    FOREIGN KEY (name) REFERENCES label_name(id);

ALTER TABLE label ADD CONSTRAINT label_fk_sortname
    FOREIGN KEY (sortname) REFERENCES label_name(id);

ALTER TABLE label ADD CONSTRAINT label_fk_type
    FOREIGN KEY (type) REFERENCES label_type(id);

ALTER TABLE label ADD CONSTRAINT label_fk_country
    FOREIGN KEY (type) REFERENCES country(id);


CREATE OR REPLACE FUNCTION a_ins_label() RETURNS trigger AS $$
BEGIN
    IF NEW.name = NEW.sortname THEN
        PERFORM inc_name_refcount('label', NEW.name, 2);
    ELSE
        PERFORM inc_name_refcount('label', NEW.name, 1);
        PERFORM inc_name_refcount('label', NEW.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_label() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        IF NEW.sortname != OLD.sortname THEN
            -- both names and sortnames are different
            IF OLD.name = OLD.sortname THEN
                PERFORM dec_name_refcount('label', OLD.name, 2);
            ELSE
                PERFORM dec_name_refcount('label', OLD.name, 1);
                PERFORM dec_name_refcount('label', OLD.sortname, 1);
            END IF;
            IF NEW.name = NEW.sortname THEN
                PERFORM inc_name_refcount('label', NEW.name, 2);
            ELSE
                PERFORM inc_name_refcount('label', NEW.name, 1);
                PERFORM inc_name_refcount('label', NEW.sortname, 1);
            END IF;
        ELSE
            -- only names are different
            PERFORM dec_name_refcount('label', OLD.name, 1);
            PERFORM inc_name_refcount('label', NEW.name, 1);
        END IF;
    ELSE
        -- only sortnames are different
        IF NEW.sortname != OLD.sortname THEN
            PERFORM dec_name_refcount('label', OLD.sortname, 1);
            PERFORM inc_name_refcount('label', NEW.sortname, 1);
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_label() RETURNS trigger AS $$
BEGIN
    IF OLD.name = OLD.sortname THEN
        PERFORM dec_name_refcount('label', OLD.name, 2);
    ELSE
        PERFORM dec_name_refcount('label', OLD.name, 1);
        PERFORM dec_name_refcount('label', OLD.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_label AFTER INSERT ON label
    FOR EACH ROW EXECUTE PROCEDURE a_ins_label();

CREATE TRIGGER a_upd_label AFTER UPDATE ON label
    FOR EACH ROW EXECUTE PROCEDURE a_upd_label();

CREATE TRIGGER a_del_label AFTER DELETE ON label
    FOR EACH ROW EXECUTE PROCEDURE a_del_label();


COMMIT;
