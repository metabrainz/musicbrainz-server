SET search_path = 'cover_art_archive';

BEGIN;

CREATE TABLE image_type (
    id SERIAL NOT NULL, -- PK
    mime_type TEXT NOT NULL,
    suffix TEXT NOT NULL
);

ALTER TABLE image_type ADD CONSTRAINT image_type_pkey PRIMARY KEY (id);

INSERT INTO image_type (mime_type, suffix)
    VALUES ('image/jpeg', 'jpg'),
           ('image/png', 'png'),
           ('image/gif', 'gif');

-- references image_type.id
ALTER TABLE cover_art ADD COLUMN image_type INTEGER;

COMMIT;

-- New transaction because postgresql isn't happy when I update
-- the table I just altered in the same transaction.

BEGIN;

UPDATE cover_art SET image_type = (
    SELECT id FROM image_type WHERE suffix = 'jpg');

COMMIT;

BEGIN;

ALTER TABLE cover_art ALTER COLUMN image_type SET NOT NULL;

ALTER TABLE cover_art
    ADD FOREIGN KEY (image_type) REFERENCES image_type(id);

COMMIT;
