package t::MusicBrainz::Server::EditSearch::Predicate::Set;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );

use aliased 'MusicBrainz::Server::EditSearch::Query';
use aliased 'MusicBrainz::Server::EditSearch::Predicate::Set' => 'Field';

test 'operator BETWEEN' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'type' =>
        {
            operator => 'IN',
            args => [ 1, 2, 3 ]
        }
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::Set', 'is a set field');
    is($field->operator, 'IN', 'handles the correct operator');
    is($field->arguments, 3, 'has correct arguments');
    cmp_set([$field->arguments], [1, 2, 3], 'has correct arguments');

    my $query = Query->new;
    $field->combine_with_query($query);

    is_deeply([$query->join], [], 'doesnt add any new joins');
    my ($where_clause) = $query->where;
    my ($sql, $args) = %$where_clause;
    is($sql, 'type IN ( ?,?,? )');
    cmp_set($args, [1, 2, 3]);
};

1;
