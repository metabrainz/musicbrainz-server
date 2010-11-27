BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE editor CASCADE;
TRUNCATE editor_preference;
TRUNCATE editor_subscribe_editor;
TRUNCATE list CASCADE;
TRUNCATE list_release CASCADE;

INSERT INTO editor (id, name, password, privs, email, website, bio, member_since,
        email_confirm_date, last_login_date, edits_accepted, edits_rejected,
        auto_edits_accepted, edits_failed)
    VALUES (1, 'new_editor', 'password', 1+8+32, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (2, 'Alice', 'secret1', 0, 'alice@example.com', 'http://example.com',
        'second biography', '2007-07-23', '2007-10-20', '2009-12-05', 11, 3, 41, 8),
         (3, 'kuno', 'byld', 0, 'kuno@example.com', 'http://frob.nl',
        'donation check test user', '2010-03-25', '2010-03-25', '2010-03-25', 0, 0, 0, 0);

INSERT INTO editor_preference (editor, name, value)
    VALUES (1, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (1, 'timezone', 'UTC'),
           (2, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (2, 'timezone', 'UTC'),
           (2, 'public_ratings', '0');

INSERT INTO editor_subscribe_editor (editor, subscribed_editor, last_edit_sent)
   VALUES (2, 1, 3);

ALTER SEQUENCE editor_id_seq RESTART 4;

INSERT INTO list (id, gid, editor, name, public) VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 2, 'kunos collection', FALSE), (2, 'd34c079d-374e-4436-9448-da92dedef3ce', 1, 'new_collection', TRUE);
INSERT INTO list_release (list, release)
    VALUES (1, 1), (1, 2);

COMMIT;
