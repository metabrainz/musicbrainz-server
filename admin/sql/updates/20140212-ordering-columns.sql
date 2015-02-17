\set ON_ERROR_STOP 1

BEGIN;

ALTER TABLE area_alias_type ADD COLUMN parent INTEGER;
ALTER TABLE area_alias_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE area_alias_type ADD COLUMN description TEXT;

ALTER TABLE area_type ADD COLUMN parent INTEGER;
ALTER TABLE area_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE area_type ADD COLUMN description TEXT;

ALTER TABLE artist_type ADD COLUMN parent INTEGER;
ALTER TABLE artist_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE artist_type ADD COLUMN description TEXT;

ALTER TABLE artist_alias_type ADD COLUMN parent INTEGER;
ALTER TABLE artist_alias_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE artist_alias_type ADD COLUMN description TEXT;

ALTER TABLE gender ADD COLUMN parent INTEGER;
ALTER TABLE gender ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE gender ADD COLUMN description TEXT;

ALTER TABLE label_type ADD COLUMN parent INTEGER;
ALTER TABLE label_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE label_type ADD COLUMN description TEXT;

ALTER TABLE label_alias_type ADD COLUMN parent INTEGER;
ALTER TABLE label_alias_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE label_alias_type ADD COLUMN description TEXT;

ALTER TABLE medium_format ADD COLUMN description TEXT;

ALTER TABLE place_type ADD COLUMN parent INTEGER;
ALTER TABLE place_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE place_type ADD COLUMN description TEXT;

ALTER TABLE place_alias_type ADD COLUMN parent INTEGER;
ALTER TABLE place_alias_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE place_alias_type ADD COLUMN description TEXT;

ALTER TABLE release_group_primary_type ADD COLUMN parent INTEGER;
ALTER TABLE release_group_primary_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE release_group_primary_type ADD COLUMN description TEXT;

ALTER TABLE release_group_secondary_type ADD COLUMN parent INTEGER;
ALTER TABLE release_group_secondary_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE release_group_secondary_type ADD COLUMN description TEXT;

ALTER TABLE release_packaging ADD COLUMN parent INTEGER;
ALTER TABLE release_packaging ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE release_packaging ADD COLUMN description TEXT;

ALTER TABLE release_status ADD COLUMN parent INTEGER;
ALTER TABLE release_status ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE release_status ADD COLUMN description TEXT;

ALTER TABLE work_alias_type ADD COLUMN parent INTEGER;
ALTER TABLE work_alias_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE work_alias_type ADD COLUMN description TEXT;

ALTER TABLE work_attribute_type ADD COLUMN parent INTEGER;
ALTER TABLE work_attribute_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE work_attribute_type ADD COLUMN description TEXT;

ALTER TABLE work_attribute_type_allowed_value ADD COLUMN parent INTEGER;
ALTER TABLE work_attribute_type_allowed_value ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE work_attribute_type_allowed_value ADD COLUMN description TEXT;

ALTER TABLE work_type ADD COLUMN parent INTEGER;
ALTER TABLE work_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE work_type ADD COLUMN description TEXT;

ALTER TABLE cover_art_archive.art_type ADD COLUMN parent INTEGER;
ALTER TABLE cover_art_archive.art_type ADD COLUMN child_order INTEGER NOT NULL DEFAULT 0;
ALTER TABLE cover_art_archive.art_type ADD COLUMN description TEXT;


-- set Original Production, Bootleg Production and Reissue Production as children of Production, like pre-NGS (MBS-2410)
UPDATE label_type SET parent = 3 WHERE id IN (4, 5, 6);

-- put Other second to last and None last (MBS-6709)
UPDATE release_packaging SET child_order = 1 WHERE id = 5;
UPDATE release_packaging SET child_order = 2 WHERE id = 7;

-- put Other last
UPDATE cover_art_archive.art_type SET child_order = 1 WHERE id = 8;

COMMIT;
