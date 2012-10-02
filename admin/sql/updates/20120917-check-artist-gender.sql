BEGIN;

UPDATE artist SET gender = NULL WHERE gender IS NOT NULL AND type = 2;

ALTER TABLE artist
ADD CHECK (
  (gender IS NULL AND type = 2)
  OR type IS DISTINCT FROM 2
);

COMMIT;
