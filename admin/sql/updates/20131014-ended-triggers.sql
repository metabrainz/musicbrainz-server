\set ON_ERROR_STOP 1
BEGIN;

------------------------
-- ADD ENDED TRIGGERS --
------------------------

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON area_alias
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON artist_alias
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON label_alias
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

CREATE TRIGGER end_date_implies_ended BEFORE UPDATE OR INSERT ON work_alias
FOR EACH ROW EXECUTE PROCEDURE end_date_implies_ended();

COMMIT;
