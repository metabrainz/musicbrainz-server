SET client_min_messages TO 'warning';

INSERT INTO label_name (id, name) VALUES (1, 'Name');
INSERT INTO label_name (id, name) VALUES (2, 'Empty Label');
INSERT INTO label_name (id, name) VALUES (3, 'Alias 1');
INSERT INTO label_name (id, name) VALUES (4, 'Alias 2');

INSERT INTO label (id, gid, name, sort_name, comment)
    VALUES (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1, ''),
           (2, '73371ea0-7217-11de-8a39-0800200c9a66', 2, 2, ''),
           (3, '686cdcc0-7218-11de-8a39-0800200c9a66', 1, 1, 'Other label');

INSERT INTO label_alias (id, label, name, sort_name) VALUES (1, 1, 3, 3);
INSERT INTO label_alias (id, label, name, sort_name) VALUES (2, 1, 4, 4);
INSERT INTO label_alias (id, label, name, sort_name) VALUES (3, 3, 4, 4);

ALTER SEQUENCE label_name_id_seq RESTART 5;
ALTER SEQUENCE label_alias_id_seq RESTART 4;


