-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'cover_art_archive';

ALTER TABLE art_type DROP CONSTRAINT IF EXISTS art_type_fk_parent;
ALTER TABLE cover_art DROP CONSTRAINT IF EXISTS cover_art_fk_release;
ALTER TABLE cover_art DROP CONSTRAINT IF EXISTS cover_art_fk_edit;
ALTER TABLE cover_art DROP CONSTRAINT IF EXISTS cover_art_fk_mime_type;
ALTER TABLE cover_art_type DROP CONSTRAINT IF EXISTS cover_art_type_fk_id;
ALTER TABLE cover_art_type DROP CONSTRAINT IF EXISTS cover_art_type_fk_type_id;
ALTER TABLE release_group_cover_art DROP CONSTRAINT IF EXISTS release_group_cover_art_fk_release_group;
ALTER TABLE release_group_cover_art DROP CONSTRAINT IF EXISTS release_group_cover_art_fk_release;
