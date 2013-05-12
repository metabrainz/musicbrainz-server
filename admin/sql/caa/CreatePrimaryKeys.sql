-- Automatically generated, do not edit.
\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive';

ALTER TABLE art_type ADD CONSTRAINT art_type_pkey PRIMARY KEY (id);
ALTER TABLE cover_art ADD CONSTRAINT cover_art_pkey PRIMARY KEY (id);
ALTER TABLE cover_art_type ADD CONSTRAINT cover_art_type_pkey PRIMARY KEY (id, type_id);
ALTER TABLE image_type ADD CONSTRAINT image_type_pkey PRIMARY KEY (mime_type);
ALTER TABLE release_group_cover_art ADD CONSTRAINT release_group_cover_art_pkey PRIMARY KEY (release_group);
