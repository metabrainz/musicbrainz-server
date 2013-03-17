\unset ON_ERROR_STOP

CREATE TRIGGER reptg_art_type ON art_type;
CREATE TRIGGER reptg_image_type ON image_type;
CREATE TRIGGER reptg_cover_art ON cover_art;
CREATE TRIGGER reptg_cover_art_type ON cover_art_type;
CREATE TRIGGER reptg_release_group_cover_art ON release_group_cover_art;
