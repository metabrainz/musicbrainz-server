package t::MusicBrainz::Server::Data::ReleasePackaging;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::ReleasePackaging;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for ReleasePackaging.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $packaging_data =
        MusicBrainz::Server::Data::ReleasePackaging->new(c => $c);

    my $packaging = $packaging_data->get_by_id(1);
    verify_name_and_id(1, 'Jewel Case', $packaging);
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $packaging_data =
        MusicBrainz::Server::Data::ReleasePackaging->new(c => $c);

    my @valid_ids = (1, 3);
    my @invalid_ids = (666);
    my @requested_ids = (@valid_ids, @invalid_ids);

    my $packagings = $packaging_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$packagings],
        \@valid_ids,
        'The keys of the returned hash are the requested *valid* row ids',
    );
    verify_name_and_id(1, 'Jewel Case', $packagings->{1});
    verify_name_and_id(3, 'Digipak', $packagings->{3});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $packaging_data =
        MusicBrainz::Server::Data::ReleasePackaging->new(c => $c);

    does_ok($packaging_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @packagings = sort { $a->{id} <=> $b->{id} } $packaging_data->get_all;
    is(@packagings, 6, 'get_all returns all 6 packagings');
    verify_name_and_id(1, 'Jewel Case', $packagings[0]);
    verify_name_and_id(2, 'Slim Jewel Case', $packagings[1]);
    verify_name_and_id(3, 'Digipak', $packagings[2]);
    verify_name_and_id(4, 'Cardboard/Paper Sleeve', $packagings[3]);
    verify_name_and_id(5, 'Other', $packagings[4]);
    verify_name_and_id(7, 'None', $packagings[5]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
