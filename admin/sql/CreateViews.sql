\set ON_ERROR_STOP 1

BEGIN;

CREATE OR REPLACE VIEW release_event AS
    SELECT
        release, date_year, date_month, date_day, country
    FROM (
        SELECT release, date_year, date_month, date_day, country
        FROM release_country
        UNION ALL
        SELECT release, date_year, date_month, date_day, NULL
        FROM release_unknown_country
    ) as q;

-- First, construct a table (recursively) of parent -> descendant connections
-- for areas, including an array of the path (the 'descendants' array).

-- Then, find the shortest path to each type of parent by joining to area,
-- distinct on descendant, type, and order by the length of the array of descendants.

-- link type de7cc874-8b1b-3a05-8272-f3834c968fb7 is the area-area 'parent of' relation
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

CREATE OR REPLACE VIEW recording_series AS
    SELECT entity0 AS recording, entity1 AS series, link_order, text_value
    FROM l_recording_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'ea6f0698-6782-30d6-b16d-293081b66774')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_series AS
    SELECT entity0 AS release, entity1 AS series, link_order, text_value
    FROM l_release_series lrs
    JOIN series s ON s.id = lrs.entity1
    JOIN link l ON l.id = lrs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '3fa29f01-8e13-3e49-9b0a-ad212aa2f81d')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW release_group_series AS
    SELECT entity0 AS release_group, entity1 AS series, link_order, text_value
    FROM l_release_group_series lrgs
    JOIN series s ON s.id = lrgs.entity1
    JOIN link l ON l.id = lrgs.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = '01018437-91d8-36b9-bf89-3f885d53b5bd')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

CREATE OR REPLACE VIEW work_series AS
    SELECT entity1 AS work, entity0 AS series, link_order, text_value
    FROM l_series_work lsw
    JOIN series s ON s.id = lsw.entity0
    JOIN link l ON l.id = lsw.link
    JOIN link_type lt ON (lt.id = l.link_type AND lt.gid = 'b0d44366-cdf0-3acb-bee6-0f65a77a6ef0')
    JOIN link_attribute_text_value latv ON (latv.attribute_type = s.ordering_attribute AND latv.link = l.id)
    ORDER BY series, link_order;

COMMIT;

-- vi: set ts=4 sw=4 et :
