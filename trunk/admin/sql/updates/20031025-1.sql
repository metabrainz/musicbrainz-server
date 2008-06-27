-- Abstract: add votes.superseded

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE votes ADD COLUMN superseded BOOLEAN;

-- Ideal, but slow
--UPDATE votes SET superseded = FALSE;
--ALTER TABLE votes ALTER COLUMN superseded SET NOT NULL;

ALTER TABLE votes ALTER COLUMN superseded SET DEFAULT FALSE;

COMMIT;

-- vi: set ts=4 sw=4 et :
