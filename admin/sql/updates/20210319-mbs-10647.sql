\set ON_ERROR_STOP 1
BEGIN;

DROP TRIGGER IF EXISTS b_del_label_special ON label;

CREATE TRIGGER b_del_label_special BEFORE DELETE ON label
    FOR EACH ROW WHEN (OLD.id IN (1, 3267)) EXECUTE PROCEDURE deny_special_purpose_deletion();

COMMIT;
