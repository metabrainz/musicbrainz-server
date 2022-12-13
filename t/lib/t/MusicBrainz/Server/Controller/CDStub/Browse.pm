package t::MusicBrainz::Server::Controller::CDStub::Browse;
use strict;
use warnings;

use Test::Routine;
use Date::Calc qw(N_Delta_YMD Today);
use MusicBrainz::Server::Test qw( html_ok );
use Hook::LexWrap;

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the Browse CD Stubs page shows data as expected.

=cut

test 'Browse CD Stubs page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

    my @today_YMD = Today;
    my ($added_years, undef, undef) = N_Delta_YMD(
        (2000, 1, 1),
        @today_YMD,
    );
    my ($modified_years, undef, undef) = N_Delta_YMD(
        (2001, 1, 1),
        @today_YMD,
    );

    $mech->get_ok('/cdstub/browse', 'Fetched the top CD stubs page');

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
        qr/Added $added_years years ago/,
        'The page contains the add date for the one existing CD stub',
    );
    $mech->content_like(
        qr/last modified $modified_years years ago/,
        'The page contains the last change date for the one existing CD stub',
    );
};

1;
