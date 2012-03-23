-- MBS-842, Allow vinyl style track numbers and sides by adding a free-text trackno column.

BEGIN;

ALTER TABLE track ADD COLUMN number VARCHAR(255);
UPDATE track SET number = position;
-- ALTER TABLE track ADD COLUMN number VARCHAR(255);

COMMIT;



