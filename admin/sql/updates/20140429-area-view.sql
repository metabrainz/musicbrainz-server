\set ON_ERROR_STOP 1

BEGIN;

-- First, construct a table (recursively) of parent -> descendant connections
-- for areas, including an array of the path (the 'descendants' array).

-- Then, find the shortest path to each type of parent by joining to area,
-- distinct on descendant, type, and order by the length of the array of descendants.
CREATE OR REPLACE VIEW area_containment AS
        WITH RECURSIVE area_descendants AS (
            SELECT entity0 AS parent, entity1 AS descendant, ARRAY[entity1] AS descendants
            FROM   l_area_area laa
            JOIN   link ON laa.link = link.id
            JOIN   link_type ON link.link_type = link_type.id
            WHERE  link_type.gid = 'de7cc874-8b1b-3a05-8272-f3834c968fb7'
                UNION ALL
            SELECT entity0 AS parent, descendant, descendants || entity1
            FROM   l_area_area laa
            JOIN   link ON laa.link=link.id
            JOIN   link_type ON link.link_type = link_type.id
            JOIN   area_descendants ON area_descendants.parent = laa.entity1
            WHERE  link_type.gid = 'de7cc874-8b1b-3a05-8272-f3834c968fb7'
            AND    NOT entity0 = ANY(descendants))
        SELECT DISTINCT ON (descendant, type) descendant, area_descendants.parent, area.type, area_type.name AS type_name, descendants || area_descendants.parent AS descendant_hierarchy
        FROM   area_descendants
        JOIN   area ON area_descendants.parent = area.id
        JOIN   area_type ON area.type = area_type.id
        WHERE  area.type IN (1, 2, 3)
        ORDER BY descendant, type, array_length(descendants, 1) ASC;

COMMIT;
