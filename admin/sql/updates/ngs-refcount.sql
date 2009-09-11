BEGIN;


SELECT n.id, n.artistcount, t.refcount
    INTO TEMPORARY tmp_artist_credit
    FROM artist_credit n JOIN
        (
            SELECT artist_credit, count(*) AS refcount
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


SELECT n.id, n.name, t.refcount
    INTO TEMPORARY tmp_label_name
    FROM label_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM label) UNION ALL
                (SELECT sortname AS name FROM label) UNION ALL
                (SELECT name FROM label_alias)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

TRUNCATE label_name;
INSERT INTO label_name SELECT * FROM tmp_label_name;


SELECT n.id, n.name, t.refcount
    INTO TEMPORARY tmp_artist_name
    FROM artist_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM artist) UNION ALL
                (SELECT sortname AS name FROM artist) UNION ALL
                (SELECT name FROM artist_alias) UNION ALL
                (SELECT name FROM artist_credit_name)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

TRUNCATE artist_name;
INSERT INTO artist_name SELECT * FROM tmp_artist_name;


SELECT n.id, n.name, t.refcount
    INTO TEMPORARY tmp_release_name
    FROM release_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM release) UNION ALL
                (SELECT name FROM release_group)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

TRUNCATE release_name;
INSERT INTO release_name SELECT * FROM tmp_release_name;


SELECT n.id, n.name, t.refcount
    INTO TEMPORARY tmp_track_name
    FROM track_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM track) UNION ALL
                (SELECT name FROM recording)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

TRUNCATE track_name;
INSERT INTO track_name SELECT * FROM tmp_track_name;

COMMIT;
