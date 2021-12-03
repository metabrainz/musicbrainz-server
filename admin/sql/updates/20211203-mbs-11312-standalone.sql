\set ON_ERROR_STOP 1

BEGIN;

-- Foreign keys

ALTER TABLE edit_note_change
   ADD CONSTRAINT edit_note_change_fk_edit_note
   FOREIGN KEY (edit_note)
   REFERENCES edit_note(id);

ALTER TABLE edit_note_change
   ADD CONSTRAINT edit_note_change_fk_change_editor
   FOREIGN KEY (change_editor)
   REFERENCES editor(id);

COMMIT;
