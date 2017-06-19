SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '32552f80-755f-11de-8a39-0800200c9a66', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist', 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 'Artist', 1, 0, '');

INSERT INTO work (id, gid, name) VALUES (1, '581556f0-755f-11de-8a39-0800200c9a66', 'Traits (remix)');

INSERT INTO work_attribute_type (id, gid, name, free_text)
    VALUES (1, '325c079d-374e-4436-9448-da92dedef3ca', 'Attribute', false),
           (2, '525c079d-374e-4436-9448-da92dedef3cd', 'Type two', true);

INSERT INTO work_attribute_type_allowed_value (id, gid, work_attribute_type, value)
    VALUES (10, 'b598f04f-5918-4713-aebc-f7d3d9c2d089', 1, 'Value'),
           (2, '12a64964-902d-4917-9036-d505dafce0b4', 1, 'Value 2');
