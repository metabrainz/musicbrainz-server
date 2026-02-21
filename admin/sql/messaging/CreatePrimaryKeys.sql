-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'messaging';

ALTER TABLE edit_note_thanks ADD CONSTRAINT edit_note_thanks_pkey PRIMARY KEY (edit_note, thanker);
ALTER TABLE edit_thanks ADD CONSTRAINT edit_thanks_pkey PRIMARY KEY (edit, thanker);
ALTER TABLE hidden_message ADD CONSTRAINT hidden_message_pkey PRIMARY KEY (message, editor);
ALTER TABLE message ADD CONSTRAINT message_pkey PRIMARY KEY (id);
ALTER TABLE notification ADD CONSTRAINT notification_pkey PRIMARY KEY (id);
