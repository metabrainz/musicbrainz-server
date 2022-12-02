package t::MusicBrainz::Server::Data::MediumFormat;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Data::MediumFormat;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Test::Utils qw( verify_name_and_id );

with 't::Context';

=head1 DESCRIPTION

This test checks the different getters for MediumFormat.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    my $c = $test->c;

    my $format_data = MusicBrainz::Server::Data::MediumFormat->new(c => $c);

    my $format = $format_data->get_by_id(1);
    verify_name_and_id(1, 'CD', $format);
    is ($format->year, 1982, 'Expected year 1982 found');

    $format = $format_data->get_by_id(2);
    verify_name_and_id(2, 'DVD', $format);
    is ($format->year, 1995, 'Expected year 1995 found');
};

test 'get_by_ids' => sub {
    my $test = shift;
    my $c = $test->c;

    my $format_data = MusicBrainz::Server::Data::MediumFormat->new(c => $c);

    my @requested_ids = (1, 2);

    my $formats = $format_data->get_by_ids(@requested_ids);
    cmp_bag(
        [keys %$formats],
        \@requested_ids,
        'The keys of the returned hash are the requested row ids',
    );
    verify_name_and_id(1, 'CD', $formats->{1});
    verify_name_and_id(2, 'DVD', $formats->{2});
};

test 'get_all' => sub {
    my $test = shift;
    my $c = $test->c;

    my $format_data = MusicBrainz::Server::Data::MediumFormat->new(c => $c);

    does_ok($format_data, 'MusicBrainz::Server::Data::Role::SelectAll');
    my @formats = sort { $a->{id} <=> $b->{id} } $format_data->get_all;
    is(@formats, 60, 'get_all returns all 60 formats');
    verify_name_and_id(1, 'CD', $formats[0]);
    verify_name_and_id(2, 'DVD', $formats[1]);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
