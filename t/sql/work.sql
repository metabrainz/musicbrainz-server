BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE annotation CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE work_annotation CASCADE;
TRUNCATE work_gid_redirect CASCADE;
TRUNCATE work_name CASCADE;
TRUNCATE work_type CASCADE;
TRUNCATE work CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'ABBA');
INSERT INTO artist (id, gid, name, sortname)
    VALUES (1, '5f9913b0-7219-11de-8a39-0800200c9a66', 1, 1),
           (2, '5f9913b0-7219-11de-8a39-0800200c9a67', 1, 1);

INSERT INTO artist_credit (id, artistcount) VALUES (1, 1), (2, 2);
INSERT INTO artist_credit_name (artist_credit, position, artist, name, joinphrase)
    VALUES (1, 0, 1, 1, NULL), (2, 0, 2, 1, NULL);

INSERT INTO work_type (id, name) VALUES (1, 'Composition');
INSERT INTO work_name (id, name) VALUES (1, 'Dancing Queen'), (2, 'Test');

INSERT INTO work (id, gid, name, artist_credit, iswc, type, editpending, comment)
    VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 1, 1, 'T-000.000.001-0',
        1, 0, 'Work');

INSERT INTO work (id, gid, name, artist_credit, iswc)
    VALUES (2, '745c079d-374e-4436-9448-da92dedef3cf', 2, 2, 'T-000.000.002-0');

INSERT INTO work_gid_redirect VALUES ('28e73402-5666-4d74-80ab-c3734dc699ea', 1);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'password');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Annotation', 'change');
INSERT INTO work_annotation (work, annotation) VALUES (1, 1);

ALTER SEQUENCE work_id_seq RESTART 3;
ALTER SEQUENCE work_name_id_seq RESTART 3;

COMMIT;
