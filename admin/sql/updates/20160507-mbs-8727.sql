\set ON_ERROR_STOP 1

BEGIN;

UPDATE vote SET superseded = 't' WHERE id IN (
    1310304, -- edit #752619
    1381783, -- edit #835828
    1389065, -- edit #854892 (vote_time is before id=1389064)
    1429402, -- edit #916266
    1572699, -- edit #1136298 (vote_time is before id=1572698)
    1611602  -- edit #1194378
);

DROP INDEX IF EXISTS vote_idx_editor_edit;
CREATE UNIQUE INDEX vote_idx_editor_edit ON vote (editor, edit) WHERE superseded = FALSE;

COMMIT;
