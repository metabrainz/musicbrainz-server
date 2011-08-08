
SET client_min_messages TO 'warning';


INSERT INTO label_type (id, name) VALUES (1, 'Official production');


INSERT INTO label_name (id, name) VALUES (1, 'Label Name');

INSERT INTO label (id, gid, name, sort_name)
    VALUES (2, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO country (id, iso_code, name) VALUES (1, 'GB', 'United Kingdom');


