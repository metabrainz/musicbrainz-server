-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

ALTER TABLE cdtoc_raw DROP CONSTRAINT cdtoc_raw_fk_release;
ALTER TABLE edit_artist DROP CONSTRAINT edit_artist_fk_edit;
ALTER TABLE edit_label DROP CONSTRAINT edit_label_fk_edit;
ALTER TABLE edit_note DROP CONSTRAINT edit_note_fk_edit;
ALTER TABLE edit_recording DROP CONSTRAINT edit_recording_fk_edit;
ALTER TABLE edit_release DROP CONSTRAINT edit_release_fk_edit;
ALTER TABLE edit_release_group DROP CONSTRAINT edit_release_group_fk_edit;
ALTER TABLE edit_url DROP CONSTRAINT edit_url_fk_edit;
ALTER TABLE edit_work DROP CONSTRAINT edit_work_fk_edit;
ALTER TABLE track_raw DROP CONSTRAINT track_raw_fk_release;
ALTER TABLE vote DROP CONSTRAINT vote_fk_edit;
