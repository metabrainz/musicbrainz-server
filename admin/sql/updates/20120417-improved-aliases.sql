BEGIN;

CREATE OR REPLACE FUNCTION unique_primary()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
        EXECUTE 'UPDATE ' || quote_ident(TG_ARGV[0]) || ' SET primary_for_locale = FALSE WHERE locale = $1'
        USING NEW.locale;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TABLE artist_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

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

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_type FOREIGN KEY (type) REFERENCES artist_alias_type (id);
ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES artist_name (id);

ALTER TABLE artist_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

DROP INDEX artist_alias_idx_locale_artist;

CREATE UNIQUE INDEX artist_alias_idx_primary ON artist_alias (artist, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON artist_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('artist_alias');

CREATE TABLE label_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

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

ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_type FOREIGN KEY (type) REFERENCES label_alias_type (id);
ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES label_name (id);

ALTER TABLE label_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

DROP INDEX label_alias_idx_locale_label;

CREATE UNIQUE INDEX label_alias_idx_primary ON label_alias (label, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON label_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('label_alias');

CREATE TABLE work_alias_type (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

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

ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_type FOREIGN KEY (type) REFERENCES work_alias_type (id);
ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES work_name (id);

ALTER TABLE work_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

DROP INDEX work_alias_idx_locale_work;

CREATE UNIQUE INDEX work_alias_idx_primary ON work_alias (work, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON work_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('work_alias');

COMMIT;
