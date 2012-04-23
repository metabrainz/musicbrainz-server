BEGIN;

CREATE TABLE release_group_secondary_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE release_group_secondary_type_join (
    release_group INTEGER NOT NULL REFERENCES release_group (id),
    secondary_type INTEGER NOT NULL REFERENCES release_group_secondary_type (id),
    PRIMARY KEY (release_group, secondary_type)
);

ALTER TABLE release_group_type RENAME to release_group_primary_type;

INSERT INTO release_group_secondary_type (id, name) VALUES
(1, 'Compilation'), (2, 'Soundtrack'), (3, 'Spokenword'), (4, 'Interview'), (5, 'Live'), (6, 'Remix');

SELECT setval('release_group_secondary_type_id_seq', (SELECT MAX(id) FROM release_group_secondary_type));

-- Migrate secondary type attributes
INSERT INTO release_group_secondary_type_join (release_group, secondary_type)
SELECT id, CASE type
    WHEN 4 THEN 1  -- Compilation
    WHEN 5 THEN 2  -- Soundtrack
    WHEN 6 THEN 3  -- Spokenword
    WHEN 7 THEN 4  -- Interview
    WHEN 9 THEN 5  -- Live
    WHEN 10 THEN 6 -- Remix
END
FROM release_group
WHERE type IN ( 4, 5, 6, 7, 9, 10 );

-- Change references to no longer valid primary types
UPDATE release_group
SET type = CASE type
  WHEN 6 THEN 11 -- Spokenword becomes 'other'
  WHEN 7 THEN 11 -- Interview becomes 'other'
END
WHERE type IN ( 6, 7 );

-- Attempt to guess albums/singles based on:
-- * > 20 minutes duration
-- * More than 1 distinct track name, after stripping ETI
UPDATE release_group
SET type = CASE satisfies_album_criteria
  WHEN TRUE THEN 1
  ELSE NULL
END
FROM (
  SELECT rg_id, bool_and(
    (has_unknown_lengths OR total_length > 1200000) -- 20 minutes
    AND
    (track_count >= 6)
  ) satisfies_album_criteria
  FROM
  (
      SELECT release_group.id AS rg_id, release.id AS r_id,
        sum(track.length) AS total_length,
        count(track.id) AS track_count,
        bool_or(track.length IS NULL) AS has_unknown_lengths
      FROM release_group
      JOIN release ON release.release_group = release_group.id
      JOIN medium ON medium.release = release.id
      JOIN track ON medium.tracklist = track.tracklist
      WHERE type IN (4, 5, 9, 10)
      GROUP BY release_group.id, release.id
  ) s
  GROUP BY rg_id
) rgs
WHERE rgs.rg_id = release_group.id;

-- These remaining release groups have no releases
UPDATE release_group
SET type = NULL
FROM (
  SELECT id
  FROM (
    SELECT release_group.id,
      (SELECT count(1) release_count FROM release
       WHERE release_group = release_group.id) release_count
    FROM release_group
    WHERE TYPE IN (4, 5, 6, 7, 9, 10)
  ) s
  WHERE release_count = 0
) rgs
WHERE rgs.id = release_group.id;

-- Remove old primary type
DELETE FROM release_group_primary_type WHERE id IN ( 4, 5, 6, 7, 9, 10 );

COMMIT;
