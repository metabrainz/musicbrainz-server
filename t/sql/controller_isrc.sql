
SET client_min_messages TO 'warning';









INSERT INTO artist_name (id, name) VALUES (1, 'Kate Bush');
INSERT INTO artist (id, name, sort_name, gid) VALUES (1, 1, 1, '51024420-cae8-11de-8a39-0800200c9a66');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (1, 1, 1, 1, '');

INSERT INTO track_name (id, name) VALUES (1, 'King of the Mountain');
INSERT INTO recording (id, name, artist_credit, gid) VALUES (1, 1, 1, '3cf2f640-cae9-11de-8a39-0800200c9a66');

INSERT INTO isrc (isrc, recording) VALUES ('DEE250800230', 1);

