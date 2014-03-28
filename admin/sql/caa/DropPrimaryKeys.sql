-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'cover_art_archive';

ALTER TABLE art_type DROP CONSTRAINT IF EXISTS art_type_pkey;
ALTER TABLE cover_art DROP CONSTRAINT IF EXISTS cover_art_pkey;
ALTER TABLE cover_art_type DROP CONSTRAINT IF EXISTS cover_art_type_pkey;
ALTER TABLE image_type DROP CONSTRAINT IF EXISTS image_type_pkey;
ALTER TABLE release_group_cover_art DROP CONSTRAINT IF EXISTS release_group_cover_art_pkey;
