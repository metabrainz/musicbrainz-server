BEGIN;
SET client_min_messages TO 'warning';

TRUNCATE artist CASCADE;
TRUNCATE artist_credit CASCADE;
TRUNCATE artist_credit_name CASCADE;
TRUNCATE artist_name CASCADE;
TRUNCATE cdtoc CASCADE;
TRUNCATE medium CASCADE;
TRUNCATE medium_cdtoc CASCADE;
TRUNCATE release CASCADE;
TRUNCATE release_group CASCADE;
TRUNCATE release_name CASCADE;
TRUNCATE tracklist CASCADE;

INSERT INTO artist_name (id, name) VALUES (1, 'Kate Bush');
INSERT INTO artist (id, name, sortname, gid) VALUES (1, 1, 1, '51024420-cae8-11de-8a39-0800200c9a66');
INSERT INTO artist_credit (id, artistcount) VALUES (1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, position, joinphrase) VALUES (1, 1, 1, 1, NULL);

INSERT INTO release_name (id, name) VALUES (1, 'Aerial');
INSERT INTO release_group (id, name, artist_credit, gid) VALUES
    (1, 1, 1, '768b07e0-cae8-11de-8a39-0800200c9a66');
INSERT INTO release (id, name, artist_credit, release_group, gid) VALUES
    (1, 1, 1, 1, '85455330-cae8-11de-8a39-0800200c9a66');

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO medium (id, release, tracklist, position) VALUES (1, 1, 1, 1);
    
INSERT INTO cdtoc (id, discid, freedbid, trackcount, leadoutoffset, trackoffset) VALUES
    (1, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-', '5908ea07', 7, 171327,
     ARRAY[150,22179,49905,69318,96240,121186,143398]);

INSERT INTO medium_cdtoc (id, medium, cdtoc) VALUES
    (1, 1, 1);

COMMIT;