SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

SELECT is( musicbrainz_unaccent('foo'), 'foo' );
SELECT is( musicbrainz_unaccent('fôó'), 'foo' );
SELECT is( musicbrainz_unaccent('Diyarbakır'), 'Diyarbakir' );
SELECT is( musicbrainz_unaccent('Ænima'), 'AEnima' );
SELECT is( musicbrainz_unaccent('Пётр'), 'Петр' );

SELECT is( ts_lexize('musicbrainz_unaccentdict', 'Ænima'), '{aenima}' );
SELECT is( ts_lexize('musicbrainz_unaccentdict', 'Пётр'), '{петр}' );
SELECT is( ts_lexize('musicbrainz_unaccentdict', 'Hey'), '{hey}' );

SELECT finish();
ROLLBACK;

