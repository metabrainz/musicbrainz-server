-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

ALTER TABLE cdtoc_raw DROP CONSTRAINT cdtoc_raw_fk_release;
ALTER TABLE edit_note DROP CONSTRAINT edit_note_fk_edit;
ALTER TABLE track_raw DROP CONSTRAINT track_raw_fk_release;
ALTER TABLE vote DROP CONSTRAINT vote_fk_edit;
