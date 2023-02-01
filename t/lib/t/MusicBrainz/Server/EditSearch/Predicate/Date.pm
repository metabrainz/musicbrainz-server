package t::MusicBrainz::Server::EditSearch::Predicate::Date;
use strict;
use warnings;

use Test::Routine;
use Test::More;

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
    is_deeply(
        [ $field->arguments ],
        [ '2010-01-01', '2011-05-01' ],
        'has correct arguments');

    my $query = Query->new( fields => [ $field ] );
    $field->combine_with_query($query);

    my ($date1, $date2) = @{ $field->sql_arguments };
    is($date1, '2010-01-01 00:00:00');
    is($date2, '2011-05-01 00:00:00');

    is_deeply(
        [$query->where],
        [ [ 'edit.opened BETWEEN SYMMETRIC ? AND ?', [ $date1, $date2 ] ] ],
        'added correct WHERE clause'
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
