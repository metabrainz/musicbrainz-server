SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

SELECT lives_ok( 'INSERT INTO link (id, link_type) VALUES (1, 123)' );
SELECT throws_ok( 'UPDATE link SET link_type = 136 WHERE id = 1' );

SELECT throws_ok( 'INSERT INTO link (id, link_type) VALUES (2, 136)' );
SELECT lives_ok( 'UPDATE link_type SET is_deprecated = TRUE WHERE id = 123' );
SELECT throws_ok( 'INSERT INTO link (id, link_type) VALUES (3, 123)' );
SELECT throws_ok( 'UPDATE link SET ended = TRUE WHERE id = 1' ); -- still not OK -- link rows are immutable!

SELECT finish();
ROLLBACK;
