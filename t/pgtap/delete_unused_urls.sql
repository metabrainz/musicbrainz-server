SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Setup
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'c63ecb0c-89af-4c26-928b-807402b1d701', 'Artist', 'Artist');

INSERT INTO artist_credit (id, artist_count, name, gid)
  VALUES (1, 1, 'Artist', '949a7fd5-fe73-3e8f-922e-01ff4ca958f7');

INSERT INTO label (id, gid, name)
  VALUES (1, '79cde6f7-80b1-45bf-9512-568bad5a54d6', 'Label');

INSERT INTO release_group (id, gid, name, artist_credit)
  VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 'Release', 1);
INSERT INTO release (id, gid, name, artist_credit, release_group)
  VALUES (1, '28cb82a8-ccd2-4168-8c39-c08594fee1d9', 'Release', 1, 1);

INSERT INTO recording (id, gid, name, artist_credit)
  VALUES (1, '603f6297-f64f-4477-b545-1bc1964d839e', 'Recording', 1);

INSERT INTO work (id, gid, name)
  VALUES (1, '6ed229cd-64b2-4029-a426-fe94f09a0875', 'Work');

INSERT INTO link (id, link_type) VALUES (1, 188);
INSERT INTO link (id, link_type) VALUES (2, 222);
INSERT INTO link (id, link_type) VALUES (3, 306);
INSERT INTO link (id, link_type) VALUES (4, 82);
INSERT INTO link (id, link_type) VALUES (5, 96);
INSERT INTO link (id, link_type) VALUES (6, 273);

INSERT INTO url (id, gid, url)
  VALUES (1, '1783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://one.com'),
         (2, '2783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://two.com'),
         (3, '3783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://three.com'),
         (4, '4783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://four.com'),
         (5, '5783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://five.com'),
         (6, '6783b91e-aebd-4cb0-b08f-8799f14d3976', 'http://six.com');

INSERT INTO l_artist_url (id, link, entity0, entity1) VALUES (1, 1, 1, 1);
INSERT INTO l_label_url (id, link, entity0, entity1) VALUES (1, 2, 1, 2);
INSERT INTO l_recording_url (id, link, entity0, entity1) VALUES (1, 3, 1, 3);
INSERT INTO l_release_url (id, link, entity0, entity1) VALUES (1, 4, 1, 4);
INSERT INTO l_release_group_url (id, link, entity0, entity1) VALUES (1, 5, 1, 5);
INSERT INTO l_url_work (id, link, entity0, entity1) VALUES (1, 6, 6, 1);

--------------------------------------------------------------------------------
-- Test
INSERT INTO url (id, gid, url)
  VALUES (7, 'd452e3e3-8386-40e0-b04f-b780be2b369a', 'http://seven.com');

UPDATE l_artist_url SET entity1 = 7;
UPDATE l_label_url SET entity1 = 7;
UPDATE l_recording_url SET entity1 = 7;
UPDATE l_release_url SET entity1 = 7;
UPDATE l_release_group_url SET entity1 = 7;
UPDATE l_url_work SET entity0 = 7;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (1), (2), (3), (4), (5), (6), (7)',
    'No URLs delete until constraint triggers fire'
);

-- Simulate the commit
SET CONSTRAINTS ALL IMMEDIATE;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (7)',
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
DELETE FROM l_url_work;

SELECT bag_eq(
    'SELECT id FROM url',
    'VALUES (7)',
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
