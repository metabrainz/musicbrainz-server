\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION a_ins_instrument() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO link_attribute_type (parent, root, child_order, gid, name, description) VALUES (14, 14, 0, NEW.gid, NEW.name, NEW.description);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_upd_instrument() RETURNS TRIGGER AS $$
BEGIN
    UPDATE link_attribute_type SET name = NEW.name, description = NEW.description WHERE gid = NEW.gid;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_del_instrument() RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM link_attribute_type WHERE gid = OLD.gid;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER a_ins_instrument AFTER INSERT ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_ins_instrument();

CREATE TRIGGER a_upd_instrument AFTER UPDATE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_upd_instrument();

CREATE TRIGGER a_del_instrument AFTER DELETE ON musicbrainz.instrument
    FOR EACH ROW EXECUTE PROCEDURE a_del_instrument();

COMMIT;
