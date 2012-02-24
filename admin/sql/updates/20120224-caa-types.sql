BEGIN;

SET search_path = 'cover_art_archive';

INSERT INTO art_type (name) VALUES ('Other');
INSERT INTO art_type (name) VALUES ('Front');
INSERT INTO art_type (name) VALUES ('Back');
INSERT INTO art_type (name) VALUES ('Booklet');
INSERT INTO art_type (name) VALUES ('Medium');
INSERT INTO art_type (name) VALUES ('Obi');
INSERT INTO art_type (name) VALUES ('Spine');
INSERT INTO art_type (name) VALUES ('Track');

COMMIT;
