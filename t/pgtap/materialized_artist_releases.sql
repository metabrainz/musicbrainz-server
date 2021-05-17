SET search_path = 'musicbrainz', 'public';

BEGIN;

\ir ../sql/artist_release_sample_data.sql

INSERT INTO artist_release SELECT * FROM get_artist_release_rows(NULL);
INSERT INTO artist_release_group SELECT * FROM get_artist_release_group_rows(NULL);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT no_plan();

PREPARE sorted_artist_releases AS
SELECT jsonb_strip_nulls(jsonb_build_object(
    'is_track_artist', is_track_artist,
    'artist', artist,
    'first_release_date', first_release_date,
    'catalog_numbers', catalog_numbers,
    'country_code', country_code,
    'barcode', barcode,
    'sort_character', sort_character,
    'release', release
))
FROM artist_release
ORDER BY is_track_artist,
    artist,
    first_release_date NULLS LAST,
    catalog_numbers NULLS LAST,
    country_code NULLS LAST,
    barcode NULLS LAST,
    sort_character;

PREPARE sorted_artist_release_groups AS
SELECT jsonb_strip_nulls(jsonb_build_object(
    'is_track_artist', is_track_artist,
    'artist', artist,
    'unofficial', unofficial,
    'primary_type', primary_type,
    'secondary_types', secondary_types,
    'first_release_date', first_release_date,
    'sort_character', sort_character,
    'release_group', release_group
))
FROM artist_release_group
ORDER BY is_track_artist,
    artist,
    unofficial,
    primary_type NULLS FIRST,
    secondary_types NULLS FIRST,
    first_release_date NULLS LAST,
    sort_character;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 1
    }'::JSONB)
    $$
);

-- Test a_ins_release_slave_safe AFTER INSERT ON release

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release VALUES
    (2, '03475f88-adef-4bed-a3e4-01bd5b48f4ea', 'A', 60, 1, NULL, NULL, NULL, NULL, NULL, '', 0, -1, '2021-04-19 16:17:32.986082+00');

-- Constraints are set to IMMEDIATE in order to apply the changes from
-- the *_pending_update tables. This would normally happen at the end
-- of the transaction. (We first make sure they're reset to DEFERRED
-- above, otherwise the triggers meant to be DEFERRED may actually
-- run first and find that the *_pending_update tables are empty.)

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_ins_track_slave_safe AFTER INSERT ON track

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO medium (id, release, position, format, name, edits_pending, last_updated, track_count) VALUES
    (1, 2, 1, 1, 'A', 0, now(), 1);

INSERT INTO recording (id, gid, name, artist_credit, length, comment, edits_pending, last_updated, video) VALUES
	(1, '939e34d3-0aea-41d9-b296-b095993fbfe8', 'A', 2046742, 300000, '', 0, now(), FALSE);

INSERT INTO track (id, gid, recording, medium, position, number, name, artist_credit, length, edits_pending, last_updated, is_data_track) VALUES
    (1, 'b9d1c753-bf42-4010-a894-5d3f8fab7bfd', 1, 1, 1, '1', 'A', 2046742, 300000, 0, now(), FALSE);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_ins_release_group_slave_safe AFTER INSERT ON release_group

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO musicbrainz.release_group (id, gid, name, artist_credit, type, comment, edits_pending, last_updated) VALUES
	(2, '914a7adf-a4c0-4161-919b-21712d38cf1a', 'A', 60, NULL, '', 0, now());

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_upd_release_slave_safe AFTER UPDATE ON release

SET CONSTRAINTS ALL DEFERRED;

UPDATE release SET name = 'B' WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SET CONSTRAINTS ALL DEFERRED;

UPDATE release SET barcode = '1234567890' WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SET CONSTRAINTS ALL DEFERRED;

UPDATE release SET release_group = 2, status = 2 WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

SET CONSTRAINTS ALL DEFERRED;

UPDATE release SET artist_credit = 2046742 WHERE id = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SET CONSTRAINTS ALL DEFERRED;

UPDATE release SET artist_credit = 60 WHERE id = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_upd_track_slave_safe AFTER UPDATE ON track

SET CONSTRAINTS ALL DEFERRED;

