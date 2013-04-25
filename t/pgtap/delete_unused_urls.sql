SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Setup
INSERT INTO artist_name (id, name) VALUES (1, 'Artist');
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'c63ecb0c-89af-4c26-928b-807402b1d701', 1, 1);

INSERT INTO artist_credit (id, artist_count, name) VALUES (1, 1, 1);

INSERT INTO label_name (id, name) VALUES (1, 'Label');
INSERT INTO label (id, gid, name, sort_name)
  VALUES (1, '79cde6f7-80b1-45bf-9512-568bad5a54d6', 1, 1);

INSERT INTO release_name (id, name) VALUES (1, 'Release');
INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 1, 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 1, 1, 1);

INSERT INTO track_name (id, name) VALUES (1, 'Recording');
INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '603f6297-f64f-4477-b545-1bc1964d839e', 1, 1);

INSERT INTO work_name (id, name) VALUES (1, 'Work');
INSERT INTO work (id, gid, name)
  VALUES (1, '6ed229cd-64b2-4029-a426-fe94f09a0875', 1);

INSERT INTO link_type (id, name, link_phrase, long_link_phrase,
    reverse_link_phrase, gid, entity_type0, entity_type1)
  VALUES (1, '', '', '', '', '1684aa44-f019-4454-9011-eb9106bc0d60', 'artist', 'url'),
         (2, '', '', '', '', '2684aa44-f019-4454-9011-eb9106bc0d60', 'label', 'url'),
         (3, '', '', '', '', '3684aa44-f019-4454-9011-eb9106bc0d60', 'recording', 'url'),
         (4, '', '', '', '', '4684aa44-f019-4454-9011-eb9106bc0d60', 'release', 'url'),
         (5, '', '', '', '', '5684aa44-f019-4454-9011-eb9106bc0d60', 'release_group', 'url'),
         (6, '', '', '', '', '6684aa44-f019-4454-9011-eb9106bc0d60', 'url', 'url'),
         (7, '', '', '', '', '7684aa44-f019-4454-9011-eb9106bc0d60', 'work', 'url');

INSERT INTO link (id, link_type) SELECT x, x FROM generate_series(1, 7) s(x);

INSERT INTO url (id, gid, url)
  VALUES (1, '1783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://one.com'),
         (2, '2783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://two.com'),
         (3, '3783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://three.com'),
         (4, '4783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://four.com'),
         (5, '5783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://five.com'),
         (6, '6783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://six.com'),
         (7, '7783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://seven.com');

INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 1, 1);
INSERT INTO l_label_url (id, link, entity0, entity1) VALUES (1, 2, 1, 2);
INSERT INTO l_recording_url (id, link, entity0, entity1) VALUES (1, 3, 1, 3);
INSERT INTO l_release_url (id, link, entity0, entity1) VALUES (1, 4, 1, 4);
INSERT INTO l_release_group_url (id, link, entity0, entity1) VALUES (1, 5, 1, 5);
INSERT INTO l_url_url (id, link, entity0, entity1) VALUES (1, 6, 1, 6);
INSERT INTO l_url_work (id, link, entity0, entity1) VALUES (1, 7, 7, 1);

--------------------------------------------------------------------------------
-- Test
INSERT INTO url (id, gid, url)
  VALUES (8, 'd452e3e3-8386-40e0-b04f-b780be2b369a', 'http://eight.com');

UPDATE l_artist_url SET entity1 = 8;
UPDATE l_label_url SET entity1 = 8;
UPDATE l_recording_url SET entity1 = 8;
UPDATE l_release_url SET entity1 = 8;
UPDATE l_release_group_url SET entity1 = 8;
UPDATE l_url_url SET entity1 = 8;
UPDATE l_url_work SET entity0 = 8;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (1), (2), (3), (4), (5), (6), (7), (8)',
    'No URLs delete until constraint triggers fire'
);

-- Simulate the commit
SET CONSTRAINTS ALL IMMEDIATE;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (1), (8)',
    'All URLs except those in use deleted'
);

--------------------------------------------------------------------------------
-- Deleting relationships should remove unused URLs
SET CONSTRAINTS ALL DEFERRED;

DELETE FROM l_artist_url;
DELETE FROM l_label_url;
DELETE FROM l_recording_url;
DELETE FROM l_release_url;
DELETE FROM l_release_group_url;
DELETE FROM l_url_url;
DELETE FROM l_url_work;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (1), (8)',
    'All URLs except those in use deleted'
);

-- Simulate the commit
SET CONSTRAINTS ALL IMMEDIATE;

SELECT is_empty(
    'SELECT id FROM url',
    'All URLs deleted'
);

SELECT finish();
ROLLBACK;
