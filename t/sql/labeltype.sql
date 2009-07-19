BEGIN;
SET client_min_messages TO 'WARNING';

TRUNCATE label_type CASCADE;

INSERT INTO label_type (id, name) VALUES (1, 'Production');
INSERT INTO label_type (id, name) VALUES (2, 'Special MusicBrainz Label');

COMMIT;
