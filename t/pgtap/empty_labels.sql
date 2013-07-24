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
INSERT INTO release_name (id, name) VALUES (1, 'Test');
INSERT INTO track_name (id, name) VALUES (1, 'Test');
INSERT INTO work_name (id, name) VALUES (1, 'Test');

INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, '0c172831-ff88-4eff-9c58-47fa1408b6b2', 1, 1);
INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 1, 1);

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

INSERT INTO label_name (id, name) VALUES (1, 'Test Label');
INSERT INTO label (id, gid, name, sort_name, last_updated, edits_pending, comment)
  VALUES (1, '159cb1fa-dbe9-4777-abf6-7ecb3ce84f91', 1, 1, now(), 0, 'Label 1'),
         (2, 'fbbf7950-eebe-49e5-86d6-058ecc2bf4ac', 1, 1, now(), 10, 'Label 2');

-- Disable triggers so we can actually update the last_updated field
ALTER TABLE label DISABLE TRIGGER USER;

--------------------------------------------------------------------------------
-- Newly created labels are not in empty_labels()
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);

--------------------------------------------------------------------------------
-- Labels > 1 day old are eligible for empty_labels().
UPDATE label SET last_updated = '1970-01-01' WHERE id = 1;

SELECT set_eq(
  'SELECT id FROM empty_labels()',
  ARRAY[ 1 ]
);

--------------------------------------------------------------------------------
-- Labels with edits pending are not eligible for empty_labels()
UPDATE label SET edits_pending = edits_pending + 1 WHERE id = 1;
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
UPDATE label SET edits_pending = 0;

--------------------------------------------------------------------------------
-- l_artist_label entries exclude labels from empty_labels()
INSERT INTO l_artist_label (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_artist_label;

--------------------------------------------------------------------------------
-- l_label_label entries exclude labels from empty_labels()
INSERT INTO l_label_label (id, entity0, entity1, link) VALUES (1, 1, 2, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_label;

--------------------------------------------------------------------------------
-- l_label_recording entries exclude labels from empty_labels()
INSERT INTO l_label_recording (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_recording;

--------------------------------------------------------------------------------
-- l_label_recording entries exclude labels from empty_labels()
INSERT INTO l_label_release (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_release;

--------------------------------------------------------------------------------
-- l_label_release_group entries exclude labels from empty_labels()
INSERT INTO l_label_release_group (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_release_group;

--------------------------------------------------------------------------------
-- l_label_url entries exclude labels from empty_labels()
INSERT INTO l_label_url (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_url;

--------------------------------------------------------------------------------
-- l_label_work entries exclude labels from empty_labels()
INSERT INTO l_label_work (id, entity0, entity1, link) VALUES (1, 1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM l_label_work;

--------------------------------------------------------------------------------
-- A label with releases is excluded from empty_labels()
INSERT INTO release_label (id, release, label) VALUES (1, 1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);
DELETE FROM release_label;

--------------------------------------------------------------------------------
-- A label with open edits linked to it is excluded from empty_labels()
INSERT INTO edit_label (edit, label) VALUES (1, 1);
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{}'::INT[]
);

-- But edits that aren't open don't block empty_labels()
UPDATE edit SET status = 2;
SELECT set_eq(
  'SELECT id FROM empty_labels()', '{1}'::INT[]
);

SELECT finish();
ROLLBACK;
