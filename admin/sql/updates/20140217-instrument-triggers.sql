\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION n_insertinstrument() RETURNS TRIGGER
    AS $$BEGIN INSERT INTO link_attribute_type (parent, root, child_order, gid, name, description) VALUES (14, 14, 0, NEW.gid, NEW.name, NEW.description); RETURN NEW; END$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION n_updateinstrument() RETURNS TRIGGER
    AS $$BEGIN UPDATE link_attribute_type SET name = NEW.name, description = NEW.description WHERE gid = NEW.gid; RETURN NEW; END$$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION n_deleteinstrument() RETURNS TRIGGER
    AS $$BEGIN DELETE FROM link_attribute_type WHERE gid = OLD.gid; RETURN OLD; END$$
    LANGUAGE plpgsql;

CREATE TRIGGER nt_insertinstrument
    AFTER INSERT ON musicbrainz.instrument
    FOR EACH ROW
    EXECUTE PROCEDURE n_insertinstrument();

CREATE TRIGGER nt_updateinstrument
    AFTER UPDATE ON musicbrainz.instrument
    FOR EACH ROW
    EXECUTE PROCEDURE n_updateinstrument();

CREATE TRIGGER nt_deleteinstrument
    AFTER DELETE ON musicbrainz.instrument
    FOR EACH ROW
    EXECUTE PROCEDURE n_deleteinstrument();

--ROLLBACK;
COMMIT;
