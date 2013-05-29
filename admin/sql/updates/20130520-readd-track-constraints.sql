\set ON_ERROR_STOP 1

BEGIN;
    ALTER TABLE track ADD CONSTRAINT track_edits_pending_check CHECK (edits_pending >= 0);
    ALTER TABLE track ADD CONSTRAINT track_length_check CHECK (length IS NULL OR length > 0);
    ALTER TABLE track ADD CONSTRAINT track_number_check CHECK (controlled_for_whitespace(number));
COMMIT;
