-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_image_type;
ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_release;
ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_edit;
ALTER TABLE cover_art_type DROP CONSTRAINT cover_art_type_fk_id;
ALTER TABLE cover_art_type DROP CONSTRAINT cover_art_type_fk_type_id;
