SET search_path = 'musicbrainz';

BEGIN;

SELECT id INTO TEMPORARY cleanup
FROM editor
WHERE (password IS NULL OR password = '')
  AND name LIKE 'Deleted Editor #%';

UPDATE editor SET
  password = '',
  privs = 0,
  email = NULL,
  email_confirm_date = NULL,
  website = NULL,
  bio = NULL,
  country = NULL,
  birth_date = NULL,
  gender = NULL
WHERE id IN (SELECT id FROM cleanup);

DELETE FROM editor_language WHERE editor IN (SELECT id FROM cleanup);

COMMIT;
