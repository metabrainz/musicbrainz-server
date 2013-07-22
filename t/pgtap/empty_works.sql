SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'editor', '{CLEARTEXT}pass', '3f3edade87115ce351d63f42d92a1834', '', now());
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

INSERT INTO artist (id, gid, name, sort_name, last_updated, edits_pending)
  VALUES (1, '159cb1fa-dbe9-4777-abf6-7ecb3ce84f91', 1, 1, now(), 0);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);
INSERT INTO label (id, gid, name, sort_name, last_updated, edits_pending)
  VALUES (1, '159cb1fa-dbe9-4777-abf6-7ecb3ce84f91', 1, 1, now(), 0);
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1, 1);
INSERT INTO url (id, gid, url)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 'http://google.com/');
INSERT INTO work (id, gid, name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1),
         (2, '9c172831-ff88-4eff-9c58-47fa1408b6b2', 1);

-- Disable triggers so we can actually update the last_updated field
ALTER TABLE work DISABLE TRIGGER USER;

--------------------------------------------------------------------------------
-- Newly created works are not in empty_works()
SELECT set_eq(
  'SELECT id FROM empty_works()', '{}'::INT[]
);

--------------------------------------------------------------------------------
-- Works > 1 day old are eligible for empty_works().
UPDATE work SET last_updated = '1970-01-01' WHERE id = 1;

SELECT set_eq(
  'SELECT id FROM empty_works()',
  ARRAY[ 1 ]
);

--------------------------------------------------------------------------------
-- Works with edits pending are not eligible for empty_works()
UPDATE work SET edits_pending = edits_pending + 1 WHERE id = 1;
SELECT set_eq(
  'SELECT id FROM empty_works()', '{}'::INT[]
);
UPDATE work SET edits_pending = 0;

--------------------------------------------------------------------------------
-- l_artist_work entries exclude works from empty_works()
INSERT INTO l_artist_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_works()', '{}'::INT[]
);
DELETE FROM l_artist_work;

--------------------------------------------------------------------------------
-- l_label_work entries exclude artists from empty_artists()
INSERT INTO l_label_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_label_work;

--------------------------------------------------------------------------------
-- l_recording_work entries exclude artists from empty_artists()
INSERT INTO l_recording_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_recording_work;

--------------------------------------------------------------------------------
-- l_artist_recording entries exclude artists from empty_artists()
INSERT INTO l_release_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_release_work;

--------------------------------------------------------------------------------
-- l_artist_release_group entries exclude artists from empty_artists()
INSERT INTO l_release_group_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_release_group_work;

--------------------------------------------------------------------------------
-- l_artist_url entries exclude artists from empty_artists()
INSERT INTO l_url_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_url_work;

--------------------------------------------------------------------------------
-- l_artist_work entries exclude artists from empty_artists()
INSERT INTO l_work_work (id, entity0, entity1, link) VALUES (1, 1, 2, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_work_work;

--------------------------------------------------------------------------------
-- A work with open edits linked to it is excluded from empty_works()
INSERT INTO edit_work (edit, work) VALUES (1, 1);
SELECT set_eq(
  'SELECT id FROM empty_works()', '{}'::INT[]
);

-- But edits that aren't open don't block empty_works()
UPDATE edit SET status = 2;
SELECT set_eq(
  'SELECT id FROM empty_works()', '{1}'::INT[]
);

SELECT finish();
ROLLBACK;
