\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE area_alias_type
   ADD CONSTRAINT area_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_alias_type(id);

ALTER TABLE area_type
   ADD CONSTRAINT area_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES area_type(id);

ALTER TABLE artist_type
   ADD CONSTRAINT artist_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_type(id);

ALTER TABLE artist_alias_type
   ADD CONSTRAINT artist_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES artist_alias_type(id);

ALTER TABLE gender
   ADD CONSTRAINT gender_fk_parent
   FOREIGN KEY (parent)
   REFERENCES gender(id);

ALTER TABLE label_type
   ADD CONSTRAINT label_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_type(id);

ALTER TABLE label_alias_type
   ADD CONSTRAINT label_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES label_alias_type(id);

ALTER TABLE place_type
   ADD CONSTRAINT place_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_type(id);

ALTER TABLE place_alias_type
   ADD CONSTRAINT place_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES place_alias_type(id);

ALTER TABLE release_group_primary_type
   ADD CONSTRAINT release_group_primary_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_primary_type(id);

ALTER TABLE release_group_secondary_type
   ADD CONSTRAINT release_group_secondary_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_group_secondary_type(id);

ALTER TABLE release_packaging
   ADD CONSTRAINT release_packaging_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_packaging(id);

ALTER TABLE release_status
   ADD CONSTRAINT release_status_fk_parent
   FOREIGN KEY (parent)
   REFERENCES release_status(id);

ALTER TABLE work_alias_type
   ADD CONSTRAINT work_alias_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_alias_type(id);

ALTER TABLE work_attribute_type
   ADD CONSTRAINT work_attribute_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_attribute_type(id);

ALTER TABLE work_attribute_type_allowed_value
   ADD CONSTRAINT work_attribute_type_allowed_value_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_attribute_type_allowed_value(id);

ALTER TABLE work_type
   ADD CONSTRAINT work_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES work_type(id);

ALTER TABLE cover_art_archive.art_type
   ADD CONSTRAINT art_type_fk_parent
   FOREIGN KEY (parent)
   REFERENCES cover_art_archive.art_type(id);

COMMIT;
