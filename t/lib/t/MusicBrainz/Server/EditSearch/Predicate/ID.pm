package t::MusicBrainz::Server::EditSearch::Predicate::ID;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );

use aliased 'MusicBrainz::Server::EditSearch::Query';
use aliased 'MusicBrainz::Server::EditSearch::Predicate::ID' => 'Field';

test 'operator =' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'id' =>
        {
            operator => '=',
            args => [ 59 ]
        }
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::ID', 'is an ID field');
    is_deeply([$field->arguments], [ 59 ], 'has correct arguments');
    is($field->operator, '=', 'handles the correct operator');

    my $query = Query->new( fields => [ $field ] );
    $field->combine_with_query($query);

    is_deeply([$query->where], [ [ 'edit.id = ?' => [59] ] ], 'adds a single WHERE clause');
};

1;
