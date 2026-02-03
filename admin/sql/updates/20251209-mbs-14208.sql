\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE FUNCTION get_area_parent_hierarchy_rows(
    descendant_area_ids INTEGER[]
) RETURNS SETOF area_containment AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
BEGIN
    RETURN QUERY EXECUTE $SQL$
        WITH RECURSIVE area_parent_hierarchy(descendant, parent, path, cycle) AS (
            SELECT entity1, entity0, ARRAY[ROW(entity1, entity0)], FALSE
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
             WHERE link.link_type = $1
               AND link.ended = FALSE
    $SQL$ || (CASE WHEN descendant_area_ids IS NULL THEN '' ELSE 'AND entity1 = any($2)' END) ||
    $SQL$
             UNION ALL
            SELECT descendant, entity0, path || ROW(descendant, entity0), ROW(descendant, entity0) = any(path)
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
              JOIN area_parent_hierarchy ON area_parent_hierarchy.parent = laa.entity1
             WHERE link.link_type = $1
               AND link.ended = FALSE
               AND descendant != entity0
               AND NOT cycle
        )
        SELECT descendant, parent, array_length(path, 1)::SMALLINT
          FROM area_parent_hierarchy
    $SQL$
    USING part_of_area_link_type_id, descendant_area_ids;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_area_descendant_hierarchy_rows(
    parent_area_ids INTEGER[]
) RETURNS SETOF area_containment AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
BEGIN
    RETURN QUERY EXECUTE $SQL$
        WITH RECURSIVE area_descendant_hierarchy(descendant, parent, path, cycle) AS (
            SELECT entity1, entity0, ARRAY[ROW(entity1, entity0)], FALSE
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
             WHERE link.link_type = $1
               AND link.ended = FALSE
    $SQL$ || (CASE WHEN parent_area_ids IS NULL THEN '' ELSE 'AND entity0 = any($2)' END) ||
    $SQL$
             UNION ALL
            SELECT entity1, parent, path || ROW(entity1, parent), ROW(entity1, parent) = any(path)
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
              JOIN area_descendant_hierarchy ON area_descendant_hierarchy.descendant = laa.entity0
             WHERE link.link_type = $1
               AND link.ended = FALSE
               AND parent != entity1
               AND NOT cycle
        )
        SELECT descendant, parent, array_length(path, 1)::SMALLINT
          FROM area_descendant_hierarchy
    $SQL$
    USING part_of_area_link_type_id, parent_area_ids;
END;
$$ LANGUAGE plpgsql;

COMMIT;
