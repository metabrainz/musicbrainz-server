-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'messaging';

ALTER TABLE edit_note_thanks
   ADD CONSTRAINT edit_note_thanks_fk_edit_note
   FOREIGN KEY (edit_note)
   REFERENCES edit_note(id);

ALTER TABLE edit_note_thanks
   ADD CONSTRAINT edit_note_thanks_fk_thanker
   FOREIGN KEY (thanker)
   REFERENCES editor(id);

ALTER TABLE edit_thanks
   ADD CONSTRAINT edit_thanks_fk_edit
   FOREIGN KEY (edit)
   REFERENCES edit(id);

ALTER TABLE edit_thanks
   ADD CONSTRAINT edit_thanks_fk_thanker
   FOREIGN KEY (thanker)
   REFERENCES editor(id);

ALTER TABLE hidden_message
   ADD CONSTRAINT hidden_message_fk_message
   FOREIGN KEY (message)
   REFERENCES message(id);

ALTER TABLE hidden_message
   ADD CONSTRAINT hidden_message_fk_editor
   FOREIGN KEY (editor)
   REFERENCES editor(id);

ALTER TABLE message
   ADD CONSTRAINT message_fk_sender
   FOREIGN KEY (sender)
   REFERENCES editor(id);

ALTER TABLE message
   ADD CONSTRAINT message_fk_receiver
   FOREIGN KEY (receiver)
   REFERENCES editor(id);

ALTER TABLE message
   ADD CONSTRAINT message_fk_parent
   FOREIGN KEY (parent)
   REFERENCES message(id);

ALTER TABLE notification
   ADD CONSTRAINT notification_fk_receiver
   FOREIGN KEY (receiver)
   REFERENCES editor(id);

