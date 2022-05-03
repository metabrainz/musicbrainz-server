\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS deny_deprecated ON link;

CREATE TRIGGER deny_deprecated BEFORE INSERT ON link
    FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();

DROP TRIGGER IF EXISTS b_upd_link ON link;

CREATE TRIGGER b_upd_link BEFORE UPDATE ON link
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link();

DROP TRIGGER IF EXISTS b_ins_link_attribute ON link_attribute;

CREATE TRIGGER b_ins_link_attribute BEFORE INSERT ON link_attribute
    FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_attributes();

DROP TRIGGER IF EXISTS b_upd_link_attribute ON link_attribute;

CREATE TRIGGER b_upd_link_attribute BEFORE UPDATE ON link_attribute
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute();

DROP TRIGGER IF EXISTS b_upd_link_attribute_credit ON link_attribute_credit;

CREATE TRIGGER b_upd_link_attribute_credit BEFORE UPDATE ON link_attribute_credit
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute_credit();

DROP TRIGGER IF EXISTS b_upd_link_attribute_text_value ON link_attribute_text_value;

CREATE TRIGGER b_upd_link_attribute_text_value BEFORE UPDATE ON link_attribute_text_value
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute_text_value();

COMMIT;
