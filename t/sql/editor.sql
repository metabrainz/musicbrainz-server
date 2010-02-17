BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE editor CASCADE;
TRUNCATE editor_preference;
TRUNCATE editor_subscribe_editor;

INSERT INTO editor (id, name, password, privs, email, website, bio, membersince,
        emailconfirmdate, lastlogindate, editsaccepted, editsrejected,
        autoeditsaccepted, editsfailed)
    VALUES (1, 'new_editor', 'password', 1+8+32, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (2, 'Alice', 'secret1', 1+8+32, 'alice@example.com', 'http://example.com',
        'second biography', '2007-07-23', '2007-10-20', '2009-12-05', 11, 3, 41, 8);

INSERT INTO editor_preference (editor, name, value)
    VALUES (1, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (1, 'timezone', 'UTC'),
           (1, 'public_ratings', '0'),
           (2, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (2, 'timezone', 'UTC'),
           (2, 'public_ratings', '0'),
           (2, 'public_collection', '0');

INSERT INTO editor_subscribe_editor (editor, subscribededitor, lasteditsent)
   VALUES (2, 1, 3);

ALTER SEQUENCE editor_id_seq RESTART 3;

COMMIT;
