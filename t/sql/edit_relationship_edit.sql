BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE link_type CASCADE;
TRUNCATE link CASCADE;
TRUNCATE l_artist_artist CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Name');

INSERT INTO artist (id, gid, name, sortname) VALUES
    (1, '945c079d-374e-4436-9448-da92dedef3cf', 1, 1),
    (2, '75a40343-ff6e-45d6-a5d2-110388d34858', 1, 1);

INSERT INTO link_type (id, gid, entitytype0, entitytype1, name, linkphrase, rlinkphrase, shortlinkphrase)
    VALUES
        (1, '7610b0e9-40c1-48b3-b06c-2c1d30d9dc3e', 'artist', 'artist', 'member', 'foo', 'oof', 'f'),
        (2, '254815bb-390a-4eed-bc50-1f25ba66fa68', 'artist', 'artist', 'support', 'foo', 'oof', 'f');

INSERT INTO link (id, link_type, attributecount) VALUES (1, 1, 0);

INSERT INTO l_artist_artist (id, link, entity0, entity1) VALUES (1, 1, 1, 2);

COMMIT;
