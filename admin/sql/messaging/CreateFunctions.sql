\set ON_ERROR_STOP 1

BEGIN;

-- Ensure hidden_message only contains the message's sender or receiver
CREATE OR REPLACE FUNCTION ensure_editor_is_connected_to_message()
RETURNS trigger AS $$
BEGIN
    IF NOT EXISTS (
      SELECT TRUE
        FROM message
        WHERE message.id = NEW.message
          AND (message.sender = NEW.editor OR message.receiver = NEW.editor)
    )
    THEN
        RAISE EXCEPTION 'A message can only be hidden for its sender or receiver';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

