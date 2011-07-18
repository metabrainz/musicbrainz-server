BEGIN;

DROP FUNCTION IF EXISTS deny_special_purpose_deletion();

DROP TRIGGER IF EXISTS b_del_artist_special ON artist;
DROP TRIGGER IF EXISTS b_del_label_special ON label;


-- Copied from admin/sql/CreateFunctions.sql
CREATE OR REPLACE FUNCTION deny_special_purpose_artist_deletion() RETURNS trigger AS $$
BEGIN
    IF OLD.id IN (1, 2) THEN
        RAISE EXCEPTION 'Attempted to delete a special purpose row';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION deny_special_purpose_label_deletion() RETURNS trigger AS $$
BEGIN
    IF OLD.id = 1 THEN
        RAISE EXCEPTION 'Attempted to delete a special purpose row';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

-- Copied from admin/sql/CreateTriggers.sql
CREATE TRIGGER b_del_artist_special BEFORE DELETE ON artist
    FOR EACH ROW EXECUTE PROCEDURE deny_special_purpose_artist_deletion();

CREATE TRIGGER b_del_label_special BEFORE DELETE ON label
    FOR EACH ROW EXECUTE PROCEDURE deny_special_purpose_label_deletion();

COMMIT;