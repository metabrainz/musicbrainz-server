SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name, comment)
    VALUES (1, '1aca11a5-1aca-11a5-1aca-11a51aca11a5', 'La Callas', 'La Callas', '');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'La Callas', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO artist_credit_name (artist_credit, position, name, artist)
    VALUES (1, 1, 'La Callas', 1);

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '2aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Release Group Name', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, '3aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Release Name', 1, 1);

INSERT INTO medium_format (id, gid, name, has_discids)
    VALUES (1411451, '4aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Format1', TRUE),
           (1411452, '5aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Format2', TRUE),
           (1411453, '6aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Format3', TRUE),
           (1411454, '7aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Format4', TRUE),
           (1411455, '8aca11a5-1aca-11a5-1aca-11a51aca11a5', 'Format5', TRUE);

INSERT INTO medium (id, release, position, format, name, track_count)
    VALUES (1, 1, 1, 1411451, 'Medium Name', 0);

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
    VALUES (30171, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee', 'foo@example.com', NOW()),
           (30172, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6', 'foo@example.com', NOW());

INSERT INTO edit (id, editor, type, status, open_time, expire_time)
    VALUES (1, 30171, /* EDIT_RELEASE_CREATE */ 31, 2, NOW() - INTERVAL '1 minute', NOW() - INTERVAL '1 minute'),
           (2, 30171, /* EDIT_RELEASE_EDIT   */ 51, 2, NOW() - INTERVAL '1 minute', NOW() - INTERVAL '1 minute'),
           (3, 30171, /* EDIT_MEDIUM_CREATE  */ 32, 2, NOW() - INTERVAL '1 second', NOW() - INTERVAL '1 second');

INSERT INTO edit_release (edit, release)
    VALUES (1, 1),
           (2, 1),
           (3, 1);
