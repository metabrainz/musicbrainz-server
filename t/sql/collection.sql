SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 'Name', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (2, 'a34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (3, 'b34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (4, 'c34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1);

INSERT INTO event (id, gid, name, type) VALUES
       (1, 'eb668bdc-a928-49a1-beb7-8e37db2a5b65', 'Cool Festival', 2),
       (2, 'ebbfa8cc-a4b8-11e4-9e22-8f887e1ba67a', 'Better Festival', 2),
       (3, 'bb857d0e-a4bc-11e4-a0f5-23485fda2851', 'Copy of the Better Festival', 2),
       (4, 'e024804e-a4c4-11e4-884d-df918190e80e', 'Another Event', 2);

INSERT INTO work (id, gid, name, type, edits_pending, comment) VALUES
    (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen', 1, 0, 'Work'),
    (2, '755c079d-374e-4436-9448-da92dedef3cf', 'Test', 1, 0, 'Another Work');

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES
(1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee', 'foo@example.com', now()),
(2, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6', 'foo@example.com', now()),
(3, 'editor3', '{CLEARTEXT}pass', 'c096994132d53f3e1cde757943b10e7d', 'foo@example.com', now());

INSERT INTO editor_collection (id, gid, editor, name, public, description, type)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3cd', 1, 'collection1', FALSE, '', 1),
           (2, 'f34c079d-374e-4436-9448-da92dedef3cb', 2, 'collection2', TRUE, 'Testy!', 1),
           (3, 'f34c079d-374e-4436-9448-da92dedef3c9', 1, 'event_collection1', FALSE, '', 4),
           (4, '24375a7a-a4bd-11e4-a92c-3b5e54a633eb', 1, 'event_collection2', FALSE, '', 4),
           (5, '24375a7a-a4bd-11e4-a92c-3b5e54a633ec', 1, 'work_collection', FALSE, '', 15),
           (6, 'a34c079d-374e-4436-9448-da92dedef3cb', 2, 'collection2_priv', FALSE, 'Private Testy!', 1);

INSERT INTO editor_collection_release (collection, release)
    VALUES (1, 1), (1, 3), (2, 2), (2, 4);

INSERT INTO editor_collection_event (collection, event, added, position, comment)
    VALUES (3, 2, NOW(), 1, ''),
           (4, 3, NOW(), 1, ''),
           (3, 4, NOW(), 1, 'testy1'),
           (4, 4, '2014-11-05 03:00:13.359654+00', 2, 'testy2');

INSERT INTO editor_collection_work (collection, work)
    VALUES (5, 1), (5, 2);

INSERT INTO editor_preference (id, editor, name, value)
    VALUES (1, 1, 'timezone', 'Antarctica/Troll'),
           (2, 2, 'timezone', 'Atlantic/Reykjavik'),
           (3, 3, 'timezone', 'Pacific/Kiritimati');

INSERT INTO editor_subscribe_collection (id, editor, collection, last_edit_sent, available, last_seen_name)
    VALUES (1, 2, 1, 0, FALSE, 'collection1'),
           (2, 2, 2, 0, TRUE, NULL);

INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 32, 1, NOW()),
           (2, 1, 32, 2, NOW()),
           (3, 1, 32, 1, NOW());
INSERT INTO edit_data (edit, data)
    VALUES (1, '{"entity":{"name":"Arrival","id":2},"new":{"name":"Departure"},"old":{"name":"Arrival"}}'),
           (2, '{"entity":{"name":"Arrival","id":4},"new":{"name":"Departure"},"old":{"name":"Arrival"}}'),
           (3, '{"entity":{"name":"Arrival","id":3},"new":{"name":"Departure"},"old":{"name":"Arrival"}}');

INSERT INTO edit_release (edit, release)
    VALUES (1, 2), (2, 4), (3, 3);
