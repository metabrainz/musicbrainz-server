BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE label_name CASCADE;
TRUNCATE label CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE work CASCADE;
TRUNCATE work_name CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Queen');
INSERT INTO artist (id, gid, name, sortname) VALUES
    (1, 'ad310a00-cae4-11de-8a39-0800200c9a66', 1, 1);
INSERT INTO artist_credit (id, artistcount) VALUES (1, 10);
INSERT INTO artist_credit_name (artist_credit, name, artist, position, joinphrase)
    VALUES (1, 1, 1, 1, NULL);
INSERT INTO label_name (id, name) VALUES (1, 'Warp Records');
INSERT INTO label (id, name, sortname, gid) VALUES
    (1, 1, 1, '5fdbdea0-cae5-11de-8a39-0800200c9a66');
INSERT INTO release_name (id, name) VALUES (1, 'Aerial');
INSERT INTO release_group (id, artist_credit, gid, name) VALUES
    (1, 1, '11b5c420-cae5-11de-8a39-0800200c9a66', 1);
INSERT INTO release (id, release_group, artist_credit, gid, name) VALUES
    (1, 1, 1, '20c868a0-cae5-11de-8a39-0800200c9a66', 1);
INSERT INTO work_name (id, name) VALUES (1, 'Dancing Queen');
INSERT INTO work (id, name, gid, artist_credit) VALUES (1, 1, '44d7f9e0-cae5-11de-8a39-0800200c9a66', 1);
    
COMMIT;