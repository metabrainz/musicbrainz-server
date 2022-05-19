SET client_min_messages TO 'WARNING';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (3, 'e2a083a9-9942-4d6e-b4d2-8397320b95f7', 'Artist 1', 'Artist 1'),
           (4, '2fed031c-0e89-406e-b9f0-3d192637907a', 'Artist 2', 'Artist 2');

INSERT INTO tag (id, name)
     VALUES (1, 'musical'),
            (2, 'rock'),
            (3, 'jazz'),
            (4, 'world music');

INSERT INTO editor (id, name, password, ha1)
     VALUES (11, 'editor1', '{CLEARTEXT}password', '0e5b1cce99adc89b535a3c6523c5410a'),
            (12, 'editor2', '{CLEARTEXT}password', '9ab932d00c88daf4a3ccf3a25e00f977'),
            (13, 'editor3', '{CLEARTEXT}password', '8226c71cd2dd007dc924910793b8ca83'),
            (14, 'editor4', '{CLEARTEXT}password', 'f0ab22e1a22cb1e60fea481f812450cb'),
            (15, 'editor5', '{CLEARTEXT}password', '3df132c9df92678048a6b25c5ad751ef');

INSERT INTO artist_tag_raw (tag, artist, editor)
     VALUES (1, 3, 11),
            (2, 3, 12),
            (2, 3, 13),
            (2, 3, 14),
            (1, 4, 11),
            (1, 4, 12),
            (1, 4, 13),
            (1, 4, 14),
            (1, 4, 15),
            (2, 4, 11),
            (2, 4, 12),
            (2, 4, 13),
            (3, 4, 14),
            (3, 4, 15),
            (4, 4, 12);
