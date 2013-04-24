\set ON_ERROR_STOP 1

BEGIN;

SELECT id AS release, country, date_year, date_month, date_day
INTO release_country
FROM release
WHERE country IS NOT NULL;

SELECT id AS release, date_year, date_month, date_day
INTO release_unknown_country
FROM release
WHERE country IS NULL AND (date_year IS NOT NULL OR date_month IS NOT NULL OR date_day IS NOT NULL);

ALTER TABLE release_country
  ADD PRIMARY KEY (release, country);

ALTER TABLE release_unknown_country
  ADD PRIMARY KEY (release);

ALTER TABLE release
  DROP COLUMN country,
  DROP COLUMN date_year,
  DROP COLUMN date_month,
  DROP COLUMN date_day;

CREATE OR REPLACE FUNCTION set_release_group_first_release_date(release_group_id INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE release_group_meta SET first_release_date_year = first.date_year,
                                  first_release_date_month = first.date_month,
                                  first_release_date_day = first.date_day
      FROM (
        SELECT date_year, date_month, date_day
        FROM (
          SELECT date_year, date_month, date_day
          FROM release
          JOIN release_country ON (release_country.release = release.id)
          WHERE release.release_group = release_group_id
          UNION
          SELECT date_year, date_month, date_day
          FROM release
          JOIN release_unknown_country ON (release_unknown_country.release = release.id)
          WHERE release.release_group = release_group_id
        ) b
        ORDER BY date_year NULLS LAST, date_month NULLS LAST, date_day NULLS LAST
        LIMIT 1
      ) AS first
    WHERE id = release_group_id;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = NEW.release;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id IN (NEW.release, OLD.release);
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release_event()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM set_release_group_first_release_date(release_group)
  FROM release
  WHERE release.id = OLD.release;
  RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release() RETURNS trigger AS $$
BEGIN
    -- increment ref_count of the name
    PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    -- increment release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
    -- add new release_meta
    INSERT INTO release_meta (id) VALUES (NEW.id);
    INSERT INTO release_coverart (id) VALUES (NEW.id);
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release() RETURNS trigger AS $$
BEGIN
    IF NEW.artist_credit != OLD.artist_credit THEN
        PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
        PERFORM inc_ref_count('artist_credit', NEW.artist_credit, 1);
    END IF;
    IF NEW.release_group != OLD.release_group THEN
        -- release group is changed, decrement release_count in the original RG, increment in the new one
        UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
        UPDATE release_group_meta SET release_count = release_count + 1 WHERE id = NEW.release_group;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release() RETURNS trigger AS $$
BEGIN
    -- decrement ref_count of the name
    PERFORM dec_ref_count('artist_credit', OLD.artist_credit, 1);
    -- decrement release_count of the parent release group
    UPDATE release_group_meta SET release_count = release_count - 1 WHERE id = OLD.release_group;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

COMMIT;
