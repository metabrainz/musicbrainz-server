INSERT INTO editor (id, name, password, privs, email, website, bio, member_since,
        email_confirm_date, last_login_date, edits_accepted, edits_rejected,
        auto_edits_accepted, edits_failed, ha1)
    VALUES (1, 'new_editor', '{CLEARTEXT}password', 1+8+32, 'test@email.com', 'http://test.website',
        'biography', '1989-07-23', '2005-10-20', '2013-04-05', 12, 2, 59, 9, 'aa550c5b01407ef1f3f0d16daf9ec3c8'),
         (2, 'Alice', '{CLEARTEXT}secret1', 0, 'alice@example.com', 'http://example.com',
        'second biography', '2007-07-23', '2007-10-20', now(), 11, 3, 41, 8, 'e7f46e4f25ae38fcc952ef2b7edf0de9'),
         (3, 'kuno', '{CLEARTEXT}byld', 0, 'kuno@example.com', 'http://frob.nl',
        'donation check test user', '2010-03-25', '2010-03-25', now(), 0, 0, 0, 0, '00863261763ed5029ea051f87c4bbec3'),
         (4, 'ModBot', '{CLEARTEXT}mb', 0, '', 'http://musicbrainz.org/doc/ModBot',
         'See the above link for more information.', NULL, NULL, NULL, 2, 1, 99951, 3560, '9bcacf185adc9268d460694f78615c33');

INSERT INTO editor_preference (editor, name, value)
    VALUES (1, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (1, 'timezone', 'UTC'),
           (2, 'datetime_format', '%m/%d/%Y %H:%M:%S'),
           (2, 'timezone', 'UTC'),
           (2, 'public_ratings', '0');

INSERT INTO artist_name (id, name) VALUES (1, 'Name');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 1, 0, '');

INSERT INTO release_name (id, name) VALUES (1, 'Arrival');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 1, 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (2, 'a34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (3, 'b34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1),
           (4, 'c34c079d-374e-4436-9448-da92dedef3ce', 1, 1, 1);

INSERT INTO editor_subscribe_editor (editor, subscribed_editor, last_edit_sent)
   VALUES (2, 1, 3);

INSERT INTO editor_collection (id, gid, editor, name, public)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 2, 'kunos collection', FALSE),
           (2, 'd34c079d-374e-4436-9448-da92dedef3ce', 1, 'new_collection', TRUE);

INSERT INTO editor_collection_release (collection, release)
    VALUES (1, 1), (1, 2);


ALTER SEQUENCE editor_id_seq RESTART 5;
