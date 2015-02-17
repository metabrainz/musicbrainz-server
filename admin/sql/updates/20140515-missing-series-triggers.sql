\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION unique_primary_series_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE series_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND series = NEW.series;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

UPDATE series SET last_updated = NOW();
UPDATE series_alias SET last_updated = NOW();

CREATE TRIGGER b_upd_series BEFORE UPDATE ON series
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER b_upd_series_alias BEFORE UPDATE ON series_alias
    FOR EACH ROW EXECUTE PROCEDURE b_upd_last_updated_table();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON series_alias
    FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON series_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_series_alias();

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON series_alias
    FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

COMMIT;
