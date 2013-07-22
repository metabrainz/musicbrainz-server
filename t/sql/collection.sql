
SET client_min_messages TO 'warning';

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

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES
(1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee', 'foo@example.com', now()),
(2, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6', 'foo@example.com', now()),
(3, 'editor3', '{CLEARTEXT}pass', 'c096994132d53f3e1cde757943b10e7d', 'foo@example.com', now());
INSERT INTO editor_collection (id, gid, editor, name, public, description)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3cd', 1, 'collection1', FALSE, ''),
           (2, 'f34c079d-374e-4436-9448-da92dedef3cb', 2, 'collection2', TRUE, 'Testy!');
ALTER SEQUENCE editor_collection_id_seq RESTART 3;

INSERT INTO editor_collection_release (collection, release)
    VALUES (1, 1), (1, 3), (2, 2), (2, 4);

INSERT INTO editor_subscribe_collection (id, editor, collection, last_edit_sent, available, last_seen_name)
    VALUES (1, 2, 1, 0, FALSE, 'collection1'),
           (2, 2, 2, 0, TRUE, NULL);

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (1, 1, 32, 1, '{"entity":{"name":"Arrival","id":2},"new":{"name":"Departure"},"old":{"name":"Arrival"}}', NOW()),
           (2, 1, 32, 2, '{"entity":{"name":"Arrival","id":4},"new":{"name":"Departure"},"old":{"name":"Arrival"}}', NOW()),
           (3, 1, 32, 1, '{"entity":{"name":"Arrival","id":3},"new":{"name":"Departure"},"old":{"name":"Arrival"}}', NOW());

INSERT INTO edit_release (edit, release)
    VALUES (1, 2), (2, 4), (3, 3);
