BEGIN;

CREATE OR REPLACE FUNCTION deny_special_purpose_deletion() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'Attempted to delete a special purpose row';
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER b_del_artist_special BEFORE DELETE ON artist
    FOR EACH ROW WHEN (OLD.id IN (1, 2)) EXECUTE PROCEDURE deny_special_purpose_deletion();

CREATE TRIGGER b_del_label_special BEFORE DELETE ON label
    FOR EACH ROW WHEN (OLD.id = 1) EXECUTE PROCEDURE deny_special_purpose_deletion();

COMMIT;
