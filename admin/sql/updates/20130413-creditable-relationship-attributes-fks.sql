\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE link_creditable_attribute_type
   ADD CONSTRAINT link_creditable_attribute_type_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_attribute_type(id)
   ON DELETE CASCADE;

ALTER TABLE link_attribute_credit
   ADD CONSTRAINT link_attribute_credit_fk_link
   FOREIGN KEY (link)
   REFERENCES link(id);

ALTER TABLE link_attribute_credit
   ADD CONSTRAINT link_attribute_credit_fk_attribute_type
   FOREIGN KEY (attribute_type)
   REFERENCES link_creditable_attribute_type(attribute_type);

COMMIT;
