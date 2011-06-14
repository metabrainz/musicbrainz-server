
SET client_min_messages TO 'WARNING';

INSERT INTO editor (id, name, password) VALUES (1, 'editor1', 'password'),
                                               (2, 'editor2', 'password'),
                                               (3, 'editor3', 'password'),
                                               (4, 'editor4', 'password'),
                                               (5, 'editor5', 'password');

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


