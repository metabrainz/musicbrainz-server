\set ON_ERROR_STOP 1

BEGIN;

SET search_path = 'messaging';

CREATE INDEX edit_note_thanks_idx_edit_note ON edit_note_thanks (edit_note);

CREATE INDEX edit_thanks_idx_edit ON edit_thanks (edit);

CREATE INDEX hidden_message_idx_editor ON hidden_message (editor);

CREATE INDEX message_idx_sender ON message (sender);
CREATE INDEX message_idx_receiver ON message (receiver);

CREATE INDEX notification_idx_receiver ON notification (receiver);

COMMIT;
