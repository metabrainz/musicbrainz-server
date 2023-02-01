package t::MusicBrainz::Server::Controller::CDStub::Browse;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );
use Hook::LexWrap;

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the Browse CD Stubs page shows data as expected.

=cut

test 'Browse CD Stubs page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

    {
        # This test is dependent on the current time to generate the
        # 'x years ago' content. I'm using a lexically scoped wrapper around
        # Date::Calc::Today in order to 'lock' the date to 2012/01/01.
        # See https://metacpan.org/pod/Hook::LexWrap#Lexically-scoped-wrappers
        # -- ocharles
        my $wrapper = wrap 'Date::Calc::Today',
            post => sub {
                $_[-1] = [2012, 1, 1];
            };

        $mech->get_ok('/cdstub/browse', 'Fetched the top CD stubs page');

        $wrapper->DESTROY;
    }


    html_ok($mech->content);

    $mech->title_like(
        qr/Top CD Stubs/,
        'The page title matches the expected one',
    );
    $mech->content_like(
        qr/Test Artist/,
        'The page contains the artist name for the one existing CD stub',
    );
    $mech->content_like(
        qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/,
        'The page contains the disc id for the one existing CD stub',
    );
    $mech->content_like(
        qr/Added 12 years ago/,
        'The page contains the add date for the one existing CD stub',
    );
    $mech->content_like(
        qr/last modified 11 years ago/,
        'The page contains the last change date for the one existing CD stub',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
