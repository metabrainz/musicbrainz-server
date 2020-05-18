SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

SELECT is( musicbrainz_unaccent('foo'), 'foo' );
SELECT is( musicbrainz_unaccent('fôó'), 'foo' );
SELECT is( musicbrainz_unaccent('Diyarbakır'), 'Diyarbakir' );
SELECT is( musicbrainz_unaccent('Ænima'), 'AEnima' );
SELECT is( musicbrainz_unaccent('Пётр'), 'Петр' );

SELECT is( mb_simple_tsvector('Ænima'), '''aenima'':1' );
SELECT is( mb_simple_tsvector('Пётр'), '''петр'':1' );
SELECT is( mb_simple_tsvector('Hey'), '''hey'':1' );

SELECT finish();
ROLLBACK;
