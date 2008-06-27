-- Abstract: Rename fk_link_attribute_type_id correctly

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE link_attribute
    ADD CONSTRAINT fk_link_attribute_type
    FOREIGN KEY (attribute_type)
    REFERENCES link_attribute_type(id);

ALTER TABLE link_attribute
    DROP CONSTRAINT fk_link_attribute_type_id;

COMMIT;

-- vi: set ts=4 sw=4 et :
