SET client_min_messages TO 'warning';

INSERT INTO work (id, gid, name, type, edits_pending, comment)
    VALUES (1, '745c079d-374e-4436-9448-da92dedef3ce', 'Dancing Queen',
        1, 0, 'Work');
INSERT INTO iswc (id, work, iswc) VALUES (1, 1, 'T-000.000.001-0');

INSERT INTO work (id, gid, name, type, edits_pending, comment)
    VALUES (5, '755c079d-374e-4436-9448-da92dedef3ce', 'Test',
        1, 0, 'Work');
INSERT INTO iswc (id, work, iswc) VALUES (2, 5, 'T-500.000.001-0'), (3, 5, 'T-500.000.002-0');

INSERT INTO work (id, gid, name, type, edits_pending, comment)
    VALUES (10, '105c079d-374e-4436-9448-da92dedef3ce', 'Test',
        1, 0, 'Work');

INSERT INTO work (id, gid, name) VALUES (2, '745c079d-374e-4436-9448-da92dedef3cf', 'Test');
INSERT INTO iswc (id, work, iswc) VALUES (4, 2, 'T-000.000.002-0');

INSERT INTO work_gid_redirect VALUES ('28e73402-5666-4d74-80ab-c3734dc699ea', 1);

INSERT INTO editor (id, name, password, ha1) VALUES (100, 'annotation_editor', '{CLEARTEXT}password', '41bd7f7951ccec2448f74bed1b7bc6cb');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 100, 'Annotation', 'change');
INSERT INTO work_annotation (work, annotation) VALUES (1, 1);
