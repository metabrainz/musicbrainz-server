SET search_path = 'musicbrainz', 'public';

SELECT no_plan();

BEGIN;

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'c63ecb0c-89af-4c26-928b-807402b1d701', 1, 1);

INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 1);
INSERT INTO artist_credit_name
    (artist_credit, artist, name, join_phrase, position)
  VALUES (1, 1, 1, NULL, 1);

INSERT INTO track_name (id, name)
  VALUES (1, 'Orphan'), (2, 'Multiple References');

INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '2e8ac33b-836e-4b43-be55-1e73eeb47618', 1, 1),
         (10, '5e8ac33b-836e-4b43-be55-1e73eeb47618', 1, 1);

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO track (id, position, number, artist_credit, name, recording, tracklist)
  VALUES (1, 1, '1', 1, 1, 1, 1);

-- Switch to a new recording
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (2, 'e2d026c2-3014-4ce6-871f-602fbcd0c921', 1, 1);

UPDATE track SET recording = 2 WHERE id = 1;

SELECT ok(
  (SELECT EXISTS (SELECT * FROM recording WHERE id = 1)),
  'old recording still exists'
);

-- Simulate the commit
SET CONSTRAINTS remove_orphaned_tracks IMMEDIATE;

SELECT ok(
  (SELECT NOT EXISTS (SELECT * FROM recording WHERE id = 1)),
  'old recording no longer exists'
);

SELECT ok(
  (SELECT EXISTS (SELECT * FROM recording WHERE id = 10)),
  'other recordings are not affected'
);

SELECT finish();
ROLLBACK;
