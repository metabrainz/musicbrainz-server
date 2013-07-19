
SET client_min_messages TO 'WARNING';





INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}pass', '16a4862191803cb596ee4b16802bb7ee'), (2, 'editor2', '{CLEARTEXT}pass', 'ba025a52cc5ff57d5d10f31874a83de6'), (3, 'editor3', '{CLEARTEXT}pass', 'c096994132d53f3e1cde757943b10e7d'), (4, 'editor4', '{CLEARTEXT}pass', '404dea695f616eadd86ede9951d1494e');

SELECT setval('label_id_seq', 99);

INSERT INTO artist_name (id, name) VALUES (1, 'Artist 1'), (2, 'Artist 2');
INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
           (4, '5441c29d-3602-4898-b1a1-b77fa23b8e50', 2, 2);

