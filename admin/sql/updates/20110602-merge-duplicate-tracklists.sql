BEGIN;

SELECT all_merge[1] AS new_tl, unnest(all_merge[2:array_upper(all_merge, 1)]) AS old_tl
INTO TEMPORARY tmp_merge_tracklists
FROM (
    SELECT array_agg(tracklist ORDER BY tracklist ASC) AS all_merge
    FROM (
        SELECT tracklist, array_agg(track.name order by position) AS names,
            array_agg(track.recording order by position) AS recordings,
            array_agg(track.length order by position) AS lengths,
            array_agg(track.artist_credit order by position) AS credits
        FROM track GROUP BY tracklist
    ) s GROUP BY names, recordings, lengths, credits HAVING count(*) > 1
) ss;

UPDATE medium SET tracklist = new_tl
FROM tmp_merge_tracklists
WHERE medium.tracklist = old_tl;

DELETE FROM track WHERE tracklist IN (SELECT old_tl FROM tmp_merge_tracklists);
DELETE FROM tracklist WHERE id IN (SELECT old_tl FROM tmp_merge_tracklists);

COMMIT;
