\set ON_ERROR_STOP 1

BEGIN;

-- Alphabetical order

CREATE VIEW moderation_all AS
    SELECT * FROM moderation_open
    UNION ALL
    SELECT * FROM moderation_closed;

CREATE VIEW moderation_note_all AS
    SELECT * FROM moderation_note_open
    UNION ALL
    SELECT * FROM moderation_note_closed;

CREATE VIEW vote_all AS
    SELECT * FROM vote_open
    UNION ALL
    SELECT * FROM vote_closed;

COMMIT;

-- vi: set ts=4 sw=4 et :
