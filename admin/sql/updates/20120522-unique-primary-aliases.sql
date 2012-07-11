BEGIN;

CREATE OR REPLACE FUNCTION unique_primary_artist_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE artist_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND artist = NEW.artist;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_label_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE label_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND label = NEW.label;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION unique_primary_work_alias()
RETURNS trigger AS $$
BEGIN
    IF NEW.primary_for_locale THEN
      UPDATE work_alias SET primary_for_locale = FALSE
      WHERE locale = NEW.locale AND id != NEW.id
        AND work = NEW.work;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

DROP TRIGGER unique_primary_for_locale ON artist_alias;
DROP TRIGGER unique_primary_for_locale ON label_alias;
DROP TRIGGER unique_primary_for_locale ON work_alias;
DROP FUNCTION unique_primary();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON artist_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_artist_alias();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON label_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_label_alias();

CREATE TRIGGER unique_primary_for_locale BEFORE UPDATE OR INSERT ON work_alias
    FOR EACH ROW EXECUTE PROCEDURE unique_primary_work_alias();

--------------------------------------------------------------------------------
-- For all aliases in an artist that are the only alias in a given locale,
-- set that alias to be primary.
UPDATE artist_alias SET primary_for_locale = TRUE
FROM (
  SELECT artist_alias.id
  FROM artist_alias
  LEFT JOIN artist_alias other ON (
    other.artist = artist_alias.artist AND
    other.id != artist_alias.id AND
    other.locale = artist_alias.locale
  )
  WHERE artist_alias.locale IS NOT NULL
    AND NOT artist_alias.primary_for_locale
    AND other.id IS NULL
) updates
WHERE artist_alias.id = updates.id;

--------------------------------------------------------------------------------
-- For all aliases in an label that are the only alias in a given locale,
-- set that alias to be primary.
UPDATE label_alias SET primary_for_locale = TRUE
FROM (
  SELECT label_alias.id
  FROM label_alias
  LEFT JOIN label_alias other ON (
    other.label = label_alias.label AND
    other.id != label_alias.id AND
    other.locale = label_alias.locale
  )
  WHERE label_alias.locale IS NOT NULL
    AND NOT label_alias.primary_for_locale
    AND other.id IS NULL
) updates
WHERE label_alias.id = updates.id;

--------------------------------------------------------------------------------
-- For all aliases in an work that are the only alias in a given locale,
-- set that alias to be primary.
UPDATE work_alias SET primary_for_locale = TRUE
FROM (
  SELECT work_alias.id
  FROM work_alias
  LEFT JOIN work_alias other ON (
    other.work = work_alias.work AND
    other.id != work_alias.id AND
    other.locale = work_alias.locale
  )
  WHERE work_alias.locale IS NOT NULL
    AND NOT work_alias.primary_for_locale
    AND other.id IS NULL
) updates
WHERE work_alias.id = updates.id;

COMMIT;
