SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

INSERT INTO artist (id, gid, name, sort_name) VALUES (1, '6a84ba85-1428-41ef-934f-7b9ef6d227ce', 'name', 'name');

INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'name', 1);

INSERT INTO release_group (id, gid, artist_credit, name) VALUES (1, '1e95786d-5ead-4626-be49-4357af6d4c21', 1, 'name');

INSERT INTO release (id, gid, release_group, artist_credit, name)
VALUES (1, '958f7767-51bb-4884-bcfc-4be8098f55b6', 1, 1, 'name');

PREPARE first_release_date AS
SELECT first_release_date_year, first_release_date_month, first_release_date_day
FROM release_group_meta
WHERE id = 1;

SELECT results_eq(
  'first_release_date',
  'VALUES (null::smallint, null::smallint, null::smallint)'
);

INSERT INTO release_unknown_country (release, date_year)
VALUES (1, 2000);

SELECT results_eq(
  'first_release_date',
  'VALUES (2000::smallint, null::smallint, null::smallint)'
);

INSERT INTO area (id, gid, name, sort_name) VALUES (1, '4fb0478c-6327-47f6-81b8-cfb35df3f0f2', 'Area', 'Area');
INSERT INTO country_area (area) VALUES (1);

INSERT INTO release_country (release, country, date_year, date_month, date_day)
VALUES (1, 1, 1999, 01, 04);

SELECT results_eq(
  'first_release_date',
  'VALUES (1999::smallint, 01::smallint, 04::smallint)'
);

UPDATE release_unknown_country SET date_year = 1990, date_day = 05 WHERE release = 1;

SELECT results_eq(
  'first_release_date',
  'VALUES (1990::smallint, null::smallint, 05::smallint)'
);

DELETE FROM release_unknown_country;

SELECT results_eq(
  'first_release_date',
  'VALUES (1999::smallint, 01::smallint, 04::smallint)'
);

DELETE FROM release_country;

SELECT results_eq(
  'first_release_date',
  'VALUES (null::smallint, null::smallint, null::smallint)'
);

SELECT finish();
ROLLBACK;
