BEGIN;

ALTER TABLE artist
DROP CONSTRAINT group_type_implies_null_gender;

ALTER TABLE artist
ADD CONSTRAINT group_type_implies_null_gender CHECK (
  (gender IS NULL AND type IN (2, 5, 6))
  OR type NOT IN (2, 5, 6)
  OR type IS NULL
);

COMMIT;
