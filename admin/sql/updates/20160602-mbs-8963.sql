\set ON_ERROR_STOP 1
BEGIN;

CREATE OR REPLACE FUNCTION a_ins_edit_note() RETURNS trigger AS $$
BEGIN
    INSERT INTO edit_note_recipient (recipient, edit_note) (
        SELECT edit.editor, NEW.id
          FROM edit
         WHERE edit.id = NEW.edit
           AND edit.editor != NEW.editor
    );
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

DELETE FROM edit_note_recipient
    USING edit_note, edit
    WHERE edit_note_recipient.edit_note = edit_note.id
      AND edit_note.edit = edit.id
      AND edit_note.editor = edit.editor
      AND edit.editor = edit_note_recipient.recipient;

COMMIT;
