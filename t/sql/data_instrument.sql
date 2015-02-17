SET client_min_messages TO 'WARNING';

INSERT INTO link_attribute_type (id, root, child_order, gid, name, description, last_updated) VALUES
    (14, 14, 3, '0abd7f04-5e28-425b-956f-94789d9bcbe2', 'instrument', 'This attribute describes the possible instruments that can be captured as part of a performance.', '2011-09-21 11:29:05.11911-07');

INSERT INTO link_creditable_attribute_type (attribute_type) VALUES (14);

INSERT INTO instrument_type (id, name) VALUES
    (1, 'Wind instrument'),
    (2, 'String instrument'),
    (3, 'Percussion instrument'),
    (4, 'Electronic instrument'),
    (5, 'Other instrument');

INSERT INTO instrument
    (id, gid, name, type, comment,
     description, last_updated)
    VALUES
    (3, '745c079d-374e-4436-9448-da92dedef3ce', 'Test Instrument', 2,
     'Yet Another Test Instrument', 'This is a description!', '2009-07-09');

INSERT INTO instrument (id, gid, name)
       VALUES (4, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Instrument'),
              (5, 'a56d18ae-485f-5547-a559-eba3efef04d0', 'Minimal Instrument 2');

INSERT INTO artist (id, gid, name, sort_name) VALUES
    (1, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 'David Bowie', 'David Bowie');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'David Bowie', 1);
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (1, 0, 1, 'David Bowie');

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '722190f8-f718-482f-a8bc-a8d479426a30', '“Heroes”', 1, 370000);

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');

INSERT INTO instrument_annotation (instrument, annotation) VALUES (3, 1);
INSERT INTO instrument_annotation (instrument, annotation) VALUES (4, 2);

INSERT INTO instrument_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 3);

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase, description)
    VALUES (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'recording', 'instrument', 'performed {additional} {instrument} on', 'has {additional} {instrument} performed by', 'performer', 'description');

INSERT INTO link_type_attribute_type(link_type, attribute_type) VALUES (1, 14);
INSERT INTO link (id, link_type, attribute_count) VALUES (1, 1, 2);
INSERT INTO link_attribute (link, attribute_type) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = '945c079d-374e-4436-9448-da92dedef3cf'));
INSERT INTO link_attribute_credit (link, attribute_type, credited_as) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = '945c079d-374e-4436-9448-da92dedef3cf'), 'blah instrument');
INSERT INTO link_attribute (link, attribute_type) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = 'a56d18ae-485f-5547-a559-eba3efef04d0'));
INSERT INTO link_attribute_credit (link, attribute_type, credited_as) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = 'a56d18ae-485f-5547-a559-eba3efef04d0'), 'stupid instrument');
INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (4, 1, 1, 1);

SELECT setval('instrument_type_id_seq', (SELECT MAX(id) FROM instrument_type));
SELECT setval('instrument_id_seq', (SELECT MAX(id) FROM instrument));
SELECT setval('annotation_id_seq', (SELECT MAX(id) FROM annotation));
SELECT setval('link_attribute_type_id_seq', (SELECT MAX(id) FROM link_attribute_type));
SELECT setval('link_id_seq', (SELECT MAX(id) FROM link));
