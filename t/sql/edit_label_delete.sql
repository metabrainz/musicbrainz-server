
SET client_min_messages TO 'warning';


INSERT INTO label_type (id, name) VALUES (1, 'Official production');


INSERT INTO label_name (id, name) VALUES (1, 'Label Name');

INSERT INTO label (id, gid, name, sort_name)
    VALUES (2, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO area_type (id, name) VALUES (1, 'Country');
INSERT INTO area (id, gid, name, sort_name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 'United Kingdom', 1);
INSERT INTO country_area (area) VALUES (221);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');

INSERT INTO label_ipi (label, ipi) VALUES (2, '00284373936');

INSERT INTO label_isni (label, isni) VALUES (2, '1422458635730476');

ALTER SEQUENCE label_name_id_seq RESTART 100;

