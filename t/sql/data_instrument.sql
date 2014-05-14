SET client_min_messages TO 'WARNING';

INSERT INTO link_attribute_type (id, root, child_order, gid, name, description, last_updated) VALUES
    (14, 14, 3, '0abd7f04-5e28-425b-956f-94789d9bcbe2', 'instrument', 'This attribute describes the possible instruments that can be captured as part of a performance.', '2011-09-21 11:29:05.11911-07');

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
       VALUES (4, '945c079d-374e-4436-9448-da92dedef3cf', 'Minimal Instrument');

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');

INSERT INTO instrument_annotation (instrument, annotation) VALUES (3, 1);
INSERT INTO instrument_annotation (instrument, annotation) VALUES (4, 2);

INSERT INTO instrument_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 3);

SELECT setval('instrument_type_id_seq', (SELECT MAX(id) FROM instrument_type));
SELECT setval('instrument_id_seq', (SELECT MAX(id) FROM instrument));
SELECT setval('annotation_id_seq', (SELECT MAX(id) FROM annotation));
SELECT setval('link_attribute_type_id_seq', (SELECT MAX(id) FROM link_attribute_type));
