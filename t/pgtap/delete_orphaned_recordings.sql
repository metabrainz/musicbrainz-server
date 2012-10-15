SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'c63ecb0c-89af-4c26-928b-807402b1d701', 1, 1);

INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 1);
INSERT INTO artist_credit_name
    (artist_credit, artist, name, join_phrase, position)
  VALUES (1, 1, 1, '', 1);

INSERT INTO track_name (id, name)
  VALUES (1, 'Orphan');

INSERT INTO recording (id, gid, name, artist_credit, edits_pending)
  VALUES
    -- This recording was created by the release editor (will be an orphan)
    (1, '2e8ac33b-836e-4b43-be55-1e73eeb47618', 1, 1, 0),
    -- This recording is a standalone
    (2, '54b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 0),
    -- This recording is a historic standalone (ADD_TRACK)
    (3, '64b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 0),
    -- This recording is a historic standalone (ADD_TRACK_KV)
    (4, '74b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 0),
    -- This recording has edits pending
    (5, '84b9d183-7dab-42ba-94a3-7388a66604b8', 1, 1, 2),
    -- This recording is nothing to do with tests, and should not change
    (10, '5e8ac33b-836e-4b43-be55-1e73eeb47618', 1, 1, 0);

INSERT INTO editor (id, name, password) VALUES (1, 'editor', 'password');
INSERT INTO edit (id, type, editor, status, data, expire_time)
    VALUES (1, 71, 1, 2, '', now()), (2, 207, 1, 2, '', now()),
           (3, 218, 1, 1, '', now());
INSERT INTO edit_recording (edit, recording) VALUES (1, 2), (2, 3), (3, 4);

INSERT INTO tracklist (id) VALUES (1);
INSERT INTO track (id, position, number, artist_credit, name, recording, tracklist)
  VALUES (1, 1, '1', 1, 1, 1, 1),
         (2, 2, '2', 1, 1, 2, 1),
         (3, 3, '3', 1, 1, 3, 1),
         (4, 4, '4', 1, 1, 4, 1),
         (5, 5, '5', 1, 1, 5, 1);

-- Switch to a new recording
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (6, 'e2d026c2-3014-4ce6-871f-602fbcd0c921', 1, 1);

UPDATE track SET recording = 6 WHERE id IN (1, 2, 3, 4, 5);

SELECT bag_eq(
  'SELECT id FROM recording WHERE id IN (1, 2, 3, 4, 5)',
  'VALUES (1), (2), (3), (4), (5)',
  'old recordings still exist'
);

-- Simulate the commit
SET CONSTRAINTS remove_orphaned_tracks IMMEDIATE;

SELECT bag_eq(
  'SELECT id FROM recording WHERE id IN (1, 2, 3, 4, 5)',
  'VALUES (2), (3), (4), (5)',
  'all recordings except 1 still exist'
);

SELECT ok(
  (SELECT EXISTS (SELECT * FROM recording WHERE id = 10)),
  'other recordings are not affected'
);

SELECT finish();

ROLLBACK;
