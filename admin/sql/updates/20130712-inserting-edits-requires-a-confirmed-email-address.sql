BEGIN;

CREATE OR REPLACE FUNCTION inserting_edits_requires_confirmed_email_address()
RETURNS trigger AS $$
BEGIN
  IF NOT (
    SELECT email_confirm_date IS NOT NULL AND email_confirm_date <= now()
    FROM editor
    WHERE editor.id = NEW.editor
  ) THEN
    RAISE EXCEPTION 'Editor tried to create edit without a confirmed email address';
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER inserting_edits_requires_confirmed_email_address BEFORE INSERT ON edit
    FOR EACH ROW EXECUTE PROCEDURE inserting_edits_requires_confirmed_email_address();

COMMIT;
