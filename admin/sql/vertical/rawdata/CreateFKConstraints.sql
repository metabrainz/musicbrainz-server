-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

ALTER TABLE cdtoc_raw
   ADD CONSTRAINT cdtoc_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release_raw(id);

ALTER TABLE edit_artist
   ADD CONSTRAINT edit_artist_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_label
   ADD CONSTRAINT edit_label_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_note
   ADD CONSTRAINT edit_note_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_recording
   ADD CONSTRAINT edit_recording_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_release
   ADD CONSTRAINT edit_release_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_release_group
   ADD CONSTRAINT edit_release_group_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_url
   ADD CONSTRAINT edit_url_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_work
   ADD CONSTRAINT edit_work_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE track_raw
   ADD CONSTRAINT track_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release_raw(id);

ALTER TABLE vote
   ADD CONSTRAINT vote_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

