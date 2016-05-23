\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE edit
  DROP COLUMN yes_votes,
  DROP COLUMN no_votes;

ALTER TABLE editor
  DROP COLUMN edits_accepted,
  DROP COLUMN edits_rejected,
  DROP COLUMN auto_edits_accepted,
  DROP COLUMN edits_failed;

COMMIT;
