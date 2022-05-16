-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

SET search_path = 'cover_art_archive';

DROP TRIGGER IF EXISTS reptg_art_type ON art_type;
DROP TRIGGER IF EXISTS reptg_cover_art ON cover_art;
DROP TRIGGER IF EXISTS reptg_cover_art_type ON cover_art_type;
DROP TRIGGER IF EXISTS reptg_image_type ON image_type;
DROP TRIGGER IF EXISTS reptg_release_group_cover_art ON release_group_cover_art;
