\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS a_ins_l_area_area_mirror ON l_area_area;

CREATE TRIGGER a_ins_l_area_area_mirror AFTER INSERT ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_ins_l_area_area_mirror();

DROP TRIGGER IF EXISTS a_upd_l_area_area_mirror ON l_area_area;

CREATE TRIGGER a_upd_l_area_area_mirror AFTER UPDATE ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_upd_l_area_area_mirror();

DROP TRIGGER IF EXISTS a_del_l_area_area_mirror ON l_area_area;

CREATE TRIGGER a_del_l_area_area_mirror AFTER DELETE ON l_area_area
    FOR EACH ROW EXECUTE PROCEDURE a_del_l_area_area_mirror();

COMMIT;
