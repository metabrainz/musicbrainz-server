-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = json_dump, public;

ALTER TABLE area_json DROP CONSTRAINT IF EXISTS area_json_pkey;
ALTER TABLE artist_json DROP CONSTRAINT IF EXISTS artist_json_pkey;
ALTER TABLE deleted_entities DROP CONSTRAINT IF EXISTS deleted_entities_pkey;
ALTER TABLE event_json DROP CONSTRAINT IF EXISTS event_json_pkey;
ALTER TABLE instrument_json DROP CONSTRAINT IF EXISTS instrument_json_pkey;
ALTER TABLE label_json DROP CONSTRAINT IF EXISTS label_json_pkey;
ALTER TABLE place_json DROP CONSTRAINT IF EXISTS place_json_pkey;
ALTER TABLE recording_json DROP CONSTRAINT IF EXISTS recording_json_pkey;
ALTER TABLE release_group_json DROP CONSTRAINT IF EXISTS release_group_json_pkey;
ALTER TABLE release_json DROP CONSTRAINT IF EXISTS release_json_pkey;
ALTER TABLE series_json DROP CONSTRAINT IF EXISTS series_json_pkey;
ALTER TABLE work_json DROP CONSTRAINT IF EXISTS work_json_pkey;
