SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

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

INSERT INTO editor (id, name, password, ha1)
VALUES (1, 'New editor', '{CLEARTEXT}mb', '');

PREPARE insert_edit AS
INSERT INTO edit (editor, type, status, expire_time, data)
VALUES (1, 1, 1, now(), '');

SELECT throws_ok(
    'insert_edit',
    'Editor tried to create edit without a confirmed email address'
);

UPDATE editor SET email = 'foo@baz.com' WHERE name = 'New editor';

SELECT throws_ok(
    'insert_edit',
    'Editor tried to create edit without a confirmed email address'
);

UPDATE editor SET email_confirm_date = now() WHERE name = 'New editor';

SELECT lives_ok(
    'insert_edit'
);

ROLLBACK;
