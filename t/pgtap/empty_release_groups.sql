SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834');
INSERT INTO edit (id, type, status, data, open_time, close_time, expire_time, editor)
  VALUES (1, 1, 1, '', now(), now(), now(), 1);

INSERT INTO link_type (id, gid, entity_type0, entity_type1, name, link_phrase,
    reverse_link_phrase, long_link_phrase)
  VALUES (1, '0059c07e-e9f5-4680-b48b-b40c6f82dd72', 'artist', 'label', '', '', '', '');
INSERT INTO link (id, link_type) VALUES (1, 1);

INSERT INTO artist_name (id, name) VALUES (1, 'Test');
INSERT INTO label_name (id, name) VALUES (1, 'Test');
INSERT INTO release_name (id, name) VALUES (1, 'Test');
INSERT INTO track_name (id, name) VALUES (1, 'Test');
INSERT INTO work_name (id, name) VALUES (1, 'Test');

INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO label (id, gid, name, sort_name)
  VALUES (1, '159cb1fa-dbe9-4777-abf6-7ecb3ce84f91', 1, 1);
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1),
         (2, '9c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1, 2);
INSERT INTO url (id, gid, url)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 'http://google.com/');
INSERT INTO work (id, gid, name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1);

-- Disable triggers so we can actually update the last_updated field
ALTER TABLE release_group DISABLE TRIGGER USER;

--------------------------------------------------------------------------------
-- Newly created release groups are not in empty_release_groups()
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);

--------------------------------------------------------------------------------
-- Release groups > 1 day old are eligible for empty_release_groups().
UPDATE release_group SET last_updated = '1970-01-01' WHERE id = 1;

SELECT set_eq(
  'SELECT id FROM release_group WHERE edits_pending = 0 AND last_updated < now() - ''1 day''::interval',
  ARRAY[ 1 ]
);

--------------------------------------------------------------------------------
-- Release groups with edits pending are not eligible for empty_release_groups()
UPDATE release_group SET edits_pending = edits_pending + 1 WHERE id = 1;
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
UPDATE release_group SET edits_pending = 0;

--------------------------------------------------------------------------------
-- l_artist_release_group entries exclude release_groups from empty_release_groups()
INSERT INTO l_artist_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_artist_release_group;

--------------------------------------------------------------------------------
-- l_label_release_group entries exclude release_groups from empty_release_groups()
INSERT INTO l_label_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_label_release_group;

--------------------------------------------------------------------------------
-- l_recording_release_group entries exclude release_groups from empty_release_groups()
INSERT INTO l_recording_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_recording_release_group;

--------------------------------------------------------------------------------
-- l_release_release_group entries exclude release_groups from empty_release_groups()
INSERT INTO l_release_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_release_release_group;

--------------------------------------------------------------------------------
-- l_release_group_release_group entries exclude release_groups from empty_release_groups()
INSERT INTO l_release_group_release_group (id, entity0, entity1, link) VALUES (1, 1, 2, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_release_group_release_group;

--------------------------------------------------------------------------------
-- l_release_group_url entries exclude release_groups from empty_release_groups()
INSERT INTO l_release_group_url (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_release_group_url;

--------------------------------------------------------------------------------
-- l_release_group_work entries exclude release_groups from empty_release_groups()
INSERT INTO l_release_group_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);
DELETE FROM l_release_group_work;

--------------------------------------------------------------------------------
-- A release_group with releases is excluded from empty_release_groups()
UPDATE release SET release_group = 1;
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM release;

--------------------------------------------------------------------------------
-- A release_group with open edits linked to it is excluded from empty_release_groups()
INSERT INTO edit_release_group (edit, release_group) VALUES (1, 1);
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{}'::INT[]
);

-- But edits that aren't open don't block empty_release_groups()
UPDATE edit SET status = 2;
SELECT set_eq(
  'SELECT id FROM empty_release_groups()', '{1}'::INT[]
);

SELECT finish();
ROLLBACK;
