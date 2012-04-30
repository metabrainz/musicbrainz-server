BEGIN;

UPDATE artist_credit_name SET join_phrase = ''
WHERE (artist_credit, position) IN (
    SELECT artist_credit, position
    FROM artist_credit_name
    JOIN artist_credit ON artist_credit.id = artist_credit_name.artist_credit
    WHERE join_phrase ~ E'^\\s+$' AND position = artist_credit.artist_count - 1
);

SELECT all_merge[1] AS new_ac, unnest(all_merge[2:array_upper(all_merge, 1)]) AS old_ac
INTO TEMPORARY tmp_merge_artist_credits
FROM (
    SELECT array_agg(artist_credit ORDER BY artist_credit ASC) AS all_merge
    FROM (
        SELECT artist_credit, array_agg(artist_credit_name.name order by position) AS names,
            array_agg(COALESCE(artist_credit_name.join_phrase, '') order by position) AS joins,
            array_agg(artist_credit_name.artist order by position) AS artists
        FROM artist_credit_name GROUP BY artist_credit
    ) s GROUP BY names, joins, artists HAVING count(*) > 1
) ss;

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

DELETE FROM artist_credit_name WHERE artist_credit IN (SELECT old_ac FROM tmp_merge_artist_credits);
DELETE FROM artist_credit WHERE id IN (SELECT old_ac FROM tmp_merge_artist_credits);

COMMIT;
