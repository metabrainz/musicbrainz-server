-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'messaging';

ALTER TABLE edit_note_thanks DROP CONSTRAINT IF EXISTS edit_note_thanks_pkey;
ALTER TABLE edit_thanks DROP CONSTRAINT IF EXISTS edit_thanks_pkey;
ALTER TABLE hidden_message DROP CONSTRAINT IF EXISTS hidden_message_pkey;
ALTER TABLE message DROP CONSTRAINT IF EXISTS message_pkey;
ALTER TABLE notification DROP CONSTRAINT IF EXISTS notification_pkey;
