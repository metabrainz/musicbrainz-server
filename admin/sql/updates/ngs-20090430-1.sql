BEGIN;


CREATE TABLE artist_name (
    id                  SERIAL,
    name                VARCHAR(255) NOT NULL,
    page                INTEGER NOT NULL,
    refcount            INTEGER DEFAULT 0
);

ALTER TABLE artist_name ADD CONSTRAINT artist_name_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX artist_name_idx_name ON artist_name (name);


CREATE TABLE artist (
    id                  SERIAL,
    gid                 UUID NOT NULL,
    name                INTEGER NOT NULL, -- references artist_name.id
    sortname            INTEGER NOT NULL, -- references artist_name.id
    begindate_year      SMALLINT,
    begindate_month     SMALLINT,
    begindate_day       SMALLINT,
    enddate_year        SMALLINT,
    enddate_month       SMALLINT,
    enddate_day         SMALLINT,
    type                INTEGER, -- references artist_type.id
    country             INTEGER, -- references country.id
    gender              INTEGER, -- references gender.id
    comment             VARCHAR(255),
    editpending         INTEGER DEFAULT 0
);

ALTER TABLE artist ADD CONSTRAINT artist_pk PRIMARY KEY (id);

CREATE UNIQUE INDEX artist_idx_gid ON artist (gid);
CREATE INDEX artist_idx_name ON artist (name);
CREATE INDEX artist_idx_sortname ON artist (sortname);

ALTER TABLE artist ADD CONSTRAINT artist_fk_name
    FOREIGN KEY (name) REFERENCES artist_name(id);

ALTER TABLE artist ADD CONSTRAINT artist_fk_sortname
    FOREIGN KEY (sortname) REFERENCES artist_name(id);

ALTER TABLE artist ADD CONSTRAINT artist_fk_type
    FOREIGN KEY (type) REFERENCES artist_type(id);


CREATE OR REPLACE FUNCTION inc_name_refcount(tbl varchar, row_id integer, val integer) RETURNS void AS $$
BEGIN
    -- increment refcount for the new name
    EXECUTE 'SELECT refcount FROM ' || tbl || '_name WHERE id = ' || row_id || ' FOR UPDATE';
    EXECUTE 'UPDATE ' || tbl || '_name SET refcount = refcount + ' || val || ' WHERE id = ' || row_id;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION dec_name_refcount(tbl varchar, row_id integer, val integer) RETURNS void AS $$
DECLARE
    ref_count integer;
BEGIN
    -- decrement refcount for the old name,
    -- or delete it if refcount would drop to 0
    EXECUTE 'SELECT refcount FROM ' || tbl || '_name WHERE id = ' || row_id || ' FOR UPDATE' INTO ref_count;
    IF ref_count <= val THEN
        EXECUTE 'DELETE FROM ' || tbl || '_name WHERE id = ' || row_id;
    ELSE
        EXECUTE 'UPDATE ' || tbl || '_name SET refcount = refcount - ' || val || ' WHERE id = ' || row_id;
    END IF;
    RETURN;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION a_ins_artist() RETURNS trigger AS $$
BEGIN
    IF NEW.name = NEW.sortname THEN
        PERFORM inc_name_refcount('artist', NEW.name, 2);
    ELSE
        PERFORM inc_name_refcount('artist', NEW.name, 1);
        PERFORM inc_name_refcount('artist', NEW.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        IF NEW.sortname != OLD.sortname THEN
            -- both names and sortnames are different
            IF OLD.name = OLD.sortname THEN
                PERFORM dec_name_refcount('artist', OLD.name, 2);
            ELSE
                PERFORM dec_name_refcount('artist', OLD.name, 1);
                PERFORM dec_name_refcount('artist', OLD.sortname, 1);
            END IF;
            IF NEW.name = NEW.sortname THEN
                PERFORM inc_name_refcount('artist', NEW.name, 2);
            ELSE
                PERFORM inc_name_refcount('artist', NEW.name, 1);
                PERFORM inc_name_refcount('artist', NEW.sortname, 1);
            END IF;
        ELSE
            -- only names are different
            PERFORM dec_name_refcount('artist', OLD.name, 1);
            PERFORM inc_name_refcount('artist', NEW.name, 1);
        END IF;
    ELSE
        -- only sortnames are different
        IF NEW.sortname != OLD.sortname THEN
            PERFORM dec_name_refcount('artist', OLD.sortname, 1);
            PERFORM inc_name_refcount('artist', NEW.sortname, 1);
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist() RETURNS trigger AS $$
BEGIN
    IF OLD.name = OLD.sortname THEN
        PERFORM dec_name_refcount('artist', OLD.name, 2);
    ELSE
        PERFORM dec_name_refcount('artist', OLD.name, 1);
        PERFORM dec_name_refcount('artist', OLD.sortname, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_artist AFTER INSERT ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist();

CREATE TRIGGER a_upd_artist AFTER UPDATE ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist();

CREATE TRIGGER a_del_artist AFTER DELETE ON artist
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist();


COMMIT;
