
SET client_min_messages TO 'warning';

INSERT INTO editor (id, name, password, privs, email, website, bio, member_since,
        email_confirm_date, last_login_date, edits_accepted, edits_rejected,
        auto_edits_accepted, edits_failed)
    VALUES (1, 'new_editor', 'password', 1+8+32, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2009-01-01', 12, 2, 59, 9),
         (2, 'Alice', 'secret1', 0, 'alice@example.com', 'http://example.com',
        'second biography', '2007-07-23', '2007-10-20', '2009-12-05', 11, 3, 41, 8),
         (3, 'kuno', 'byld', 0, 'kuno@example.com', 'http://frob.nl',
        'donation check test user', '2010-03-25', '2010-03-25', '2010-03-25', 0, 0, 0, 0);

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (1, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (2, 2, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (3, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (4, 2, 123, 2, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (5, 3, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO artist_name (id, name) VALUES (1, 'artist');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '145c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (2, '245c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (3, '345c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (4, '445c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO label_name (id, name) VALUES (1, 'label');
INSERT INTO label (id, gid, name, sort_name)
    VALUES (1, '145c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 2);
INSERT INTO edit_label (edit, label) VALUES (2, 1);

SELECT setval('edit_id_seq', (SELECT max(id) FROM edit));


