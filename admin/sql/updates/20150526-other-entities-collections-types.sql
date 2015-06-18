\set ON_ERROR_STOP 1
BEGIN;

SELECT setval('editor_collection_type_id_seq', (SELECT MAX(id) FROM editor_collection_type));
INSERT INTO editor_collection_type (name, entity_type, child_order) VALUES
        ('Area', 'area', 2),
        ('Artist', 'artist', 2),
        ('Instrument', 'instrument', 2),
        ('Label', 'label', 2),
        ('Place', 'place', 2),
        ('Recording', 'recording', 2),
        ('Release group', 'release_group', 2),
        ('Series', 'series', 2),
        ('Work', 'work', 2);
SELECT setval('editor_collection_type_id_seq', (SELECT MAX(id) FROM editor_collection_type));

COMMIT;
