-- Abstract: change moderationnote.text from VARCHAR(255) to TEXT
-- Formerly called admin/sql/AlterModerationNoteText.sql

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE moderationnote ADD COLUMN text2 TEXT;
UPDATE moderationnote SET text2 = text;
ALTER TABLE moderationnote ALTER COLUMN text2 SET NOT NULL;
ALTER TABLE moderationnote DROP COLUMN text;
ALTER TABLE moderationnote RENAME COLUMN text2 TO text;

COMMIT;

