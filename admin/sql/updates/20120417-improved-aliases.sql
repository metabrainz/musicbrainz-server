BEGIN;

CREATE TABLE artist_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO artist_alias_type (id, name)
VALUES (1, 'Artist name'), (2, 'Legal name'), (3, 'Search hint');

SELECT setval('artist_alias_type_id_seq', (SELECT MAX(id) FROM artist_alias_type));

ALTER TABLE artist_alias ADD COLUMN type INTEGER;
ALTER TABLE artist_alias ADD COLUMN sort_name INTEGER;
ALTER TABLE artist_alias ADD COLUMN begin_date_year SMALLINT;
ALTER TABLE artist_alias ADD COLUMN begin_date_month SMALLINT;
ALTER TABLE artist_alias ADD COLUMN begin_date_day SMALLINT;
ALTER TABLE artist_alias ADD COLUMN end_date_year SMALLINT;
ALTER TABLE artist_alias ADD COLUMN end_date_month SMALLINT;
ALTER TABLE artist_alias ADD COLUMN end_date_day SMALLINT;
ALTER TABLE artist_alias ADD COLUMN primary_for_locale BOOLEAN NOT NULL DEFAULT false;

UPDATE artist_alias SET sort_name = name;
ALTER TABLE artist_alias ALTER COLUMN sort_name SET NOT NULL;

DROP INDEX artist_alias_idx_locale_artist;

CREATE UNIQUE INDEX artist_alias_idx_primary ON artist_alias (artist, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

--------------------------------------------------------------------------------

CREATE TABLE label_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO label_alias_type (id, name)
VALUES (1, 'Label name'), (2, 'Search hint');

SELECT setval('label_alias_type_id_seq', (SELECT MAX(id) FROM label_alias_type));

ALTER TABLE label_alias ADD COLUMN type INTEGER;
ALTER TABLE label_alias ADD COLUMN sort_name INTEGER;
ALTER TABLE label_alias ADD COLUMN begin_date_year SMALLINT;
ALTER TABLE label_alias ADD COLUMN begin_date_month SMALLINT;
ALTER TABLE label_alias ADD COLUMN begin_date_day SMALLINT;
ALTER TABLE label_alias ADD COLUMN end_date_year SMALLINT;
ALTER TABLE label_alias ADD COLUMN end_date_month SMALLINT;
ALTER TABLE label_alias ADD COLUMN end_date_day SMALLINT;
ALTER TABLE label_alias ADD COLUMN primary_for_locale BOOLEAN NOT NULL DEFAULT false;

UPDATE label_alias SET sort_name = name;
ALTER TABLE label_alias ALTER COLUMN sort_name SET NOT NULL;

DROP INDEX label_alias_idx_locale_label;

CREATE UNIQUE INDEX label_alias_idx_primary ON label_alias (label, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

--------------------------------------------------------------------------------

CREATE TABLE work_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO work_alias_type (id, name)
VALUES (1, 'Work name'), (2, 'Search hint');

SELECT setval('work_alias_type_id_seq', (SELECT MAX(id) FROM work_alias_type));

ALTER TABLE work_alias ADD COLUMN type INTEGER;
ALTER TABLE work_alias ADD COLUMN sort_name INTEGER;
ALTER TABLE work_alias ADD COLUMN begin_date_year SMALLINT;
ALTER TABLE work_alias ADD COLUMN begin_date_month SMALLINT;
ALTER TABLE work_alias ADD COLUMN begin_date_day SMALLINT;
ALTER TABLE work_alias ADD COLUMN end_date_year SMALLINT;
ALTER TABLE work_alias ADD COLUMN end_date_month SMALLINT;
ALTER TABLE work_alias ADD COLUMN end_date_day SMALLINT;
ALTER TABLE work_alias ADD COLUMN primary_for_locale BOOLEAN NOT NULL DEFAULT false;

UPDATE work_alias SET sort_name = name;
ALTER TABLE work_alias ALTER COLUMN sort_name SET NOT NULL;

DROP INDEX work_alias_idx_locale_work;

CREATE UNIQUE INDEX work_alias_idx_primary ON work_alias (work, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

COMMIT;
