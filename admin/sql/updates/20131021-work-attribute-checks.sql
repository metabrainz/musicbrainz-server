BEGIN;

ALTER TABLE work_attribute
  DROP CONSTRAINT IF EXISTS work_attribute_check,
  ADD CONSTRAINT work_attribute_check CHECK (
    (work_attribute_type_allowed_value IS NULL AND work_attribute_text IS NOT NULL)
    OR
    (work_attribute_type_allowed_value IS NOT NULL AND work_attribute_text IS NULL)
  );

COMMIT;
