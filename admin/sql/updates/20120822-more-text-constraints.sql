\set ON_ERROR_STOP 1

--------------------------------------------------------------------------------
-- These are needed to speed up deletion
CREATE INDEX tmp_artist_alias_name ON artist_alias (name);
CREATE INDEX tmp_artist_alias_sort_name ON artist_alias (sort_name);
CREATE INDEX tmp_artist_credit_name_name ON artist_credit_name (name);
CREATE INDEX tmp_artist_credit_name ON artist_credit (name);
CREATE INDEX tmp_track_name_corrected ON track_name (controlled_for_whitespace(name));

BEGIN;

DELETE FROM artist_name WHERE NOT controlled_for_whitespace(name);

--------------------------------------------------------------------------------
UPDATE url SET description = btrim(regexp_replace(description, E'\\s{2,}', ' ', 'g'))
WHERE NOT controlled_for_whitespace(description);

--------------------------------------------------------------------------------
SELECT recording.id,
  btrim(regexp_replace(track_name.name, E'\\s{2,}', ' ', 'g')) AS correct_name
INTO TEMPORARY invalid_recordings
FROM recording
JOIN track_name ON track_name.id = recording.name
WHERE NOT controlled_for_whitespace(track_name.name);

SELECT track.id,
  btrim(regexp_replace(track_name.name, E'\\s{2,}', ' ', 'g')) AS correct_name
INTO TEMPORARY invalid_tracks
FROM track
JOIN track_name ON track_name.id = track.name
WHERE NOT controlled_for_whitespace(track_name.name);

INSERT INTO track_name (name)
SELECT n FROM (
  SELECT correct_name n FROM invalid_recordings
  UNION
  SELECT correct_name n FROM invalid_tracks
) s
WHERE NOT EXISTS (SELECT TRUE FROM track_name WHERE name = n);

UPDATE recording
SET name = (SELECT id FROM track_name WHERE name = correct_name)
FROM invalid_recordings inv
WHERE recording.id = inv.id;

UPDATE track
SET name = (SELECT id FROM track_name WHERE name = correct_name)
FROM invalid_tracks inv
WHERE track.id = inv.id;

DELETE FROM track_name WHERE NOT controlled_for_whitespace(name);

--------------------------------------------------------------------------------
DROP INDEX tmp_artist_alias_name;
DROP INDEX tmp_artist_alias_sort_name;
DROP INDEX tmp_artist_credit_name_name;
DROP INDEX tmp_artist_credit_name;
DROP INDEX tmp_track_name_corrected;

COMMIT;
