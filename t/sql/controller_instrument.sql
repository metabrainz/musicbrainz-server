SET client_min_messages TO 'warning';

INSERT INTO instrument (id, gid, name, type, edits_pending, last_updated, comment, description)
  VALUES (62, '089f123c-0f7d-4105-a64e-49de81ca8fa4', 'violin', 2, 0,
         '2021-11-04 15:33:33.580302+00', 'Soprano of modern violin family',
         'The most famous member of the violin family, it is actually the "small viol". Its register is soprano and it''s a principal member of the symphony orchestra.');

INSERT INTO editor (id, name, password, ha1)
  VALUES (1, 'editor1', '{CLEARTEXT}pass', '343cbae85500be826a413b9b6b242669');

INSERT INTO annotation (id, editor, text)
  VALUES (1, 1, 'Test annotation 1');

INSERT INTO instrument_annotation (instrument, annotation)
  VALUES (62, 1);
