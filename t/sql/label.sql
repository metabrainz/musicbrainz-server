SET client_min_messages TO 'warning';

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');

INSERT INTO label_name (id, name) VALUES (1, 'Warp Records');
INSERT INTO label_name (id, name) VALUES (2, 'To Merge');

INSERT INTO label_type (id, name) VALUES (1, 'Production');

INSERT INTO label (id, gid, name, sort_name, type, area, label_code,
                   begin_date_year, begin_date_month, begin_date_day,
                   end_date_year, end_date_month, end_date_day, comment)
     VALUES (3, '46f0f4cd-8aab-4b33-b698-f459faf64190', 1, 1, 1, 221, 2070,
             1989, 02, 03, 2008, 05, 19, 'Sheffield based electronica label');

INSERT INTO label (id, gid, name, sort_name)
    VALUES (2, 'f2a9a3c0-72e3-11de-8a39-0800200c9a66', 2, 2);

INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834');
INSERT INTO annotation (id, editor, text, changelog) VALUES (1, 1, 'Label Annotation', 'Changes');
INSERT INTO label_annotation (label, annotation) VALUES (3, 1);

INSERT INTO label_gid_redirect (gid, new_id) VALUES ('efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592', 3);

ALTER SEQUENCE label_name_id_seq RESTART 4;
ALTER SEQUENCE label_id_seq RESTART 4;


