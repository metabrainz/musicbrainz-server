\set ON_ERROR_STOP 1

BEGIN;

DROP TRIGGER IF EXISTS unique_primary_for_locale ON area_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON artist_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON event_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON genre_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON instrument_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON label_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON place_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON recording_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON release_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON release_group_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON series_alias;
DROP TRIGGER IF EXISTS unique_primary_for_locale ON work_alias;

DROP FUNCTION IF EXISTS unique_primary_area_alias();
DROP FUNCTION IF EXISTS unique_primary_artist_alias();
DROP FUNCTION IF EXISTS unique_primary_event_alias();
DROP FUNCTION IF EXISTS unique_primary_genre_alias();
DROP FUNCTION IF EXISTS unique_primary_instrument_alias();
DROP FUNCTION IF EXISTS unique_primary_label_alias();
DROP FUNCTION IF EXISTS unique_primary_place_alias();
DROP FUNCTION IF EXISTS unique_primary_recording_alias();
DROP FUNCTION IF EXISTS unique_primary_release_alias();
DROP FUNCTION IF EXISTS unique_primary_release_group_alias();
DROP FUNCTION IF EXISTS unique_primary_series_alias();
DROP FUNCTION IF EXISTS unique_primary_work_alias();

COMMIT;
