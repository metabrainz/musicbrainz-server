-- Abstract:
--    - tagging (coming soon)
--    - keeping options for TOCs open

\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE cdtoc ADD COLUMN degraded BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;

-- vi: set ts=4 sw=4 et :
