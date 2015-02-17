SET client_min_messages TO 'warning';

INSERT INTO artist (id, gid, name, sort_name)
    VALUES (1, '32552f80-755f-11de-8a39-0800200c9a66', 'Artist', 'Artist');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Artist', 1);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, join_phrase)
    VALUES (1, 'Artist', 1, 0, '');

INSERT INTO recording (id, gid, name, artist_credit, comment)
    VALUES (1, '581556f0-755f-11de-8a39-0800200c9a66', 'Traits (remix)', 1, 'a comment');
