package t::MusicBrainz::Server::EditSearch::Predicate::Set;
use strict;
use warnings;

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
            operator => '=',
            args => [ 1, 2, 3, 4, 5 ]
        }
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::Set', 'is a set field');
    is($field->operator, '=', 'handles the correct operator');
    is($field->arguments, 5, 'has correct arguments');
    cmp_set([$field->arguments], [1, 2, 3, 4, 5], 'has correct arguments');
    is($field->valid, 1, 'is a valid set field');

    my $query = Query->new( fields => [ $field ] );
    $field->combine_with_query($query);

    my ($where_clause) = $query->where;
    my ($sql, $arglist) = @$where_clause;
    is($sql, 'edit.type = any(?)');

    my @args = @$arglist;
    cmp_set($args[0], [1, 2, 3, 4, 5]);
    is(@args, 1);
};

test 'Non-integer arguments are rejected' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'type' =>
        {
            operator => '=',
            args => [ 1, 2, 3, '4,5' ]
        }
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::Set', 'is a set field');
    cmp_set([$field->arguments], [1, 2, 3, '4,5'], 'has correct arguments');
    is($field->valid, 0, 'is not a valid set field');
};

1;
