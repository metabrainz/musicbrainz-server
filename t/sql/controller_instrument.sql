SET client_min_messages TO 'warning';

-- To avoid entering a duplicate link_attribute_type
ALTER TABLE instrument DISABLE TRIGGER a_ins_instrument;

INSERT INTO instrument (id, gid, name, type, edits_pending, last_updated, comment, description)
  VALUES (62, '089f123c-0f7d-4105-a64e-49de81ca8fa4', 'violin', 2, 0,
         '2021-11-04 15:33:33.580302+00', 'Soprano of modern violin family',
         'The most famous member of the violin family, it is actually the "small viol". Its register is soprano and it''s a principal member of the symphony orchestra.');

ALTER TABLE instrument ENABLE TRIGGER a_ins_instrument;

INSERT INTO editor (id, name, password, ha1)
  VALUES (1, 'editor1', '{CLEARTEXT}pass', '343cbae85500be826a413b9b6b242669');

INSERT INTO annotation (id, editor, text)
  VALUES (1, 1, 'Test annotation 1');

INSERT INTO instrument_annotation (instrument, annotation)
  VALUES (62, 1);


-- Artist for tab data testing

INSERT INTO artist (id, gid, name, sort_name)
  VALUES (396487, '77e13fe3-a607-4ede-b94e-fa66d1050797', 'Salvatore Accardo', 'Accardo, Salvatore');

INSERT INTO artist_credit (id, artist_count, name, gid)
  VALUES (1297074, 1, 'Salvatore Accardo', 'c746d89b-d96d-3d6c-9214-b4bf4cd13653');

INSERT INTO artist_credit_name (artist_credit, position, artist, name)
  VALUES (1297074, 0, 396487, 'Salvatore Accardo');


-- Violin teacher for artist

INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1814950, 'faf537b9-5c3d-463c-9560-794d4b0bf7cd', 'Anastasiya Petryshak', 'Petryshak, Anastasiya');

INSERT INTO link (id, link_type, attribute_count)
  VALUES (593041, 847, 0);

INSERT INTO link_attribute (link, attribute_type)
  VALUES (593041, 86);

INSERT INTO l_artist_artist (id, link, entity0, entity1)
  VALUES (449800, 593041, 396487, 1814950);


-- Violin performance on recording

INSERT INTO recording (id, gid, name, artist_credit, length)
  VALUES (1299240, 'cc821538-3dfe-44ca-b421-64aee3e951b0', '24 Capricci per violino solo, op. 1: 1. Andante. E-dur', 1297074, 108000);

INSERT INTO link (id, link_type, attribute_count)
  VALUES (23339, 148, 0);

INSERT INTO link_attribute (link, attribute_type)
  VALUES (23339, 86);

INSERT INTO link_attribute_credit (link, attribute_type, credited_as)
  VALUES (23339, 86, 'violino');

INSERT INTO l_artist_recording (id, link, entity0, entity1)
  VALUES (3497346, 23339, 396487, 1299240);


-- Violin performance on release

INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (557046, 'e29a8105-5744-3572-a2dd-aeb77217480f', 'Diabolus in Musica - Accardo interpreta Paganini', 1297074);

INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (221010, '8b23b2cd-e9b7-4b3f-bc5d-406f0945e5af', 'Diabolus in Musica - Accardo interpreta Paganini', 1297074, 557046);

INSERT INTO link (id, link_type, attribute_count)
  VALUES (31, 44, 0);

INSERT INTO link_attribute (link, attribute_type)
  VALUES (31, 86);

INSERT INTO l_artist_release (id, link, entity0, entity1)
  VALUES (100037, 31, 396487, 221010);
