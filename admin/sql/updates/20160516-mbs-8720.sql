\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE edit_note_recipient (
    recipient           INTEGER NOT NULL, -- PK, references editor.id
    edit_note           INTEGER NOT NULL  -- PK, references edit_note.id
);

-- Copying old data
INSERT INTO edit_note_recipient (recipient, edit_note) (
    SELECT edit.editor, edit_note.id
      FROM edit_note
      JOIN edit ON edit_note.edit = edit.id
);

ALTER TABLE edit_note_recipient ADD CONSTRAINT edit_note_recipient_pkey PRIMARY KEY (recipient, edit_note);

CREATE OR REPLACE FUNCTION a_ins_edit_note() RETURNS trigger AS $$
BEGIN
    INSERT INTO edit_note_recipient (recipient, edit_note) (
        SELECT edit.editor, NEW.id
          FROM edit
         WHERE edit.id = NEW.edit
    );
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
