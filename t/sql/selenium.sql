\set ON_ERROR_STOP 1

BEGIN;

-- Skip past $EDITOR_MODBOT.
SELECT setval('editor_id_seq', 5, FALSE);

COMMIT;
