BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE annotation CASCADE;
TRUNCATE editor CASCADE;
TRUNCATE label CASCADE;
TRUNCATE label_annotation CASCADE;
TRUNCATE label_gid_redirect CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE label_type CASCADE;

INSERT INTO label_name (id, name) VALUES (1, 'Warp Records');
INSERT INTO label_name (id, name) VALUES (2, 'To Merge');

INSERT INTO label_type (id, name) VALUES (1, 'Production');

INSERT INTO label (id, gid, name, sortname, type, country, labelcode,
                   begindate_year, begindate_month, begindate_day,
                   enddate_year, enddate_month, enddate_day, comment)
     VALUES (1, '46f0f4cd-8aab-4b33-b698-f459faf64190', 1, 1, 1, 1, 2070,
             1989, 02, 03, 2008, 05, 19, 'Sheffield based electronica label');

INSERT INTO label (id, gid, name, sortname)
    VALUES (2, 'f2a9a3c0-72e3-11de-8a39-0800200c9a66', 2, 2);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'pass');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Label Annotation', 'Changes');
INSERT INTO label_annotation (label, annotation) VALUES (1, 1);

INSERT INTO label_gid_redirect (gid, newid) VALUES ('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592', 1);

ALTER SEQUENCE label_name_id_seq RESTART 3;
ALTER SEQUENCE label_id_seq RESTART 3;

COMMIT;
