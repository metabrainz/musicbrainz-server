\set ON_ERROR_STOP 1

BEGIN;

----------------------------------------
-- Calculate maximum tag count for each entity, this is used
-- later to weight relations between common tags.
----------------------------------------

CREATE TEMPORARY TABLE tmp_artist_tag_count
(
    id INTEGER NOT NULL,
    max_count INTEGER NOT NULL
);

CREATE TEMPORARY TABLE tmp_release_tag_count
(
    id INTEGER NOT NULL,
    max_count INTEGER NOT NULL
);

CREATE TEMPORARY TABLE tmp_label_tag_count
(
    id INTEGER NOT NULL,
    max_count INTEGER NOT NULL
);

CREATE TEMPORARY TABLE tmp_recording_tag_count
(
    id INTEGER NOT NULL,
    max_count INTEGER NOT NULL
);


INSERT INTO tmp_artist_tag_count SELECT
    a.id, MAX(t.count) AS max_count
FROM
    artist a
    JOIN artist_tag t ON t.artist = a.id
GROUP BY a.id;


INSERT INTO tmp_release_tag_count SELECT
    r.id, MAX(t.count) AS max_count
FROM
    release r
    JOIN release_tag t ON t.release = r.id
GROUP BY r.id;


INSERT INTO tmp_label_tag_count SELECT
    a.id, MAX(t.count) AS max_count
FROM
    label a
    JOIN label_tag t ON t.label = a.id
GROUP BY a.id;


INSERT INTO tmp_recording_tag_count SELECT
    a.id, MAX(t.count) AS max_count
FROM
    recording a
    JOIN recording_tag t ON t.recording = a.id
GROUP BY a.id;


CREATE UNIQUE INDEX tmp_artist_tag_count_id_idx ON tmp_artist_tag_count (id);
CREATE UNIQUE INDEX tmp_release_tag_count_id_idx ON tmp_release_tag_count (id);
CREATE UNIQUE INDEX tmp_label_tag_count_id_idx ON tmp_label_tag_count (id);
CREATE UNIQUE INDEX tmp_recording_tag_count_id_idx ON tmp_recording_tag_count (id);


----------------------------------------
-- Calculate weighted relations between tags from common tags on entities.
----------------------------------------


CREATE TEMPORARY TABLE tmp_artist_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_release_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_label_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_recording_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_area_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_instrument_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);

CREATE TEMPORARY TABLE tmp_series_tag_relation
(
    tag1 INTEGER NOT NULL,
    tag2 INTEGER NOT NULL,
    weight FLOAT NOT NULL
);


INSERT INTO tmp_artist_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    artist a
    JOIN artist_tag t1 ON t1.artist = a.id
    JOIN artist_tag t2 ON t2.artist = a.id
    LEFT JOIN tmp_artist_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_release_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    release a
    JOIN release_tag t1 ON t1.release = a.id
    JOIN release_tag t2 ON t2.release = a.id
    LEFT JOIN tmp_release_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_label_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    label a
    JOIN label_tag t1 ON t1.label = a.id
    JOIN label_tag t2 ON t2.label = a.id
    LEFT JOIN tmp_label_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_recording_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    recording a
    JOIN recording_tag t1 ON t1.recording = a.id
    JOIN recording_tag t2 ON t2.recording = a.id
    LEFT JOIN tmp_recording_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_area_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    area a
    JOIN area_tag t1 ON t1.area = a.id
    JOIN area_tag t2 ON t2.area = a.id
    LEFT JOIN tmp_area_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_instrument_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    instrument a
    JOIN instrument_tag t1 ON t1.instrument = a.id
    JOIN instrument_tag t2 ON t2.instrument = a.id
    LEFT JOIN tmp_instrument_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


INSERT INTO tmp_series_tag_relation SELECT
    t1.tag, t2.tag,
    SUM(((t1.count + t2.count) / 2.0) / tc.max_count) AS weight
FROM
    series a
    JOIN series_tag t1 ON t1.series = a.id
    JOIN series_tag t2 ON t2.series = a.id
    LEFT JOIN tmp_series_tag_count tc ON a.id = tc.id
WHERE t1.tag < t2.tag
GROUP BY t1.tag, t2.tag
HAVING COUNT(*) >= 3;


CREATE INDEX tmp_artist_tag_relation_tag1 ON tmp_artist_tag_relation (tag1);
CREATE INDEX tmp_artist_tag_relation_tag2 ON tmp_artist_tag_relation (tag2);

CREATE INDEX tmp_release_tag_relation_tag1 ON tmp_release_tag_relation (tag1);
CREATE INDEX tmp_release_tag_relation_tag2 ON tmp_release_tag_relation (tag2);

CREATE INDEX tmp_label_tag_relation_tag1 ON tmp_label_tag_relation (tag1);
CREATE INDEX tmp_label_tag_relation_tag2 ON tmp_label_tag_relation (tag2);

CREATE INDEX tmp_recording_tag_relation_tag1 ON tmp_recording_tag_relation (tag1);
CREATE INDEX tmp_recording_tag_relation_tag2 ON tmp_recording_tag_relation (tag2);

CREATE INDEX tmp_series_tag_relation_tag1 ON tmp_series_tag_relation (tag1);
CREATE INDEX tmp_series_tag_relation_tag2 ON tmp_series_tag_relation (tag2);

CREATE INDEX tmp_area_tag_relation_tag1 ON tmp_area_tag_relation (tag1);
CREATE INDEX tmp_area_tag_relation_tag2 ON tmp_area_tag_relation (tag2);

CREATE INDEX tmp_instrument_tag_relation_tag1 ON tmp_instrument_tag_relation (tag1);
CREATE INDEX tmp_instrument_tag_relation_tag2 ON tmp_instrument_tag_relation (tag2);

----------------------------------------
-- Join the temporary table and calculate the final weights.
----------------------------------------

TRUNCATE tag_relation;

INSERT INTO tag_relation SELECT
    COALESCE(r1.tag1, r2.tag1, r3.tag1, r4.tag1) AS tag1,
    COALESCE(r1.tag2, r2.tag2, r3.tag2, r4.tag2) AS tag2,
    COALESCE(r1.weight, 0) + COALESCE(r2.weight, 0) + COALESCE(r3.weight, 0) + COALESCE(r4.weight, 0) AS weight
FROM
    tmp_artist_tag_relation r1
    FULL OUTER JOIN tmp_release_tag_relation r2
        ON (r2.tag1 = r1.tag1 AND r2.tag2 = r1.tag2)
    FULL OUTER JOIN tmp_label_tag_relation r3
        ON (r3.tag1 = COALESCE(r1.tag1, r2.tag1) AND r3.tag2 = COALESCE(r1.tag2, r2.tag2))
    FULL OUTER JOIN tmp_recording_tag_relation r4
        ON (r4.tag1 = COALESCE(r1.tag1, r2.tag1, r3.tag1) AND r4.tag2 = COALESCE(r1.tag2, r2.tag2, r3.tag2));

/*

Usage:

SELECT
   t1.name, t2.name, tr.weight
FROM
   tag t1
   JOIN tag_relation tr ON t1.id = tr.tag1 OR t1.id = tr.tag2
   JOIN tag t2 ON t1.id != t2.id AND (t2.id = tr.tag1 OR t2.id = tr.tag2)
WHERE
   t1.name = 'jazz'
ORDER BY tr.weight DESC;

*/

COMMIT;

VACUUM ANALYZE tag_relation;
