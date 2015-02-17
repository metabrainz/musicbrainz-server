
SET client_min_messages TO 'WARNING';

INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor1', '{CLEARTEXT}password', '0e5b1cce99adc89b535a3c6523c5410a'), (2, 'editor2', '{CLEARTEXT}password', '9ab932d00c88daf4a3ccf3a25e00f977'), (3, 'editor3', '{CLEARTEXT}password', '8226c71cd2dd007dc924910793b8ca83'), (4, 'editor4', '{CLEARTEXT}password', 'f0ab22e1a22cb1e60fea481f812450cb'), (5, 'editor5', '{CLEARTEXT}password', '3df132c9df92678048a6b25c5ad751ef');

INSERT INTO artist_tag_raw (tag, artist, editor) VALUES

    (1, 3, 1),

    (2, 3, 2),
    (2, 3, 3),
    (2, 3, 4),

    (1, 4, 1),
    (1, 4, 2),
    (1, 4, 3),
    (1, 4, 4),
    (1, 4, 5),

    (2, 4, 1),
    (2, 4, 2),
    (2, 4, 3),

    (3, 4, 4),
    (3, 4, 5),

    (4, 4, 2);


