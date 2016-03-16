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

COMMIT;
