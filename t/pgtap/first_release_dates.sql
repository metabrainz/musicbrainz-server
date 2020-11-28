SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

INSERT INTO artist (id, gid, name, sort_name) VALUES (1, '6a84ba85-1428-41ef-934f-7b9ef6d227ce', 'name', 'name');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'name', 1);

INSERT INTO release_group (id, gid, artist_credit, name)
VALUES
  (1, '1e95786d-5ead-4626-be49-4357af6d4c21', 1, 'name'),
  (2, '9f811f64-acdb-4c92-a4ab-6e9a5a2f96e5', 1, 'name');

INSERT INTO release (id, gid, release_group, artist_credit, name)
VALUES
  -- release 1 has rg 1
  (1, '958f7767-51bb-4884-bcfc-4be8098f55b6', 1, 1, 'name'),
  -- releases 2 & 3 share rg 2
  (2, '1d57a1dd-7ff0-40c5-81fe-844f8f833efc', 2, 1, 'name'),
  (3, 'a20d2fe3-6309-4b56-b903-5a85e602375c', 2, 1, 'name');

INSERT INTO medium (id, release, position, format, name)
VALUES (1, 1, 1, 1, ''), (2, 2, 1, 1, ''), (3, 3, 1, 1, '');

-- recording 1 is shared by all 3 releases
INSERT INTO recording (id, gid, name, artist_credit, length)
VALUES (1, '180adb03-6714-49a0-9bad-17098a42aba5', 'name', 1, 1000);

INSERT INTO track (id, gid, medium, position, number, recording, name, artist_credit, length)
VALUES
  (1, '6572410f-34af-4c63-b94e-8f17b36645b9', 1, 1, '1', 1, 'name', 1, 1000),
  (2, '568b34bc-c359-4d37-a7c2-2dad7ef193d9', 2, 1, '1', 1, 'name', 1, 1000),
  (3, '9466b38a-3a95-494c-8e0d-8184309af829', 3, 1, '1', 1, 'name', 1, 1000);

PREPARE all_release_first_release_dates AS
SELECT *
FROM release_first_release_date
ORDER BY release;

PREPARE release_group_first_release_dates AS
SELECT id, first_release_date_year, first_release_date_month, first_release_date_day
FROM release_group_meta
ORDER BY id ASC;

PREPARE recording_1_first_release_date AS
SELECT year, month, day
FROM recording_first_release_date
WHERE recording = 1;

SELECT results_eq(
  'all_release_first_release_dates',
  'SELECT 1 WHERE false'
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, null::smallint, null::smallint, null::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'SELECT 1 WHERE false'
);

INSERT INTO release_unknown_country (release, date_year)
VALUES (1, 2000);

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 2000::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 2000::smallint, null::smallint, null::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (2000::smallint, null::smallint, null::smallint)'
);

INSERT INTO area (id, gid, name) VALUES (1, '4fb0478c-6327-47f6-81b8-cfb35df3f0f2', 'Area');
INSERT INTO country_area (area) VALUES (1);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (1, 1, 1999, 01, 04);

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1999::smallint, 01::smallint, 04::smallint)'
);

UPDATE release_unknown_country SET date_year = 1990, date_day = 05 WHERE release = 1;

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1990::smallint, null::smallint, 5::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1990::smallint, null::smallint, 5::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1990::smallint, null::smallint, 05::smallint)'
);

UPDATE release_unknown_country SET release = 2 WHERE release = 1;

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1990::smallint, null::smallint, 5::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1990::smallint, null::smallint, 5::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1990::smallint, null::smallint, 05::smallint)'
);

UPDATE release_unknown_country SET date_year = 1989, date_day = NULL WHERE release = 2;

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1989::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1989::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1989::smallint, null::smallint, null::smallint)'
);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (3, 1, 1970, 11, NULL);

INSERT INTO release_unknown_country (release, date_year, date_month, date_day)
VALUES (3, 1970, 11, NULL);

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1989::smallint, null::smallint, null::smallint),
      (3::integer, 1970::smallint, 11::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1970::smallint, 11::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1970::smallint, 11::smallint, null::smallint)'
);

DELETE FROM release_unknown_country;

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (3::integer, 1970::smallint, 11::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, 1970::smallint, 11::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1970::smallint, 11::smallint, null::smallint)'
);

DELETE FROM release_country WHERE date_year = 1970;

SELECT results_eq(
  'all_release_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint)
  $$
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, 1999::smallint, 1::smallint, 4::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'VALUES (1999::smallint, 01::smallint, 04::smallint)'
);

DELETE FROM release_country;

SELECT results_eq(
  'all_release_first_release_dates',
  'SELECT 1 WHERE false'
);

SELECT results_eq(
  'release_group_first_release_dates',
  $$
    VALUES
      (1::integer, null::smallint, null::smallint, null::smallint),
      (2::integer, null::smallint, null::smallint, null::smallint)
  $$
);

SELECT results_eq(
  'recording_1_first_release_date',
  'SELECT 1 WHERE false'
);

SELECT finish();
ROLLBACK;
