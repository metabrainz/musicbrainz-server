\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work
   FOREIGN KEY (work)
   REFERENCES work(id);

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_attribute
   ADD CONSTRAINT work_attribute_fk_work_attribute_type_value
   FOREIGN KEY (work_attribute_type_value)
   REFERENCES work_attribute_type_value(id);

ALTER TABLE work_attribute_type_value
   ADD CONSTRAINT work_attribute_type_value_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);


COMMIT;
