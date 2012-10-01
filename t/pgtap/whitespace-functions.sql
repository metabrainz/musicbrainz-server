SET search_path = 'musicbrainz', 'public';

BEGIN;
SELECT no_plan();

SELECT is(padded_by_whitespace('Hello '), TRUE, 'Trailing whitespace');
SELECT is(padded_by_whitespace(' Hello'), TRUE, 'Leading whitespace');
SELECT is(padded_by_whitespace(' Hello '), TRUE,
          'Trailing & leading whitespace');

SELECT is(padded_by_whitespace('Foo'), FALSE, 'No whitespace padding');
SELECT is(padded_by_whitespace('Foo Bar'), FALSE,
          'No padding, contains spaces');

SELECT is(whitespace_collapsed('Foo Bar'), TRUE, 'Single space is collapsed');
SELECT is(whitespace_collapsed('Foo Bar Baz Pancakes'), TRUE,
          'Multiple single spaces are collapsed');
SELECT is(whitespace_collapsed('Foo  Bar Baz Pancakes'), FALSE,
          'Double spaces are not collapsed');
SELECT is(whitespace_collapsed('Foo  Bar    Baz Pancakes'), FALSE,
          '2+ spaces are not collapsed');

SELECT is(controlled_for_whitespace('Foo Bar Baz'), TRUE);
SELECT is(controlled_for_whitespace('Foo  Bar Baz'), FALSE);
SELECT is(controlled_for_whitespace('Foo Bar  Baz'), FALSE);
SELECT is(controlled_for_whitespace(' Foo Bar Baz'), FALSE);
SELECT is(controlled_for_whitespace(' Foo Bar Baz '), FALSE);

SELECT finish();
ROLLBACK;
