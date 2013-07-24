SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

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

SELECT finish();
ROLLBACK;
