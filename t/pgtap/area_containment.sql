BEGIN;
SET search_path = musicbrainz, public;
SELECT no_plan();

PREPARE area_containment_table AS
SELECT descendant, parent, depth
FROM area_containment
ORDER BY descendant, parent, depth;

-- `all_calculated_area_containments_1` should be identical to
-- `area_containment`, as if it were implemented by a VIEW.  This gives an
-- extra check that we're materializing the table correctly.
--
-- `all_calculated_area_containments_2` is the same, but uses
-- `get_area_descendant_hierarchy_rows` instead of
-- `get_area_parent_hierarchy_rows`.  These should be equivalent, so we
-- have the tests verify this.

PREPARE all_calculated_area_containments_1 AS
SELECT DISTINCT ON (descendant, parent)
    descendant,
    parent,
    depth
  FROM get_area_parent_hierarchy_rows(NULL)
 ORDER BY descendant, parent, depth;

PREPARE all_calculated_area_containments_2 AS
SELECT DISTINCT ON (descendant, parent)
    descendant,
    parent,
    depth
  FROM get_area_descendant_hierarchy_rows(NULL)
 ORDER BY descendant, parent, depth;

SELECT results_eq(
  'area_containment_table',
  'SELECT 1 WHERE false'
);

-- Testing the behavior when changing an area-area relationship's link type
-- to/from "part of" requires a bogus link type other than "part of".

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase, reverse_link_phrase, long_link_phrase)
     VALUES (9999999, '5551a28f-0941-4bae-92de-d83deefe08f4', 'area', 'area', 'south of', 'southern areas', 'north of', 'is south of');

INSERT INTO area (id, gid, name)
     VALUES (1, 'bc074501-0435-4bbd-82ed-3e404751ea7c', 'A'),
            (2, '2f767836-4673-4692-9b72-7e41e293c89b', 'B'),
            (3, 'e3bf83a9-938a-4d98-82b0-b9f43d44fb2e', 'C'),
            (4, '77269cfb-16ce-4bdd-b23f-183a9417e3a2', 'D'),
            (5, '138827f9-9bc2-4735-a715-b1fa5255efeb', 'E');

INSERT INTO link (id, link_type)
     VALUES (1, 356), (2, 9999999);

-- Add an area part (1 > 2).

INSERT INTO l_area_area (id, link, entity0, entity1)
     VALUES (1, 1, 1, 2);

-- 1 > 2

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Add an unrelated area-area relationship.

INSERT INTO l_area_area (id, link, entity0, entity1)
     VALUES (2, 2, 2, 4);

-- 1 > 2

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Change the added relationship to "part of".

UPDATE l_area_area SET link = 1 WHERE id = 2;

-- 1 > 2 > 4

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (4::integer, 1::integer, 2::smallint),
      (4::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Reverse entity0/entity1.

UPDATE l_area_area SET entity0 = entity1, entity1 = entity0 WHERE id = 2;

-- 1 > 2
-- 4 > 2

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (2::integer, 4::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Change the link type back to "south of".

UPDATE l_area_area SET link = 2 WHERE id = 2;

-- 1 > 2

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Change the link type back to "part of" again, and reverse the entities.

UPDATE l_area_area SET link = 1, entity0 = entity1, entity1 = entity0 WHERE id = 2;

-- 1 > 2 > 4

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (4::integer, 1::integer, 2::smallint),
      (4::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Add another "part of" relationship (1 > 3).

INSERT INTO l_area_area (id, link, entity0, entity1)
     VALUES (3, 1, 1, 3);

-- 1 > 2 > 4
-- 1 > 3

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (3::integer, 1::integer, 1::smallint),
      (4::integer, 1::integer, 2::smallint),
      (4::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Change (1 > 2) to (5 > 2).
UPDATE l_area_area SET entity0 = 5 WHERE id = 1;

-- 5 > 2 > 4
-- 1 > 3

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 5::integer, 1::smallint),
      (3::integer, 1::integer, 1::smallint),
      (4::integer, 2::integer, 1::smallint),
      (4::integer, 5::integer, 2::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Delete the first "part of" relationship we added (5 > 2).
DELETE FROM l_area_area WHERE id = 1;

-- 2 > 4
-- 1 > 3

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (3::integer, 1::integer, 1::smallint),
      (4::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Create a cycle to check that our recursive queries self-terminate.

UPDATE l_area_area SET entity0 = 1, entity1 = 2 WHERE id = 2;
UPDATE l_area_area SET entity0 = 2, entity1 = 3 WHERE id = 3;
INSERT INTO l_area_area (id, link, entity0, entity1)
     VALUES (4, 1, 3, 1);

-- 1 > 2 > 3 > 1

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (1::integer, 2::integer, 2::smallint),
      (1::integer, 3::integer, 1::smallint),
      (2::integer, 1::integer, 1::smallint),
      (2::integer, 3::integer, 2::smallint),
      (3::integer, 1::integer, 2::smallint),
      (3::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Cycle test, pt. 2: link all nodes to each other bidirectionally.

INSERT INTO l_area_area (id, link, entity0, entity1)
     VALUES (5, 1, 1, 3),
            (6, 1, 2, 1),
            (7, 1, 3, 2);

-- 1 > 2
-- 2 > 1
-- 1 > 3
-- 3 > 1
-- 2 > 3
-- 3 > 2

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (1::integer, 2::integer, 1::smallint),
      (1::integer, 3::integer, 1::smallint),
      (2::integer, 1::integer, 1::smallint),
      (2::integer, 3::integer, 1::smallint),
      (3::integer, 1::integer, 1::smallint),
      (3::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Check that "duplicate" links are ignored/combined.
-- Link id=3 differs from id=1 only by begin_date_year.

INSERT INTO link (id, link_type, begin_date_year)
     VALUES (3, 356, 1999);

UPDATE l_area_area SET link = 3, entity0 = 1, entity1 = 2 WHERE entity0 = 2 AND entity1 = 1;
UPDATE l_area_area SET link = 3, entity0 = 1, entity1 = 3 WHERE entity0 = 3 AND entity1 = 1;
UPDATE l_area_area SET link = 3, entity0 = 2, entity1 = 3 WHERE entity0 = 3 AND entity1 = 2;

-- 1 > 2 (x2)
-- 1 > 3 (x2)
-- 2 > 3 (x2)

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (3::integer, 1::integer, 1::smallint),
      (3::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

-- Delete the duplicate relationships with link id=1.
-- This should be a no-op for area_containment.

DELETE FROM l_area_area WHERE link = 1;

-- 1 > 2
-- 1 > 3
-- 2 > 3

SELECT results_eq(
  'area_containment_table',
  $$
    VALUES
      (2::integer, 1::integer, 1::smallint),
      (3::integer, 1::integer, 1::smallint),
      (3::integer, 2::integer, 1::smallint)
  $$
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_1'
);

SELECT results_eq(
  'area_containment_table',
  'all_calculated_area_containments_2'
);

SELECT finish();
ROLLBACK;
