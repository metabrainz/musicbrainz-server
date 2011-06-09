package t::MusicBrainz::Server::EditSearch::Predicate::Date;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );

use aliased 'MusicBrainz::Server::EditSearch::Query';
use aliased 'MusicBrainz::Server::EditSearch::Predicate::Date' => 'Field';

test 'operator BETWEEN' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'opened' =>
        {
            operator => 'BETWEEN',
            args => [ '2010-01-01', '2011-05-01' ]
        }
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::Date', 'is a date field');
    is($field->operator, 'BETWEEN', 'handles the correct operator');
    is($field->arguments, 2, 'has correct arguments');
    my ($date1, $date2) = $field->arguments;
    isa_ok($date1, 'DateTime', 'has correct arguments');
    isa_ok($date2, 'DateTime', 'has correct arguments');

    my $query = Query->new;
    $field->combine_with_query($query);

    is_deeply([$query->join], [], 'doesnt add any new joins');
    is_deeply(
        [$query->where],
        [ { 'opened BETWEEN ? AND ?' => [ $date1, $date2 ] } ],
        'added correct WHERE clause'
    );
};

1;
