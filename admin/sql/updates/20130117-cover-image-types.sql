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

ALTER TABLE cover_art ADD COLUMN image_type TEXT NOT NULL DEFAULT 'image/jpeg' REFERENCES image_type(mime_type);

COMMIT;
