-- MBS-842, Allow vinyl style track numbers and sides by adding a free-text trackno column.

BEGIN;

ALTER TABLE track ADD COLUMN number TEXT;
UPDATE track SET number = position;
ALTER TABLE track ALTER COLUMN number SET NOT NULL;

COMMIT;