UPDATE track SET artist_credit = 2060761 WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_ins_release_country_slave_safe AFTER INSERT ON release_country

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release_country (release, country) VALUES (2, 38);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "country_code": "CA",
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "country_code": "CA",
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "country_code": "CA",
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_upd_release_country_slave_safe AFTER UPDATE ON release_country

SET CONSTRAINTS ALL DEFERRED;

UPDATE release_country SET country = 222 WHERE release = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "country_code": "US",
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "country_code": "US",
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "country_code": "US",
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_del_release_country_slave_safe AFTER DELETE ON release_country

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release_country WHERE release = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_ins_release_label_slave_safe AFTER INSERT ON release_label

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release_label (release, label, catalog_number) VALUES
    (2, 95, 'ABC-123'),
    (2, 95, 'ABC-456');

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["ABC-123", "ABC-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["ABC-123", "ABC-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["ABC-123", "ABC-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_upd_release_label_slave_safe AFTER UPDATE ON release_label

SET CONSTRAINTS ALL DEFERRED;

UPDATE release_label SET catalog_number = 'DEF-456'
WHERE catalog_number = 'ABC-456';

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["ABC-123", "DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["ABC-123", "DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["ABC-123", "DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_del_release_label_slave_safe AFTER DELETE ON release_label

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release_label WHERE catalog_number = 'ABC-123';

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

-- Test a_ins_release_first_release_date_slave_safe AFTER INSERT ON release_first_release_date

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release_unknown_country (release, date_year, date_month, date_day) VALUES
    (1, 1990, 1, 1);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "first_release_date": 19900101,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "first_release_date": 19900101,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_upd_release_first_release_date_slave_safe AFTER UPDATE ON release_first_release_date
-- Test a_upd_release_group_meta_slave_safe AFTER UPDATE ON release_group_meta

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (1, 38, 1989, 1, 1);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "country_code": "CA",
        "first_release_date": 19890101,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "first_release_date": 19890101,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_del_release_first_release_date_slave_safe AFTER DELETE ON release_first_release_date

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release_country WHERE release = 1;
DELETE FROM release_unknown_country WHERE release = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_ins_release_group_secondary_type_join_slave_safe AFTER INSERT ON release_group_secondary_type_join

SET CONSTRAINTS ALL DEFERRED;

INSERT INTO release_group_secondary_type_join (release_group, secondary_type) VALUES
    (1, 1),
    (1, 2);

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [1, 2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "secondary_types": [1, 2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "secondary_types": [1, 2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_del_release_group_secondary_type_join_slave_safe AFTER DELETE ON release_group_secondary_type_join

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release_group_secondary_type_join
WHERE release_group = 1 AND secondary_type = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "A",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_upd_release_group_slave_safe AFTER UPDATE ON release_group

SET CONSTRAINTS ALL DEFERRED;

UPDATE release_group SET name = 'B' WHERE id = 1;
UPDATE release_group SET type = 1, artist_credit = 2046742 WHERE id = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "primary_type": 1,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 2107,
        "primary_type": 1,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 197,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": true,
        "artist": 2107,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB)
    $$
);

-- Test a_del_track_slave_safe AFTER DELETE ON track

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM track WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "barcode": 1234567890,
        "sort_character": "B",
        "release": 1
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "primary_type": 1,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 2107,
        "primary_type": 1,
        "unofficial": true,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB)
    $$
);

-- Test a_del_release_slave_safe AFTER DELETE ON release

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release WHERE id = 1;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_releases',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "catalog_numbers": ["DEF-456"],
        "sort_character": "A",
        "release": 2
    }'::JSONB)
    $$
);

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 60,
        "primary_type": 1,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB),
    ('{
        "is_track_artist": false,
        "artist": 2107,
        "primary_type": 1,
        "unofficial": false,
        "sort_character": "A",
        "release_group": 2
    }'::JSONB)
    $$
);

-- Test a_del_release_group_slave_safe AFTER DELETE ON release_group

SET CONSTRAINTS ALL DEFERRED;

DELETE FROM release_group WHERE id = 2;

SET CONSTRAINTS ALL IMMEDIATE;

SELECT results_eq(
    'sorted_artist_release_groups',
    $$VALUES
    ('{
        "is_track_artist": false,
        "artist": 60,
        "unofficial": false,
        "secondary_types": [2],
        "sort_character": "B",
        "release_group": 1
    }'::JSONB)
    $$
);

SELECT finish();

ROLLBACK;
