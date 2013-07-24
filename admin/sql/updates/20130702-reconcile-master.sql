\set ON_ERROR_STOP 1
BEGIN;

SET search_path = musicbrainz;

CREATE EXTENSION cube WITH SCHEMA musicbrainz FROM unpackaged;

DROP TABLE editor_remember_me;
DROP TABLE link_type_2;
DROP TABLE isrc_20110523;
DROP TABLE ocharles_timezones;
DROP TABLE tmp_artist_credit_repl;
DROP TABLE tmp_potential_spammers;
DROP TABLE tmp_recording_merge;
DROP TABLE tmp_release_album;
DROP TABLE tmp_release_merge;
DROP TABLE tmp_spam;
DROP TABLE tmp_url_merge;
DROP TABLE tmp_work_merge;

ALTER TABLE edit_artist ALTER COLUMN status SET NOT NULL;
ALTER TABLE edit_label ALTER COLUMN status SET NOT NULL;

ALTER TABLE editor ALTER COLUMN last_login_date SET DEFAULT now();
ALTER TABLE editor ALTER COLUMN ha1 TYPE char(32);

DROP FUNCTION rehash_password ();

ALTER TABLE artist
  DROP CONSTRAINT artist_check,
  ADD CONSTRAINT group_type_implies_null_gender CHECK (
    gender IS NULL AND type = 2 OR type IS DISTINCT FROM 2
  ),

  DROP CONSTRAINT artist_va_check,
  ADD CONSTRAINT artist_va_check CHECK (
    id <> 1 OR (
      type = 3 AND
      gender IS NULL AND
      area IS NULL AND
      begin_area IS NULL AND
      end_area IS NULL AND
      begin_date_year IS NULL AND
      begin_date_month IS NULL AND
      begin_date_day IS NULL AND
      end_date_year IS NULL AND
      end_date_month IS NULL AND
      end_date_day IS NULL
    );

CREATE OR REPLACE FUNCTION page_index(txt varchar) RETURNS integer AS $$
DECLARE
    input varchar;
    res integer;
    i integer;
    x varchar;
BEGIN
    input := regexp_replace(upper(substr(musicbrainz.musicbrainz_unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
    res := 0;
    FOR i IN 1..6 LOOP
        x := substr(input, i, 1);
        IF x = '_' OR x = '' THEN
            res := (res << 5);
        ELSIF x = ' ' THEN
            res := (res << 5) | 1;
        ELSE
            res := (res << 5) | (ascii(x) - 63);
        END IF;
    END LOOP;
    RETURN res;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION page_index_max(txt varchar) RETURNS integer AS $$
DECLARE
    input varchar;
    res integer;
    i integer;
    x varchar;
BEGIN
    input := regexp_replace(upper(substr(musicbrainz_unaccent(txt), 1, 6)), '[^A-Z ]', '_', 'g');
    res := 0;
    FOR i IN 1..6 LOOP
        x := substr(input, i, 1);
        IF x = '' THEN
            res := (res << 5) | 31;
        ELSIF x = '_' THEN
            res := (res << 5);
        ELSIF x = ' ' THEN
            res := (res << 5) | 1;
        ELSE
            res := (res << 5) | (ascii(x) - 63);
        END IF;
    END LOOP;
    RETURN res;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;

ALTER TABLE artist_name
  DROP CONSTRAINT artist_name_name_check,
  DROP CONSTRAINT artist_name_name_check1,
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE label_name
  DROP CONSTRAINT label_name_name_check,
  DROP CONSTRAINT label_name_name_check1,
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE release_name
  DROP CONSTRAINT release_name_name_check,
  DROP CONSTRAINT release_name_name_check1,
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE track_name
  DROP CONSTRAINT track_name_name_check,
  DROP CONSTRAINT track_name_name_check1,
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE work_name
  DROP CONSTRAINT work_name_name_check,
  DROP CONSTRAINT work_name_name_check1,
  ADD CONSTRAINT control_for_whitespace CHECK (controlled_for_whitespace(name)),
  ADD CONSTRAINT only_non_empty CHECK (name != '');

ALTER TABLE medium ADD CHECK (controlled_for_whitespace(name));

ALTER SEQUENCE release_group_type_id_seq RENAME TO release_group_primary_id_seq;

ALTER TABLE link_type
  ALTER COLUMN entity_type0 SET NOT NULL,
  ALTER COLUMN entity_type1 SET NOT NULL;

ALTER TABLE isrc
  DROP CONSTRAINT isrc_check_isrc,
  ADD CONSTRAINT isrc_isrc_check CHECK (isrc ~ E'^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$');

ALTER INDEX release_group_type_pkey RENAME TO release_group_primary_type_pkey;

COMMIT;
