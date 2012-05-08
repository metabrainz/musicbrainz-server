BEGIN;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION simplify_search_hints()
RETURNS trigger AS $$
BEGIN
    IF NEW.type::int = TG_ARGV[0]::int THEN
        NEW.sort_name := NEW.name;
        NEW.begin_date_year := NULL;
        NEW.begin_date_month := NULL;
        NEW.begin_date_day := NULL;
        NEW.end_date_year := NULL;
        NEW.end_date_month := NULL;
        NEW.end_date_day := NULL;
        NEW.end_date_day := NULL;
        NEW.locale := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
        EXECUTE 'UPDATE ' || quote_ident(TG_ARGV[0]) || ' SET primary_for_locale = FALSE WHERE locale = $1 AND id != $2'
        USING NEW.locale, NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

--------------------------------------------------------------------------------

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

ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_type FOREIGN KEY (type) REFERENCES artist_alias_type (id);
ALTER TABLE artist_alias ADD CONSTRAINT artist_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES artist_name (id);

ALTER TABLE artist_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

ALTER TABLE artist_alias ADD CONSTRAINT search_hints_are_empty
CHECK (
    (type <> 3) OR (
      type = 3 AND sort_name = name AND
      begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
      end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
      primary_for_locale IS FALSE AND locale IS NULL
    )
);

DROP INDEX artist_alias_idx_locale_artist;

CREATE UNIQUE INDEX artist_alias_idx_primary ON artist_alias (artist, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON artist_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('artist_alias');

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON artist_alias
FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(3);

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

ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_type FOREIGN KEY (type) REFERENCES label_alias_type (id);
ALTER TABLE label_alias ADD CONSTRAINT label_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES label_name (id);

ALTER TABLE label_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

DROP INDEX label_alias_idx_locale_label;

CREATE UNIQUE INDEX label_alias_idx_primary ON label_alias (label, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON label_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('label_alias');

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON label_alias
FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

ALTER TABLE label_alias ADD CONSTRAINT search_hints_are_empty
CHECK (
    (type <> 2) OR (
      type = 2 AND sort_name = name AND
      begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
      end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
      primary_for_locale IS FALSE AND locale IS NULL
    )
);

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

ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_type FOREIGN KEY (type) REFERENCES work_alias_type (id);
ALTER TABLE work_alias ADD CONSTRAINT work_alias_fk_sort_name FOREIGN KEY (sort_name) REFERENCES work_name (id);

ALTER TABLE work_alias ADD CONSTRAINT primary_check
CHECK ((locale IS NULL AND primary_for_locale IS FALSE) OR (locale IS NOT NULL));

DROP INDEX work_alias_idx_locale_work;

CREATE UNIQUE INDEX work_alias_idx_primary ON work_alias (work, locale) WHERE primary_for_locale = TRUE AND locale IS NOT NULL;

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON work_alias
FOR EACH ROW EXECUTE PROCEDURE unique_primary('work_alias');

CREATE TRIGGER search_hint BEFORE UPDATE OR INSERT ON work_alias
FOR EACH ROW EXECUTE PROCEDURE simplify_search_hints(2);

ALTER TABLE work_alias ADD CONSTRAINT search_hints_are_empty
CHECK (
    (type <> 2) OR (
      type = 2 AND sort_name = name AND
      begin_date_year IS NULL AND begin_date_month IS NULL AND begin_date_day IS NULL AND
      end_date_year IS NULL AND end_date_month IS NULL AND end_date_day IS NULL AND
      primary_for_locale IS FALSE AND locale IS NULL
    )
);

COMMIT;
