package t::MusicBrainz::Server::Data::ReleaseStatus;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::ReleaseStatus;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for ReleaseStatus.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $status_data = MusicBrainz::Server::Data::ReleaseStatus->new(c => $c);

    my $status = $status_data->get_by_id(1);
    verify_name_and_id(1, 'Official', $status);
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $status_data = MusicBrainz::Server::Data::ReleaseStatus->new(c => $c);

    my @requested_ids = (1, 3);
    my $statuses = $status_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$statuses],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'Official', $statuses->{1});
    verify_name_and_id(3, 'Bootleg', $statuses->{3});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $status_data = MusicBrainz::Server::Data::ReleaseStatus->new(c => $c);

    does_ok($status_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @statuses = sort { $a->{id} <=> $b->{id} } $status_data->get_all;
    is(@statuses, 4, 'get_all returns all 4 statuses');
    verify_name_and_id(1, 'Official', $statuses[0]);
    verify_name_and_id(2, 'Promotion', $statuses[1]);
    verify_name_and_id(3, 'Bootleg', $statuses[2]);
    verify_name_and_id(4, 'Pseudo-Release', $statuses[3]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
