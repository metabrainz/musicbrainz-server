-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

ALTER TABLE cdtoc_raw
   ADD CONSTRAINT cdtoc_raw_fk_release
   FOREIGN KEY (release)
   REFERENCES release_raw(id);

ALTER TABLE edit_note
   ADD CONSTRAINT edit_note_fk_edit
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

