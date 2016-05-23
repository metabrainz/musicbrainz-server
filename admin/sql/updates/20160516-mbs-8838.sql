\set ON_ERROR_STOP 1
BEGIN;

-- Creating columns
ALTER TABLE area_type ADD COLUMN gid uuid;
ALTER TABLE area_alias_type ADD COLUMN gid uuid;
ALTER TABLE artist_alias_type ADD COLUMN gid uuid;
ALTER TABLE artist_type ADD COLUMN gid uuid;
ALTER TABLE editor_collection_type ADD COLUMN gid uuid;
ALTER TABLE event_alias_type ADD COLUMN gid uuid;
ALTER TABLE event_type ADD COLUMN gid uuid;
ALTER TABLE gender ADD COLUMN gid uuid;
ALTER TABLE instrument_alias_type ADD COLUMN gid uuid;
ALTER TABLE instrument_type ADD COLUMN gid uuid;
ALTER TABLE label_alias_type ADD COLUMN gid uuid;
ALTER TABLE label_type ADD COLUMN gid uuid;
ALTER TABLE medium_format ADD COLUMN gid uuid;
ALTER TABLE place_alias_type ADD COLUMN gid uuid;
ALTER TABLE place_type ADD COLUMN gid uuid;
ALTER TABLE recording_alias_type ADD COLUMN gid uuid;
ALTER TABLE release_alias_type ADD COLUMN gid uuid;
ALTER TABLE release_group_alias_type ADD COLUMN gid uuid;
ALTER TABLE release_group_secondary_type ADD COLUMN gid uuid;
ALTER TABLE release_group_primary_type ADD COLUMN gid uuid;
ALTER TABLE release_packaging ADD COLUMN gid uuid;
ALTER TABLE release_status ADD COLUMN gid uuid;
ALTER TABLE series_alias_type ADD COLUMN gid uuid;
ALTER TABLE series_ordering_type ADD COLUMN gid uuid;
ALTER TABLE series_type ADD COLUMN gid uuid;
ALTER TABLE work_alias_type ADD COLUMN gid uuid;
ALTER TABLE work_attribute_type ADD COLUMN gid uuid;
ALTER TABLE work_attribute_type_allowed_value ADD COLUMN gid uuid;
ALTER TABLE work_type ADD COLUMN gid uuid;
ALTER TABLE cover_art_archive.art_type ADD COLUMN gid uuid;

-- Generating GIDs
UPDATE area_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'area_type' || id);
UPDATE area_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'area_alias_type' || id);
UPDATE artist_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'artist_alias_type' || id);
UPDATE artist_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'artist_type' || id);
UPDATE editor_collection_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'editor_collection_type' || id);
UPDATE event_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'event_alias_type' || id);
UPDATE event_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'event_type' || id);
UPDATE gender SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'gender' || id);
UPDATE instrument_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'instrument_alias_type' || id);
UPDATE instrument_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'instrument_type' || id);
UPDATE label_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'label_alias_type' || id);
UPDATE label_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'label_type' || id);
UPDATE medium_format SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'medium_format' || id);
UPDATE place_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'place_alias_type' || id);
UPDATE place_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'place_type' || id);
UPDATE recording_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'recording_alias_type' || id);
UPDATE release_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_alias_type' || id);
UPDATE release_group_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_group_alias_type' || id);
UPDATE release_group_secondary_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_group_secondary_type' || id);
UPDATE release_group_primary_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_group_primary_type' || id);
UPDATE release_packaging SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_packaging' || id);
UPDATE release_status SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'release_status' || id);
UPDATE series_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_alias_type' || id);
UPDATE series_ordering_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_ordering_type' || id);
UPDATE series_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'series_type' || id);
UPDATE work_alias_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'work_alias_type' || id);
UPDATE work_attribute_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'work_attribute_type' || id);
UPDATE work_attribute_type_allowed_value SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'work_attribute_type_allowed_value' || id);
UPDATE work_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'work_type' || id);
UPDATE cover_art_archive.art_type SET gid =
    generate_uuid_v3('6ba7b8119dad11d180b400c04fd430c8', 'cover_art_archive.art_type' || id);

