\set ON_ERROR_STOP 1
BEGIN;

CREATE TABLE edit_note_recipient (
    recipient           INTEGER NOT NULL, -- PK, references editor.id
    edit_note           INTEGER NOT NULL  -- PK, references edit_note.id
);

ALTER TABLE edit_note_recipient ADD CONSTRAINT edit_note_recipient_pkey PRIMARY KEY (recipient, edit_note);

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_recipient
   FOREIGN KEY (recipient)
   REFERENCES editor(id);

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_edit_note
   FOREIGN KEY (edit_note)
   REFERENCES edit_note(id);

-- Copying old data
INSERT INTO edit_note_recipient (recipient, edit_note) (
    SELECT edit.editor, edit_note.id
      FROM edit_note
      JOIN edit ON edit_note.edit = edit.id
);

CREATE INDEX edit_note_recipient_idx_editor ON edit_note_recipient (recipient);

-- Trigger

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

CREATE TRIGGER a_ins_edit_note AFTER INSERT ON edit_note
    FOR EACH ROW EXECUTE PROCEDURE a_ins_edit_note();

COMMIT;
