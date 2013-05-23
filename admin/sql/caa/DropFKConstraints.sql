-- Automatically generated, do not edit.
\unset ON_ERROR_STOP

ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_release;
ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_edit;
ALTER TABLE cover_art DROP CONSTRAINT cover_art_fk_mime_type;
ALTER TABLE cover_art_type DROP CONSTRAINT cover_art_type_fk_id;
ALTER TABLE cover_art_type DROP CONSTRAINT cover_art_type_fk_type_id;
ALTER TABLE release_group_cover_art DROP CONSTRAINT release_group_cover_art_fk_release_group;
ALTER TABLE release_group_cover_art DROP CONSTRAINT release_group_cover_art_fk_release;
