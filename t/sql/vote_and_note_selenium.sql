SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'Name', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase)
    VALUES (1, 1, 'Name', 0, '');

INSERT INTO release_group (id, gid, name, artist_credit)
    VALUES (1, '3b4faa80-72d9-11de-8a39-0800200c9a66', 'Arrival', 1);

INSERT INTO release (id, gid, name, artist_credit, release_group)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (2, 'a34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (3, 'b34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1),
           (4, 'c34c079d-374e-4436-9448-da92dedef3ce', 'Arrival', 1, 1);

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES
(1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee', 'foo@example.com', now());

INSERT INTO edit (id, editor, type, status, expire_time)
    VALUES (1, 1, 32, 1, NOW() + interval '72 hours'),
           (2, 1, 32, 1, NOW() + interval '72 hours'),
           (3, 1, 32, 1, NOW() + interval '72 hours');
INSERT INTO edit_data (edit, data)
    VALUES (1, '{"entity":{"name":"Arrival","id":2},"new":{"name":"Departure"},"old":{"name":"Arrival"}}'),
           (2, '{"entity":{"name":"Arrival","id":4},"new":{"name":"Departure"},"old":{"name":"Arrival"}}'),
           (3, '{"entity":{"name":"Arrival","id":3},"new":{"name":"Departure"},"old":{"name":"Arrival"}}');

INSERT INTO edit_release (edit, release)
    VALUES (1, 2), (2, 4), (3, 3);
