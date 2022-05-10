\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE area_containment (
    descendant          INTEGER NOT NULL, -- PK, references area.id
    parent              INTEGER NOT NULL, -- PK, references area.id
    depth               SMALLINT NOT NULL
);

CREATE OR REPLACE FUNCTION a_ins_l_area_area_mirror() RETURNS trigger AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    IF (SELECT link_type FROM link WHERE id = NEW.link) = part_of_area_link_type_id THEN
        PERFORM update_area_containment_mirror(ARRAY[NEW.entity0], ARRAY[NEW.entity1]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_upd_l_area_area_mirror() RETURNS trigger AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
    old_lt_id INTEGER;
    new_lt_id INTEGER;
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    SELECT link_type INTO old_lt_id FROM link WHERE id = OLD.link;
    SELECT link_type INTO new_lt_id FROM link WHERE id = NEW.link;
    IF (
        (
            old_lt_id = part_of_area_link_type_id AND
            new_lt_id = part_of_area_link_type_id AND
            (OLD.entity0 != NEW.entity0 OR OLD.entity1 != NEW.entity1)
        ) OR
        (old_lt_id = part_of_area_link_type_id) != (new_lt_id = part_of_area_link_type_id)
    ) THEN
        PERFORM update_area_containment_mirror(ARRAY[OLD.entity0, NEW.entity0], ARRAY[OLD.entity1, NEW.entity1]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION a_del_l_area_area_mirror() RETURNS trigger AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.
    IF (SELECT link_type FROM link WHERE id = OLD.link) = part_of_area_link_type_id THEN
        PERFORM update_area_containment_mirror(ARRAY[OLD.entity0], ARRAY[OLD.entity1]);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

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
    $SQL$ || (CASE WHEN descendant_area_ids IS NULL THEN '' ELSE 'AND entity1 = any($2)' END) ||
    $SQL$
             UNION ALL
            SELECT descendant, entity0, path || ROW(descendant, entity0), ROW(descendant, entity0) = any(path)
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
              JOIN area_parent_hierarchy ON area_parent_hierarchy.parent = laa.entity1
             WHERE link.link_type = $1
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
    $SQL$ || (CASE WHEN parent_area_ids IS NULL THEN '' ELSE 'AND entity0 = any($2)' END) ||
    $SQL$
             UNION ALL
            SELECT entity1, parent, path || ROW(entity1, parent), ROW(entity1, parent) = any(path)
              FROM l_area_area laa
              JOIN link ON laa.link = link.id
              JOIN area_descendant_hierarchy ON area_descendant_hierarchy.descendant = laa.entity0
             WHERE link.link_type = $1
               AND parent != entity1
               AND NOT cycle
        )
        SELECT descendant, parent, array_length(path, 1)::SMALLINT
          FROM area_descendant_hierarchy
    $SQL$
    USING part_of_area_link_type_id, parent_area_ids;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_area_containment_mirror(
    parent_ids INTEGER[], -- entity0 of area-area "part of"
    descendant_ids INTEGER[] -- entity1
) RETURNS VOID AS $$
DECLARE
    part_of_area_link_type_id CONSTANT SMALLINT := 356;
    descendant_ids_to_update INTEGER[];
    parent_ids_to_update INTEGER[];
BEGIN
    -- DO NOT modify any replicated tables in this function; it's used
    -- by a trigger on mirrors.

    SELECT array_agg(descendant)
      INTO descendant_ids_to_update
      FROM area_containment
     WHERE parent = any(parent_ids);

    SELECT array_agg(parent)
      INTO parent_ids_to_update
      FROM area_containment
     WHERE descendant = any(descendant_ids);

    -- For INSERTS/UPDATES, include the new IDs that aren't present in
    -- area_containment yet.
    descendant_ids_to_update := descendant_ids_to_update || descendant_ids;
    parent_ids_to_update := parent_ids_to_update || parent_ids;

    DELETE FROM area_containment
     WHERE descendant = any(descendant_ids_to_update);

    DELETE FROM area_containment
     WHERE parent = any(parent_ids_to_update);

    -- Update the parents of all descendants of parent_ids.
    -- Update the descendants of all parents of descendant_ids.

    INSERT INTO area_containment
    SELECT DISTINCT ON (descendant, parent)
        descendant, parent, depth
      FROM (
          SELECT * FROM get_area_parent_hierarchy_rows(descendant_ids_to_update)
          UNION ALL
          SELECT * FROM get_area_descendant_hierarchy_rows(parent_ids_to_update)
      ) area_hierarchy
     ORDER BY descendant, parent, depth;
END;
$$ LANGUAGE plpgsql;

-- Note: when passing NULL, it doesn't matter whether we use
-- get_area_parent_hierarchy_rows vs. get_area_descendant_hierarchy_rows
-- to build the entire table.
INSERT INTO area_containment
SELECT DISTINCT ON (descendant, parent)
    descendant,
    parent,
    depth
 FROM get_area_parent_hierarchy_rows(NULL)
ORDER BY descendant, parent, depth;

ALTER TABLE area_containment ADD CONSTRAINT area_containment_pkey PRIMARY KEY (descendant, parent);

CREATE INDEX area_containment_idx_parent ON area_containment (parent);

COMMIT;
