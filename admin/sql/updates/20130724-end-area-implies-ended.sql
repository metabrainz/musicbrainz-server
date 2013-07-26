BEGIN;

UPDATE artist SET ended = TRUE WHERE NOT ended AND end_area IS NOT NULL;

CREATE OR REPLACE FUNCTION end_area_implies_ended()
RETURNS trigger AS $$
BEGIN
    IF NEW.end_area IS NOT NULL
    THEN
        NEW.ended = TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER end_area_implies_ended BEFORE UPDATE OR INSERT ON artist
    FOR EACH ROW EXECUTE PROCEDURE end_area_implies_ended();

COMMIT;
