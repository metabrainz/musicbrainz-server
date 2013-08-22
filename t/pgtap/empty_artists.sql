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

INSERT INTO artist (id, gid, name, sort_name, last_updated, edits_pending, comment)
  VALUES (1, '159cb1fa-dbe9-4777-abf6-7ecb3ce84f91', 1, 1, now(), 0, 'Artist 1'),
         (2, 'fbbf7950-eebe-49e5-86d6-058ecc2bf4ac', 1, 1, now(), 10, 'Artist 2');
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);

INSERT INTO label (id, gid, name, sort_name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1, 1);
INSERT INTO url (id, gid, url)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 'http://google.com/');
INSERT INTO work (id, gid, name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1);

-- Disable triggers so we can actually update the last_updated field
ALTER TABLE artist DISABLE TRIGGER USER;

--------------------------------------------------------------------------------
-- Newly created artists are not in empty_artists()
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);

--------------------------------------------------------------------------------
-- Artists > 1 day old are eligible for empty_artists().
UPDATE artist SET last_updated = '1970-01-01' WHERE id = 1;

SELECT set_eq(
  'SELECT id FROM empty_artists()',
  ARRAY[ 1 ]
);

--------------------------------------------------------------------------------
-- Artists with edits pending are not eligible for empty_artists()
UPDATE artist SET edits_pending = edits_pending + 1 WHERE id = 1;
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
UPDATE artist SET edits_pending = 0;

--------------------------------------------------------------------------------
-- l_artist_artist entries exclude artists from empty_artists()
INSERT INTO l_artist_artist (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_artist;

--------------------------------------------------------------------------------
-- l_artist_label entries exclude artists from empty_artists()
INSERT INTO l_artist_label (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_label;

--------------------------------------------------------------------------------
-- l_artist_recording entries exclude artists from empty_artists()
INSERT INTO l_artist_recording (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_recording;

--------------------------------------------------------------------------------
-- l_artist_recording entries exclude artists from empty_artists()
INSERT INTO l_artist_release (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_release;

--------------------------------------------------------------------------------
-- l_artist_release_group entries exclude artists from empty_artists()
INSERT INTO l_artist_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_release_group;

--------------------------------------------------------------------------------
-- l_artist_url entries exclude artists from empty_artists()
INSERT INTO l_artist_url (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_url;

--------------------------------------------------------------------------------
-- l_artist_work entries exclude artists from empty_artists()
INSERT INTO l_artist_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM l_artist_work;

--------------------------------------------------------------------------------
-- A artist with recordings is excluded from empty_artists()
INSERT INTO artist_credit (id, artist_count, name) VALUES (2, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, join_phrase, position)
  VALUES (2, 1, 1, '', 1);

UPDATE recording SET artist_credit = 2;
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM recording;

-- A artist with releases is excluded from empty_artists()
INSERT INTO artist_credit (id, artist_count, name) VALUES (2, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, join_phrase, position)
  VALUES (2, 1, 1, '', 1);

UPDATE release SET artist_credit = 2;
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM release;

-- A artist with release groups is excluded from empty_artists()
INSERT INTO artist_credit (id, artist_count, name) VALUES (2, 1, 1);
INSERT INTO artist_credit_name (artist_credit, artist, name, join_phrase, position)
  VALUES (2, 1, 1, '', 1);

UPDATE release_group SET artist_credit = 2;
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);
DELETE FROM release_group;

--------------------------------------------------------------------------------
-- A artist with open edits linked to it is excluded from empty_artists()
INSERT INTO edit_artist (edit, artist) VALUES (1, 1);
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{}'::INT[]
);

-- But edits that aren't open don't block empty_artists()
UPDATE edit SET status = 2;
SELECT set_eq(
  'SELECT id FROM empty_artists()', '{1}'::INT[]
);

SELECT finish();
ROLLBACK;
