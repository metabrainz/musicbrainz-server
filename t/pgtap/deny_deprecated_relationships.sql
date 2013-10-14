SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

--------------------------------------------------------------------------------
-- Test setup. See below for tests.
INSERT INTO link_type
    (id, name, entity_type0, entity_type1, gid, link_phrase, reverse_link_phrase,
    long_link_phrase, is_deprecated)
VALUES
    (1, 'performer', 'artist', 'artist', '0e747859-2491-4b16-8173-87d211a8f56b',
    'performer', 'performer', 'performer', FALSE),
    (2, 'composer', 'artist', 'artist', '6f68ed33-e70c-46e8-82de-3a16d2dcba26',
    'composer', 'composer', 'composer', TRUE);

SELECT lives_ok( 'INSERT INTO link (id, link_type) VALUES (1, 1)' );
SELECT throws_ok( 'UPDATE link SET link_type = 2 WHERE id = 1' );

SELECT throws_ok( 'INSERT INTO link (id, link_type) VALUES (2, 2)' );
SELECT lives_ok( 'UPDATE link_type SET is_deprecated = TRUE WHERE id = 1' );
SELECT throws_ok( 'INSERT INTO link (id, link_type) VALUES (3, 1)' );
SELECT lives_ok( 'UPDATE link SET ended = TRUE WHERE id = 1' );

SELECT finish();
ROLLBACK;
