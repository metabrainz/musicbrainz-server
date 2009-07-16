BEGIN;


CREATE TABLE tmp_artist_credit (
    id                  SERIAL,
    artistcount         SMALLINT NOT NULL,
    refcount            INTEGER DEFAULT 0
);

INSERT INTO tmp_artist_credit
    SELECT n.id, n.artistcount, t.refcount
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

DROP TABLE artist_credit;
ALTER TABLE tmp_artist_credit RENAME TO artist_credit;
ALTER TABLE tmp_artist_credit_id_seq RENAME TO artist_credit_id_seq;
DELETE FROM artist_credit_name WHERE
    artist_credit NOT IN (SELECT id FROM artist_credit);


CREATE TABLE tmp_label_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL,
    refcount            INTEGER DEFAULT 0
);

INSERT INTO tmp_label_name
    SELECT n.id, n.name, t.refcount
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

DROP TABLE label_name;
ALTER TABLE tmp_label_name RENAME TO label_name;
ALTER TABLE tmp_label_name_id_seq RENAME TO label_name_id_seq;


CREATE TABLE tmp_artist_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL,
    refcount            INTEGER DEFAULT 0
);

INSERT INTO tmp_artist_name
    SELECT n.id, n.name, t.refcount
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

DROP TABLE artist_name;
ALTER TABLE tmp_artist_name RENAME TO artist_name;
ALTER TABLE tmp_artist_name_id_seq RENAME TO artist_name_id_seq;


CREATE TABLE tmp_release_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL,
    refcount            INTEGER DEFAULT 0
);

INSERT INTO tmp_release_name
    SELECT n.id, n.name, t.refcount
    FROM release_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM release) UNION ALL
                (SELECT name FROM release_group)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

DROP TABLE release_name;
ALTER TABLE tmp_release_name RENAME TO release_name;
ALTER TABLE tmp_release_name_id_seq RENAME TO release_name_id_seq;


CREATE TABLE tmp_track_name (
    id                  SERIAL,
    name                VARCHAR NOT NULL,
    refcount            INTEGER DEFAULT 0
);

INSERT INTO tmp_track_name
    SELECT n.id, n.name, t.refcount
    FROM track_name n JOIN
        (
            SELECT tbl.name, count(*) AS refcount
            FROM (
                (SELECT name FROM track) UNION ALL
                (SELECT name FROM recording)
            ) tbl
            GROUP BY tbl.name
        ) t ON t.name=n.id;

DROP TABLE track_name;
ALTER TABLE tmp_track_name RENAME TO track_name;
ALTER TABLE tmp_track_name_id_seq RENAME TO track_name_id_seq;


COMMIT;
