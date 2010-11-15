BEGIN;


SELECT n.id, n.name, n.artist_count, t.ref_count
    INTO TEMPORARY tmp_artist_credit
    FROM artist_credit n JOIN
        (
            SELECT artist_credit, count(*) AS ref_count
            FROM (
                (SELECT artist_credit FROM recording) UNION ALL
                (SELECT artist_credit FROM release) UNION ALL
                (SELECT artist_credit FROM release_group) UNION ALL
                (SELECT artist_credit FROM track) UNION ALL
                (SELECT artist_credit FROM work)
            ) tbl
            GROUP BY artist_credit
        ) t ON t.artist_credit=n.id;

TRUNCATE artist_credit;
INSERT INTO artist_credit SELECT * FROM tmp_artist_credit;

SELECT * INTO TEMPORARY tmp_artist_credit_name
FROM artist_credit_name WHERE
    artist_credit IN (SELECT id FROM artist_credit);
TRUNCATE artist_credit_name;
INSERT INTO artist_credit_name SELECT * FROM tmp_artist_credit_name;

COMMIT;
