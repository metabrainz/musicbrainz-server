\set ON_ERROR_STOP 1
BEGIN;

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_recipient
   FOREIGN KEY (recipient)
   REFERENCES editor(id);

ALTER TABLE edit_note_recipient
   ADD CONSTRAINT edit_note_recipient_fk_edit_note
   FOREIGN KEY (edit_note)
   REFERENCES edit_note(id);

CREATE TRIGGER a_ins_edit_note AFTER INSERT ON edit_note
    FOR EACH ROW EXECUTE PROCEDURE a_ins_edit_note();

COMMIT;
