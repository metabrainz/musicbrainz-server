\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE TRIGGER a_ins_l_area_area_mirror AFTER INSERT ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_ins_l_area_area_mirror();

CREATE OR REPLACE TRIGGER a_upd_l_area_area_mirror AFTER UPDATE ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_upd_l_area_area_mirror();

CREATE OR REPLACE TRIGGER a_del_l_area_area_mirror AFTER DELETE ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_del_l_area_area_mirror();

COMMIT;
