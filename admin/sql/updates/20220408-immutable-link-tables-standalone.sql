\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE TRIGGER deny_deprecated BEFORE INSERT ON link
    FOR EACH ROW EXECUTE PROCEDURE deny_deprecated_links();

CREATE OR REPLACE TRIGGER b_upd_link BEFORE UPDATE ON link
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link();

CREATE OR REPLACE TRIGGER b_ins_link_attribute BEFORE INSERT ON link_attribute
    FOR EACH ROW EXECUTE PROCEDURE prevent_invalid_attributes();

CREATE OR REPLACE TRIGGER b_upd_link_attribute BEFORE UPDATE ON link_attribute
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute();

CREATE OR REPLACE TRIGGER b_upd_link_attribute_credit BEFORE UPDATE ON link_attribute_credit
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute_credit();

CREATE OR REPLACE TRIGGER b_upd_link_attribute_text_value BEFORE UPDATE ON link_attribute_text_value
    FOR EACH ROW EXECUTE PROCEDURE b_upd_link_attribute_text_value();

COMMIT;
