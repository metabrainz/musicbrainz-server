\set ON_ERROR_STOP 1

BEGIN;

SELECT id AS release, country, date_year, date_month, date_day
INTO release_country
FROM release
WHERE country IS NOT NULL;

SELECT id AS release, date_year, date_month, date_day
INTO release_unknown_country
FROM release
WHERE country IS NULL;

ALTER TABLE release_country
  ADD PRIMARY KEY (release, country);

ALTER TABLE release_unknown_country
  ADD PRIMARY KEY (release);

ALTER TABLE release
  DROP COLUMN country,
  DROP COLUMN date_year,
  DROP COLUMN date_month,
  DROP COLUMN date_day;

COMMIT;
