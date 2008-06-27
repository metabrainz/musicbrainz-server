-- Abstract: add column "notetime" to moderation_note_open, moderation_note_closed

\set ON_ERROR_STOP 1

BEGIN;

-- add the columns, then set their default value.
ALTER TABLE moderation_note_closed ADD COLUMN notetime TIMESTAMP WITH TIME ZONE; 
ALTER TABLE moderation_note_open ADD COLUMN notetime TIMESTAMP WITH TIME ZONE; 

ALTER TABLE moderation_note_closed ALTER COLUMN notetime SET DEFAULT NOW();
ALTER TABLE moderation_note_open ALTER COLUMN notetime SET DEFAULT NOW();

-- recreate the view of all moderation_notes
DROP VIEW moderation_note_all;
CREATE VIEW moderation_note_all AS
    SELECT * FROM moderation_note_open
    UNION ALL
    SELECT * FROM moderation_note_closed;

COMMIT;

-- vi: set ts=4 sw=4 et :