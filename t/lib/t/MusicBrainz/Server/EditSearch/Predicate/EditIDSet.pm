package t::MusicBrainz::Server::EditSearch::Predicate::EditIDSet;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );

use aliased 'MusicBrainz::Server::EditSearch::Query';
use aliased 'MusicBrainz::Server::EditSearch::Predicate::EditIDSet' => 'Field';

test 'operator BETWEEN' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'type' =>
        {
            operator => '=',
            args => [ 1, 2, 3, 4, 5 ],
        },
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::EditIDSet');
    is($field->operator, '=', 'handles the correct operator');
    is($field->arguments, 5, 'has correct arguments');
    cmp_set([$field->arguments], [1, 2, 3, 4, 5], 'has correct arguments');
    is($field->valid, 1, 'is a valid set field');

    my $query = Query->new( fields => [ $field ] );
    $field->combine_with_query($query);

    my ($where_clause) = $query->where;
    my ($sql, $arglist) = @$where_clause;
    is($sql, 'edit.type = any(?)', 'The WHERE clause is correct');

    my @args = @$arglist;
    cmp_set(
      $args[0],
      [1, 2, 3, 4, 5],
      'The WHERE clause arguments are correct',
    );
    is(@args, 1, 'Only one array argument is passed');
};

test 'Comma-separated integer arguments are allowed' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'type' =>
        {
            operator => '=',
            args => [ 1, 2, 3, '4,5' ],
        },
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::EditIDSet');
    is($field->arguments, 4, 'has correct arguments');
    cmp_set([$field->arguments], [1, 2, 3, '4,5'], 'has correct arguments');
    is($field->valid, 1, 'is a valid set field');

    my $query = Query->new( fields => [ $field ] );
    $field->combine_with_query($query);

    my ($where_clause) = $query->where;
    my ($sql, $arglist) = @$where_clause;
    is($sql, 'edit.type = any(?)', 'The WHERE clause is correct');

    my @args = @$arglist;
    cmp_set(
      $args[0],
      [1, 2, 3, 4, 5],
      'The WHERE clause arguments are correct',
    );
    is(@args, 1, 'Only one array argument is passed');
};

test 'Other non-integer arguments are rejected' => sub {
    my $test = shift;
    my $field = Field->new_from_input(
        'type' =>
        {
            operator => '=',
            args => [ 1, 2, 3, 'undefined' ],
        },
    );

    ok(defined $field, 'did construct a field');
    isa_ok($field, 'MusicBrainz::Server::EditSearch::Predicate::EditIDSet');
    cmp_set([$field->arguments], [1, 2, 3, 'undefined'], 'has correct arguments');
    is($field->valid, 0, 'is not a valid set field');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
