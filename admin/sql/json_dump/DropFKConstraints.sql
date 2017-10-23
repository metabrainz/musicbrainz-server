-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = json_dump, public;

ALTER TABLE area_lastmod DROP CONSTRAINT IF EXISTS area_lastmod_fk_id;
ALTER TABLE artist_lastmod DROP CONSTRAINT IF EXISTS artist_lastmod_fk_id;
ALTER TABLE event_lastmod DROP CONSTRAINT IF EXISTS event_lastmod_fk_id;
ALTER TABLE instrument_lastmod DROP CONSTRAINT IF EXISTS instrument_lastmod_fk_id;
ALTER TABLE label_lastmod DROP CONSTRAINT IF EXISTS label_lastmod_fk_id;
ALTER TABLE place_lastmod DROP CONSTRAINT IF EXISTS place_lastmod_fk_id;
ALTER TABLE recording_lastmod DROP CONSTRAINT IF EXISTS recording_lastmod_fk_id;
ALTER TABLE release_group_lastmod DROP CONSTRAINT IF EXISTS release_group_lastmod_fk_id;
ALTER TABLE release_lastmod DROP CONSTRAINT IF EXISTS release_lastmod_fk_id;
ALTER TABLE series_lastmod DROP CONSTRAINT IF EXISTS series_lastmod_fk_id;
ALTER TABLE work_lastmod DROP CONSTRAINT IF EXISTS work_lastmod_fk_id;
