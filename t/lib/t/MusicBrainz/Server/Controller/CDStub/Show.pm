package t::MusicBrainz::Server::Controller::CDStub::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the page for a specific CD stub
shows data as expected.

=cut

test 'CD stub page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

    $mech->get_ok(
        '/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs-',
        'Fetched the CD stub page',
    );

    html_ok($mech->content);

    $mech->title_like(
        qr/Test Stub/,
        'The page title contains the CD stub title',
    );
    $mech->title_like(
        qr/Test Artist/,
        'The page title contains the CD stub artist',
    );
    $mech->content_like(
        qr/Test Stub/,
        'The page content contains the CD stub title',
    );
    $mech->content_like(
        qr/Test Artist/,
        'The page content contains the CD stub artist',
    );
    $mech->content_like(
        qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/,
        'The page content contains the disc id',
    );
    $mech->content_like(
        qr/Track title 1/,
        'The page content contains the first track title',
    );
    $mech->content_like(
        qr/Track title 2/,
        'The page content contains the second track title',
    );
    $mech->content_like(
        qr/837101029192/,
        'The page content contains the barcode',
    );
    $mech->content_like(
        qr/this is a comment/,
        'The page content contains the expected comment',
    );

    $mech->get_ok(
      '/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs',
      'Fetched the CD stub page, without the ending dash',
    );

    ok(
        $mech->uri =~ qr{/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/?$},
        'The user is redirected to the version with the dash',
    );
};

1;
