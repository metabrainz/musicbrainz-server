package t::MusicBrainz::Server::Data::WorkType;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Moose;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::WorkType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for WorkType.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $wt_data = MusicBrainz::Server::Data::WorkType->new(c => $c);

    verify_name_and_id(1, 'Aria', $wt_data->get_by_id(1));
    verify_name_and_id(2, 'Ballet', $wt_data->get_by_id(2));
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $wt_data = MusicBrainz::Server::Data::WorkType->new(c => $c);

    my @requested_ids = (1, 2);

    my $wts = $wt_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$wts],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'Aria', $wts->{1});
    verify_name_and_id(2, 'Ballet', $wts->{2});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $wt_data = MusicBrainz::Server::Data::WorkType->new(c => $c);

    does_ok($wt_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = sort { $a->{id} <=> $b->{id} } $wt_data->get_all;
    is(@types, 29, 'get_all returns all 29 work types');
    verify_name_and_id(1, 'Aria', $types[0]);
    verify_name_and_id(2, 'Ballet', $types[1]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
