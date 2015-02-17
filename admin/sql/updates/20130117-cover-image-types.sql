\set ON_ERROR_STOP 1

SET search_path = 'cover_art_archive';

BEGIN;

CREATE TABLE image_type (
    mime_type TEXT NOT NULL, -- PK
    suffix TEXT NOT NULL
);

ALTER TABLE image_type ADD CONSTRAINT image_type_pkey PRIMARY KEY (mime_type);

INSERT INTO image_type (mime_type, suffix)
    VALUES ('image/jpeg', 'jpg'),
           ('image/png', 'png'),
           ('image/gif', 'gif');

ALTER TABLE cover_art ADD COLUMN mime_type TEXT NOT NULL DEFAULT 'image/jpeg';
ALTER TABLE cover_art ALTER COLUMN mime_type DROP DEFAULT;

COMMIT;
