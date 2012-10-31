\set ON_ERROR_STOP 1

BEGIN;

--------------------------------------------------------------------------------
-- Find all artist credits that have trailing whitespace
SELECT artist_credit, position
INTO TEMPORARY artist_credit_name_trailing
FROM (
  SELECT artist_credit, position
  FROM (
    SELECT artist_credit, position, join_phrase,
      row_number() OVER (PARTITION BY artist_credit ORDER BY position DESC)
    FROM artist_credit_name
  ) a
  WHERE join_phrase ~ E'\\s+$' AND row_number = 1
) b;

-- Find all artist credits that don't have collapsed whitespace
SELECT artist_credit, position
INTO TEMPORARY artist_credit_name_non_collapsed
FROM artist_credit_name
WHERE join_phrase ~ E'\\s{2,}';

-- Find all artist credits where credited names are not controlled for whitespace
SELECT artist_credit, position
INTO TEMPORARY artist_credit_name_non_controlled
FROM artist_credit_name
JOIN artist_name ON artist_credit_name.name = artist_name.id
WHERE NOT controlled_for_whitespace(artist_name.name);

--------------------------------------------------------------------------------
-- Remove trailing join phrase whitespace
UPDATE artist_credit_name SET join_phrase = regexp_replace(join_phrase, E'\\s+$', '')
WHERE (artist_credit, position) IN (
  SELECT artist_credit, position FROM artist_credit_name_trailing
);

-- Collapse whitespace in join phrases
UPDATE artist_credit_name
SET join_phrase = regexp_replace(join_phrase, E'\\s{2,}', ' ', 'g')
WHERE (artist_credit, position) IN (
  SELECT artist_credit, position FROM artist_credit_name_non_collapsed
);

-- Control whitespace for artist credit names
INSERT INTO artist_name (name)
SELECT DISTINCT btrim(regexp_replace(n.name, E'\\s{2,}', ' ', 'g'))
FROM artist_credit_name
JOIN artist_name n ON n.id = artist_credit_name.name
WHERE NOT EXISTS (
  SELECT TRUE FROM artist_name
  WHERE
    artist_name.name = btrim(regexp_replace(n.name, E'\\s{2,}', ' ', 'g'))
);

UPDATE artist_credit_name
SET name = (
  SELECT canonical.id
  FROM artist_name cur
  JOIN artist_name canonical
    ON (canonical.name = btrim(regexp_replace(cur.name, E'\\s{2,}', ' ', 'g')))
  WHERE cur.id = artist_credit_name.name
)
FROM artist_credit_name_non_controlled nc
WHERE artist_credit_name.artist_credit = nc.artist_credit
  AND artist_credit_name.position = nc.position;

-- If any artist credits have a credited name of the empty string, default them
-- to the artist's name.
SELECT artist_credit, position INTO TEMPORARY artist_credits_empty
FROM artist_credit_name acn
JOIN artist ON artist.id = acn.artist
JOIN artist_name acn_name ON acn_name.id = acn.name
JOIN artist a_name ON a_name.id = artist.name
WHERE acn_name.name ~ E'^\\s*$';

UPDATE artist_credit_name acn
SET name = artist.name
FROM artist
WHERE artist.id = acn.artist
  AND (artist_credit, position) IN (
    SELECT artist_credit, position FROM artist_credits_empty
  );

--------------------------------------------------------------------------------
-- Identify duplicate artist credits
SELECT
  all_merge[1] AS new_ac,
  unnest(all_merge[2:array_upper(all_merge, 1)]) AS old_ac
INTO TEMPORARY tmp_merge_artist_credits
FROM (
    SELECT array_agg(artist_credit ORDER BY artist_credit ASC) AS all_merge
    FROM (
        SELECT artist_credit,
          array_agg(artist_credit_name.name ORDER BY position) AS names,
          array_agg(coalesce(artist_credit_name.join_phrase, '') ORDER BY position) AS joins,
          array_agg(artist_credit_name.artist ORDER BY position) AS artists
        FROM artist_credit_name
        GROUP BY artist_credit
    ) s GROUP BY names, joins, artists HAVING count(*) > 1
) ss;

--------------------------------------------------------------------------------
-- Use the 'canonical' artist credit from a set of merges

-- The amount of recordings which use artist credits that are duplicated is small,
-- but PostgreSQL seems to think a sequential scan is the best strategy. Disable
-- it gets these updates running in seconds, not minutes.
SET enable_seqscan TO FALSE;

UPDATE recording SET artist_credit = new_ac
FROM tmp_merge_artist_credits
WHERE recording.artist_credit = old_ac;

UPDATE release SET artist_credit = new_ac
FROM tmp_merge_artist_credits
WHERE release.artist_credit = old_ac;

UPDATE release_group SET artist_credit = new_ac
FROM tmp_merge_artist_credits
WHERE release_group.artist_credit = old_ac;

UPDATE track SET artist_credit = new_ac
FROM tmp_merge_artist_credits
WHERE track.artist_credit = old_ac;

--------------------------------------------------------------------------------
-- Delete now unused artist credits (complete the merge)
DELETE FROM artist_credit_name
WHERE artist_credit IN (SELECT old_ac FROM tmp_merge_artist_credits);

DELETE FROM artist_credit
WHERE id IN (SELECT old_ac FROM tmp_merge_artist_credits);

--------------------------------------------------------------------------------
-- Regenerate properties in the 'artist_credit' table
SELECT
  artist_credit.id,
  string_agg(artist_name.name || coalesce(join_phrase, ''), '' ORDER BY position ASC) AS name,
  count(artist_credit_name.artist) AS count
INTO TEMPORARY artist_credit_materialized
FROM artist_credit
JOIN artist_credit_name ON artist_credit.id = artist_credit_name.artist_credit
JOIN artist_name ON artist_name.id = artist_credit_name.name
WHERE artist_credit IN (
  SELECT new_ac FROM tmp_merge_artist_credits
  UNION
  SELECT artist_credit FROM artist_credit_name_trailing
  UNION
  SELECT artist_credit FROM artist_credit_name_non_collapsed
  UNION
  SELECT artist_credit FROM artist_credit_name_non_controlled
  UNION
  SELECT artist_credit FROM artist_credits_empty
  UNION
  SELECT artist_credit.id FROM artist_credit
  JOIN artist_name ON artist_credit.name = artist_name.id
  WHERE NOT controlled_for_whitespace(artist_name.name)
)
GROUP BY artist_credit.id;

INSERT INTO artist_name (name)
SELECT DISTINCT name
FROM artist_credit_materialized
WHERE NOT EXISTS (
  SELECT TRUE
  FROM artist_name an
  WHERE an.name = artist_credit_materialized.name
);

UPDATE artist_credit SET
  name = (SELECT id FROM artist_name WHERE name = materialized.name),
  artist_count = materialized.count
FROM artist_credit_materialized materialized
WHERE materialized.id = artist_credit.id;

COMMIT;
