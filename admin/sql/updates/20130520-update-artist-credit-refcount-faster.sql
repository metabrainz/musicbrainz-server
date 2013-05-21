\set ON_ERROR_STOP 1

BEGIN;
    CREATE TEMPORARY TABLE track_ac_count AS SELECT artist_credit, count(*) FROM track GROUP BY artist_credit;
    CREATE TEMPORARY TABLE release_ac_count AS SELECT artist_credit, count(*) FROM release GROUP BY artist_credit;
    CREATE TEMPORARY TABLE release_group_ac_count AS SELECT artist_credit, count(*) FROM release_group GROUP BY artist_credit;
    CREATE TEMPORARY TABLE recording_ac_count AS SELECT artist_credit, count(*) FROM recording GROUP BY artist_credit;

    CREATE TABLE artist_credit_new AS
    SELECT
        artist_credit.id,
        artist_credit.name,
        artist_credit.artist_count,
        coalesce(track_ac_count.count, 0) + coalesce(release_ac_count.count, 0) + coalesce(release_group_ac_count.count, 0) + coalesce(recording_ac_count.count, 0) AS ref_count,
        artist_credit.created
    FROM
        artist_credit
        LEFT JOIN track_ac_count ON track_ac_count.artist_credit=artist_credit.id
        LEFT JOIN release_ac_count ON release_ac_count.artist_credit=artist_credit.id
        LEFT JOIN release_group_ac_count ON release_group_ac_count.artist_credit=artist_credit.id
        LEFT JOIN recording_ac_count ON recording_ac_count.artist_credit=artist_credit.id;
COMMIT;
