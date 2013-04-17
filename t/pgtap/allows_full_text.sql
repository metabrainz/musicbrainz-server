SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO work_attribute_type (id, name, comment, free_text)
  VALUES (1, 'with_text', '', TRUE),
         (2, 'no_text', '', FALSE);

-- Ensure that only attribute types that allow text can have text added

SELECT lives_ok(
  'INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value, work_attribute_text)
   VALUES (1, 1, 1, NULL, ''This type of attribute allows text'')');

SELECT throws_ok(
  'INSERT INTO work_attribute (id, work, work_attribute_type, work_attribute_type_allowed_value, work_attribute_text)
   VALUES (1, 1, 2, 1, ''This type of attribute does not allow text'')')

SELECT finish();
ROLLBACK;
