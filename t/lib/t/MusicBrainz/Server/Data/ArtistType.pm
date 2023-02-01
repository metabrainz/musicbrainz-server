package t::MusicBrainz::Server::Data::ArtistType;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::ArtistType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for ArtistType.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $c);

    verify_name_and_id(1, 'Person', $at_data->get_by_id(1));
    verify_name_and_id(2, 'Group', $at_data->get_by_id(2));
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $c);

    my @requested_ids = (1, 2);
    my $ats = $at_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$ats],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'Person', $ats->{1});
    verify_name_and_id(2, 'Group', $ats->{2});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $c);

    does_ok($at_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @types = sort { $a->{id} <=> $b->{id} } $at_data->get_all;
    is(@types, 6, 'Expected number of types found');
    verify_name_and_id(1, 'Person', $types[0]);
    verify_name_and_id(2, 'Group', $types[1]);
    verify_name_and_id(3, 'Other', $types[2]);
    verify_name_and_id(4, 'Character', $types[3]);
    verify_name_and_id(5, 'Orchestra', $types[4]);
    verify_name_and_id(6, 'Choir', $types[5]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
