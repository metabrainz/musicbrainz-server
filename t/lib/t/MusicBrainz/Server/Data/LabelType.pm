package t::MusicBrainz::Server::Data::LabelType;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::LabelType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for LabelType.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $lt_data = MusicBrainz::Server::Data::LabelType->new(c => $c);

    verify_name_and_id(3, 'Production', $lt_data->get_by_id(3));
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $lt_data = MusicBrainz::Server::Data::LabelType->new(c => $c);

    my @requested_ids = (1, 3);

    my $lts = $lt_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$lts],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'Distributor', $lts->{1});
    verify_name_and_id(3, 'Production', $lts->{3});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $lt_data = MusicBrainz::Server::Data::LabelType->new(c => $c);

    does_ok($lt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = sort { $a->{id} <=> $b->{id} } $lt_data->get_all;
    is(@types, 9, 'get_all returns all 9 label types');
    verify_name_and_id(1, 'Distributor', $types[0]);
    verify_name_and_id(2, 'Holding', $types[1]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
