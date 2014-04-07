\set ON_ERROR_STOP 1
BEGIN;
    ALTER TABLE link_type ADD COLUMN entity0_cardinality integer,
                          ADD COLUMN entity1_cardinality integer;

    -- Type pairs where the info is central to entity1, but many-valued to entity0
    -- e.g. artist-recording (performer, mastering, etc.)
    UPDATE link_type SET entity0_cardinality = 1, entity1_cardinality = 0
     WHERE (entity_type0 = 'artist' AND entity_type1 IN ('recording', 'release', 'release_group', 'work'))
        OR (entity_type0 = 'label'  AND entity_type1 IN ('recording', 'release', 'work'));

    -- Type pairs where the info is central to entity0, but many-valued to entity1
    -- e.g. recording-work (performance, medley, etc.)
    UPDATE link_type SET entity0_cardinality = 0, entity1_cardinality = 1
     WHERE (entity_type0 = 'artist' AND entity_type1 = 'label')
        OR (entity_type0 = 'recording' AND entity_type1 IN ('release', 'work'));

    -- Type pairs where the info is central to both entities. Default.
    UPDATE link_type SET entity0_cardinality = 0, entity1_cardinality = 0 WHERE entity0_cardinality IS NULL AND entity1_cardinality IS NULL;

    ALTER TABLE link_type ALTER COLUMN entity0_cardinality SET NOT NULL,
                          ALTER COLUMN entity0_cardinality SET DEFAULT 0,
                          ALTER COLUMN entity1_cardinality SET NOT NULL,
                          ALTER COLUMN entity1_cardinality SET DEFAULT 0;
COMMIT;
