\set ON_ERROR_STOP 1
BEGIN;

LOCK TABLE link_attribute_text_value IN EXCLUSIVE MODE;

CREATE TEMPORARY TABLE tmp_link_attribute_text_value (link, attribute_type, text_value) AS SELECT link, attribute_type, text_value FROM link_attribute_text_value;

CREATE TRIGGER "reptg_link_attribute_text_value"
AFTER INSERT OR DELETE OR UPDATE ON "link_attribute_text_value"
FOR EACH ROW EXECUTE PROCEDURE "recordchange" ();

DELETE FROM link_attribute_text_value;
INSERT INTO link_attribute_text_value (link, attribute_type, text_value) SELECT link, attribute_type, text_value FROM link_attribute_text_value;

COMMIT;
