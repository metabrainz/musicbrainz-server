BEGIN;


CREATE TABLE artist_credit_name (
    artist_credit       INTEGER NOT NULL, -- references artist_credit.id
    position            SMALLINT NOT NULL,
    artist              INTEGER NOT NULL, -- references artist.id
    name                INTEGER NOT NULL, -- references name.id
    joinphrase          VARCHAR(32)
);

ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_pk PRIMARY KEY (artist_credit, position);


CREATE TABLE artist_credit (
    id                  SERIAL,
    artistcount         SMALLINT,
    refcount            SMALLINT DEFAULT 0
);

ALTER TABLE artist_credit ADD CONSTRAINT artist_credit_pk PRIMARY KEY (id);


ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_fk_artist_credit
    FOREIGN KEY (artist_credit) REFERENCES artist_credit(id) ON DELETE CASCADE;

ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_fk_artist
    FOREIGN KEY (artist) REFERENCES artist(id);

ALTER TABLE artist_credit_name ADD CONSTRAINT artist_credit_name_fk_name
    FOREIGN KEY (name) REFERENCES artist_name(id);


CREATE OR REPLACE FUNCTION a_ins_artist_credit_name() RETURNS trigger AS $$
BEGIN
    PERFORM inc_name_refcount('artist', NEW.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_artist_credit_name() RETURNS trigger AS $$
BEGIN
    IF NEW.name != OLD.name THEN
        PERFORM dec_name_refcount('artist', OLD.name, 1);
        PERFORM inc_name_refcount('artist', NEW.name, 1);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_artist_credit_name() RETURNS trigger AS $$
BEGIN
    PERFORM dec_name_refcount('artist', OLD.name, 1);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER a_ins_artist_credit_name AFTER INSERT ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_ins_artist_credit_name();

CREATE TRIGGER a_upd_artist_credit_name AFTER UPDATE ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_upd_artist_credit_name();

CREATE TRIGGER a_del_artist_credit_name AFTER DELETE ON artist_credit_name
    FOR EACH ROW EXECUTE PROCEDURE a_del_artist_credit_name();


COMMIT;
