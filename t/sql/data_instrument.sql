SET client_min_messages TO 'WARNING';

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

INSERT INTO artist_credit (id, name, artist_count, gid)
    VALUES (1, 'David Bowie', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, position, artist, name) VALUES (1, 0, 1, 'David Bowie');

INSERT INTO recording (id, gid, name, artist_credit, length) VALUES
    (1, '722190f8-f718-482f-a8bc-a8d479426a30', '“Heroes”', 1, 370000);

INSERT INTO annotation (id, editor, text) VALUES (1, 1, 'Test annotation 1');
INSERT INTO annotation (id, editor, text) VALUES (2, 1, 'Test annotation 2');

INSERT INTO instrument_annotation (instrument, annotation) VALUES (3, 1);
INSERT INTO instrument_annotation (instrument, annotation) VALUES (4, 2);

INSERT INTO instrument_gid_redirect VALUES ('a4ef1d08-962e-4dd6-ae14-e42a6a97fc11', 3);

INSERT INTO link (id, link_type, attribute_count) VALUES (1, 148, 2);
INSERT INTO link_attribute (link, attribute_type) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = '945c079d-374e-4436-9448-da92dedef3cf'));
INSERT INTO link_attribute_credit (link, attribute_type, credited_as) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = '945c079d-374e-4436-9448-da92dedef3cf'), 'blah instrument');
INSERT INTO link_attribute (link, attribute_type) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = 'a56d18ae-485f-5547-a559-eba3efef04d0'));
INSERT INTO link_attribute_credit (link, attribute_type, credited_as) VALUES (1, (SELECT id FROM link_attribute_type WHERE gid = 'a56d18ae-485f-5547-a559-eba3efef04d0'), 'stupid instrument');
INSERT INTO l_artist_recording (id, link, entity0, entity1) VALUES (4, 1, 1, 1);
