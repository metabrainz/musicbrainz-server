BEGIN;

CREATE TABLE artist_alias
(
    id                 SERIAL,
    artist             INTEGER NOT NULL, -- references artist.id
    name               INTEGER NOT NULL,
    editpending        INTEGER DEFAULT 0
);

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_pk PRIMARY KEY (id);

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_artist
    FOREIGN KEY (artist) REFERENCES artist(id);

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_name
    FOREIGN KEY (name) REFERENCES artist_name(id);

CREATE INDEX artist_alias_idx_name ON artist_alias (name);
CREATE INDEX artist_alias_idx_artist ON artist_alias (artist);
    
CREATE OR REPLACE FUNCTION a_ins_artist_alias() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('artist', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist_alias() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('artist', OLD.name, 1);
        PERFORM inc_name_refcount('artist', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist_alias() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('artist', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_artist_alias AFTER INSERT ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist_alias();

CREATE TRIGGER a_upd_artist_alias AFTER UPDATE ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist_alias();

CREATE TRIGGER a_del_artist_alias AFTER DELETE ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist_alias();

COMMIT;
