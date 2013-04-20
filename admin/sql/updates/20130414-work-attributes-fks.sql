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
   ADD CONSTRAINT work_attribute_fk_work_attribute_type_allowed_value
   FOREIGN KEY (work_attribute_type_allowed_value)
   REFERENCES work_attribute_type_allowed_value(id);

ALTER TABLE work_attribute_type_allowed_value
   ADD CONSTRAINT work_attribute_type_allowed_value_fk_work_attribute_type
   FOREIGN KEY (work_attribute_type)
   REFERENCES work_attribute_type(id);

CREATE OR REPLACE FUNCTION ensure_work_attribute_type_allows_text()
RETURNS trigger AS $$
  BEGIN
    IF NEW.work_attribute_text IS NOT NULL
        AND NOT EXISTS (
           SELECT TRUE FROM work_attribute_type
                WHERE work_attribute_type.id = NEW.work_attribute_type
                AND free_text
        )
    THEN
        RAISE EXCEPTION 'This attribute type can not contain free text';
    ELSE RETURN NEW;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER ensure_work_attribute_type_allows_text BEFORE INSERT OR UPDATE ON work_attribute
    FOR EACH ROW EXECUTE PROCEDURE ensure_work_attribute_type_allows_text();

COMMIT;