-- Adding NOT NULL constraint
ALTER TABLE area_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE area_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE artist_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE artist_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE editor_collection_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE event_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE event_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE gender ALTER COLUMN gid SET NOT NULL;
ALTER TABLE instrument_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE instrument_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE label_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE label_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE medium_format ALTER COLUMN gid SET NOT NULL;
ALTER TABLE place_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE place_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE recording_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_group_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_group_secondary_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_group_primary_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_packaging ALTER COLUMN gid SET NOT NULL;
ALTER TABLE release_status ALTER COLUMN gid SET NOT NULL;
ALTER TABLE series_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE series_ordering_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE series_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE work_alias_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE work_attribute_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE work_attribute_type_allowed_value ALTER COLUMN gid SET NOT NULL;
ALTER TABLE work_type ALTER COLUMN gid SET NOT NULL;
ALTER TABLE cover_art_archive.art_type ALTER COLUMN gid SET NOT NULL;

-- Indexes
CREATE UNIQUE INDEX area_type_idx_gid ON area_type (gid);
CREATE UNIQUE INDEX area_alias_type_idx_gid ON area_alias_type (gid);
CREATE UNIQUE INDEX artist_alias_type_idx_gid ON artist_alias_type (gid);
CREATE UNIQUE INDEX artist_type_idx_gid ON artist_type (gid);
CREATE UNIQUE INDEX editor_collection_type_idx_gid ON editor_collection_type (gid);
CREATE UNIQUE INDEX event_alias_type_idx_gid ON event_alias_type (gid);
CREATE UNIQUE INDEX event_type_idx_gid ON event_type (gid);
CREATE UNIQUE INDEX gender_idx_gid ON gender (gid);
CREATE UNIQUE INDEX instrument_alias_type_idx_gid ON instrument_alias_type (gid);
CREATE UNIQUE INDEX instrument_type_idx_gid ON instrument_type (gid);
CREATE UNIQUE INDEX label_alias_type_idx_gid ON label_alias_type (gid);
CREATE UNIQUE INDEX label_type_idx_gid ON label_type (gid);
CREATE UNIQUE INDEX medium_format_idx_gid ON medium_format (gid);
CREATE UNIQUE INDEX place_alias_type_idx_gid ON place_alias_type (gid);
CREATE UNIQUE INDEX place_type_idx_gid ON place_type (gid);
CREATE UNIQUE INDEX recording_alias_type_idx_gid ON recording_alias_type (gid);
CREATE UNIQUE INDEX release_alias_type_idx_gid ON release_alias_type (gid);
CREATE UNIQUE INDEX release_group_alias_type_idx_gid ON release_group_alias_type (gid);
CREATE UNIQUE INDEX release_group_secondary_type_idx_gid ON release_group_secondary_type (gid);
CREATE UNIQUE INDEX release_group_primary_type_idx_gid ON release_group_primary_type (gid);
CREATE UNIQUE INDEX release_packaging_idx_gid ON release_packaging (gid);
CREATE UNIQUE INDEX release_status_idx_gid ON release_status (gid);
CREATE UNIQUE INDEX series_alias_type_idx_gid ON series_alias_type (gid);
CREATE UNIQUE INDEX series_ordering_type_idx_gid ON series_ordering_type (gid);
CREATE UNIQUE INDEX series_type_idx_gid ON series_type (gid);
CREATE UNIQUE INDEX work_alias_type_idx_gid ON work_alias_type (gid);
CREATE UNIQUE INDEX work_attribute_type_idx_gid ON work_attribute_type (gid);
CREATE UNIQUE INDEX work_attribute_type_allowed_value_idx_gid ON work_attribute_type_allowed_value (gid);
CREATE UNIQUE INDEX work_type_idx_gid ON work_type (gid);
CREATE UNIQUE INDEX art_type_idx_gid ON cover_art_archive.art_type (gid);

COMMIT;
