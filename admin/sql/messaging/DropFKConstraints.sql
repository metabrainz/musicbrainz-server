-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'messaging';

ALTER TABLE edit_note_thanks DROP CONSTRAINT IF EXISTS edit_note_thanks_fk_edit_note;
ALTER TABLE edit_note_thanks DROP CONSTRAINT IF EXISTS edit_note_thanks_fk_thanker;
ALTER TABLE edit_thanks DROP CONSTRAINT IF EXISTS edit_thanks_fk_edit;
ALTER TABLE edit_thanks DROP CONSTRAINT IF EXISTS edit_thanks_fk_thanker;
ALTER TABLE hidden_message DROP CONSTRAINT IF EXISTS hidden_message_fk_message;
ALTER TABLE hidden_message DROP CONSTRAINT IF EXISTS hidden_message_fk_editor;
ALTER TABLE message DROP CONSTRAINT IF EXISTS message_fk_sender;
ALTER TABLE message DROP CONSTRAINT IF EXISTS message_fk_receiver;
ALTER TABLE message DROP CONSTRAINT IF EXISTS message_fk_parent;
ALTER TABLE notification DROP CONSTRAINT IF EXISTS notification_fk_receiver;
