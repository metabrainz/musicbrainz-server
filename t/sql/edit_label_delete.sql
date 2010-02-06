BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE label CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE country CASCADE;

INSERT INTO label_name (id, name) VALUES (1, 'Label Name');

INSERT INTO label (id, gid, name, sortname)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1);

INSERT INTO country (id, isocode, name) VALUES (1, 'GB', 'United Kingdom');

COMMIT;
