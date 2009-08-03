BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE editor CASCADE;
TRUNCATE editor_preference;

INSERT INTO editor (id, name, password, privs, email, website, bio, membersince,
        emailconfirmdate, lastlogindate, editsaccepted, editsrejected,
        autoeditsaccepted, editsfailed)
    VALUES (1, 'new_editor', 'password', 1, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9);

INSERT INTO editor_preference (editor, name, value)
    VALUES (1, 'datetimeformat', '%m/%d/%Y %H:%M:%S'),
           (1, 'timezone', 'CEST'),
           (1, 'public_ratings', '0');

ALTER SEQUENCE editor_id_seq RESTART 2;

COMMIT;
