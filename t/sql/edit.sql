BEGIN;
SET client_min_messages TO 'warning';
TRUNCATE edit CASCADE;
TRUNCATE edit_artist CASCADE;

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (1, 1, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (2, 2, 123, 2, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (3, 1, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (4, 2, 123, 2, '<d><key>value</key></d>', NOW());

INSERT INTO edit (id, editor, type, status, data, expiretime)
    VALUES (5, 3, 123, 1, '<d><key>value</key></d>', NOW());

INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 1);
INSERT INTO edit_artist (edit, artist) VALUES (4, 2);

SELECT setval('edit_id_seq', (SELECT max(id) FROM edit));

COMMIT;
