SET client_min_messages TO 'warning';

INSERT INTO artist (id, name, sort_name, gid) VALUES (1, 'Kate Bush', 'Kate Bush', '51024420-cae8-11de-8a39-0800200c9a66');
INSERT INTO artist_credit (id, name, artist_count, gid) VALUES (1, 'Kate Bush', 1, '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');
INSERT INTO artist_credit_name (artist_credit, artist, name, position, join_phrase) VALUES (1, 1, 'Kate Bush', 1, '');

INSERT INTO recording (id, name, artist_credit, gid) VALUES (1, 'King of the Mountain', 1, '3cf2f640-cae9-11de-8a39-0800200c9a66');

INSERT INTO isrc (isrc, recording) VALUES ('DEE250800230', 1);

