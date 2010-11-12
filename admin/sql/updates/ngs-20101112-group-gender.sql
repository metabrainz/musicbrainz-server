
\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION artist_groups_have_no_gender() RETURNS trigger AS $$
BEGIN
    -- Group artists cannot have a gender
    IF NEW.type = 2 THEN
        NEW.gender = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER b_ins_artist BEFORE INSERT ON artist
    FOR EACH ROW EXECUTE PROCEDURE artist_groups_have_no_gender();

CREATE TRIGGER b_upd_artist BEFORE UPDATE ON artist
    FOR EACH ROW EXECUTE PROCEDURE artist_groups_have_no_gender();

COMMIT;
