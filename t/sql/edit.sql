
SET client_min_messages TO 'warning';




INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (1, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (2, 2, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (3, 1, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (4, 2, 123, 2, '{ "key": "value" }', NOW());

INSERT INTO edit (id, editor, type, status, data, expire_time)
    VALUES (5, 3, 123, 1, '{ "key": "value" }', NOW());

INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 2);
INSERT INTO edit_label (edit, label) VALUES (2, 1);

SELECT setval('edit_id_seq', (SELECT max(id) FROM edit));


